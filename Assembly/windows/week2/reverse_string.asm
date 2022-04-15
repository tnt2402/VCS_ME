; ml /c /coff /Zd .\reverse_string.asm  
; link /subsystem:console .\reverse_string.obj
.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc 
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

max_size equ 270

.data? 
    input_text db max_size dup(?)
.data
    msg1 db "Input: ", 0Ah, 0
    msg2 db "Text in reversed order: ", 0Ah, 0
    newline db 0Ah, 0
.code
    reverse proc
        add edi, eax                ; edi point to last character of the input string - '\n'
        dec edi                     ; move edi to the left
        inc eax
        shr eax, 1                  ; eax (length of the input string) /= 2

        @loop:
            mov bl, [esi]           ; bl = input[i]
            mov bh, [edi]           ; bh = input[length - i]
            mov [esi], bh           ; swap(bl, bh)
            mov [edi], bl
            inc esi                 ; i++
            dec edi
            dec eax                 ; eax--
            jnz @loop               ; while (eax != 0)
        ret
    reverse endp
start:
    push offset msg1                ; print msg "Input: "
    call StdOut

    push max_size                   ; read input from StdIn and store it in input variable
    push offset input_text
    call StdIn

    mov ecx, eax                    
    mov edi, offset input_text      ; edi point to input string
    mov esi, offset input_text      ; esi point to input string
    call reverse

    push offset msg2                ; print msg2 
    call StdOut 

    push offset input_text          ; print input string after reversed
    call StdOut

    push offset newline             ; print newline
    call StdOut

    inkey                           ; stop program and ask user to exit

    push 0h                         ; exit
    call ExitProcess

end start