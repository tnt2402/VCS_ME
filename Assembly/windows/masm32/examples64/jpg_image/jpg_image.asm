; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include64\masm64rt.inc

    .data?
      hInstance dq ?
      hIcon     dq ?
      hBmp      dq ?
      hStatic   dq ?

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

entry_point proc

    GdiPlusBegin                        ; initialise GDIPlus

    mov hInstance, rv(GetModuleHandle,0)
    mov hIcon,     rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
    mov hBmp,      rv(ResImageLoad,20)

    invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon

    GdiPlusEnd                          ; GdiPlus cleanup

    invoke ExitProcess,0
    ret

entry_point endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD

    .switch uMsg
      .case WM_INITDIALOG
        invoke SetWindowText,hWin,"JPG Image In Dialog"
        invoke SendMessage,hWin,WM_SETICON,1,lParam
        mov hStatic, rv(GetDlgItem,hWin,102)
        invoke SendMessage,hStatic,STM_SETIMAGE,IMAGE_BITMAP,hBmp
        .return TRUE

      .case WM_COMMAND
        .switch wParam
          .case 101
            jmp exit_dialog             ; The OK button
        .endsw

      .case WM_CLOSE
        exit_dialog:
        invoke EndDialog,hWin,0         ; exit from system menu
    .endsw

    xor rax, rax
    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    end
