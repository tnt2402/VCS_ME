;ml /c /Zd /coff .\big_num_sum_windows.asm
;link /subsystem:console .\big_num_sum_windows.obj

.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32@lib 
includelib C:\masm32\lib\masm32@lib 

max_size  EQU 22                            ; max_size of input/output string

.data?
    number1 db max_size dup(?)
    number2 db max_size dup(?)
    number1_prefix db max_size dup(?)
    number2_prefix db max_size dup(?)
.data
    msg1 db "Enter first number: ", 0h
    msg2 db "Enter second number: ", 0h
    msg3 db "Sum: ", 0h
    tmp_string db "                    ", 0h
    newLn db 0Ah, 0h
    carry db 2
    number1_len dw 1
    number2_len dw 1
.code 
    ;Input: edi - string pointer
    ;Output: eax - strlen
    strlen proc
        xor eax,eax		                    ; Set the value that scasb will search for@ In this case it is zero (the null terminator byte)
        mov ecx,-1		                    ; Store -1 in ecx so that scasb runs forever (or until it finds a null terminator)@ scasb DECREMENTS ecx each iteration
        cld			                        ; Clear the direction flag so scasb iterates forward through the input string
        repne scasb		                    ; Execute the scasb instruction@ This leaves edi pointing at the base of the null terminator@
        not ecx		                        ; Invert the value of ecx so that we get the two's complement value of the count@ E@g, a count of -25 results in 24@
        mov eax,ecx		                    ; Move the length of the string into eax
        sub eax, 2
        ret
    strlen endp
    ;;  Input:   edi - pointer to output string
    ;;           esi - pointer to input number
    ;;           ch - number of characters in the input number
    ;;  Output: in output string
    prefix proc
        mov eax, edi                        ; eax = output[]
        mov dh, 1                           ; dh (counter) = 1
        mov dl, max_size                    ; dl = max_size - length of input string
        sub dl, ch
        @li:
            cmp dh, dl                      ; for dh in range(0, dl)
            je @continue
            mov byte ptr [eax], '0'             ; output[dh] = '0'
            inc eax
            inc dh                          ; dh++
            jmp @li                         ; do loop
        @continue:
            mov ebx, esi                    ; ebx = input[]
        @loop:
            mov ch, byte ptr [ebx]              ; for i in range(length of input)
            mov byte ptr [eax], ch              ; output[dh] = input[i]
            inc ebx                         ; i++
            inc eax                         ; dh++
            inc dh
            cmp dh, max_size                
            jle @loop
            jmp @done
        @done:
            ret                             ; result: E.g, input "123456789" -> output "00000000000123456789"
    prefix endp
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
start:
    push offset msg1                            ; print msg1 'Enter first number'
    call StdOut

    push max_size                               ; read input from StdIn and store it in number1 
    push offset number1
    call StdIn

    push offset msg2                            ; print msg2 "Enter second number: "
    call StdOut

    push max_size                               ; read input from StdIn and store it in number1 
    push offset number2
    call StdIn

    mov edi, offset number1                     ; store length of number1 in number1_len variable
    call strlen
    mov dword ptr [number1_len], eax

    lea edi, [number1_prefix]                   ; prefix number1 with '0' and store in number1_prefix variable
    lea esi, [number1]
    mov ch, byte ptr [number1_len]
    call prefix

    mov edi, offset number2                     ; store length of number2 in number2_len variable
    call strlen
    mov dword ptr [number2_len], eax

    lea edi, [number2_prefix]                   ; prefix number2 with '0' and store in number2_prefix variable
    lea esi, [number2]
    mov ch, byte ptr [number2_len]
    call prefix

    mov dl, 0                                   ; set carry = 0
    mov [carry], dl

    lea edi, [number1_prefix]                   ; call big_int_sum to calculate sum of two prefixed-string numberss
    lea esi, [number2_prefix]
    mov ecx, max_size
    call big_int_sum

    push offset msg3                            ; print msg3 'Sum: '
    call StdOut

    lea edi, [number1_prefix]                   ; print sum
    call print_beautify_string

    push offset newLn                           ; print newline
    call StdOut

    inkey                                       ; stop program and ask user to exit

    push 0h                                     ; exit
    call ExitProcess

end start