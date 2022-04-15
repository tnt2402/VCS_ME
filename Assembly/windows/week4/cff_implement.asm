.386
.model flat, stdcall
option casemap :none

include C:\masm32\include\masm32rt.inc
; include C:\masm32\include\windows.inc 
; include C:\masm32\include\kernel32.inc 
; include C:\masm32\include\masm32.inc 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\masm32.lib 

.data
max_size EQU 17
newLn db " ", 0Ah, 0h
separator db "  | ", 0h
;FileName    db 'test2.exe',0     ; file to read
;FileName    db 'Utility.exe',0     ; file to read
;FileName    db 'wab.exe',0     ; file to read
;FileName    db 'test.dll',0     ; file to read
FileName     db 200 dup(?)
selection dw max_size dup(?)
selection_int dd 1
counter_int dd 0
exe_type dd 1           ; 0 for dll
                        ; 1 for exe
arch dd 1               ; 0 for 32bit
                        ; 1 for 64bit
size2Read dd 1
number_of_directories dd 1      ; number of data directories
dll_exe_possible_flag dd '2', '3', '6', '7', 'A', 'E', 'F'

fileName_msg db "File Directory: ", 0h

dll_msg         db 0Ah, "File Type: dll", 0Ah, 0h
exe_msg         db 0Ah, "File Type: exe", 0Ah, 0h
_32bit_msg      db "Architecture: 32bit", 0Ah, 0h
_64bit_msg      db "Architecture: 64bit", 0Ah, 0h
not_valid_exc   db 0Ah,"File Type: Unknown Type", 0h
valid_exc       db 0Ah,"File Type: Executable file", 0h
byte_msg        db "Byte  | ", 0h
word_msg        db "WORD  | ", 0h
dword_msg       db "DWORD | ", 0h 
qword_msg       db "QWORD | ", 0h

menu_msg db 0Ah,"MENU",0Ah, "1. Dos Header", 0Ah, "2. NT Header", 0Ah, "3. Section Header", 0Ah, "4. Import Directory", 0Ah, "5. Export Directory", 0Ah, "6. Exit", 0Ah, "Your selection: ", 0h

tmp_string db max_size dup(?), 0h
tmp_string2 db max_size dup(?), 0h
tmp_string3 db max_size dup(?), 0h
string_buf db max_size dup(?)
lpHexString	db "0123456789ABCDEF"
;; Dos Header
DH0 db 0Ah, "Dos Header", 0Ah, "Member     |  Offset    |  Size  | Value", 0Ah, 0h
e_magic   db "e_magic    |  00000000  |  WORD  | ", 0h
e_cblp    db "e_cblp     |  00000002  |  WORD  | ", 0h
e_cp      db "e_cp       |  00000004  |  WORD  | ", 0h
e_crlc    db "e_crlc     |  00000006  |  WORD  | ", 0h
e_cparhdr db "e_cparhdr  |  00000008  |  WORD  | ", 0h
e_minalloc db "e_minalloc |  0000000A  |  WORD  | ", 0h
e_maxalloc db "e_maxalloc |  0000000C  |  WORD  | ", 0h
e_ss      db "e_ss       |  0000000E  |  WORD  | ", 0h
e_sp      db "e_sp       |  00000010  |  WORD  | ", 0h
e_csum    db "e_csum     |  00000012  |  WORD  | ", 0h
e_ip      db "e_ip       |  00000014  |  WORD  | ", 0h
e_cs      db "e_cs       |  00000016  |  WORD  | ", 0h
e_lfarlc  db "e_lfarlc   |  00000018  |  WORD  | ", 0h
e_ovno    db "e_ovno     |  0000001A  |  WORD  | ", 0h
e_res     db "e_res      |  0000001C  |  WORD  | ", 0h
e_res_1   db "           |  0000001E  |  WORD  | ", 0h
e_res_2   db "           |  00000020  |  WORD  | ", 0h
e_res_3   db "           |  00000022  |  WORD  | ", 0h
e_oemid   db "e_oemid    |  00000024  |  WORD  | ", 0h
e_oeminfo db "e_oeminfo  |  00000026  |  WORD  | ", 0h
e_res2    db "e_res2     |  00000028  |  WORD  | ", 0h  
e_res2_1  db "           |  0000002A  |  WORD  | ", 0h  
e_res2_2  db "           |  0000002C  |  WORD  | ", 0h  
e_res2_3  db "           |  0000002E  |  WORD  | ", 0h  
e_res2_4  db "           |  00000030  |  WORD  | ", 0h  
e_res2_5  db "           |  00000032  |  WORD  | ", 0h  
e_res2_6  db "           |  00000034  |  WORD  | ", 0h  
e_res2_7  db "           |  00000036  |  WORD  | ", 0h  
e_res2_8  db "           |  00000038  |  WORD  | ", 0h  
e_res2_9  db "           |  0000003A  |  WORD  | ", 0h  
e_lfanew  db "e_lfanew   |  0000003C  |  DWORD | ", 0h

DH_msg dq offset e_magic,offset e_cblp,offset e_cp,offset e_crlc\
,offset e_cparhdr,offset e_minalloc,offset e_maxalloc,offset e_ss\
,offset e_sp,offset e_csum,offset e_ip,offset e_cs\
,offset e_lfarlc,offset e_ovno,offset e_res,offset e_res_1\
,offset e_res_2,offset e_res_3,offset e_oemid,offset e_oeminfo\
,offset e_res2,offset e_res2_1,offset e_res2_2,offset e_res2_3\
,offset e_res2_4,offset e_res2_5,offset e_res2_6,offset e_res2_7\
,offset e_res2_8,offset e_res2_9,offset e_lfanew
DH_members_size dd 30 dup (2h), 4


; Nt Header
Nt db 0Ah, "Nt Header", 0Ah, "Member     |  Size  |  Offset    | Value", 0Ah, "Signature  |  DWORD |  ", 0h
fileHeader          db "--> File Header", 0Ah, "    Member               |  Size  |  Offset   | Value", 0Ah, 0h
machine             db "    Machine              |  WORD  | ", 0h
numberOfSections    db "    NumberOfSections     |  WORD  | ", 0h
timeDateStamp       db "    TimeDateStamp        |  DWORD | ", 0h
pointer2SymbolTable db "    PointerToSymbolTable |  DWORD | ", 0h
numberOfSymbols     db "    NumberOfSymbols      |  DWORD | ", 0h
sizeOptionalHeader  db "    SizeOfOptionalHeader |  WORD  | ", 0h
characteristics     db "    Characteristics      |  WORD  | ", 0h
fileHeader_msg dq offset machine, offset numberOfSections,\
offset timeDateStamp, offset pointer2SymbolTable, offset numberOfSymbols,\
offset sizeOptionalHeader, offset characteristics
fileHeader_members_size dd 2h, 2h, 4h, 4h, 4h, 2h, 2h


;; Optional Header
Opt db 0Ah, "Optional Header (Image Only)", 0Ah,\
                           "Member                  |  Size  | Offset    | Value", 0Ah, 0h
;; Optional Header Standard Fields
magic                   db "Magic                   |  WORD  | ", 0h
majorLinkerVersion      db "MajorLinkerVersion      |  Byte  | ", 0h
minorLinkerVersion      db "MinorLinkerVersion      |  Byte  | ", 0h
sizeOfCode              db "SizeOfCode              |  DWORD | ", 0h
sizeOfInitializedData   db "SizeOfInitializedData   |  DWORD | ", 0h
sizeOfUninitializedData db "SizeOfUninitializedData |  DWORD | ", 0h
addressOfEntryPoint     db "AddressOfEntryPoint     |  DWORD | ", 0h
baseOfCode              db "BaseOfCode              |  DWORD | ", 0h
baseOfData              db "BaseOfData              |  DWORD | ", 0h
;;Optional Header Windows-Specified Fields
imageBase               db "ImageBase               |  ", 0h
sectionAlignment        db "SectionAlignment        |  ", 0h
fileAlignment           db "FileAlignment           |  ", 0h
majorOSVer              db "MajorOSVersion          |  ", 0h
minorOSVer              db "MinorOsVersion          |  ", 0h
majorImageVersion       db "MajorImageVersion       |  ", 0h
minorImageVersion       db "MinorImageVersion       |  ", 0h
majorSubSystemVersion   db "MajorSubSystemVersion   |  ", 0h
minorSubSystemVersion   db "MinorSubSystemVersion   |  ", 0h
win32VersionBlue        db "Win32VersionBlue        |  ", 0h
sizeOfImage             db "SizeOfImage             |  ", 0h
sizeOfHeaders           db "SizeOfHeaders           |  ", 0h
checkSum                db "CheckSum                |  ", 0h
subSystem               db "SubSystem               |  ", 0h
dllCharacteristics      db "DllCharacteristics      |  ", 0h
sizeOfStackReverse      db "SizeOfStackReverse      |  ", 0h
sizeOfStackCommit       db "SizeOfStackCommit       |  ", 0h
sizeOfHeapReverse       db "SizeOfHeapReverse       |  ", 0h
sizeOfHeapCommit        db "SizeOfHeapCommit        |  ", 0h
loaderFlags             db "LoaderFlags             |  ", 0h
numberOfRvaAndSizes     db "NumberOfRvaAndSizes     |  ", 0h
;; Data directories Fields
dataDir                 db "----> Data Directories", 0Ah,\
                           "    Member                                  |  Size   |  Offset    | Value  ", 0Ah, 0h
ex_RVA                  db "    ExportDirectory RVA                     |  DWORD  |  ", 0h
ex_size                 db "    ExportDirectory Size                    |  DWORD  |  ", 0h
im_RVA                  db "    ImportDirectory RVA                     |  DWORD  |  ", 0h
im_size                 db "    ImportDirectory Size                    |  DWORD  |  ", 0h
rsc_RVA                 db "    ResourceDirectory RVA                   |  DWORD  |  ", 0h
rsc_size                db "    ResourceDirectory Size                  |  DWORD  |  ", 0h
excep_RVA               db "    ExceptionDirectory RVA                  |  DWORD  |  ", 0h
excep_size              db "    ExceptionDirectory Size                 |  DWORD  |  ", 0h
sec_RVA                 db "    SecurityDirectory RVA                   |  DWORD  |  ", 0h
sec_size                db "    SecurityDirectory Size                  |  DWORD  |  ", 0h
relo_RVA                db "    RelocationDirectory RVA                 |  DWORD  |  ", 0h
relo_size               db "    RelocationDirectory Size                |  DWORD  |  ", 0h
dbg_RVA                 db "    DebugDirectory RVA                      |  DWORD  |  ", 0h
dbg_size                db "    DebugDirectory Size                     |  DWORD  |  ", 0h  
arch_RVA                db "    Architecture Directory RVA              |  DWORD  |  ", 0h
arch_size               db "    Architecture Directory Size             |  DWORD  |  ", 0h
reserved                db "    Reserved                                |  DWORD  |  ", 0h
tls_RVA                 db "    TLS Directory RVA                       |  DWORD  |  ", 0h
tls_size                db "    TLS Directory Size                      |  DWORD  |  ", 0h
cfg_RVA                 db "    Configuration Directory RVA             |  DWORD  |  ", 0h
cfg_size                db "    Configuration Directory Size            |  DWORD  |  ", 0h
boundim_RVA             db "    Bound Import Directory RVA              |  DWORD  |  ", 0h
boundim_size            db "    Bound Import Directory Size             |  DWORD  |  ", 0h
iat_RVA                 db "    Import Address Table Directory RVA      |  DWORD  |  ", 0h
iat_size                db "    Import Address Table Directory Size     |  DWORD  |  ", 0h
delay_RVA               db "    Delay Import Directory RVA              |  DWORD  |  ", 0h
delay_size              db "    Delay Import Directory Size             |  DWORD  |  ", 0h
comNet_RVA              db "    .NET MetaData Directory RVA             |  DWORD  |  ", 0h
comNet_size             db "    .NET MetaData Directory Size            |  DWORD  |  ", 0h

;; msg for Optional Header 32bit
opt_header_msg_32 dq offset magic, offset majorLinkerVersion, offset minorLinkerVersion,\
offset sizeOfCode, offset sizeOfInitializedData, offset sizeOfUninitializedData,\
offset addressOfEntryPoint, offset baseOfCode, offset baseOfData
optHeader_members_size_32 dd 2, 1, 1, 6 dup (4)

;; msg for Optional Header 64bit (No baseofData)
opt_header_msg_64 dq offset magic, offset majorLinkerVersion, offset minorLinkerVersion,\
offset sizeOfCode, offset sizeOfInitializedData, offset sizeOfUninitializedData,\
offset addressOfEntryPoint, offset baseOfCode
optHeader_members_size_64 dd 2, 1, 1, 5 dup (4)

;; msg for Optional Header Windows-Specific Fields 
opt_win_spec_msg dq offset imageBase,offset sectionAlignment,offset fileAlignment,\
offset majorOSVer,offset minorOSVer,offset majorImageVersion,offset minorImageVersion,\
offset majorSubSystemVersion,offset minorSubSystemVersion,offset win32VersionBlue,offset sizeOfImage,\
offset sizeOfHeaders,offset checkSum,offset subSystem,offset dllCharacteristics,offset sizeOfStackReverse,\
offset sizeOfStackCommit,offset sizeOfHeapReverse,offset sizeOfHeapCommit,offset loaderFlags,offset numberOfRvaAndSizes
;; size arrays for Optional Header Windows-Specific Fields
optHeader_win_spec_members_size_32 dd 3 dup (4), 6 dup (2), 4 dup (4), 2 dup (2), 6 dup (4)
optHeader_win_spec_members_size_64 dd 8, 2 dup (4), 6 dup (2), 4 dup (4), 2 dup (2), 4 dup (8), 2 dup (4)
;; msg for Optional Header - Data Directories 
data_msg dq offset ex_RVA,offset ex_size,offset im_RVA,offset im_size,\
offset rsc_RVA,offset rsc_size,offset excep_RVA,offset excep_size,offset sec_RVA,\
offset sec_size,offset relo_RVA,offset relo_size,offset dbg_RVA,\
offset dbg_size,offset arch_RVA,offset arch_size,2 dup (offset reserved),offset tls_RVA,offset tls_size,\
offset cfg_RVA,offset cfg_size,offset boundim_RVA,offset boundim_size,offset iat_RVA,\
offset iat_size,offset delay_RVA,offset delay_size,offset comNet_RVA,offset comNet_size 


;; Section Header 
sectionHeader       db 0Ah, "SECTION HEADER", 0Ah, 0h
virtualSize         db "    Virtual Size        |  DWORD  | ", 0h
virtualAddress      db "    Virtual Address     |  DWORD  | ", 0h
rawSize             db "    Raw Size            |  DWORD  | ", 0h
rawAddress          db "    Raw Address         |  DWORD  | ", 0h
relocAddress        db "    Reloc Address       |  DWORD  | ", 0h
linenumbers         db "    Linenumbers         |  DWORD  | ", 0h
relocNumbers        db "    Relocation Numbers  |  WORD   | ", 0h
linenumbersNumber   db "    Linenumbers Number  |  WORD   | ", 0h
characteristics_2   db "    Characteristics     |  DWORD  | ", 0h
; msg for Section Header
sectionHeader_msg   dq offset virtualAddress, offset virtualSize, offset rawSize,\
offset rawAddress, offset relocAddress, offset linenumbers, offset relocNumbers,\
offset linenumbersNumber, offset characteristics_2
; size of Section header's members 
sectionHeader_members_size dd 6 dup (4), 2 dup (2), 4 
virtAddr_array dd 20 dup (?)
rawAddr_array dd 20 dup (?)

;; Import Directory message
impDir_msg          db 0Ah, "[+] Import Directory", 0Ah, \
                            "Module Name   | Imports   | OFTs      | TimeDateStamp | ForwarderChain | Name RVA | FTs (IAR) ", 0Ah, 0h

;; Export Directory message
expDir_header       db 0Ah, "[+] Export Directory", 0Ah, \
                           "Member                  |  Size  | Offset    | Value", 0Ah, 0h
expDir_msg_1        db     "Characteristics         |  DWORD | ", 0h
expDir_msg_2        db     "TimeDateStamp           |  DWORD | ", 0h
expDir_msg_3        db     "MajorVersion            |  WORD  | ", 0h
expDir_msg_4        db     "MinorVersion            |  WORD  | ", 0h
expDir_msg_5        db     "Name                    |  DWORD | ", 0h
expDir_msg_6        db     "Base                    |  DWORD | ", 0h
expDir_msg_7        db     "NumberOfFunctions       |  DWORD | ", 0h
expDir_msg_8        db     "NumberOfNames           |  DWORD | ", 0h
expDir_msg_9        db     "AddressOfFunctions      |  DWORD | ", 0h
expDir_msg_10       db     "AddressOfNames          |  DWORD | ", 0h
expDir_msg_11       db     "AddressOfNameOrdinals   |  DWORD | ", 0h

expDir_msg dq offset expDir_msg_1, offset expDir_msg_2, offset expDir_msg_3, offset expDir_msg_4, \
offset expDir_msg_5, offset expDir_msg_6, offset expDir_msg_7, offset expDir_msg_8, \
offset expDir_msg_9, offset expDir_msg_10, offset expDir_msg_11

expDir_member_size dd 4, 4, 2, 2, 4, 4, 4, 4, 4, 4, 4

not_found_msg db 0Ah, "Not Found", 0Ah, 0h
buffer dw 150h dup (?)
BytesBuffer dd 4
singleByte db 2
cur_offset dd 1
Nt_offset dd 1
numberOfSections_int dd 1
numberOfImportedDlls_int dd 1
offsetOfImportDirRVA dd 1
offsetOfExportDirRVA dd 1

.data?

hFile       dd ?
Filesize    dd ?
hMem        dd ?
BytesRead   db ?
.code

    ;; Input: eax - number to convert
    ;;        edi - pointer to buffer
    ;; Output: hex number in buffer
	Dec2Hex proc
        mov ecx, 8
    @digit_loop:
        rol eax, 4
        mov edx, eax
        and edx, 0Fh
        movzx edx, byte ptr [lpHexString + edx]
        mov [edi], dl
        inc edi

        dec ecx
        jnz @digit_loop
        mov byte ptr [edi], 0h
        ret
	Dec2Hex endp

    ;; Input: edi - pointer to string
    ;;        ecx - number of bytes to print
    ;; Output: StdOut
    print_string proc
        push ecx
        call Dec2Hex
        pop ecx
        mov edi, offset tmp_string
        add ecx, ecx
        mov eax, 8
        sub eax, ecx
        add edi, eax
        mov esi, offset string_buf
        Li:
            mov ah, byte ptr [edi]
            mov byte ptr [esi], ah
            cmp ecx, 1h
            je @done
            inc edi
            inc esi
            dec ecx
            jmp Li
        @done:
            inc esi
            mov byte ptr [esi], 0h
            push offset string_buf
            call StdOut
            ret
    print_string endp



    DosHeader_print proc
        push ebp
        mov ebp, esp

        push offset newLn
        call StdOut

        invoke  CreateFile,ADDR FileName,GENERIC_READ,0,0,\
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0   
        mov     hFile,eax
        push offset DH0
        call StdOut
        mov esi, -1
        push esi
        Li:
        pop esi
        cmp esi, 30
        je @done
        inc esi
        push esi
        lea edi, [DH_msg]
        mov eax, [edi + esi*8]
        push eax
        call StdOut

        mov eax, dword ptr [DH_members_size + esi*4]
        invoke  ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0
        mov edi, offset tmp_string
        mov eax, dword ptr [BytesBuffer]
        mov ecx, dword ptr [DH_members_size + esi*4]
        call print_string
        push offset newLn
        call StdOut
        jmp Li
    @done:
        invoke CloseHandle, hFile
        mov esp, ebp
        pop ebp
        ret
    DosHeader_print endp

    optionalHeader_print proc
            add [cur_offset], 2h
            push offset Opt
            call StdOut

            cmp byte ptr [arch], 0h
            je optionalHeader_print_32
            cmp byte ptr [arch], 1h
            je optionalHeader_print_64
        optionalHeader_print_32:
            xor esi, esi
            push esi
        @opt_Li_32:
            lea edi, [opt_header_msg_32]
            mov eax, [edi + esi*8]
            push eax
            call StdOut

            mov edi, offset tmp_string
            mov eax, [cur_offset]
            call Dec2Hex
            invoke StdOut, offset tmp_string
            invoke StdOut, offset separator

            mov eax, dword ptr [optHeader_members_size_32 + esi*4]
            mov ebx, [cur_offset]
            add ebx, eax
            mov [cur_offset], ebx
            invoke ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0

            mov edi, offset tmp_string
            mov eax, dword ptr [BytesBuffer]
            call Dec2Hex

            lea edi, [optHeader_members_size_32]
            mov ecx, dword ptr [edi + esi*4]
            mov edi, offset tmp_string
            call print_string

            push offset newLn
            call StdOut
            pop esi
            cmp esi, 8h
            je optionalHeader_win_spec_print_32
            inc esi 
            push esi 
            jmp @opt_Li_32
        optionalHeader_win_spec_print_32:
            xor esi, esi
            push esi
        @opt_win_spec_Li_32:
            lea edi, [opt_win_spec_msg]
            mov eax, [edi + esi*8]
            push eax
            call StdOut

            cmp byte ptr [optHeader_win_spec_members_size_32 + esi*4], 2h
            je print_word_msg
            cmp byte ptr [optHeader_win_spec_members_size_32 + esi*4], 4h
            je print_dword_msg
            cmp byte ptr [optHeader_win_spec_members_size_32 + esi*4], 8h
            je print_qword_msg
            print_word_msg:
                push offset word_msg
                call StdOut
                jmp continue
            print_dword_msg:
                push offset dword_msg
                call StdOut
                jmp continue
            print_qword_msg:
                push offset qword_msg
                call StdOut
                jmp continue
            continue:
            mov edi, offset tmp_string
            mov eax, [cur_offset]
            call Dec2Hex
            invoke StdOut, offset tmp_string
            invoke StdOut, offset separator

            mov eax, dword ptr [optHeader_win_spec_members_size_32 + esi*4]
            mov ebx, [cur_offset]
            add ebx, eax
            mov [cur_offset], ebx
            invoke ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0

            mov edi, offset tmp_string
            mov eax, dword ptr [BytesBuffer]
            call Dec2Hex

            lea edi, [optHeader_win_spec_members_size_32]
            mov ecx, dword ptr [edi + esi*4]
            mov edi, offset tmp_string
            call print_string

            push offset newLn
            call StdOut
            pop esi
            cmp esi, 14h
            je data_directories_print
            inc esi 
            push esi 
            jmp @opt_win_spec_Li_32
        optionalHeader_print_64:
            xor esi, esi
            push esi
        @opt_Li_64:
            lea edi, [opt_header_msg_64]
            mov eax, [edi + esi*8]
            push eax
            call StdOut

            mov edi, offset tmp_string
            mov eax, [cur_offset]
            call Dec2Hex
            invoke StdOut, offset tmp_string
            invoke StdOut, offset separator

            mov eax, dword ptr [optHeader_members_size_64 + esi*4]
            mov ebx, [cur_offset]
            add ebx, eax
            mov [cur_offset], ebx
            invoke ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0

            mov edi, offset tmp_string
            mov eax, dword ptr [BytesBuffer]
            call Dec2Hex

            lea edi, [optHeader_members_size_64]
            mov ecx, dword ptr [edi + esi*4]
            mov edi, offset tmp_string
            call print_string

            push offset newLn
            call StdOut
            pop esi
            cmp esi, 7h
            je optionalHeader_win_spec_print_64
            inc esi 
            push esi 
            jmp @opt_Li_64
        optionalHeader_win_spec_print_64:
            xor esi, esi
            push esi
        @opt_win_spec_Li_64:
            lea edi, [opt_win_spec_msg]
            mov eax, [edi + esi*8]
            push eax
            call StdOut

            cmp byte ptr [optHeader_win_spec_members_size_64 + esi*4], 2h
            je print_word_msg_64
            cmp byte ptr [optHeader_win_spec_members_size_64 + esi*4], 4h
            je print_dword_msg_64
            cmp byte ptr [optHeader_win_spec_members_size_64 + esi*4], 8h
            je print_qword_msg_64
            print_word_msg_64:
                push offset word_msg
                call StdOut
                jmp continue_64
            print_dword_msg_64:
                push offset dword_msg
                call StdOut
                jmp continue_64
            print_qword_msg_64:
                push offset qword_msg
                call StdOut
                jmp continue_64
            continue_64:
            mov edi, offset tmp_string
            mov eax, [cur_offset]
            call Dec2Hex
            invoke StdOut, offset tmp_string
            invoke StdOut, offset separator

            mov eax, dword ptr [optHeader_win_spec_members_size_64 + esi*4]
            mov ebx, [cur_offset]
            add ebx, eax
            mov [cur_offset], ebx
            cmp eax, 8h
            je print_value_qword
            invoke ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0
            mov edi, offset tmp_string
            mov eax, dword ptr [BytesBuffer]
            call Dec2Hex

            mov ecx, dword ptr [optHeader_win_spec_members_size_64 + esi*4]
            mov edi, offset tmp_string
            call print_string
            jmp continue_qword
            print_value_qword:  
                invoke ReadFile,hFile,addr BytesBuffer,4,addr BytesRead,0
                mov edi, offset tmp_string3
                mov eax, dword ptr [BytesBuffer]
                call Dec2Hex
                
                invoke ReadFile,hFile,addr BytesBuffer,4,addr BytesRead,0
                mov edi, offset tmp_string2
                mov eax, dword ptr [BytesBuffer]
                call Dec2Hex
                invoke StdOut, offset tmp_string2
                invoke StdOut, offset tmp_string3

            continue_qword:
            push offset newLn
            call StdOut
            pop esi
            cmp esi, 14h
            je data_directories_print
            inc esi 
            push esi 
            jmp @opt_win_spec_Li_64
        data_directories_print:
            invoke StdOut, offset dataDir                       ; set number_of_directories = value of NumberOfRvaAndSizes * 2 - 2
            mov eax, dword ptr [BytesBuffer]
            lea eax, [eax + eax]
            sub eax, 3
            mov [number_of_directories], eax
            xor esi, esi
            push esi
        @data_dir_Li:
            lea edi, [data_msg]
            mov eax, [edi + esi*8]
            push eax
            call StdOut

            mov edi, offset tmp_string
            mov eax, [cur_offset]
            call Dec2Hex
            invoke StdOut, offset tmp_string
            invoke StdOut, offset separator

            mov eax, 4
            mov ebx, [cur_offset]
            add ebx, eax
            mov [cur_offset], ebx
            invoke ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0

            mov edi, offset tmp_string
            mov eax, dword ptr [BytesBuffer]
            call Dec2Hex

            mov ecx, 4
            mov edi, offset tmp_string
            call print_string

            push offset newLn
            call StdOut
            pop esi
            cmp esi, dword ptr [number_of_directories]
            je @done
            inc esi 
            push esi 
            jmp @data_dir_Li
        @done:
            invoke CloseHandle, hFile
            mov esp, ebp
            pop ebp
            ret
        optionalHeader_print endp
    NtHeader_print proc
        push ebp
        mov ebp, esp
        invoke  CreateFile,ADDR FileName,GENERIC_READ,0,0,\
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0   
        mov     hFile,eax
        ;; Print Nt Header
        push offset newLn
        call StdOut
        push offset Nt
        call StdOut
        ;invoke ReadFile,hFile,addr buffer,3Ch,addr BytesRead,0
        invoke SetFilePointer,hFile, 3Ch, 0, FILE_BEGIN
        invoke ReadFile,hFile, addr BytesBuffer, 2, addr BytesRead, 0
        
        mov edi, offset tmp_string
        mov eax, dword ptr [BytesBuffer]
        call Dec2Hex
        invoke StdOut, offset tmp_string
        mov esi, dword ptr [BytesBuffer]
        add esi, 2
        mov [cur_offset], esi
        mov [Nt_offset], esi
        invoke StdOut, offset separator

        mov eax, dword ptr [BytesBuffer]
        sub eax, 3Eh
        ;invoke ReadFile,hFile,addr buffer,eax,addr BytesRead,0
        invoke SetFilePointer, hFile, eax, 0, FILE_CURRENT

        invoke ReadFile,hFile,addr BytesBuffer, 4,addr BytesRead,0
        mov edi, offset tmp_string
        mov eax, dword ptr [BytesBuffer]
        mov ecx, 4
        push esi
        call print_string
        pop esi

        push offset newLn
        call StdOut

        ;; Print File Header
        xor esi, esi
        
        push offset fileHeader
        call StdOut
        push esi
        Li:
        lea edi, [fileHeader_msg]
        mov eax, [edi + esi*8]
        push eax
        call StdOut

        lea edi, [fileHeader_members_size]
        mov eax, dword ptr [edi + esi*4]
        mov ebx, [cur_offset]
        add ebx, eax
        mov [cur_offset], ebx
        invoke ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0

        mov edi, offset tmp_string
        mov eax, [cur_offset]
        call Dec2Hex
        invoke StdOut, offset tmp_string
        invoke StdOut, offset separator

        mov edi, offset tmp_string
        mov eax, dword ptr [BytesBuffer]
        pop esi
        mov ecx, dword ptr [fileHeader_members_size + esi*4]
        push esi
        call print_string

        push offset newLn
        call StdOut
        pop esi
        cmp esi, 6h
        je optionalHeader_print
        inc esi 
        push esi 
        jmp Li

    NtHeader_print endp

    print_nameMemberOfSectionHeader proc
        push offset newLn
        call StdOut

        xor esi, esi
    Li:
        cmp esi, 8
        je @done
        invoke ReadFile,hFile,addr singleByte, 1,addr BytesRead,0
        mov edi, offset tmp_string
        mov ah, byte ptr [singleByte]
        mov byte ptr [edi], ah
        inc edi
        mov byte ptr [edi], 0h
        push offset tmp_string
        call StdOut
        inc esi
        jmp Li
    @done:

        ret
    print_nameMemberOfSectionHeader endp

    print_eachMemberOfSectionHeader proc
    xor edx, edx
    push edx
    @loop:
        pop edx
        cmp edx, dword ptr [numberOfSections_int]
        je @done_section_header
        inc edx
        push edx
        call print_nameMemberOfSectionHeader
        ;;print each member of Section Header
            xor esi, esi
            push esi
        @Li_print_:

            push offset newLn
            call StdOut

            mov eax, dword ptr [sectionHeader_msg + esi * 8]
            push eax
            call StdOut

            mov eax, dword ptr [sectionHeader_members_size + esi * 4]
            mov ebx, [cur_offset]
            add ebx, eax
            mov [cur_offset], ebx
            invoke ReadFile,hFile,addr BytesBuffer,eax,addr BytesRead,0

            mov eax, dword ptr [BytesBuffer]
            mov ecx, dword ptr [sectionHeader_members_size + esi*4]
            mov edi, offset tmp_string
            call print_string

            pop esi
            cmp esi, 8h
            je @loop
            inc esi 
            push esi 
            jmp @Li_print_
        @done_section_header:
        ret
    print_eachMemberOfSectionHeader endp

    SectionHeader_print proc
        push ebp
        mov ebp, esp
        invoke  CreateFile,ADDR FileName,GENERIC_READ,0,0,\
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0   
        mov     hFile,eax
        ;; Print Nt Header
        push offset newLn

        mov eax, dword ptr [Nt_offset]
        add eax, 4

        ; mov eax, dword ptr [Nt_offset]
        ; mov ecx, 4
        ; mov edi, offset tmp_string
        ; call print_string

        invoke ReadFile, hFile, addr buffer, eax, addr BytesRead,0
        invoke ReadFile, hFile, addr BytesBuffer, 2, addr BytesRead, 0
        mov ebx, dword ptr [BytesBuffer]
        mov [numberOfSections_int], ebx

        cmp [arch], 0
        je SectionHeader_offset_32
        add eax, 255
        jmp cont
        SectionHeader_offset_32:
            add eax, 239
        cont:
        invoke ReadFile,hFile,addr buffer,eax,addr BytesRead,0
        
        ;;print Section Header msg
        push offset sectionHeader
        call StdOut

        call print_eachMemberOfSectionHeader
        invoke CloseHandle, hFile
        mov esp, ebp
        pop ebp
        ret
    SectionHeader_print endp

    file_information proc
        push ebp
        mov ebp, esp

        push offset FileName
        call StdOut

        invoke  CreateFile,ADDR FileName,GENERIC_READ,0,0,\
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0   
        mov     hFile,eax
        invoke  ReadFile,hFile,addr BytesBuffer,2,addr BytesRead,0
        mov eax, dword ptr [BytesBuffer]
        cmp eax, 5A4Dh
        je @valid_excutable
        jmp @not_valid_excutable
    @valid_excutable:
        invoke SetFilePointer, hFile, 3Ah, 0, FILE_CURRENT
        invoke ReadFile,hFile, addr BytesBuffer, 2, addr BytesRead, 0

        mov esi, dword ptr [BytesBuffer]
        add esi, 2
        mov [cur_offset], esi
        mov [Nt_offset], esi
        sub esi, 2Ah
        invoke SetFilePointer, hFile, esi, 0, FILE_CURRENT
        invoke ReadFile,hFile, addr BytesBuffer, 2, addr BytesRead, 0
        mov edi, offset tmp_string
        movzx eax, word ptr [BytesBuffer]
        call Dec2Hex

        lea edi, [tmp_string]
        add edi, 5
        xor ecx, ecx
        Li:
            mov bh, byte ptr [edi]
            cmp bh, byte ptr [dll_exe_possible_flag + ecx * 4]
            je @is_dll
            inc ecx
            cmp ecx, 7
            jne Li
            xor ecx, ecx
            add edi, 2
        Li2:
            mov bh, byte ptr [edi]
            cmp bh, byte ptr [dll_exe_possible_flag + ecx * 4]
            je @is_exe
            inc ecx
            cmp ecx, 7
            jne Li2
            jmp @not_valid_excutable
        @is_dll:
            mov [exe_type], 0h
            push offset dll_msg
            call StdOut
            jmp @check_arch
        @is_exe:
            mov [exe_type], 1h
            push offset exe_msg
            call StdOut
            jmp @check_arch
    @check_arch:
        invoke ReadFile,hFile, addr BytesBuffer, 2, addr BytesRead, 0
        mov eax, dword ptr [BytesBuffer]
        cmp eax, 10Bh
        je @is_32bit
        cmp eax, 20Bh
        je @is_64bit
        jmp @not_valid_excutable
    @is_32bit:
        mov [arch], 0h
        push offset _32bit_msg
        call StdOut
        jmp @done_information
    @is_64bit:
        mov [arch], 1h
        push offset _64bit_msg
        call StdOut
        jmp @done_information
    @not_valid_excutable:
        invoke StdOut, offset not_valid_exc
        invoke StdOut, offset newLn
        jmp @done_information
    @done_information:
        invoke CloseHandle, hFile
        mov esp, ebp
        pop ebp
        ret
    file_information endp
    ;;  Input:  eax - integer
    ;;          esi - pointer to result buffer
    ;;  Output: in buffer
    itoa proc 
        add esi, max_size       ; point to the last of result buffer
        mov byte ptr [esi], 0h      ; set the last byte of result buffser to null
        mov ebx, 10             ; ebx = 10
        cmp eax, 0h
        jge @loop_positive
        neg eax
    @loop_negative:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov byte ptr [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz @loop_negative      ; if not -> loop
        mov dl, 2Dh        ; 
        dec esi
        mov byte ptr [esi], dl           ; mov '-' to the current byte
        jmp @done
    @loop_positive:
        xor edx, edx            ; edx = 0
        div ebx                 ; ebx = divisor
        add dl, '0'             ; dl - remainder
        dec esi                 ; point to the next left byte 
        mov byte ptr [esi], dl           ; mov remainder to the current byte
        test eax, eax           ; if (eax == 0) ?
        jnz @loop_positive      ; if not -> loop
        jmp @done
    @done:
        mov eax, esi            ; else return result to eax
        ret     
    itoa endp

    ;; Input:       ebx - RVA offset
    ;; Output:      ebx - raw offset
    convert_RVA_to_raw_offset proc
        xor edx, edx
        @loop_find_section:
        cmp ebx, dword ptr [virtAddr_array + edx * 4]
        jl @found_section
        inc edx
        cmp edx, dword ptr [numberOfSections_int]
        je @found_section 
        jmp @loop_find_section
    @found_section:
        dec edx
        sub ebx, dword ptr [virtAddr_array + edx * 4]
        add ebx, dword ptr [rawAddr_array + edx * 4]
        ret
    convert_RVA_to_raw_offset endp

    printNameOfEachMember proc
        push ebp
        mov ebp, esp
        push offset newLn
        call StdOut
    Li:
        invoke ReadFile,hFile,addr singleByte, 1,addr BytesRead,0
        mov edi, offset tmp_string
        mov ah, byte ptr [singleByte]
        cmp ah, 0
        je @done
        mov byte ptr [edi], ah
        inc edi
        mov byte ptr [edi], 0h
        push offset tmp_string
        call StdOut
        jmp Li
    @done:
        mov esp, ebp
        pop ebp
        ret
    printNameOfEachMember endp

    print_eachModuleInImportDir proc
        push ebp
        mov ebp, esp

        mov eax, dword ptr [offsetOfImportDirRVA]
        add eax, 0Ch
        invoke SetFilePointer, hFile, eax, 0, FILE_BEGIN
        ; get Name RVA of each module
        invoke ReadFile, hFile, addr BytesBuffer, 2, addr BytesRead, 0
        movzx ebx, word ptr [BytesBuffer]
        call convert_RVA_to_raw_offset
        ; put file pointer at Name raw_offset then print each char of Name
        invoke SetFilePointer, hFile, ebx, 0, FILE_BEGIN
        mov ebx, 0Ch
        call printNameOfEachMember

        push offset separator
        call StdOut

        mov eax, dword ptr [offsetOfImportDirRVA]
        invoke SetFilePointer, hFile, eax, 0, FILE_BEGIN
        ; get Name RVA of each module
        invoke ReadFile, hFile, addr BytesBuffer, 2, addr BytesRead, 0
        movzx ebx, word ptr [BytesBuffer]
        call convert_RVA_to_raw_offset
        ; put file pointer at Name raw_offset then print each char of Name
        invoke SetFilePointer, hFile, ebx, 0, FILE_BEGIN
        xor esi, esi
        cmp dword ptr [arch], 0h
        je @dword_size_each_dll
        mov dword ptr [size2Read], 4h
        jmp @find_number_of_functions
    @dword_size_each_dll:
        mov dword ptr [size2Read], 2h
        jmp @find_number_of_functions
    @find_number_of_functions:
        invoke ReadFile, hFile, addr BytesBuffer, dword ptr [size2Read], addr BytesRead, 0
        mov ecx, dword ptr [BytesBuffer]
        cmp ecx, 0h
        je @found_number_of_functions
        inc esi
        invoke ReadFile, hFile, addr BytesBuffer, dword ptr [size2Read], addr BytesRead, 0
        jmp @find_number_of_functions
    @found_number_of_functions:
        mov eax, esi
        mov esi, offset tmp_string
        call itoa
        push eax
        call StdOut
        invoke SetFilePointer, hFile, dword ptr [offsetOfImportDirRVA], 0, FILE_BEGIN
        xor esi, esi
        push esi
    @print_theother:
        push offset separator
        call StdOut
        invoke ReadFile, hFile, addr BytesBuffer, 4, addr BytesRead, 0
        movzx eax, word ptr [BytesBuffer]
        mov ecx, 4
        mov edi, offset tmp_string
        call print_string
        pop esi
        cmp esi, 4
        je @done_printEachModule
        inc esi
        push esi
        jmp @print_theother
    @done_printEachModule:
        mov esp, ebp
        pop ebp
        ret
    print_eachModuleInImportDir endp

    importDir_print proc
        push ebp
        mov ebp, esp
        invoke  CreateFile,ADDR FileName,GENERIC_READ,0,0,\
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0   
        mov     hFile,eax
        ;; Print Nt Header
        push offset newLn

        mov eax, dword ptr [Nt_offset]
        add eax, 4

        ;invoke ReadFile, hFile, addr buffer, eax, addr BytesRead,0
        invoke SetFilePointer, hFile, eax, 0, FILE_BEGIN
        invoke ReadFile, hFile, addr BytesBuffer, 2, addr BytesRead, 0
        mov ebx, dword ptr [BytesBuffer]
        mov [numberOfSections_int], ebx

        cmp [arch], 0
        je SectionHeader_offset_32
        add eax, 255
        jmp cont
        SectionHeader_offset_32:
            add eax, 239
        cont:
        ;invoke ReadFile,hFile,addr buffer,eax,addr BytesRead,0
        add eax, 12
        invoke SetFilePointer, hFile, eax, 0, FILE_CURRENT

        mov esi, 1
        push esi
        lo:
        pop esi
        cmp esi, dword ptr [numberOfSections_int]
        je @count_number_of_dlls
        push esi
        invoke ReadFile,hFile,addr BytesBuffer,4,addr BytesRead,0
        mov eax, dword ptr [BytesBuffer]
        pop esi
        mov [virtAddr_array + esi * 4], eax
        push esi

        invoke SetFilePointer, hFile, 4, 0, FILE_CURRENT
        invoke ReadFile,hFile, addr BytesBuffer, 4, addr BytesRead, 0
        mov eax, dword ptr [BytesBuffer]
        pop esi
        mov [rawAddr_array + esi * 4], eax
        push esi

        pop esi
        inc esi
        push esi
        invoke SetFilePointer, hFile, 28, 0, FILE_CURRENT
        jmp lo
    @count_number_of_dlls:
        mov eax, dword ptr [Nt_offset]
        cmp byte ptr [arch], 0h
        je @move_2_Import_Dir_RVA_32
        add eax, 8eh
        jmp @get_Import_Dir_RVA
    @move_2_Import_Dir_RVA_32:
        add eax, 7Eh
        jmp @get_Import_Dir_RVA
    @get_Import_Dir_RVA:
        invoke SetFilePointer, hFile, eax, 0, FILE_BEGIN
        invoke ReadFile, hFile, addr BytesBuffer, 2, addr BytesRead, 0
        movzx ebx, word ptr [BytesBuffer]
        call convert_RVA_to_raw_offset
        mov dword ptr [offsetOfImportDirRVA], ebx
        invoke SetFilePointer, hFile, ebx, 0, FILE_BEGIN
        xor ebx, ebx
        xor esi, esi
        xor edi, edi
        push esi
        lo_:
            invoke ReadFile,hFile, addr BytesBuffer, 4h, addr BytesRead, 0

            add ebx, dword ptr [BytesBuffer]
            pop esi
            add esi, 4h
            cmp esi, 14h
            je @check_if_dll
            push esi
            jmp lo_
        @check_if_dll:
            cmp ebx, 0h
            je @found_last_import_dll
            inc edi
            xor ebx, ebx
            pop esi
            xor esi, esi
            push esi
            jmp lo_

        @found_last_import_dll:
            mov dword ptr [numberOfImportedDlls_int], edi
            push offset impDir_msg
            call StdOut
            mov edi, 1
            push edi
        @print_modules:
            call print_eachModuleInImportDir
            add dword ptr [offsetOfImportDirRVA], 14h
            pop edi
            cmp edi, dword ptr [numberOfImportedDlls_int]
            je @done
            inc edi
            push edi
            jmp @print_modules
        @done:
        invoke CloseHandle, hFile
        mov esp, ebp
        pop ebp
        ret
    importDir_print endp

    exportDir_print proc
        push ebp
        mov ebp, esp
        invoke  CreateFile,ADDR FileName,GENERIC_READ,0,0,\
                OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0   
        mov     hFile,eax
        ;; Print Nt Header
        push offset newLn

        mov eax, dword ptr [Nt_offset]
        add eax, 4

        ;invoke ReadFile, hFile, addr buffer, eax, addr BytesRead,0
        invoke SetFilePointer, hFile, eax, 0, FILE_BEGIN
        invoke ReadFile, hFile, addr BytesBuffer, 2, addr BytesRead, 0
        mov ebx, dword ptr [BytesBuffer]
        mov [numberOfSections_int], ebx

        cmp [arch], 0
        je SectionHeader_offset_32
        add eax, 255
        jmp cont
        SectionHeader_offset_32:
            add eax, 239
        cont:
        ;invoke ReadFile,hFile,addr buffer,eax,addr BytesRead,0
        add eax, 12
        invoke SetFilePointer, hFile, eax, 0, FILE_CURRENT

        mov esi, 1
        push esi
        lo:
        pop esi
        cmp esi, dword ptr [numberOfSections_int]
        je @print_exp
        push esi
        invoke ReadFile,hFile,addr BytesBuffer,4,addr BytesRead,0
        mov eax, dword ptr [BytesBuffer]
        pop esi
        mov [virtAddr_array + esi * 4], eax
        push esi

        invoke SetFilePointer, hFile, 4, 0, FILE_CURRENT
        invoke ReadFile,hFile, addr BytesBuffer, 4, addr BytesRead, 0
        mov eax, dword ptr [BytesBuffer]
        pop esi
        mov [rawAddr_array + esi * 4], eax
        push esi

        pop esi
        inc esi
        push esi
        invoke SetFilePointer, hFile, 28, 0, FILE_CURRENT
        jmp lo
    @print_exp:
        mov eax, dword ptr [Nt_offset]
        cmp byte ptr [arch], 0h
        je @move_2_Export_Dir_RVA_32
        add eax, 86h
        jmp @get_Export_Dir_RVA
    @move_2_Export_Dir_RVA_32:
        add eax, 76h
        jmp @get_Export_Dir_RVA
    @get_Export_Dir_RVA:
        invoke SetFilePointer, hFile, eax, 0, FILE_BEGIN
        invoke ReadFile, hFile, addr BytesBuffer, 2, addr BytesRead, 0
        movzx ebx, word ptr [BytesBuffer]
        cmp ebx, 0h
        je @not_found_export_dir
        call convert_RVA_to_raw_offset
        mov dword ptr [offsetOfExportDirRVA], ebx

        invoke SetFilePointer, hFile, ebx, 0, FILE_BEGIN

        xor esi, esi
        push esi

    @print_eachMember:
        push dword ptr [expDir_msg + esi * 8]
        call StdOut
    
        pop esi
        movzx eax, word ptr [offsetOfExportDirRVA]
        mov ecx, 4
        mov edi, offset tmp_string
        push esi
        call print_string

        push offset separator
        call StdOut

        pop esi
        mov ecx, dword ptr [expDir_member_size + esi * 4]
        invoke ReadFile, hFile, addr BytesBuffer, ecx, addr BytesRead, 0
        mov eax, dword ptr [BytesBuffer]
        mov ecx, dword ptr [expDir_member_size + esi * 4]
        push esi
        mov edi, offset tmp_string
        call print_string

        push offset newLn
        call StdOut
        pop esi
        movzx eax, word ptr [expDir_member_size + esi * 4]
        add dword ptr [offsetOfExportDirRVA], eax
        cmp esi, 10
        je @done
        inc esi
        push esi
        jmp @print_eachMember

    @not_found_export_dir:
        push offset not_found_msg
        call StdOut
        @done:
        invoke CloseHandle, hFile
        mov esp, ebp
        pop ebp
        ret
    exportDir_print endp

    ;;  Input:   edi - input string
    ;;  Output:  eax - result in integer
    atoi proc uses ebx ecx edx esi edi
        xor eax, eax            ; set eax = 0
    @loop:
        movzx ecx, byte ptr [edi]   ; ecx = first byte of edi - input string
        sub ecx, '0'            ; convert num -> int 
        jb @done                ; 

        lea eax, [eax*4+eax]    ; eax = eax * 5
        lea eax, [eax*2+ecx]    ; eax = eax * 5 * 2 + ecx
        inc edi                 ; next character of string
        jmp @loop
    @done:
        ret
    atoi endp

    menu proc
        ; push max_size
        ; push offset FileName
        ; call StdIn
        ; call importDir_print
    call file_information

        push offset menu_msg
        call StdOut

        push 12
        push offset selection
        call StdIn

        mov edi, offset selection
        call atoi
        cmp eax, 1h
        je DosHeader_print
        cmp eax, 2h
        je NtHeader_print
        cmp eax, 3h
        je SectionHeader_print
        cmp eax, 4h 
        je importDir_print
        cmp eax, 5h
        je exportDir_print
        ret
    menu endp

start:
    push offset fileName_msg                            ; print
    call StdOut

    push 200
    push offset FileName
    call StdIn
    call menu
    invoke  ExitProcess,0

END start