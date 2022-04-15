
;include C:\masm64\include\user32.inc 
includelib C:\masm32\lib64\kernel32.lib 
includelib C:\masm32\lib64\user32.lib 
include C:\masm32\include64\masm64rt.inc
include C:\masm32\include64\msvcrt.inc

;EXTERN crt__getch: proc

.const
max_size equ 200
Console                 equ     -11         ; The standard output device code

.data
hTimerQueue dq  0
phNewTimer  dq 0
param       dq      123

newLn db 0Ah, 0h

time db "Time: ", 0h

f1              db '    Window handle = %X , window title = "%s"',0Ah, 0h
found_browser   db "  [+] Found a running browser!", 0Ah, 0h
; Browser Name 
    edge    db "Edge", 0h
    chrome  db "Chrome", 0h
    firefox db "Firefox", 0h
    browser dq offset edge, offset chrome, offset firefox
    length_browser dq 4, 6, 7
test_browser db "microsoft Edge", 0h
pid dq 1
count dq 0
time_counter dq 0

nBytesWritten       qword      ?                       ; Reserved space for number of bytes written
StdOut_              qword      ?                       ; Reserves space for handel to stdOut
StdIn_              qword ? ; Reserves space for handel to
STR1 db " ", 0Ah, 0h
.data?


buffer      db max_size dup(?)
buffer2     db max_size dup(?)
tmp         db max_size dup(?)

.code                                       ; Marks the start of Code section

    ;;Input:   rcx - pointer to string
    ;;         rdx - pointer to substring
    ;;Output:  rax - the number of times 'input substring' appears in 'input string'
     times_ proc
        mov rax, rdi                        ; rax = string[0]
        mov rbx, rsi                        ; rbx = substring[0]
        mov rdi, 0h                         ; rdi - the number of times
        mov rcx, 0h                         ; rcx - counter 
    @loop:
        cmp byte ptr [rbx], 0h              ; compare rbx vs '\n'
        je @found                           ; if rbx == '\n' -> found substring
        cmp byte ptr [rax + rcx], 0h        ; else compare string[rcx] vs '\n'
        je @done                            ; if string[rcx] == '\n' -> done 
        mov dh, byte ptr [rbx]              ; compare string[counter] vs rbx = substring[?]
        cmp byte ptr [rax + rcx], dh
        jne @skip                           ; if not -> skip to next character of string
        inc rbx                             ; else counter++, rbx = next character of substring
        inc rcx
        jmp @loop                           ; do loop
    @skip:
        mov rdx, rsi
        cmp rbx, rdx
        je @inc_rcx
        mov rbx, rsi                        ; set rbx - first character of substring
        jmp @loop                           ; do loop
    @inc_rcx:
        inc rcx
        mov rbx, rsi
        jmp @loop
    @found:
        mov rbx, [count]
        mov rbx, qword ptr [length_browser + rbx * 8]
        sub rcx, rbx
        add rcx, 1
        inc rdi                             ; rdi++
        mov rbx, rsi                        ; set rbx - first character of substring
        jmp @loop                           ; do loop
    @done:
        mov rax, rdi                        ; mov result to rax 
        ret                                 ; return
    times_ endp

    ;;  Input:  rax - integer
    ;;          rsi - pointer to result buffer
    ;;  Output: in buffer
    itoa proc 
        xor rdi, rdi
        add rsi, max_size      ; point to the last of result buffer
        dec rsi
        mov byte ptr [rsi], 0h      ; set the last byte of result buffser to null
        mov rbx, 10             ; rbx = 10
    @loop:
        xor rdx, rdx            ; rdx = 0
        div rbx                 ; divide rax by divisor rbx = 10
        add dl, '0'             ; dl - remainder
        dec rsi                 ; point to the next left byte 
        mov [rsi], dl           ; mov remainder to the current byte
        inc rdi
        test rax, rax           ; if (rax == 0) ?
        jnz @loop               ; if not -> loop
        mov rax, rsi            ; else return result to rax
        ret      
    itoa endp


EnumWndProc PROC hwnd:QWORD,lParam:QWORD

    mov r8, 200
    mov rdx, offset buffer
    mov rcx, hwnd
    call GetWindowTextA

    mov byte ptr [buffer + rax], 0h

    ; invoke  StdOut,ADDR buffer2
    ; mov rcx, StdOut_                 ; hConsoleOutput
    ; lea rdx, buffer
    ; mov r8, 10
    ; lea r9, nBytesWritten
    ; call WriteConsoleA

    mov [count], 0
@loop_find_browser:
    cmp [count], 3
    je @next_process


    push rdi
    push rsi
    push rbx

    mov rax, [count]
    mov rdi, offset buffer
    mov rsi, qword ptr [browser + rax * 8]
    call times_

    pop rbx
    pop rsi
    pop rdi

    cmp rax, 0h
    je @next_browser

    mov rcx, qword ptr [StdOut_]                 ; hConsoleOutput
    lea rdx, found_browser
    mov r8, lengthof found_browser
    lea r9, nBytesWritten
    call WriteConsoleA


    mov r9, offset buffer
    mov r8, hwnd
    mov rdx, offset f1
    mov rcx, offset buffer2
    call wsprintf

    ; invoke  StdOut,ADDR buffer2
    mov rcx, StdOut_                 ; hConsoleOutput
    lea rdx, buffer2
    mov r8, rax
    lea r9, nBytesWritten
    call WriteConsoleA

    ;invoke GetWindowThreadProcessId,hwnd,offset pid
    mov rdx, offset pid
    mov rcx, hwnd
    call GetWindowThreadProcessId

    ;invoke OpenProcess, PROCESS_TERMINATE,0, [pid]
    mov r8, QWORD PTR [pid]
    mov rdx, 0
    mov rcx, PROCESS_TERMINATE
    call OpenProcess

    ;invoke TerminateProcess, rax, 0
    mov rdx, 0
    mov rcx, rax
    call TerminateProcess


    mov rcx, StdOut_                 ; hConsoleOutput
    lea rdx, newLn
    mov r8, lengthof newLn
    lea r9, nBytesWritten
    call WriteConsoleA

    @next_browser:
        add [count], 1
        jmp @loop_find_browser

    @next_process:
        mov     rax,1h
        ret

EnumWndProc ENDP   

TimerProc proc hwnd:QWORD, uMsg:QWORD, PMidEvent:QWORD, dwTime:QWORD
    mov r9, OFFSET TimerProc
    mov r8, 2500
    mov rdx, 10
    mov rcx, 0
    call SetTimer

    mov rcx, StdOut_                 ; hConsoleOutput
    lea rdx, time
    mov r8, lengthof time
    lea r9, nBytesWritten
    call WriteConsoleA

    mov rax, qword ptr [time_counter]
    mov rsi, offset tmp
    call itoa

    add qword ptr [time_counter], 5

    mov rcx, qword ptr [StdOut_]                 ; hConsoleOutput
    mov rdx, rax
    mov r8, rdi
    lea r9, nBytesWritten
    call WriteConsoleA

    mov rcx, StdOut_                 ; hConsoleOutput
    lea rdx, newLn
    mov r8, lengthof newLn
    lea r9, nBytesWritten
    call WriteConsoleA

    ;invoke  EnumWindows,ADDR EnumWndProc,0
    mov rdx, 0
    mov rcx, offset EnumWndProc
    call EnumWindows

    mov rcx, 5000
    call Sleep

    mov rcx, 0
    mov rdx, 10
    call KillTimer    

TimerProc endp

main proc
            sub         rbp, 40             ; Reserve 40 bytes of Shadow Space

        ; Gets the STD output handle
            mov         rcx, STD_OUTPUT_HANDLE         ; QWORD nStdHandle:
            call        GetStdHandle        ; Returned handle is in RAX
            mov         StdOut_, rax         ; stores the handle for later use

            mov         rcx, STD_INPUT_HANDLE         ; QWORD nStdHandle:
            call        GetStdHandle        ; Returned handle is in RAX
            mov         StdIn_, rax         ; stores the handle for later use

        call TimerProc 

           @done:
            ; Exit process
            mov         rcx, 0              ; Set the Exit Code to 0
            add         rbp, 40             ; Release 40 bytes of Shadow Space
            call        ExitProcess         ; Hand back the CPU control to Windows
main endp

end