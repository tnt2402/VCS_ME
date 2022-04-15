section .data
    msg1 db "Enter number N: "
    msg1_len equ $-msg1
    msg2 db "Fibonacci: ", 0Ah
    msg2_len equ $-msg2
    space db " "
    space_len equ $-space
    newLn db 0Ah, 0h
    max_size equ 20
    number1_prefix db "00000000000000000001"
    number2_prefix db "00000000000000000000"
    tmp_prefix db "00000000000000000000"
section .bss
    n resb 5
    n_int resb 2
    carry resb 2
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
        xor eax, eax
    .loop:
        movzx ecx, byte [edi]
        sub ecx, '0'
        jb .done

        lea eax, [eax*4+eax]
        lea eax, [eax*2+ecx]
        inc edi
        jmp .loop
    .done:
        ret
    ;;  Input:  eax - integer
    ;;          esi - pointer to result buffer
    ;;  Output: in buffer
    itoa:
        add esi, 10
        mov byte [esi], 0h
        mov ebx, 10
    .loop:
        xor edx, edx
        div ebx
        add ecx, '0'
        dec esi
        mov [esi], ecx
        test eax, eax
        jnz .loop
        mov eax, esi
        ret
    ;Input: edi - string pointer
    ;Output: eax - strlen
    strlen:
        xor eax,eax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
        mov ecx,-1		; Store -1 in ecx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS ecx each iteration
        cld			; Clear the direction flag so scasb iterates forward through the input string
        repne scasb		; Execute the scasb instruction. This leaves edi pointing at the base of the null terminator.
        not ecx		; Invert the value of ecx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
        mov eax,ecx		; Move the length of the string into eax
        sub eax, 3
        ret
    ;;  Input:   edi - pointer to output string
    ;;           esi - pointer to input number
    ;;           ch - number of characters in the input number
    ;;  Output: in output string
    prefix:
        mov eax, edi
        mov dh, 1
        mov dl, max_size
        sub dl, ch
        .li:
            cmp dh, dl
            je .continue
            mov byte [eax], '0'
            inc eax
            inc dh
            jmp .li
        .continue:
            mov ebx, esi
        .loop:
            mov ch, byte [ebx]
            mov byte [eax], ch
            inc ebx
            inc eax
            inc dh
            cmp dh, max_size
            jle .loop
            jmp .done
        .done:
            ret
    ;;Sum of 2 big int 
    ;;Input:    edi - pointer to the number1
    ;;          esi - pointer to the number2
    ;;          ecx - maximum size of the number
    ;;Output:   in the number 1
    big_int_sum:
        mov eax, edi
        mov ebx, esi
    .loop:
        cmp ecx, 0
        je .done
        mov dh, byte [ebx + ecx]
        sub dh, '0'
        add byte [eax + ecx], dh
        mov dl, [carry]
        add byte [eax + ecx], dl
        cmp byte [eax + ecx], 39h
        jle .0_carry
        sub byte [eax + ecx], 10
        mov dl, 1
        mov [carry], dl
        dec ecx
        jmp .loop
    .0_carry:
        mov dl, 0
        mov [carry], dl
        dec ecx
        jmp .loop
    .done:
        ret
    ;;Strcpy() function implemention 
    ;;Input:   edi - pointer to the target string
    ;;         esi - pointer to the source string
    ;;Output:  in the target string 
    strcpy:
        mov eax, edi
        mov ebx, esi
        mov ecx, max_size
    .loop:
        cmp ecx, 0
        jl .done
        mov dh, byte [ebx + ecx]
        mov byte [eax + ecx], dh
        dec ecx
        jnz .loop
    .done:
        ret
    global main
main:
    mov ecx, msg1
    mov edx, msg1_len
    call print

    mov ecx, n
    mov edx, 5
    call read

    lea edi, [n]
    call atoi
    mov [n_int], eax

    mov dl, 0
    mov [carry], dl

    mov ecx, msg2
    mov edx, msg2_len
    call print

    mov ch, [n_int]
    first_N_fibo:
        mov cl, 1
    .loop:
        cmp cl, ch
        push cx
        jg .done
        mov ecx, number1_prefix
        mov edx, max_size
        call print
        call newline


        lea edi, [tmp_prefix]
        lea esi, [number1_prefix]
        call strcpy


        lea edi, [number1_prefix]
        lea esi, [number2_prefix]
        lea ecx, max_size
        call big_int_sum

        lea edi, [number2_prefix]
        lea esi, [tmp_prefix]
        call strcpy

        pop cx
        inc cl
        jmp .loop
    .done:
        call exit










