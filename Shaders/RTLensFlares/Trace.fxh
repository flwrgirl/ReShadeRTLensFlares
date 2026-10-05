#pragma once
namespace RTL {
uint Hash(uint x){x^=x>>16;x*=2246822519u;x^=x>>13;x*=3266489917u;return x^(x>>16);}
float Random(uint x){return float(Hash(x)&16777215u)/16777216.0;}
float4 Random4(uint x){return float4(Random(x),Random(x+747796405u),Random(x+2891336453u),Random(x+277803737u));}
[numthreads(8,8,1)]void CS_Clear(uint3 id:SV_DispatchThreadID){
 if(id.x<_RTL_W && id.y<_RTL_H){tex2Dstore(AccumRU,int2(id.xy),0);tex2Dstore(AccumGU,int2(id.xy),0);tex2Dstore(AccumBU,int2(id.xy),0);}
 if(id.y==0 && id.x<8)tex2Dstore(CountersU,int2(id.x,0),0);
}
void Accumulate(int2 p,float3 flux,uint seed){
 if(any(p<0)||p.x>=_RTL_W||p.y>=_RTL_H)return;
 float3 scaled=flux*FixedPointScale;
 int3 value=int3(floor(scaled+float3(Random(seed),Random(seed+1u),Random(seed+2u))));
 int r=atomicAdd(AccumRU,p,value.x),g=atomicAdd(AccumGU,p,value.y),b=atomicAdd(AccumBU,p,value.z);
 if((value.x>0 && r>2147483647-value.x)||(value.y>0 && g>2147483647-value.y)||(value.z>0 && b>2147483647-value.z)||any(scaled>2147483647.0))atomicAdd(CountersU,int2(4,0),1);
 atomicAdd(CountersU,int2(3,0),1);
}
void Splat(float2 position,float3 flux,uint seed){
 float radius=SplatRadius;
 if(radius<=0)return;
 int2 low=int2(ceil(position-radius)),high=int2(floor(position+radius));
 float2 sum=0;
 [loop]for(int x=low.x;x<=high.x;++x)sum.x+=max(1-abs(float(x)-position.x)/radius,0);
 [loop]for(int y=low.y;y<=high.y;++y)sum.y+=max(1-abs(float(y)-position.y)/radius,0);
 if(sum.x*sum.y<=0)return;
 [loop]for(int y=low.y;y<=high.y;++y)[loop]for(int x=low.x;x<=high.x;++x){
  float wx=max(1-abs(float(x)-position.x)/radius,0),wy=max(1-abs(float(y)-position.y)/radius,0);
  if(wx*wy>0)Accumulate(int2(x,y),flux*(wx*wy/(sum.x*sum.y)),seed^Hash(uint(x)*1597334677u^uint(y)*3812015801u));
 }
}
[numthreads(64,1,1)]void CS_Rays(uint3 id:SV_DispatchThreadID){
 if(id.x>=RTL_TRACE_WORKERS)return;
 if(tex2Dfetch(SourceMetaS,int2(0,0)).x<=0 || SpectralSamples<=0 || RayBudget<=0)return;
 float3 spectral=tex2Dfetch(SourceMetaS,int2(1,0)).rgb;
 uint frame=FreezeNoise?0:uint(FFT::FrameCount);
 int count=GhostCount();float lensRadius=EntranceRadius();
 float pupilRadius=ActiveLens().x/(2*EffectiveFNumber());
 float normalArea=_RTL_PI*pupilRadius*pupilRadius;
 float pixelRatio=float(OFB2_RENDER_DIVISOR)*OFB2_RENDER_DIVISOR/(float(RTL_RENDER_DIVISOR)*RTL_RENDER_DIVISOR);
 [loop]for(uint rayID=id.x;rayID<uint(RayBudget);rayID+=RTL_TRACE_WORKERS){
  uint seed=Hash(rayID^Hash(frame+uint(NoiseSeed)*747796405u));
  float2 uv;float3 colour;float sourcePDF;
  SelectSource(Random4(seed),uv,colour,sourcePDF);
  if(sourcePDF<=0)continue;
  float3 direction=SourceDirection(uv);float theta=acos(clamp(direction.z,-1,1));
  float angle=theta/MaxAngle()*(RTL_ANGLE_BINS-1);
  int bin=clamp(int(round(angle)),0,RTL_ANGLE_BINS-1);
  float total=tex2Dfetch(GhostTotalS,int2(0,bin)).x;
  if(total<=0)continue;
  float target=Random(seed+1274126177u)*total;int low=0,high=count-1;
  while(low<high){int mid=(low+high)/2;if(tex2Dfetch(GhostCDFS,int2(mid,bin)).x<=target)low=mid+1;else high=mid;}
  int ghost=low;float current=tex2Dfetch(GhostCDFS,int2(ghost,bin)).x;
  float previous=ghost>0?tex2Dfetch(GhostCDFS,int2(ghost-1,bin)).x:0;
  float ghostPDF=(current-previous)/total;if(ghostPDF<=0)continue;
  float4 bounds=float4(-lensRadius,-lensRadius,lensRadius,lensRadius);
  // Off-screen directions beyond the table use full-domain tracing.
  if(UseBounds && angle<=RTL_ANGLE_BINS-1){
   int a=clamp(int(floor(angle)),0,RTL_ANGLE_BINS-1),b=min(a+1,RTL_ANGLE_BINS-1);
   float4 ba=tex2Dfetch(EntranceBoundsS,int2(ghost,a)),bb=tex2Dfetch(EntranceBoundsS,int2(ghost,b));
   bounds=float4(min(ba.xy,bb.xy),max(ba.zw,bb.zw));
  }
  float2 size=bounds.zw-bounds.xy;
  float2 entrance=lerp(bounds.xy,bounds.zw,float2(Random(seed+1831565813u),Random(seed+1367130551u)));
  // Axisymmetric optical data is bounded at azimuth zero, then rotated to
  // the actual light direction. The non-circular iris is evaluated afterward.
  float azimuth=atan2(direction.y,direction.x),c=cos(azimuth),s=sin(azimuth);
  entrance=float2(c*entrance.x-s*entrance.y,s*entrance.x+c*entrance.y);
  float sourceScale=TestLight?1:pixelRatio;
  float3 importance=colour*(sourceScale*size.x*size.y/(normalArea*sourcePDF*ghostPDF*float(RayBudget)))*exp2(FlareExposure);
  int2 pair=GhostPair(ghost);
  [loop]for(int wave=0;wave<SpectralSamples;++wave){
   atomicAdd(CountersU,int2(0,0),1);
   float4 ray=TraceBundle(entrance,direction,pair,Wavelength(wave),false);
   if(ray.w==0){atomicAdd(CountersU,int2(2,0),1);continue;}
   atomicAdd(CountersU,int2(1,0),1);
   float2 sensorUV=0.5-ray.xy/SensorSize();
   float2 pixel=sensorUV*float2(BUFFER_WIDTH,BUFFER_HEIGHT)/RTL_RENDER_DIVISOR-0.5;
   float3 energy=importance*ray.z*SpectralResponse(Wavelength(wave))/max(spectral,1e-30);
   if(!any(isnan(energy)) && !any(isinf(energy)))Splat(pixel,energy,seed+uint(wave)*1597334677u);
  }
 }
}
[numthreads(1,1,1)]void CS_HistoryState(uint3 id:SV_DispatchThreadID){
 float4 previous=tex2Dfetch(SourcePreviousS,int2(0,0)),current=tex2Dfetch(SourceMetaS,int2(0,0));
 float4 state=tex2Dfetch(HistoryStateS,int2(0,0));
 bool valid=state.w==8729 && state.x==float(FFT::FrameCount-1);
 float energyChange=abs(current.x-previous.x)/max(max(current.x,previous.x),1e-30);
 valid=valid && energyChange<0.05 && length(current.yz-previous.yz)<MotionTolerance && abs(current.w-previous.w)<MotionTolerance;
 valid=valid && tex2Dfetch(CacheS,int2(0,0)).z==0 && !FFT::Dirty();
 float frames=valid?state.y+1:1;
 float weight=valid?(Progressive?(frames-1)/frames:TemporalWeight):0;
 if(current.x<=0)weight=0;
 tex2Dstore(HistoryNextU,int2(0,0),float4(FFT::FrameCount,frames,weight,8729));
}
[numthreads(8,8,1)]void CS_Resolve(uint3 id:SV_DispatchThreadID){
 if(id.x>=_RTL_W||id.y>=_RTL_H)return;
 int2 p=int2(id.xy);
 float3 current=float3(tex2Dfetch(AccumRS,p),tex2Dfetch(AccumGS,p),tex2Dfetch(AccumBS,p))/FixedPointScale;
 float weight=tex2Dfetch(HistoryNextS,int2(0,0)).z;
 current=lerp(current,tex2Dfetch(FlarePreviousS,p).rgb,weight);
 tex2Dstore(FlareCurrentU,p,float4(current,1));
}
[numthreads(8,8,1)]void CS_Commit(uint3 id:SV_DispatchThreadID){
 if(id.x<_RTL_W && id.y<_RTL_H)tex2Dstore(FlarePreviousU,int2(id.xy),tex2Dfetch(FlareCurrentS,int2(id.xy)));
 if(id.y==0 && id.x<12)tex2Dstore(ConfigPreviousU,int2(id.x,0),Parameters(id.x));
 if(id.y==0 && id.x<2)tex2Dstore(SourcePreviousU,int2(id.x,0),tex2Dfetch(SourceMetaS,int2(id.x,0)));
 if(all(id.xy==0))tex2Dstore(HistoryStateU,int2(0,0),tex2Dfetch(HistoryNextS,int2(0,0)));
}
}
