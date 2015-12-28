.386
.model flat, stdcall
option casemap: none

include \MASM32\Include\Windows.inc
include \MASM32\Include\Kernel32.inc
include \MASM32\Include\User32.inc
include \MASM32\Include\Comdlg32.inc
        
includelib \MASM32\Lib\Kernel32.lib
includelib \MASM32\Lib\User32.lib
includelib \MASM32\Lib\Comdlg32.lib

dlgProc     proto hwndDlg:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

readCxc     proto CxcName:DWORD, NameBuffer:DWORD, NameLen:DWORD, CxcBuffer:DWORD, CxcLen:DWORD
deCxc       proto CxcBuffer:DWORD, CxcLen:DWORD, NameBuffer:DWORD
enCxc       proto CxcBuffer:DWORD, CxcLen:DWORD, NameBuffer:DWORD, NameLen:DWORD

genChkSum   proto CxcBuffer:DWORD, CxcLen:DWORD
genMagic    proto
setChkSum   proto CxcBuffer:DWORD
verChkSum   proto CxcBuffer:DWORD

getCccName  proto CxcBuffer:DWORD, NameBuffer:DWORD, NameLen:DWORD

.data?
    
    hInst       HINSTANCE       ?
    hFile       HANDLE          ?
    
    tmpDW       DWORD           ?
    tmpTbl      DWORD           16 dup (?)
    magicTbl    DWORD           4  dup (?)
    nameLen     DWORD           ?
    encLen      DWORD           ?
    tmpW        WORD            ?

    strCxc      BYTE            100000 dup (?)
    strName     BYTE            100 dup (?)
    strFile     BYTE            300 dup (?)
    strTmp      BYTE            600 dup (?)

    strcOfn     OPENFILENAME    <?>

.const
    IDI_APP         equ     200
    IDC_DECRYPT     equ     1001
    IDC_ENCRYPT     equ     1002    


.code
start:
    invoke GetModuleHandle, NULL
    mov hInst, eax
    jmp @@1
        hDlg    BYTE    "DLGBOX",0

        cccExt  BYTE    ".ccc",0
        cxcExt  BYTE    ".cxc",0

        openCcc BYTE    "Open a CCC file...",0
        openCxc BYTE    "Open a CXC file...",0  

        cccFil  BYTE    "Chron X Decrypted Character Files (*.ccc)",0,"*.CCC",0,0      
        cxcFil  BYTE    "Chron X Character Files (*.cxc)",0,"*.CXC",0,0        

        cccX    BYTE    "ccc",0
        cxcX    BYTE    "cxc",0

        msgTtl      BYTE    "decxc 1.0",0 
        msgCxcRead  BYTE    "Reading of CXC file failed!",0
        msgCccRead  BYTE    "Reading of CCC file failed!",0
        msgChkFail  BYTE    "Warning! File checksum for this decrypted CCC file failed!",0
        msgEncPass  BYTE    "Encryption successful !",0
        msgDecPass  BYTE    "Decryption successful !",0        
@@1:    
    invoke DialogBoxParam, hInst, ADDR hDlg, NULL, ADDR dlgProc, NULL
    invoke ExitProcess, NULL

dlgProc proc hwndDlg:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .IF uMsg == WM_INITDIALOG
        invoke LoadIcon, hInst, IDI_APP
        invoke SendMessage, hwndDlg, WM_SETICON, eax, ICON_BIG

        mov strcOfn.lStructSize, SIZEOF OPENFILENAME
        push hwndDlg
        pop strcOfn.hwndOwner
        push hwndDlg
        pop strcOfn.hInstance
        mov strcOfn.lpstrFile, OFFSET strFile
        mov strcOfn.nMaxFile, 300
        mov strcOfn.Flags, OFN_PATHMUSTEXIST or OFN_NONETWORKBUTTON or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY

    .ELSEIF uMsg == WM_CLOSE
        invoke EndDialog, hwndDlg, 0
    .ELSEIF uMsg == WM_COMMAND
        .IF wParam == IDC_DECRYPT
            mov strcOfn.lpstrFilter, OFFSET cxcFil
            mov strcOfn.lpstrTitle, OFFSET openCxc
            mov strcOfn.lpstrDefExt, OFFSET cxcX
            mov byte ptr [strFile], 0
            invoke GetOpenFileName, ADDR strcOfn
            test eax, eax
            je escProc
            invoke readCxc, ADDR strFile, ADDR strName, ADDR nameLen, ADDR strCxc, ADDR encLen 
            .IF eax == FALSE
                invoke MessageBox, hwndDlg, ADDR msgCxcRead, ADDR msgTtl, MB_ICONINFORMATION
            escProc:                
                mov eax, TRUE
                ret
            .ELSE
                invoke deCxc, ADDR strCxc, encLen, ADDR strName
                invoke MessageBox, hwndDlg, ADDR msgDecPass, ADDR msgTtl, MB_ICONINFORMATION                
                invoke genChkSum, ADDR strCxc, encLen
                invoke verChkSum, ADDR strCxc
                .IF eax == FALSE
                     invoke MessageBox, hwndDlg, ADDR msgChkFail, ADDR msgTtl, MB_ICONINFORMATION                    
                .ENDIF
                
            .ENDIF                                        
        .ELSEIF wParam == IDC_ENCRYPT
            mov strcOfn.lpstrFilter, OFFSET cccFil
            mov strcOfn.lpstrTitle, OFFSET openCcc
            mov strcOfn.lpstrDefExt, OFFSET cccX
            mov byte ptr [strFile], 0
            invoke GetOpenFileName, ADDR strcOfn            
            test eax, eax
            je escProc
            invoke CreateFile, ADDR strFile, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, \
            FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, NULL 
            .IF eax == INVALID_HANDLE_VALUE
                invoke MessageBox, hwndDlg, ADDR msgCccRead, ADDR msgTtl, MB_ICONINFORMATION
                mov eax, TRUE
                ret
            .ENDIF
            push eax
            invoke GetFileSize, eax, ADDR tmpDW
            mov encLen, eax
            pop eax
            push eax
            invoke ReadFile, eax, ADDR strCxc, encLen, ADDR tmpDW, NULL
            invoke genChkSum, ADDR strCxc, encLen
            invoke setChkSum, ADDR strCxc 
            invoke getCccName, ADDR strCxc, ADDR strName, ADDR nameLen
            invoke enCxc, ADDR strCxc, encLen, ADDR strName, nameLen
            pop eax
            invoke CloseHandle, eax
            invoke MessageBox, hwndDlg, ADDR msgEncPass, ADDR msgTtl, MB_ICONINFORMATION
        .ENDIF
    .ELSE
        mov eax, FALSE
        ret        
    .ENDIF
    mov eax, TRUE
    ret
dlgProc endp

readCxc proc uses esi CxcName:DWORD, NameBuffer:DWORD, NameLen:DWORD, CxcBuffer:DWORD, CxcLen:DWORD
    invoke CreateFile, CxcName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, \
                FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, NULL
    cmp eax, INVALID_HANDLE_VALUE
    jz endRead
    mov hFile, eax
    mov esi, NameBuffer
    invoke ReadFile, eax, NameBuffer, 4, ADDR tmpDW, NULL
    test eax, eax
    jz failRead
    cmp dword ptr [esi], "GAC3"
    jnz failRead
    invoke ReadFile, hFile, NameBuffer, 4, ADDR tmpDW, NULL
    test eax, eax
    jz failRead
    mov eax, dword ptr [esi]
    mov esi, NameLen
    mov dword ptr [esi], eax
    mov byte ptr [esi+eax],0
    invoke ReadFile, hFile, NameBuffer, eax, ADDR tmpDW, NULL
    test eax, eax
    jz failRead
    invoke ReadFile, hFile, CxcBuffer, 4, ADDR tmpDW, NULL
    test eax, eax
    jz failRead
    mov esi, CxcBuffer
    mov eax, dword ptr [esi]
    mov esi, CxcLen
    mov dword ptr [esi], eax
    push eax 
    add eax, 80h
    invoke RtlZeroMemory, CxcBuffer, eax
    pop eax
    invoke ReadFile, hFile, CxcBuffer, eax, ADDR tmpDW, NULL
    test eax, eax
    jz failRead
    invoke CloseHandle, hFile
    mov eax, TRUE
    ret
failRead:    
    invoke CloseHandle, hFile
endRead:
    mov eax, FALSE
    ret
readCxc endp

deCxc proc uses ecx esi CxcBuffer:DWORD, CxcLen:DWORD, NameBuffer:DWORD
    mov eax, CxcLen
    mov cl, 2
    shr eax, cl
    mov ecx, eax
    mov eax, CxcBuffer
    mov esi, 0CA11ACABh
loopDeCxc:    
    test ecx, ecx
    jz endDeCxc
    push dword ptr[eax]
    xor dword ptr[eax], esi
    pop esi
    add eax, 4
    dec ecx
    jmp loopDeCxc
endDeCxc:
    invoke lstrcpy, ADDR strFile, NameBuffer
    invoke lstrcat, ADDR strFile, ADDR cccExt
    invoke CreateFile, ADDR strFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    push eax
    invoke WriteFile, eax, CxcBuffer, CxcLen, ADDR tmpDW, 0
    pop eax
    invoke CloseHandle, eax
    ret
deCxc endp

genChkSum proc uses ecx edx CxcBuffer:DWORD, CxcLen:DWORD
    mov dword ptr [magicTbl], 67452301h
    mov dword ptr [magicTbl+04h], 0EFCDAB89h
    mov dword ptr [magicTbl+08h], 98BADCFEh
    mov dword ptr [magicTbl+0Ch], 10325476h

    mov eax, CxcLen
    sub eax, 20
    mov cl, 6
    shr eax, cl
    push eax
    shl eax, cl
    mov ecx, CxcLen
    sub ecx, 20
    sub ecx, eax
    cmp ecx, 52
    mov ecx, 6
    pop eax
    jle addFileSize
    inc eax
addFileSize:
    push eax
    shl eax, cl
    add eax, CxcBuffer
    add eax, 14h
    add eax, 38h
    push eax
    mov eax, CxcLen
    sub eax, 20
    mov cl, 3
    shl eax, cl
    mov ecx, eax
    pop eax
    mov dword ptr [eax], ecx
         
    mov eax, CxcBuffer
    mov ecx, CxcLen
    mov byte ptr [eax+ecx], 80h
    add eax, 20
    pop ecx
    inc ecx
loopGenerate:    
    test ecx, ecx
    jz endGenerate
    push eax
    invoke genMagic
    pop eax
    add eax, 40h
    dec ecx
    jmp loopGenerate
endGenerate:    
    ret
genChkSum endp

genMagic proc uses ebx ecx edx esi edi
    mov edx, dword ptr [magicTbl+0Ch]
    mov esi, dword ptr [magicTbl+8]
    mov edi, dword ptr [magicTbl+4]
    mov ecx, [eax]
    mov ebx, edx
    mov dword ptr [tmpTbl+4], ecx
    xor ebx, esi
    and ebx, edi
    xor ebx, edx
    add ebx, ecx
    mov ecx, dword ptr [magicTbl+0]
    lea ecx, [ebx+ecx-28955B88h]
    mov ebx, [eax+4]
    mov dword ptr [tmpTbl+24h], ebx
    mov ebx, esi
    rol ecx, 7
    xor ebx, edi
    add ecx, edi
    and ebx, ecx
    xor ebx, esi
    add ebx, edx
    mov edx, dword ptr [tmpTbl+24h]
    lea edx, [ebx+edx-173848AAh]
    mov ebx, [eax+8]
    mov dword ptr [tmpTbl+8], ebx
    mov ebx, edi
    rol edx, 0Ch
    xor ebx, ecx
    add edx, ecx
    and ebx, edx
    xor ebx, edi
    add ebx, esi
    mov esi, dword ptr [tmpTbl+8]
    lea esi, [ebx+esi+242070DBh]
    mov ebx, [eax+0Ch]
    mov dword ptr [tmpTbl+2Ch], ebx
    mov ebx, edx
    rol esi, 11h
    add esi, edx
    xor ebx, ecx
    and ebx, esi
    xor ebx, ecx
    add ebx, edi
    mov edi, dword ptr [tmpTbl+2Ch]
    lea edi, [ebx+edi-3E423112h]
    mov ebx, [eax+10h]
    mov dword ptr [tmpTbl+14h], ebx
    mov ebx, edx
    rol edi, 16h
    add edi, esi
    xor ebx, esi
    and ebx, edi
    xor ebx, edx
    add ebx, ecx
    mov ecx, dword ptr [tmpTbl+14h]
    lea ecx, [ebx+ecx-0A83F051h]
    mov ebx, [eax+14h]
    mov dword ptr [tmpTbl+34h], ebx
    mov ebx, esi
    rol ecx, 7
    add ecx, edi
    xor ebx, edi
    and ebx, ecx
    xor ebx, esi
    add ebx, edx
    mov edx, dword ptr [tmpTbl+34h]
    lea edx, [ebx+edx+4787C62Ah]
    mov ebx, [eax+18h]
    mov dword ptr [tmpTbl+1Ch], ebx
    mov ebx, edi
    rol edx, 0Ch
    add edx, ecx
    xor ebx, ecx
    and ebx, edx
    xor ebx, edi
    add ebx, esi
    mov esi, dword ptr [tmpTbl+1Ch]
    lea esi, [ebx+esi-57CFB9EDh]
    mov ebx, [eax+1Ch]
    mov dword ptr [tmpTbl+38h], ebx
    mov ebx, edx
    rol esi, 11h
    xor ebx, ecx
    add esi, edx
    and ebx, esi
    xor ebx, ecx
    add ebx, edi
    mov edi, dword ptr [tmpTbl+38h]
    lea edi, [ebx+edi-2B96AFFh]
    mov ebx, [eax+20h]
    mov dword ptr [tmpTbl+20h], ebx
    mov ebx, edx
    rol edi, 16h
    xor ebx, esi
    add edi, esi
    and ebx, edi
    xor ebx, edx
    add ebx, ecx
    mov ecx, dword ptr [tmpTbl+20h]
    lea ecx, [ebx+ecx+698098D8h]
    mov ebx, [eax+24h]
    mov dword ptr [tmpTbl+0Ch], ebx
    mov ebx, esi
    rol ecx, 7
    xor ebx, edi
    add ecx, edi
    and ebx, ecx
    xor ebx, esi
    add ebx, edx
    mov edx, dword ptr [tmpTbl+0Ch]
    lea edx, [ebx+edx-74BB0851h]
    mov ebx, [eax+28h]
    mov dword ptr [tmpTbl+28h], ebx
    mov ebx, edi
    rol edx, 0Ch
    add edx, ecx
    xor ebx, ecx
    and ebx, edx
    xor ebx, edi
    add ebx, esi
    mov esi, dword ptr [tmpTbl+28h]
    lea esi, [ebx+esi-0A44Fh]
    mov ebx, [eax+2Ch]
    mov dword ptr [tmpTbl+10h], ebx
    mov ebx, edx
    rol esi, 11h
    add esi, edx
    xor ebx, ecx
    and ebx, esi
    xor ebx, ecx
    add ebx, edi
    mov edi, dword ptr [tmpTbl+10h]
    lea edi, [ebx+edi-76A32842h]
    mov ebx, [eax+30h]
    mov dword ptr [tmpTbl+30h], ebx
    mov ebx, edx
    rol edi, 16h
    add edi, esi
    xor ebx, esi
    and ebx, edi
    xor ebx, edx
    add ebx, ecx
    mov ecx, dword ptr [tmpTbl+30h]
    lea ecx, [ebx+ecx+6B901122h]
    mov ebx, [eax+34h]
    mov dword ptr [tmpTbl+18h], ebx
    mov ebx, esi
    rol ecx, 7
    add ecx, edi
    xor ebx, edi
    and ebx, ecx
    xor ebx, esi
    add ebx, edx
    mov edx, dword ptr [tmpTbl+18h]
    lea ebx, [ebx+edx-2678E6Dh]
    rol ebx, 0Ch
    mov edx, [eax+38h]
    add ebx, ecx
    mov dword ptr [tmpTbl+3Ch], edx
    mov edx, edi
    xor edx, ecx
    mov eax, [eax+3Ch]
    and edx, ebx
    mov dword ptr [tmpTbl], eax
    xor edx, edi
    add edx, esi
    mov esi, dword ptr [tmpTbl+3Ch]
    lea edx, [edx+esi-5986BC72h]
    mov esi, ebx
    rol edx, 11h
    add edx, ebx
    xor esi, ecx
    and esi, edx
    xor esi, ecx
    add esi, edi
    mov edi, edx
    lea esi, [esi+eax+49B40821h]
    rol esi, 16h
    add esi, edx
    xor edi, esi
    and edi, ebx
    xor edi, edx
    add edi, ecx
    mov ecx, dword ptr [tmpTbl+24h]
    lea ecx, [edi+ecx-9E1DA9Eh]
    mov edi, esi
    rol ecx, 5
    add ecx, esi
    xor edi, ecx
    and edi, edx
    xor edi, esi
    add edi, ebx
    mov ebx, dword ptr [tmpTbl+1Ch]
    lea edi, [edi+ebx-3FBF4CC0h]
    rol edi, 9
    add edi, ecx
    mov ebx, edi
    xor ebx, ecx
    and ebx, esi
    xor ebx, ecx
    add ebx, edx
    mov edx, dword ptr [tmpTbl+10h]
    lea edx, [ebx+edx+265E5A51h]
    mov ebx, edi
    rol edx, 0Eh
    add edx, edi
    xor ebx, edx
    and ebx, ecx
    xor ebx, edi
    add ebx, esi
    mov esi, dword ptr [tmpTbl+4h]
    lea esi, [ebx+esi-16493856h]
    mov ebx, edx
    rol esi, 14h
    add esi, edx
    xor ebx, esi
    and ebx, edi
    xor ebx, edx
    add ebx, ecx
    mov ecx, dword ptr [tmpTbl+34h]
    lea ecx, [ebx+ecx-29D0EFA3h]
    mov ebx, esi
    rol ecx, 5
    add ecx, esi
    xor ebx, ecx
    and ebx, edx
    xor ebx, esi
    add ebx, edi
    mov edi, dword ptr [tmpTbl+28h]
    lea edi, [ebx+edi+2441453h]
    rol edi, 9
    add edi, ecx
    mov ebx, edi
    xor ebx, ecx
    and ebx, esi
    xor ebx, ecx
    add ebx, edx
    lea edx, [ebx+eax-275E197Fh]
    mov eax, edi
    rol edx, 0Eh
    add edx, edi
    xor eax, edx
    and eax, ecx
    xor eax, edi
    add eax, esi
    mov esi, dword ptr [tmpTbl+14h]
    lea esi, [eax+esi-182C0438h]
    mov eax, edx
    rol esi, 14h
    add esi, edx
    xor eax, esi
    and eax, edi
    xor eax, edx
    add eax, ecx
    mov ecx, dword ptr [tmpTbl+0Ch]
    lea ecx, [eax+ecx+21E1CDE6h]
    mov eax, esi
    rol ecx, 5
    add ecx, esi
    xor eax, ecx
    and eax, edx
    xor eax, esi
    add eax, edi
    mov edi, dword ptr [tmpTbl+3Ch]
    lea edi, [eax+edi-3CC8F82Ah]
    rol edi, 9
    add edi, ecx
    mov eax, edi
    xor eax, ecx
    and eax, esi
    xor eax, ecx
    add eax, edx
    mov edx, dword ptr [tmpTbl+2Ch]
    lea edx, [eax+edx-0B2AF279h]
    mov eax, edi
    rol edx, 0Eh
    add edx, edi
    xor eax, edx
    and eax, ecx
    xor eax, edi
    add eax, esi
    mov esi, dword ptr [tmpTbl+20h]
    lea esi, [eax+esi+455A14EDh]
    mov eax, edx
    rol esi, 14h
    add esi, edx
    xor eax, esi
    and eax, edi
    xor eax, edx
    add eax, ecx
    mov ecx, dword ptr [tmpTbl+18h]
    lea ecx, [eax+ecx-561C16FBh]
    mov eax, esi
    rol ecx, 5
    add ecx, esi
    xor eax, ecx
    and eax, edx
    xor eax, esi
    add eax, edi
    mov edi, dword ptr [tmpTbl+8]
    lea edi, [eax+edi-3105C08h]
    rol edi, 9
    add edi, ecx
    mov eax, edi
    mov ebx, edi
    xor eax, ecx
    and eax, esi
    xor eax, ecx
    add eax, edx
    mov edx, dword ptr [tmpTbl+38h]
    lea eax, [eax+edx+676F02D9h]
    mov edx, ecx
    rol eax, 0Eh
    add eax, edi
    xor ebx, eax
    and edx, ebx
    xor edx, edi
    add edx, esi
    mov esi, dword ptr [tmpTbl+30h]
    lea edx, [edx+esi-72D5B376h]
    rol edx, 14h
    add edx, eax
    mov esi, edx
    xor esi, ebx
    add esi, ecx
    mov ecx, dword ptr [tmpTbl+34h]
    lea ecx, [esi+ecx-5C6BEh]
    mov esi, eax
    rol ecx, 4
    add ecx, edx
    xor esi, edx
    xor esi, ecx
    mov ebx, ecx
    add esi, edi
    mov edi, dword ptr [tmpTbl+20h]
    lea esi, [esi+edi-788E097Fh]
    rol esi, 0Bh
    add esi, ecx
    mov edi, esi
    xor edi, edx
    xor edi, ecx
    add edi, eax
    mov eax, dword ptr [tmpTbl+10h]
    lea eax, [edi+eax+6D9D6122h]
    mov edi, esi
    rol eax, 10h
    add eax, esi
    xor edi, eax
    xor ebx, edi
    add ebx, edx
    mov edx, dword ptr [tmpTbl+3Ch]
    lea edx, [ebx+edx-21AC7F4h]
    rol edx, 17h
    add edx, eax
    mov ebx, edx
    xor ebx, edi
    mov edi, eax
    add ebx, ecx
    mov ecx, dword ptr [tmpTbl+24h]
    xor edi, edx
    lea ecx, [ebx+ecx-5B4115BCh]
    rol ecx, 4
    add ecx, edx
    xor edi, ecx
    mov ebx, ecx
    add edi, esi
    mov esi, dword ptr [tmpTbl+14h]
    lea esi, [edi+esi+4BDECFA9h]
    rol esi, 0Bh
    add esi, ecx
    mov edi, esi
    xor edi, edx
    xor edi, ecx
    add edi, eax
    mov eax, dword ptr [tmpTbl+38h]
    lea eax, [edi+eax-944B4A0h]
    mov edi, esi
    rol eax, 10h
    add eax, esi
    xor edi, eax
    xor ebx, edi
    add ebx, edx
    mov edx, dword ptr [tmpTbl+28h]
    lea edx, [ebx+edx-41404390h]
    rol edx, 17h
    add edx, eax
    mov ebx, edx
    xor ebx, edi
    mov edi, eax
    add ebx, ecx
    mov ecx, dword ptr [tmpTbl+18h]
    xor edi, edx
    lea ecx, [ebx+ecx+289B7EC6h]
    rol ecx, 4
    add ecx, edx
    xor edi, ecx
    add edi, esi
    mov esi, dword ptr [tmpTbl+4]
    lea esi, [edi+esi-155ED806h]
    rol esi, 0Bh
    add esi, ecx
    mov ebx, ecx
    mov edi, esi
    xor edi, edx
    xor edi, ecx
    add edi, eax
    mov eax, dword ptr [tmpTbl+2Ch]
    lea eax, [edi+eax-2B10CF7Bh]
    mov edi, esi
    rol eax, 10h
    add eax, esi
    xor edi, eax
    xor ebx, edi
    add ebx, edx
    mov edx, dword ptr [tmpTbl+1Ch]
    lea edx, [ebx+edx+4881D05h]
    rol edx, 17h
    add edx, eax
    mov ebx, edx
    xor ebx, edi
    mov edi, eax
    add ebx, ecx
    mov ecx, dword ptr [tmpTbl+0Ch]
    xor edi, edx
    lea ecx, [ebx+ecx-262B2FC7h]
    mov ebx, dword ptr [tmpTbl+08h]
    rol ecx, 4
    add ecx, edx
    xor edi, ecx
    add edi, esi
    mov esi, dword ptr [tmpTbl+30h]
    lea esi, [edi+esi-1924661Bh]
    rol esi, 0Bh
    add esi, ecx
    mov edi, esi
    xor edi, edx
    xor edi, ecx
    add edi, eax
    mov eax, dword ptr [tmpTbl]
    lea edi, [edi+eax+1FA27CF8h]
    mov eax, esi
    rol edi, 10h
    add edi, esi
    xor eax, edi
    xor eax, ecx
    add eax, edx
    lea edx, [eax+ebx-3B53A99Bh]
    mov eax, esi
    rol edx, 17h
    add edx, edi
    not eax
    or eax, edx
    xor eax, edi
    add eax, ecx
    mov ecx, dword ptr [tmpTbl+4]
    lea ecx, [eax+ecx-0BD6DDBCh]
    mov eax, edi
    rol ecx, 6
    add ecx, edx
    not eax
    or eax, ecx
    xor eax, edx
    add eax, esi
    mov esi, dword ptr [tmpTbl+38h]
    lea esi, [eax+esi+432AFF97h]
    mov eax, edx
    rol esi, 0Ah
    add esi, ecx
    not eax
    or eax, esi
    xor eax, ecx
    add eax, edi
    mov edi, dword ptr [tmpTbl+3Ch]
    lea edi, [eax+edi-546BDC59h]
    mov eax, ecx
    rol edi, 0Fh
    add edi, esi
    not eax
    or eax, edi
    xor eax, esi
    add eax, edx
    mov edx, dword ptr [tmpTbl+34h]
    lea edx, [eax+edx-36C5FC7h]
    mov eax, esi
    rol edx, 15h
    add edx, edi
    not eax
    or eax, edx
    xor eax, edi
    add eax, ecx
    mov ecx, dword ptr [tmpTbl+30h]
    lea ecx, [eax+ecx+655B59C3h]
    mov eax, edi
    rol ecx, 6
    add ecx, edx
    not eax
    or eax, ecx
    xor eax, edx
    add eax, esi
    mov esi, dword ptr [tmpTbl+2Ch]
    lea esi, [eax+esi-70F3336Eh]
    mov eax, edx
    rol esi, 0Ah
    add esi, ecx
    not eax
    or eax, esi
    xor eax, ecx
    add eax, edi
    mov edi, dword ptr [tmpTbl+28h]
    lea edi, [eax+edi-100B83h]
    mov eax, ecx
    rol edi, 0Fh
    add edi, esi
    not eax
    or eax, edi
    xor eax, esi
    add eax, edx
    mov edx, dword ptr [tmpTbl+24h]
    lea edx, [eax+edx-7A7BA22Fh]
    mov eax, esi
    rol edx, 15h
    add edx, edi
    not eax
    or eax, edx
    xor eax, edi
    add eax, ecx
    mov ecx, dword ptr [tmpTbl+20h]
    lea ecx, [eax+ecx+6FA87E4Fh]
    mov eax, edi
    rol ecx, 6
    add ecx, edx
    not eax
    or eax, ecx
    xor eax, edx
    add eax, esi
    mov esi, dword ptr [tmpTbl]
    lea eax, [eax+esi-1D31920h]
    mov esi, edx
    rol eax, 0Ah
    add eax, ecx
    not esi
    or esi, eax
    xor esi, ecx
    add esi, edi
    mov edi, dword ptr [tmpTbl+1Ch]
    lea esi, [esi+edi-5CFEBCECh]
    mov edi, ecx
    rol esi, 0Fh
    add esi, eax
    not edi
    or edi, esi
    xor edi, eax
    add edi, edx
    mov edx, dword ptr [tmpTbl+18h]
    lea edx, [edi+edx+4E0811A1h]
    mov edi, eax
    rol edx, 15h
    add edx, esi
    not edi
    or edi, edx
    xor edi, esi
    add edi, ecx
    mov ecx, dword ptr [tmpTbl+14h]
    lea ecx, [edi+ecx-8AC817Eh]
    mov edi, esi
    rol ecx, 6
    add ecx, edx
    not edi
    or edi, ecx
    xor edi, edx
    add edi, eax
    mov eax, dword ptr [tmpTbl+10h]
    lea eax, [edi+eax-42C50DCBh]
    mov edi, edx
    rol eax, 0Ah
    add eax, ecx
    not edi
    or edi, eax
    xor edi, ecx
    add edi, esi
    lea esi, [edi+ebx+2AD7D2BBh]
    mov edi, ecx
    rol esi, 0Fh
    add esi, eax
    not edi
    or edi, esi
    xor edi, eax
    add edi, edx
    mov edx, dword ptr [tmpTbl+0Ch]
    lea edx, [edi+edx-14792C6Fh]
    mov edi, dword ptr [magicTbl+0]
    rol edx, 15h
    add ecx, edi
    mov dword ptr [magicTbl+0], ecx
    lea ecx, dword ptr [esi+edx]
    add ecx, dword ptr [magicTbl+4]
    mov dword ptr [magicTbl+4], ecx
    mov ecx, dword ptr [magicTbl+8]
    add esi, ecx
    mov ecx, dword ptr [magicTbl+0Ch]
    add eax, ecx
    mov dword ptr [magicTbl+8], esi
    mov dword ptr [magicTbl+0Ch], eax
    ret
genMagic endp

enCxc proc uses ecx esi edi CxcBuffer:DWORD, CxcLen:DWORD, NameBuffer:DWORD, NameLen:DWORD
    mov eax, CxcLen
    mov cl, 2
    shr eax, cl
    mov ecx, eax
    mov eax, CxcBuffer
    mov esi, 0CA11ACABh
chkEn:
    test ecx, ecx
    jz endEnCxc
    xor dword ptr[eax], esi
    mov esi, dword ptr [eax]
    add eax, 4
    dec ecx
    jmp chkEn
endEnCxc:
    invoke lstrcpy, ADDR strFile, NameBuffer
    invoke lstrcat, ADDR strFile, ADDR cxcExt
    invoke CreateFile, ADDR strFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hFile, eax
    
    mov dword ptr [strTmp], 47414333h
    mov eax, NameLen
    mov dword ptr [strTmp+4], eax
    invoke WriteFile, hFile, ADDR strTmp, 8, ADDR tmpDW, 0
    invoke WriteFile, hFile, NameBuffer, NameLen, ADDR tmpDW, 0
    mov eax, CxcLen    
    mov dword ptr [strTmp], eax
    invoke WriteFile, hFile, ADDR strTmp, 4, ADDR tmpDW, 0
    invoke WriteFile, hFile, CxcBuffer, CxcLen, ADDR tmpDW, 0
    invoke CloseHandle, hFile
    ret
enCxc endp

setChkSum proc uses ecx edx CxcBuffer:DWORD 
      xor ecx, ecx
      mov eax, CxcBuffer
      add eax, 4
loopSet:
      mov edx, dword ptr [magicTbl+ecx*4]
      mov dword ptr [eax+ecx*4], edx
      inc cl
      cmp cl, 4
      jne loopSet
      ret
setChkSum endp

verChkSum proc uses ecx edx CxcBuffer:DWORD
    xor ecx, ecx
    mov eax, CxcBuffer
    add eax, 4
loopVerify:
    mov edx, dword ptr [eax+ecx*4]
    cmp dword ptr [magicTbl+ecx*4], edx
    jne endVerify
    inc cl
    cmp cl, 4
    jne loopVerify
    mov eax, TRUE
    ret
endVerify:
    mov eax, FALSE
    ret    
verChkSum endp    

getCccName proc uses ebx ecx edx CxcBuffer:DWORD, NameBuffer:DWORD, NameLen:DWORD
    mov eax, CxcBuffer
    mov edx, dword ptr [eax+74h]
    mov ecx, NameLen
    mov dword ptr [ecx], edx
    add eax, 78h
    mov ecx, NameBuffer
    mov byte ptr [ecx+edx],0
loopName:    
    cmp edx, 0
    jl endName
    dec edx
    mov bl, byte ptr [eax+edx]
    mov byte ptr [ecx+edx], bl
    jmp loopName
endName:
    ret    
getCccName endp
end start