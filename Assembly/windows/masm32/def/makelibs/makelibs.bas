' いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    #include "\basic\include\win32api.inc"

' いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

FUNCTION PBmain as LONG

    Open "getnames.bat" for Output as #1
      Print #1, "@echo off"
      Print #1, "dir /b ..\*.def > deflist.txt"
    Close #1

    shell "getnames.bat"

    Open "deflist.txt" for Input as #1
    Open "bldlibs.bat" for Output as #2
      Print #2, "@echo off"
      Do
        Line Input #1, defname$
        libname$ = remove$(defname$,".def")+".lib"

        Print #2, "polib /verbose /machine:x64 /def:..\"+defname$+" /out:lib\"+libname$

      Loop while not eof(1)

      Print #2, "move lib\*.lib ..\..\lib64"

    Close #2
    Close #1

    shell "bldlibs.bat"

    kill "getnames.bat"
    kill "deflist.txt"
    kill "bldlibs.bat"

End FUNCTION

' いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

' polib /machine:x64 /def:..\kernel32.def /out:kernel32.lib