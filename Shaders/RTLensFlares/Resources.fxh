#pragma once
namespace RTL {
#define RTL_TEXTURE(NAME,W,H) \
 texture2D NAME { Width=W; Height=H; Format=RGBA32F; }; \
 sampler2D NAME##S { Texture=NAME; MinFilter=POINT; MagFilter=POINT; MipFilter=POINT; }; \
 storage2D NAME##U { Texture=NAME; };
RTL_TEXTURE(EntranceBounds,_RTL_GHOSTS,_RTL_ANGLE_ROWS)
RTL_TEXTURE(SensorBounds,_RTL_GHOSTS,_RTL_ANGLE_ROWS)
RTL_TEXTURE(BundleEnergy,_RTL_GHOSTS,_RTL_ANGLE_ROWS)
RTL_TEXTURE(GhostCDF,_RTL_GHOSTS,_RTL_ANGLE_ROWS)
RTL_TEXTURE(GhostTotal,1,_RTL_ANGLE_ROWS)
RTL_TEXTURE(PixelCDF,(_RTL_TX*16),(_RTL_TY*16))
RTL_TEXTURE(TileRaw,_RTL_TX,_RTL_TY)
RTL_TEXTURE(LightData,_RTL_TX,_RTL_TY)
RTL_TEXTURE(LightColour,_RTL_TX,_RTL_TY)
RTL_TEXTURE(TileCDF,_RTL_TX,_RTL_TY)
RTL_TEXTURE(BlockSum,_RTL_BLOCKS,1)
RTL_TEXTURE(BlockCDF,_RTL_BLOCKS,1)
RTL_TEXTURE(SourceMeta,2,1)
RTL_TEXTURE(SourcePrevious,2,1)
RTL_TEXTURE(ConfigPrevious,_RTL_PARAMETERS,1)
RTL_TEXTURE(BoundsAnchor,1,1)
RTL_TEXTURE(Cache,1,1)
RTL_TEXTURE(HistoryState,1,1)
RTL_TEXTURE(HistoryNext,1,1)
RTL_TEXTURE(FlarePrevious,_RTL_W,_RTL_H)
RTL_TEXTURE(FlareCurrent,_RTL_W,_RTL_H)
RTL_TEXTURE(FlarePreview,_RTL_W,_RTL_H)
RTL_TEXTURE(MomentsPrevious,_RTL_W,_RTL_H)
RTL_TEXTURE(MomentsCurrent,_RTL_W,_RTL_H)
RTL_TEXTURE(FilterState,1,1)
RTL_TEXTURE(FilterNext,1,1)
sampler2D FlareLinearS { Texture=FlareCurrent; MinFilter=LINEAR; MagFilter=LINEAR; MipFilter=POINT; AddressU=CLAMP; AddressV=CLAMP; };
sampler2D FlarePreviewLinearS { Texture=FlarePreview; MinFilter=LINEAR; MagFilter=LINEAR; MipFilter=POINT; AddressU=CLAMP; AddressV=CLAMP; };
#undef RTL_TEXTURE
#define RTL_ATOMIC(NAME) \
 texture2D NAME { Width=_RTL_W; Height=_RTL_H; Format=R32I; }; \
 sampler2D<int> NAME##S { Texture=NAME; MinFilter=POINT; MagFilter=POINT; MipFilter=POINT; }; \
 storage2D<int> NAME##U { Texture=NAME; };
RTL_ATOMIC(AccumR)
RTL_ATOMIC(AccumG)
RTL_ATOMIC(AccumB)
#undef RTL_ATOMIC
texture2D Counters { Width=8; Height=1; Format=R32I; };
sampler2D<int> CountersS { Texture=Counters; MinFilter=POINT; MagFilter=POINT; MipFilter=POINT; };
storage2D<int> CountersU { Texture=Counters; };
texture2D DiagramMask { Width=_RTL_DW; Height=_RTL_DH; Format=R32I; };
sampler2D<int> DiagramMaskS { Texture=DiagramMask; MinFilter=POINT; MagFilter=POINT; MipFilter=POINT; };
storage2D<int> DiagramMaskU { Texture=DiagramMask; };
texture2D DiagramGeometry { Width=_RTL_DW; Height=_RTL_DH; Format=RGBA16F; };
sampler2D DiagramGeometryS { Texture=DiagramGeometry; MinFilter=LINEAR; MagFilter=LINEAR; MipFilter=POINT; AddressU=CLAMP; AddressV=CLAMP; };
storage2D DiagramGeometryU { Texture=DiagramGeometry; };
}
