# f = open("a.bmp", "r")
# r = f.read()
r = "hello"
v9 = [None] * len(r) * 8

# i = 0;
# v29 = v9;
# v11 = 0;
# v32 = 0;
# do
# {
# v12 = Dest[i];
# v9[v11] = v12 & 1;
# v9[v11 + 1] = (v12 >> 1) & 1;
# v9[v11 + 2] = (v12 >> 2) & 1;
# v9[v11 + 3] = (v12 >> 3) & 1;
# v9[v11 + 4] = (v12 >> 4) & 1;
# v9[v11 + 5] = (v12 >> 5) & 1;
# v9[v11 + 6] = (v12 >> 6) & 1;
# i = v32 + 1;
# v9[v11 + 7] = (v12 >> 7) & 1;
# v11 += 8;
# v32 = i;
# }
# while ( i < v3 );
i = 0
v11 = 0
while (i < len(r)):
    v12 = ord(r[i])
    v9[v11] = v12 & 1
    v9[v11 + 1] = (v12 >> 1) & 1
    v9[v11 + 2] = (v12 >> 2) & 1
    v9[v11 + 3] = (v12 >> 3) & 1
    v9[v11 + 4] = (v12 >> 4) & 1
    v9[v11 + 5] = (v12 >> 5) & 1
    v9[v11 + 6] = (v12 >> 6) & 1
    v9[v11 + 7] = (v12 >> 7) & 1
    v11 = v11 + 8
    i = i + 1
for i in range(0, len(r) * 8, 8):
    print(''.join(str(j) for j in v9[i:i+8]))
print(v9)
# 01000000
# 00010100
# 00010001
# 00010100
# 01010000
# 00010100
# 01010000
# 00010100
# 01010101
# 00010100

