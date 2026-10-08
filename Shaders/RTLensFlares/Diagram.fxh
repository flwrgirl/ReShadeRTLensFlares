#pragma once
namespace RTL {
// This view traces the live prescription with the normal optical hit solver.
// It is diagnostic only; inactive passes return before any texture access.
float2 DiagramAxis(){
 float angle=DiagramPlane*_RTL_PI/180;
 if(IsAnamorphic(LensID()))angle-=AnamorphicRotation*_RTL_PI/180;
 return float2(cos(angle),sin(angle));
}
float4 DiagramExtent(){
 float left=PupilInfo(LensID()).y*LensScale,right=ActiveLens().y;
 float radius=EntranceRadius();
 [loop]for(int i=0;i<SurfaceCount(LensID());++i){
  float4 g=Geometry(LensID(),i);radius=max(radius,g.z*LensScale*ClearRadiusScale);
 }
 float width=right-left,aspect=float(_RTL_DW)/_RTL_DH;
 float height=max(2.3*radius,width*1.12/aspect);
 return float4((left+right)*0.5,0,height*aspect,height);
}
float2 DiagramWorld(float2 uv,float4 extent){return extent.xy+float2(uv.x-0.5,0.5-uv.y)*extent.zw;}
float2 DiagramPixel(float3 p,float4 extent){
 float2 world=float2(p.z,dot(p.xy,DiagramAxis()));
 float2 uv=(world-extent.xy)/extent.zw;uv.y=-uv.y;
 return (uv+0.5)*float2(_RTL_DW,_RTL_DH)-0.5;
}
bool DiagramSag(float4 g,float height,out float z){
 float2 axis=DiagramAxis();float h=height/LensScale;
 float radius=g.y;z=g.x*LensScale;
 if(g.w==0){
  if(radius==0)return true;
  float discriminant=radius*radius-h*h;if(discriminant<0)return false;
  z+=(radius-sign(radius)*sqrt(discriminant))*LensScale;return true;
 }
 int index=int(g.w)-1;float4 shape=tex2Dfetch(LiveShapeS,int2(index,0));
 int model=int(shape.x),terms=int(shape.z);
 if(model==3){
  float powered=h*dot(axis,tex2Dfetch(LiveShapeS,int2(index,1)).xy);
  float discriminant=radius*radius-powered*powered;if(discriminant<0)return false;
  z+=(radius-sign(radius)*sqrt(discriminant))*LensScale;return true;
 }
 float4 coefficients[(_RTL_ASPHERIC_TERMS+3)/4];
 [unroll]for(int row=0;row<(_RTL_ASPHERIC_TERMS+3)/4;++row){
  coefficients[row]=tex2Dfetch(LiveShapeS,int2(index,1+row));
 }
 float3 sagPoint=float3(h*axis,0),gradient=0;float residual=0;
 [loop]for(int iteration=0;iteration<12;++iteration){
  AsphereEquation(model,radius,shape.y,terms,coefficients,sagPoint,residual,gradient);
  if(abs(residual)<=0.00001+0.000002*abs(g.x)){z=(g.x+sagPoint.z)*LensScale;return true;}
  if(abs(gradient.z)<1e-7)return false;sagPoint.z-=residual/gradient.z;
 }
 return false;
}
[numthreads(8,8,1)]void CS_DiagramGeometry(uint3 id:SV_DispatchThreadID){
 if(RTDebugView!=9 || id.x>=_RTL_DW || id.y>=_RTL_DH)return;
 int2 pixel=int2(id.xy);float4 extent=DiagramExtent();
 float2 world=DiagramWorld((float2(pixel)+0.5)/float2(_RTL_DW,_RTL_DH),extent);
 float thickness=extent.z/_RTL_DW*0.8;
 float3 colour=float3(0.008,0.011,0.02),edgeColour=0;
 if(abs(world.y)<thickness*0.45)colour+=float3(0.04,0.045,0.06);
 float firstZ=0;bool firstValid=false;
 int count=SurfaceCount(LensID());
 [loop]for(int i=0;i<count;++i){
  float4 g=Geometry(LensID(),i);float z=0;
  bool valid=abs(world.y)<=g.z*LensScale*ClearRadiusScale;
  if(valid)valid=DiagramSag(g,world.y,z);
  if(valid && firstValid && i>0){
   if(Material(LensID(),i-1).x>1 && world.x>=min(firstZ,z) && world.x<=max(firstZ,z))colour=float3(0.045,0.1,0.15);
  }
  if(valid && abs(world.x-z)<thickness)edgeColour=float3(0.18,0.38,0.5);
  if(BarrelEnabled && i+1<count && BarrelGap(i)){
   float4 next=Geometry(LensID(),i+1);
   float wall=max(g.z,next.z)*LensScale*ClearRadiusScale*BarrelRadiusScale;
   if(world.x>=g.x*LensScale && world.x<=next.x*LensScale && abs(abs(world.y)-wall)<thickness)colour=float3(0.12,0.1,0.08);
  }
  firstZ=z;firstValid=valid;
 }
 if(any(edgeColour>0))colour=edgeColour;
 float4 lens=ActiveLens();
 if(abs(world.x-lens.z)<thickness){
  float2 q=DiagramAxis()*world.y/lens.w;
  bool blocked=abs(world.y)>lens.w;
  if(!blocked)blocked=PupilMask(q)<=0;
  if(blocked)colour=float3(0.42,0.4,0.33);
 }
 float2 axis=SensorFromLens(DiagramAxis()),sensor=SensorSize()*0.5;
 float sensorHeight=min(sensor.x/max(abs(axis.x),1e-20),sensor.y/max(abs(axis.y),1e-20));
 if(abs(world.x-lens.y)<thickness && abs(world.y)<=sensorHeight)colour=float3(0.42,0.15,0.3);
 tex2Dstore(DiagramGeometryU,pixel,float4(colour,1));tex2Dstore(DiagramMaskU,pixel,0);
}
void DiagramLine(float3 a,float3 b,int flags,float4 extent){
 float2 begin=DiagramPixel(a,extent),end=DiagramPixel(b,extent);
 if(any(isnan(begin)) || any(isinf(begin)) || any(isnan(end)) || any(isinf(end)))return;
 // Clip before rasterization so off-screen paths cannot create giant loops.
 float2 delta=end-begin;float low=0,high=1;
 [loop]for(int axis=0;axis<2;++axis){
  float limit=axis==0?float(_RTL_DW):float(_RTL_DH);
  if(abs(delta[axis])<1e-12){if(begin[axis]<0 || begin[axis]>=limit)return;}
  else{float t0=-begin[axis]/delta[axis],t1=(limit-1-begin[axis])/delta[axis];low=max(low,min(t0,t1));high=min(high,max(t0,t1));}
 }
 if(high<low)return;
 end=begin+delta*high;begin+=delta*low;delta=end-begin;
 int steps=int(ceil(max(abs(delta.x),abs(delta.y))));
 [loop]for(int step=0;step<=steps;++step){
  int2 p=int2(round(begin+delta*(steps==0?0:float(step)/steps)));
  if(all(p>=0) && p.x<_RTL_DW && p.y<_RTL_DH)atomicOr(DiagramMaskU,p,flags);
 }
}
void DiagramPath(float2 entrance,float3 direction,int2 pair,int flags,float4 extent){
 float3 p=float3(entrance,PupilInfo(LensID()).y*LensScale),d=direction;
 float energy=direction.z;int count=SurfaceCount(LensID());float4 iris=ActiveLens();
 bool barrel=pair.x==-2;int secondBounce=2*pair.x-pair.y;
 int steps=barrel?count:count+2*(pair.x-pair.y);
 int step=0;bool pendingWall=false;
 [loop]while(step<=steps){
  float3 start=p,travel=d;bool valid=true,last=false;
  if(pendingWall){
   valid=BarrelBounce(pair.y,false,p,d,energy);pendingWall=false;
  }else if(step==steps){
   if(d.z<=0)return;float t=(iris.y-p.z)/d.z;if(t<0)return;
   valid=IrisSegmentAt(iris,p,d,t,false,energy);p+=d*t;last=true;
  }else{
   bool backward=!barrel && step>pair.x && step<=secondBounce;
   int index=barrel?step:step<=pair.x?step:backward?2*pair.x-step:step-2*(pair.x-pair.y);
   bool bounce=!barrel && (step==pair.x || step==secondBounce);
   valid=HitSurface(index,backward?-1:1,bounce,DiagramWavelength,false,true,iris,p,d,energy);
   if(!valid){
    float t=0;float3 normal=0;
    if(!SurfaceIntersection(index,start,travel,t,normal))return;
    float irisT=(iris.z-start.z)/travel.z;
    if(irisT>=0 && irisT<=t){float2 q=(start+travel*irisT).xy/iris.w;if(dot(q,q)>1 || PupilMask(q)<=0)t=irisT;}
    p=start+travel*t;
   }
   pendingWall=barrel && index==pair.y;step++;
  }
  DiagramLine(start,p,valid?flags:(flags|4),extent);
  if(!valid || last)return;
 }
}
[numthreads(64,1,1)]void CS_DiagramRays(uint3 id:SV_DispatchThreadID){
 if(RTDebugView!=9)return;
 float4 extent=DiagramExtent();float2 axis=DiagramAxis();
 float theta=DiagramAngle*_RTL_PI/180;float3 direction=float3(axis*sin(theta),cos(theta));
 int sequence=InspectSequence;if(sequence<0 || sequence>=GhostCount())sequence=0;
 int2 pair=GhostPair(sequence);
 [loop]for(int ray=int(id.x);ray<DiagramRays;ray+=64){
  float height=DiagramRays==1?0:lerp(-EntranceRadius(),EntranceRadius(),float(ray)/float(DiagramRays-1));
  [loop]for(int path=0;path<2;++path)DiagramPath(axis*height,direction,path==0?int2(-1,-1):pair,path==0?1:2,extent);
 }
}
float3 DiagramView(float2 uv){
 int2 p=int2(uv*float2(_RTL_DW,_RTL_DH));p=min(p,int2(_RTL_DW-1,_RTL_DH-1));
 float3 colour=tex2Dlod(DiagramGeometryS,float4(uv,0,0)).rgb;
 int flags=tex2Dfetch(DiagramMaskS,p);
 if((flags&3)==3)colour=float3(0.8,0.85,0.6);
 else if((flags&2)!=0)colour=float3(0.05,0.8,0.75);
 else if((flags&1)!=0)colour=float3(0.9,0.55,0.1);
 if((flags&4)!=0)colour=lerp(colour,float3(0.7,0.06,0.03),0.7);
 return colour;
}
}
