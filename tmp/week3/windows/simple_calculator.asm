;ml /c /coff /Zd  .\simple_calculator.asm 
;link /subsystem:console .\simple_calculator.asm 

.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

max_size  EQU 100                        ; max_size of input/output string

.data?
    selection db max_size dup(?)
    number1 db max_size dup(?)
    number2 db max_size dup(?)
    result db max_size dup(?)
    remainder db max_size dup(?)
 
.data
    msg_list_menu db "Menu: ", 0Ah, "1. Cong", 0Ah, "2. Tru", 0Ah, "3. Nhan", 0Ah, "4. Chia", 0Ah, "5. Thoat", 0Ah, "Lua chon: ", 0h
    msg_error db "Error!", 0Ah, 0h
    msg_number1 db "Enter number 1: ", 0h
    msg_number2 db "Enter number 2: ", 0h
    msg_result db "Ket qua: ", 0h
    msg_remainder db "So du: ", 0h
    selection_int dd 2
    number1_int dd 2
    number2_int dd 2
    result_int dd 2
    remainder_int dd 2
    newline db 0Ah, 0h

.code
    ;;  Input:  eax - integer
    ;;          esi - pointer to result buffer
    ;;  Output: in buffer
    itoa proc 
        add esi, max_size       ; point to the last of result buffer
        mov byte ptr [esi], 0h      ; set the last byte of result buffser to null
        mov ebx, 10             ; ebx = 10
        cmp eax, 0h
        jge @loop_positive
        neg eax
    @loop_negative:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov byte ptr [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz @loop_negative      ; if not -> loop
        mov dl, 2Dh        ; 
        dec esi
        mov byte ptr [esi], dl           ; mov '-' to the current byte
        jmp @done
    @loop_positive:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov byte ptr [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz @loop_positive      ; if not -> loop
        jmp @done
    @done:
        mov eax, esi            ; else return result to eax
        ret     
    itoa endp
 
    ;;  Input:   edi - input string
    ;;  Output:  eax - result in integer
    atoi proc uses ebx ecx edx esi edi
        xor eax, eax            ; set eax = 0
        movzx ecx, byte ptr [edi]   ; ecx = first byte of edi - input string
        cmp ecx, 2Dh       ; check input number is negative or positive
        je @negative
        jmp @positive
    @negative:
        inc edi                 ; skip '-' character
        movzx ecx, byte ptr [edi]   ; 
        sub ecx, '0'            ; convert num -> int 
        jb @done_negative       ; done

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        test edi, edi
        jnz @negative
    @positive:
        movzx ecx, byte ptr [edi]   ; ecx = first byte of edi - input string

        sub ecx, '0'            ; convert num -> int 
        jb @done_positive       ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        inc edi                 ; next character of string
        test edi, edi
        jnz @positive
    @done_negative: 
        mov ebx, 0h             ; negative_num = 0 - (- negative_number)
        sub ebx, eax
        mov eax, ebx
        ret
    @done_positive:
        ret
    atoi endp

    enter_number proc  
        push offset msg_number1         ; print msg_number1 'Enter number 1: '
        call StdOut

        push max_size
        push offset number1             ; read number1 from StdIn
        call StdIn

        lea edi, [number1]              ; convert number1 -> int number1_int
        call atoi
        mov [number1_int], eax

        push offset msg_number2         ; print msg_number2 'Enter number 2: '
        call StdOut

        push max_size
        push offset number2             ; read number2 from StdIn
        call StdIn

        lea edi, [number2]              ; convert number2 -> int number2_int
        call atoi
        mov [number2_int], eax
        ret
    enter_number endp

    addition proc
        mov eax, [number1_int]      ; eax += ebx
        mov ebx, [number2_int]
        add eax, ebx
        jmp continue
        ret
    addition endp

    subtract proc
        mov ecx, [number1_int]      ; eax -= ebx
        mov ebx, [number2_int]
        sub ecx, ebx
        mov eax, ecx

        jmp continue
        ret
    subtract endp
    
    multiply proc
        mov eax, [number1_int]      ; eax *= ecx
        mov ecx, [number2_int]
        mul ecx
        jmp continue
        ret
    multiply endp

    divide proc
        xor ecx, ecx                ; ecx is counter
        xor edx, edx                ; edx = 0 to save remainder
        mov eax, [number1_int]      ; eax = [number1_int]
        cmp eax, 0h                 ; check eax is negative or positive
        jl @neg_eax
    @l1:
        mov ebx, [number2_int]      ; ebx = [number2_int]
        cmp ebx, 0h                 ; check ebx is negative or positive
        jl @neg_ebx
    @l2:
        xor edx, edx
        div ebx                     ; eax = /= ebx
        mov dword ptr [remainder_int], edx
        and ecx, 1                  ; and ecx vs 1 -> to check even or odd
        jz continue                 ; if ecx is even (ecx = 0 or 2) -> done
        neg eax
        cmp edx, 0h
        je continue 
        sub edx, dword ptr [number2_int]
        neg edx
        mov dword ptr [remainder_int], edx
        jmp continue                ; then done
        ret
    @neg_eax:                       ; if eax is negative -> eax = -eax E,g. eax = -20 -> eax = 20
        neg eax                     ;                                       ecx++
        inc ecx
        jmp @l1
    @neg_ebx:                       ; if ebx is negative -> ebx = -ebx E,g. ebx = -10 -> ebx = 10
        neg ebx                     ;                                       ecx++
        inc ecx
        jmp @l2
    divide endp

    print_remainder proc
        push offset msg_remainder
        call StdOut

        mov eax, dword ptr [remainder_int]
        lea esi, [remainder]
        call itoa

        push eax
        call StdOut

        push offset newline
        call StdOut
        ret
    print_remainder endp

    error proc
        push offset msg_error
        call StdOut

        push offset newline
        call StdOut
        ret
    error endp
    
start:
    push offset msg_list_menu       ; print msg_list_menu
    call StdOut

    push max_size                   ; read selection from StdIn
    push offset selection
    call StdIn

    cmp eax, 1                      
    jne error

    push offset newline             ; print newline
    call StdOut

    lea edi, [selection]            ; convert input string to integer
    call atoi
    mov [selection_int], eax

    call enter_number               ; enter 2 numbers

    push offset msg_result          ; print msg_result 'Ket qua: '
    call StdOut
    
    cmp dword ptr [selection_int], 1h       ; switch (x)
    je addition                             ;       case 1: addition
    cmp dword ptr [selection_int], 2h
    je subtract                             ;       case 2: subtract
    cmp dword ptr [selection_int], 3h
    je multiply                             ;       case 3: multiply
    cmp dword ptr [selection_int], 4h
    je divide                               ;       case 4: divide
    continue:

    lea esi, [result]                       ; convert result to integer
    call itoa

    push eax                                ; print result
    call StdOut

    push offset newline
    call StdOut

    cmp dword ptr [selection_int], 4h       ; print remainder
    je print_remainder                       

    push offset newline
    call StdOut

    inkey                                   ; stop program and ask user to exit

    push 0h                                 ; exit
    call ExitProcess

end start