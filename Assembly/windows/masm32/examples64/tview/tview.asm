comment # いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    BUILD RESULTS VIEWER

    Application accepts a file name on the command line which it will load and display.
    Press F1 to copy contents, ESC to exit

いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい #

    include \masm32\include64\masm64rt.inc

    .data?
      hInstance dq ?
      hWnd      dq ?
      hIcon     dq ?
      hCursor   dq ?
      hEdit     dq ?
      sWid      dq ?
      sHgt      dq ?

    .data
      classname db "64_bit_result_viewer",0
      caption db "Result View... F1 to copy, ESC to exit",0

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

entry_point proc

    mov hInstance, rv(GetModuleHandle,0)
    mov hIcon,     rv(LoadIcon,hInstance,10)
    mov hCursor,   rv(LoadCursor,0,IDC_ARROW)
    mov sWid,      rv(GetSystemMetrics,SM_CXSCREEN)
    mov sHgt,      rv(GetSystemMetrics,SM_CYSCREEN)

    call main

    invoke ExitProcess,0

    ret

entry_point endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL wc      :WNDCLASSEX
    LOCAL lft     :QWORD
    LOCAL top     :QWORD
    LOCAL wid     :QWORD
    LOCAL hgt     :QWORD
    LOCAL pFile   :QWORD
    LOCAL pbuf    :QWORD
    LOCAL buf[128]:BYTE

    mov wc.cbSize,         SIZEOF WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW
    mov wc.lpfnWndProc,    ptr$(WndProc)
    mov wc.cbClsExtra,     128
    mov wc.cbWndExtra,     128
    mrm wc.hInstance,      hInstance
    mrm wc.hIcon,          hIcon
    mrm wc.hCursor,        hCursor
    mov wc.hbrBackground,  0        ; COLOR_BTNSHADOW+1
    mov wc.lpszMenuName,   0
    mov wc.lpszClassName,  ptr$(classname)
    mrm wc.hIconSm,        hIcon

    invoke RegisterClassEx,ADDR wc

    mov wid, function(getpercent,sWid,65)   ; 65% screen width
    mov hgt, function(getpercent,sHgt,65)   ; 65% screen height

    invoke aspect_ratio,hgt,45              ; height + 45%
    cmp wid, rax                            ; if wid > rax
    jle @F
    mov wid, rax                            ; set wid to rax
  @@:
    mov rax, sWid                           ; calculate offset from left side
    sub rax, wid
    shr rax, 1
    mov lft, rax

    mov rax, sHgt                           ; calculate offset from top edge
    sub rax, hgt
    shr rax, 1
    mov top, rax

  ; ---------------------------------
  ; centre window at calculated sizes
  ; ---------------------------------

    WS_EX_NOREDIRECTIONBITMAP equ <00200000h>

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES or WS_EX_TRANSPARENT, \
                          ADDR classname,ADDR caption, \
                          WS_OVERLAPPEDWINDOW or WS_VISIBLE,\
                          lft,top,wid,hgt,0,0,hInstance,0
    mov hWnd, rax

    invoke LoadLibrary,"riched20.dll"
    mov hEdit, rv(rich_edit,hWnd,hInstance)
    invoke SendMessage,hWnd,WM_SIZE,0,0
    invoke SetFocus,hEdit

  ; --------------------------------------
  ;     load file from command line
  ; --------------------------------------
    call cmd_tail                   ; get command tail
    mov pFile, rax                  ; store rax in variable
    cmp BYTE PTR [rax], 0           ; test if its empty
    je rfout                        ; bypass loading file if empty

    invoke exist,pFile              ; check if file exists
    test rax, rax
    jnz @F

    mov pbuf,ptr$(buf)
    mcat pbuf,"Command line file '",pFile,"' cannot be found."
    invoke MsgboxI,hWnd,pbuf,"Whoops",MB_OK,10
    jmp rfout

  @@:
    invoke file_read,hEdit,pFile

  rfout:
    mfree pFile                     ; release the memory from cmd_tail
  ; --------------------------------------

    call msgloop

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

msgloop proc

    LOCAL msg    :MSG
    LOCAL pmsg   :QWORD

    lea rax, msg
    mov pmsg, rax
    jmp gmsg

  stlp:
    .switch msg.message
      .case WM_KEYDOWN
        .switch msg.wParam
          .case VK_ESCAPE
            invoke SendMessage,hWnd,WM_SYSCOMMAND,SC_CLOSE,NULL
          .case VK_F1
            invoke Select_All,hEdit
            invoke SendMessage,hEdit,WM_COPY,0,0
        .endsw
    .endsw
    invoke TranslateMessage,pmsg
    invoke DispatchMessage,pmsg
  gmsg:
    test rax, rv(GetMessage,pmsg,0,0,0)
    jnz stlp

    ret

msgloop endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD

    LOCAL rct :RECT

    .switch uMsg
      .case WM_SIZE
        invoke GetClientRect,hWin,ADDR rct
        invoke MoveWindow,hEdit,0,0,rct.right,rct.bottom,TRUE

      .case WM_CLOSE
        invoke SendMessage,hWin,WM_DESTROY,0,0

      .case WM_DESTROY
        invoke PostQuitMessage,NULL

    .endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

rich_edit proc hParent:QWORD,instance:QWORD

    LOCAL pEdit  :QWORD
    LOCAL hFont  :QWORD
    LOCAL styl   :QWORD

  ; ---------------------------
  ; create the richedit control
  ; ---------------------------
    mov styl, WS_VISIBLE or WS_CHILDWINDOW or WS_CLIPSIBLINGS or \
              ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_AUTOHSCROLL or \
              ES_AUTOVSCROLL or ES_NOHIDESEL or ES_DISABLENOSCROLL

    invoke CreateWindowEx,WS_EX_STATICEDGE,"RichEdit20a", \
             0,styl,0,0,200,100,hParent,111,instance,0

    mov pEdit, rax
  ; ---------------------------

    invoke SendMessage,pEdit,EM_EXLIMITTEXT,0,1000000000
    invoke SendMessage,pEdit,EM_SETOPTIONS,ECOOP_XOR,ECO_SELECTIONBAR

    mov hFont, rv(font_handle,"fixedsys",9,600)         ; library procedure
    invoke SendMessage,pEdit,WM_SETFONT,hFont,TRUE

    invoke SendMessage,hWnd,WM_SIZE,0,0                 ; size control to client area

    mov rax, pEdit

    ret

rich_edit endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

Select_All Proc Edit:QWORD

    LOCAL Cr :CHARRANGE

    mov Cr.cpMin,0
    invoke GetWindowTextLength,Edit
    add rax, 1
    mov Cr.cpMax, eax
    invoke SendMessage,Edit,EM_EXSETSEL,0,ADDR Cr

    ret

Select_All endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    end
