@echo off
cls
@echo.
@echo.
@echo   The following operations create 952 include and library files.
@echo.
@echo   The libraries are constructed from DEF files using Pelle's POLIB.EXE
@echo.
@echo   The include files are created from the libraries using a dedicated utility.
@echo.
@echo   The combined operations take a reasonable amount of time to complete.
@echo.
pause

cd def\makelibs
makelibs
cd lib\incs
lib2inc64 ..\
del test.txt

move *.inc ..\..\..\..\include64
cd ..
move *.lib ..\..\..\lib64

cd ..\..\..\

cd tempdir
copy *.* ..\include64
cd ..

@echo.
@echo.
@echo Thats all folks, press any key ....
@echo.
@echo.
pause