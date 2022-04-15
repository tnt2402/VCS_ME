;nasm -felf32 simple_addition.asm
;gcc -m32 --no-pie simple_addition.o -o simple_addition
section .data
    msg1 db "Input number A: "
    msg1_len equ $-msg1
    msg2 db "Input number B: "
    msg2_len equ $-msg2
    msg_error db "Invalid input!", 0Ah
    msg_error_len equ $-msg_error
    msg_result db "Sum of A and B: "
    msg_result_len equ $-msg_result
    max_size equ 11
    newLn db 0Ah, 0h

section .bss
    number1 resb max_size
    number1_int resb 8
    number2 resb max_size
    number2_int resb 8
    sum resb max_size
    sum_int resb 8

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
    newline:
        mov ecx, newLn
        mov edx, 2
        call print
        ret
    ;;  Input:   edi - input string
    ;;  Output:  eax - result in integer
    atoi:
        xor eax, eax        ; set eax = 0
    .loop:
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string
        sub ecx, '0'            ; convert num -> int 
        jb .done                ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        inc edi                 ; next character of string
        jmp .loop
    .done:
        ret
    ;;  Input:  eax - integer
    ;;          esi - pointer to result buffer
    ;;  Output: in buffer
    itoa:
        add esi, max_size       ; point to the last of result buffer
        mov byte [esi], 0h      ; set the last byte of result buffser to null
        mov ebx, 10             ; ebx = 10
    .loop:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz .loop               ; if not -> loop
        mov eax, esi            ; else return result to eax
        ret                 
    global main
main:
    mov ecx, msg1               ; print msg1 "Input number A: "
    mov edx, msg1_len
    call print

    mov ecx, number1            ; read user input from STDIN and store to number1
    mov edx, max_size
    call read

    mov ecx, msg2               ; print msg2 "Input number B: "
    mov edx, msg2_len
    call print

    mov ecx, number2            ; read user input from STDIN and store to number2
    mov edx, max_size
    call read

    lea edi, [number1]          ; convert string (number1) to int (number1_int) 
    call atoi
    mov [number1_int], eax

    lea edi, [number2]          ; convert string (number2) to int (number2_int)
    call atoi
    mov [number2_int], eax

    mov ebx, [number1_int]      ; ebx = number1_int
    add eax, ebx                ; number2_int += ebx
    lea esi, [sum]              ; esi point to "sum" string
    call itoa                   ; convert number2_int to string and store it in "sum" string

    mov ecx, msg_result         ; print msg_result "Sum of A and B: "
    mov edx, msg_result_len
    call print

    mov ecx, sum                ; print "sum" string
    mov edx, max_size
    call print

    call newline

    call exit                   ; Exit

