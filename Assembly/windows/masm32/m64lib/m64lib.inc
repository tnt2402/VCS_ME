  ; ___________________________
  ; MASM64 Library Include File
  ; ���������������������������
    X64ST STRUCT
      mmx   dq ?
      sse   dq ?
      sse2  dq ?
      sse3  dq ?
      ssse3 dq ?
      sse41 dq ?
      sse42 dq ?
      avx   dq ?
      avx2  dq ?
      aes   dq ?
      htt   dq ?
      amd3D dq ?
      amd3x dq ?
      mmxx  dq ?
    X64ST ENDS

    externdef atofp:PROC
    externdef arrev:PROC
    externdef bitmap_image:PROC
    externdef block_ltrim:PROC
    externdef block_rtrim:PROC
    externdef block_trim:PROC
    externdef block_monospace:PROC
    externdef button:PROC
    externdef chartype:PROC
    externdef chfilter:PROC
    externdef checkbox:PROC
    externdef cpDiv:PROC
    externdef cpMul:PROC
    externdef cpSqrt:PROC
    externdef editbox:PROC
    externdef group_box:PROC
    externdef listbox:PROC
    externdef radiobutton:PROC
    externdef progress_bar:PROC
    externdef syslink:PROC
    externdef ascii_dump:PROC
    externdef atou_ex:PROC
    externdef bcopy:PROC
    externdef bin2hex:PROC
    externdef block_rtrim:PROC
    externdef dbcompact:PROC
    externdef char_count:PROC
    externdef CreateMMF:PROC
    externdef CloseMMF:PROC
    externdef copy_all:PROC
    externdef lBrowseForFolder:PROC
    externdef ErrOut:PROC
    externdef fptoa:PROC
    externdef GetAppName:PROC
    externdef GetAppPath:PROC
    externdef GetBmpSize:PROC
    externdef Get_Vendor:PROC
    externdef MsgboxI:PROC
    externdef StdOut:PROC
    externdef aspect_ratio:PROC
    externdef cmd_tail:PROC
    externdef execute:PROC
    externdef exist:PROC
    externdef fastsort:PROC
    externdef file_read:PROC
    externdef file_write:PROC
    externdef FindStr:PROC
    externdef font_handle:PROC
    externdef fixed_array:PROC
    externdef get_cpu_id_string:PROC
    externdef get_ext:PROC
    externdef GetPathOnly:PROC
    externdef getpercent:PROC
    externdef get_unique_seed:PROC
    externdef Get_Vendor:PROC
    externdef HexDump:PROC
    externdef hexstream:PROC
    externdef inbin:PROC
    externdef intdiv:PROC
    externdef intmul:PROC
    externdef irand:PROC
    externdef lfcnt:PROC
    externdef line:PROC
    externdef lntok:PROC
    externdef LoadGdiImage:PROC
    externdef load_file:PROC
    externdef low_ascii:PROC
    externdef ltok:PROC
    externdef mcopy:PROC
    externdef MonthByNumber:PROC
    externdef mmi:PROC
    externdef NameFromPath:PROC
    externdef onecrlf:PROC
    externdef open_file_dialog:PROC
    externdef preparse:PROC
    externdef rawssort:PROC
    externdef re_alloc:PROC
    externdef ResImageLoad:PROC
    externdef rrand:PROC
    externdef save_file:PROC
    externdef save_file_dialog:PROC
    externdef seed_rrand:PROC
    externdef seed_irand:PROC
    externdef select_all:PROC
    externdef static_left:PROC
    externdef static_cntr:PROC
    externdef static_rght:PROC
    externdef StdIn:PROC
    externdef StrLen:PROC
    externdef str_strip:PROC
    externdef string_clean:PROC
    externdef stripcc:PROC
    externdef szCatStr:PROC
    externdef szCmp:PROC
    externdef szCmpi:PROC
    externdef szCopy:PROC
    externdef szLeft:PROC
    externdef szLeft$:PROC
    externdef szLen:PROC
    externdef szLower:PROC
    externdef szLtrim:PROC
    externdef szMono:PROC
    externdef szRemove:PROC
    externdef szRep:PROC
    externdef szRev:PROC
    externdef szRight:PROC
    externdef szRight$:PROC
    externdef szRtrim:PROC
    externdef szSpace:PROC
    externdef szTrim:PROC
    externdef szUpper:PROC
    externdef szWcnt:PROC
    externdef szappend:PROC
    externdef szmulticat:PROC
    externdef truncate:PROC
    externdef txt2mem:PROC
    externdef underline_font:PROC
    externdef wait_key:PROC
    externdef winshell:PROC
    externdef wordtok:PROC
    externdef xmmcopya:PROC
    externdef xor_data:PROC
    externdef ymmcopya:PROC
    externdef zerofill:PROC
