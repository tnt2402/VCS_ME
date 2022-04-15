; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
;                              Pass procedure arguments in an array
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include64\masm64rt.inc

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

entry_point proc

    LOCAL arr[16] :QWORD                    ; create a QWORD array on the stack

    lea rcx, arr                            ; load its address into RCX
    mov QWORD PTR [rcx], 1
    mov QWORD PTR [rcx+8], 2
    mov QWORD PTR [rcx+16], 3
    mov QWORD PTR [rcx+24], 4
    mov QWORD PTR [rcx+32], 5
    mov QWORD PTR [rcx+40], 6
    mov QWORD PTR [rcx+48], 7
    mov QWORD PTR [rcx+56], 8
    call arrtest                            ; call the arrtest proc with address in RCX

    waitkey

    invoke ExitProcess,0

    ret

entry_point endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

arrtest proc parr:QWORD

    LOCAL .r15 :QWORD

    mov [rbp+16], rcx                       ; copy RCX into parr address
    mov .r15, r15                           ; preserve r15

    mov r15, parr

    conout str$(QWORD PTR [r15]),lf
    conout str$(QWORD PTR [r15+8]),lf
    conout str$(QWORD PTR [r15+16]),lf
    conout str$(QWORD PTR [r15+24]),lf
    conout str$(QWORD PTR [r15+32]),lf
    conout str$(QWORD PTR [r15+40]),lf
    conout str$(QWORD PTR [r15+48]),lf
    conout str$(QWORD PTR [r15+56]),lf

    mov r15, .r15                           ; restore r15

    ret

arrtest endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    end
