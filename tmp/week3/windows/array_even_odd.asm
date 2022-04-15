;ml /c /coff /Zd .\array_even_odd.asm
;link /subsystem:console .\array_even_odd.asm

.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

max_size  EQU 12                        ; max_size of input/output string

.data?
    n db max_size dup(?)

    tmp db max_size dup(?)
    tmp_string db max_size dup(?)
 
.data
    msg1 db "Enter number N: ", 0h
    msg2 db "Enter elements: ", 0Ah, 0h
    msg3 db "Sum of even elements: ", 0h
    msg4 db "Sum of odd elements: ", 0h
    sum db max_size dup(?)
    n_int dd 2
    number1 dd 2
    number2 dd 2
    sum_even dd 2
    sum_odd dd 2
    newline db 0Ah, 0h

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

start:
    ; Get the numbers in ascii
    push offset msg1            ; print msg1 'Enter number N: '
    call StdOut

    push max_size               ; read max_size bytes from StdIn and store in 'n' variable
    push offset n
    call StdIn

    mov edi, offset n                   ; convert 'n' string to 'n_int' integer
    call atoi
    mov dword ptr [n_int], eax

    mov dword ptr [sum_even], 0h        ; set sum_even = 0

    mov dword ptr [sum_odd], 0h         ; set sum_odd = 0

    mov esi, 0h                         ; set esi as a counter: esi = 0
    sum_even_odd proc
    Li:
        cmp esi, dword ptr [n_int]      ; for esi in range(0, n_int]
        je @done
        
        push offset msg2                ; print msg2 'Enter elements: '
        call StdOut
        
        push max_size                   ; read each elements
        push offset tmp
        call StdIn

        lea edi, [tmp]                  ; convert to int
        call atoi
        push eax                        ; save input int
        and eax, 1h                     ; check if input int is even or odd
        jz @sum_even                    ; if (int & 1) == 0 -> even
        jmp @sum_odd                    ; else -> odd
    @continue:
        inc esi
        jmp Li
    @sum_even:
        mov ebx, dword ptr [sum_even]   ; ebx = sum_even
        pop eax                         ; eax = saved int
        add ebx, eax                    ; ebx += eax -> sum_even += even int
        mov [sum_even], ebx
        jmp @continue
    @sum_odd:               
        mov ebx, dword ptr [sum_odd]    ; ebx = sum_odd
        pop eax                         ; eax = saved int
        add ebx, eax                    ; ebx += eax -> sum_odd += odd int
        mov [sum_odd], ebx              
        jmp @continue
    @done: 
    sum_even_odd endp

    push offset msg3                    ; print msg3 'Sum of even elements: '
    call StdOut

    mov eax, dword ptr [sum_even]       ; print sum_even
    lea esi, [tmp_string]
    call itoa
    push eax
    call StdOut

    push offset newline                 ; print newline
    call StdOut

    push offset msg4                    ; print msg4 'Sum of odd elements: '
    call StdOut

    mov eax, dword ptr [sum_odd]        ; print sum_odd
    lea esi, [tmp_string]
    call itoa
    push eax
    call StdOut

    push offset newline                 ; print newline
    call StdOut

    inkey                               ; stop program and ask user to exit

    push 0h                             ; exit
    call ExitProcess

end start