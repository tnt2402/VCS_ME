;ml /c /coff /Zd .\array_min_max.asm  
;link /subsystem:console .\array_min_max.asm  

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
    msg3 db "Max: ", 0h
    msg4 db "Min: ", 0h
    sum db max_size dup(?)
    n_int dd 2
    number1 dd 2
    number2 dd 2
    min_int dd 2
    max_int dd 2
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

    min_max proc
    Li:
        cmp esi, dword ptr [n_int]      ; for esi in range(0, n_int]
        je @done
        
        push offset msg2                ; print msg2 'Enter elements: '
        call StdOut
        
        push max_size                   ; read each elements
        push offset tmp
        call StdIn

        lea edi, [tmp]                  ; convert input string to number 
        call atoi
        cmp eax, dword ptr [max_int]    ; compare input int vs max_int
        jge @set_max                    ; if input > max_int: max_int = input
    @continue:
        cmp eax, dword ptr [min_int]    ; if input < min_int: min_int = input
        jl @set_min
        inc esi                         ; counter++
        jmp Li
    @set_max:
        mov dword ptr [max_int], eax    
        jmp @continue
    @set_min:
        mov dword ptr [min_int], eax
        inc esi                         ; counter++
        jmp Li
    @done: 
        ret
    min_max endp
start:
    ; Get the numbers in ascii
    push offset msg1                ; print msg1 'Enter number N: '
    call StdOut

    push max_size                   ; read max_size bytes from StdIn and store in 'n' variable
    push offset n
    call StdIn

    mov edi, offset n               ; convert string 'n' to int 'n_int'
    call atoi
    mov dword ptr [n_int], eax

    mov dword ptr [min_int], 7fffffffh  ; min_int = 7fffffffh

    mov dword ptr [max_int], 0h     ; max_int = 0h

    mov esi, 0h                     ; set esi (counter) = 0
    call min_max                    ; call min_max proc

    push offset msg3                ; print msg3 'Max: '
    call StdOut

    mov eax, dword ptr [max_int]    ; print max_int
    lea esi, [tmp_string]
    call itoa
    push eax    
    call StdOut

    push offset newline             ; print newline
    call StdOut

    push offset msg4                ; print msg4 'Min: '
    call StdOut

    mov eax, dword ptr [min_int]    ; print min_int
    lea esi, [tmp_string]
    call itoa
    push eax
    call StdOut

    push offset newline             ; print newline
    call StdOut

    inkey                           ; stop program and ask user to exit

    push 0h                         ; exit
    call ExitProcess

end start