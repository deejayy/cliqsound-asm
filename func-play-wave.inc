; [ebp + 8] DirectSoundBuffer object, should be already loaded with sound data
_PlayWave@4:
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
  ret 4

  .localDSBuffer dd 0
;
