; [ebp + 8] hWnd
InitWaveOut@4:
  push ebp
  mov ebp, esp

  push 0
  push dword .lpDS
  push 0
  call [__imp__DirectSoundCreate@12]

._setCooperativeLevel:
  push 2   ; DSSCL_
  push dword [ebp + 8]
  mov eax, [.lpDS]
  mov ecx, [eax]
  push eax ; this
  call [ecx+24] ; IDirectSound::SetCooperativeLevel

  mov eax, dword [.lpDS]

  mov esp, ebp
  pop ebp
  ret 4

  .lpDS dd 0
;
