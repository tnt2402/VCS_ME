@echo off

set appname=dlltest

del %appname%.obj
del %appname%.exe

\masm32\bin64\ml64.exe /c %appname%.asm

\masm32\bin64\polink.exe /SUBSYSTEM:WINDOWS /ENTRY:entry_point /LARGEADDRESSAWARE %appname%.obj dll\test.lib

dir %appname%.exe

pause