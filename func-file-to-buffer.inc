; [ebp + 12] buffer address store ptr
; [ebp + 8] fileName PTR
_LoadFileToBuffer@8:
  push ebp
  mov ebp, esp

._openFile:
  push 0
  push 80h ; FILE_ATTRIBUTE_NORMAL
  push 3 ; OPEN_EXISTING
  push 0
  push 1 ; FILE_SHARE_READ
  push 80000000h ; GENERIC_READ
  push dword [ebp + 8] ; filename
  call [__imp__CreateFileA@28]

  mov dword [.fileHandle], eax

._readRiffHeader:
  push 0
  push dword [.bytesRead]
  push 14h ; "RIFF    WAVEfmt ...."
  push .riffHeader
  push dword [.fileHandle]
  call [__imp__ReadFile@20]

._readWaveHeader:
  push 0
  push dword [.bytesRead]
  push 10h ; "sizeof WAVEFORMATEX"
  push WaveHeader
  push dword [.fileHandle]
  call [__imp__ReadFile@20]

._readChunkInfo:
  push 0
  push dword [.bytesRead]
  push 8h ; "data...."
  push .Chunk
  push dword [.fileHandle]
  call [__imp__ReadFile@20]

._allocateBuffer:
  push dword [.Chunk + WAVEDATACHUNK.chunkSize]
  push 0
  call [__imp__GlobalAlloc@8]
  mov ebx, [ebp + 12]
  mov [ebx], eax

._readChunkData:
  push 0
  push dword [.bytesRead]
  push dword [.Chunk + WAVEDATACHUNK.chunkSize]
  push dword [ebx]
  push dword [.fileHandle]
  call [__imp__ReadFile@20]

._closeFile:
  push dword [.fileHandle]
  call [__imp__CloseHandle@4]

  mov eax, dword [.Chunk + WAVEDATACHUNK.chunkSize]

._LoadFileToBuffer_return:
  mov esp, ebp
  pop ebp
  ret 8

  .fileHandle dd 0
  .bytesRead dd 0
  .riffHeader resd 5

  .Chunk: istruc WAVEDATACHUNK
    at WAVEDATACHUNK.chunkName, dd 0
    at WAVEDATACHUNK.chunkSize, dd 0
  iend
;
