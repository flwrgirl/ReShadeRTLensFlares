# ReShadeRTLensFlares
parameterised ai slop generated reshade shader for realistic lens flares

**ai disclaimer**: i did not write any of this code by hand other than the readme because im a stupid chud this is all computer generated but the shader is nice i gues. i cant read any of the code and i dont think any other human could either. i very much dislike ai but this is my one exception, you dont have to use this shader if you dont want to and i totally understand that.

[version with only the fft bloom and no lens tracing](https://github.com/flwrgirl/ReShadeFFTBloom)

# this is not intended to be realtime !!!!

## tips for best use
- disable all in game bloom and lens effects
  - if the game doesnt let you, try using [shader toggler](https://github.com/FransBouma/ShaderToggler)
- use a tonemapper that preserves detail in highlights as best as possible ([renodx](https://github.com/clshortfuse/renodx) can likely help with that)
- convolution source exposure controls brightness of the bloom and flares
- enable progressive gathering under sample options for screenshots and let the samples accumulate
- in preprocessor definitions set `OFB2_APERTURE_SIZE` to a power of 2 that as closely matches your display as possible
  - e.g. at 1080p set it to 1024, at 2160p (4k) set it to 2048
- dont forget to set your input color space (hdr/srgb) at the top
- use a lens with a focal length that closely matches your camera fov ([converter](https://basicfreetools.com/fov-visualizer/))

![SpaceEngine + Forza Horizon 6 demo photos](https://files.catbox.moe/tg0qml.png)

#### features coming soon maybe
- better denoising/ preview filters

[based on this paper](https://dl.acm.org/doi/10.1145/2010324.1965003)
inspired by the amazing lens tracing work of [LandHooman](https://land_hooman.artstation.com/) in samuel krug's [mrenders discord server](https://discord.gg/nXCErDSdgz)

#### support human creation, free palestine
