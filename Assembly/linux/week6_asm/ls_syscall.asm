
; struct linux_dirent {
; 	unsigned long  d_ino;     /* Inode number */
; 	unsigned long  d_off;     /* Offset to next linux_dirent */
; 	unsigned short d_reclen;  /* Length of this linux_dirent */
; 	char           d_name[];  /* Filename (null-terminated) */
; 						/* length is actually (d_reclen - 2 -
; 						offsetof(struct linux_dirent, d_name)) */
; 	/*
; 	char           pad;       // Zero padding byte
; 	char           d_type;    // File type (only since Linux
; 								// 2.6.4); offset is (d_reclen - 1)
; 	*/
; }

;; d_type enum
;     DT_UNKNOWN = 0,
; # define DT_UNKNOWN        DT_UNKNOWN
;     DT_FIFO = 1,
; # define DT_FIFO        DT_FIFO
;     DT_CHR = 2,
; # define DT_CHR                DT_CHR
;     DT_DIR = 4,
; # define DT_DIR                DT_DIR
;     DT_BLK = 6,
; # define DT_BLK                DT_BLK
;     DT_REG = 8,
; # define DT_REG                DT_REG
;     DT_LNK = 10,
; # define DT_LNK                DT_LNK
;     DT_SOCK = 12,
; # define DT_SOCK        DT_SOCK
;     DT_WHT = 14
; # define DT_WHT                DT_WHT

BITS 64

section .data
	max_size equ 200
	len_of_name dq 0
	proc_dir db "/proc/", 0h
	cmdline_dir db "/cmdline", 0h
	count dq 0
	newLn db " ", 0Ah, 0h
	second_and_newLn db " s", 0Ah, 0h
	timer dq 0
	pid_msg db "	Found netcat process's PID: ", 0h
	time_msg db "Time: ", 0h

;; sleep param
	timespec:
		tv_sec  dq 10
		tv_nsec dq 0
section .bss
	tmp resb max_size 
	tmp_name resb max_size
	tmp_dir resb max_size
	tmp_cmdline resb 8
section .text
	GLOBAL _start

 	;;  Input:   rdi - input string
    ;;  Output:  rax - result in integer
    atoi:
        xor rax, rax            ; set rax = 0
    .loop:
        movzx rcx, byte [rdi]   ; rcx = first byte of rdi - input string
        sub rcx, '0'            ; convert num -> int 
        jb .done                ; 

        lea rax, [rax*4+rax]    ; rax = rax * 5
        lea rax, [rax*2+rcx]    ; rax = rax * 5 * 2 + rcx
        inc rdi                 ; next character of string
        jmp .loop
    .done:
        ret

    ;;  Input:  rax - integer
    ;;          rsi - pointer to result buffer
    ;;  Output: in buffer
	;;			rdi - length of result 
    itoa:
        add rsi, max_size       ; point to the last of result buffer
        mov byte [rsi], 0h      ; set the last byte of result buffser to null
        mov rbx, 10             ; rbx = 10
		mov rdi, 0
    .loop:
        xor rdx, rdx            ; rdx = 0
        div rbx                 ; rbx = divisor
        add dl, '0'             ; dl - remainder
        dec rsi                 ; point to the next left byte 
        mov [rsi], dl           ; mov remainder to the current byte
		add rdi, 1
        test rax, rax           ; if (rax == 0) ?
        jnz .loop               ; if not -> loop
        mov rax, rsi            ; else return result to rax
        ret 

_start:
	mov qword [timer], 0h
.10_second_later:


	mov rax, 1			; print time_msg
	lea rsi, [time_msg]
	mov rdi, 1
	mov rdx, 7
	syscall

	mov rax, qword [timer]
	lea rsi, [tmp]
	call itoa

	mov rsi, rax		; print timer
	mov rdx, rdi
	mov rax, 1
	mov rdi, 1
	syscall

	mov rax, 1			; print time_msg
	lea rsi, [second_and_newLn]
	mov rdi, 1
	mov rdx, 4
	syscall

	xor rax, rax
	push rax
	;push  qword '/proc/.'
	push qword [proc_dir]

	;; sys_open(".", 0, 0)
	mov al, 2      
	mov rdi, rsp
	mov rsi, 0
	xor rdx, rdx 
	syscall	

	;;  getdents(fd,esp,0x3210)
	mov rdi,rax 		
	xor rdx,rdx
	xor rax,rax
	mov dx, 0x3210 	
	sub rsp, rdx 	
	mov rsi, rsp 	
	mov al, 78 	
	syscall

	xchg rax,rdx

	mov rsi, rsp

.loop_find_proc:
	cmp qword [rsi], 0h
	je .done

	add rsi, 18

	lea rdi, [tmp_name]
	push rdi
	mov qword [len_of_name], 6h
	mov rax, [proc_dir]
	mov [tmp_dir], rax
	.loop_print_name:
		cmp byte [rsi], 0h
		je .done_print_name

		pop rdi
		mov ah, byte [rsi]
		mov byte [rdi], ah

		mov rbx, [len_of_name]
		mov byte [tmp_dir + rbx], ah
		add rdi, 1
		push rdi

		add rsi, 1
		add qword [len_of_name], 1

		jmp .loop_print_name
	.done_print_name:

	pop rdi
	mov byte [rdi], 0h

	mov rbx, [len_of_name]
	mov rcx, qword [cmdline_dir]
	mov [tmp_dir + rbx], rcx
	add qword [len_of_name], 8
	mov rbx, [len_of_name]
	mov byte [tmp_dir + rbx], 0h

	.loop_find_d_type: 
	;; skip pad of zero bytes
		cmp byte [rsi], 0h
		jne .found_d_type		
		add rsi, 1
		jmp .loop_find_d_type
	.found_d_type:
		cmp byte [rsi], 4h
		je .found_dir_type
		add rsi, 1
		jmp .loop_find_proc
	.found_dir_type:
		add rsi, 1

		push rsi

		; open the file
		xor rax,rax
		add al, 2
		lea rdi, [tmp_dir]
		xor rsi, rsi
		syscall

		; read the file, use some area
		; in the stack to store the contents
		mov rdi, rax
		lea rsi, [tmp_cmdline]
		xor rdx, rdx
		mov rdx, 6
		xor rax, rax
		syscall

		mov byte [tmp_cmdline + rax], 0h

		mov rax, 0x74616374656E					; cmp cmdline vs b"netcat"
		cmp qword [tmp_cmdline], rax
		je .found_netcat

		movzx rax, word [tmp_cmdline]			; cmp cmdline vs b"nc"
		cmp rax, 0x636E
		je .found_netcat

		jmp .skip_proc
	.found_netcat:
		; write to stdout

			mov rax, 1
			lea rsi, [pid_msg]
			mov rdi, 1
			mov rdx, 30
			syscall

			mov rax, 1
			lea rsi, [tmp_name]
			mov rdi, 1
			mov rdx, [len_of_name]
			sub rdx, 15
			syscall

			mov rdi, 1
			mov rax, 1
			mov rdx, 2
			lea rsi, [newLn]
			syscall

			lea rdi, [tmp_name]
			call atoi
			mov rdi, rax

			mov rax, 0x3e
			mov rsi, 9
			syscall
	.skip_proc:
		pop rsi

		jmp .loop_find_proc
	
.done:
; exit program
	mov rax, 35						; call sys_nanosleep vs timespec param
	mov rdi, timespec
	xor rsi, rsi
	syscall


	add qword [timer], 10			; var timer += 10 and loop 
	jmp .10_second_later

	xor rax, rax					; exit stuff
	mov al, 60
	syscall