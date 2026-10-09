#pragma once
namespace RTL {
bool TemporalPreview(){
 return DenoiseEnabled && DenoiseMethod==0 && DenoiseStrength!=0 &&
  DenoiseFrames>1 && !Progressive && !FreezeNoise;
}
// Reuse the existing one-thread accumulation-state dispatch. Preview history
// has its own rejection rules and never alters the raw photon history.
void PreviewHistoryState(float4 current,float4 previous,float energyChange){
 if(!TemporalPreview()){
  tex2Dstore(FilterNextU,int2(0,0),0);return;
 }
 float4 state=tex2Dfetch(FilterStateS,int2(0,0));
 bool valid=state.x!=0 && state.y==float(FFT::FrameCount-1) && state.z==0 && state.w>0;
 valid=valid && !RTForceRebuild && !FFT::Dirty();
 // Manual optical/source configuration edits restart the preview. Test-light
 // position/power and fresh noise seeds remain eligible for temporal blending.
 [loop]for(int i=0;i<17;++i){
  if(i!=5 && i!=8)valid=valid && !any(Parameters(i)!=tex2Dfetch(ConfigPreviousS,int2(i,0)));
 }
 float4 oldTest=tex2Dfetch(ConfigPreviousS,int2(5,0));
 float4 oldNoise=tex2Dfetch(ConfigPreviousS,int2(8,0));
 valid=valid && TestLight==oldTest.x && SequenceOnly==oldNoise.x && FreezeNoise==oldNoise.z && Progressive==oldNoise.w;
 if(current.x<=0){tex2Dstore(FilterNextU,int2(0,0),0);return;}
 float frames=valid?min(state.w+1,float(DenoiseFrames)):1;
 float weight=(frames-1)/frames;
 float change=64*length(current.yz-previous.yz)+32*abs(current.w-previous.w)+8*energyChange;
 weight*=exp2(-DenoiseMotion*change);
 // Reduced retention also shortens the effective age on the following frame.
 frames=1/(1-weight);
 tex2Dstore(FilterNextU,int2(0,0),float4(weight,frames,valid,1170));
}
}
