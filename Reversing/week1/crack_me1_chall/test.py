import string
v3 = b"ABDCEHGFIJKLUNOPYRTSMVWXQZajcdefohibkmlngpqrstuv4xzy8123w56709+0"

result = [" "]*5
# for c in range(32, 128):
#     v10 = (c & 0xfc) >> 2
#     if v3[v10] == (0x624a5751 & 0xff):
#         result[0] = chr(c)
#         print(chr(c))
#         input = c
# for c in string.printable[:-8]:
#     v11 = ((ord(c) & 0xF0) >> 4) + 16 * (input & 3)
#     if (v3[v11] == ((0x624a5751 & 0xff00) >> 8)):
#         result[1] = c
#         input = ord(c)
#         break
# for c in string.printable[:-8]:
#     v12 = ((ord(c) & 0xC0) >> 6) + 4 * (input & 0xF)
#     if (v3[v11] == ((0x624a5751 & 0xff)) and v3[ord(c) & 0x3f] == ((0x624a5751 & 0xff0000) >> 16)):
#         result[2] = c
#         input = ord(c)
#         break
for v14 in range(32, 128):
    for v15 in range(32, 128):
        for v16 in range(32, 128):
            v10 = (v14 & 0xfc) >> 2
            v11 = ((v15 & 0xF0) >> 4) + 16 * (v14 & 3)
            v12 = ((v16 & 0xC0) >> 6) + 4 * (v15 & 0xF)
            if v3[v10] == (0x624a5751 & 0xff) and v3[v11] == ((0x624a5751 & 0xff00) >> 8) and v3[v12] == ((0x624a5751 & 0xff0000) >> 16) and v3[v16 & 0x3f] == ((0x624a5751 & 0xff000000) >> 24):
                print("{} {} {}".format(v14, v15, v16))


