 pass SceneXLocal { ComputeShader=FFT::CS_SceneXLocal; DispatchSizeX=(V2_FX+1023)/1024; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#if V2_FX >= 2048
 pass SceneX2048 { ComputeShader=FFT::CS_SceneX2048; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 4096
 pass SceneX4096 { ComputeShader=FFT::CS_SceneX4096; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 8192
 pass SceneX8192 { ComputeShader=FFT::CS_SceneX8192; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 16384
 pass SceneX16384 { ComputeShader=FFT::CS_SceneX16384; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 32768
 pass SceneX32768 { ComputeShader=FFT::CS_SceneX32768; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 65536
 pass SceneX65536 { ComputeShader=FFT::CS_SceneX65536; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 131072
 pass SceneX131072 { ComputeShader=FFT::CS_SceneX131072; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 262144
 pass SceneX262144 { ComputeShader=FFT::CS_SceneX262144; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 524288
 pass SceneX524288 { ComputeShader=FFT::CS_SceneX524288; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 1048576
 pass SceneX1048576 { ComputeShader=FFT::CS_SceneX1048576; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 2097152
 pass SceneX2097152 { ComputeShader=FFT::CS_SceneX2097152; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 4194304
 pass SceneX4194304 { ComputeShader=FFT::CS_SceneX4194304; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 8388608
 pass SceneX8388608 { ComputeShader=FFT::CS_SceneX8388608; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 16777216
 pass SceneX16777216 { ComputeShader=FFT::CS_SceneX16777216; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 33554432
 pass SceneX33554432 { ComputeShader=FFT::CS_SceneX33554432; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 67108864
 pass SceneX67108864 { ComputeShader=FFT::CS_SceneX67108864; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 134217728
 pass SceneX134217728 { ComputeShader=FFT::CS_SceneX134217728; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 268435456
 pass SceneX268435456 { ComputeShader=FFT::CS_SceneX268435456; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 536870912
 pass SceneX536870912 { ComputeShader=FFT::CS_SceneX536870912; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 1073741824
 pass SceneX1073741824 { ComputeShader=FFT::CS_SceneX1073741824; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
 pass SceneRowsCommit { ComputeShader=FFT::CS_SceneRowsCommit; DispatchSizeX=(V2_FX+15)/16; DispatchSizeY=(V2_FY+15)/16; DispatchSizeZ=3; GenerateMipMaps=false; }
 pass SceneYLocal { ComputeShader=FFT::CS_SceneYLocal; DispatchSizeX=(V2_FY+1023)/1024; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#if V2_FY >= 2048
 pass SceneY2048 { ComputeShader=FFT::CS_SceneY2048; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 4096
 pass SceneY4096 { ComputeShader=FFT::CS_SceneY4096; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 8192
 pass SceneY8192 { ComputeShader=FFT::CS_SceneY8192; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 16384
 pass SceneY16384 { ComputeShader=FFT::CS_SceneY16384; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 32768
 pass SceneY32768 { ComputeShader=FFT::CS_SceneY32768; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 65536
 pass SceneY65536 { ComputeShader=FFT::CS_SceneY65536; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 131072
 pass SceneY131072 { ComputeShader=FFT::CS_SceneY131072; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 262144
 pass SceneY262144 { ComputeShader=FFT::CS_SceneY262144; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 524288
 pass SceneY524288 { ComputeShader=FFT::CS_SceneY524288; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 1048576
 pass SceneY1048576 { ComputeShader=FFT::CS_SceneY1048576; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 2097152
 pass SceneY2097152 { ComputeShader=FFT::CS_SceneY2097152; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 4194304
 pass SceneY4194304 { ComputeShader=FFT::CS_SceneY4194304; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 8388608
 pass SceneY8388608 { ComputeShader=FFT::CS_SceneY8388608; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 16777216
 pass SceneY16777216 { ComputeShader=FFT::CS_SceneY16777216; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 33554432
 pass SceneY33554432 { ComputeShader=FFT::CS_SceneY33554432; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 67108864
 pass SceneY67108864 { ComputeShader=FFT::CS_SceneY67108864; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 134217728
 pass SceneY134217728 { ComputeShader=FFT::CS_SceneY134217728; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 268435456
 pass SceneY268435456 { ComputeShader=FFT::CS_SceneY268435456; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 536870912
 pass SceneY536870912 { ComputeShader=FFT::CS_SceneY536870912; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 1073741824
 pass SceneY1073741824 { ComputeShader=FFT::CS_SceneY1073741824; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
 pass Multiply { ComputeShader=FFT::CS_Multiply; DispatchSizeX=(V2_FX+15)/16; DispatchSizeY=(V2_FY+15)/16; DispatchSizeZ=3; GenerateMipMaps=false; }
 pass InverseXLocal { ComputeShader=FFT::CS_InverseXLocal; DispatchSizeX=(V2_FX+1023)/1024; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#if V2_FX >= 2048
 pass InverseX2048 { ComputeShader=FFT::CS_InverseX2048; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 4096
 pass InverseX4096 { ComputeShader=FFT::CS_InverseX4096; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 8192
 pass InverseX8192 { ComputeShader=FFT::CS_InverseX8192; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 16384
 pass InverseX16384 { ComputeShader=FFT::CS_InverseX16384; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 32768
 pass InverseX32768 { ComputeShader=FFT::CS_InverseX32768; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 65536
 pass InverseX65536 { ComputeShader=FFT::CS_InverseX65536; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 131072
 pass InverseX131072 { ComputeShader=FFT::CS_InverseX131072; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 262144
 pass InverseX262144 { ComputeShader=FFT::CS_InverseX262144; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 524288
 pass InverseX524288 { ComputeShader=FFT::CS_InverseX524288; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 1048576
 pass InverseX1048576 { ComputeShader=FFT::CS_InverseX1048576; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 2097152
 pass InverseX2097152 { ComputeShader=FFT::CS_InverseX2097152; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 4194304
 pass InverseX4194304 { ComputeShader=FFT::CS_InverseX4194304; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 8388608
 pass InverseX8388608 { ComputeShader=FFT::CS_InverseX8388608; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 16777216
 pass InverseX16777216 { ComputeShader=FFT::CS_InverseX16777216; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 33554432
 pass InverseX33554432 { ComputeShader=FFT::CS_InverseX33554432; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 67108864
 pass InverseX67108864 { ComputeShader=FFT::CS_InverseX67108864; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 134217728
 pass InverseX134217728 { ComputeShader=FFT::CS_InverseX134217728; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 268435456
 pass InverseX268435456 { ComputeShader=FFT::CS_InverseX268435456; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 536870912
 pass InverseX536870912 { ComputeShader=FFT::CS_InverseX536870912; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FX >= 1073741824
 pass InverseX1073741824 { ComputeShader=FFT::CS_InverseX1073741824; DispatchSizeX=(V2_FX/2+255)/256; DispatchSizeY=V2_FY; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
 pass InverseRowsCommit { ComputeShader=FFT::CS_InverseRowsCommit; DispatchSizeX=(V2_FX+15)/16; DispatchSizeY=(V2_FY+15)/16; DispatchSizeZ=3; GenerateMipMaps=false; }
 pass InverseYLocal { ComputeShader=FFT::CS_InverseYLocal; DispatchSizeX=(V2_FY+1023)/1024; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#if V2_FY >= 2048
 pass InverseY2048 { ComputeShader=FFT::CS_InverseY2048; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 4096
 pass InverseY4096 { ComputeShader=FFT::CS_InverseY4096; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 8192
 pass InverseY8192 { ComputeShader=FFT::CS_InverseY8192; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 16384
 pass InverseY16384 { ComputeShader=FFT::CS_InverseY16384; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 32768
 pass InverseY32768 { ComputeShader=FFT::CS_InverseY32768; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 65536
 pass InverseY65536 { ComputeShader=FFT::CS_InverseY65536; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 131072
 pass InverseY131072 { ComputeShader=FFT::CS_InverseY131072; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 262144
 pass InverseY262144 { ComputeShader=FFT::CS_InverseY262144; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 524288
 pass InverseY524288 { ComputeShader=FFT::CS_InverseY524288; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 1048576
 pass InverseY1048576 { ComputeShader=FFT::CS_InverseY1048576; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 2097152
 pass InverseY2097152 { ComputeShader=FFT::CS_InverseY2097152; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 4194304
 pass InverseY4194304 { ComputeShader=FFT::CS_InverseY4194304; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 8388608
 pass InverseY8388608 { ComputeShader=FFT::CS_InverseY8388608; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 16777216
 pass InverseY16777216 { ComputeShader=FFT::CS_InverseY16777216; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 33554432
 pass InverseY33554432 { ComputeShader=FFT::CS_InverseY33554432; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 67108864
 pass InverseY67108864 { ComputeShader=FFT::CS_InverseY67108864; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 134217728
 pass InverseY134217728 { ComputeShader=FFT::CS_InverseY134217728; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 268435456
 pass InverseY268435456 { ComputeShader=FFT::CS_InverseY268435456; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 536870912
 pass InverseY536870912 { ComputeShader=FFT::CS_InverseY536870912; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
#if V2_FY >= 1073741824
 pass InverseY1073741824 { ComputeShader=FFT::CS_InverseY1073741824; DispatchSizeX=(V2_FY/2+255)/256; DispatchSizeY=V2_FX; DispatchSizeZ=3; GenerateMipMaps=false; }
#endif
 pass Bloom { ComputeShader=FFT::CS_Bloom; DispatchSizeX=(V2_W+7)/8; DispatchSizeY=(V2_H+7)/8; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass SourceHistory { ComputeShader=FFT::CS_SourceHistory; DispatchSizeX=(V2_W+7)/8; DispatchSizeY=(V2_H+7)/8; DispatchSizeZ=1; GenerateMipMaps=false; }
 pass CacheCommit { ComputeShader=FFT::CS_CacheCommit; DispatchSizeX=1; DispatchSizeY=1; DispatchSizeZ=1; GenerateMipMaps=false; }
