section .data

%include "imports.inc"
%include "types.inc"

EXTERN SetKeyHook
EXTERN DelKeyHook

CHANNELS equ 16
MAXFILES equ 20

fileNameDown1 db ".\sound\cherry-mx-white\cherry-mx-white-down01.wav", 0
fileNameDown2 db ".\sound\cherry-mx-white\cherry-mx-white-down02.wav", 0
fileNameDown3 db ".\sound\cherry-mx-white\cherry-mx-white-down03.wav", 0
fileNameDown4 db ".\sound\cherry-mx-white\cherry-mx-white-down04.wav", 0
fileNameDown5 db ".\sound\cherry-mx-white\cherry-mx-white-down05.wav", 0
fileNameDown6 db ".\sound\cherry-mx-white\cherry-mx-white-down06.wav", 0
fileNameDown7 db ".\sound\cherry-mx-white\cherry-mx-white-down07.wav", 0
fileNameUp1 db ".\sound\cherry-mx-white\cherry-mx-white-up01.wav", 0
fileNameUp2 db ".\sound\cherry-mx-white\cherry-mx-white-up02.wav", 0
fileNameUp3 db ".\sound\cherry-mx-white\cherry-mx-white-up03.wav", 0
fileNameUp4 db ".\sound\cherry-mx-white\cherry-mx-white-up04.wav", 0
fileNameUp5 db ".\sound\cherry-mx-white\cherry-mx-white-up05.wav", 0
fileNameUp6 db ".\sound\cherry-mx-white\cherry-mx-white-up06.wav", 0
fileNameUp7 db ".\sound\cherry-mx-white\cherry-mx-white-up07.wav", 0

fileNamesDown dd fileNameDown1, fileNameDown2, fileNameDown3, fileNameDown4, fileNameDown5, fileNameDown6, fileNameDown7
fileNamesUp dd fileNameUp1, fileNameUp2, fileNameUp3, fileNameUp4, fileNameUp5, fileNameUp6, fileNameUp7
fileCountDown dd 7
fileCountUp dd 7

WindowClass db "CliqAsm", 0
currentChannel dd 0
currentDSBuffer dd 0
fileLoadIterator dd 0

sysTime: istruc SYSTEMTIME
  at SYSTEMTIME.wYear,         dw 0
  at SYSTEMTIME.wMonth,        dw 0
  at SYSTEMTIME.wDayOfWeek,    dw 0
  at SYSTEMTIME.wDay,          dw 0
  at SYSTEMTIME.wHour,         dw 0
  at SYSTEMTIME.wMinute,       dw 0
  at SYSTEMTIME.wSecond,       dw 0
  at SYSTEMTIME.wMilliseconds, dw 0
iend

section .bss

hWnd resd 1
bytesRead resd 1

dataPtrsDown resd MAXFILES
dataPtrsUp resd MAXFILES
dataSizesDown resd MAXFILES
dataSizesUp resd MAXFILES

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

  mov ecx, [fileCountDown]

._loadFileIterationDown:
  sub ecx, 1

  mov eax, dataPtrsDown
  lea ebx, [eax+ecx*4]
  push dword ebx

  mov eax, fileNamesDown
  lea ebx, [eax+ecx*4]
  push dword [ebx]

  mov [fileLoadIterator], ecx

  call LoadFileToBuffer@8

  mov ecx, [fileLoadIterator]

  mov ebx, dataSizesDown
  lea ebx, [ebx+ecx*4]
  mov [ebx], eax

  cmp ecx, 0
  jnz ._loadFileIterationDown
;

  mov ecx, [fileCountUp]

._loadFileIterationUp:
  sub ecx, 1

  mov eax, dataPtrsUp
  lea ebx, [eax+ecx*4]
  push dword ebx

  mov eax, fileNamesUp
  lea ebx, [eax+ecx*4]
  push dword [ebx]

  mov [fileLoadIterator], ecx

  call LoadFileToBuffer@8

  mov ecx, [fileLoadIterator]

  mov ebx, dataSizesUp
  lea ebx, [ebx+ecx*4]
  mov [ebx], eax

  cmp ecx, 0
  jnz ._loadFileIterationUp
;

  push dword [hWnd]
  call _ShowWindow
  call SetKeyHook
  jmp _Message_loop
;

_PlayKeyDown:
  call _SetCurrentDSBuffer

  mov eax, [sysTime + SYSTEMTIME.wMilliseconds]
  mov ecx, [fileCountDown]
  xor edx, edx
  div ecx ; edx = remainder

  mov eax, dataSizesDown
  lea eax, [eax+edx*4]
  push dword [eax]

  mov eax, dataPtrsDown
  lea eax, [eax+edx*4]
  push dword eax

  push dword [currentDSBuffer]
  push dword lpDS
  call LoadWave@16

  push dword [currentDSBuffer]
  call PlayWave@4
  ret
;

_PlayKeyUp:
  call _SetCurrentDSBuffer

  mov eax, [sysTime + SYSTEMTIME.wMilliseconds]
  mov ecx, [fileCountUp]
  xor edx, edx
  div ecx ; edx = remainder

  mov eax, dataSizesUp
  lea eax, [eax+edx*4]
  push dword [eax]

  mov eax, dataPtrsUp
  lea eax, [eax+edx*4]
  push dword eax

  push dword [currentDSBuffer]
  push dword lpDS
  call LoadWave@16

  push dword [currentDSBuffer]
  call PlayWave@4
  ret
;

_SetCurrentDSBuffer:
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
  mov [currentDSBuffer], eax

  mov eax, [eax]
  cmp eax, 0

  je ._SetCurrentDSBuffer_return

  push dword [currentDSBuffer]
  call DestroyWaveOut@4

._SetCurrentDSBuffer_return:
  push dword sysTime
  call [__imp__GetSystemTime@4]

  ret
;

%include "func-window-handling.inc"
%include "func-init-waveout.inc"
%include "func-file-to-buffer.inc"
%include "func-load-wave.inc"
%include "func-play-wave.inc"
%include "func-destroy-waveout.inc"

