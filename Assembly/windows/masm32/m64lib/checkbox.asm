; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

    include \masm32\include64\masm64rt.inc

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

checkbox proc hparent:QWORD,instance:QWORD,text:QWORD,topx:QWORD,topy:QWORD,wid:QWORD,hgt:QWORD,idnum:QWORD

    invoke CreateWindowEx,WS_EX_LEFT,"BUTTON",text, \
                          WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX,\
                          topx,topy,wid,hgt,hparent,idnum,instance,0
    ret

checkbox endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    end
