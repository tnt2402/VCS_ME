; ��������������������������������������������������������������������������������������������������

    include \masm32\include64\masm64rt.inc

    .code

; ��������������������������������������������������������������������������������������������������

 atofp proc pstr:QWORD,fpval:REAL8

    invoke vc_sscanf, pstr,"%lf", fpval

    ret

 atofp endp

; ��������������������������������������������������������������������������������������������������

    end