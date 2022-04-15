;ml /c /Zd /coff .\uppercase_windows.asm
;link /subsystem:console .\uppercase_windows.obj

.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

max_size equ 32                         ; max_size of input/output string
.data?
    text db max_size dup(?)
.data
    msg1 db "Input: ", 0Ah, 0
    msg2 db "Text (uppercase): ", 0Ah, 0
    newline db 0Ah, 0

.code
    upper proc 
        cmp byte ptr [ebp+ecx], 41h     ; compare char vs 'A'
        jb @next_char                   ; if < 'A' -> next_char
        cmp byte ptr [ebp+ecx], 5Ah     ; compare char vs 'Z'
        ja @lower                       ; if char is not upper -> check lower
        jmp @next_char;                 ; else next_char
    @lower:
        cmp byte ptr [ebp+ecx], 61h     ; compare char vs 'a'
        jb @next_char;
        cmp byte ptr [ebp+ecx], 7ah     ; compare char vs 'z'
        ja @next_char;                  ; if char not lower -> next-char
        sub byte ptr [ebp+ecx], 20h     ; else convert to lowercase
    @next_char:
        dec ecx                         ; decrease ecx (counter)
        jnz upper                       ; if ecx != 0 -> loop
        ret                             ; else return
    upper endp
start:  
    push offset msg1                    ; print msg1 "Input: "
    call StdOut

    push max_size                       ; read max_size bytes from StdIn and store in 'text' variable
    push offset text 
    call StdIn

    mov ecx, max_size                   ; place length of input text into ecx
    mov ebp, offset text                ; place address of input text into ebp
    dec ebp
    
    call upper                          ; call upper func

    push offset msg2                    ; print msg2 "Text (uppercase): "
    call StdOut

    push offset text                    ; print 'text' to StdOut
    call StdOut

    push offset newline                 ; print newline
    call StdOut

    inkey                               ; stop program and ask user to exit

    push 0h                             ; exit
    call ExitProcess
end start