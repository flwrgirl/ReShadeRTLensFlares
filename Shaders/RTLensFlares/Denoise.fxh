#pragma once
// Original temporal preview implementation. No photon statistics, motion
// estimation, multiscale blur or filtered feedback into raw accumulation.
namespace RTL {
float3 PreviewSample(int2 p){
 return float3(tex2Dfetch(AccumRS,p),tex2Dfetch(AccumGS,p),tex2Dfetch(AccumBS,p))/FixedPointScale;
}
float3 PreviewToYCoCg(float3 rgb){
 return float3(dot(rgb,float3(0.25,0.5,0.25)),0.5*(rgb.r-rgb.b),0.5*rgb.g-0.25*(rgb.r+rgb.b));
}
float3 PreviewFromYCoCg(float3 v){return float3(v.x+v.y-v.z,v.x+v.z,v.x-v.y-v.z);}
groupshared float3 PreviewTile[100];
groupshared float3 PreviewRGB[100];
void LoadPreviewTile(uint3 gid,uint3 tid){
  uint lane=tid.y*8+tid.x;
  [loop]for(uint i=lane;i<100;i+=64){
   int2 q=int2(gid.xy)*8+int2(i%10,i/10)-1;
   q=clamp(q,int2(0,0),int2(_RTL_W-1,_RTL_H-1));
   PreviewRGB[i]=PreviewSample(q);
   PreviewTile[i]=PreviewToYCoCg(PreviewRGB[i]);
  }
  // Border lanes must participate before out-of-range threads return.
  barrier();
}
float3 TemporalPreviewColour(int2 p,float3 currentSample,uint3 tid,bool clipHistory){
 float4 state=tex2Dfetch(FilterNextS,int2(0,0));
 float3 filtered=currentSample;
 if(state.x!=0){
  float3 history=tex2Dfetch(MomentsPreviousS,p).rgb;
  if(clipHistory){
   float3 mean=0,second=0;
   [unroll]for(int y=0;y<3;++y)[unroll]for(int x=0;x<3;++x){
    float3 colour=PreviewTile[(tid.y+y)*10+tid.x+x];
    mean+=colour;second+=colour*colour;
   }
   mean/=9;second/=9;
   float3 extent=abs(DenoiseNoise)*sqrt(max(second-mean*mean,0));
   float3 centre=PreviewToYCoCg(currentSample);
   float3 low=min(mean-extent,centre),high=max(mean+extent,centre);
   float3 boxCentre=(low+high)*0.5,halfSize=(high-low)*0.5;
   float3 delta=PreviewToYCoCg(history)-boxCentre;
   float3 normalized=abs(delta)/max(halfSize,1e-20);
   float distance=max(normalized.x,max(normalized.y,normalized.z));
   if(distance>1)history=max(PreviewFromYCoCg(clamp(boxCentre+delta/distance,low,high)),0);
  }
  filtered=lerp(currentSample,history,state.x);
 }
 tex2Dstore(MomentsCurrentU,p,float4(filtered,state.y));
 return filtered;
}
#include "DenoiseLocal.fxh"
[numthreads(8,8,1)]void CS_PreviewFilter(uint3 id:SV_DispatchThreadID){PreviewLocal(id);}
}
