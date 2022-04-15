.386
.model     flat, stdcall
option     casemap :none
         
include C:\masm32\include\windows.inc 
include C:\masm32\include\kernel32.inc 
include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

max_size  EQU 12

.data?
  number1 db max_size dup(?)
  number2 db max_size dup(?)
 
.data
    msg1 db "Input number A: ", 0
    msg2 db "Input number B: ", 0
    msg3 db "Sum A + B: ", 0
    msg db max_size dup(0)

.code
    itoa proc uses ebx edx esi
    ; In: eax, number value
    ; Out: eax, offset of value in string format
    mov     esi, offset msg + max_size - 1
    mov     ebx, 10
    @loop:
        dec     esi
        xor     edx, edx
        div     ebx
        or      edx, 30h
        mov     byte ptr [esi], dl
        or      eax, eax
    jnz     @loop
    mov     eax, esi
    ret
    itoa endp
 
    atoi proc uses ebx ecx edx esi edi
    ; In: eax, offset to str_num
    ; out: eax, the number converted
        xor eax, eax
    @loop:
        movzx ecx, byte ptr [edi]
        sub ecx, '0'
        jb @done

        lea eax, [eax*4+eax]
        lea eax, [eax*2+ecx]
        inc edi
        jmp @loop
    @done:
        ret
    atoi endp
start:
    ; Get the numbers in asciiz
    invoke     StdOut, offset msg1
    invoke     StdIn, offset number1, max_size
    invoke     StdOut, offset msg2
    invoke     StdIn, offset number2, max_size

    ; Convert to numbers and sum
    mov        edi, offset number1
    call       atoi
    mov        ebx, eax

    mov        edi, offset number2
    call       atoi
    add        ebx, eax

    ; Show the result
    invoke     StdOut, offset msg3
    mov        eax, ebx
    call       itoa
    invoke     StdOut, eax
    invoke     ExitProcess, 0

end start