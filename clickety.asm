%include "imports.inc"
%include "types.inc"

MIXRATE     equ 48000
BUFFER_SIZE equ 10000h
WM_DESTROY  equ 2
WM_KEYDOWN  equ 100h
WM_KEYUP    equ 101h

section .data

WindowClass db "CliqAsm", 0
hInstance dd 0
hWnd dd 0
fileName1 db ".\sound\cliq-0\keydown.wav", 0
fileName2 db ".\sound\cliq-0\keyup.wav", 0
fileHandle dd 0
bytesRead dd 0
riffHeader resd 5
dataChunkDesc dd 0
dataChunkSize dd 0 ; FIXME, indirect assignment
dataPtr dd 0

lpDS     dd 0 ; -> IDirectSound
lpDSBuf1 dd 0 ; -> IDirectSoundBuffer
lpDSBuf2 dd 0 ; -> IDirectSoundBuffer

; Wave format descriptor used to configure the DirectSound buffer
pcm  dd 20001h  ; wFormatTag <= WAVE_FORMAT_PCM, nChannels <= 2
  dd MIXRATE
  dd MIXRATE*4
  dd 100004h ; wBitsPerSample <= 16, nBlockAlign <= 4
  dd 0       ; cbSize <= 0 (no extra info)
;

; DirectSound buffer descriptor
bufDesc dd 20 ; DSBUFFERDESC1
  ; (for older DirectX versions compatibility)
  dd 14000h ; dwFlags <= DSBCAPS_STICKYFOCUS OR DSBCAPS_GETCURRENTPOSITION2
  dd BUFFER_SIZE ; dwBufferBytes
  dd 0
  dd pcm ; lpwfxFormat
;

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

waveHeader: istruc WAVEFORMATEX
  at WAVEFORMATEX.wFormatTag,      dw 0
  at WAVEFORMATEX.nChannels,       dw 0
  at WAVEFORMATEX.nSamplesPerSec,  dd 0
  at WAVEFORMATEX.nAvgBytesPerSec, dd 0
  at WAVEFORMATEX.nBlockAlign,     dw 0
  at WAVEFORMATEX.wBitsPerSample,  dw 0
  at WAVEFORMATEX.cbSize,          dw WAVEFORMATEX_size
iend

section .text

GLOBAL _Main
_Main:
  call _CreateWindow
  call _InitWaveOut

  push dword fileName1
  push dword dataPtr
  call _LoadFileToBuffer

  push dword dataPtr
  push dword lpDSBuf1
  call _LoadWave

  push dword fileName2
  push dword dataPtr
  call _LoadFileToBuffer

  push dword dataPtr
  push dword lpDSBuf2
  call _LoadWave

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
  call _PlayWave
  jmp ._WndProc_return

._WndProc_emitSound_up:
  push dword lpDSBuf2
  call _PlayWave
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
  call _DestroyWaveOut@4

  call DelKeyHook

  push dword [hWnd]
  call [__imp__DestroyWindow@4]

  push 0
  call [__imp__ExitProcess@4]

  ret
;

_InitWaveOut:
  ; Request an instance of IDirectSound.
  push 0
  push dword lpDS
  push 0
  call [__imp__DirectSoundCreate@12]

._setCooperativeLevel:
  push 2   ; DSSCL_
  push dword [hWnd]
  mov eax, [lpDS]
  mov ecx, [eax]
  push eax ; this
  call [ecx+24] ; IDirectSound::SetCooperativeLevel

  ret
;

_LoadFileToBuffer:
  push ebp
  mov ebp, esp

._openFile:
  push 0
  push 80h ; FILE_ATTRIBUTE_NORMAL
  push 3 ; OPEN_EXISTING
  push 0
  push 1 ; FILE_SHARE_READ
  push 80000000h ; GENERIC_READ
  push dword [ebp + 12]
  call [__imp__CreateFileA@28]

  mov dword [fileHandle], eax

._readRiffHeader:
  push 0
  push dword [bytesRead]
  push 14h ; "RIFF    WAVEfmt ...."
  push riffHeader
  push dword [fileHandle]
  call [__imp__ReadFile@20]

._readWaveHeader:
  push 0
  push dword [bytesRead]
  push 10h ; "sizeof WAVEFORMATEX"
  push waveHeader
  push dword [fileHandle]
  call [__imp__ReadFile@20]

._readChunkInfo:
  push 0
  push dword [bytesRead]
  push 8h ; "data...."
  push dataChunkDesc
  push dword [fileHandle]
  call [__imp__ReadFile@20]

._allocateBuffer:
  push dword [dataChunkSize]
  push 0
  call [__imp__GlobalAlloc@8]
  mov ebx, [ebp + 8]
  mov [ebx], eax

._readChunkData:
  push 0
  push dword [bytesRead]
  push dword [dataChunkSize]
  push dword [ebx]
  push dword [fileHandle]
  call [__imp__ReadFile@20]

._closeFile:
  push dword [fileHandle]
  call [__imp__CloseHandle@4]

._LoadFileToBuffer_return:
  mov esp, ebp
  pop ebp
  ret 12
;

; [ebp + 12] pointer to the wave data buffer 
; [ebp + 8] existing DirectSound buffer ready to receive data
_LoadWave:
  push ebp
  mov ebp, esp

  mov eax, [ebp + 8]
  mov [.localDSBuffer], eax

  mov eax, [ebp + 12]
  mov [.localDataBuffer], eax

._createSoundBuffer:
  push 0
  push dword [.localDSBuffer]
  push bufDesc
  mov eax, [lpDS]
  mov ecx, [eax]
  push eax ; this
  call [ecx+12] ; IDirectSound::CreateSoundBuffer

._lockBuffer:
  push 0 ; dwFlags
  push .dwSize2
  push .lpPtr2
  push .dwSize1
  push .lpPtr1
  push BUFFER_SIZE
  push 0
  mov eax, dword [.localDSBuffer]
  mov eax, [eax]
  mov ecx, [eax]
  push eax ; this
  call [ecx+44] ; IDirectSoundBuffer::Lock

._copyData:
  mov eax, dword [.localDataBuffer]
  mov esi, [eax]
  mov edi, [.lpPtr1]
  mov ecx, [dataChunkSize]
  rep movsb

._unlockBuffer:
  push 0
  push 0
  push DWORD [.dwSize1]
  push DWORD [.lpPtr1]
  mov eax, dword [.localDSBuffer]
  mov eax, [eax]
  mov ecx, [eax]
  push eax ; this
  call [ecx+76] ; IDirectSoundBuffer::Unlock
  
._LoadWave_return:
  mov esp, ebp
  pop ebp
  ret 16

  .localDSBuffer dd 0
  .localDataBuffer dd 0
  .dwSize2 dd 0
  .lpPtr2  dd 0
  .dwSize1 dd 0
  .lpPtr1  dd 0
;

_PlayWave:
  push ebp
  mov ebp, esp

  mov eax, [ebp + 8]
  mov [.localDSBuffer], eax

  push 0   ; dwFlags = DSBPLAY_LOOPING
  push 0
  push 0
  mov eax, dword [.localDSBuffer]
  mov eax, [eax]
  mov ecx, [eax]
  push eax ; this
  call [ecx+48] ; IDirectSoundBuffer::Play

._PlayWave_return:
  mov esp, ebp
  pop ebp
  ret 12

  .localDSBuffer dd 0
;

_DestroyWaveOut@4:
  ; Release DirectSound instance and free all buffers.
  mov eax, [lpDS]
  mov ecx, [eax]
  push eax
  call [ecx+8]  ; IDirectSound::Release

  ret
;
