#pragma once
namespace RTL {
float ActiveZoom(){
 int count=ZoomCount(LensID());if(count==0)return 0;
 int start=LensExtension(LensID())+4,stride=12+2*SurfaceCount(LensID());
 return lerp(LensData(start),LensData(start+(count-1)*stride),ZoomPosition);
}
int ZoomFrameAddress(int lens,int frame){return LensExtension(lens)+4+frame*(12+2*SurfaceCount(lens));}
float CamValue(int a,int b,int offset,float cam){return lerp(LensData(a+offset),LensData(b+offset),cam);}
float4 CamGeometry(int lens,int surface,int a,int b,float cam){
 float4 g=RawGeometry(lens,surface);g.x=CamValue(a,b,12+2*surface,cam);g.z=CamValue(a,b,13+2*surface,cam);return g;
}
float3 CamParaxial(int lens,int a,int b,float cam,float stop){
 float y=1,u=0,n=1,previous=0,pupil=0;bool found=false;
 [loop]for(int i=0;i<SurfaceCount(lens);++i){
  float4 g=CamGeometry(lens,i,a,b,cam);float next=RawMaterial(lens,i).x;
  if(!found && stop>=previous && stop<=g.x){pupil=y+(stop-previous)*u/n;found=true;}
  y+=(g.x-previous)*u/n;if(g.y!=0)u-=(next-n)*y/g.y;
  n=next;previous=g.x;
 }
 if(!found)pupil=y+(stop-previous)*u/n;
 return float3(-1/u,-y*n/u,pupil);
}
float4 CacheGeometry(float4 geometry,int index){if(geometry.w!=0)geometry.w=index+1;return geometry;}
[numthreads(1,1,1)]void CS_LensState(uint3 id:SV_DispatchThreadID){
 // Decode a selected prescription once, not once per interface per photon.
 // This pass never samples LiveLens while writing it.
 int count=ZoomCount(LensID());
 float focal=ActiveZoom();float4 old=tex2Dfetch(ConfigPreviousS,int2(12,0));
 if(!RTForceRebuild && old.x==LensID() && old.y==focal && old.w==20261008)return;
 float3 spectrum=GlassSpectrum(LensID());
 bool newLens=RTForceRebuild || old.x!=LensID() || old.w!=20261008;
 if(newLens){[loop]for(int i=0;i<SurfaceCount(LensID());++i){
  float2 glass=RawMaterial(LensID(),i);
  float b=glass.y==0?0:(glass.x-1)/(glass.y*(spectrum.x-spectrum.y));
  tex2Dstore(LiveLensU,int2(i+4,1),float4(glass,b,spectrum.z));
  int address=int(RawGeometry(LensID(),i).w);
  float4 shape=address==0?0:float4(LensData(address),LensData(address+1),LensData(address+2),0);
  tex2Dstore(LiveShapeU,int2(i,0),shape);
  [loop]for(int row=1;row<1+((_RTL_ASPHERIC_TERMS+3)/4);++row){
   float4 values=0;
   if(int(shape.x)==3){if(row==1)values=float4(cos(shape.y),sin(shape.y),0,0);}
   else if(address!=0){[unroll]for(int k=0;k<4;++k){int term=(row-1)*4+k;if(term<int(shape.z))values[k]=LensData(address+3+term);}}
   tex2Dstore(LiveShapeU,int2(i,row),values);
  }
 }
 }
 if(count==0){
  tex2Dstore(LiveLensU,int2(0,0),LensData4(LensID()*16+4));
  tex2Dstore(LiveLensU,int2(1,0),LensData4(LensID()*16+8));
  tex2Dstore(LiveLensU,int2(2,0),float4(LensData(LensExtension(LensID())),LensData(LensID()*16+4),0,0));
  tex2Dstore(LiveLensU,int2(3,0),float4(LensID(),0,0,20261008));
  [loop]for(int i=0;i<SurfaceCount(LensID());++i)tex2Dstore(LiveLensU,int2(i+4,0),CacheGeometry(RawGeometry(LensID(),i),i));
  return;
 }
 int segment=0;
 [loop]for(int k=1;k<count-1;++k)if(focal>=LensData(ZoomFrameAddress(LensID(),k)))segment=k;
 int a=ZoomFrameAddress(LensID(),segment),b=ZoomFrameAddress(LensID(),segment+1);
 float u=(focal-LensData(a))/(LensData(b)-LensData(a)),cam=u;
 if(u>0 && u<1){
  float target=CamValue(a,b,1,u),lo=0,hi=1;
  bool increasing=LensData(b+1)>LensData(a+1);
  [loop]for(int iteration=0;iteration<18;++iteration){
   cam=(lo+hi)*0.5;float actual=CamParaxial(LensID(),a,b,cam,CamValue(a,b,3,cam)).x;
   if((actual<target)==increasing)lo=cam;else hi=cam;
  }
  cam=(lo+hi)*0.5;
 }
 // Outside the published range the inferred cam extrapolates, without a cap.
 float stop=CamValue(a,b,3,cam),fno=CamValue(a,b,7,cam);
 float3 paraxial=CamParaxial(LensID(),a,b,cam,stop);
 float last=CamGeometry(LensID(),SurfaceCount(LensID())-1,a,b,cam).x;
 float sensor=last+paraxial.y+CamValue(a,b,9,cam);
 tex2Dstore(LiveLensU,int2(0,0),float4(paraxial.x,sensor,stop,abs(paraxial.z)*paraxial.x/(2*fno)));
 tex2Dstore(LiveLensU,int2(1,0),float4(CamValue(a,b,5,cam),CamValue(a,b,6,cam),fno,paraxial.y));
 tex2Dstore(LiveLensU,int2(2,0),float4(paraxial.xx,cam,focal));
 tex2Dstore(LiveLensU,int2(3,0),float4(LensID(),focal,0,20261008));
 [loop]for(int i=0;i<SurfaceCount(LensID());++i)tex2Dstore(LiveLensU,int2(i+4,0),CacheGeometry(CamGeometry(LensID(),i,a,b,cam),i));
}
}
