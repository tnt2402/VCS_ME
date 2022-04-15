; nasm -felf32 reverse_string.asm -o reverse_string.oerse_string
; gcc -m32 --no-pie ./reverse_string.o -o ./reverse_string
section .data
    max_size equ 256
    msg db "Input: ", 0Ah
    msg_len equ $-msg
    msg2 db "Reverse: "
    msg2_len equ $-msg2
    newLn db 0Ah, 0h

section .bss
    input resb max_size
section .text
    print:
        mov eax, 4
        mov ebx, 1
        int 80h
        ret
    read:
        mov eax, 3
        mov ebx, 0
        int 80h
        ret
    exit:
        mov eax, 1
        mov ebx, 0
        int 80h
        ret
    newline:
        mov ecx, newLn
        mov edx, 2
        call print
        ret
    reverse:
    add edi, eax                ; edi point to last character of the input string - '\n'
    dec edi                     ; move edi to the left
    shr eax, 1                  ; eax (length of the input string) /= 2

    .loop:
        mov bl, [esi]           ; bl = input[i]
        mov bh, [edi]           ; bh = input[length - i]
        mov [esi], bh           ; swap(bl, bh)
        mov [edi], bl
        inc esi                 ; i++
        dec edi
        dec eax                 ; eax--
        jnz .loop               ; while (eax != 0)
        ret
    global main
main:
    mov ecx, msg                ; print msg "Input: "
    mov edx, msg_len
    call print

    mov ecx, input              ; read input from StdIn and store it in input variable
    mov edx, max_size
    call read

    mov ecx, eax
    mov edi, input              ; edi point to input string
    mov esi, input              ; esi point to input string
    call reverse

    mov ecx, msg2               ; print msg2 "Reverse: "
    mov edx, msg2_len
    call print

    mov edx, ecx                ; print input string after reversed
    mov ecx, input
    call print

    call newline

    call exit                   ; exit
