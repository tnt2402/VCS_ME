section .data
    msg1 db "Enter first number: "
    msg1_len equ $-msg1
    msg2 db "Enter second number: "
    msg2_len equ $-msg2
    msg3 db "Sum: "
    msg3_len equ $-msg3
    space db " "
    space_len equ $-space
    newLn db 0Ah, 0h
    max_size equ 25
section .bss
    number1 resb max_size
    number2 resb max_size
    number1_len resb 2
    number2_len resb 2
    number1_prefix resb max_size
    number2_prefix resb max_size
    result resb max_size
    result_len equ max_size
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
        mov dl, 0
        mov [carry], dl
        dec ecx
        jmp .loop
    .done:
        ret                                 ; result: E.g, number1 = "000000123" + number2 = "000000342" -> "000000465"
    global main
main:
    mov ecx, msg1                           ; print msg1 "Enter first number: " 
    mov edx, msg1_len
    call print

    mov ecx, number1                        ; read input from StdIn and store it in number1 variable
    mov edx, max_size
    call read
    sub eax, 2                          
    mov [number1_len], eax                  ; store length of number1 in number1_len variable

    mov ecx, msg2                           ; print msg2 "Enter second number: "
    mov edx, msg2_len
    call print

    mov ecx, number2                        ; read input from StdIn and store it in number1 variable
    mov edx, max_size
    call read
    sub eax, 2                              
    mov [number2_len], eax                  ; store length of number2 in number2_len variable

    lea edi, [number1_prefix]               ; prefix number1 with '0' and store in number1_prefix variable
    lea esi, [number1]
    mov ch, [number1_len]
    call prefix

    lea edi, [number2_prefix]               ; prefix number2 with '0' and store in number2_prefix variable
    lea esi, [number2]
    mov ch, [number2_len]
    call prefix

    mov dl, 0                               ; set carry = 0
    mov [carry], dl

    lea edi, [number1_prefix]               ; call big_int_sum to calculate sum of two prefixed-string numberss
    lea esi, [number2_prefix]
    mov ecx, max_size
    call big_int_sum

    mov ecx, msg3                           ; print msg3 "Sum: "
    mov edx, msg3_len
    call print

    mov ecx, number1_prefix                 ; print sum 
    mov edx, max_size
    call print
    
    call newline                            ; print newline

    call exit                               ; exit

