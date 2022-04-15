;nasm -felf32 ./hello_world.asm 
;gcc -m32 --no-pie ./hello_world.o -o ./hello_world
section .data
    msg db "Hello, World!",0Ah
    msg_len equ $-msg
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
    global main
main:
    mov ecx, msg             ; address of string to output
    mov edx, msg_len         ; number of bytes
    call print

    call exit
