  batchfile \
    db "@echo off",13,10
    db 13,10
    db "set appname=xxxxxxxxxxxxxxxxxxxxxxxx",13,10
    db 13,10
    db "del %appname%.obj",13,10
    db "del %appname%.exe",13,10
    db 13,10
    db "\masm32\bin64\porc64.exe rsrc.rc",13,10
    db 13,10
    db "\masm32\bin64\ml64.exe /c /nologo %appname%.asm",13,10
    db 13,10
    db "\masm32\bin64\Polink.exe /SUBSYSTEM:WINDOWS /ENTRY:entry_point /nologo /LARGEADDRESSAWARE %appname%.obj rsrc.res",13,10
    db 13,10
    db "dir %appname%.*",13,10
    db 13,10
    db "pause",13,10,0