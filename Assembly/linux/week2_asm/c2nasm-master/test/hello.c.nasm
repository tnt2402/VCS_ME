






global main
global __x86.get_pc_thunk.ax

extern _GLOBAL_OFFSET_TABLE_


SECTION .text   

main:
        push    ebp
        mov     ebp, esp
        sub     esp, 16
        call    __x86.get_pc_thunk.ax
        add     eax, _GLOBAL_OFFSET_TABLE_-$
        mov     byte [ebp-2H], 1
        mov     byte [ebp-1H], 2
        movzx   edx, byte [ebp-1H]
        movzx   eax, byte [ebp-2H]
        add     eax, edx
        mov     byte [ebp-2H], al
        movzx   eax, byte [ebp-2H]
        add     eax, eax
        mov     byte [ebp-2H], al
        movsx   eax, byte [ebp-2H]
        leave
        ret



SECTION .data   


SECTION .bss    


SECTION .text.__x86.get_pc_thunk.ax 

__x86.get_pc_thunk.ax:
        mov     eax, dword [esp]
        ret



SECTION .note.gnu.property align=4

        db 04H, 00H, 00H, 00H, 18H, 00H, 00H, 00H
        db 05H, 00H, 00H, 00H, 47H, 4EH, 55H, 00H
        db 02H, 00H, 01H, 0C0H, 04H, 00H, 00H, 00H
        db 00H, 00H, 00H, 00H, 01H, 00H, 01H, 0C0H
        db 04H, 00H, 00H, 00H, 01H, 00H, 00H, 00H


