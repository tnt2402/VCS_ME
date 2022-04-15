.386
.model flat, stdcall 

option casemap :none 
include C:\masm32\include\windows.inc 
include C:\masm32\include\kernel32.inc 
include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 
include C:\masm32\include\masm32rt.inc

.data
    consoleOutHandle dd ? 
    bytesWritten dd ? 
    message      db  'Hello, World!', 0
    message_len equ 20
.code
    start:
        INVOKE GetStdHandle, STD_OUTPUT_HANDLE
        mov consoleOutHandle, eax
        mov edx, offset message
        pushad
        mov eax, message_len
        invoke WriteConsoleA, consoleOutHandle, edx, eax, offset bytesWritten, 0
        popad
        inkey
        invoke ExitProcess, NULL      
    end start