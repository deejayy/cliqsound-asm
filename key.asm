section .data

EXTERN __imp__FindWindowA@8
EXTERN __imp__SendMessageA@16
EXTERN __imp__CallNextHookEx@16
EXTERN __imp__SetWindowsHookExA@16
EXTERN __imp__UnhookWindowsHookEx@4

GLOBAL SetKeyHook
EXPORT SetKeyHook
GLOBAL DelKeyHook
EXPORT DelKeyHook

section .text
_hInstance dd 0
_hHook dd 0
_windowHandle dd 0
_windowName db "CliqAsm", 0

SetKeyHook:
  cmp     dword [_hHook], 0
  jne     .return_SetKeyHook

  push    0
  push    dword [_hInstance]
  push    hookproc
  push    2
  call    [__imp__SetWindowsHookExA@16]
  mov     [_hHook], eax

.return_SetKeyHook:
  ret
;

DelKeyHook:
  mov     eax, [_hHook]
  cmp     eax, 0
  je      .return_DelKeyHook

  push    _hHook
  call    [__imp__UnhookWindowsHookEx@4]

.return_DelKeyHook:
  ret
;

GLOBAL _DllMain@12
_DllMain@12:
  mov   eax, dword [ebp + 12]
  mov   [_hInstance], eax
  mov   eax, 1
  ret   12
;

hookproc:
  push  ebp
  mov   ebp, esp

  cmp   dword [ebp + 8], 0
  jne   .return_hookproc

  push  0
  push  _windowName
  call  [__imp__FindWindowA@8]
  mov   [_windowHandle], eax

  cmp   eax, 0
  je    .return_hookproc

  push  dword [ebp + 16]
  push  dword [ebp + 12]
  push  0x401
  push  eax
  call  [__imp__SendMessageA@16]

.return_hookproc:
  push  dword [ebp + 16]
  push  dword [ebp + 12]
  push  dword [ebp + 8]
  push  _hHook
  call  [__imp__CallNextHookEx@16]

  mov   esp, ebp
  pop   ebp
  ret   16
;
