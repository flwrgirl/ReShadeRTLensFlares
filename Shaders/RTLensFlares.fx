// RTLensFlares v1.1.0 - MIT. Requires ReShade 6.8+ compute support.
// DX12 / Vulkan: spherical/aspheric ray tracing, AABB bundle sampling, integer
// compute splatting, angle-dependent ghost probabilities and integrated FFT.
#include "RTLensFlares/Config.fxh"
#include "RTLensFlares/Lenses.fxh"
#include "RTLensFlares/Controls.fxh"
#include "RTLensFlares/Resources.fxh"
#include "RTLensFlares/FFT.fxh"
#include "RTLensFlares/Optics.fxh"
#include "RTLensFlares/Bounds.fxh"
#include "RTLensFlares/Sources.fxh"
#include "RTLensFlares/Trace.fxh"
#include "RTLensFlares/Composite.fxh"

technique RTLensFlares < ui_label="RTLensFlares v1"; ui_tooltip="Physically based two-reflection lens flares with spherical/aspheric surfaces and bounded compute ray tracing. Source modes: detected lights, extracted highlights, full frame. Workload-controlled preview defaults; all numeric controls accept uncapped input. See the README for accuracy and validation."; > {
 #include "RTLensFlares/FFTPrepare.fxh"
 pass LensCache { ComputeShader=RTL::CS_Cache; DispatchSizeX=1; DispatchSizeY=1; GenerateMipMaps=false; }
 pass BundleBounds { ComputeShader=RTL::CS_Bounds; DispatchSizeX=_RTL_GHOSTS; DispatchSizeY=RTL_ANGLE_BINS; GenerateMipMaps=false; }
 pass SequenceBudget { ComputeShader=RTL::CS_GhostCDF; DispatchSizeX=1; DispatchSizeY=RTL_ANGLE_BINS; GenerateMipMaps=false; }
 pass PixelDistribution { ComputeShader=RTL::CS_PixelCDF; DispatchSizeX=_RTL_TX; DispatchSizeY=_RTL_TY; GenerateMipMaps=false; }
 pass LightDetection { ComputeShader=RTL::CS_DetectLights; DispatchSizeX=(_RTL_TILES+63)/64; DispatchSizeY=1; GenerateMipMaps=false; }
 pass TileDistribution { ComputeShader=RTL::CS_TileCDF; DispatchSizeX=_RTL_BLOCKS; DispatchSizeY=1; GenerateMipMaps=false; }
 pass SourceDistribution { ComputeShader=RTL::CS_SourceGlobal; DispatchSizeX=1; DispatchSizeY=1; GenerateMipMaps=false; }
 pass ClearPhotons { ComputeShader=RTL::CS_Clear; DispatchSizeX=(_RTL_W+7)/8; DispatchSizeY=(_RTL_H+7)/8; GenerateMipMaps=false; }
 pass TracePhotons { ComputeShader=RTL::CS_Rays; DispatchSizeX=(RTL_TRACE_WORKERS+63)/64; DispatchSizeY=1; GenerateMipMaps=false; }
 pass AccumulationState { ComputeShader=RTL::CS_HistoryState; DispatchSizeX=1; DispatchSizeY=1; GenerateMipMaps=false; }
 pass ResolvePhotons { ComputeShader=RTL::CS_Resolve; DispatchSizeX=(_RTL_W+7)/8; DispatchSizeY=(_RTL_H+7)/8; GenerateMipMaps=false; }
 #include "RTLensFlares/FFTConvolve.fxh"
 pass CommitHistory { ComputeShader=RTL::CS_Commit; DispatchSizeX=_RTL_COMMIT_X; DispatchSizeY=(_RTL_H+7)/8; GenerateMipMaps=false; }
 pass Composite { VertexShader=FFT::VS_Fullscreen; PixelShader=RTL::PS_Composite; }
}
