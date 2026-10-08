// Exact v1.5 local reconstruction, retained as an optional method.
void PreviewLocal(uint3 id){
 if(!DenoiseEnabled || DenoiseMethod!=1 || id.x>=_RTL_W || id.y>=_RTL_H)return;
 int2 p=int2(id.xy);float3 center=tex2Dfetch(FlareCurrentS,p).rgb;
 float3 variance=max(tex2Dfetch(MomentsCurrentS,p).rgb-center*center,0);
 float frames=tex2Dfetch(HistoryNextS,int2(0,0)).y;
 float count=Progressive?frames:(TemporalWeight>0 && TemporalWeight<1?(1+TemporalWeight)/(1-TemporalWeight):1);
 float luminance=FFT::Lum(center),noise=FFT::Lum(variance)/max(count,1);
 float3 sum=0;float total=0;
 int radius=DenoiseRadius;
 [loop]for(int y=-radius;y<=radius;++y)[loop]for(int x=-radius;x<=radius;++x){
  int2 q=p+int2(x,y);if(any(q<0) || q.x>=_RTL_W || q.y>=_RTL_H)continue;
  float3 neighbour=tex2Dfetch(FlareCurrentS,q).rgb;
  float other=FFT::Lum(neighbour),delta=other-luminance;
  float localNoise=FFT::Lum(max(tex2Dfetch(MomentsCurrentS,q).rgb-neighbour*neighbour,0))/max(count,1);
  float bandwidth=noise+localNoise+0.1*(luminance+other)*(luminance+other)+1e-20;
  float spatial=exp(-2*float(x*x+y*y)/max(float(radius*radius),1));
  float weight=spatial/(1+DenoiseEdge*delta*delta/bandwidth);
  sum+=neighbour*weight;total+=weight;
 }
 float amount=DenoiseStrength/(Progressive?sqrt(max(frames,1)):1);
 float3 filtered=total>0?sum/total:center;
 tex2Dstore(FlarePreviewU,p,float4(lerp(center,filtered,amount),1));
}
