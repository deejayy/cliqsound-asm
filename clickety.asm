section .data

%include "imports.inc"
%include "types.inc"

EXTERN SetKeyHook
EXTERN DelKeyHook

CHANNELS equ 8

WindowClass db "CliqAsm", 0
fileName1 db ".\sound\cherry-mx-white\cherry-mx-white-down01.wav", 0
fileName2 db ".\sound\cherry-mx-white\cherry-mx-white-up01.wav", 0
currentChannel dd 0
currentBuffer dd 0

section .bss

hWnd resd 1
bytesRead resd 1
dataPtr1 resd 1
dataPtr2 resd 1
dataSize1 resd 1
dataSize2 resd 1

lpDS    resd 1 ; -> IDirectSound
lpDSBuf resd CHANNELS ; -> IDirectSoundBuffer array

Message: istruc MSG
  at MSG.hwnd,    resd 1
  at MSG.message, resd 1
  at MSG.wParam,  resw 1
  at MSG.lParam,  resw 1
  at MSG.time,    resd 1
  at MSG.pt,      resd 1
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
  mov [dataSize1], eax

  push dword dataPtr2
  push dword fileName2
  call LoadFileToBuffer@8
  mov [dataSize2], eax

  push dword [hWnd]
  call _ShowWindow
  call SetKeyHook
  jmp _Message_loop
;

_PlayKeyDown:
  call _SetCurrentBuffer

  push dword [dataSize1]
  push dword dataPtr1
  push dword [currentBuffer]
  push dword lpDS
  call LoadWave@16

  push dword [currentBuffer]
  call PlayWave@4
  ret
;

_PlayKeyUp:
  call _SetCurrentBuffer

  push dword [dataSize2]
  push dword dataPtr2
  push dword [currentBuffer]
  push dword lpDS
  call LoadWave@16

  push dword [currentBuffer]
  call PlayWave@4
  ret
;

_SetCurrentBuffer:
  mov eax, [currentChannel]
  add eax, 1
  xor edx, edx
  mov ecx, CHANNELS
  div ecx
  mov eax, edx
  mov [currentChannel], eax
  mov ecx, 4
  mul ecx
  add eax, lpDSBuf
  mov ecx, eax
  ; mov eax, [eax]
  mov [currentBuffer], eax

  mov eax, [eax]
  cmp eax, 0

  je ._SetCurrentBuffer_return

  push dword [currentBuffer]
  call DestroyWaveOut@4

._SetCurrentBuffer_return:
  ret
;

%include "func-window-handling.inc"
%include "func-init-waveout.inc"
%include "func-file-to-buffer.inc"
%include "func-load-wave.inc"
%include "func-play-wave.inc"
%include "func-destroy-waveout.inc"

