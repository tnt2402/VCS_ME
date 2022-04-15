; nasm -felf32 ./simple_calculator.asm 
; gcc -m32 --no-pie ./simple_calculator.o -o ./simple_calculator
section .data
    msg_list_menu db "Menu: ", 0Ah, "1. Cong", 0Ah, "2. Tru", 0Ah, "3. Nhan", 0Ah, "4. Chia", 0Ah, "5. Thoat", 0Ah, "Lua chon: ", 0h
    msg_list_menu_len equ $-msg_list_menu
    msg_error db "Error!", 0Ah, 0h
    msg_error_len equ $-msg_error
    msg_number1 db "Enter number 1: ", 0h
    msg_number1_len equ $-msg_number1
    msg_number2 db "Enter number 2: ", 0h
    msg_number2_len equ $-msg_number2
    msg_result db "Ket qua: ", 0h
    msg_result_len equ $-msg_result
    msg_remainder db "So du: ", 0h
    msg_remainder_len equ $-msg_remainder
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
    remainder resb max_size
    remainder_int resb 4
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
    error:
        mov ecx, msg_error
        mov edx, msg_error_len
        call print
        ret
    ;;  Input:   edi - input string
    ;;  Output:  eax - result in integer
    atoi:
        xor eax, eax            ; set eax = 0
    .loop:
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string
        cmp ecx, byte '-'       ; check input number is negative or positive
        je .negative
        jmp .positive
    .negative:
        inc edi                 ; skip '-' character
        movzx ecx, byte [edi]   ; 
        sub ecx, '0'            ; convert num -> int 
        jb .done_negative       ; done

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        test edi, edi
        jnz .negative
    .positive:
        movzx ecx, byte [edi]   ; ecx = first byte of edi - input string

        sub ecx, '0'            ; convert num -> int 
        jb .done_positive       ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        inc edi                 ; next character of string
        test edi, edi
        jnz .positive
    .done_negative: 
        mov ebx, 0h             ; negative_num = 0 - (- negative_number)
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
        jnz .loop_negative      ; if not -> loop
        mov dl, byte '-'        ; 
        dec esi
        mov [esi], dl           ; mov '-' to the current byte
        jmp .done
    .loop_positive:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz .loop_positive      ; if not -> loop
        jmp .done
    .done:
        mov eax, esi            ; else return result to eax
        ret 

    enter_number:    
        mov ecx, msg_number1        ; print msg_number1 'Enter number 1: '
        mov edx, msg_number1_len
        call print

        mov ecx, number1            ; read number1 from StdIn
        mov edx, max_size
        call read

        lea edi, [number1]          ; convert number1 -> int number1_int
        call atoi
        mov [number1_int], eax

        mov ecx, msg_number2        ; print msg_number2 'Enter number 2: '
        mov edx, msg_number2_len
        call print

        mov ecx, number2            ; read number2 from StdIn
        mov edx, max_size
        call read

        lea edi, [number2]          ; convert number2 -> int number2_int
        call atoi
        mov [number2_int], eax
        ret

    add:
        mov eax, [number1_int]      ; eax += ebx
        mov ebx, [number2_int]
        add eax, ebx
        jmp continue
        ret
    sub:
        mov ecx, [number1_int]      ; eax -= ebx
        mov ebx, [number2_int]
        sub ecx, ebx
        mov eax, ecx
        jmp continue
        ret
    mul:
        mov eax, [number1_int]      ; eax *= ecx
        mov ecx, [number2_int]
        mul ecx
        jmp continue
        ret
    div:
        xor ecx, ecx                ; ecx is counter
        xor edx, edx                ; edx = 0 to save remainder
        mov eax, [number1_int]      ; eax = [number1_int]
        cmp eax, 0h                 ; check eax is negative or positive
        jl .neg_eax
    .l1:
        mov ebx, [number2_int]      ; ebx = [number2_int]
        cmp ebx, 0h                 ; check ebx is negative or positive
        jl .neg_ebx
    .l2:
        xor edx, edx
        div ebx                     ; eax = /= ebx
        mov [remainder_int], edx
        and ecx, 1                  ; and ecx vs 1 -> to check even or odd
        jz continue                 ; if ecx is even (ecx = 0 or 2) -> done
        neg eax
        cmp edx, 0h
        je continue 
        sub edx, [number2_int]
        neg edx
        mov [remainder_int], edx
        jmp continue                ; then done
        ret
    .neg_eax:                       ; if eax is negative -> eax = -eax E,g. eax = -20 -> eax = 20
        neg eax                     ;                                       ecx++
        inc ecx
        jmp .l1
    .neg_ebx:                       ; if ebx is negative -> ebx = -ebx E,g. ebx = -10 -> ebx = 10
        neg ebx                     ;                                       ecx++
        inc ecx
        jmp .l2

    print_remainder:
        mov ecx, msg_remainder
        mov edx, msg_remainder_len
        call print

        mov eax, [remainder_int]
        lea esi, [remainder]
        call itoa
        mov ecx, remainder
        mov edx, max_size
        call print

        call newline
        ret
    global main
main:
    mov ecx, msg_list_menu          ; print msg_list_menu
    mov edx, msg_list_menu_len
    call print

    mov ecx, selection              ; read selection from StdIn
    mov edx, 5
    call read

    cmp eax, 2                      ; input string's length == 2 ?
    jne error

    lea edi, [selection]            ; convert input string to integer
    call atoi
    mov [selection_int], eax

    call enter_number               ; enter 2 numbers

    cmp dword [selection_int], 1h   ; switch (x)
    je add                          ;       case 1: add
    cmp dword [selection_int], 2h
    je sub                          ;       case 2: sub
    cmp dword [selection_int], 3h
    je mul                          ;       case 3: mul
    cmp dword [selection_int], 4h
    je div                          ;       case 4: div
    continue:
    lea esi, [result]               ; convert result to integer
    call itoa

    mov ecx, msg_result             ; print msg_result 'Result: '
    mov edx, msg_result_len
    call print

    mov ecx, result                 ; print result 
    mov edx, max_size
    call print

    call newline

    cmp dword [selection_int], 4h
    je print_remainder

    call newline                    ; print newline
    call exit                       ; exit

