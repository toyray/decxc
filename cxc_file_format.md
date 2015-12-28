## CXC File Format Specification

```
0x00000000	File Header (3CAG)
0x00000004	Length of Character Name
0x00000008	Character Name

+ 0x00000000	Length of Encrypted CCC Data
+ 0x00000004	Encrypted CCC Data
```

## Decryption Function

- encrypted data is decrypted by XORing DWORDs with Magic (Initial Magic is 0xCA11ACAB)
   - Magic is the previous DWORD before being XORed
- decrypted data is encrypted by XORing DWORDs with Magic (Initial Magic is 0xCA11ACAB)
   - Magic is the previous DWORD after being XORed
- decryption function is located in CXMain.DLL at location 100AF900
- encryption function has not been found yet
