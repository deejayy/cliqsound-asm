; [ebp + 8] DirectSound/Buffer output device
DestroyWaveOut@4:
  push ebp
  mov ebp, esp

  mov eax, [ebp + 8]
  mov eax, [eax]
  mov ecx, [eax]
  push eax
  call [ecx+8]  ; IDirectSound::Release, IDirectSoundBuffer::Release (IUnkown actually)

  mov esp, ebp
  pop ebp
  ret 4
;
