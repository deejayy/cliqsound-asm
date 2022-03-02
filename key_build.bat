nasm -f win32 key.asm
d:\masm32\bin\link.exe /ALIGN:128 /SUBSYSTEM:WINDOWS /ENTRY:DllMain /DLL /RELEASE /LIBPATH:"d:\masm32\lib" /STUB:stub.bin key.obj kernel32.lib user32.lib dsound.lib /OUT:key.dll
