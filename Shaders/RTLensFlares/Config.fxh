#pragma once
// Allocation defaults. No upper bounds; hardware limits still apply.
#ifndef RTL_RENDER_DIVISOR
#define RTL_RENDER_DIVISOR 4
#endif
#ifndef RTL_ANGLE_BINS
#define RTL_ANGLE_BINS 32
#endif
#ifndef RTL_BOUND_GRID
#define RTL_BOUND_GRID 32
#endif
#ifndef RTL_TRACE_WORKERS
#define RTL_TRACE_WORKERS 16384
#endif
#ifndef RTL_SPECTRAL_SAMPLES
#define RTL_SPECTRAL_SAMPLES 3
#endif
#ifndef OFB2_APERTURE_SIZE
#define OFB2_APERTURE_SIZE 256
#endif
#ifndef OFB2_RENDER_DIVISOR
#define OFB2_RENDER_DIVISOR 6
#endif
#ifndef OFB2_SPECTRAL_SAMPLES
#define OFB2_SPECTRAL_SAMPLES 3
#endif
#if RTL_RENDER_DIVISOR < 1 || RTL_TRACE_WORKERS < 1 || RTL_BOUND_GRID < 1 || RTL_ANGLE_BINS < 2
#error "Positive allocation dimensions required, with at least two angle bins. There are no upper limits."
#endif
#define _RTL_W ((BUFFER_WIDTH+RTL_RENDER_DIVISOR-1)/RTL_RENDER_DIVISOR)
#define _RTL_H ((BUFFER_HEIGHT+RTL_RENDER_DIVISOR-1)/RTL_RENDER_DIVISOR)
#define _RTL_SW ((BUFFER_WIDTH+OFB2_RENDER_DIVISOR-1)/OFB2_RENDER_DIVISOR)
#define _RTL_SH ((BUFFER_HEIGHT+OFB2_RENDER_DIVISOR-1)/OFB2_RENDER_DIVISOR)
#define _RTL_TX ((_RTL_SW+15)/16)
#define _RTL_TY ((_RTL_SH+15)/16)
#define _RTL_TILES (_RTL_TX*_RTL_TY)
#define _RTL_BLOCKS ((_RTL_TILES+255)/256)
#if ((_RTL_W+7)/8) < 2
#define _RTL_COMMIT_X 2
#else
#define _RTL_COMMIT_X ((_RTL_W+7)/8)
#endif
#define _RTL_PI 3.14159265358979323846
