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
    ButtonID equ 1                                ; The control ID of the button control
    EditID equ 2                                    ; The control ID of the edit control
    IDM_GETTEXT equ 3
    IDM_EXIT equ 4
.data?
    hInstance HINSTANCE ?
    hdc HDC ?

    wc WNDCLASSEX <?>
    msg MSG <?>
    hwnd HWND ?

    hEdit dd ?
    hButton    dd ?
    hPrint    dd ?
    buffer db 100 dup(?)                    ; buffer to store the text retrieved from the edit box
    buffer_2 db 100 dup(?) ; buffer to store the text retrieved from the
.data
    newline db 0Ah, 0h
	ClassName        db "MyWinClass", 0                ; class name, will be registered below
    AppName db "Reverse Text Box", 0h
    state db 0

    WIN_WIDTH dd 1024
    WIN_HEIGHT dd 768

	wcx        WNDCLASSEX <WNDCLASSEX, CS_HREDRAW or CS_VREDRAW, WndProc, 0, 0, 1, 2, 3, COLOR_BTNFACE+1, 0, ClassName, 4>

.code

reverse proc
    add edi, eax
    dec edi
    @loop_length:
        mov bh, byte ptr [edi]           
        mov bl, byte ptr [esi]
        mov byte ptr [esi], bh          
        inc esi                
        dec edi
        dec eax
        cmp eax, 0h
        jge @loop_length               
    mov byte ptr [esi], 0h
    ret
reverse endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    cmp uMsg, WM_CREATE
    je start_WM_CREATE

    cmp uMsg, WM_DESTROY
    je start_WM_CLOSE

    cmp uMsg, WM_ACTIVATE
    je start_WM_ACTIVATE

    cmp uMsg, WM_TIMER
    je start_WM_TIMER

    cmp uMsg, WM_COMMAND
    je start_WM_COMMAND

    cmp uMsg, WM_QUIT
    je start_WM_CLOSE

    cmp uMsg, WM_CLOSE
    je start_WM_CLOSE

    jmp start_default

    start_WM_TIMER:
        push 0h
        push IDM_GETTEXT
        push WM_COMMAND
        push hwnd
        call SendMessage

        jmp exit_proc

    start_WM_ACTIVATE:  

        push 0h
        push 100
        push 10
        push hwnd
        call SetTimer  

        jmp exit_proc

    start_WM_CREATE:
		mov esi, rv(CreateMenu)                ; create the main menu
        mov edi, rv(CreateMenu)                ; create a sub-menu

        push chr$("&Menu")
        push edi
        push MF_POPUP
        push esi
        call AppendMenu

        push chr$("&About")
        push 101
        push MF_STRING
        push edi
        call AppendMenu

        push chr$("&Exit")
        push 102
        push MF_STRING
        push edi
        call AppendMenu

        push esi
        push hWnd
        call SetMenu

        push 0h
        push wcx.hInstance
        push 103
        push hWnd
        push 50
        push 800
        push 9
        push 9
        push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOVSCROLL
        push 0h
        push chr$("edit")
        push WS_EX_CLIENTEDGE
        call CreateWindowEx
        
		mov hEdit, eax        ; you may need this global variable for further processing

		
        push 0h
        push wcx.hInstance
        push 104
        push hWnd
        push 50
        push 800
        push 200
        push 9
        push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOVSCROLL or ES_READONLY or ES_NOHIDESEL
        push 0h
        push chr$("edit")
        push WS_EX_CLIENTEDGE
        call CreateWindowEx
        
        mov hPrint, eax

        push hwnd
        call SetFocus

        push hwnd
        call SetActiveWindow

        jmp exit_proc

	start_WM_COMMAND:
		movzx eax, word ptr wParam        ; the Ids are in the LoWord of wParam

        .IF eax==101
            MsgBox 0, "This program has been made by tnt2402", "About", MB_OK
            jmp start_default
            .ENDIF
        .IF eax==102
            jmp start_WM_CLOSE
            .ENDIF

        .IF ax==IDM_GETTEXT
                ;invoke GetWindowText,hEdit,offset buffer,90
                push 90
                push offset buffer
                push hEdit
                call GetWindowText

                lea edi, [buffer]
                lea esi, [buffer_2]
                call reverse
                ;invoke SendMessage,hPrint,WM_SETTEXT,FALSE,addr buffer_2
                push offset buffer_2
                push FALSE
                push WM_SETTEXT
                push hPrint
                call SendMessage

        .ELSE
        .ENDIF
            jmp exit_proc
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
