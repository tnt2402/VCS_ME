@echo off

set appname=alnmem

del %appname%.obj
del %appname%.exe

\masm32\bin64\ml64.exe /c %appname%.asm

\masm32\bin64\link.exe /SUBSYSTEM:CONSOLE /MACHINE:X64 /ENTRY:entry_point /nologo /LARGEADDRESSAWARE %appname%.obj

dir %appname%.*

pause