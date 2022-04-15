; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include64\masm64rt.inc

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

entry_point proc

    LOCAL arrmem :QWORD
    LOCAL .r15   :QWORD
    LOCAL .r14   :QWORD

    LOCAL buffer[64]:BYTE
    LOCAL pbuf :QWORD

    LOCAL strt$ :QWORD

    mrm strt$, "The number = "

    icnt equ <32768>

    mov .r14, r14
    mov .r15, r15

    mov arrmem, rv(fixed_array,icnt,32)         ; allocate the array

  ; -----------------------
  ; load array with strings
  ; -----------------------
    mov r14, 0
    mov r15, arrmem
  @@:
    mov pbuf, ptr$(buffer)                      ; get buffer pointer
    mcat pbuf,strt$,str$(r14)                   ; join the strings
    invoke mcopy,pbuf, \
           QWORD PTR [r15+r14*8], len(pbuf)     ; load each string into array
    add r14, 1
    cmp r14, icnt
    jb @B
  ; ---------------------------------
  ; display the contents of the array
  ; ---------------------------------
    mov r14, 0
    mov r15, arrmem
  @@:
    conout QWORD PTR [r15+r14*8],lf             ; display each string in array
    add r14, 1
    cmp r14, icnt
    jb @B
  ; ---------------------------------

    waitkey

    mfree arrmem                                ; release array memory

    mov r14, .r14
    mov r15, .r15

    invoke ExitProcess,0

    ret

entry_point endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    end
