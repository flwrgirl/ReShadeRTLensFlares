#pragma once
namespace RTL {
bool AdaptivePreview(){return DenoiseEnabled && DenoiseMethod==0 && DenoiseRadius>0 && DenoiseStrength!=0;}
uint Hash(uint x){x^=x>>16;x*=2246822519u;x^=x>>13;x*=3266489917u;return x^(x>>16);}
float Random(uint x){return float(Hash(x)&16777215u)/16777216.0;}
float4 Random4(uint x){return float4(Random(x),Random(x+747796405u),Random(x+2891336453u),Random(x+277803737u));}
float PhotonMomentScale(){
 float ratio=TestLight?1:float(OFB2_RENDER_DIVISOR)*OFB2_RENDER_DIVISOR/(float(RTL_RENDER_DIVISOR)*RTL_RENDER_DIVISOR);
 float flux=tex2Dfetch(SourceMetaS,int2(0,0)).x*ratio*exp2(FlareExposure)/max(float(RayBudget),1);
 return 1099511627776.0/max(flux*flux,1e-24);
}
[numthreads(8,8,1)]void CS_Clear(uint3 id:SV_DispatchThreadID){
 if(id.x<_RTL_W && id.y<_RTL_H){
  tex2Dstore(AccumRU,int2(id.xy),0);tex2Dstore(AccumGU,int2(id.xy),0);tex2Dstore(AccumBU,int2(id.xy),0);
  if(AdaptivePreview()){
   tex2Dstore(PhotonMomentU,int2(id.xy),0);tex2Dstore(PhotonMomentHighU,int2(id.xy),0);
  }
 }
 if(id.y==0 && id.x<8)tex2Dstore(CountersU,int2(id.x,0),0);
}
void Accumulate(int2 p,float3 flux,uint seed,float momentScale){
 if(any(p<0)||p.x>=_RTL_W||p.y>=_RTL_H)return;
 float3 scaled=flux*FixedPointScale;
 int3 value=int3(floor(scaled+float3(Random(seed),Random(seed+1u),Random(seed+2u))));
 int r=atomicAdd(AccumRU,p,value.x),g=atomicAdd(AccumGU,p,value.y),b=atomicAdd(AccumBU,p,value.z);
 if((value.x>0 && r>2147483647-value.x)||(value.y>0 && g>2147483647-value.y)||(value.z>0 && b>2147483647-value.z)||any(scaled>2147483647.0))atomicAdd(CountersU,int2(4,0),1);
 atomicAdd(CountersU,int2(3,0),1);
 if(AdaptivePreview()){
  // Exposure-normalized, stochastically rounded second moment in two uint32
  // words. Integer atomicAdd plus carry avoids a UAV-dependent CAS retry loop,
  // which ReShade FX cannot mark allow_uav_condition for Microsoft's compiler.
  // These statistics never change the original RGB atomics or random stream.
  // Stochastic RGB rounding has variance f*(1-f)/scale^2. Include it before
  // normalizing; otherwise weak, quantized ghosts appear falsely noise-free.
  // This part is independent between wavelengths and is not multiplied by K.
  float3 fraction=frac(scaled);
  float quantum=FFT::Lum(fraction*(1-fraction))/(FixedPointScale*FixedPointScale);
  float second=floor((FFT::Lum(flux*flux)+quantum/max(float(SpectralSamples),1))*momentScale+Random(seed+2246822519u));
  float high=floor(second/4294967296.0);
  uint low=uint(second-high*4294967296.0);
  uint before=uint(atomicAdd(PhotonMomentU,p,int(low)));
  uint carry=before>4294967295u-low?1u:0u;
  uint upper=uint(high)+carry;
  if(upper!=0)atomicAdd(PhotonMomentHighU,p,int(upper));
 }
}
void Splat(float2 position,float3 flux,uint seed,float momentScale){
 float radius=SplatRadius;
 if(radius<=0)return;
 int2 low=int2(ceil(position-radius)),high=int2(floor(position+radius));
 float2 sum=0;
 [loop]for(int x=low.x;x<=high.x;++x)sum.x+=max(1-abs(float(x)-position.x)/radius,0);
 [loop]for(int y=low.y;y<=high.y;++y)sum.y+=max(1-abs(float(y)-position.y)/radius,0);
 if(sum.x*sum.y<=0)return;
 [loop]for(int y=low.y;y<=high.y;++y)[loop]for(int x=low.x;x<=high.x;++x){
  float wx=max(1-abs(float(x)-position.x)/radius,0),wy=max(1-abs(float(y)-position.y)/radius,0);
  if(wx*wy>0)Accumulate(int2(x,y),flux*(wx*wy/(sum.x*sum.y)),seed^Hash(uint(x)*1597334677u^uint(y)*3812015801u),momentScale);
 }
}
void Rays(uint3 id,bool advanced,bool barrel,bool cylindersOnly){
 if(id.x>=RTL_TRACE_WORKERS)return;
 if(tex2Dfetch(SourceMetaS,int2(0,0)).x<=0 || SpectralSamples<=0 || RayBudget<=0)return;
 float3 spectral=tex2Dfetch(SourceMetaS,int2(1,0)).rgb;
 uint frame=FreezeNoise?0:uint(FFT::FrameCount);
 int count=GhostCount();float lensRadius=EntranceRadius();
 float pupilRadius=ActiveLens().x/(2*EffectiveFNumber());
 float normalArea=_RTL_PI*pupilRadius*pupilRadius;
 float pixelRatio=float(OFB2_RENDER_DIVISOR)*OFB2_RENDER_DIVISOR/(float(RTL_RENDER_DIVISOR)*RTL_RENDER_DIVISOR);
 float momentScale=AdaptivePreview()?PhotonMomentScale():0;
 [loop]for(uint rayID=id.x;rayID<uint(RayBudget);rayID+=RTL_TRACE_WORKERS){
  uint seed=Hash(rayID^Hash(frame+uint(NoiseSeed)*747796405u));
  float2 uv;float3 colour;float sourcePDF;
  SelectSource(Random4(seed),uv,colour,sourcePDF);
  if(sourcePDF<=0)continue;
  float3 direction=SourceDirection(uv);float theta=acos(clamp(direction.z,-1,1));
  float angle=theta/MaxAngle()*(RTL_ANGLE_BINS-1);
  int bin=clamp(int(round(angle)),0,RTL_ANGLE_BINS-1);
  bool anamorphic=IsAnamorphic(LensID());
  float azimuth=atan2(direction.y,direction.x);
  float phi=(azimuth/(2*_RTL_PI)+1)*RTL_AZIMUTH_BINS;
  int azimuthBin=anamorphic?int(round(phi))%RTL_AZIMUTH_BINS:0;
  bin+=azimuthBin*RTL_ANGLE_BINS;
  float total=tex2Dfetch(GhostTotalS,int2(0,bin)).x;
  if(total<=0)continue;
  float target=Random(seed+1274126177u)*total;int low=0,high=count-1;
  while(low<high){int mid=(low+high)/2;if(tex2Dfetch(GhostCDFS,int2(mid,bin)).x<=target)low=mid+1;else high=mid;}
  int ghost=low;float current=tex2Dfetch(GhostCDFS,int2(ghost,bin)).x;
  float previous=ghost>0?tex2Dfetch(GhostCDFS,int2(ghost-1,bin)).x:0;
  float ghostPDF=(current-previous)/total;if(ghostPDF<=0)continue;
  float4 bounds=float4(-lensRadius,-lensRadius,lensRadius,lensRadius);
  // Off-screen directions beyond the table use full-domain tracing.
  if(UseBounds && angle<=RTL_ANGLE_BINS-1 && tex2Dfetch(CacheS,int2(0,0)).w==0){
   int a=clamp(int(floor(angle)),0,RTL_ANGLE_BINS-1),b=min(a+1,RTL_ANGLE_BINS-1);
   int pa=anamorphic?int(floor(phi))%RTL_AZIMUTH_BINS:0,pb=anamorphic?(pa+1)%RTL_AZIMUTH_BINS:0;
   float4 ba=tex2Dfetch(EntranceBoundsS,int2(ghost,a+pa*RTL_ANGLE_BINS)),bb=tex2Dfetch(EntranceBoundsS,int2(ghost,b+pa*RTL_ANGLE_BINS));
   bounds=float4(min(ba.xy,bb.xy),max(ba.zw,bb.zw));
   if(anamorphic){
    ba=tex2Dfetch(EntranceBoundsS,int2(ghost,a+pb*RTL_ANGLE_BINS));bb=tex2Dfetch(EntranceBoundsS,int2(ghost,b+pb*RTL_ANGLE_BINS));
    bounds=float4(min(bounds.xy,min(ba.xy,bb.xy)),max(bounds.zw,max(ba.zw,bb.zw)));
   }
  }
  float2 size=bounds.zw-bounds.xy;
  float2 entrance=lerp(bounds.xy,bounds.zw,float2(Random(seed+1831565813u),Random(seed+1367130551u)));
  // Axisymmetric optical data is bounded at azimuth zero, then rotated to
  // the actual light direction. The non-circular iris is evaluated afterward.
  if(!anamorphic){float c=cos(azimuth),s=sin(azimuth);entrance=float2(c*entrance.x-s*entrance.y,s*entrance.x+c*entrance.y);}
  float sourceScale=TestLight?1:pixelRatio;
  float3 importance=colour*(sourceScale*size.x*size.y/(normalArea*sourcePDF*ghostPDF*float(RayBudget)))*exp2(FlareExposure);
  int2 pair=GhostPair(ghost);
  [loop]for(int wave=0;wave<SpectralSamples;++wave){
   atomicAdd(CountersU,int2(0,0),1);
   float4 ray;
   if(barrel){ray=TraceBundle(entrance,direction,pair,Wavelength(wave),false);}
   else{ray=TracePath(entrance,direction,pair,Wavelength(wave),false,advanced,false,cylindersOnly);}
   if(ray.w==0){atomicAdd(CountersU,int2(2,0),1);continue;}
   atomicAdd(CountersU,int2(1,0),1);
   if(pair.x==-2)atomicAdd(CountersU,int2(5,0),1);
   float2 sensorUV=0.5-SensorFromLens(ray.xy)/SensorSize();
   float2 pixel=sensorUV*float2(BUFFER_WIDTH,BUFFER_HEIGHT)/RTL_RENDER_DIVISOR-0.5;
   float3 energy=importance*ray.z*SpectralResponse(Wavelength(wave))/max(spectral,1e-30);
   if(pair.x==-2)energy*=BarrelTint;
   if(!any(isnan(energy)) && !any(isinf(energy)))Splat(pixel,energy,seed+uint(wave)*1597334677u,momentScale);
  }
 }
}
// Constant specialization removes unused Newton/cylinder/wall code from the
// common spherical kernel. Exactly one kernel traces the full requested budget.
[numthreads(64,1,1)]void CS_Rays(uint3 id:SV_DispatchThreadID){
 if(BarrelEnabled || LensHasShapes(LensID()))return;Rays(id,false,false,false);
}
[numthreads(64,1,1)]void CS_RaysAdvanced(uint3 id:SV_DispatchThreadID){
 if(BarrelEnabled || !LensHasAspheres(LensID()))return;Rays(id,true,false,false);
}
[numthreads(64,1,1)]void CS_RaysCylinders(uint3 id:SV_DispatchThreadID){
 if(BarrelEnabled || !LensHasShapes(LensID()) || LensHasAspheres(LensID()))return;Rays(id,true,false,true);
}
[numthreads(64,1,1)]void CS_RaysBarrel(uint3 id:SV_DispatchThreadID){
 if(!BarrelEnabled)return;Rays(id,true,true,false);
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
 if(DenoiseEnabled){
  float3 previous=tex2Dfetch(FlarePreviousS,p).rgb;
  float4 oldMoment=tex2Dfetch(MomentsPreviousS,p);
  bool wasFiltering=tex2Dfetch(FilterStateS,int2(0,0)).x!=0;
  float3 moment=wasFiltering?oldMoment.rgb:previous*previous;
  float variance=0;
  if(AdaptivePreview()){
   float n=max(float(RayBudget),1);
   // Wavelengths share the same entrance draw. Cauchy's inequality bounds the
   // cross-wavelength moment without pretending these are independent rays.
   float momentLow=float(uint(tex2Dfetch(PhotonMomentS,p)));
   float momentHigh=float(uint(tex2Dfetch(PhotonMomentHighS,p)));
   float second=max(float(SpectralSamples),1)*(momentLow+momentHigh*4294967296.0)/PhotonMomentScale();
   float currentVariance=n>1?max(second-FFT::Lum(current*current)/n,0)*n/(n-1):second;
   float4 filterState=tex2Dfetch(FilterStateS,int2(0,0));
   bool knownHistory=wasFiltering && filterState.z==0 && filterState.w!=0;
   float previousVariance=knownHistory?oldMoment.w:currentVariance;
   // A frozen random stream repeats one sample; it does not gain confidence.
   variance=!knownHistory?currentVariance:FreezeNoise?lerp(currentVariance,previousVariance,weight):
    (1-weight)*(1-weight)*currentVariance+weight*weight*previousVariance;
  }
  tex2Dstore(MomentsCurrentU,p,float4(lerp(current*current,moment,weight),variance));
 }
 current=lerp(current,tex2Dfetch(FlarePreviousS,p).rgb,weight);
 tex2Dstore(FlareCurrentU,p,float4(current,1));
 tex2Dstore(FlarePreviewU,p,float4(current,1));
}
[numthreads(8,8,1)]void CS_Commit(uint3 id:SV_DispatchThreadID){
 if(id.x<_RTL_W && id.y<_RTL_H)tex2Dstore(FlarePreviousU,int2(id.xy),tex2Dfetch(FlareCurrentS,int2(id.xy)));
 if(DenoiseEnabled && id.x<_RTL_W && id.y<_RTL_H)tex2Dstore(MomentsPreviousU,int2(id.xy),tex2Dfetch(MomentsCurrentS,int2(id.xy)));
 if(id.y==0 && id.x<_RTL_PARAMETERS)tex2Dstore(ConfigPreviousU,int2(id.x,0),Parameters(id.x));
 if(id.y==0 && id.x<2)tex2Dstore(SourcePreviousU,int2(id.x,0),tex2Dfetch(SourceMetaS,int2(id.x,0)));
 if(all(id.xy==0)){
  tex2Dstore(FilterStateU,int2(0,0),float4(DenoiseEnabled,0,DenoiseMethod,AdaptivePreview()));
  tex2Dstore(HistoryStateU,int2(0,0),tex2Dfetch(HistoryNextS,int2(0,0)));
  if(tex2Dfetch(CacheS,int2(0,0)).x!=0)tex2Dstore(BoundsAnchorU,int2(0,0),float4(LensID(),ActiveZoom(),20261008,0));
 }
}
}
