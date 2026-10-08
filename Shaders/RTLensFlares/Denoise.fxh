#pragma once
// Original reconstruction code inspired by variance-guided a-trous filtering.
// Operates on flare radiance, without geometry/depth guides or reprojection.
namespace RTL {
bool FilterHasSignal(){
 return tex2Dfetch(CountersS,int2(3,0))>0 || tex2Dfetch(HistoryNextS,int2(0,0)).z!=0;
}
[numthreads(8,8,1)]void CS_PreviewNoise(uint3 id:SV_DispatchThreadID){
 if(!AdaptivePreview() || id.x>=_RTL_W || id.y>=_RTL_H || !FilterHasSignal())return;
 int2 p=int2(id.xy);float3 center=tex2Dfetch(FlareCurrentS,p).rgb;
 float3 mean=0;float deviation=0,total=0;
 // The guide uses actual photon noise, not spatial gradients. Splat neighbours
 // are correlated, so sum standard deviations for a conservative guide bound.
 [unroll]for(int y=-1;y<=1;++y)[unroll]for(int x=-1;x<=1;++x){
  int2 q=p+int2(x,y);if(any(q<0) || q.x>=_RTL_W || q.y>=_RTL_H)continue;
  float weight=(x==0?2:1)*(y==0?2:1);
  float3 colour=tex2Dfetch(FlareCurrentS,q).rgb;
  mean+=colour*weight;deviation+=sqrt(max(tex2Dfetch(MomentsCurrentS,q).w,0))*weight;total+=weight;
 }
 mean/=total;deviation/=total;
 // A noise-free guide must not hide a thin, fully resolved optical feature.
 if(deviation==0)mean=center;
 float variance=max(tex2Dfetch(MomentsCurrentS,p).w,0);
 tex2Dstore(DenoiseGuideU,p,float4(mean,deviation*deviation));
 tex2Dstore(DenoiseWorkAU,p,float4(center,variance));
}
float4 PreviewWavelet(sampler2D source,int2 p,int step,bool first){
 float4 center=tex2Dfetch(source,p);
 float4 centerGuide=first?tex2Dfetch(DenoiseGuideS,p):center;
 float3 sum=0;float total=0,variance=0;
 int radius=DenoiseRadius;
 [loop]for(int y=-radius;y<=radius;++y)[loop]for(int x=-radius;x<=radius;++x){
  int2 q=p+int2(x,y)*step;if(any(q<0) || q.x>=_RTL_W || q.y>=_RTL_H)continue;
  float4 other=tex2Dfetch(source,q);
  float4 guide=first?tex2Dfetch(DenoiseGuideS,q):other;
  float l0=FFT::Lum(centerGuide.rgb),l1=FFT::Lum(guide.rgb);
  float sigma=sqrt(max(centerGuide.w+guide.w,0))*abs(DenoiseNoise);
  // A small relative floor keeps stable gradients from breaking into bands.
  sigma+=0.02*abs(l0+l1)+1e-20;
  float3 difference=centerGuide.rgb-guide.rgb;
  float distance=sqrt(max(FFT::Lum(difference*difference),0));
  float range=exp(-DenoiseEdge*distance/sigma);
  float spatial=exp(-2*float(x*x+y*y)/float(radius*radius));
  float weight=spatial*range;
  sum+=other.rgb*weight;total+=weight;variance+=other.w*weight*weight;
 }
 return total>0?float4(sum/total,variance/(total*total)):center;
}
[numthreads(8,8,1)]void CS_PreviewWaveletA1(uint3 id:SV_DispatchThreadID){
 if(!AdaptivePreview() || id.x>=_RTL_W || id.y>=_RTL_H || !FilterHasSignal())return;
 tex2Dstore(DenoiseWorkBU,int2(id.xy),PreviewWavelet(DenoiseWorkAS,int2(id.xy),1,true));
}
[numthreads(8,8,1)]void CS_PreviewWaveletB2(uint3 id:SV_DispatchThreadID){
 if(!AdaptivePreview() || id.x>=_RTL_W || id.y>=_RTL_H || !FilterHasSignal())return;
 tex2Dstore(DenoiseWorkAU,int2(id.xy),PreviewWavelet(DenoiseWorkBS,int2(id.xy),2,false));
}
[numthreads(8,8,1)]void CS_PreviewWaveletA4(uint3 id:SV_DispatchThreadID){
 if(!AdaptivePreview() || id.x>=_RTL_W || id.y>=_RTL_H || !FilterHasSignal())return;
 tex2Dstore(DenoiseWorkBU,int2(id.xy),PreviewWavelet(DenoiseWorkAS,int2(id.xy),4,false));
}
[numthreads(8,8,1)]void CS_PreviewWaveletB8(uint3 id:SV_DispatchThreadID){
 if(!AdaptivePreview() || id.x>=_RTL_W || id.y>=_RTL_H || !FilterHasSignal())return;
 tex2Dstore(DenoiseWorkAU,int2(id.xy),PreviewWavelet(DenoiseWorkBS,int2(id.xy),8,false));
}
groupshared float3 PreviewRawFlux[256];
groupshared float3 PreviewFilteredFlux[256];
[numthreads(256,1,1)]void CS_PreviewEnergy(uint3 id:SV_DispatchThreadID){
 if(!AdaptivePreview() || !FilterHasSignal())return;
 float3 raw=0,filtered=0;
 [loop]for(uint i=id.x;i<uint(_RTL_W)*uint(_RTL_H);i+=256){
  int2 p=int2(i%_RTL_W,i/_RTL_W);
  raw+=tex2Dfetch(FlareCurrentS,p).rgb;
  filtered+=tex2Dfetch(DenoiseWorkAS,p).rgb;
 }
 PreviewRawFlux[id.x]=raw;PreviewFilteredFlux[id.x]=filtered;barrier();
 [unroll]for(uint stride=128;stride>0;stride>>=1){
  if(id.x<stride){PreviewRawFlux[id.x]+=PreviewRawFlux[id.x+stride];PreviewFilteredFlux[id.x]+=PreviewFilteredFlux[id.x+stride];}
  barrier();
 }
 if(id.x==0){
  float3 scale=1;
  [unroll]for(int channel=0;channel<3;++channel)if(PreviewFilteredFlux[0][channel]!=0)scale[channel]=PreviewRawFlux[0][channel]/PreviewFilteredFlux[0][channel];
  tex2Dstore(DenoiseEnergyU,int2(0,0),float4(scale,1));
 }
}

#include "DenoiseLocal.fxh"
[numthreads(8,8,1)]void CS_PreviewFilter(uint3 id:SV_DispatchThreadID){
 if(!DenoiseEnabled || id.x>=_RTL_W || id.y>=_RTL_H)return;
 if(DenoiseMethod==1){PreviewLocal(id);return;}
 if(!AdaptivePreview() || !FilterHasSignal())return;
 int2 p=int2(id.xy);float3 center=tex2Dfetch(FlareCurrentS,p).rgb;
 float3 filtered=tex2Dfetch(DenoiseWorkAS,p).rgb*tex2Dfetch(DenoiseEnergyS,int2(0,0)).rgb;
 float frames=tex2Dfetch(HistoryNextS,int2(0,0)).y;
 float amount=DenoiseStrength/(Progressive && !FreezeNoise?sqrt(max(frames,1)):1);
 tex2Dstore(FlarePreviewU,p,float4(lerp(center,filtered,amount),1));
}
}
