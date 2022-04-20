
#       v30 = GetFileSize(v4, 0);

#         v9 = malloc(8 * v3);
#         v10 = 0;
#         v29 = v9;
#         v11 = 0;
#         v32 = 0;
#         v13 = lpBaseAddress;
#         if ( *(WORD *) lpBaseAddress == 19778 && v30 < *(_DWORD *)(lpBaseAddress + 2) )
#         {
#           v14 = *(_DWORD *)(lpBaseAddress + 10);
#           if ( v14 >= v30 && v11 >= *(_DWORD *)(lpBaseAddress + 34) )
#           {
#             v15 = 0;
#             v16 = *(_DWORD *)(lpBaseAddress + 18);
#             v27 = *(_DWORD *)(lpBaseAddress + 22);
#             v17 = &lpBaseAddress[v14];
#             v18 = 0;
#             v25 = v16;
#             v26 = v17;
#             *((_WORD *)lpBaseAddress + 3) = v11;
#             v33 = 0;
#             if ( v11 )
#             {
#               v19 = 0;
#               v31 = 0;
#               do
#               {
#                 if ( v18 >= v27 )
#                   break;
#                 v20 = 0;
#                 if ( v15 < v11 )
#                 {
#                   do
#                   {
#                     if ( v20 >= v16 )
#                       break;
#                     v21 = v19 + v20++;
#                     v22 = v29[v15++];
#                     v26[2 * v21 + v21] = v22;
#                     v19 = v31;
#                     v16 = v25;
#                   }
#                   while ( v15 < v11 );
#                   v18 = v33;
#                 }
#                 ++v18;
#                 v19 += 3 * v16;
#                 v33 = v18;
#                 v31 = v19;
#               }
#               while ( v15 < v11 );
#               v13 = lpBaseAddress;
#             }
#             v9 = v29;
#           }
#         }
#         free(v9);
#         UnmapViewOfFile(v13);
#         CloseHandle(hObject);
#         CloseHandle(v23);
#       }
#       else
#       {
#         CloseHandle(v8);
#         CloseHandle(v5);
#       }
#     }
#   }
# }
path = "inside-the-mind-of-a-hacker-memory.bmp"
# path = "a.bmp"
import os
v30 = os.path.getsize(path)
print(hex(v30))
f = open(path, "rb")
r = f.read()
v14 = (r[13] << 24) + (r[12] << 16) + (r[11] << 8) + (r[10])
v16 = (r[21] << 24) + (r[20] << 16) + (r[19] << 8) + (r[18])
v27 = (r[25] << 24) + (r[24] << 16) + (r[23] << 8) + (r[22])
v17 = r[v14]
v25 = v16
v26 = v17

print("v14 {}\nv16 {}\nv27 {}\nv17 {}".format(hex(v14), hex(v16), hex(v27), hex(v17)))

v19 = 0
v31 = 0
for v15 in range(v11):
  v20 = 0


