#pragma once
namespace RTL {
groupshared float SourceScan[256];
groupshared float4 SourceMoments[256];
void ScanSourceWeights(uint lane){
 barrier();
 for(uint offset=1;offset<256;offset<<=1){
  float add=lane>=offset?SourceScan[lane-offset]:0;barrier();
  SourceScan[lane]+=add;barrier();
 }
 // Floating-point association can make zero-weight plateaus fall by one ULP.
 // The prefix maximum keeps binary-search CDFs monotone, including black padding.
 for(uint offset=1;offset<256;offset<<=1){
  float previous=lane>=offset?SourceScan[lane-offset]:0;barrier();
  SourceScan[lane]=max(SourceScan[lane],previous);barrier();
 }
}
float SourceFootprint(int2 p){
 float2 extent=min(float2(OFB2_RENDER_DIVISOR,OFB2_RENDER_DIVISOR),float2(BUFFER_WIDTH,BUFFER_HEIGHT)-float2(p)*OFB2_RENDER_DIVISOR);
 return extent.x*extent.y/(OFB2_RENDER_DIVISOR*OFB2_RENDER_DIVISOR);
}
float2 SourceCentre(int2 p){
 float2 extent=min(float2(OFB2_RENDER_DIVISOR,OFB2_RENDER_DIVISOR),float2(BUFFER_WIDTH,BUFFER_HEIGHT)-float2(p)*OFB2_RENDER_DIVISOR);
 return (float2(p)*OFB2_RENDER_DIVISOR+extent*0.5)/float2(BUFFER_WIDTH,BUFFER_HEIGHT);
}
[numthreads(256,1,1)]void CS_PixelCDF(uint3 gid:SV_GroupID,uint3 tid:SV_GroupThreadID){
 int2 tile=int2(gid.xy),p=tile*16+int2(tid.x%16,tid.x/16);
 float value=0;
 if(p.x<_RTL_SW && p.y<_RTL_SH)value=FFT::Lum(tex2Dfetch(FFT::SourceS,p).rgb)*SourceFootprint(p);
 float2 uv=SourceCentre(p);
 SourceMoments[tid.x]=float4(value,value*uv,value*dot(uv,uv));
 SourceScan[tid.x]=value;ScanSourceWeights(tid.x);
 tex2Dstore(PixelCDFU,p,float4(SourceScan[tid.x],0,0,0));
 for(uint stride=128;stride>0;stride>>=1){if(tid.x<stride)SourceMoments[tid.x]+=SourceMoments[tid.x+stride];barrier();}
 if(tid.x==0){SourceMoments[0].x=SourceScan[255];tex2Dstore(TileRawU,tile,SourceMoments[0]);}
}
[numthreads(64,1,1)]void CS_DetectLights(uint3 id:SV_DispatchThreadID){
 uint t=id.x;if(t>=_RTL_TILES)return;
 int2 tile=int2(t%_RTL_TX,t/_RTL_TX),base=tile*16;
 float peak=0,total=0;int count=0;int2 maximum=base;
 [loop]for(int k=0;k<256;++k){
  int2 p=base+int2(k%16,k/16);if(p.x>=_RTL_SW||p.y>=_RTL_SH)continue;
  float l=FFT::Lum(tex2Dfetch(FFT::SourceS,p).rgb);total+=l;++count;
  if(l>peak){peak=l;maximum=p;}
 }
 float3 colour=0;float2 centre=0;float luminance=0;
 if(peak>=DetectionMinimum && peak>=total/max(count,1)*DetectionContrast){
  [loop]for(int k=0;k<256;++k){
   int2 p=base+int2(k%16,k/16);if(p.x>=_RTL_SW||p.y>=_RTL_SH)continue;
   if(DetectionRadius>0 && length(float2(p-maximum))>DetectionRadius)continue;
   float3 rgb=tex2Dfetch(FFT::SourceS,p).rgb*SourceFootprint(p);float l=FFT::Lum(rgb);
   colour+=rgb;centre+=SourceCentre(p)*l;luminance+=l;
  }
 }
 centre=luminance>0?centre/luminance:SourceCentre(maximum);
 float2 uv=centre;
 tex2Dstore(LightDataU,tile,float4(uv,luminance,peak));
 tex2Dstore(LightColourU,tile,float4(colour,1));
}
[numthreads(256,1,1)]void CS_TileCDF(uint3 gid:SV_GroupID,uint3 tid:SV_GroupThreadID){
 uint tile=gid.x*256+tid.x;float value=0;float2 uv=0;
 if(tile<_RTL_TILES){
  int2 t=int2(tile%_RTL_TX,tile/_RTL_TX);
  float4 light=tex2Dfetch(LightDataS,t);
  float4 raw=tex2Dfetch(TileRawS,t);
  value=SourceMode==0?light.z:raw.x;
  uv=SourceMode==0?light.xy:(raw.x>0?raw.yz/raw.x:float2(0,0));
 }
 SourceScan[tid.x]=value;
 if(tile<_RTL_TILES && SourceMode!=0)SourceMoments[tid.x]=tex2Dfetch(TileRawS,int2(tile%_RTL_TX,tile/_RTL_TX));
 else SourceMoments[tid.x]=float4(value,value*uv,value*dot(uv,uv));
 ScanSourceWeights(tid.x);
 if(tile<_RTL_TILES)tex2Dstore(TileCDFU,int2(tile%_RTL_TX,tile/_RTL_TX),float4(SourceScan[tid.x],value,0,0));
 for(uint stride=128;stride>0;stride>>=1){if(tid.x<stride)SourceMoments[tid.x]+=SourceMoments[tid.x+stride];barrier();}
 if(tid.x==0){SourceMoments[0].x=SourceScan[255];tex2Dstore(BlockSumU,int2(gid.x,0),SourceMoments[0]);}
}
[numthreads(1,1,1)]void CS_SourceGlobal(uint3 id:SV_DispatchThreadID){
 float4 moment=0;
 [loop]for(int i=0;i<_RTL_BLOCKS;++i){moment+=tex2Dfetch(BlockSumS,int2(i,0));tex2Dstore(BlockCDFU,int2(i,0),float4(moment.x,0,0,0));}
 if(moment.x>0)moment.yzw/=moment.x;
 if(TestLight)moment=float4(FFT::Lum(TestColour)*TestPower,TestPosition,dot(TestPosition,TestPosition));
 tex2Dstore(SourceMetaU,int2(0,0),moment);
 float3 spectral=0;
 [loop]for(int s=0;s<SpectralSamples;++s)spectral+=SpectralResponse(Wavelength(s));
 tex2Dstore(SourceMetaU,int2(1,0),float4(spectral,0));
}
void SelectSource(float4 random,out float2 uv,out float3 colour,out float pdf){
 if(TestLight){uv=TestPosition;colour=TestColour*TestPower;pdf=1;return;}
 float total=tex2Dfetch(SourceMetaS,int2(0,0)).x;
 float target=random.x*total;int low=0,high=_RTL_BLOCKS-1;
 while(low<high){int mid=(low+high)/2;if(tex2Dfetch(BlockCDFS,int2(mid,0)).x<=target)low=mid+1;else high=mid;}
 int block=low;float before=block>0?tex2Dfetch(BlockCDFS,int2(block-1,0)).x:0;
 target-=before;low=block*256;high=min(low+255,_RTL_TILES-1);
 while(low<high){int mid=(low+high)/2;if(tex2Dfetch(TileCDFS,int2(mid%_RTL_TX,mid/_RTL_TX)).x<=target)low=mid+1;else high=mid;}
 int tile=low;int2 t=int2(tile%_RTL_TX,tile/_RTL_TX);
 if(SourceMode==0){
  uv=tex2Dfetch(LightDataS,t).xy;colour=tex2Dfetch(LightColourS,t).rgb;pdf=FFT::Lum(colour)/total;return;
 }
 float pixelTotal=tex2Dfetch(TileRawS,t).x;
 target=random.y*pixelTotal;low=0;high=255;
 while(low<high){
  int mid=(low+high)/2;int2 p=t*16+int2(mid%16,mid/16);
  if(tex2Dfetch(PixelCDFS,p).x<=target)low=mid+1;else high=mid;
 }
 int2 p=t*16+int2(low%16,low/16);
 colour=tex2Dfetch(FFT::SourceS,p).rgb*SourceFootprint(p);pdf=FFT::Lum(colour)/total;
 // Sample the displayed footprint, including shortened edge texels.
 float2 extent=min(float2(OFB2_RENDER_DIVISOR,OFB2_RENDER_DIVISOR),float2(BUFFER_WIDTH,BUFFER_HEIGHT)-float2(p)*OFB2_RENDER_DIVISOR);
 uv=(float2(p)*OFB2_RENDER_DIVISOR+random.zw*extent)/float2(BUFFER_WIDTH,BUFFER_HEIGHT);
}
}
