; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

    include \masm32\include64\masm64rt.inc

    externdef intdiv:PROC
    externdef intmul:PROC

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

getpercent proc src:QWORD,pcnt:QWORD

    mov r10, pcnt
    shl src, 10
    shl pcnt, 10

    fn intdiv,src,100
    fn intmul,rax,r10

    shr rax, 10

    ret

getpercent endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

    end
