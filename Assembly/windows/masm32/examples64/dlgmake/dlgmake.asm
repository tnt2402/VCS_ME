; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include64\masm64rt.inc

    .data?
      hInstance dq ?
      hWnd      dq ?
      hIcon     dq ?
      hEdit1    dq ?
      hEdit2    dq ?

    .data
      include data\batchfile.asm
      include data\dlgmain.asm
      include data\icondata.asm
      include data\rcdlg.asm
      include data\rsrcdata.asm
      include data\xmlfile.asm

      icolen dq 766

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

entry_point proc

    mov hInstance, rv(GetModuleHandle,0)
    mov hIcon, rv(LoadImage,hInstance,10,IMAGE_ICON,32,32,LR_DEFAULTCOLOR)
    invoke DialogBoxParam,hInstance,100,0,ADDR main,hIcon
    invoke ExitProcess,0

    ret

entry_point endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD

    LOCAL pbuf  :QWORD
    LOCAL buffer[260]:BYTE
    LOCAL tpath :QWORD
    LOCAL pname :QWORD
    LOCAL pbuffr[128]:BYTE

    .switch uMsg
      .case WM_INITDIALOG
      ; ------------------------------------------------------
      ; lParam is the icon handle passed from DialogBoxParam()
      ; ------------------------------------------------------
        invoke SendMessage,hWin,WM_SETICON,1,lParam     ; set the icon for the dialog
        invoke SendMessage,rv(GetDlgItem,hWin,102), \   ; set the icon in the client area
               STM_SETIMAGE,IMAGE_ICON,lParam
        invoke SetWindowText,hWin,"Create Base Dialog Template"
        mov hEdit1, rv(GetDlgItem,hWin,106)
        mov hEdit2, rv(GetDlgItem,hWin,107)
        mrm hWnd, hWin
        .return TRUE

      .case WM_COMMAND
        .switch wParam
          .case 101
            jmp exit_dialog             ; The OK button

          ; --------------
          ; create project
          ; --------------
          .case 102
            call create_project

          ; -------------
          ; build project
          ; -------------
          .case 103
            .if rv(exist,"makeit.bat") == 0
              invoke MessageBox,hWin,"You Must Build The Project First","dlgmake",MB_OK
            .else
              invoke WinExec,"makeit.bat",1
            .endif

          ; ------------
          ; test project
          ; ------------
          .case 104
            mov pbuf, ptr$(buffer)
            mov pname, ptr$(pbuffr)
            invoke GetWindowText,hEdit2,pname,128
            mcat pbuf,pname,".exe"

            .if rv(exist,pbuf) == 0
              invoke MessageBox,hWin,"You Must Build The Project First","dlgmake",MB_OK
            .else
              invoke WinExec,pbuf,1
            .endif

          ; --------------
          ; set target dir
          ; --------------
          .case 105
            invoke lBrowseForFolder,hWin,ADDR buffer, \
                   "Set Target Path For Project", \
                   "Create A New Directory If Necessary."
            mov tpath, ptr$(buffer)
            cmp BYTE PTR [rax], 0
            je @F
            invoke SetWindowText,hEdit1,tpath
            chdir tpath
          @@:

        .endsw

      .case WM_CLOSE
        exit_dialog:
        invoke EndDialog,hWin,0         ; exit from system menu
    .endsw

    xor rax, rax
    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

create_project proc

    LOCAL tlen :QWORD
    LOCAL pbuffr[64]:BYTE
    LOCAL pname :QWORD
    LOCAL datname:QWORD

    LOCAL fbuffr[128]:BYTE
    LOCAL pfname :QWORD

    invoke GetWindowTextLength,hEdit1
    test rax, rax
    jnz @F
    invoke MessageBox,hWnd,"You must set a target path first","Sorry ...",MB_OK
    ret
  @@:

    invoke GetWindowTextLength,hEdit2
    test rax, rax
    jnz @F
    invoke MessageBox,hWnd,"You must set a project name","Sorry ...",MB_OK
    ret
  @@:

  ; --------------------
  ; get the project name
  ; --------------------
    mov pname, ptr$(pbuffr)
    invoke GetWindowText,hEdit2,pname,260

    lea rax, dlgmain        ; main dialog file
    mov datname, rax

    mov pfname, ptr$(fbuffr)
    mcat pfname,pname,".asm"
    mov tlen, len(datname)
    invoke save_file,pfname,datname,tlen

    mov pfname, ptr$(fbuffr)
    lea rax, xmlfile        ; manifest file
    mov datname, rax
    mov tlen, len(datname)
    invoke save_file,"manifest.xml",datname,tlen

    lea rax, dlg_rc         ; dialog rc file
    mov datname, rax
    mov tlen, len(datname)
    invoke save_file,"dlgs.rc",datname,tlen

    lea rax, rsrc_data      ; main rc file
    mov datname, rax
    mov tlen, len(datname)
    invoke save_file,"rsrc.rc",datname,tlen

    lea rax, icondata       ; main rc file
    mov datname, rax
    invoke save_file,"icon.ico",datname,766

    lea rax, batchfile      ; main rc file
    mov datname, rax
    invoke szRep,datname,datname,"xxxxxxxxxxxxxxxxxxxxxxxx",pname
    mov tlen, len(datname)
    invoke save_file,"makeit.bat",datname,tlen

    invoke MessageBox,hWnd,"Project Written To Disk","Dlg Make",MB_OK

    ret

create_project endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    end




















