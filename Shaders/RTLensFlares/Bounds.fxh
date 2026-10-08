#pragma once
namespace RTL {
float4 Parameters(int i){
 if(i==0)return float4(LensIndex,FNumber,LensScale,SensorWidth);
 if(i==1)return float4(FocusShift,ClearRadiusScale,Absorption,Dispersion);
 if(i==2)return float4(CoatingMix,CoatingIndex,CoatingThickness,BoundsPadding);
 if(i==3)return float4(BudgetExponent,UniformBudgetFraction,BrightnessBudget,UseBounds);
 if(i==4)return float4(SourceMode,DetectionRadius,DetectionContrast,DetectionMinimum);
 if(i==5)return float4(TestLight,TestPosition.x,TestPosition.y,TestPower);
 if(i==6)return float4(TestColour,FlareExposure);
 if(i==7)return float4(RayBudget,SpectralSamples,SplatRadius,FixedPointScale);
 if(i==8)return float4(SequenceOnly,NoiseSeed,FreezeNoise,Progressive);
 if(i==9)return float4(FFT::Threshold,FFT::SoftKnee,FFT::PreExposure,FFT::SourceExposure);
 if(i==10)return float4(FFT::InputSpace,FFT::MaximumSource,FFT::HighlightCompression,FFT::PerChannelThreshold);
 if(i==11)return float4(RTL_BOUND_GRID,RTL_ANGLE_BINS,RTL_RENDER_DIVISOR,20261008);
 if(i==12)return float4(LensIndex,ActiveZoom(),IsAnamorphic(LensIndex)?1:0,20261008);
 if(i==13)return float4(BarrelEnabled,BarrelRadiusScale,BarrelReflectivity,BarrelIntensity);
 if(i==14)return float4(BarrelTint,AnamorphicRotation);
 if(i==15)return float4(RTL_AZIMUTH_BINS,RTL_BOUND_WORKERS,0,0);
 return float4(_RTL_PARAMETERS,0,0,20261008);
}
[numthreads(1,1,1)]void CS_Cache(uint3 id:SV_DispatchThreadID){
 bool boundsDirty=RTForceRebuild || tex2Dfetch(ConfigPreviousS,int2(11,0)).w!=20261008;
 for(int i=0;i<3;++i)boundsDirty=boundsDirty||any(Parameters(i)!=tex2Dfetch(ConfigPreviousS,int2(i,0)));
 boundsDirty=boundsDirty||any(Parameters(11)!=tex2Dfetch(ConfigPreviousS,int2(11,0)));
 boundsDirty=boundsDirty||any(Parameters(13)!=tex2Dfetch(ConfigPreviousS,int2(13,0)))||Parameters(14).w!=tex2Dfetch(ConfigPreviousS,int2(14,0)).w||any(Parameters(15)!=tex2Dfetch(ConfigPreviousS,int2(15,0)));
 float4 zoomPrevious=tex2Dfetch(ConfigPreviousS,int2(12,0)),anchor=tex2Dfetch(BoundsAnchorS,int2(0,0));
 bool zoomChanged=ActiveZoom()!=zoomPrevious.y;
 bool moving=ZoomCount(LensIndex)>0 && zoomPrevious.x==LensIndex && zoomChanged;
 bool anchorDirty=anchor.x!=LensIndex || anchor.y!=ActiveZoom() || anchor.z!=20261008;
 boundsDirty=boundsDirty||(!moving && anchorDirty);
 bool budgetDirty=boundsDirty || any(Parameters(3)!=tex2Dfetch(ConfigPreviousS,int2(3,0))) || Parameters(8).x!=tex2Dfetch(ConfigPreviousS,int2(8,0)).x;
 bool historyDirty=boundsDirty||zoomChanged||any(Parameters(14)!=tex2Dfetch(ConfigPreviousS,int2(14,0)));
 [loop]for(int i=3;i<11;++i)historyDirty=historyDirty||any(Parameters(i)!=tex2Dfetch(ConfigPreviousS,int2(i,0)));
 tex2Dstore(CacheU,int2(0,0),float4(boundsDirty?1:0,budgetDirty?1:0,historyDirty?1:0,moving?1:0));
}
groupshared float4 BoundMin[64];
groupshared float4 BoundMax[64];
groupshared float2 EnergyReduce[64];
void BuildBounds(int ghost,int angle,uint3 tid){
 float4 low=float4(1e30,1e30,1e30,1e30),high=-low;
 float2 energy=0;
 float radius=EntranceRadius();
 float theta=MaxAngle()*float(angle%RTL_ANGLE_BINS)/float(RTL_ANGLE_BINS-1);
 float phi=2*_RTL_PI*float(angle/RTL_ANGLE_BINS)/RTL_AZIMUTH_BINS;
 float3 direction=float3(sin(theta)*float2(cos(phi),sin(phi)),cos(theta));
 int2 pair=GhostPair(ghost);
 if(ghost<GhostCount()){
  [loop]for(uint k=tid.x;k<RTL_BOUND_GRID*RTL_BOUND_GRID;k+=64){
   float2 xy=((float2(k%RTL_BOUND_GRID,k/RTL_BOUND_GRID)+0.5)/RTL_BOUND_GRID*2-1)*radius;
   [loop]for(int wave=0;wave<3;++wave){
    float4 ray=TraceBundle(xy,direction,pair,lerp(420.0,680.0,float(wave)*0.5),true);
    if(ray.w>0){low=min(low,float4(xy,ray.xy));high=max(high,float4(xy,ray.xy));energy+=float2(ray.z,1);}
   }
  }
 }
 BoundMin[tid.x]=low;BoundMax[tid.x]=high;EnergyReduce[tid.x]=energy;barrier();
 for(uint stride=32;stride>0;stride>>=1){
  if(tid.x<stride){BoundMin[tid.x]=min(BoundMin[tid.x],BoundMin[tid.x+stride]);BoundMax[tid.x]=max(BoundMax[tid.x],BoundMax[tid.x+stride]);EnergyReduce[tid.x]+=EnergyReduce[tid.x+stride];}barrier();
 }
 if(tid.x==0){
  float2 e=EnergyReduce[0];float4 lo=BoundMin[0],hi=BoundMax[0];
  float cell=2*radius/RTL_BOUND_GRID,padding=cell*BoundsPadding;
  float4 bounds=float4(lo.xy-padding,hi.xy+padding);
  // No probe hit: retain the whole entrance domain and exploratory probability.
  if(e.y==0)bounds=float4(-radius,-radius,radius,radius);
  bounds.xy=max(bounds.xy,-radius);bounds.zw=min(bounds.zw,radius);
  float total=e.x/(RTL_BOUND_GRID*RTL_BOUND_GRID*3)*4*radius*radius;
  if(e.y==0 && ghost<GhostCount())total=BarePairEstimate(pair)*4*radius*radius;
  tex2Dstore(EntranceBoundsU,int2(ghost,angle),bounds);
  tex2Dstore(SensorBoundsU,int2(ghost,angle),e.y>0?float4(lo.zw,hi.zw):0);
  tex2Dstore(BundleEnergyU,int2(ghost,angle),float4(total,e.y/(RTL_BOUND_GRID*RTL_BOUND_GRID*3),e.y==0?1:0,0));
 }
 barrier();
}
[numthreads(64,1,1)]void CS_Bounds(uint3 gid:SV_GroupID,uint3 tid:SV_GroupThreadID){
 if(tex2Dfetch(CacheS,int2(0,0)).x==0)return;
 int slices=IsAnamorphic(LensIndex)?RTL_AZIMUTH_BINS:1;
 [loop]for(int ghost=int(gid.x);ghost<_RTL_GHOSTS;ghost+=(RTL_BOUND_WORKERS+63)/64){
  [loop]for(int phi=0;phi<slices;++phi)BuildBounds(ghost,int(gid.y)+phi*RTL_ANGLE_BINS,tid);
  if(slices==1 && tid.x==0){[loop]for(int phi=1;phi<RTL_AZIMUTH_BINS;++phi){
   int2 location=int2(ghost,int(gid.y)+phi*RTL_ANGLE_BINS);
   tex2Dstore(EntranceBoundsU,location,0);tex2Dstore(SensorBoundsU,location,0);tex2Dstore(BundleEnergyU,location,0);
  }}
 }
}
groupshared float GhostScan[_RTL_GHOST_SCAN];
groupshared float BudgetReduce[64];
void BuildGhostCDF(int angle,uint3 tid){
 int n=GhostCount();
 // Uniform rows keep diagnostics normalized for inactive symmetric slices.
 // They do not need the 64 redundant per-row subtotal scans used in v1.2.
 float partial=0;
 if(IsAnamorphic(LensIndex) || angle<RTL_ANGLE_BINS){
  for(int i=int(tid.x);i<n;i+=64)partial+=pow(max(tex2Dfetch(BundleEnergyS,int2(i,angle)).x,1e-30),BudgetExponent);
 }else{partial=float(n)*pow(1e-30,BudgetExponent)/64;}
 BudgetReduce[tid.x]=partial;barrier();
 for(uint stride=32;stride>0;stride>>=1){if(tid.x<stride)BudgetReduce[tid.x]+=BudgetReduce[tid.x+stride];barrier();}
 if(LensIndex<2 && tid.x==0 && angle<RTL_ANGLE_BINS){
  // Retain the original rounding for existing Tessar/Minolta renders.
  float serial=0;for(int i=0;i<n;++i)serial+=pow(max(tex2Dfetch(BundleEnergyS,int2(i,angle)).x,1e-30),BudgetExponent);
  BudgetReduce[0]=serial;
 }
 barrier();float subtotal=BudgetReduce[0];
 for(uint g=tid.x;g<_RTL_GHOST_SCAN;g+=64){
  float w=0;
  if(g<n){
   float e=pow(max(tex2Dfetch(BundleEnergyS,int2(g,angle)).x,1e-30),BudgetExponent);
   w=BrightnessBudget?lerp(e/subtotal,1.0/n,UniformBudgetFraction):1.0/n;
   if(SequenceOnly>=0)w=int(g)==SequenceOnly?1:0;
  }
  GhostScan[g]=w;
 }
 barrier();
 if(tid.x==0){
  // The cached per-angle prefix has only one entry per sequence. A single
  // lane avoids cross-chunk synchronization and supports any catalog size.
  float sum=0;
  [loop]for(int g=0;g<n;++g){sum+=GhostScan[g];tex2Dstore(GhostCDFU,int2(g,angle),float4(sum,0,0,0));}
  for(int g=n;g<_RTL_GHOSTS;++g)tex2Dstore(GhostCDFU,int2(g,angle),float4(sum,0,0,0));
  tex2Dstore(GhostTotalU,int2(0,angle),float4(sum,0,0,0));
 }
 barrier();
}
[numthreads(64,1,1)]void CS_GhostCDF(uint3 gid:SV_GroupID,uint3 tid:SV_GroupThreadID){
 if(tex2Dfetch(CacheS,int2(0,0)).y==0)return;
 [loop]for(int phi=0;phi<RTL_AZIMUTH_BINS;++phi)BuildGhostCDF(int(gid.y)+phi*RTL_ANGLE_BINS,tid);
}

}
