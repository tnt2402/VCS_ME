v8 = b'bdnpQai|nufimnug`n{FafhrW'
# for first 5 characters of "flag{", we can generate the 5-byte key
key = [0x04, 0x08, 0xf, 0x17, 0x2a]

result = ''

for i in range(len(v8)):
    result = result + chr(v8[i] ^ key[i % 5])
print(result)

# flag{easy_baby_challenge}