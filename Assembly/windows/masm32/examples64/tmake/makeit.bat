@echo off

set appname=tmake

if exist %1.obj del %appname%.obj
if exist %1.exe del %appname%.exe

\masm32\bin64\rc.exe rsrc.rc

\masm32\bin64\ml64.exe /c /nologo %appname%.asm

\masm32\bin64\Polink.exe /SUBSYSTEM:WINDOWS /ENTRY:entry_point /LARGEADDRESSAWARE %appname%.obj rsrc.res

dir %appname%.*

pause