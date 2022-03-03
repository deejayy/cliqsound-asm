%include "imports.inc"
%include "types.inc"

EXTERN SetKeyHook
EXTERN DelKeyHook

section .data

WindowClass db "CliqAsm", 0
hWnd dd 0
fileName1 db ".\sound\cliq-0\keydown.wav", 0
fileName2 db ".\sound\cliq-0\keyup.wav", 0
bytesRead dd 0
dataPtr1 dd 0
dataPtr2 dd 0

lpDS     dd 0 ; -> IDirectSound
lpDSBuf1 dd 0 ; -> IDirectSoundBuffer
lpDSBuf2 dd 0 ; -> IDirectSoundBuffer

Message: istruc MSG
  at MSG.hwnd,                 dd 0
  at MSG.message,              dd 0
  at MSG.wParam,               dw 0
  at MSG.lParam,               dw 0
  at MSG.time,                 dd 0
  at MSG.pt,                   dd 0
iend

section .text

GLOBAL _Main
_Main:
  call _CreateWindow@4
  mov [hWnd], eax

  push dword [hWnd]
  call InitWaveOut@4

  mov dword [lpDS], eax

  push dword dataPtr1
  push dword fileName1
  call LoadFileToBuffer@8

  push eax
  push dword dataPtr1
  push dword lpDSBuf1
  push dword lpDS
  call LoadWave@16

  push dword dataPtr2
  push dword fileName2
  call LoadFileToBuffer@8

  push eax
  push dword dataPtr2
  push dword lpDSBuf2
  push dword lpDS
  call LoadWave@16

  push dword [hWnd]
  call _ShowWindow
  call SetKeyHook
  jmp _Message_loop
;

%include "func-window-handling.inc"

_PlayKeyDown:
  push dword lpDSBuf1
  call PlayWave@4
  ret
;

_PlayKeyUp:
  push dword lpDSBuf2
  call PlayWave@4
  ret
;

%include "func-init-waveout.inc"
%include "func-file-to-buffer.inc"
%include "func-load-wave.inc"
%include "func-play-wave.inc"
%include "func-destroy-waveout.inc"
