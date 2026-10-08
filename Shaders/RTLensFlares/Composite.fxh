#pragma once
namespace RTL {
float3 BoundsView(float2 uv){
 bool entrance=uv.x<0.5;
 float2 xy=float2(frac(uv.x*2),uv.y)*2-1;
 int row=InspectAngle+(IsAnamorphic(LensIndex)?InspectAzimuth*RTL_ANGLE_BINS:0);
 float4 box=entrance?tex2Dfetch(EntranceBoundsS,int2(InspectSequence,row)):tex2Dfetch(SensorBoundsS,int2(InspectSequence,row));
 float2 domain=entrance?EntranceRadius().xx:SensorSize()*0.5;
 float2 p=xy*domain;
 float2 q=min(abs(p-box.xy),abs(p-box.zw))/domain;
 bool inside=all(p>=box.xy)&&all(p<=box.zw);
 float edge=min(q.x,q.y),circle=abs(length(xy)-1);
 return inside?float3(0.08,0.32,0.15)*(1-step(0.015,edge))+float3(0.01,0.06,0.02):float3(0.01,0.01,0.015)+float3(0.12,0.12,0.15)*(1-step(0.005,circle));
}
float4 PS_Composite(float4 position:SV_Position,float2 uv:TEXCOORD0):SV_Target{
 float3 scene=FFT::Decode(tex2Dlod(FFT::GameS,float4(uv,0,0)).rgb);
 float2 flareUV=uv*float2(BUFFER_WIDTH,BUFFER_HEIGHT)/(float2(_RTL_W,_RTL_H)*RTL_RENDER_DIVISOR);
 float2 fftUV=uv*float2(BUFFER_WIDTH,BUFFER_HEIGHT)/(float2(V2_W,V2_H)*V2_DIV);
 float3 flare=FFT::Saturation(max(tex2Dlod(FlareLinearS,float4(flareUV,0,0)).rgb,0),FlareSaturation)*FlareTint;
 float3 bloom=BloomEnabled?FFT::Saturation(tex2Dlod(FFT::BloomS,float4(fftUV,0,0)).rgb,FFT::BloomSaturation)*FFT::BloomTint*FFT::BloomIntensity:0;
 if(TestLight && BloomEnabled){
  float3 kernel=FFT::NativeKernel((uv-TestPosition)*float2(BUFFER_WIDTH,BUFFER_HEIGHT));
  kernel/=max(tex2Dfetch(FFT::KernelStatsS,int2(0,0)).rgb,1e-30);
  bloom+=kernel*TestColour*TestPower*RTL_RENDER_DIVISOR*RTL_RENDER_DIVISOR*FFT::BloomIntensity;
 }
 float3 value=scene+flare+bloom;
 if(RTDebugView==1)value=flare;
 else if(RTDebugView==2)value=bloom;
 else if(RTDebugView==3)value=tex2Dlod(FFT::SourceS,float4(fftUV,0,0)).rgb;
 else if(RTDebugView==4){
  int2 p=int2(uv*float2(_RTL_SW,_RTL_SH)),tile=p/16;float4 l=tex2Dfetch(LightDataS,tile);
  value=scene*0.15;float distance=length((uv-l.xy)*float2(BUFFER_WIDTH,BUFFER_HEIGHT));
  if(l.z>0 && distance<4)value+=float3(1,0.25,0.05);
 }
 else if(RTDebugView==5)value=FFT::OpticsPreview(position.xy);
 else if(RTDebugView==6)value=BoundsView(uv);
 else if(RTDebugView==7){
  int2 p=int2(uv*float2(GhostCount(),RTL_ANGLE_BINS));p=min(p,int2(GhostCount()-1,RTL_ANGLE_BINS-1));
  if(IsAnamorphic(LensIndex))p.y+=InspectAzimuth*RTL_ANGLE_BINS;
  float a=tex2Dfetch(GhostCDFS,p).x,b=p.x>0?tex2Dfetch(GhostCDFS,p-int2(1,0)).x:0;
  float probability=(a-b)/max(tex2Dfetch(GhostTotalS,int2(0,p.y)).x,1e-30);
  value=float3(probability*GhostCount()*0.5,probability*GhostCount()*0.15,0.04);
 }
 else if(RTDebugView==8){
  int columns=BarrelEnabled?6:5;
  int column=min(int(uv.x*columns),columns-1);float v=float(tex2Dfetch(CountersS,int2(column,0)));
  float total=float(RayBudget)*SpectralSamples;
  float height=column==3?v/(max(total,1)*4):column==4?(v>0?1:0):v/max(total,1);
  value=uv.y>1-height?(column==4?float3(1,0.05,0.01):float3(0.12,0.7,0.4)):float3(0.01,0.01,0.015);
 }
 return float4(FFT::Encode(value),1);
}
}
