;ml /c /Zd /coff .\simple_addition_windows.asm
;link /subsystem:console .\simple_addition_windows.obj

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
    number1 db max_size dup(?)
    number2 db max_size dup(?)
 
.data
    msg1 db "Input number A: ", 0h
    msg2 db "Input number B: ", 0h
    msg3 db "Sum A + B:      ", 0h
    sum db max_size dup(?)
    newline db 0Ah, 0

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
    push offset msg1            ; print msg1 "Input number A: "  
    call StdOut

    push max_size               ; read max_size bytes from StdIn and store in 'number1' variable
    push offset number1
    call StdIn

    push offset msg2            ; print msg2 "Input number B: "
    call StdOut

    push max_size               ; read max_size bytes from StdIn and store in 'number2' variable
    push offset number2
    call StdIn

    ; Convert to numbers and sum
    mov edi, offset number1
    call atoi
    mov ebx, eax

    mov edi, offset number2
    call atoi
    add ebx, eax

    ; Show the result
    push offset msg3
    call StdOut

    mov eax, ebx
    mov esi, offset sum
    call itoa

    push eax                    ; print result
    call StdOut

    push offset newline         ; print newline
    call StdOut

    inkey                       ; stop program and ask user to exit
    push 0h                     ; exit
    call ExitProcess

end start