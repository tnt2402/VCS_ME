import string
from arc4 import ARC4
varC = [0x1, 0x0, 0x0CCCCCC74, 0x1, 0x1, 0x0CCCCCC48, 0x1, 0x2, 0x0CCCCCC3B, 0x2, 0x88, 0x0CCCC2481, 0x3, 0x6F, 0x6F593363, 0x2, 0x84, 0x0CCCC0101, 0x2, 0x0A, 0x0CCCCAF35, 0x1, 0x0D0, 0x0CCCCCC33, 0x3, 0x0F, 0x76784D64, 0x4, 0x12, 0x1AB120DD, 0x1, 0x106, 0x0CCCCCC0C, 0x3, 0x0E8, 0x3542446A, 0x2, 0x1D, 0x0CCCC21A6, 0x2, 0x1F, 0x0CCCC8ABE, 0x1, 0x21, 0x0CCCCCC4C, 0x2, 0x22, 0x0CCCC0E26, 0x1, 0x24, 0x0CCCCCC35, 0x1, 0x5D, 0x0CCCCCC3B, 0x3, 0x2B, 0x7539456A, 0x4, 0x16, 0x0DED3F88, 0x3, 0x0EB, 0x7A56336A, 0x2, 0x32, 0x0CCCCAF35, 0x2, 0x30, 0x0CCCC2FAB, 0x2, 0x8, 0x0CCCC3681, 0x3, 0x34, 0x75636C6A, 0x1, 0x37, 0x0CCCCCC00, 0x2, 0x38, 0x0CCCC3C25, 0x3, 0x53, 0x67524649, 0x1, 0x3E, 0x0CCCCCC21, 0x1, 0x3F, 0x0CCCCCC54, 0x1, 0x92, 0x0CCCCCC37, 0x1, 0x86, 0x0CCCCCC74, 0x4, 0x109, 0x13FD36C0, 0x1, 0x4A, 0x0CCCCCC00, 0x1, 0x10D, 0x0CCCCCC52, 0x4, 0x4D, 0x43BA3DC1, 0x3, 0x11C, 0x6F773264, 0x4, 0x3A, 0x0CB073CD, 0x4, 0x56, 0x6B973CD, 0x3, 0x5A, 0x796D3251, 0x4, 0x10F, 0x10AE36CB, 0x1, 0x5E, 0x0CCCCCC3D, 0x2, 0x5F, 0x0CCCC2101, 0x4, 0x68, 0x6B52788, 0x1, 0x0BA, 0x0CCCCCC44, 0x4, 0x9A, 0x6BA3ADC, 0x3, 0x6C, 0x6D4A4649, 0x4, 0x4, 0x43AE6288, 0x4, 0x72, 0x0EFD20C1, 0x2, 0x0C7, 0x0CCCC863D, 0x1, 0x7A, 0x0CCCCCC2B, 0x4, 0x7B, 0x0DB82788, 0x1, 0x0C6, 0x0CCCCCC0E, 0x1, 0x83, 0x0CCCCCC2B, 0x1, 0x3, 0x0CCCCCC01, 0x4, 0x93, 0x13BC2388, 0x4, 0x0A9, 0x43B23788, 0x3, 0x0C, 0x436D475A, 0x4, 0x8A, 0x11BC36CE, 0x4, 0x8E, 0x11BC73DB, 0x4, 0x0AF, 0x0AB527D1, 0x2, 0x44, 0x0CCCCA525, 0x1, 0x97, 0x0CCCCCC37, 0x2, 0x98, 0x0CCCC2F01, 0x4, 0x61, 0x2FD3CDC, 0x1, 0x9E, 0x0CCCCCC52, 0x4, 0x9F, 0x3AFD7DDB, 0x4, 0x46, 0x17B126CB, 0x1, 0x0A7, 0x0CCCCCC33, 0x1, 0x2F, 0x0CCCCCC00, 0x1, 0x87, 0x0CCCCCC48, 0x1, 0x0AD, 0x0CCCCCC33, 0x1, 0x0AE, 0x0CCCCCC4E, 0x4, 0x0C9, 0x0FD26C7, 0x2, 0x0B3, 0x0CCCCA122, 0x1, 0x0B5, 0x0CCCCCC00, 0x4, 0x0B6, 0x43A83CD1, 0x3, 0x65, 0x73593351, 0x1, 0x0BB, 0x0CCCCCC37, 0x1, 0x0BC, 0x0CCCCCC31, 0x4, 0x0D2, 0x0CA973DC, 0x3, 0x0BF, 0x3842545A, 0x2, 0x0C2, 0x0CCCC2181, 0x1, 0x0DA, 0x0CCCCCC4E, 0x4, 0x7F, 0x17B430C9, 0x4, 0x76, 0x0FB821CD, 0x4, 0x0FB, 0x11AD73CD, 0x2, 0x0CD, 0x0CCCC26A6, 0x1, 0x0CF, 0x0CCCCCC00, 0x2, 0x4B, 0x0CCCC2C25, 0x1, 0x0D1, 0x0CCCCCC31, 0x2, 0x0BD, 0x0CCCC22A3, 0x3, 0x113, 0x796D4749, 0x2, 0x0C4, 0x0CCCCA426, 0x3, 0x0EF, 0x6C6D476A, 0x4, 0x0DC, 0x0DBC73CD, 0x1, 0x0EE, 0x0CCCCCC00, 0x4, 0x0E4, 0x0CAF27C6, 0x3, 0x1A, 0x5539315A, 0x1, 0x2E, 0x0CCCCCC35, 0x4, 0x0E0, 0x0CBE73CC, 0x1, 0x0DB, 0x0CCCCCC35, 0x2, 0x0F2, 0x0CCCCA48C, 0x4, 0x0F4, 0x7B33288, 0x2, 0x25, 0x0CCCC39A7, 0x4, 0x40, 0x5B43788, 0x1, 0x0FF, 0x0CCCCCC3D, 0x3, 0x100, 0x6B563251, 0x3, 0x103, 0x6D4A5864, 0x4, 0x27, 0x3CBA1DC7, 0x2, 0x107, 0x0CCCC062B, 0x4, 0x0A3, 0x0FD26C7, 0x1, 0x0A8, 0x0CCCCCC4E, 0x1, 0x10E, 0x0CCCCCC3D, 0x3, 0x0F8, 0x67524649, 0x4, 0x0D6, 0x2B53088, 0x2, 0x116, 0x0CCCC8625, 0x4, 0x118, 0x0CFD20DC, 0x2, 0x51, 0x0CCCCA2A8, 0x3, 0x11F, 0x33566C63, 0x3, 0x122, 0x6B4A5851, 0x1, 0x125, 0x0CCCCCC0E]

result = [" "] * 300

j = 0
def int_to_bytes(x: int) -> bytes:
    return x.to_bytes((x.bit_length() + 7) // 8, 'little')

for i in range(0, len(varC), 3):
    if varC[i] == 1:
        c = (varC[i+2] & 0xff) ^ 0x20
        if (c % 2 == 0 and chr(c) in string.printable):
            result[varC[i+1]] = chr(c)
        else:
            c = (varC[i+2] & 0xff) ^ 0x52
            result[varC[i+1]] = chr(c)
    if varC[i] == 2:
        for m in string.printable:
            for n in string.printable:
                v4 = ord(m) | ord(n) << 8
                for k in range(1, 6):
                    v4 = ((v4 >> (16 - k)) | (v4 << k)) ^ 0x1693
                    v4 = v4 & 0xffff
                if v4 == (varC[i + 2] & 0xffff):
                    result[varC[i+1]] = n
                    result[varC[i+1] + 1] = m
                    break
    if varC[i] == 3:
        v3 = b"ABDCEHGFIJKLUNOPYRTSMVWXQZajcdefohibkmlngpqrstuv4xzy8123w56709+0"
        for v14 in range(32, 128):
            for v15 in range(32, 128):
                for v16 in range(32, 128):
                    v10 = (v14 & 0xfc) >> 2
                    v11 = ((v15 & 0xF0) >> 4) + 16 * (v14 & 3)
                    v12 = ((v16 & 0xC0) >> 6) + 4 * (v15 & 0xF)
                    if v3[v10] == (varC[i+2] & 0xff) and v3[v11] == ((varC[i+2] & 0xff00) >> 8) and v3[v12] == ((varC[i+2] & 0xff0000) >> 16) and v3[v16 & 0x3f] == ((varC[i+2] & 0xff000000) >> 24):
                        # print("{} {} {}".format(v14, v15, v16))
                        result[varC[i+1]] = chr(v14)
                        result[varC[i+1] + 1] = chr(v15)
                        result[varC[i+1] + 2] = chr(v16)
                        break
    if varC[i] == 4:
        arc4 = ARC4(b'\x73\x75\x73\x61\x6e')
        hex_str = []
        
        hex_str = int_to_bytes(varC[i+2])
        hex_str  = hex_str + b'\x00' * (4 - len(hex_str))

        clear_txt = arc4.decrypt(hex_str)
        for j in range(4):
            result[varC[i+1] + j] = chr(clear_txt[j])
print("".join(i for i in result))
# ThiS 1s A rIdiCuLously l0ng_Lon9_l0ng_loNg_lOng strIng. The most difficult thing is the decision to act, the rest is merely tenacity. The fears are paper tigers. You can do anything you decide to do. You can act to change and control your life; and the procedure, the process is its own reward.
# vcstraining{Aw3s0me_D4ta_tran5Form4t1oN_Kak4}

