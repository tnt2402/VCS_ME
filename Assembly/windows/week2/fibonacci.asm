; ml /c /coff /Zd .\fibonacci.asm
; link /subsystem:console .\fibonacci.obj
.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc 
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

max_size  EQU 20

.data?
    n db max_size dup(?)
.data
    msg1 db "Enter number N: ", 0h
    msg2 db "Fibonacci: ", 0Ah, 0h
    number1_prefix db "00000000000000000001", 0h
    number2_prefix db "00000000000000000000", 0h
    tmp_prefix db "00000000000000000000", 0h
    tmp_string db "                    ", 0h
    newLn db 0Ah, 0h
    carry db 2
    number1_len dw 1
    number2_len dw 1
    n_int dw 1
.code 
    ;;  Input:  eax - integer
    ;;          esi - pointer to result buffer
    ;;  Output: in buffer
    itoa proc uses ebx edx esi
        add esi, max_size      ; point to the last of result buffer
        dec esi
        mov byte ptr [esi], 0h      ; set the last byte of result buffser to null
        mov ebx, 10             ; ebx = 10
    @loop:
        xor edx, edx            ; edx = 0
        div ebx                 ; divide eax by divisor ebx = 10
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz @loop               ; if not -> loop
        mov eax, esi            ; else return result to eax
        ret      
    itoa endp
 
    ;;  Input:   edi - input string
    ;;  Output:  eax - result in integer
    atoi proc uses ebx ecx edx esi edi
        xor eax, eax            ; set eax = 0
    @loop:
        movzx ecx, byte ptr [edi]   ; ecx = first byte of edi - input string
        sub ecx, '0'            ; convert num -> int 
        jb @done                ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        inc edi                 ; next character of string
        jmp @loop
    @done:
        ret
    atoi endp

    ;Input: edi - string pointer
    ;Output: eax - strlen
    strlen proc
        xor eax,eax		; Set the value that scasb will search for@ In this case it is zero (the null terminator byte)
        mov ecx,-1		; Store -1 in ecx so that scasb runs forever (or until it finds a null terminator)@ scasb DECREMENTS ecx each iteration
        cld			; Clear the direction flag so scasb iterates forward through the input string
        repne scasb		; Execute the scasb instruction@ This leaves edi pointing at the base of the null terminator@
        not ecx		; Invert the value of ecx so that we get the two's complement value of the count@ E@g, a count of -25 results in 24@
        mov eax,ecx		; Move the length of the string into eax
        sub eax, 3
        ret
    strlen endp
    ;;  Input:   edi - pointer to output string
    ;;  Output: print to StdOut
    print_beautify_string proc
        mov eax, edi
        mov ebx, offset tmp_string
        @li:
            cmp byte ptr [eax], "0"
            jne @print
            inc eax
            jmp @li
        @print:
            mov dh, byte ptr [eax]
            mov byte ptr [ebx], dh
            inc eax
            inc ebx
            cmp byte ptr [eax], 0h
            je @done
            jmp @print
        @done:
            push offset tmp_string
            call StdOut
            ret
    print_beautify_string endp
    ;;Input:    edi - pointer to the number1
    ;;          esi - pointer to the number2
    ;;          ecx - maximum size of the number
    ;;Output:   in the number 1
    big_int_sum proc
        mov eax, edi                        ; eax = number1[]
        mov ebx, esi                        ; ebx = number2[]
    @loop:
        cmp ecx, 0                          ; ecx is counter
        je @done                            ; if ecx == 0 -> done
        mov dh, byte ptr [ebx + ecx]            ; dh = number2[ecx]
        sub dh, '0'                         ; convert dh to int
        add byte ptr [eax + ecx], dh            ; number1[ecx] += dh
        mov dl, [carry]                     ; dl = carry
        add byte ptr [eax + ecx], dl            ; number1[ecx] += carry
        cmp byte ptr [eax + ecx], 39h           ; cmp number1[ecx] vs '9' 
        jle @0_carry                        ; if number1[ecx] <= '9'
        sub byte ptr [eax + ecx], 10        ; carry = number1[ecx] % 10
        mov dl, 1
        mov [carry], dl
        dec ecx                             ; ecx--
        jmp @loop                           ; do loop
    @0_carry:
        mov dl, 0
        mov [carry], dl
        dec ecx
        jmp @loop
    @done:
        ret                                 ; result: E.g, number1 = "000000123" + number2 = "000000342" -> "000000465"
    big_int_sum endp

    ;;Strcpy() function implemention 
    ;;Input:   edi - pointer to the target string
    ;;         esi - pointer to the source string
    ;;Output:  in the target string 
    strcpy proc
        mov eax, edi                        ; eax = target[]
        mov ebx, esi                        ; ebx = source[]
        mov ecx, max_size                   ; ecx (counter) = max_size
    @loop:
        cmp ecx, 0                          ; compare ecx vs 0h
        jl @done                            ; if ecx < 0 -> done
        mov dh, byte ptr [ebx + ecx]            ; else dh = source[ecx]
        mov byte ptr [eax + ecx], dh            ; target[ecx] = dh = source[ecx]
        dec ecx                             ; ecx--
        jnz @loop
    @done:
        ret
    strcpy endp

    first_N_fibo proc
    @loop:
        cmp cl, ch                          ; for c1 in range(1, n_int]
        jg @done
        push cx

        lea edi, [number1_prefix]           ; print number1_prefix
        call print_beautify_string

        push offset newLn                   ; print newline
        call StdOut

        lea edi, [tmp_prefix]               ; strcpy tmp_prefix = number1_prefix
        lea esi, [number1_prefix]
        call strcpy


        lea edi, [number1_prefix]           ; call big_int_sum to calculate sum of 
        lea esi, [number2_prefix]
        mov ecx, offset max_size            ; Result: number1_prefix += number2_prefix
        dec ecx
        call big_int_sum

        lea edi, [number2_prefix]           ; strcpy number2_prefix = tmp_prefix
        lea esi, [tmp_prefix]
        call strcpy

        pop cx
        inc cl                              ; cl++ (increase counter)
        call @loop
    @done:
        ret
    first_N_fibo endp
start:
    push offset msg1                        ; print msg1 "Enter number N: "
    call StdOut

    push max_size                           ; read input from StdIn and store it in 'n' 
    push offset n
    call StdIn

    mov edi, offset n                       ; convert 'n' to number and store in 'n_int' 
    call atoi
    mov dword ptr [n_int], eax

    mov dl, 0                               ; set carry = 0
    mov [carry], dl

    push offset msg2                        ; print msg2 'Fibonacci: '
    call StdOut

    mov ch, byte ptr [n_int]                ; ch = n_int
    mov cl, 1h                              ; cl (counter) = 1
    call first_N_fibo                       ; call first_N_fibo func

    inkey                                   ; stop program and ask user to exit

    push 0h                                 ; exit
    call ExitProcess

end start