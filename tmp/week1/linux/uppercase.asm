;nasm -felf32 uppercase.asm
;gcc -m32 --no-pie uppercase.o -o uppercase
section .data
    msg db "Input: ", 0Ah
    msg_len equ $-msg
    msg2 db "Text (Uppercase): ", 0Ah
    msg2_len equ $-msg2
    max_size equ 33
section .bss
    input resb max_size
section .text
    print:
        mov eax,4            ; 'write' system call = 4
	    mov ebx,1            ; file descriptor 1 = STDOUT
        int 80h
        ret
    exit:
        mov eax,1            ; 'exit' system call
	    mov ebx,0            ; exit with error code 0
        int 80h
        ret
    read:
        mov eax, 3           ; 'read' system call
        mov ebx, 0           ; file descriptor 0 = STDIN
        int 80h              ; call the kernel 
        ret
    global main
main:
    mov ecx, msg             ; print msg "Input: "
    mov edx, msg_len         
    call print

    mov ecx, input           ; read user input from STDIN and store to input variable
    mov edx, max_size
    call read

    mov ecx, msg2            ; print msg2 "Text (Uppercase): "
    mov edx, msg2_len
    call print

    mov ecx, max_size ;place length of input text into ecx
    mov ebp, input  ;place address of input text into ebp
    dec ebp

    upper:
        cmp byte [ebp+ecx], 0x41 ;compare char vs 'A'
        jb next_char    ;if < 'A' -> next_char
        cmp byte [ebp+ecx], 0x5A ; compare char vs 'Z'
        ja lower    ;
        jmp next_char;
    lower:
        cmp byte [ebp+ecx], 0x61    ;compare char vs 'a'
        jb next_char;
        cmp byte [ebp+ecx], 0x7a    ;compare char vs 'z'
        ja next_char;
        sub byte [ebp+ecx], 0x20    ;convert to lowercase
    next_char:
        dec ecx
        jnz upper

    mov ecx, input                  ;print result
    mov edx, max_size
    call print

    call exit
