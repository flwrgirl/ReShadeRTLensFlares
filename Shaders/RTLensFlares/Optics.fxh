#pragma once
namespace RTL {
float3 SpectralResponse(float lambda) {
 float3 t=(lambda-float3(610,545,455))/float3(48,36,30);
 return exp(-0.5*t*t);
}
float Wavelength(int spectralIndex) {
 if(SpectralSamples==1)return 550;
 if(SpectralSamples==3)return spectralIndex==0?610:spectralIndex==1?550:460;
 return lerp(420.0,680.0,float(spectralIndex)/float(SpectralSamples-1));
}
float EffectiveFNumber(){return FNumber==0?PupilInfo(LensIndex).z:FNumber;}
float4 ActiveLens(){float4 info=LensInfo(LensIndex)*LensScale;info.y+=FocusShift;info.w*=PupilInfo(LensIndex).z/EffectiveFNumber();return info;}
float EntranceRadius(){return PupilInfo(LensIndex).x*LensScale*ClearRadiusScale;}
float2 SensorSize(){return SensorWidth*float2(1,float(BUFFER_HEIGHT)/BUFFER_WIDTH);}
float3 SourceDirection(float2 uv){
 float2 p=-(uv-0.5)*SensorSize()/ActiveLens().x;
 if(LensProjection(LensIndex)==0)return normalize(float3(p,1));
 // Equidistant input-angle approximation for fisheye prescriptions. The
 // game image is not warped; this maps light positions to incoming rays.
 float theta=length(p);
 return float3(p*(theta==0?1:sin(theta)/theta),cos(theta));
}
float MaxAngle(){float a=length(SensorSize()*0.5/ActiveLens().x);return LensProjection(LensIndex)==0?atan(a):a;}
float IndexAt(float2 glass,float lambda){
 if(glass.y==0)return glass.x;
 // Two-term Cauchy: nd and the F-C separation prescribed by Vd.
 float invF=1.0/(486.1327*486.1327),invC=1.0/(656.2725*656.2725);
 float b=(glass.x-1)/((glass.y==0?1:glass.y)*(invF-invC));
 if(GlassReferenceKind(LensIndex)!=0){
  // Preserve ne/Ve tables at the mercury e-line and F'/C' lines.
  float3 spectrum=GlassSpectrum(LensIndex);
  b=(glass.x-1)/(glass.y*(spectrum.x-spectrum.y));
  return glass.x+Dispersion*b*(1/(lambda*lambda)-spectrum.z);
 }
 return glass.x+Dispersion*b*(1/(lambda*lambda)-1/(587.5618*587.5618));
}
float2 FresnelSP(float n0,float n1,float c0,float c1){
 return float2((n0*c0-n1*c1)/(n0*c0+n1*c1),(n1*c0-n0*c1)/(n1*c0+n0*c1));
}
float Reflectance(float n0,float n1,float cosine,float lambda,out float transmittedCosine){
 float s2=(n0/n1)*(n0/n1)*(1-cosine*cosine);
 if(s2>=1){transmittedCosine=0;return 1;}
 transmittedCosine=sqrt(1-s2);
 float2 bare=FresnelSP(n0,n1,cosine,transmittedCosine);
 float reflectivity=dot(bare,bare)*0.5;
 if(CoatingMix!=0 && (abs(n0-1)<0.0001 || abs(n1-1)<0.0001)){
  float filmS2=(n0/CoatingIndex)*(n0/CoatingIndex)*(1-cosine*cosine);
  if(filmS2<1){
   float cf=sqrt(1-filmS2);
   float2 r0=FresnelSP(n0,CoatingIndex,cosine,cf);
   float2 r1=FresnelSP(CoatingIndex,n1,cf,transmittedCosine);
   float phase=4*_RTL_PI*CoatingIndex*CoatingThickness*cf/lambda;
   float2 a=r0*r0+r1*r1+2*r0*r1*cos(phase);
   float2 b=1+r0*r0*r1*r1+2*r0*r1*cos(phase);
   reflectivity=lerp(reflectivity,dot(a/b,float2(0.5,0.5)),CoatingMix);
  }
 }
 return reflectivity;
}
int GhostCount(){int n=SurfaceCount(LensIndex);return n*(n-1)/2;}
int2 GhostPair(int ghost){
 int k=0,n=SurfaceCount(LensIndex);
 [loop]for(int rear=1;rear<n;++rear){if(ghost<k+rear)return int2(rear,ghost-k);k+=rear;}
 return int2(-1,-1);
}
float PupilMask(float2 normalized){
 float2 p=normalized*FFT::LinkedRadius();
 float2 uv=p*0.5+0.5;
 if(any(uv<0)||any(uv>1))return 0;
 float amplitude=tex2Dlod(FFT::ApertureS,float4(uv,0,0)).r;
 return amplitude*amplitude;
}
bool IrisSegment(float3 p,float3 d,float distance,bool probe,inout float energy){
 float4 info=ActiveLens();
 if(abs(d.z)<0.0000001)return false;
 float t=(info.z-p.z)/d.z;
 if(t>=0 && t<=distance){
  float2 q=(p+d*t).xy/info.w;
  if(dot(q,q)>1)return false;
  if(!probe){energy*=PupilMask(q);if(energy<=0)return false;}
 }
 return true;
}
void AsphereEquation(int model,float radius,float conic,int terms,
                     float coefficients[_RTL_ASPHERIC_TERMS],float3 q,
                     out float residual,out float3 gradient){
 float h2=dot(q.xy,q.xy);
 float x=model==2?0.5*(h2+q.z*q.z):h2;
 float poly=0,derivative=0;
 [loop]for(int i=terms-1;i>=0;--i){derivative=derivative*x+poly;poly=poly*x+coefficients[i];}
 if(model==2){
  // Leica US5161060: p(s)=sum K(n)*(s^2/2)^n, s is the 3D
  // chord from the vertex. This is an implicit surface, not a sag polynomial.
  derivative=poly+x*derivative;
  residual=q.z-x*poly;
  gradient=float3(-derivative*q.xy,1-derivative*q.z);
 }else{
  float c=radius==0?0:1/radius;
  float discriminant=1-(1+conic)*c*c*h2;
  if(discriminant<=0){residual=1e30;gradient=0;return;}
  float root=sqrt(discriminant);
  float sag=c*h2/(1+root)+h2*h2*poly;
  float slope=c/root+2*(2*h2*poly+h2*h2*derivative);
  residual=q.z-sag;gradient=float3(-slope*q.xy,1);
 }
}
bool AsphereIntersection(float4 geometry,float3 p,float3 d,
                         inout float distance,out float3 normal){
 int address=int(geometry.w);
 int model=int(LensData(address)),terms=int(LensData(address+2));
 float conic=LensData(address+1),coefficients[_RTL_ASPHERIC_TERMS];
 [loop]for(int i=0;i<terms;++i)coefficients[i]=LensData(address+3+i);
 float3 origin=p/LensScale;origin.z-=geometry.x;
 float t=distance/LensScale,residual=0;float3 gradient=0;
 float tolerance=0.00001+0.000002*abs(geometry.x);
 // A numerical convergence bound, independent of spectral/ray budgets.
 // Failed roots are rejected instead of producing a nonphysical hit.
 [loop]for(int iteration=0;iteration<12;++iteration){
  AsphereEquation(model,geometry.y,conic,terms,coefficients,origin+d*t,residual,gradient);
  if(abs(residual)<=tolerance)break;
  float slope=dot(gradient,d);
  if(abs(slope)<0.0000001 || any(isnan(gradient)) || any(isinf(gradient)))return false;
  t-=residual/slope;
 }
 AsphereEquation(model,geometry.y,conic,terms,coefficients,origin+d*t,residual,gradient);
 if(abs(residual)>tolerance || isnan(t) || isinf(t) || dot(gradient,gradient)==0)return false;
 distance=t*LensScale;normal=normalize(gradient);
 return true;
}
bool HitSurface(int index,int travel,bool bounce,float lambda,bool probe,
                inout float3 p,inout float3 d,inout float energy){
 float4 g=Geometry(LensIndex,index);g.xyz*=LensScale;g.z*=ClearRadiusScale;
 float t=0;float3 normal=float3(0,0,1);
 if(g.y==0){if(abs(d.z)<0.0000001)return false;t=(g.x-p.z)/d.z;}
 else{
  float3 c=float3(0,0,g.x+g.y),oc=p-c;
  float b=dot(oc,d),disc=b*b-dot(oc,oc)+g.y*g.y;
  if(disc<0){
   if(g.w==0 || abs(d.z)<0.0000001)return false;
   t=(g.x-p.z)/d.z;
  }else{
   float root=sqrt(disc),t0=-b-root,t1=-b+root;
   // Select the vertex-side spherical cap in either traversal direction.
   t=abs((p+d*t0).z-g.x)<abs((p+d*t1).z-g.x)?t0:t1;
   normal=normalize(p+d*t-c);
  }
 }
 // ReShade FX does not short-circuit logical expressions. Keep this call
 // inside its own branch: it mutates t/normal and is only valid for aspheres.
 if(g.w!=0){
  if(!AsphereIntersection(Geometry(LensIndex,index),p,d,t,normal))return false;
 }
 if(t<0)return false;
 float3 hit=p+d*t;
 if(dot(hit.xy,hit.xy)>g.z*g.z)return false;
 if(!IrisSegment(p,d,t,probe,energy))return false;
 float2 before=index==0?float2(1,0):Material(LensIndex,index-1);
 float2 after=Material(LensIndex,index);
 float n0=IndexAt(travel>0?before:after,lambda),n1=IndexAt(travel>0?after:before,lambda);
 if(n0>1)energy*=exp(-Absorption*t);
 if(dot(normal,d)>0)normal=-normal;
 float cosine=-dot(normal,d),ct=0;
 float r=Reflectance(n0,n1,cosine,lambda,ct);
 if(bounce){d=reflect(d,normal);energy*=r;}
 else{
  if(ct==0)return false;
  d=normalize((n0/n1)*d+((n0/n1)*cosine-ct)*normal);
  energy*=1-r;
 }
 p=hit+d*(0.00001*abs(LensScale));
 return energy>0 && !any(isnan(p)) && !any(isinf(p)) && !any(isnan(d)) && !any(isinf(d));
}
float4 TraceBundle(float2 entrance,float3 direction,int2 pair,float lambda,bool probe){
 float3 p=float3(entrance,PupilInfo(LensIndex).y*LensScale),d=direction;
 float energy=direction.z;
 int n=SurfaceCount(LensIndex);
 [loop]for(int i=0;i<=pair.x;++i)if(!HitSurface(i,1,i==pair.x,lambda,probe,p,d,energy))return 0;
 [loop]for(int i=pair.x-1;i>=pair.y;--i)if(!HitSurface(i,-1,i==pair.y,lambda,probe,p,d,energy))return 0;
 [loop]for(int i=pair.y+1;i<n;++i)if(!HitSurface(i,1,false,lambda,probe,p,d,energy))return 0;
 if(d.z<=0)return 0;
 float t=(ActiveLens().y-p.z)/d.z;
 if(t<0 || !IrisSegment(p,d,t,probe,energy))return 0;
 float2 sensor=(p+d*t).xy;
 if(any(isnan(sensor))||any(isinf(sensor)))return 0;
 return float4(sensor,energy,1);
}
float BarePairEstimate(int2 pair){
 float2 a=pair.x==0?float2(1,0):Material(LensIndex,pair.x-1),b=Material(LensIndex,pair.x);
 float2 c=pair.y==0?float2(1,0):Material(LensIndex,pair.y-1),d=Material(LensIndex,pair.y);
 float r0=(a.x-b.x)/(a.x+b.x),r1=(c.x-d.x)/(c.x+d.x);
 return r0*r0*r1*r1*0.001;
}
}
