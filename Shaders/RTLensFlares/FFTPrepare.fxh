
 pass CacheState { ComputeShader=FFT::CS_CacheState; DispatchSizeX=1; DispatchSizeY=1; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass Aperture { ComputeShader=FFT::CS_Aperture; DispatchSizeX=(V2_N+7)/8; DispatchSizeY=(V2_N+7)/8; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass PupilXLocal { ComputeShader=FFT::CS_PupilXLocal; DispatchSizeX=(V2_P+1023)/1024; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#if V2_P >= 2048
 pass PupilX2048 { ComputeShader=FFT::CS_PupilX2048; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 4096
 pass PupilX4096 { ComputeShader=FFT::CS_PupilX4096; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 8192
 pass PupilX8192 { ComputeShader=FFT::CS_PupilX8192; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 16384
 pass PupilX16384 { ComputeShader=FFT::CS_PupilX16384; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 32768
 pass PupilX32768 { ComputeShader=FFT::CS_PupilX32768; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 65536
 pass PupilX65536 { ComputeShader=FFT::CS_PupilX65536; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 131072
 pass PupilX131072 { ComputeShader=FFT::CS_PupilX131072; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 262144
 pass PupilX262144 { ComputeShader=FFT::CS_PupilX262144; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 524288
 pass PupilX524288 { ComputeShader=FFT::CS_PupilX524288; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 1048576
 pass PupilX1048576 { ComputeShader=FFT::CS_PupilX1048576; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 2097152
 pass PupilX2097152 { ComputeShader=FFT::CS_PupilX2097152; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 4194304
 pass PupilX4194304 { ComputeShader=FFT::CS_PupilX4194304; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 8388608
 pass PupilX8388608 { ComputeShader=FFT::CS_PupilX8388608; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 16777216
 pass PupilX16777216 { ComputeShader=FFT::CS_PupilX16777216; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 33554432
 pass PupilX33554432 { ComputeShader=FFT::CS_PupilX33554432; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 67108864
 pass PupilX67108864 { ComputeShader=FFT::CS_PupilX67108864; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 134217728
 pass PupilX134217728 { ComputeShader=FFT::CS_PupilX134217728; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 268435456
 pass PupilX268435456 { ComputeShader=FFT::CS_PupilX268435456; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 536870912
 pass PupilX536870912 { ComputeShader=FFT::CS_PupilX536870912; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 1073741824
 pass PupilX1073741824 { ComputeShader=FFT::CS_PupilX1073741824; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
 pass PupilRowsCommit { ComputeShader=FFT::CS_PupilRowsCommit; DispatchSizeX=(V2_P+15)/16; DispatchSizeY=(V2_P+15)/16; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
 pass PupilYLocal { ComputeShader=FFT::CS_PupilYLocal; DispatchSizeX=(V2_P+1023)/1024; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#if V2_P >= 2048
 pass PupilY2048 { ComputeShader=FFT::CS_PupilY2048; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 4096
 pass PupilY4096 { ComputeShader=FFT::CS_PupilY4096; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 8192
 pass PupilY8192 { ComputeShader=FFT::CS_PupilY8192; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 16384
 pass PupilY16384 { ComputeShader=FFT::CS_PupilY16384; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 32768
 pass PupilY32768 { ComputeShader=FFT::CS_PupilY32768; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 65536
 pass PupilY65536 { ComputeShader=FFT::CS_PupilY65536; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 131072
 pass PupilY131072 { ComputeShader=FFT::CS_PupilY131072; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 262144
 pass PupilY262144 { ComputeShader=FFT::CS_PupilY262144; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 524288
 pass PupilY524288 { ComputeShader=FFT::CS_PupilY524288; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 1048576
 pass PupilY1048576 { ComputeShader=FFT::CS_PupilY1048576; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 2097152
 pass PupilY2097152 { ComputeShader=FFT::CS_PupilY2097152; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 4194304
 pass PupilY4194304 { ComputeShader=FFT::CS_PupilY4194304; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 8388608
 pass PupilY8388608 { ComputeShader=FFT::CS_PupilY8388608; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 16777216
 pass PupilY16777216 { ComputeShader=FFT::CS_PupilY16777216; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 33554432
 pass PupilY33554432 { ComputeShader=FFT::CS_PupilY33554432; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 67108864
 pass PupilY67108864 { ComputeShader=FFT::CS_PupilY67108864; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 134217728
 pass PupilY134217728 { ComputeShader=FFT::CS_PupilY134217728; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 268435456
 pass PupilY268435456 { ComputeShader=FFT::CS_PupilY268435456; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 536870912
 pass PupilY536870912 { ComputeShader=FFT::CS_PupilY536870912; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
#if V2_P >= 1073741824
 pass PupilY1073741824 { ComputeShader=FFT::CS_PupilY1073741824; DispatchSizeX=(V2_P/2+255)/256; DispatchSizeY=V2_P; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
#endif
 pass OpticalIntensity { ComputeShader=FFT::CS_OpticalIntensity; DispatchSizeX=(V2_P+7)/8; DispatchSizeY=(V2_P+7)/8; DispatchSizeZ=V2_WAVES; GenerateMipMaps=false; }
 pass RawKernel { ComputeShader=FFT::CS_RawKernel; DispatchSizeX=(V2_K+7)/8; DispatchSizeY=(V2_K+7)/8; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass KernelStatistics { ComputeShader=FFT::CS_KernelStatistics; DispatchSizeX=1; DispatchSizeY=1; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass Extract { ComputeShader=FFT::CS_Extract; DispatchSizeX=(V2_W+15)/16; DispatchSizeY=(V2_H+15)/16; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass SourceStatistics { ComputeShader=FFT::CS_SourceStatistics; DispatchSizeX=1; DispatchSizeY=1; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass KernelXLocal { ComputeShader=FFT::CS_KernelXLocal; DispatchSizeX=(V2_FX+1023)/1024; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#if V2_FX >= 2048
 pass KernelX2048 { ComputeShader=FFT::CS_KernelX2048; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 4096
 pass KernelX4096 { ComputeShader=FFT::CS_KernelX4096; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 8192
 pass KernelX8192 { ComputeShader=FFT::CS_KernelX8192; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 16384
 pass KernelX16384 { ComputeShader=FFT::CS_KernelX16384; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 32768
 pass KernelX32768 { ComputeShader=FFT::CS_KernelX32768; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 65536
 pass KernelX65536 { ComputeShader=FFT::CS_KernelX65536; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 131072
 pass KernelX131072 { ComputeShader=FFT::CS_KernelX131072; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 262144
 pass KernelX262144 { ComputeShader=FFT::CS_KernelX262144; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 524288
 pass KernelX524288 { ComputeShader=FFT::CS_KernelX524288; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 1048576
 pass KernelX1048576 { ComputeShader=FFT::CS_KernelX1048576; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 2097152
 pass KernelX2097152 { ComputeShader=FFT::CS_KernelX2097152; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 4194304
 pass KernelX4194304 { ComputeShader=FFT::CS_KernelX4194304; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 8388608
 pass KernelX8388608 { ComputeShader=FFT::CS_KernelX8388608; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 16777216
 pass KernelX16777216 { ComputeShader=FFT::CS_KernelX16777216; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 33554432
 pass KernelX33554432 { ComputeShader=FFT::CS_KernelX33554432; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 67108864
 pass KernelX67108864 { ComputeShader=FFT::CS_KernelX67108864; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 134217728
 pass KernelX134217728 { ComputeShader=FFT::CS_KernelX134217728; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 268435456
 pass KernelX268435456 { ComputeShader=FFT::CS_KernelX268435456; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 536870912
 pass KernelX536870912 { ComputeShader=FFT::CS_KernelX536870912; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 1073741824
 pass KernelX1073741824 { ComputeShader=FFT::CS_KernelX1073741824; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
 pass KernelRowsCommit { ComputeShader=FFT::CS_KernelRowsCommit; DispatchSizeX=(V2_FX+15)/16; DispatchSizeY=(V2_FY+15)/16; DispatchSizeZ=3; GenerateMipMaps=false; }
 pass KernelYLocal { ComputeShader=FFT::CS_KernelYLocal; DispatchSizeX=(V2_FY+1023)/1024; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#if V2_FY >= 2048
 pass KernelY2048 { ComputeShader=FFT::CS_KernelY2048; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 4096
 pass KernelY4096 { ComputeShader=FFT::CS_KernelY4096; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 8192
 pass KernelY8192 { ComputeShader=FFT::CS_KernelY8192; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 16384
 pass KernelY16384 { ComputeShader=FFT::CS_KernelY16384; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 32768
 pass KernelY32768 { ComputeShader=FFT::CS_KernelY32768; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 65536
 pass KernelY65536 { ComputeShader=FFT::CS_KernelY65536; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 131072
 pass KernelY131072 { ComputeShader=FFT::CS_KernelY131072; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 262144
 pass KernelY262144 { ComputeShader=FFT::CS_KernelY262144; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 524288
 pass KernelY524288 { ComputeShader=FFT::CS_KernelY524288; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 1048576
 pass KernelY1048576 { ComputeShader=FFT::CS_KernelY1048576; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 2097152
 pass KernelY2097152 { ComputeShader=FFT::CS_KernelY2097152; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 4194304
 pass KernelY4194304 { ComputeShader=FFT::CS_KernelY4194304; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 8388608
 pass KernelY8388608 { ComputeShader=FFT::CS_KernelY8388608; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 16777216
 pass KernelY16777216 { ComputeShader=FFT::CS_KernelY16777216; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 33554432
 pass KernelY33554432 { ComputeShader=FFT::CS_KernelY33554432; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 67108864
 pass KernelY67108864 { ComputeShader=FFT::CS_KernelY67108864; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 134217728
 pass KernelY134217728 { ComputeShader=FFT::CS_KernelY134217728; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 268435456
 pass KernelY268435456 { ComputeShader=FFT::CS_KernelY268435456; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 536870912
 pass KernelY536870912 { ComputeShader=FFT::CS_KernelY536870912; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 1073741824
 pass KernelY1073741824 { ComputeShader=FFT::CS_KernelY1073741824; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
 pass KernelCommit { ComputeShader=FFT::CS_KernelCommit; DispatchSizeX=(V2_FX+15)/16; DispatchSizeY=(V2_FY+15)/16; DispatchSizeZ=3; GenerateMipMaps=false; }
