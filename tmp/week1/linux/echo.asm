;nasm -felf32 ./echo.asm 
section .data
    msg db "Input: ", 0Ah
    msg_len equ $-msg
    msg2 db "Text: ", 0Ah
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

    mov ecx, input           ; take input data from STDIN and store to 'input' variable
    mov edx, 32
    call read

    mov ecx, msg2            ; print msg2 "Text: "
    mov edx, msg2_len
    call print

    mov ecx, input           ; print input variable to STDOUT
    mov edx, 32
    call print

    call exit
