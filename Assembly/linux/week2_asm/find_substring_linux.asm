; nasm -felf32 ./find_substring_linux.asm 
; gcc -m32 --no-pie ./find_substring_linux.o -o find_substring_linux
; test
; abcabcdabcdabcabcdabcd
; abcdabc
section .data
    msg1 db "Enter string: "
    msg1_len equ $-msg1
    msg2 db "Enter substring: "
    msg2_len equ $-msg2
    space db " "
    space_len equ $-space
    newLn db 0Ah, 0h
    max_size equ 100
    arr: times max_size db 0

section .bss
    string resb max_size
    substring resb max_size
    string_len resb 2
    substring_len resb 2
    result resb max_size
    result_int resb 5
    tmp resb max_size
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
    ;Input: edi - string pointer
    ;Output: eax - strlen
    strlen:
        xor eax,eax		        ; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
        mov ecx,-1		        ; Store -1 in ecx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS ecx each iteration
        cld			            ; Clear the direction flag so scasb iterates forward through the input string
        repne scasb		        ; Execute the scasb instruction. This leaves edi pointing at the base of the null terminator.
        not ecx		            ; Invert the value of ecx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
        mov eax,ecx		        ; Move the length of the string into eax
        sub eax, 2              ; stringlen without '\n' E.g, String 'abcd\n' has 4 characters.
        ret
    ;;Input:   edi - pointer to string
    ;;         esi - pointer to substring
    ;;Output:  eax - the number of times 'input substring' appears in 'input string'
    times_:
        mov eax, edi                        ; eax = string[0]
        mov ebx, esi                        ; ebx = substring[0]
        mov edi, 0h                         ; edi - the number of times
        mov ecx, 0                          ; ecx - counter 
    .loop:
        cmp byte [ebx], 0Ah                 ; compare ebx vs '\n'
        je .found                           ; if ebx == '\n' -> found substring
        cmp byte [eax + ecx], 0Ah           ; else compare string[ecx] vs '\n'
        je .done                            ; if string[ecx] == '\n' -> done 
        mov dh, byte [ebx]                  ; compare string[counter] vs ebx = substring[?]
        cmp byte [eax + ecx], dh
        jne .skip                           ; if not -> skip to next character of string
        inc ebx                             ; else counter++, ebx = next character of substring
        inc ecx
        jmp .loop                           ; do loop
    .skip:
        mov edx, esi
        cmp ebx, edx
        je .inc_ecx
        mov ebx, esi                        ; set ebx - first character of substring
        jmp .loop                           ; do loop
    .inc_ecx:
        inc ecx
        mov ebx, esi
        jmp .loop                           ; do loop
    .found:
        mov [arr + edi], ecx                ; save position of substring in string: arr[edi] = ecx
        inc edi
        mov ebx, esi                        ; set ebx - first character of substring
        sub ecx, [substring_len]
        add ecx, 2
        jmp .loop                           ; do loop
    .done:
        mov eax, edi                        ; mov result to eax 
        ret                                 ; return

    global main
main:
    mov ecx, msg1                           ; print msg1 'Enter string: '
    mov edx, msg1_len
    call print

    mov ecx, string                         ; read input from StdIn and store it in 'string' variable
    mov edx, max_size
    call read

    mov [string_len], eax

    mov ecx, msg2                           ; print msg2 'Enter substring: '
    mov edx, msg2_len
    call print

    mov ecx, substring                      ; read input from StdIn and store it in 'substring' variable
    mov edx, max_size
    call read

    mov [substring_len], eax
    
    lea edi, [string]                       ; call times_ function 
    lea esi, [substring]                    ; Result: eax 
    call times_
    
    lea esi, [result]                       ; Convert number in eax to string and store in 'result' variable
    call itoa

    mov ecx, result                         ; Print the number of times 'input substring' appears in 'input string'
    mov edx, max_size
    call print

    call newline                            ; Print newline

    mov esi, arr                            ; arr has positions of substring 
    print_index:                            ; print posistions
    .loop:
        cmp edi, 0h                         ; edi (the number of times) cmp vs 0h -> edi is counter
        je .done                            ; if edi = 0 -> done
        movzx eax, byte [esi]               ; else mov first byte of arr to eax -> eax = first posistions of substring = arr[0]
        sub eax, [substring_len]            ; eax = eax - substring_len
        inc eax
        push esi                            ; save esi value
        lea esi, [tmp]                      ; convert eax to string
        call itoa

        mov ecx, tmp                        ; print first posistions
        mov edx, max_size
        call print

        pop esi                             ; restore previous value of esi
        inc esi                             ; increase esi = next posistions of substring = arr[1]
        dec edi                             ; decrease counter edi
        call backspace                      ; print space
        jmp .loop                           ; do loop
    .done:
        call newline                        ; print newline
    
    call exit                               ; exit

