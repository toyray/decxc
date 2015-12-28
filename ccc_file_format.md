## CCC File Format Specification

```
0x00000000	Length of Checksum
0x00000004	Checksum (16 bytes)
0x00000014	File Header (AOAG)
0x00000018	0x00000002
0x0000001C	0x00000001
0x00000020	0x00000002
0x00000024	0x00000000
0x00000028	0x00000000
0x0000002C	0x00000000
0x00000030	0x00000000
0x00000034	0x00000000
0x00000038	0x00000000
0x0000003C	0x00000000
0x00000040	0x00000000
0x00000044	0x00000014
0x00000048	0x00000000
0x0000004C	0x00000001
0x00000050	0x00000001
0x00000054	0x00000002
0x00000058	0x00000001
0x0000005C	0x00000002
0x00000060	"CM",0x02,0x00
0x00000064	0x00000001
0x00000068	0x00000000
0x0000006C	0x00200011
0x00000070	0x00000001
0x00000074	Length of Character Name
0x00000078	Character Name

+ 0x00000000	0x00000001

OPTIONAL FOR PASSWORD-PROTECTED CHARACTER FILES
+ 0x00000000	Length of Password (0 = No Password)
+ 0x00000004	Password (DWORD(s) not present if No Password)

+ 0x00000000	0x00000001
+ 0x00000004	0x00000000
+ 0x00000008	Registration (Yes = 1, No = 0)
+ 0x0000000C	Starter Deck (Default = 0, 1st Edition = 3B9F8D53)
+ 0x00000010	0x00000000
+ 0x00000014	Character Sex (Male = 0, Female = 1)
+ 0x00000018	0x00000001
+ 0x0000001C	0x00100001
+ 0x00000020	0x00000001
+ 0x00000024	Length of Card Collection Name
+ 0x00000028	Card Collection Name (Default = Not Present, 1st Edition = NewDeck)
	
+ 0x00000000	Number of Cards in Collection
+ 0x00000004	Card Codes

+ 0x00000000	0x00000001
+ 0x00000004	0x00000004
+ 0x00000008	0x00000001
+ 0x0000000C	Number of Boxes and Decks (Default = 2, After clicking on Manage Decks = 3)
+ 0x00000010	Section Number (= 03)
+ 0x00000014	0x00100001
+ 0x00000018	0x00000001
+ 0x0000001C	Length of Deck Name 
+ 0x00000020	Deck Name (Default = Default Deck)
+ 0x0000002C	Number of Cards in Deck
+ 0x00000030	Card Codes

+ 0x00000000	0x00000001
+ 0x00000004	Section Number (= 04)
+ 0x00000008	0x00100001
+ 0x0000000C	0x00000001
+ 0x00000010	Length of "%Storage Box" (= 0C)
+ 0x00000014	"%Storage Box"
+ 0x00000020	Number of Cards in Storage Box
+ 0x00000024	Card Codes

+ 0x00000000	0x00000001
+ 0x00000004	Section Number (= 05)
+ 0x00000008	0x00100001
+ 0x0000000C	0x00000001
+ 0x00000010	Length of "%GiveTo Box" (= 0B)
+ 0x00000014	"%GiveTo Box",03
+ 0x00000020	Number of Cards in GiveTo Box
+ 0x00000024	Card Codes

+ 0x00000000	0x00000001
+ 0x00000004	0x00000004
+ 0x00000008	0x00000001
+ 0x0000000C	Number of Scrap Piles
+ 0x00000010	Section Number (= 06)
+ 0x00000014	0x0100002F
+ 0x00000020	0x00000004
+ 0x00000024	0x00000001
+ 0x00000000	0x00000003
+ 0x00000004	Section Number (= 07)
+ 0x00000008	0x00000001
+ 0x0000000C	0x00000001
+ 0x00000010	Length of "Scrap Pile" (=0x0A)
+ 0x00000014	"Scrap Pile",0x02h,0x00
+ 0x00000020	Number of Cards in Scrap Pile
+ 0x00000024	Card Codes

+ 0x00000000	0x00000001
+ 0x00000004	Section Number (= 08)
+ 0x00000008	0x00100001
+ 0x0000000C	0x00000001
+ 0x00000010	Length of "Scrap Pile" (=0x0A)
+ 0x00000014	"Scrap Pile",0x02h,0x00
+ 0x00000020	Number of Cards in Scrap Pile
+ 0x00000024	Card Codes

+ 0x00000000	0x00000001
+ 0x00000004	Section Number (= 09)
+ 0x00000008	0x00100001
+ 0x0000000C	0x00000001
+ 0x00000010	Length of "Scrap Pile" (=0x0A)
+ 0x00000014	"Scrap Pile",0x02h,0x00
+ 0x00000020	Number of Cards in Scrap Pile
+ 0x00000024	Card Codes

+ 0x00000000	0x00000000
+ 0x00000004	0x00000001
+ 0x00000008	0x00000003
+ 0x0000000C	0x00000001	
+ 0x00000010	0x00000001	
+ 0x00000014	0x00000001	
+ 0x00000018	0x00000000	
+ 0x0000001C	0x00000000
+ 0x00000020	0x00000000
+ 0x00000024	0x00000000
+ 0x00000028	0x00000000
+ 0x0000002C	0x00000000
+ 0x00000030	Section Number (= 0A)
+ 0x00000034	0x0010002F
+ 0x00000038	0x00000004
+ 0x0000003C	0x00000001
+ 0x00000040	0x00000000
+ 0x00000044	0x00000000
+ 0x00000048	0x00000000
+ 0x0000004C	0x00000000
+ 0x00000050	0x00000000
+ 0x00000054	0x00000000
+ 0x00000058	0x00000000
+ 0x0000005C	0x00000000
+ 0x00000060	0x00000000
+ 0x00000064	0x00000000
+ 0x00000068	0x00000000
+ 0x0000006C	Section Number (= 0B)
+ 0x00000070	0x0010002F
+ 0x00000074	0x00000004
+ 0x00000078	0x00000001
+ 0x00000080	0x00000000
+ 0x00000084	0x00000000
+ 0x00000088	0x00000000
+ 0x0000008C	0x00000000
+ 0x00000080	0x00000000
+ 0x00000084	0x00000000
+ 0x00000088	0x00000000
+ 0x0000008C	0x00000000
+ 0x00000090	0x00000000
+ 0x00000094	0x00000000
+ 0x00000098	0x00000000
+ 0x0000009C	0x00000003
+ 0x000000A0	0x00000000	
+ 0x000000A4	0x00000000
+ 0x000000A8	0x00000000
+ 0x000000AC	0x00000015
+ 0x000000B0	0x00000000
+ 0x000000B4	0x00000001
+ 0x000000B8	Length of Current Box (Default = 0x11, 1st Edition = 0x15)
+ 0x000000BC	Current Box 09090909,  (Default = 0x09,0x09,0x09,0x09,"Default Deck", 1st Edition = 					0x09,"Open",0x09,0x09,0x09,"Default Deck")

+ 0x00000000	0x00000109
+ 0x00000004	0x00000000
+ 0x00000008	0x00000003
+ 0x0000000C	0x00000000
+ 0x00000010	0x00000000
+ 0x00000014	0x00000001
+ 0x00000018	Length of Unknown Constant (= 0x21)
+ 0x0000001C	"100031214779878-025-0002577-16340",0x01

+ 0x00000000	0x00000001
+ 0x00000008	0x00000000
+ 0x0000000C	0x00000000
+ 0x00000010	0x00000000
+ 0x00000014	0x00000000
+ 0x00000018	0x00000000
```

## NOTES

- All strings are stored in DWORDs. If the DWORD is not used fully, the string is appended wtih a byte indicating the number of used bytes in the the DWORDs

- %GiveTo Box section is only generated if an unofficial deck is saved

- Default refers to a randomly-generated starter deck whereas 1st Edition refers to the starter deck generated when app is connected to the Internet when generating a new character. 1st Edition starter decks contain at least 20 Base cards whereas the number of Base cards in Default starter decks is not constant. All decks contain 4 Rare cards and 56 Uncommon and Common cards

- Card codes are in the following format `STTT00`
	- S refers to the card series number (1st Edition = 1, Overture = 2, Ascension = 3, Defiance = 4, Special = 5,6, Whiteout = 7 Breakpoint = 8)
 	- TTT refers to the card type (Asset = 040, Base & HQ = 080, Program = 0C0, Enhancements = 100, Interventions = 140)
 	- 00 refers to the card number (from 00 to 0F - not all numbers are assigned cards and not all cards assigned are usable cards - some are created by other cards in play are do not exist standalone)	

- Every 4 booster packs are guaranteed to generate 1 Very Rare card and 7 Rare cards

- Additional scrap piles created after generation of characters appends extra scarp pile sections and the number of scrap pile sections is not consistent so the format of the additional scrap pile section is shown below

```
0x00000000	0x00000001
0x00000004	0x0000000B	- First additional scrap pile section starts at 0x0B
0x00000008	0x00100001
0x0000000C	0x00000001
0x00000010	Length of scrap pile (=0A)
0x00000014	"Scrap Pile",0x02, 0x00
0x00000018	Number of cards in Scrap Pile
0x0000001C	Card Codes
```

## Checksum Function

- checksum function is found at 100B6769 in CXMain.DLL
- checksum is calculated on all bytes in the CCC file except the first 20 bytes
- 0x80 is appended to the end of the file as a DWORD
- if the number of checksumed bytes modulus 64 is less than 52, the number of checksummed bytes multipled by 8 replaces the second last DWORD of the last 64 bytes, otherwise a new set of 64 bytes is added to the checksummed bytes with the second last DWORD of the new set being replaced.
- the Magic supplied to the checksum function is 32 bytes, 0x67452301, 0xEFCDAB89, 0x98BADCFE and 0x10325476
- the calculated checksum must match the checksum of the CCC file otherwise the app will not load the character file
- checksum function is either a MD5 one-way hash or a MD5 message authenication code system