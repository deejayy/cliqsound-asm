nasm -f win32 waveout.asm
d:\masm32\bin\link.exe /ALIGN:128 /SUBSYSTEM:WINDOWS /ENTRY:DllMain /DLL /RELEASE /LIBPATH:"d:\masm32\lib" /STUB:stub.bin waveout.obj kernel32.lib user32.lib dsound.lib /OUT:waveout.dll
