_WndProc:
  push ebp
  mov ebp, esp

  cmp dword [ebp + 12], 0x002 ; WM_DESTROY
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
  call _PlayKeyDown
  jmp ._WndProc_return

._WndProc_emitSound_up:
  call _PlayKeyUp
  jmp ._WndProc_return
;

_CreateWindow@4:
  push ebp
  mov ebp, esp

  push 0
  call [__imp__GetModuleHandleA@4]
  mov ebx, .Window
  mov [ebx + WNDCLASSEX.hInstance], eax

  push 32512 ; IDC_ARROW
  push 0
  call [__imp__LoadCursorA@8]
  mov [ebx + WNDCLASSEX.hCursor], eax

  push 32512 ; IDI_APPLICATION
  push 0
  call [__imp__LoadIconA@8]
  mov [ebx + WNDCLASSEX.hIcon], eax

  push .Window
  call [__imp__RegisterClassExA@4]

  push 0
  push dword [ebx + WNDCLASSEX.hInstance]
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

  mov esp, ebp
  pop ebp
  ret 4

  .Window: istruc WNDCLASSEX
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
;

; [ebp + 8] hWnd
_ShowWindow:
  push ebp
  mov ebp, esp

  push 5 ; SW_SHOW
  push dword [ebp + 8]
  call [__imp__ShowWindow@8]

  mov esp, ebp
  pop ebp
  ret 4
;

_Message_loop:
_Message_loop_start:
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
