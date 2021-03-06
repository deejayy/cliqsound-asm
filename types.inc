struc WNDCLASSEX
  .cbSize:        resd 1
  .style:         resd 1
  .lpfnWndProc:   resd 1
  .cbClsExtra:    resd 1
  .cbWndExtra:    resd 1
  .hInstance:     resd 1
  .hIcon:         resd 1
  .hCursor:       resd 1
  .hbrBackground: resd 1
  .lpszMenuName:  resd 1
  .lpszClassName: resd 1
  .hIconSm:       resd 1
endstruc

struc MSG
  .hwnd:          resd 1
  .message:       resd 1
  .wParam:        resw 1
  .lParam:        resw 1
  .time:          resd 1
  .pt:            resd 1
endstruc

struc WAVEFORMATEX
  .wFormatTag      resw 1 ; format type
  .nChannels       resw 1 ; number of channels (i.e. mono, stereo, etc.)
  .nSamplesPerSec  resd 1 ; sample rate
  .nAvgBytesPerSec resd 1 ; for buffer estimation
  .nBlockAlign     resw 1 ; block size of data
  .wBitsPerSample  resw 1 ; number of bits per sample of mono data
  .cbSize          resw 1 ; the count in bytes of the size of
endstruc

struc DSBUFFERDESC
  .dwSize          resd 1
  .dwFlags         resd 1
  .dwBufferBytes   resd 1
  .dwReserved      resd 1
  .lpwfxFormat     resd 1
  .guid3DAlgorithm resd 1
endstruc

struc WAVEDATACHUNK
  .chunkName       resd 1
  .chunkSize       resd 1
endstruc

struc SYSTEMTIME
  .wYear           resw 1
  .wMonth          resw 1
  .wDayOfWeek      resw 1
  .wDay            resw 1
  .wHour           resw 1
  .wMinute         resw 1
  .wSecond         resw 1
  .wMilliseconds   resw 1
endstruc
