%include "imports.inc"
%include "types.inc"

EXTERN SetKeyHook
EXTERN DelKeyHook

WM_DESTROY  equ 2
WM_KEYDOWN  equ 100h
WM_KEYUP    equ 101h

section .data

WindowClass db "CliqAsm", 0
hInstance dd 0
hWnd dd 0
fileName1 db ".\sound\cliq-0\keydown.wav", 0
fileName2 db ".\sound\cliq-0\keyup.wav", 0
bytesRead dd 0
dataPtr1 dd 0
dataPtr2 dd 0

lpDS     dd 0 ; -> IDirectSound
lpDSBuf1 dd 0 ; -> IDirectSoundBuffer
lpDSBuf2 dd 0 ; -> IDirectSoundBuffer

Window: istruc WNDCLASSEX
  at WNDCLASSEX.cbSize,        dd WNDCLASSEX_size
  at WNDCLASSEX.style,         dd 3 ; CS_HREDRAW|CS_VREDRAW
  at WNDCLASSEX.lpfnWndProc,   dd _WndProc
  at WNDCLASSEX.cbClsExtra,    dd 0
  at WNDCLASSEX.cbWndExtra,    dd 0
  at WNDCLASSEX.hInstance,     dd 0
  at WNDCLASSEX.hIcon,         dd 0
  at WNDCLASSEX.hCursor,       dd 0
  at WNDCLASSEX.hbrBackground, dd 5 ; COLOR_WINDOW
  at WNDCLASSEX.lpszMenuName,  dd 0
  at WNDCLASSEX.lpszClassName, dd WindowClass
  at WNDCLASSEX.hIconSm,       dd 0
iend

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
  call _CreateWindow

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

  call _ShowWindow
  call SetKeyHook
  jmp _Message_loop
;

_WndProc:
  push ebp
  mov ebp, esp

  cmp dword [ebp + 12], WM_DESTROY
  je ._WndProc_destroy
  cmp dword [ebp + 12], 0x401
  je ._WndProc_emitSound

  push dword [ebp + 20]
  push dword [ebp + 16]
  push dword [ebp + 12]
  push dword [ebp + 8]
  call [__imp__DefWindowProcA@16]

._WndProc_return:
  mov esp, ebp
  pop ebp
  ret 16

._WndProc_destroy:
  push 0
  call [__imp__PostQuitMessage@4]
  xor eax, eax
  jmp ._WndProc_return

._WndProc_emitSound:
  mov eax, dword [ebp + 20]
  shr eax, 30

  cmp eax, 0
  je ._WndProc_emitSound_down

  cmp eax, 3
  je ._WndProc_emitSound_up

  jmp ._WndProc_return

._WndProc_emitSound_down:
  push dword lpDSBuf1
  call PlayWave@4
  jmp ._WndProc_return

._WndProc_emitSound_up:
  push dword lpDSBuf2
  call PlayWave@4
  jmp ._WndProc_return
;

_CreateWindow:
  push 0
  call [__imp__GetModuleHandleA@4]
  mov ebx, Window
  mov [hInstance], eax
  mov [ebx + WNDCLASSEX.hInstance], eax

  push 32512 ; IDC_ARROW
  push 0
  call [__imp__LoadCursorA@8]
  mov [ebx + WNDCLASSEX.hCursor], eax

  push 32512 ; IDI_APPLICATION
  push 0
  call [__imp__LoadIconA@8]
  mov [ebx + WNDCLASSEX.hIcon], eax

  push Window
  call [__imp__RegisterClassExA@4]

  push 0
  push dword [hInstance]
  push 0
  push 0
  push 300
  push 300
  push 200
  push 200
  push 0C00000h|80000h|40000h|20000h|10000h|10000000h ; WS_OVERLAPPED|WS_CAPTION|WS_SYSMENU|WS_THICKFRAME|WS_MINIMIZEBOX|WS_MAXIMIZEBOX|WS_VISIBLE
  push WindowClass
  push WindowClass
  push 0
  call [__imp__CreateWindowExA@48]
  mov [hWnd], eax

  ret
;

_ShowWindow:
  push 5 ; SW_SHOW
  push dword [hWnd]
  call [__imp__ShowWindow@8]
  ret
;

_Message_loop:
  push 0
  push 0
  push 0
  push Message
  call [__imp__GetMessageA@16]

  cmp eax, 0
  je ._Message_loop_end

  push Message
  call [__imp__TranslateMessage@4]

  push Message
  call [__imp__DispatchMessageA@4]

  jmp _Message_loop

._Message_loop_end:
._Return:
  push dword lpDS
  call DestroyWaveOut@4

  call DelKeyHook

  push dword [hWnd]
  call [__imp__DestroyWindow@4]

  push 0
  call [__imp__ExitProcess@4]

  ret
;

%include "func-init-waveout.inc"
%include "func-file-to-buffer.inc"
%include "func-load-wave.inc"
%include "func-play-wave.inc"
%include "func-destroy-waveout.inc"
