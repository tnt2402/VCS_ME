.386 ; 386 Processor Instruction Set
.model flat, stdcall ; Flat memory model and stdcall method
option casemap:none ; Case Sensitive

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc ; defines alias such as NULL and STD_OUTPUT_HANDLE
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib
includelib C:\masm32\lib\gdi32.lib

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD

.const
DRAWING equ 1
BALL_SIZE equ 20
.data?
    hInstance HINSTANCE ?
    ps PAINTSTRUCT <?>
    hdc HDC ?

    right_bottom POINT <>
    left_top POINT <>

    wc WNDCLASSEX <?>
    msg MSG <?>
    hwnd HWND ?

    hPen_out HPEN ?
    hPen_in HPEN ?
    hOldPen HPEN ?

.data
    newline db 0Ah, 0h
    ClassName db "WinClass", 0h
    AppName db "Ball Bouncing", 0h
    state db 0

    WIN_WIDTH dd 1024
    WIN_HEIGHT dd 768

    vector_X dd 6
    vector_Y dd -6
    RangeOfNumbers dd 1
.code
;; generate random number in range
;   Input: RangeOfNumbers:DWORD
;   Output: eax - random number in range (0, RangeOfNumbers)
gen_rand proc
    @@:
    db 0Fh, 0C7h, 0F0h                  ; rdrand eax
    jnc @B                              ; Invalid number - try again

    ; Adjust EAX to the range
    mov ecx, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
    xor edx, edx                        ; Needed for DIV
    div ecx                             ; EDX:EAX/ECX -> EAX remainder EDX
    mov eax, edx                        ; Get the remainder
    err_exit:
    ret
gen_rand endp

moveBall proc
    mov eax, dword ptr [vector_X]
    mov ecx, dword ptr [vector_Y]

    add left_top.x, eax
    add left_top.y, ecx
    add right_bottom.x, eax
    add right_bottom.y, ecx

    ret
moveBall endp

createBall proc
    push hPen_out
    push hdc
    call SelectObject
    mov eax, hOldPen

    ; print ellipse
    push right_bottom.y
    push right_bottom.x
    push left_top.y
    push left_top.x
    push hdc
    call Ellipse

    push hPen_in
    push hdc
    call SelectObject
    mov eax, hOldPen

    push hPen_in
    push hdc
    call SelectObject
    mov eax, hOldPen
    push right_bottom.y
    push right_bottom.x
    push left_top.y
    push left_top.x
    push hdc
    call Ellipse  
    
    push hOldPen
    push hdc
    call SelectObject          

    call moveBall

    mov eax, WIN_WIDTH
    sub eax, 30
    cmp right_bottom.x, eax
    jg meet_right_left

    mov eax, WIN_HEIGHT
    sub eax, 60
    cmp right_bottom.y, eax
    jg meet_bottom_top

    cmp left_top.x, 14
    jl meet_right_left

    cmp left_top.y, 14
    jl meet_bottom_top

    jmp bouncing

    meet_right_left:
        neg vector_X
        jmp bouncing

    meet_bottom_top:
        neg vector_Y
        jmp bouncing

    bouncing:
        ret
createBall endp

TimerProc PROC thwnd:HWND, uMsg:UINT, idEvent:UINT, dwTime:DWORD
        push TRUE
        push NULL
        push thwnd
        call InvalidateRect
        ret
TimerProc ENDP

updateXY proc lParam:LPARAM
    cmp [state], DRAWING
    je @drawing_update

    mov eax, dword ptr [WIN_WIDTH]
    sub eax, 50
    mov dword ptr [RangeOfNumbers], eax
    call gen_rand
    add eax, 20
    mov left_top.x, eax
    mov right_bottom.x, eax
    add right_bottom.x, BALL_SIZE

    mov eax, dword ptr [WIN_HEIGHT]
    sub eax, 50
    mov dword ptr [RangeOfNumbers], eax
    call gen_rand
    add eax, 20
    mov left_top.y, eax
    mov right_bottom.y, eax
    add right_bottom.y, BALL_SIZE

    mov dword ptr [RangeOfNumbers], 4
    call gen_rand
    cmp eax, 0h                 ; ball go to top - right (default)
    je @done_updateXY

    cmp eax, 1h                 ; ball go to top - left
    je @ball_go_to_top_left

    cmp eax, 2h                 ; ball go to bottom - right
    je @ball_go_to_bottom_right

    cmp eax, 3h                 ; ball go to bottom - left
    je @ball_go_to_bottom_left  
@ball_go_to_top_left:
    neg vector_X
    ret
@ball_go_to_bottom_right:
    neg vector_Y
    ret
@ball_go_to_bottom_left:
    neg vector_X
    neg vector_Y
    ret
    
@drawing_update:
    mov eax, lParam

    ; get low word that contain x
    xor ebx, ebx
    mov bx, ax

    mov left_top.x, ebx
    mov right_bottom.x, ebx
    add right_bottom.x, BALL_SIZE

    ; get high word that contain y
    mov eax, lParam
    shr eax, 16

    mov left_top.y, eax
    mov right_bottom.y, eax
    add right_bottom.y, BALL_SIZE
@done_updateXY:
    ret
updateXY endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    cmp uMsg, WM_PAINT
    je start_WM_PAINT

    cmp uMsg, WM_CREATE
    je start_WM_CREATE

    cmp uMsg, WM_DESTROY
    je start_WM_CLOSE

    cmp uMsg, WM_ACTIVATE
    je start_WM_ACTIVATE

    cmp uMsg, WM_QUIT
    je start_WM_CLOSE

    cmp uMsg, WM_CLOSE
    je start_WM_CLOSE

    jmp start_default

    start_WM_CREATE:
        push Black  ; create our pen
        push 30
        push PS_SOLID
        call CreatePen
        mov hPen_out, eax

        push Red  ; create our pen
        push 20
        push PS_SOLID
        call CreatePen
        mov hPen_in, eax

        jmp exit_proc
    start_WM_PAINT:
        push offset ps
        push hWnd
        call BeginPaint
        mov hdc, eax
        
        call createBall

        push offset ps
        push hWnd
        call EndPaint

        jmp exit_proc   
    start_WM_ACTIVATE:

            push lParam
            call updateXY

            mov [state], DRAWING

            push OFFSET TimerProc
            push 33
            push 10
            push hwnd
            call SetTimer

            jmp exit_proc          
    ; user close program
    start_WM_CLOSE:
        push NULL
        call PostQuitMessage
        jmp exit_proc 
    start_default:
        push lParam
        push wParam
        push uMsg
        push hWnd
        call DefWindowProc

        jmp exit_proc
    exit_proc:
        ret
WndProc endp 

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD

    ; Load default icon
    push IDI_APPLICATION
    push NULL
    call LoadIcon
    mov wc.hIcon, eax
    mov wc.hIconSm, eax

    ; Load default cursor
    push IDC_ARROW
    push NULL
    call LoadCursor
    mov wc.hCursor, eax

        mov wc.cbSize, SIZEOF WNDCLASSEX    ; size of this structure
        mov wc.style, CS_HREDRAW or CS_VREDRAW  ; style of windows https://msdn.microsoft.com/en-us/library/windows/desktop/ff729176(v=vs.85).aspx
        mov wc.lpfnWndProc, OFFSET WndProc  ; andress of window procedure
        mov wc.cbClsExtra, NULL
        mov wc.cbWndExtra, NULL
        push hInstance
        pop wc.hInstance
        mov wc.hbrBackground, COLOR_WINDOW+1    ; background color, require to add 1
        mov wc.lpszMenuName, NULL
        mov wc.lpszClassName, OFFSET ClassName

        ; we register our own class, named in ClassName
        push offset wc
        call RegisterClassEx

        ; after register ClassName, we use it to create windows compond
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms632680(v=vs.85).aspx
        push NULL
        push hInstance
        push NULL
        push NULL
        push WIN_HEIGHT
        push WIN_WIDTH
        push CW_USEDEFAULT
        push CW_USEDEFAULT
        push WS_OVERLAPPEDWINDOW
        push offset AppName
        push offset ClassName
        push WS_EX_CLIENTEDGE
        call CreateWindowEx
        mov hwnd, eax 

        ; display window
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
        push CmdShow
        push hwnd
        call ShowWindow

        ; update window
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd145167(v=vs.85).aspx
        push hwnd
        call UpdateWindow

    ; .while TRUE
    ;     invoke GetMessage, addr msg, NULL, 0, 0
    ;     .break .if (!eax)
    ;         push offset msg
    ;         call TranslateMessage
    ;         push offset msg
    ;         call DispatchMessage
    ;     .endw 

    ; mov eax, msg.wParam
    ; ret

    ;Message Loop
    MESSAGE_LOOP:
        ; get message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644936(v=vs.85).aspx
        push 0
        push 0
        push NULL
        push offset msg
        call GetMessage

        ; return in eax
        ; if the function retrieves a message other than WM_QUIT, the return value is nonzero.
        ; if the function retrieves the WM_QUIT message, the return value is zero.
        test eax, eax
        jle END_LOOP

        ; translate virtual-key messages into character messages - ASCII in WM_CHAR
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644955(v=vs.85).aspx
        push offset msg
        call TranslateMessage

        ; sends the message data to the window procedure responsible for the specific window the message is for.
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms644934(v=vs.85).aspx
        push offset msg
        call DispatchMessage

        jmp MESSAGE_LOOP

    END_LOOP:
        mov eax, msg.wParam
    ret
WinMain endp

start:  
    push 0h
    call GetModuleHandle

    mov hInstance, eax
    push SW_SHOW
    push 0h
    push 0h
    push hInstance
    call WinMain

    push eax
    call ExitProcess
end start