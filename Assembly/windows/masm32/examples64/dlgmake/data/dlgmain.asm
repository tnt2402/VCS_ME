
  dlgmain \
    db "; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい",13,10
    db 13,10
    db "    include \masm32\include64\masm64rt.inc",13,10
    db 13,10
    db "    .data?",13,10
    db "      hInstance dq ?",13,10
    db "      hIcon     dq ?",13,10
    db 13,10
    db "    .code",13,10
    db 13,10
    db "; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい",13,10
    db 13,10
    db "entry_point proc",13,10
    db 13,10
    db "  ; -----------------------",13,10
    db "  ; get the instance handle",13,10
    db "  ; -----------------------",13,10
    db "    mov hInstance, rv(GetModuleHandle,0)",13,10
    db 13,10
    db "  ; -------------------------------------------------------------",13,10
    db "  ; set the icon loaded size here to match the original icon size",13,10
    db "  ; -------------------------------------------------------------",13,10
    db "    mov hIcon, rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)",13,10
    db 13,10
    db "  ; ---------------------",13,10
    db "  ; create a modal dialog",13,10
    db "  ; ---------------------",13,10
    db "    invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon",13,10
    db 13,10
    db "  ; --------------------------------",13,10
    db "  ; terminate app when dialog closes",13,10
    db "  ; --------------------------------",13,10
    db "    invoke ExitProcess,0",13,10
    db 13,10
    db "    ret",13,10
    db 13,10
    db "entry_point endp",13,10
    db 13,10
    db "; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい",13,10
    db 13,10
    db "main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD",13,10
    db 13,10
    db "    .switch uMsg",13,10
    db "      .case WM_INITDIALOG",13,10
    db "      ; ------------------------------------------------------",13,10
    db "      ; lParam is the icon handle passed from DialogBoxParam()",13,10
    db "      ; ------------------------------------------------------",13,10
    db "        invoke SendMessage,hWin,WM_SETICON,1,lParam     ; set the icon for the dialog",13,10
    db "        invoke SendMessage,rv(GetDlgItem,hWin,102), \   ; set the icon in the client area",13,10
    db "               STM_SETIMAGE,IMAGE_ICON,lParam",13,10
    db "        invoke SetWindowText,hWin,",34,"Base Dialog",34,13,10
    db "      ; ----------------------------------------------------",13,10
    db "      ; set the focus to the first control by returning TRUE",13,10
    db "      ; ----------------------------------------------------",13,10
    db "        .return TRUE",13,10
    db 13,10
    db "      .case WM_COMMAND",13,10
    db "        .switch wParam",13,10
    db "          .case 101",13,10
    db "            jmp exit_dialog             ; The OK button",13,10
    db "        .endsw",13,10
    db 13,10
    db "      .case WM_CLOSE",13,10
    db "        exit_dialog:",13,10
    db "        invoke EndDialog,hWin,0         ; exit from system menu",13,10
    db "    .endsw",13,10
    db 13,10
    db "    xor rax, rax",13,10
    db "    ret",13,10
    db 13,10
    db "main endp",13,10
    db 13,10
    db "; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい",13,10
    db 13,10
    db "    end",13,10,0