; [ebp + 20] size of the data buffer
; [ebp + 16] pointer to the wave data buffer
; [ebp + 12] existing DirectSound buffer ready to receive data
; [ebp + 8] DirectSound output device
LoadWave@16:
  push ebp
  mov ebp, esp

  mov eax, [ebp + 8]
  mov eax, [eax]
  mov [.localDS], eax

  mov eax, [ebp + 12]
  mov [.localDSBuffer], eax

  mov eax, [ebp + 16]
  mov [.localDataBuffer], eax

  mov eax, [ebp + 20]
  mov [.chunkSize], eax

  mov [.bufDesc + DSBUFFERDESC.dwBufferBytes], eax

._createSoundBuffer:
  push 0
  push dword [.localDSBuffer]
  push .bufDesc
  mov eax, [.localDS]
  mov ecx, [eax]
  push eax ; this
  call [ecx+12] ; IDirectSound::CreateSoundBuffer

._lockBuffer:
  push 0 ; dwFlags
  push .dwSize2
  push .lpPtr2
  push .dwSize1
  push .lpPtr1
  push dword [.chunkSize]
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
  mov ecx, [.chunkSize]
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

  .localDS dd 0
  .localDSBuffer dd 0
  .localDataBuffer dd 0
  .dwSize2 dd 0
  .lpPtr2  dd 0
  .dwSize1 dd 0
  .lpPtr1  dd 0
  .chunkSize dd 0

  .bufDesc: istruc DSBUFFERDESC
    at DSBUFFERDESC.dwSize,          dd 20
    at DSBUFFERDESC.dwFlags,         dd 0x8000
    at DSBUFFERDESC.dwBufferBytes,   dd 0
    at DSBUFFERDESC.dwReserved,      dd 0
    at DSBUFFERDESC.lpwfxFormat,     dd pcm
    at DSBUFFERDESC.guid3DAlgorithm, dd 0
  iend

  pcm  dd 20001h  ; wFormatTag <= WAVE_FORMAT_PCM, nChannels <= 2
    dd 48000
    dd 48000*4
    dd 100004h ; wBitsPerSample <= 16, nBlockAlign <= 4
    dd 0       ; cbSize <= 0 (no extra info)
;
