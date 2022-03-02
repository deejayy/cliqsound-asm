section .data

%include "imports.inc"
%include "types.inc"

GLOBAL DestroyWaveOut@4
EXPORT DestroyWaveOut@4
GLOBAL LoadFileToBuffer@8
EXPORT LoadFileToBuffer@8
GLOBAL InitWaveOut@4
EXPORT InitWaveOut@4
GLOBAL LoadWave@16
EXPORT LoadWave@16
GLOBAL PlayWave@4
EXPORT PlayWave@4

_hInstance dd 0

section .text

GLOBAL _DllMain@12
_DllMain@12:
  mov   eax, dword [ebp + 12]
  mov   [_hInstance], eax
  mov   eax, 1
  ret   12
;

%include "func-init-waveout.inc"
%include "func-file-to-buffer.inc"
%include "func-load-wave.inc"
%include "func-play-wave.inc"
%include "func-destroy-waveout.inc"
