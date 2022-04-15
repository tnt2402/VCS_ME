@echo off
if exist test.obj del test.obj
if exist test.dll del test.dll
\masm32\bin64\ml64 /c test.asm
\masm32\bin64\Link /SUBSYSTEM:WINDOWS /entry:LibMain /DLL /DEF:test.def test.obj 
del test.obj
del test.exp
dir test.*
copy test.dll ..
pause
