@echo off
del clickety.exe
nasm clickety.asm -f win32
d:\masm32\bin\polink.exe /ALIGN:128 /SUBSYSTEM:WINDOWS /ENTRY:Main /RELEASE /LIBPATH:"d:\masm32\lib" /STUB:stub.bin clickety.obj kernel32.lib user32.lib dsound.lib key.lib
