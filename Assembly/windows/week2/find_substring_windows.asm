;ml /c /Zd /coff .\find_substring_windows.asm
;link /subsystem:console .\find_substring_windows.obj

.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

max_size equ 101

.data?
    string db max_size dup(?)
    substring db max_size dup(?)
    result db max_size dup(?)
    tmp dw max_size dup(?)
.data
    msg1 db "Enter string: ", 0Ah, 0h
    msg2 db "Enter substring: ", 0Ah, 0h
    newLn db 0Ah, 0h
    backspace db " ", 0h
    result_int db 4 dup(?)
    string_len dw 4
    substring_len dw 4
    arr dw max_size dup(0)
.code
    ;;  Input:  eax - integer
    ;;          esi - pointer to result buffer
    ;;  Output: in buffer
    itoa proc uses ebx edx esi
        add esi, max_size           ; point to the last of result buffer
        dec esi
        mov byte ptr [esi], 0h      ; set the last byte of result buffser to null
        mov ebx, 10                 ; ebx = 10
    @loop:
        xor edx, edx                ; edx = 0
        div ebx                     ; divide eax by divisor ebx = 10
        add dl, '0'                 ; dl - remainder
        dec esi                     ; point to the next left byte 
        mov [esi], dl               ; mov remainder to the current byte
        test eax, eax               ; if (eax == 0) ?
        jnz @loop                   ; if not -> loop
        mov eax, esi                ; else return result to eax
        ret      
    itoa endp

    ;;Input:   edi - pointer to string
    ;;         esi - pointer to substring
    ;;Output:  eax - the number of times 'input substring' appears in 'input string'
    times_ proc
        mov eax, edi                        ; eax = string[0]
        mov ebx, esi                        ; ebx = substring[0]
        mov edi, 0h                         ; edi - the number of times
        mov ecx, 0h                         ; ecx - counter 
    @loop:
        cmp byte ptr [ebx], 0h              ; compare ebx vs '\n'
        je @found                           ; if ebx == '\n' -> found substring
        cmp byte ptr [eax + ecx], 0h        ; else compare string[ecx] vs '\n'
        je @done                            ; if string[ecx] == '\n' -> done 
        mov dh, byte ptr [ebx]              ; compare string[counter] vs ebx = substring[?]
        cmp byte ptr [eax + ecx], dh
        jne @skip                           ; if not -> skip to next character of string
        inc ebx                             ; else counter++, ebx = next character of substring
        inc ecx
        jmp @loop                           ; do loop
    @skip:
        mov edx, esi
        cmp ebx, edx
        je @inc_ecx
        mov ebx, esi                        ; set ebx - first character of substring
        jmp @loop                           ; do loop
    @inc_ecx:
        inc ecx
        mov ebx, esi
        jmp @loop
    @found:
        mov dword ptr [arr + edi], ecx      ; save position of substring in string: arr[edi] = ecx
        movzx ebx, byte ptr [substring_len]
        sub ecx, ebx
        add ecx, 1
        inc edi                             ; edi++
        mov ebx, esi                        ; set ebx - first character of substring
        jmp @loop                           ; do loop
    @done:
        mov eax, edi                        ; mov result to eax 
        ret                                 ; return
    times_ endp

    print_position proc                         ; print position
        @loop:
            cmp edi, 0h                         ; edi (the number of times) cmp vs 0h -> edi is counter
            je @done                            ; if edi = 0 -> done
            movzx eax, byte ptr [esi]           ; else mov first byte of arr to eax -> eax = first position of substring = arr[0]
            movzx ebx, byte ptr [substring_len]
            sub eax, ebx                        ; eax = eax - substring_len
            push esi                            ; save esi value
            lea esi, [tmp]                      ; convert eax to string
            call itoa

            push eax                            ; print position of substring
            call StdOut

            push offset backspace               ; print space
            call StdOut

            pop esi                             ; restore previous value of esi
            inc esi                             ; increase esi = next position of substring = arr[1]
            dec edi                             ; decrease counter edi
            jmp @loop                           ; do loop
        @done:
            ret
        print_position endp
start:
    push offset msg1                            ; print msg1 'Enter string: '
    call StdOut

    push max_size                               ; read string from StdIn
    push offset string
    call StdIn

    push offset msg2                            ; print msg2 'Enter substring: '
    call StdOut

    push max_size                               ; read substring from StdIn
    push offset substring
    call StdIn

    mov dword ptr [substring_len], eax          ; set substring_len = substring's length


    mov edi, offset string                      ; call times_ function 
    mov esi, offset substring                   ; Result: eax 
    call times_

    mov eax, edi
    mov esi, offset result                      ; Convert number in eax to string and store in 'result' variable
    call itoa
    mov dword ptr [result_int], eax
    push eax                                    ; Print the number of times 'input substring' appears in 'input string'
    call StdOut

    push offset newLn                           ; Print newline
    call StdOut


    mov esi, offset arr                         ; print position of substrings
    call print_position

    push offset newLn                           ; Print newline
    call StdOut
    inkey                                       ; stop program and ask user to exit

    push 0h                                     ; exit
    call ExitProcess

end start
