; nasm -felf32 ./find_substring_linux.asm 
; gcc -m32 --no-pie ./find_substring_linux.o -o find_substring_linux
section .data
    msg1 db "Enter N (number of elements): "
    msg1_len equ $-msg1
    msg2 db "Array's elements: ", 0Ah
    msg2_len equ $-msg2
    space db " "
    space_len equ $-space
    newLn db 0Ah, 0h
    max_size equ 100
    arr: times max_size db 0

section .bss
    n resb max_size
    n_int resb 5
    tmp resb max_size
    tmp_int resb 6
    max_int resb 6
    min_int resb 6
    tmp_string resb max_size
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
    global main
main:
    mov ecx, msg1                           ; print msg1 
    mov edx, msg1_len
    call print

    mov ecx, n                              ; read input from StdIn and store it in 'string' variable
    mov edx, max_size
    call read

    lea edi, [n]
    call atoi
    mov [n_int], eax

    mov eax, 2147483647
    mov [min_int], eax

    mov eax, 0
    mov [max_int], eax

    mov esi, 0h
    Li:
        cmp esi, dword [n_int]
        je .done
        mov ecx, msg2
        mov edx, msg2_len
        call print
        
        mov ecx, tmp
        mov edx, 5
        call read

        lea edi, [tmp]
        call atoi
        cmp eax, dword [max_int]
        jge .set_max
    .continue:
        cmp eax, dword [min_int]
        jl .set_min
        inc esi
        jmp Li
    .set_max:
        mov [max_int], eax
        jmp .continue
    .set_min:
        mov [min_int], eax
        inc esi
        jmp Li
    .done: 

    mov eax, [max_int]
    lea esi, [tmp_string]
    call itoa

    mov ecx, eax
    mov edx, max_size
    call print

    call newline

    mov eax, [min_int]
    lea esi, [tmp_string]
    call itoa
    
    mov ecx, eax
    mov edx, max_size
    call print

    
    
    call exit                               ; exit

