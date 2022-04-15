; nasm -felf32 array_even_odd_sum.asm 
; gcc -m32 --no-pie ./array_even_odd_sum.o -o array_even_odd_sum
section .data
    msg_error db "Error!", 0Ah, 0h
    msg_error_len equ $-msg_error
    msg_number1 db "Enter number 1: ", 0h
    msg_number1_len equ $-msg_number1
    msg_number2 db "Enter number 2: ", 0h
    msg_number2_len equ $-msg_number2
    msg_result db "Result: ", 0h
    msg_result_len equ $-msg_result
    msg_negative db "Negative", 0h
    msg_negative_len equ $-msg_negative
    msg_positive db "Positive", 0h
    msg_positive_len equ $-msg_positive
    space db " "
    space_len equ $-space
    newLn db 0Ah, 0h
    max_size equ 100
    arr: times max_size db 0

section .bss
    selection resb 2
    selection_int resb 4
    number1 resb max_size
    number1_int resb 4
    number2 resb max_size
    number2_int resb 4
    result resb max_size
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
    backspace:
        mov ecx, space
        mov edx, space_len
        call print
        ret
    ;;  Input:   edi - input string
    ;;  Output:  eax - result in integer
    atoi:
        xor eax, eax            ; set eax = 0
    .loop:
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string
        cmp ecx, byte '-'
        je .negative
        jmp .positive
    .negative:
        inc edi
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string
        sub ecx, '0'            ; convert num -> int 
        jb .done_negative                ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        test edi, edi
        jnz .negative
    .positive:
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string

        sub ecx, '0'            ; convert num -> int 
        jb .done_positive                ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        inc edi                 ; next character of string
        test edi, edi
        jnz .positive
    .done_negative: 
        mov ebx, 0h
        sub ebx, eax
        mov eax, ebx
        ret
    .done_positive:
        ret
    ;;  Input:  eax - integer
    ;;          esi - pointer to result buffer
    ;;  Output: in buffer
    itoa:
        add esi, max_size       ; point to the last of result buffer
        mov byte [esi], 0h      ; set the last byte of result buffser to null
        mov ebx, 10             ; ebx = 10
        cmp eax, 0h
        jge .loop_positive
        neg eax
    .loop_negative:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz .loop_negative             ; if not -> loop
        mov dl, byte '-'
        dec esi
        mov [esi], dl ; mov remainder to the current byte
        jmp .done
    .loop_positive:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz .loop_positive               ; if not -> loop
        jmp .done
    .done:
        mov eax, esi            ; else return result to eax
        ret 

    error: 
        mov ecx, msg_error
        mov edx, msg_error_len
        call print
        ret
    enter_number:    
        mov ecx, msg_number1
        mov edx, msg_number1_len
        call print

        mov ecx, number1
        mov edx, max_size
        call read

        lea edi, [number1]
        call atoi
        mov [number1_int], eax

        mov ecx, msg_number2
        mov edx, msg_number2_len
        call print

        mov ecx, number2
        mov edx, max_size
        call read

        lea edi, [number2]
        call atoi
        mov [number2_int], eax
        ret

    global main
main:
    mov ecx, msg_number1
    mov edx, msg_number1_len
    call print

    mov ecx, number1
    mov edx, max_size
    call read

    lea edi, [number1]
    call atoi
    mov [number1_int], eax

    add eax, 10
    
    lea esi, [number2]
    call itoa 
    call newline

    mov ecx, number2
    mov edx, max_size
    call print
    call exit                               ; exit

