
.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib

EnumWndProc PROTO :DWORD,:DWORD

max_size equ 200
.data
hTimerQueue HANDLE  0
phNewTimer  PHANDLE 0
param       dd      123

newLn db 0Ah, 0h
f1          db '    Window handle = %X , window title = "%s"',13,10,0
found_browser db "  [+] Found a running browser!", 0Ah, 0h
; Browser Name 
    edge db "Edge", 0h
    chrome db "Chrome", 0h
    firefox db "Firefox", 0h
    browser dq offset edge, offset chrome, offset firefox
    length_browser dq 4, 6, 7

pid dd 1
count dd 0

.data?

buffer      db max_size dup(?)
buffer2     db max_size dup(?)
tmp db max_size dup(?)

.code

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
        mov ebx, [count]
        mov ebx, dword ptr [length_browser + ebx * 8]
        sub ecx, ebx
        add ecx, 1
        inc edi                             ; edi++
        mov ebx, esi                        ; set ebx - first character of substring
        jmp @loop                           ; do loop
    @done:
        mov eax, edi                        ; mov result to eax 
        ret                                 ; return
    times_ endp

EnumWndProc PROC hwnd:DWORD,lParam:DWORD

    invoke  GetWindowText,hwnd,ADDR buffer,200

    invoke  wsprintf,ADDR buffer2,ADDR f1,\
            hwnd,ADDR buffer
    invoke  StdOut,ADDR buffer2

    mov [count], 0

@loop_find_browser:
    cmp [count], 3
    je @next_process

    push edi
    push esi
    push ebx

    mov eax, [count]
    mov edi, offset buffer
    mov esi, dword ptr [browser + eax * 8]
    call times_ 

    pop ebx
    pop esi
    pop edi

    cmp eax, 0h
    je @next_browser

    push offset found_browser
    call StdOut

    invoke GetWindowThreadProcessId,hwnd,offset pid
    invoke OpenProcess, PROCESS_TERMINATE,0, [pid]
    invoke TerminateProcess, eax, 0

    invoke  wsprintf,ADDR buffer2,ADDR f1,\
            hwnd,ADDR buffer

    push offset newLn
    call StdOut

    @next_browser:
        add [count], 1
        jmp @loop_find_browser


    @next_process:
        mov     eax,1h
        ret
  
EnumWndProc ENDP   

TimerProc proc lpParam:PVOID, TimerOrWaitFired:DWORD
    invoke  EnumWindows,ADDR EnumWndProc,0
    ret
TimerProc endp

start:

    invoke CreateTimerQueue
    mov hTimerQueue, eax
    .IF eax == 0
        printf("CreateTimerQueue error %s\n",LastError$())
        inkey
    .ENDIF

    invoke CreateTimerQueueTimer, ADDR phNewTimer, hTimerQueue,
                                  TimerProc, ADDR param,
                                  1, 5000, WT_EXECUTEINTIMERTHREAD
    .IF eax == 0
        printf("CreateTimerQueueTimer error %s\n",LastError$())
        inkey
    .ENDIF

    ;inkey " ", 13, 10
    call  crt__getch

    invoke DeleteTimerQueueTimer, hTimerQueue, phNewTimer, NULL
    .IF eax == 0
        printf("DeleteTimerQueueTimer error %s\n",LastError$())
    .ENDIF

    invoke DeleteTimerQueueEx, hTimerQueue, INVALID_HANDLE_VALUE
    .IF eax == 0
        printf("DeleteTimerQueueEx error %s\n",LastError$())
    .ENDIF

    ;inkey

    exit

end start