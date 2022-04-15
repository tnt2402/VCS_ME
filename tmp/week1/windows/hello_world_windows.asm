;ml /c /Zd /coff .\hello_world_windows.asm
;link /subsystem:console .\hello_world_windows.obj

.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

.data 
     HelloWorld db "Hello, World!", 0Ah, 0 
.code 
start: 
     push offset HelloWorld        ; print HelloWorld "Hello, World!"
     call StdOut

     inkey                         ; stop program and ask user to exit 

     push 0h                       ; exit
     call ExitProcess
end start