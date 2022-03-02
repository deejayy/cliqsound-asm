; [ebp + 8] hWnd
_InitWaveOut@4:
  push ebp
  mov ebp, esp

  push 0
  push dword lpDS
  push 0
  call [__imp__DirectSoundCreate@12]

._setCooperativeLevel:
  push 2   ; DSSCL_
  push dword [ebp + 8]
  mov eax, [lpDS]
  mov ecx, [eax]
  push eax ; this
  call [ecx+24] ; IDirectSound::SetCooperativeLevel

  mov esp, ebp
  pop ebp
  ret 4
;
