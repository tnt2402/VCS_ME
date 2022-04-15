;ml /c /Zd /coff .\echo_windows.asm
;link /subsystem:console .\echo_windows.obj

.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 
max_size equ 33
.data?
    input_text db max_size dup(?)
.data 
    msg1 db "Input: ", 0 
    msg2 db "Text: ", 0
    newline db 0Ah, 0
.code 
start: 
    invoke GetStdHandle, STD_OUTPUT_HANDLE

    push offset msg1                    ; print msg1 "Input: "
    call StdOut

    push max_size                       ; size of input_text
    push offset input_text              ; address of input_text
    call StdIn                          ; read max_size bytes from StdIn and store in input_text variable

    push offset msg2                    ; print msg2 "Text: "
    call StdOut

    push offset input_text              ; print input_text
    call StdOut

    push offset newline                 ; print newline
    call StdOut

    inkey                               ; stop program and ask user to exit the program
    push 0h                             ; exit
    call ExitProcess
end start
