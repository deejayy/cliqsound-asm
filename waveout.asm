%include "imports.inc"
%include "types.inc"

section .text
_hInstance dd 0

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
