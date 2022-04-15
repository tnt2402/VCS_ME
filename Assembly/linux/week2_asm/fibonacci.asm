; nasm -felf32 ./fibonacci.asm -o ./fibonacci.o
; gcc -m32 --no-pie ./fibonacci.o -o ./fibonacci
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
    tmp_string db "00000000000000000000"
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
        xor eax, eax            ; set eax = 0
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

    ;;  Input:   edi - pointer to output string
    ;;           esi - pointer to input number
    ;;           ch - number of characters in the input number
    ;;  Output: in output string
    prefix:
        mov eax, edi                        ; eax = output[]
        mov dh, 1                           ; dh (counter) = 1
        mov dl, max_size                    ; dl = max_size - length of input string
        sub dl, ch
        .li:
            cmp dh, dl                      ; for dh in range(0, dl)
            je .continue
            mov byte [eax], '0'             ; output[dh] = '0'
            inc eax
            inc dh                          ; dh++
            jmp .li                         ; do loop
        .continue:
            mov ebx, esi                    ; ebx = input[]
        .loop:
            mov ch, byte [ebx]              ; for i in range(length of input)
            mov byte [eax], ch              ; output[dh] = input[i]
            inc ebx                         ; i++
            inc eax                         ; dh++
            inc dh
            cmp dh, max_size                
            jle .loop
            jmp .done
        .done:
            ret                             ; result: E.g, input "123456789" -> output "00000000000123456789"
    ;;Sum of 2 big int 
    ;;Input:    edi - pointer to the number1
    ;;          esi - pointer to the number2
    ;;          ecx - maximum size of the number
    ;;Output:   in the number 1
    big_int_sum:
        mov eax, edi                        ; eax = number1[]
        mov ebx, esi                        ; ebx = number2[]
    .loop:
        cmp ecx, 0                          ; ecx is counter
        je .done                            ; if ecx == 0 -> done
        mov dh, byte [ebx + ecx]            ; dh = number2[ecx]
        sub dh, '0'                         ; convert dh to int
        add byte [eax + ecx], dh            ; number1[ecx] += dh
        mov dl, [carry]                     ; dl = carry
        add byte [eax + ecx], dl            ; number1[ecx] += carry
        cmp byte [eax + ecx], 39h           ; cmp number1[ecx] vs '9' 
        jle .0_carry                        ; if number1[ecx] <= '9'
        sub byte [eax + ecx], 10            ; carry = number1[ecx] % 10
        mov dl, 1
        mov [carry], dl
        dec ecx                             ; ecx--
        jmp .loop                           ; do loop
    .0_carry:
        mov dl, 0                           ; set carry = 0
        mov [carry], dl
        dec ecx
        jmp .loop
    .done:
        ret                                 ; result: E.g, number1 = "000000123" + number2 = "000000342" -> "000000465"
    ;;Strcpy() function implemention 
    ;;Input:   edi - pointer to the target string
    ;;         esi - pointer to the source string
    ;;Output:  in the target string 
    strcpy:
        mov eax, edi                        ; eax = target[]
        mov ebx, esi                        ; ebx = source[]
        mov ecx, max_size                   ; ecx (counter) = max_size
    .loop:
        cmp ecx, 0                          ; compare ecx vs 0h
        jl .done                            ; if ecx < 0 -> done
        mov dh, byte [ebx + ecx]            ; else dh = source[ecx]
        mov byte [eax + ecx], dh            ; target[ecx] = dh = source[ecx]
        dec ecx                             ; ecx--
        jnz .loop
    .done:
        ret                                 ; return
    global main
main:
    mov ecx, msg1                           ; print msg1 "Enter number N: "
    mov edx, msg1_len
    call print

    mov ecx, n                              ; read input from StdIn and store it in 'n' variable
    mov edx, 5
    call read

    lea edi, [n]                            ; convert 'n' to number and store in 'n_int' variable
    call atoi
    mov [n_int], eax

    mov dl, 0                               ; set carry = 0
    mov [carry], dl

    mov ecx, msg2                           ; print msg2 'Fibonacci: '
    mov edx, msg2_len
    call print

    mov ch, [n_int]                         ; ch = n_int
    first_N_fibo:
        mov cl, 1                           ; cl (counter) = 1
    .loop:
        cmp cl, ch                          ; for c1 in range(1, n_int]
        push cx
        jg .done
        
        mov ecx, number1_prefix             ; print number1_prefix
        mov edx, max_size
        call print

        call newline                        ; print newline 

        lea edi, [tmp_prefix]               ; strcpy tmp_prefix = number1_prefix
        lea esi, [number1_prefix]
        call strcpy

        lea edi, [number1_prefix]           ; call big_int_sum to calculate sum of number1_prefix and number2_prefix
        lea esi, [number2_prefix]
        lea ecx, max_size
        call big_int_sum                    ; Result: number1_prefix += number2_prefix

        lea edi, [number2_prefix]           ; strcpy number2_prefix = tmp_prefix
        lea esi, [tmp_prefix]               
        call strcpy

        pop cx
        inc cl                              ; cl++ (increase counter)
        jmp .loop                           ; do loop
    .done:
        call exit                           ; exit