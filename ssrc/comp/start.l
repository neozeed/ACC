0000                    	use16
0000                    
0000                    STACKLEN:	equ	$800	; size of stack in paragraphs
0000                    
0000                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0000 eb16               start:	jmp	short skip
0002 d01f               startsize	dw	endstart-start
0004 00000000           mainloc	dd	_main  ;4
0008 00000000           _code32a	dd	0    ;8		; base address of 32bit data segment
000c 00000000           _lowheapbase	dd	0   ;12		; relative base of free low memory
0010 00000000           _lowheaplen	dd	0  ;16		; size of free low memory
0014 00000000           _lowtemp:	dd	0  ;20	;4K block of low memory
0018                    
0018 bc0080             skip:	mov	sp,STACKLEN*16
001b 0e                 	push cs 			; DS = CS
001c 1f                 	pop ds
001d 8c063301           	mov	psp,es
0021 8c0e3501           	mov	_code32s,cs
0025 8c163101           	mov	sseg,ss
0029                    
0029 660fb7163501       	movzx	edx,word _code32s
002f 66c1e204           	shl	edx,4
0033 6689160800         	mov	_code32a,edx
0038                    
0038 e85703             	call _pm_info			; get information
003b                    
003b 7316               	jnc short startf0		; if no error, go on
003d                    
003d                    startf1:
003d 8bf0               	mov si,ax			; print error message for code AX
003f 03f0               	add si,ax
0041 8b943701           	mov dx,[si+errmsgtbl]
0045 b409               	mov ah,9
0047 cd21               	int $21
0049 b8ff4c             	mov ax,$4cff
004c cd21               	int $21
004e                    
004e 33c0               nomem:	xor	ax,ax
0050 e9eaff             	jmp	startf1
0053                    
0053                    startf0:
0053 33c0               	xor ax,ax			; check low memory and allocate low
0055 8cd1               	mov cx,ss			;  buffer needed for protected mode
0057 81c10008           	add cx,STACKLEN
005b 66260fb7160200     	movzx edx,word es:[2]
0062 2bd1               	sub dx,cx
0064 3bd3               	cmp dx,bx
0066 0f82d3ff           	jb startf1
006a 8ec1               	mov es,cx
006c                    
006c 03cb               	add cx,bx
006e 660fb7c9           	movzx ecx,cx		; calculate base and size of free low
0072 66c1e104           	shl ecx,4			;  memory and push to stack
0076 66890e0c00         	mov _lowheapbase,ecx
007b 2bd3               	sub dx,bx
007d 66c1e204           	shl edx,4
0081 6689161000         	mov _lowheaplen,edx
0086                    
0086 66a10c00           	mov	eax,_lowheapbase
008a 662b060800         	sub	eax,_code32a
008f 66a31400           	mov	_lowtemp,eax
0093 6681c000210000     	add	eax,8192+256 ;256=argcv
009a 66a30c00           	mov	_lowheapbase,eax
009e 66812e1000002101   	sub	long _lowheaplen,256+8192+$10000
00a6 00
00a7 0f82a3ff           	jc	nomem
00ab                    
00ab                    
00ab e82d04             	call _pm_init			; enter protected mode
00ae                    
00ae 0f828bff           	jc startf1			; if error, go to error message
00b2                    
00b2 b90100             	mov cx,1			; allocate 1 descriptor
00b5 33c0               	xor ax,ax
00b7 cd31               	int $31
00b9                    
00b9 8bd8               	mov bx,ax			; BX = descriptor allocated
00bb                    
00bb baffff             	mov dx,$ffff		   ; set size to 4G
00be 8bca               	mov cx,dx
00c0 b80800             	mov ax,8
00c3 cd31               	int $31
00c5                    
00c5 660fb7163501       	movzx	edx,word _code32s
00cb 66c1e204           	shl	edx,4
00cf 660fa4d110         	shld ecx,edx,16
00d4 b80700             	mov ax,7
00d7 cd31               	int $31
00d9                    
00d9 8cc8               	mov ax,cs			; set descriptor type to 32bit code
00db 0f02c8             	lar cx,ax			;  at the current CPL
00de 8acd               	mov cl,ch
00e0 b5c0               	mov ch,$c0
00e2 b80900             	mov ax,9
00e5 cd31               	int $31
00e7                    
00e7 8beb               	mov bp,bx			; preserve selector
00e9                    
00e9 8cdb               	mov bx,ds			; BX = current data selector
00eb                    
00eb baffff             	mov dx,$ffff		   ; set size to 4G
00ee 8bca               	mov cx,dx
00f0 b80800             	mov ax,8
00f3 cd31               	int $31
00f5                    
00f5 660fb7163501       	movzx	edx,word _code32s
00fb 66c1e204           	shl	edx,4
00ff 660fa4d110         	shld ecx,edx,16
0104 b80700             	mov ax,7
0107 cd31               	int $31
0109                    
0109                    
0109 fa                 	cli			     ; we don't want to be interrupted
010a                    				;  while changing SS:ESP
010a 8edb               	mov ds,bx			; set all segment registers to data
010c 8ec3               	mov es,bx			;  selector
010e 8ee3               	mov fs,bx
0110 8eeb               	mov gs,bx
0112 8ed3               	mov ss,bx
0114                    
0114 a13101             	mov ax,sseg
0117 2b063501           	sub ax,_code32s
011b 660fb7c0           	movzx eax,ax
011f 66c1e004           	shl eax,4
0123 6603e0             	add esp,eax
0126                    
0126 fb                 	sti
0127                    
0127 6655               	push ebp			; push target CS:EIP in 32bit code
0129 6668               	db $66,$68
012b f11d0000           	dd start32
012f                    
012f 66                 	db $66				; 32bit RETF to 32bit code
0130 cb                 	retf
0131                    
0131                    
0131 0000               sseg:	dw	0
0133 0000               psp	dw	0
0135 0000               _code32s	dw	0
0137                    
0137 45015e017e01bc01   errmsgtbl	dw	errmsg0,errmsg1,errmsg2,errmsg3
013f d601f3012002       	dw	errmsg4,errmsg5,errmsg6
0145                    
0145 4e6f7420656e6f75   errmsg0	db	'Not enough low memory!',13,10,36
014d 6768206c6f77206d
0155 656d6f7279210d0a
015d 24
015e 3830333836206f72   errmsg1	db	'80386 or better not detected!',13,10,36
0166 2062657474657220
016e 6e6f742064657465
0176 63746564210d0a24
017e 53797374656d2061   errmsg2	db	'System already in protected mode and no VCPI or DPMI found!',13,10,36
0186 6c72656164792069
018e 6e2070726f746563
0196 746564206d6f6465
019e 20616e64206e6f20
01a6 56435049206f7220
01ae 44504d4920666f75
01b6 6e64210d0a24
01bc 44504d4920686f73   errmsg3	db	'DPMI host is not 32bit!',13,10,36
01c4 74206973206e6f74
01cc 203332626974210d
01d4 0a24
01d6 436f756c64206e6f   errmsg4	db	'Could not enable A20 gate!',13,10,36
01de 7420656e61626c65
01e6 2041323020676174
01ee 65210d0a24
01f3 436f756c64206e6f   errmsg5	db	'Could not enter DPMI 32bit protected mode!',13,10,36
01fb 7420656e74657220
0203 44504d4920333262
020b 69742070726f7465
0213 63746564206d6f64
021b 65210d0a24
0220 436f756c64206e6f   errmsg6	db	'Could not allocate needed DPMI selectors!',13,10,36
0228 7420616c6c6f6361
0230 7465206e65656465
0238 642044504d492073
0240 656c6563746f7273
0248 210d0a24
024c                    
024c                    ; PMODE v3.07 DPMI/VCPI/XMS/raw protected mode interface kernel.
024c                    ; Copyright (c) 1994, Tran (a.k.a. Thomas Pytel).
024c                    
024c                    
024c                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
024c                    ; DATA
024c                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
024c                    SELCODE         equ $08                   ; code32s code selector
024c                    SELZERO         equ $10                   ; selector of entire memory space
024c                    SELCALLBACKDS   equ $18                   ; callback DS selector
024c                    SELREAL         equ $20                   ; real mode attributes selector
024c                    SELVCPITSS      equ $28                   ; TSS selector for VCPI
024c                    SELVCPICODE     equ $30                   ; VCPI call code selector
024c                    SYSSELECTORS    equ 9                     ; number of system selectors in GDT
024c                    
024c                    	align	4
024c 00000000           dpmiepmode      dd      0               ; DPMI enter pmode addx
0250 00000000           codebase        dd      0               ; code32s linear address
0254 d0020000           vcpistrucaddx   dd      vcpi_cr3    ; VCPI switch structure linear address
0258 00000000           vcpiswitchstack dd      0               ; VCPI temporary mode switch stack
025c 00000000           oldint15vector  dd      0               ; preserved INT 15h vector
0260 ba0c0000           int3vector      dd      intrmatrix+3    ; protected mode INT 3 vector
0264 0800               	dw      SELCODE
0266 0000               	dw      0               ; just here for alignment
0268                    
0268 00000000           pmstacklen      dd      0               ; protected mode stack length in bytes
026c 00000000           pmstackbase	dd	0		; bottom of protected mode stack area
0270 00000000           pmstacktop      dd      0               ; top of protected mode stack area
0274 00000000           callbackbase    dd      0               ; base of real mode callbacks
0278 0000               callbackseg     dw      0               ; segment of callbacks
027a                    
027a 1000               selzero         dw      SELZERO         ; for immediate segreg loading
027c 1800               selcallbackds   dw      SELCALLBACKDS   ; for immediate segreg loading
027e                    
027e 0100               rawextmemused   dw      1               ; raw extended memory used in K
0280 ffffffff           rawextmembase   dd      $0ffffffff      ; raw extended memory base
0284 00000000           rawextmemtop    dd      0               ; raw extended memory top
0288                    
0288 0000               rmstackbase     dw      0               ; bottom of real mode stack area
028a 0000               rmstacktop      dw      0               ; top of real mode stack area
028c 0000               rmstackparmtop  dw      0               ; for functions 0300h, 0301h, 0302h
028e                    
028e 0000               gdtseg          dw      0               ; segment of GDT
0290                    
0290 0000               gdtlimit        dw      0               ; GDT limit                          |
0292 00000000           gdtbase         dd      0               ; GDT base                           |
0296 ff07               idtlimit        dw      $7ff            ; IDT limit                         |
0298 00000000           idtbase         dd      0               ; IDT base                          |
029c ff03               rmidtlimit      dw      $3ff            ; real mode IDT limit                |
029e 00000000           rmidtbase       dd      0               ; real mode IDT base                 |
02a2                    
02a2 340a               rmtopmswrout    dw      v_rmtopmsw  ; addx of real to protected routine
02a4 760a0000           pmtormswrout    dd      v_pmtormsw  ; addx of protected to real routine
02a8                    
02a8 00000000           pagetablebase   dd      0               ; base of page table area
02ac 00000000           pagetabletop    dd      0               ; top of page table area
02b0 00000000           pagetablefree   dd      0               ; base of available page table area
02b4 00                 	db      0               ; just here for alignment
02b5                    
02b5 02                 _pm_pagetables  db      2               ; number of page tables under VCPI
02b6 4000               _pm_selectors   dw      64              ; max selectors under VCPI/XMS/raw
02b8 4000               _pm_rmstacklen  dw      $40             ; real mode stack length, in para
02ba 8000               _pm_pmstacklen  dw      $80             ; protected mode stack length, in para
02bc 04                 _pm_rmstacks    db      4               ; real mode stack nesting
02bd 02                 _pm_pmstacks    db      2               ; protected mode stack nesting
02be 10                 _pm_callbacks   db      16              ; number of real mode callbacks
02bf 01                 _pm_mode        db      1               ; mode bits
02c0                    
02c0 00                 processortype   db      0               ; processor type                     |
02c1 02                 pmodetype       db      2               ; protected mode type                |
02c2 70                 picslave        db      $70             ; PIC slave base interrupt          |
02c3 08                 picmaster       db      8               ; PIC master base interrupt         |
02c4                    
02c4                    tempd0  ;        label   long           ; temporary variables                |
02c4                    tempw0  ;        label   word            ;                                    |
02c4 00                 tempb0          db      0               ;                                    |
02c5 00                 tempb1          db      0               ;                                    |
02c6                    tempw1 ;          label   word            ;                                    |
02c6 00                 tempb2          db      0               ;                                    |
02c7 00                 tempb3          db      0               ;                                    |
02c8                    tempd1  ;        label   long           ;                                    |
02c8                    tempw2  ;        label   word            ;                                    |
02c8 00                 tempb4          db      0               ;                                    |
02c9 00                 tempb5          db      0               ;                                    |
02ca                    tempw3   ;       label   word            ;                                    |
02ca 00                 tempb6          db      0               ;                                    |
02cb 00                 tempb7          db      0               ;                                    |
02cc                    
02cc 0000               xms_callip      dw      0               ; XMS driver offset                 |
02ce 0000               xms_callcs      dw      0               ; XMS driver segment                |
02d0                    
02d0 00000000           vcpi_cr3        dd      0               ; VCPI CR3 value for protected mode  |
02d4 90020000           vcpi_gdtaddx    dd      gdtlimit    ; linear addx of GDT limit and base  |
02d8 96020000           vcpi_idtaddx    dd      idtlimit    ; linear addx of IDT limit and base  |
02dc 0000               vcpi_selldt     dw      0               ; LDT selector for protected mode    |
02de 2800               vcpi_seltss     dw      SELVCPITSS      ; TSS selector for protected mode    |
02e0 4d0a0000           vcpi_eip        dd      v_rmtopmswpm; destination EIP in protected mode  |
02e4 0800               vcpi_cs         dw      SELCODE         ; destination CS in protected mode   |
02e6                    
02e6 00000000           vcpi_calleip    dd      0               ; VCPI protected mode call offset   |
02ea 3000               vcpi_callcs     dw      SELVCPICODE     ; VCPI protected mode call selector |
02ec                    
02ec f408b40866050905   initrouttbl     dw      r_init, x_init, v_init, d_init
02f4                    
02f4 0009010902090000   int31functbl    dw      $0900, $0901, $0902, $0000, $0001, $0003, $0006, $0007
02fc 0100030006000700
0304 0800090000020102   	dw      $0008, $0009, $0200, $0201, $0204, $0205, $0305, $0306
030c 0402050205030603
0314 0004               	dw      $0400
0316 0a000b000c000e00   	dw      $000a, $000b, $000c, $000e, $000f
031e 0f00
0320 000301030203       	dw      $0300, $0301, $0302
0326 03030403           	dw      $0303, $0304
032a 0005010502050305   	dw      $0500, $0501, $0502, $0503, $050a
0332 0a05
0334                    INT31FUNCNUM    equ (*-int31functbl)/2
0334                    
0334 d712e912fb12a010   int31routtbl    dw      int310900, int310901, int310902, int310000
033c f21019111f113411   	dw      int310001, int310003, int310006, int310007
0344 4911791137124e12   	dw      int310008, int310009, int310200, int310201
034c 651295121d153715   	dw      int310204, int310205, int310305, int310306
0354 5115               	dw      int310400
0356 9811c911df110912   	dw      int31000a, int31000b, int31000c, int31000e, int31000f
035e 3112
0360 0d131c131c13       	dw      int310300, int310301, int310302
0366 9b14e414           	dw      int310303, int310304
036a 9716a916df16f016   int31mrouttbl   dw      int310500v, int310501v, int310502v, int310503v
0372 9f18               	dw      int31050av
0374 8d19a819df19fa19   int31mxrouttbl  dw      int310500x, int310501x, int310502x, int310503x
037c 251a               	dw      int31050ax
037e 161b421bb91bf21b   int31mrrouttbl  dw      int310500r, int310501r, int310502r, int310503r
0386 d41d               	dw      int31050ar
0388 651ace0fa10f       int31mnrouttbl  dw      int310500rnomem, int31fail8013, int31fail8023
038e a10fa10f           	dw      int31fail8023, int31fail8023
0392                    
0392                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
0392                    ; DETECT/INIT CODE
0392                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
0392                    
0392                    ;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
0392                    ; Get protected mode info
0392                    ; Out:
0392                    ;   AX = return code:
0392                    ;     0000h = successful
0392                    ;     0001h = no 80386+ detected
0392                    ;     0002h = system already in protected mode and no VCPI or DPMI found
0392                    ;     0003h = DPMI - host is not 32bit
0392                    ;   CF = set on error, if no error:
0392                    ;     BX = number of paragraphs needed for protected mode data (may be 0)
0392                    ;     CL = processor type:
0392                    ;       02h = 80286
0392                    ;       03h = 80386
0392                    ;       04h = 80486
0392                    ;       05h = 80586
0392                    ;       06h-FFh = reserved for future use
0392                    ;     CH = protected mode type:
0392                    ;       00h = raw
0392                    ;       01h = XMS
0392                    ;       02h = VCPI
0392                    ;       03h = DPMI
0392                    ;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
0392                    _pm_info:
0392 525657551e065351   	push dx si di bp ds es bx cx    ; preserve registers
039a                    
039a 0e                 	push cs                         ; DS = CS (code32s)
039b 1f                 	pop ds
039c                    
039c f606bf0201         	test byte _pm_mode,1                 ; check order of DPMI/VCPI detection
03a1 7408               	jz short infof0
03a3                    
03a3 e89700             	call detect_VCPI              ; check for VCPI first
03a6 e86800             	call detect_DPMI              ; check for DPMI second
03a9 eb06               	jmp short infof2              ; neither found, go on to XMS check
03ab                    
03ab                    infof0:
03ab e86300             	call detect_DPMI              ; check for DPMI first
03ae e88c00             	call detect_VCPI              ; check for VCPI second
03b1                    
03b1                    ;-----------------------------------------------------------------------------
03b1                    infof2:
03b1 0f01e0             	smsw ax                         ; AX = machine status word
03b4 a801               	test al,1                       ; is system in protected mode?
03b6 b80200             	mov ax,2                        ; error code in case protected mode
03b9 7541               	jnz short infofail            ; if in protected mode, fail
03bb                    
03bb b80043             	mov ax,$4300                    ; chek for XMS
03be cd2f               	int $2f
03c0 3c80               	cmp al,$80                      ; XMS present?
03c2 0f94c5             	sete ch                         ; if yes, pmode type is XMS
03c5                    
03c5 bb8000             	mov bx,$80                      ; BX = memory requirement (IDT)
03c8                    
03c8                    ;-----------------------------------------------------------------------------
03c8                    infof1:
03c8 0fb606bc02         	movzx ax,byte _pm_rmstacks           ; size of real mode stack area
03cd 0faf06b802         	imul ax,word _pm_rmstacklen
03d2 03d8               	add bx,ax
03d4                    
03d4 0fb606bd02         	movzx ax,byte _pm_pmstacks           ; size of protected mode stack area
03d9 0faf06ba02         	imul ax,_pm_pmstacklen
03de 03d8               	add bx,ax
03e0                    
03e0 0fb606be02         	movzx ax,_pm_callbacks          ; size of callbacks
03e5 6bc019             	imul ax,25
03e8 050f00             	add ax,$f
03eb c1e804             	shr ax,4
03ee 03d8               	add bx,ax
03f0                    
03f0 a1b602             	mov ax,_pm_selectors            ; size of GDT
03f3 050f00             	add ax,1+SYSSELECTORS+5
03f6 d1e8               	shr ax,1
03f8 03d8               	add bx,ax
03fa                    
03fa eb05               	jmp short infook              ; go to done ok
03fc                    
03fc                    ;-----------------------------------------------------------------------------
03fc                    infofail:
03fc 595b               	pop cx bx                       ; restore BX and CX
03fe f9                 	stc                             ; carry set, failed
03ff eb09               	jmp short infodone
0401                    
0401                    ;-----------------------------------------------------------------------------
0401                    infook:
0401 882ec102           	mov pmodetype,ch                ; store pmode type
0405                    
0405 83c404             	add sp,4                        ; skip BX and CX on stack
0408 33c0               	xor ax,ax                       ; success code, also clear carry flag
040a                    
040a                    ;-----------------------------------------------------------------------------
040a                    infodone:
040a 071f5d5f5e5a       	pop es ds bp di si dx           ; restore other registers
0410 c3                 	ret                            ; return
0411                    
0411                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0411                    detect_DPMI:                          ; detect a DPMI host
0411 5d                 	pop bp                          ; pop return address from stack
0412                    
0412 b88716             	mov ax,$1687                    ; check for DPMI
0415 cd2f               	int $2f
0417                    
0417 0bc0               	or ax,ax                        ; DPMI present?
0419 7520               	jnz short detect_DPMIdone     ; if no, exit routine
041b                    
041b b80300             	mov ax,3                        ; error code in case DPMI not 32bit
041e f6c301             	test bl,1                       ; is DPMI 32bit?
0421 74d9               	jz short infofail                   ; if no, fail
0423                    
0423 b80100             	mov ax,1                        ; error code in case no processor 386+
0426 80f903             	cmp cl,3                        ; is processor 386+? (redundant)
0429 0f82cfff           	jb infofail                   ; if no, fail
042d                    
042d 893e4c02           	mov word dpmiepmode,di   ; store DPMI initial mode switch addx
0431 8c064e02           	mov word dpmiepmode+2,es
0435                    
0435 8bde               	mov bx,si                       ; BX = number of paragraphs needed
0437 b503               	mov ch,3                        ; pmode type is 3 (DPMI)
0439                    
0439 ebc6               	jmp short infook                    ; go to done ok
043b                    
043b                    detect_DPMIdone:
043b ffe5               	jmp bp                          ; return to calling routine
043d                    
043d                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
043d                    detect_VCPI:                          ; detect a VCPI server
043d 5d                 	pop bp                          ; pop return address from stack
043e                    
043e e83900             	call detect_processor         ; get processor type
0441                    
0441 b80100             	mov ax,1                        ; error code in case no processor 386+
0444 80f903             	cmp cl,3                        ; is processor 386+?
0447 0f82b1ff           	jb infofail                   ; if no, no VCPI
044b                    
044b 880ec002           	mov processortype,cl            ; store processor type
044f                    
044f 33c0               	xor ax,ax                       ; get INT 67h vector
0451 8ec0               	mov es,ax
0453 26a19c01           	mov ax,es:[$67*4]
0457 260b069e01         	or ax,es:[$67*4+2]              ; is vector NULL
045c 741a               	jz short detect_VCPIdone      ; if yes, no VCPI
045e                    
045e b800de             	mov ax,$de00                   ; call VCPI installation check
0461 cd67               	int $67
0463 0ae4               	or ah,ah                        ; AH returned as 0?
0465 7511               	jnz short detect_VCPIdone     ; if no, no VCPI
0467                    
0467 0fb61eb502         	movzx bx,_pm_pagetables         ; BX = VCPI page table memory needed
046c c1e308             	shl bx,8                        ; 100h paragraphs per page table
046f 81c38602           	add bx,$100+$ff+7+$80          ; + page dir + align buf + TSS + IDT
0473                    
0473 b502               	mov ch,2                        ; pmode type is 2 (VCPI)
0475                    
0475 e950ff             	jmp infof1                    ; go to figure other memory needed
0478                    
0478                    detect_VCPIdone:
0478 ffe5               	jmp bp                          ; return to calling routine
047a                    
047a                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
047a                    detect_processor:                     ; get processor: 286, 386, 486, or 586
047a 32c9               	xor cl,cl                       ; processor type 0 in case of exit
047c                    
047c 9c                 	pushf                           ; transfer FLAGS to BX
047d 5b                 	pop bx
047e                    
047e 8bc3               	mov ax,bx                       ; try to clear high 4 bits of FLAGS
0480 80e40f             	and ah,$f
0483                    
0483 50                 	push ax                         ; transfer AX to FLAGS
0484 9d                 	popf
0485 9c                 	pushf                           ; transfer FLAGS back to AX
0486 58                 	pop ax
0487                    
0487 80e4f0             	and ah,$f0                     ; isolate high 4 bits
048a 80fcf0             	cmp ah,$f0
048d 744b               	je short detect_processordone ; if bits are set, CPU is 8086/8
048f                    
048f b102               	mov cl,2                        ; processor type 2 in case of exit
0491                    
0491 80cff0             	or bh,$f0                      ; try to set high 4 bits of FLAGS
0494                    
0494 53                 	push bx                         ; transfer BX to FLAGS
0495 9d                 	popf
0496 9c                 	pushf                           ; transfer FLAGS to AX
0497 58                 	pop ax
0498                    
0498 80e4f0             	and ah,$f0                     ; isolate high 4 bits
049b 743d               	jz short detect_processordone ; if bits are not set, CPU is 80286
049d                    
049d 41                 	inc cx                          ; processor type 3 in case of exit
049e                    
049e 66506653           	push eax ebx                    ; preserve 32bit registers
04a2                    
04a2 669c               	pushfd                          ; transfer EFLAGS to EBX
04a4 665b               	pop ebx
04a6                    
04a6 668bc3             	mov eax,ebx                     ; try to flip AC bit in EFLAGS
04a9 6681f000000400     	xor eax,$40000
04b0                    
04b0 6650               	push eax                        ; transfer EAX to EFLAGS
04b2 669d               	popfd
04b4 669c               	pushfd                          ; transfer EFLAGS back to EAX
04b6 6658               	pop eax
04b8                    
04b8 6633c3             	xor eax,ebx                     ; AC bit fliped?
04bb 7419               	jz short detect_processordone2; if no, CPU is 386
04bd                    
04bd 41                 	inc cx                          ; processor type 4 in case of exit
04be                    
04be 668bc3             	mov eax,ebx                     ; try to flip ID bit in EFLAGS
04c1 6681f000002000     	xor eax,$200000
04c8                    
04c8 6650               	push eax                        ; transfer EAX to EFLAGS
04ca 669d               	popfd
04cc 669c               	pushfd                          ; transfer EFLAGS back to EAX
04ce 6658               	pop eax
04d0                    
04d0 6633c3             	xor eax,ebx                     ; ID bit fliped?
04d3 7401               	jz short detect_processordone2; if no, CPU is 486
04d5                    
04d5 41                 	inc cx                          ; processor type 5, CPU is 586
04d6                    
04d6                    detect_processordone2:
04d6 665b6658           	pop ebx eax                     ; restore 32bit registers
04da                    
04da                    detect_processordone:
04da c3                 	ret                             ; return
04db                    
04db                    ;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
04db                    ; Initialize protected mode
04db                    ; In:
04db                    ;   ES = real mode segment for protected mode data (ignored if not needed)
04db                    ; Out:
04db                    ;   AX = return code:
04db                    ;     0000h = successful
04db                    ;     0001h = no 80386+ detected
04db                    ;     0002h = system already in protected mode and no VCPI or DPMI found
04db                    ;     0003h = DPMI - host is not 32bit
04db                    ;     0004h = could not enable A20 gate
04db                    ;     0005h = DPMI - could not enter 32bit protected mode
04db                    ;     0006h = DPMI - could not allocate needed selectors
04db                    ;   CF = set on error, if no error:
04db                    ;     ESP = high word clear
04db                    ;     CS = 16bit selector for real mode CS with limit of 64k
04db                    ;     SS = selector for real mode SS with limit of 64k
04db                    ;     DS = selector for real mode DS with limit of 64k
04db                    ;     ES = selector for PSP with limit of 100h
04db                    ;     FS = 0 (NULL selector)
04db                    ;     GS = 0 (NULL selector)
04db                    ;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
04db                    _pm_init:
04db 5351               	push bx cx                      ; get initial info on protected mode
04dd e8b2fe             	call   _pm_info
04e0 595b               	pop cx bx
04e2 7301               	jnc short initf0              ; error?
04e4                    
04e4 c3                 	ret                            ; yup, abort
04e5                    
04e5                    initf0:                               ; no error, init protected mode
04e5 6660               	pushad
04e7 1e                 	push ds
04e8 8bec               	mov bp,sp
04ea 0e                 	push cs                         ; DS = code32s
04eb 1f                 	pop ds
04ec fc                 	cld
04ed                    
04ed 660fb7063501       	movzx eax,word _code32s              ; set base addx of code32s
04f3 a35b0b             	mov c32patch,ax
04f6 66c1e004           	shl eax,4
04fa 66a35002           	mov codebase,eax
04fe                    
04fe 0fb61ec102         	movzx bx,pmodetype              ; jump to appropriate init code
0503 d1e3               	shl bx,1
0505 ffa7ec02           	jmp word [bx+initrouttbl]
0509                    
0509                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0509                    d_init:                                 ; DPMI protected mode init
0509 1f                 	pop ds                          ; get original caller DS from stack
050a b80100             	mov ax,1                        ; enter DPMI protected mode
050d 2eff1e4c02         	fcall word cs:[dpmiepmode]
0512 1e                 	push ds                         ; put DS back onto stack
0513 7312               	jnc short dvxr_init             ; error? if not, go on with init
0515                    
0515 bb0600             	mov bx,6                        ; error entering protected mode, set
0518 3d1180             	cmp ax,$8011                    ;  error code and abort
051b f9                 	stc
051c 7402               	je short init_done
051e b305               	mov bl,5                        ; error code 5, not 6
0520                    
0520                    ;-----------------------------------------------------------------------------
0520                    init_done:                              ; return with return code
0520 895e1e             	mov [bp+30],bx
0523 1f                 	pop ds
0524 6661               	popad
0526 c3                 	ret
0527                    
0527                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0527                    dvxr_init:                              ; DPMI/VCPI/XMS/raw common init tail
0527 33c0               	xor ax,ax                       ; allocate selector for return code
0529 b90100             	mov cx,1
052c cd31               	int $31
052e 7304               	jnc short dvxr_initf0
0530                    
0530 b44c               	mov ah,$4c                      ; could not allocate selector
0532 cd21               	int $21                         ; terminate immediately
0534                    
0534                    dvxr_initf0:
0534 8bd8               	mov bx,ax                       ; new code descriptor for return
0536                    
0536 b80700             	mov ax,$0007                    ; set base address of calling segment
0539 33c9               	xor cx,cx
053b 8b5624             	mov dx,[bp+36]
053e 0fa4d104           	shld cx,dx,4
0542 c1e204             	shl dx,4
0545 cd31               	int $31
0547                    
0547 b80800             	mov ax,$0008                    ; set selector limit of 64k
054a 33c9               	xor cx,cx
054c baffff             	mov dx,$ffff
054f cd31               	int $31
0551                    
0551 b80900             	mov ax,$0009                    ; set selector type and access rights
0554 8cca               	mov dx,cs                       ; get DPL from current CPL, and access
0556 0f02ca             	lar cx,dx                       ;  rights and type from current CS
0559 c1e908             	shr cx,8                        ; type is already 16bit code segment
055c cd31               	int $31
055e                    
055e                    dvxr_initdone:
055e                    
055e 895e24             	mov [bp+36],bx                  ; store selector in return address
0561 33db               	xor bx,bx                       ; init successful, carry clear
0563 e9baff             	jmp init_done
0566                    
0566                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0566                    v_init:                                 ; VCPI protected mode init
0566 b80ade             	mov ax,$de0a                   ; get PIC mappings
0569 cd67               	int $67
056b 881ec302           	mov picmaster,bl
056f 880ec202           	mov picslave,cl
0573                    
0573 66a15002           	mov eax,codebase                ; adjust addresses for VCPI structure
0577 660106d402         	add vcpi_gdtaddx,eax
057c 660106d802         	add vcpi_idtaddx,eax
0581 6601065402         	add vcpistrucaddx,eax
0586                    
0586 8cc2               	mov dx,es                       ; align data area on page
0588 81c2ff00           	add dx,$ff
058c 32d2               	xor dl,dl
058e 8ec2               	mov es,dx
0590                    
0590 660fb7c2           	movzx eax,dx                    ; set base and top of page table area
0594 66c1e004           	shl eax,4
0598 6681c000100000     	add eax,$1000
059f 66a3a802           	mov pagetablebase,eax
05a3 660fb60eb502       	movzx ecx,byte _pm_pagetables
05a9 66c1e10c           	shl ecx,12
05ad 6603c1             	add eax,ecx
05b0 66a3ac02           	mov pagetabletop,eax
05b4                    
05b4 33ff               	xor di,di                       ; clear page dir and first page table
05b6 b90010             	mov cx,$1000
05b9 33c0               	xor ax,ax
05bb f3ab               	rep stos  word es:[di]
05bd                    
05bd 8eea               	mov gs,dx                       ; GS = segment of page directory
05bf 66678d8200010000   	lea eax,[edx+$100]
05c7 8ec0               	mov es,ax                       ; ES = segment of first page table
05c9 8ee0               	mov fs,ax                       ; FS = segment of first page table
05cb                    
05cb 16                 	push ss                         ; stack space for VCPI descriptors
05cc 1f                 	pop ds
05cd 83ec18             	sub sp,8*3
05d0 8bf4               	mov si,sp
05d2                    
05d2 33ff               	xor di,di                       ; get VCPI protected mode interface
05d4 b801de             	mov ax,$de01
05d7 cd67               	int $67
05d9                    
05d9 0e                 	push cs                         ; DS = code32s
05da 1f                 	pop ds
05db                    
05db 660fb7c7           	movzx eax,di                    ; set base of usable page table area
05df 660306a802         	add eax,pagetablebase
05e4 660106b002         	add pagetablefree,eax
05e9                    
05e9 66891ee602         	mov vcpi_calleip,ebx            ; store protected mode VCPI call EIP
05ee 0fb6f6             	movzx si,dh                     ; get physical address of page dir
05f1 c1e602             	shl si,2                        ;  from first page table for CR3
05f4 6664ad             	lods long fs:[si]
05f7 66a3d002           	mov vcpi_cr3,eax
05fb                    
05fb                    v_initl0:
05fb 26806501f1         	and byte es:[di+1],$f1     ; clear bits 9-11 in copied page table
0600 83ef04             	sub di,4
0603 0f83f4ff           	jnc v_initl0
0607                    
0607 8cc2               	mov dx,es                       ; DX = current page table segment
0609 6633db             	xor ebx,ebx                     ; index in page dir, also loop counter
060c eb09               	jmp short v_initl1f0
060e                    
060e                    v_initl1:
060e 33ff               	xor di,di                       ; clear page table
0610 b90008             	mov cx,$800
0613 33c0               	xor ax,ax
0615 f3ab               	rep stos word  es:[di]
0617                    
0617                    v_initl1f0:
0617 81c20001           	add dx,$100                     ; increment page table segment
061b 8ec2               	mov es,dx
061d                    
061d 6664ad             	lods long fs:[si]          ; set physical address of page table
0620 66656789049d0000   	mov gs:[ebx*4],eax              ;  in page directory
0628 0000
062a                    
062a 43                 	inc bx                          ; increment index in page directory
062b 3a1eb502           	cmp bl,_pm_pagetables           ; at end of page tables?
062f 0f82dbff           	jb v_initl1                   ; if no, loop
0633                    
0633                    ;-----------------------------------------------------------------------------
0633 52                 	push dx                         ; preserve seg of TSS for later use
0634                    
0634 33ff               	xor di,di                       ; clear TSS with all 0, not really
0636 b93400             	mov cx,$34                      ;  needed, but just to be safe
0639 33c0               	xor ax,ax
063b f3ab               	rep stos word  es:[di]
063d                    
063d 66a1d002           	mov eax,vcpi_cr3                ; set CR3 in TSS
0641 6626a31c00         	mov es:[$1c],eax
0646 6626c70664000000   	mov long es:[$64],$680000  ; set offset of I/O permission bitmap
064e 6800
0650                    	                                ;  and clear T bit
0650 83c207             	add dx,7                        ; increment next data area ptr
0653 8ec2               	mov es,dx
0655                    
0655                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
0655                    vxr_init:                               ; VCPI/XMS/raw common init tail
0655 8cc0               	mov ax,es                       ; set IDT base address
0657 660fb7d8           	movzx ebx,ax
065b 66c1e304           	shl ebx,4
065f 66891e9802         	mov idtbase,ebx
0664                    
0664 0fb61ebc02         	movzx bx,_pm_rmstacks           ; set top and base of real mode stack
0669 0faf1eb802         	imul bx,word _pm_rmstacklen          ;  area for interrupt redirection
066e 058000             	add ax,$80                      ;  from protected mode
0671 a38802             	mov rmstackbase,ax
0674 03c3               	add ax,bx
0676 a38a02             	mov rmstacktop,ax
0679                    
0679 33ff               	xor di,di                       ; set up IDT
067b 8b16c202           	mov dx,word picslave
067f 6633c9             	xor ecx,ecx
0682                    
0682                    vxr_initl0:
0682 66678d81b70c0800   	lea eax,[ecx+SELCODE*$10000+intrmatrix]
068a 66ab               	stos long  es:[di]
068c                    
068c 66b8008e0000       	mov eax,$8e00                   ; interrupt gate type
0692 8ad9               	mov bl,cl                       ; isolate high 5 bits of int num
0694 80e3f8             	and bl,$f8
0697                    
0697 f6c1f8             	test cl,$f8                    ; one of the low 8 interrupts?
069a 740b               	jz short vxr_initl0f0         ; if yes, store as interrupt gate
069c                    
069c 3ada               	cmp bl,dl                       ; one of the high IRQs?
069e 7407               	je short vxr_initl0f0         ; if yes, store as interrupt gate
06a0 3ade               	cmp bl,dh                       ; one of the low IRQs?
06a2 7403               	je short vxr_initl0f0         ; if yes, store as interrupt gate
06a4                    
06a4 80cc01             	or ah,1                         ; set to trap gate type
06a7                    
06a7                    vxr_initl0f0:
06a7 66ab               	stos long  es:[di]
06a9                    
06a9 fec1               	inc cl                          ; increment interrupt number
06ab 0f85d3ff           	jnz vxr_initl0                ; loop if more interrupts to go
06af                    
06af 26c7068801690f     	mov word es:[8*$31],offset int31    ; protected mode INT 31h
06b6 26c7060801490f     	mov word es:[8*$21],offset int21    ; protected mode INT 21h
06bd 26c7061800b70d     	mov word es:[8*3],offset intr  ; protected mode INT 3
06c4                    
06c4 8e068a02           	mov es,rmstacktop               ; set next data area ptr to end of
06c8                    	                                ;  real mode stack area
06c8                    ;-----------------------------------------------------------------------------
06c8 8cc0               	mov ax,es			; set protected mode stack area base
06ca 660fb7c0           	movzx eax,ax                    ;  for callbacks
06ce 66c1e004           	shl eax,4
06d2 66a36c02           	mov pmstackbase,eax
06d6                    
06d6 660fb70eba02       	movzx ecx,word _pm_pmstacklen        ; set protected mode stack area top
06dc 660fb61ebd02       	movzx ebx,byte _pm_pmstacks          ;  for callbacks
06e2 66c1e104           	shl ecx,4
06e6 66890e6802         	mov pmstacklen,ecx              ; protected mode stack size in bytes
06eb 660fafd9           	imul ebx,ecx
06ef 6603d8             	add ebx,eax
06f2 66891e7002         	mov pmstacktop,ebx              ; protected mode stack area top
06f7                    
06f7 8a0ebe02           	mov cl,_pm_callbacks            ; CL = number of callbacks
06fb 0ac9               	or cl,cl                        ; any callbacks?
06fd 7459               	jz short vxr_initf3           ; if no, done with this part
06ff                    
06ff 66891e7402         	mov callbackbase,ebx            ; top of stacks is base of callbacks
0704 66c1eb04           	shr ebx,4                       ; BX = seg of callback area
0708 891e7802           	mov callbackseg,bx
070c                    
070c 8ec3               	mov es,bx                       ; ES = seg of callback area
070e 33ff               	xor di,di                       ; location within callback seg
0710                    
0710 2e8b163501         	mov	dx,word cs:_code32s
0715                    vxr_initl1:
0715 26c7056660         	mov word es:[di],$6066      ; PUSHAD instruction
071a 26c6450268         	mov byte es:[di+2],$068     ; PUSH WORD instruction
071f 26c745030000       	mov word es:[di+3],0        ; immediate 0 used as free flag
0725 26c745056668       	mov word es:[di+5],$6866   ; PUSH long instruction
072b 26c6450bb9         	mov byte es:[di+11],$b9   ; MOV CX,? instruction
0730 26c7450e6668       	mov word es:[di+14],$6866  ; PUSH long instruction
0736 26c64514ea         	mov byte es:[di+20],$ea    ; JMP FAR PTR ?:? intruction
073b 26c74515810b       	mov word es:[di+21],offset callback
0741 26895517           	mov word es:[di+23],dx  ;(DA)word code32s
0745                    
0745 83c719             	add di,25                       ; increment ptr to callback
0748 fec9               	dec cl                          ; decrement loop counter
074a 0f85c7ff           	jnz vxr_initl1                ; if more callbacks to do, loop
074e                    
074e 83c70f             	add di,$f			; align next data area on paragraph
0751 c1ef04             	shr di,4
0754 03df               	add bx,di
0756 8ec3               	mov es,bx                       ; set ES to base of next data area
0758                    
0758                    vxr_initf3:
0758                    
0758                    ;-----------------------------------------------------------------------------
0758 8c068e02           	mov gdtseg,es			; store segment of GDT
075c                    
075c 8cc0               	mov ax,es                       ; set GDT base address
075e 660fb7c0           	movzx eax,ax
0762 66c1e004           	shl eax,4
0766 66a39202           	mov gdtbase,eax
076a                    
076a 8b0eb602           	mov cx,_pm_selectors            ; set GDT limit
076e 66678d0ccd6f0000   	lea ecx,[ecx*8+8*5+8*SYSSELECTORS-1]
0776 00
0777 890e9002           	mov gdtlimit,cx
077b                    
077b 33ff               	xor di,di                       ; clear GDT with all 0
077d 41                 	inc cx
077e d1e9               	shr cx,1
0780 33c0               	xor ax,ax
0782 f3ab               	rep stos word  es:[di]
0784                    
0784 803ec10202         	cmp byte pmodetype,2                 ; if under VCPI, do VCPI GDT set up
0789 7530               	jne short vxr_initf1
078b                    
078b 58                 	pop ax                          ; restore TSS seg from stack
078c 660fb7c0           	movzx eax,ax                    ; set up TSS selector in GDT
0790 66c1e004           	shl eax,4
0794 6626a32a00         	mov long es:[SELVCPITSS+2],eax
0799 26c606280067       	mov byte es:[SELVCPITSS],$67
079f 26c6062d0089       	mov byte es:[SELVCPITSS+5],$89
07a5                    
07a5 6683c040           	add eax,$64-4*9                 ; unused part of TSS is also
07a9 66a35802           	mov vcpiswitchstack,eax         ;  temporary switch stack
07ad                    
07ad bf3000             	mov di,SELVCPICODE              ; copy 3 VCPI descriptors from stack
07b0 8bf4               	mov si,sp                       ;  to GDT
07b2 b90c00             	mov cx,4*3
07b5 f336a5             	rep movs word es:[di],word ss:[si]
07b8                    
07b8 83c418             	add sp,8*3                      ; adjust stack
07bb                    
07bb                    vxr_initf1:
07bb 26c7061000ffff     	mov word es:[SELZERO],$ffff; set SELZERO descriptor
07c2 26c706150092df     	mov word es:[SELZERO+5],$df92
07c9                    
07c9 26c7061800ffff     	mov word es:[SELCALLBACKDS],$ffff  ; set callback DS descriptor
07d0 26c7061d0092df     	mov word es:[SELCALLBACKDS+5],$df92
07d7                    
07d7 26c7062000ffff     	mov word es:[SELREAL],$ffff; set real mode attributes descriptor
07de 26c70625009210     	mov word es:[SELREAL+5],$1092
07e5                    
07e5 8cc8               	mov ax,cs                       ; set SELCODE descriptor (code32s)
07e7 bb0800             	mov bx,SELCODE                  ; BX = index to SELCODE descriptor
07ea b9ffff             	mov cx,$ffff                   ; CX = limit (64k)
07ed ba9a10             	mov dx,$109a                    ; DX = access rights
07f0 e8a900             	call vxr_initsetdsc
07f3                    
07f3 bb4800             	mov bx,8*SYSSELECTORS           ; BX = base of free descriptors
07f6 53                 	push bx                         ; store selector
07f7                    
07f7 8cd0               	mov ax,ss                       ; set caller SS descriptor
07f9 ba9250             	mov dx,$5092
07fc e89d00             	call vxr_initsetdsc
07ff                    
07ff 8b4600             	mov ax,[bp+0]                     ; set caller DS descriptor
0802 895e00             	mov [bp+0],bx                     ; put DS selector on stack for exit
0805 e89400             	call vxr_initsetdsc
0808                    
0808 53                 	push bx                         ; get PSP segment
0809 b451               	mov ah,$51
080b cd21               	int $21
080d 8bf3               	mov si,bx
080f 5b                 	pop bx
0810                    
0810 8ee6               	mov fs,si                       ; set caller environment descriptor
0812 64a12c00           	mov ax,fs:[$2c]
0816 0bc0               	or ax,ax                        ; is environment seg 0?
0818 7408               	jz short vxr_initf0           ; if yes, dont convert to descriptor
081a 64891e2c00         	mov fs:[$2c],bx                 ; store selector value in PSP
081f e87a00             	call vxr_initsetdsc
0822                    
0822                    vxr_initf0:
0822 8bc6               	mov ax,si                       ; set caller PSP descriptor
0824 b9ff00             	mov cx,$ff                     ; limit is 100h bytes
0827 e87200             	call vxr_initsetdsc
082a                    
082a                    ;-----------------------------------------------------------------------------
082a 66678d4bf8         	lea ecx,[ebx-8]                 ; CX = ES descriptor, just set
082f 5a                 	pop dx                          ; DX = SS descriptor, from stack
0830 b81000             	mov ax,SELZERO                  ; AX = DS descriptor, SELZERO
0833 660fb7dc           	movzx ebx,sp                    ; EBX = SP, current SP - same stack
0837 be0800             	mov si,SELCODE                  ; target CS is SELCODE, same segment
083a 66bf44080000       	mov edi,offset vxr_initf2        ; target EIP
0840                    
0840                    
0840 ff26a202           	jmp word [rmtopmswrout]                ; jump to mode switch routine
0844                    
0844                    vxr_initf2:
0844                    
0844 662e8b3e5002       	mov edi,cs:codebase             ; EDI = offset of code32s from 0
084a 66a15400           	mov eax,[4*$15]              ; get INT 15h vector
084e 666789875c020000   	mov [edi+oldint15vector],eax  ; store INT 15h vector
0856                    
0856 662e8b368002       	mov esi,cs:rawextmembase        ; ESI = raw base of extended memory
085c 662e3b368402       	cmp esi,cs:rawextmemtop         ; is there any raw extended memory?
0862 0f83c1fc           	jae dvxr_init                   ; if no, go DPMI/VCPI/XMS/raw init
0866                    
0866 c7065400140a       	mov	word [4*$15],offset int15
086c 2ea13501           	mov	ax,cs:_code32s
0870 a35600             	mov	[4*$15+2],ax
0873                    ;        dw $b866,int15,code32s  ; MOV EAX,code32s:offset int15
0873                    ;        mov [4*$15],eax              ; set new INT 15h handler
0873                    
0873 662e8b3e8402       	mov edi,cs:rawextmemtop         ; EDI = raw top of extended memory
0879 668bc7             	mov eax,edi                     ; EAX = size of extended memory
087c 662bc6             	sub eax,esi
087f 6683e810           	sub eax,$10                     ; subtract memory control block size
0883 66678947f0         	mov [edi-16],eax                ; store size in memory control block
0888 6633c0             	xor eax,eax
088b 66678947f4         	mov [edi-12],eax                ; no next memory control block
0890 66678947f8         	mov [edi-8],eax                 ; no previous memory control block
0895 678847fc           	mov [edi-4],al                  ; memory block is free
0899                    
0899 e98bfc             	jmp dvxr_init                   ; go to DPMI/VCPI/XMS/raw init tail
089c                    
089c                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
089c                    vxr_initsetdsc:                         ; set descriptor for VCPI/XMS/raw init
089c 660fb7c0           	movzx eax,ax                    ; EAX = base of segment
08a0 66c1e004           	shl eax,4
08a4 26890f             	mov word es:[bx],cx         ; limit = CX
08a7 6626894702         	mov long es:[bx+2],eax     ; base address = EAX
08ac 26895705           	mov word es:[bx+5],dx       ; access rights = DX
08b0 83c308             	add bx,8                        ; increment descriptor index
08b3 c3                 	ret
08b4                    
08b4                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
08b4                    x_init:                                 ; XMS protected mode init
08b4 06                 	push es                         ; preserve ES, INT 2Fh destroys it
08b5                    
08b5 b81043             	mov ax,$4310                    ; get XMS driver address
08b8 cd2f               	int $2f
08ba                    
08ba 891ecc02           	mov xms_callip,bx               ; store XMS driver address
08be 8c06ce02           	mov xms_callcs,es
08c2                    
08c2 07                 	pop es                          ; restore ES (buffer segment)
08c3                    
08c3 b403               	mov ah,3                        ; enable A20
08c5 ff1ecc02           	fcall word [xms_callip]
08c9                    
08c9 bb0400             	mov bx,4                        ; error code 0004h in case of error
08cc 3d0100             	cmp ax,1                        ; error enabling A20?
08cf 0f824dfc           	jc init_done                    ; if yes, exit with error 0004h
08d3                    
08d3 be7403             	mov si,offset int31mxrouttbl       ; set XMS memory allocation functions
08d6                    
08d6                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
08d6                    xr_init:                                ; XMS/raw common init tail
08d6 06                 	push es                         ; preserve ES
08d7                    
08d7 1e                 	push ds                         ; ES = DS for table copy
08d8 07                 	pop es
08d9                    
08d9 bf6a03             	mov di,offset int31mrouttbl        ; copy memory allocation function
08dc b90500             	mov cx,5                        ;  addresses to table
08df f3a5               	rep movs word es:[di],word ds:[si]
08e1                    
08e1 07                 	pop es                          ; restore ES (buffer segment)
08e2                    
08e2 c706a202e10a       	mov word rmtopmswrout,offset xr_rmtopmsw; set XMS/raw mode switch addresses
08e8 66c706a4021b0b00   	mov long pmtormswrout,offset xr_pmtormsw
08f0 00
08f1                    
08f1 e961fd             	jmp vxr_init                    ; go to VCPI/XMS/raw continue init
08f4                    
08f4                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
08f4                    r_init:                                 ; raw protected mode init
08f4 b488               	mov ah,$88                      ; how much extended memory free
08f6 cd15               	int $15
08f8                    
08f8 be8803             	mov si,offset int31mnrouttbl       ; SI -> no memory allocation functions
08fb 0bc0               	or ax,ax                        ; if none, done with raw init
08fd 0f84d5ff           	jz xr_init
0901                    
0901 660fb7c0           	movzx eax,ax                    ; convert AX K to ptr to top of mem
0905 66c1e00a           	shl eax,10
0909 6681c000001000     	add eax,$100000
0910 662ea38402         	mov cs:rawextmemtop,eax
0915                    
0915 e86600             	call enablea20                  ; enable A20
0918                    
0918 06                 	push es                         ; preserve ES (buffer segment)
0919                    
0919 33c9               	xor cx,cx                       ; ES -> 0 (interrupt vector table)
091b 8ec1               	mov es,cx
091d 26c41e6400         	les bx,es:[4*$19]     ; ES:BX -> int vector table
0922                    
0922 66b800001000       	mov eax,$100000                 ; initial free extended memory base
0928 6626817f12564449   	cmp long es:[bx+$12],'SIDV'; VDISK memory allocation?
0930 53
0931 7510               	jne short r_initf0            ; if present, get base of free mem
0933                    
0933 66268b472c         	mov eax,long es:[bx+$2c]   ; get first free byte of extended mem
0938 6683c00f           	add eax,$f                     ; align on paragraph
093c 6681e0f0ffff00     	and eax,$fffff0                ; address is only 24bit
0943                    
0943                    r_initf0:
0943 49                 	dec cx                          ; ES -> 0ffffh for ext mem addressing
0944 8ec1               	mov es,cx
0946                    
0946 6626813e13005644   	cmp long es:[$13],'SIDV'   ; VDISK memory allocation?
094e 4953
0950 7513               	jne short r_initf1            ; if present, get base of free mem
0952                    
0952 66260fb71e2e00     	movzx ebx,word es:[$2e]     ; get first free K of extended memory
0959 66c1e30a           	shl ebx,10                      ; adjust K to bytes
095d                    
095d 663bc3             	cmp eax,ebx                     ; pick larger of 2 addresses
0960 7703               	ja short r_initf1
0962                    
0962 668bc3             	mov eax,ebx
0965                    
0965                    r_initf1:
0965 07                 	pop es                          ; restore ES (buffer segment)
0966                    
0966 be8803             	mov si,offset int31mnrouttbl       ; SI -> no memory allocation functions
0969 662e3b068402       	cmp eax,cs:rawextmemtop         ; any valid free extended memory
096f 0f8363ff           	jae xr_init                     ; if none, done with raw init
0973                    
0973 662ea38002         	mov cs:rawextmembase,eax
0978 be7e03             	mov si,offset int31mrrouttbl       ; set raw memory allocation functions
097b                    
097b e958ff             	jmp xr_init                     ; go to XMS/raw continue init
097e                    
097e                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
097e                    enablea20:                              ; hardware enable gate A20
097e 9c                 	pushf
097f 0fa00fa8           	push fs gs
0983 fa                 	cli
0984                    
0984 33c0               	xor ax,ax                       ; set A20 test segments 0 and 0ffffh
0986 8ee0               	mov fs,ax
0988 48                 	dec ax
0989 8ee8               	mov gs,ax
098b                    
098b e86f00             	call enablea20test              ; is A20 already enabled?
098e 7458               	jz short enablea20done        ; if yes, done
0990                    
0990 e492               	in al,$92                       ; PS/2 A20 enable
0992 0c02               	or al,2
0994 eb00               	jmp short *+2
0996 eb00               	jmp short *+2
0998 eb00               	jmp short *+2
099a e692               	out $92,al
099c                    
099c e85e00             	call enablea20test              ; is A20 enabled?
099f 7447               	jz short enablea20done        ; if yes, done
09a1                    
09a1 e84a00             	call enablea20kbwait            ; AT A20 enable
09a4 7510               	jnz short enablea20f0
09a6                    
09a6 b0d1               	mov al,$d1
09a8 e664               	out $64,al
09aa                    
09aa e84100             	call enablea20kbwait
09ad 7507               	jnz short enablea20f0
09af                    
09af b0df               	mov al,$df
09b1 e660               	out $60,al
09b3                    
09b3 e83800             	call enablea20kbwait
09b6                    
09b6                    enablea20f0:                          ; wait for A20 to enable
09b6 b90008             	mov cx,$800                     ; do 800h tries
09b9                    
09b9                    enablea20l0:
09b9 e84100             	call enablea20test              ; is A20 enabled?
09bc 0f842800           	jz enablea20done              ; if yes, done
09c0                    
09c0 e440               	in al,$40                       ; get current tick counter
09c2 eb00               	jmp short *+2
09c4 eb00               	jmp short *+2
09c6 eb00               	jmp short *+2
09c8 e440               	in al,$40
09ca 8ae0               	mov ah,al
09cc                    
09cc                    enablea20l1:                          ; wait a single tick
09cc e440               	in al,$40
09ce eb00               	jmp short *+2
09d0 eb00               	jmp short *+2
09d2 eb00               	jmp short *+2
09d4 e440               	in al,$40
09d6 3ac4               	cmp al,ah
09d8 0f84f0ff           	je enablea20l1
09dc                    
09dc e2db               	loop enablea20l0              ; loop for another try
09de                    
09de 8bec               	mov bp,sp                       ; error, A20 did not enable
09e0 b80400             	mov ax,4                        ; error code 4
09e3 c746062005         	mov word [bp+6],offset init_done       ; set init_done return address
09e8                    
09e8                    enablea20done:
09e8 0fa90fa1           	pop gs fs
09ec 9d                 	popf
09ed c3                 	ret
09ee                    
09ee                    ;-----------------------------------------------------------------------------
09ee                    enablea20kbwait:                        ; wait for safe to write to 8042
09ee 33c9               	xor cx,cx
09f0                    enablea20kbwaitl0:
09f0 eb00               	jmp short *+2
09f2 eb00               	jmp short *+2
09f4 eb00               	jmp short *+2
09f6 e464               	in al,$64                       ; read 8042 status
09f8 a802               	test al,2                       ; buffer full?
09fa e0f4               	loopnz enablea20kbwaitl0      ; if yes, loop
09fc c3                 	ret
09fd                    
09fd                    ;-----------------------------------------------------------------------------
09fd                    enablea20test:                          ; test for enabled A20
09fd 64a00000           	mov al,fs:[0]                   ; get byte from 0:0
0a01 8ae0               	mov ah,al                       ; preserve old byte
0a03 f6d0               	not al                          ; modify byte
0a05 6586061000         	xchg al,gs:[$10]                ; put modified byte to 0ffffh:10h
0a0a 643a260000         	cmp ah,fs:[0]                   ; set zero if byte at 0:0 not modified
0a0f 65a21000           	mov gs:[$10],al                 ; put back old byte at 0ffffh:10h
0a13 c3                 	ret                             ; return, zero if A20 enabled
0a14                    
0a14                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0a14                    int15:                                  ; real mode INT 15h handler
0a14 80fc88             	cmp ah,$88                      ; function 88h?
0a17 7406               	je short int15f0              ; if yes, need to process
0a19                    
0a19 662eff265c02       	jmp long cs:[oldint15vector]           ; no, go on to old INT 15h handler
0a1f                    
0a1f                    int15f0:
0a1f 9c                 	pushf                           ; call old int 15h handler
0a20 662eff165c02       	call long cs:[oldint15vector]
0a26                    
0a26 2e2b067e02         	sub ax,cs:rawextmemused         ; adjust AX by extended memory used
0a2b                    
0a2b 55                 	push bp                         ; clear carry flag on stack for IRET
0a2c 8bec               	mov bp,sp
0a2e 806606fe           	and byte [bp+6],$fe
0a32 5d                 	pop bp
0a33                    
0a33 cf                 	iret                            ; return with new AX extended memory
0a34                    
0a34                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
0a34                    ; PROTECTED MODE KERNEL CODE
0a34                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
0a34                    
0a34                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0a34                    v_rmtopmsw:                             ; VCPI real to protected switch
0a34 9c                 	pushf                           ; store FLAGS
0a35 fa                 	cli
0a36 0e                 	push cs                         ; DS = code32s
0a37 1f                 	pop ds
0a38 8f06c402           	pop word tempw0                      ; move FLAGS from stack to temp
0a3c a3c602             	mov tempw1,ax                   ; store AX (protected mode DS)
0a3f 8936c802           	mov tempw2,si                   ; store SI (protected mode CS)
0a43 668b365402         	mov esi,vcpistrucaddx           ; ESI = linear addx of VCPI structure
0a48 b80cde             	mov ax,$de0c                   ; VCPI switch to protected mode
0a4b cd67               	int $67
0a4d                    v_rmtopmswpm:
0a4d 8ed2               	mov ss,dx                       ; load protected mode SS:ESP
0a4f 668be3             	mov esp,ebx
0a52 2e8e1ec602         	mov ds,cs:tempw1                ; load protected mode DS
0a57 8ec1               	mov es,cx                       ; load protected mode ES
0a59 33c0               	xor ax,ax
0a5b 8ee0               	mov fs,ax                       ; load protected mode FS with NULL
0a5d 8ee8               	mov gs,ax                       ; load protected mode GS with NULL
0a5f 669c               	pushfd                          ; store EFLAGS
0a61 2ea1c402           	mov ax,cs:tempw0                ; move bits 0-11 of old FLAGS onto
0a65 80e40f             	and ah,$f                      ;  stack for IRETD
0a68 67890424           	mov [esp],ax
0a6c 662eff36c802       	push long cs:tempd1                  ; store protected mode target CS
0a72 6657               	push edi                        ; store protected mode target EIP
0a74 66cf               	iretd                           ; go to targed addx in protected mode
0a76                    
0a76                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0a76                    v_pmtormsw:                             ; VCPI protected to real switch
0a76 9c                 	pushf                           ; store FLAGS
0a77 fa                 	cli
0a78 50                 	push ax                         ; store AX (real mode DS)
0a79 2e8e1e7a02         	mov ds,cs:selzero               ; DS -> 0 (beginning of memory)
0a7e 660fb7db           	movzx ebx,bx                    ; clear high word of EBX, real mode SP
0a82 660fb7d2           	movzx edx,dx                    ; clear high word of EDX, real mode SS
0a86 662ea15802         	mov eax,cs:vcpiswitchstack      ; EAX -> top of temporary switch stack
0a8b 6667c74020000000   	mov long [eax+32],0     ; store real mode GS
0a93 00
0a94 6667c7401c000000   	mov long [eax+28],0     ; store real mode FS
0a9c 00
0a9d 660fb7c9           	movzx ecx,cx                    ; clear high word of ECX, real mode ES
0aa1 6667894814         	mov [eax+20],ecx             ; store real mode ES
0aa6 59                 	pop cx                          ; move real mode DS from protected
0aa7 6667894818         	mov [eax+24],ecx             ;  mode stack to VCPI call stack
0aac 6667895010         	mov [eax+16],edx             ; store real mode SS
0ab1 666789580c         	mov [eax+12],ebx             ; store real mode SP
0ab6 662e0fb71e3501     	movzx ebx,word cs:_code32s
0abd 6667895804         	mov long [eax+4],ebx ;(DA)  word code32s             ; store real mode CS
0ac2 6667c74000dd0a00   	mov long [eax+0],offset v_pmtormswf0     ; store real mode IP
0aca 00
0acb 5b                 	pop bx                          ; restore FLAGS from stack
0acc 2e8e167a02         	mov ss,cs:selzero               ; SS -> 0 (beginning of memory)
0ad1 668be0             	mov esp,eax                     ; ESP = stack ptr for VCPI call
0ad4 b80cde             	mov ax,$de0c                   ; VCPI switch to real mode (V86)
0ad7 662eff1ee602       	fcall long cs:[vcpi_calleip]
0add                    v_pmtormswf0:
0add 53                 	push bx                         ; store old FLAGS
0ade 56                 	push si 			; store target CS in real mode
0adf 57                 	push di 			; store target IP in real mode
0ae0 cf                 	iret				; go to target addx in real mode
0ae1                    
0ae1                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0ae1                    xr_rmtopmsw:                            ; XMS/raw real to protected switch
0ae1 669c               	pushfd                          ; store EFLAGS
0ae3 fa                 	cli
0ae4 50                 	push ax                         ; store AX (protected mode DS)
0ae5 2e0f011e9602       	lidt long cs:idtlimit      ; load protected mode IDT
0aeb 2e0f01169002       	lgdt long cs:gdtlimit      ; load protected mode GDT
0af1 0f20c0             	mov eax,cr0                     ; switch to protected mode
0af4 0c01               	or al,1
0af6 0f22c0             	mov cr0,eax
0af9 ea                 	db $ea                         ; JMP FAR PTR SELCODE:$+4
0afa fe0a0800           	dw *+4,SELCODE                  ;  (clear prefetch que)
0afe 1f                 	pop ds                          ; load protected mode DS
0aff 8ec1               	mov es,cx                       ; load protected mode ES
0b01 33c0               	xor ax,ax
0b03 8ee0               	mov fs,ax                       ; load protected mode FS with NULL
0b05 8ee8               	mov gs,ax                       ; load protected mode GS with NULL
0b07 6658               	pop eax
0b09 8ed2               	mov ss,dx                       ; load protected mode SS:ESP
0b0b 668be3             	mov esp,ebx
0b0e 80e4bf             	and ah,$bf                     ; set NT=0 in old EFLAGS
0b11 50                 	push ax                         ; set current FLAGS
0b12 9d                 	popf
0b13 6650               	push eax                        ; store old EFLAGS
0b15 6656               	push esi                        ; store protected mode target CS
0b17 6657               	push edi                        ; store protected mode target EIP
0b19 66cf               	iretd                           ; go to targed addx in protected mode
0b1b                    
0b1b                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0b1b                    xr_pmtormsw:                            ; XMS/raw protected to real switch
0b1b 51                 	push cx                         ; store CX (real mode ES)
0b1c 9c                 	pushf                           ; store FLAGS
0b1d fa                 	cli
0b1e 50                 	push ax                         ; store AX (real mode DS)
0b1f 2e8e1e7a02         	mov ds,cs:selzero               ; DS -> 0 (beginning of memory)
0b24 662e8b0e5002       	mov ecx,cs:codebase             ; get offset of code32s from 0
0b2a 678f81c4020000     	pop word [ecx+tempw0]              ; move real mode DS from stack to temp
0b31 678f81c6020000     	pop word [ecx+tempw1]              ; move FLAGS from stack to temp
0b38 59                 	pop cx                          ; restore CX (real mode ES)
0b39 b82000             	mov ax,SELREAL                  ; load descriptors with real mode seg
0b3c 8ed8               	mov ds,ax                       ;  attributes
0b3e 8ec0               	mov es,ax
0b40 8ee0               	mov fs,ax
0b42 8ee8               	mov gs,ax
0b44 8ed0               	mov ss,ax                       ; load descriptor with real mode attr
0b46 660fb7e3           	movzx esp,bx                    ; load real mode SP, high word 0
0b4a 2e0f011e9c02       	lidt long cs:rmidtlimit    ; load real mode IDT
0b50 0f20c0             	mov eax,cr0                     ; switch to real mode
0b53 24fe               	and al,$fe
0b55 0f22c0             	mov cr0,eax
0b58 ea                 	db $ea                         ; JMP FAR PTR code32s:$+4
0b59 5d0b               	dw xr_back
0b5b 0000               c32patch: dw	0        ;  (clear prefetch que) ;**************** problem (DA)
0b5d                    xr_back:
0b5d                    
0b5d 8ed2               	mov ss,dx                       ; load real mode SS
0b5f 2e8e1ec402         	mov ds,cs:tempw0                ; load real mode DS
0b64 8ec1               	mov es,cx                       ; load real mode ES
0b66 33c0               	xor ax,ax
0b68 8ee0               	mov fs,ax                       ; load real mode FS with NULL
0b6a 8ee8               	mov gs,ax                       ; load real mode GS with NULL
0b6c 2eff36c602         	push word cs:tempw1                  ; store old FLAGS
0b71 56                 	push si                         ; store real mode target CS
0b72 57                 	push di                         ; store real mode target IP
0b73 cf                 	iret                            ; go to target addx in real mode
0b74                    
0b74                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0b74                    vxr_saverestorerm:                      ; VCPI/XMS/raw save/restore status
0b74 cb                 	retf                            ; no save/restore needed, 16bit RETF
0b75                    
0b75                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0b75                    vxr_saverestorepm:                      ; VCPI/XMS/raw save/restore status
0b75 66cb               	db $66,$cb                     ; no save/restore needed, 32bit RETF
0b77                    
0b77                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0b77                    critical_error:                         ; some unrecoverable error
0b77 fa                 	cli                             ; make sure we are not interrupted
0b78 e461               	in al,$61                       ; beep
0b7a 0c03               	or al,3
0b7c e661               	out $61,al
0b7e e9fdff             	jmp *                           ; now hang
0b81                    
0b81                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0b81                    callback:                               ; real mode callback handler
0b81 8bc4               	mov ax,sp                       ; preserve SS:SP for callback
0b83 16                 	push ss
0b84 50                 	push ax
0b85                    
0b85 0fa80fa01e06       	push gs fs ds es                ; preserve real mode regs for callback
0b8b 9c                 	pushf                           ; preserve FLAGS for callback
0b8c                    
0b8c fa                 	cli
0b8d fc                 	cld
0b8e                    
0b8e 662e8b2e7002       	mov ebp,cs:pmstacktop           ; EBP = ESP for protected mode
0b94                    
0b94 668bdd             	mov ebx,ebp                     ; set EBX to next stack location
0b97 662e2b1e6802       	sub ebx,cs:pmstacklen
0b9d 662e891e7002       	mov cs:pmstacktop,ebx           ; update ptr for possible reenterancy
0ba3                    
0ba3 662e3b1e6c02       	cmp ebx,cs:pmstackbase          ; exceeded protected mode stack space?
0ba9 0f82caff           	jb critical_error               ; if yes, critical error (hang)
0bad                    
0bad 6633c0             	xor eax,eax                     ; EAX = base address of SS
0bb0 8cd0               	mov ax,ss
0bb2 66c1e004           	shl eax,4
0bb6                    
0bb6 660fb7dc           	movzx ebx,sp			; EBX = current linear SS:SP
0bba 6603d8             	add ebx,eax
0bbd                    
0bbd 2e8e068e02         	mov es,cs:gdtseg		; set for protected mode callback DS
0bc2 6681c800000092     	or eax,$92000000		;  base address in GDT
0bc9 6626a31a00         	mov es:[SELCALLBACKDS+2],eax
0bce                    
0bce b81000             	mov ax,SELZERO                  ; DS selector for protected mode
0bd1 8bd0               	mov dx,ax                       ; SS selector = DS selector
0bd3 be0800             	mov si,SELCODE                  ; target protected mode CS:EIP
0bd6 66bfe10b0000       	mov edi,offset callbackf0
0bdc                    
0bdc 2eff26a202         	jmp word cs:[rmtopmswrout]             ; go to protected mode
0be1                    
0be1                    callbackf0:
0be1 66678b7c240e       	mov edi,[esp+14]                ; EDI -> register structure from stack
0be7                    
0be7 66678d742418       	lea esi,[esp+24]                ; copy general registers from stack
0bed 66b908000000       	mov ecx,8                       ;  to register structure
0bf3 f36667a5           	rep movs long es:[edi],long ds:[esi]
0bf7                    
0bf7 668bf4             	mov esi,esp                     ; copy FLAGS, ES, DS, FG, and GS
0bfa 67a5               	movs word es:[edi],word ds:[esi]
0bfc 6667a5             	movs long es:[edi],long ds:[esi]
0bff 6667a5             	movs long es:[edi],long ds:[esi]
0c02                    
0c02 6667ad             	lods long ds:[esi]         ; EAX = real mode SS:SP from stack
0c05 052a00             	add ax,42                       ; adjust SP for stuff on stack
0c08 662667894704       	mov es:[edi+4],eax              ; put in register structure
0c0e                    
0c0e 2e8e1e7c02         	mov ds,cs:selcallbackds         ; DS = callback DS selector
0c13 6683ef2a           	sub edi,42                      ; EDI -> register structure
0c17 660fb7f0           	movzx esi,ax                    ; ESI = old real mode SP
0c1b 6687e5             	xchg esp,ebp                    ; ESP = protected mode stack
0c1e                    
0c1e 669c               	pushfd                          ; push flags for IRETD from callback
0c20 66                 	db $66                          ; push 32bit CS for IRETD
0c21 0e                 	push cs
0c22 6668370c0000       	dw $6866,callbackf1,0         ; push 32bit EIP for IRETD
0c28                    
0c28 66670fb74516       	movzx eax,word [ebp+22]     ; EAX = target CS of callback
0c2e 6650               	push eax                        ; push 32bit CS for RETF to callback
0c30 6667ff7512         	push long [ebp+18]         ; push 32bit EIP for retf
0c35                    
0c35 66                 	db $66                          ; 32bit RETF to callback
0c36 cb                 	retf
0c37                    
0c37                    callbackf1:
0c37 fa                 	cli
0c38 fc                 	cld
0c39                    
0c39 06                 	push es                         ; DS:ESI = register structure
0c3a 1f                 	pop ds
0c3b 668bf7             	mov esi,edi
0c3e                    
0c3e 2e8e067a02         	mov es,cs:selzero               ; ES -> 0 (beginning of memory)
0c43                    
0c43 66670fb75e2e       	movzx ebx,word [esi+$2e]    ; EBX = real mode SP from structure
0c49 66670fb75630       	movzx edx,word [esi+$30]    ; EDX = real mode SS from structure
0c4f 83eb2a             	sub bx,42                       ; subtract size of vars to be put
0c52                    
0c52 66678b6e0c         	mov ebp,[esi+$c]               ; EBP = pushed ESP from real mode
0c57 8beb               	mov bp,bx                       ; EBP = old high & new low word of ESP
0c59                    
0c59 66678d3c95000000   	lea edi,[edx*4]                 ; EDI -> real mode base of stack
0c61 00
0c62 66678d3cbb         	lea edi,[ebx+edi*4]             ;  of vars to be stored
0c67                    
0c67 66b908000000       	mov ecx,8                       ; copy general registers to stack
0c6d f36667a5           	rep movs long es:[edi],long ds:[esi]
0c71                    
0c71 66678b4606         	mov eax,[esi+6]                 ; EAX = return FS and GS for real mode
0c76 6626678907         	mov es:[edi],eax                ; store on real mode stack for return
0c7b                    
0c7b 67a1               	mov ax,[esi]                    ; AX = return FLAGS for real mode
0c7d 2667894708         	mov es:[edi+8],ax               ; store on real mode stack for return
0c82 66678b460a         	mov eax,[esi+10]                ; EAX = return CS:IP for real mode
0c87 662667894704       	mov es:[edi+4],eax              ; store on real mode stack for return
0c8d                    
0c8d 678b4604           	mov ax,[esi+4]                  ; AX = return DS for real mode
0c91 678b4e02           	mov cx,[esi+2]                  ; CX = return ES for real mode
0c95                    
0c95 2e8b363501         	mov si,word cs:_code32s               ; real mode target CS:IP
0c9a bfa20c             	mov di,offset callbackf2
0c9d                    
0c9d 2eff26a402         	jmp word cs:[pmtormswrout]
0ca2                    
0ca2                    callbackf2:
0ca2 668be5             	mov esp,ebp                     ; restore total ESP, old high word
0ca5                    
0ca5 662ea16802         	mov eax,cs:pmstacklen           ; restore top of protected mode stack
0caa 662e01067002       	add cs:pmstacktop,eax
0cb0                    
0cb0 6661               	popad                           ; get callback return general regs
0cb2 0fa10fa9           	pop fs gs                       ; get callback return FS and GS values
0cb6 cf                 	iret                            ; go to callback return CS:IP
0cb7                    
0cb7                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0cb7                    intrmatrix:				; INT redirectors for all INTs
0cb7 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc               ; 100h INT 3s
0cbf cccccccccccccccc
0cc7 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0ccf cccccccccccccccc
0cd7 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0cdf cccccccccccccccc
0ce7 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0cef cccccccccccccccc
0cf7 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0cff cccccccccccccccc
0d07 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d0f cccccccccccccccc
0d17 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d1f cccccccccccccccc
0d27 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d2f cccccccccccccccc
0d37 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d3f cccccccccccccccc
0d47 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d4f cccccccccccccccc
0d57 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d5f cccccccccccccccc
0d67 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d6f cccccccccccccccc
0d77 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d7f cccccccccccccccc
0d87 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d8f cccccccccccccccc
0d97 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0d9f cccccccccccccccc
0da7 cccccccccccccccc   	db	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
0daf cccccccccccccccc
0db7                    
0db7                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0db7                    intr:                                   ; general interrupt redirector
0db7 67837c240408       	cmp word [esp+4],SELCODE    ; INT redirection or internal INT 3?
0dbd 7406               	je short intrf0               ; if not INT 3, jump to redirection
0dbf                    
0dbf 662eff2e6002       	fjmp long cs:int3vector     ; INT 3, jump to INT 3 vector
0dc5                    
0dc5                    intrf0:
0dc5                    
0dc5 666789442408       	mov [esp+8],eax                 ; store EAX for later POPAD
0dcb 66678b0424         	mov eax,[esp]                   ; get address in redirection matrix
0dd0 6683c408           	add esp,8                       ; discard EIP and CS from INT 3
0dd4 6651665266536654   	push ecx edx ebx esp ebp esi edi; store rest of registers for POPAD
0ddc 665566566657
0de2 1e060fa00fa8       	push ds es fs gs
0de8                    
0de8 2e8e1e7a02         	mov ds,cs:selzero               ; DS -> 0 (beginning of memory)
0ded 662e8b3e5002       	mov edi,cs:codebase             ; EDI = offset of code32s from 0
0df3                    
0df3 2e8b168a02         	mov dx,cs:rmstacktop            ; DX = SS for real mode redirection
0df8 660fb7ea           	movzx ebp,dx                    ; EBP -> top of real mode stack
0dfc 66c1e504           	shl ebp,4
0e00                    
0e00 2e8b1eb802         	mov bx,cs:_pm_rmstacklen        ; get size of real mode stack
0e05 2bd3               	sub dx,bx                       ; adjust DX to next stack location
0e07 6789978a020000     	mov [edi+rmstacktop],dx       ; update ptr for possible reenterancy
0e0e c1e304             	shl bx,4                        ; set real mode SP to top of stack
0e11                    
0e11 2e3b168802         	cmp dx,cs:rmstackbase           ; exceeded real mode stack space?
0e16 0f825dfd           	jb critical_error               ; if yes, critical error (hang)
0e1a                    
0e1a 3e678c55fe         	mov ds:[ebp-2],ss               ; store SS:ESP on real mode stack
0e1f 663e678965fa       	mov ds:[ebp-6],esp
0e25                    
0e25 2db80c             	sub ax,offset intrmatrix+1         ; AX = int number
0e28 8ae0               	mov ah,al                       ; AH = high 5 bits of int number
0e2a 80e4f8             	and ah,$f8
0e2d                    
0e2d 2e3a26c202         	cmp ah,cs:picslave              ; high IRQ?
0e32 7407               	je short intrirq                ; if yes, do IRQ
0e34 2e3a26c302         	cmp ah,cs:picmaster             ; low IRQ?
0e39 754a               	jne short intrint               ; if no, do INT (with general regs)
0e3b                    
0e3b                    ;-----------------------------------------------------------------------------
0e3b                    intrirq:                                ; an IRQ redirection
0e3b 678887530e0000     	mov [edi+intrirqintnum],al  ; modify code with interrupt number
0e42                    
0e42 2e8b363501         	mov si,word cs:_code32s               ; real mode target CS:IP
0e47 bf520e             	mov di,offset intrirqf0
0e4a 83eb06             	sub bx,6                        ; adjust real mode SP for stored vars
0e4d                    
0e4d 2eff26a402         	jmp word cs:[pmtormswrout]    ;  not seg:16bit offset
0e52                    
0e52                    intrirqf0:
0e52 cd                 	db $cd                         ; INT intrirqintnum
0e53 00                 intrirqintnum db      0
0e54                    
0e54 b81000             	mov ax,SELZERO                  ; DS selector value for protected mode
0e57 8bc8               	mov cx,ax                       ; ES selector value for protected mode
0e59 665b               	pop ebx                         ; get protected mode SS:ESP from stack
0e5b 5a                 	pop dx
0e5c be0800             	mov si,SELCODE                  ; target CS:EIP in protected mode
0e5f 66bf6a0e0000       	mov edi,offset intrirqf1
0e65                    
0e65 2eff26a202         	jmp word cs:[rmtopmswrout]             ; go back to protected mode
0e6a                    
0e6a                    intrirqf1:
0e6a 662e8b3e5002       	mov edi,cs:codebase             ; restore top of real mode stack
0e70 2ea1b802           	mov ax,cs:_pm_rmstacklen
0e74 6701878a020000     	add [edi+rmstacktop],ax
0e7b                    
0e7b 0fa90fa1071f       	pop gs fs es ds                 ; restore all registers
0e81 6661               	popad
0e83 66cf               	iretd
0e85                    
0e85                    ;-----------------------------------------------------------------------------
0e85                    intrint:                                ; an INT redirection
0e85 678887bb0e0000     	mov [edi+intrintintnum],al  ; modify code with interrupt number
0e8c                    
0e8c 2e8e067a02         	mov es,cs:selzero               ; copy registers from protected mode
0e91 66678d7dda         	lea edi,[ebp-$26]               ;  stack to real mode stack
0e96 66678d742408       	lea esi,[esp+8]
0e9c 66b908000000       	mov ecx,8
0ea2 fc                 	cld
0ea3 f3666736a5         	rep movs long es:[edi],long ss:[esi]
0ea8                    
0ea8 2e8b363501         	mov si,word cs:_code32s               ; real mode target CS:IP
0ead bfb80e             	mov di,offset intrintf0
0eb0 83eb26             	sub bx,$26                      ; adjust real mode SP for stored vars
0eb3                    
0eb3 2eff26a402         	jmp word cs:[pmtormswrout]    ;  not seg:16bit offset
0eb8                    
0eb8                    intrintf0:
0eb8 6661               	popad                           ; load regs with int call values
0eba                    
0eba cd                 	db $cd                         ; INT intrirqintnum
0ebb 00                 intrintintnum db      0
0ebc                    
0ebc 6660               	pushad                          ; store registers on stack
0ebe 9c                 	pushf                           ; store flags on stack
0ebf fa                 	cli
0ec0                    
0ec0 6633c0             	xor eax,eax                     ; EAX = linear ptr to SS
0ec3 8cd0               	mov ax,ss
0ec5 66c1e004           	shl eax,4
0ec9 660fb7ec           	movzx ebp,sp                    ; EBP = SP
0ecd                    
0ecd 668b5e22           	mov ebx,[bp+$22]                ; get protected mode SS:ESP from stack
0ed1 8b5626             	mov dx,[bp+$26]
0ed4                    
0ed4 6603e8             	add ebp,eax                     ; EBP -> stored regs on stack
0ed7                    
0ed7 b81000             	mov ax,SELZERO                  ; DS selector value for protected mode
0eda 8bc8               	mov cx,ax                       ; ES selector value for protected mode
0edc be0800             	mov si,SELCODE                  ; target CS:EIP in protected mode
0edf 66bfea0e0000       	mov edi,offset intrintf1
0ee5                    
0ee5 2eff26a202         	jmp word cs:[rmtopmswrout]             ; go back to protected mode
0eea                    
0eea                    intrintf1:
0eea 662e8b3e5002       	mov edi,cs:codebase             ; restore top of real mode stack
0ef0 2ea1b802           	mov ax,cs:_pm_rmstacklen
0ef4 6701878a020000     	add [edi+rmstacktop],ax
0efb                    
0efb 3e678b4500         	mov ax,ds:[ebp+0]                 ; move return FLAGS from real mode
0f00 25d508             	and ax,$8d5                     ;  stack to protected mode stack
0f03 678b5c2430         	mov bx,[esp+$30]
0f08 81e32af7           	and bx,~$8d5
0f0c 0bc3               	or ax,bx
0f0e 6789442430         	mov [esp+$30],ax
0f13                    
0f13 663e678b7d02       	mov edi,ds:[ebp+2]              ; restore return registers from real
0f19 663e678b7506       	mov esi,ds:[ebp+6]              ;  mode stack
0f1f 663e678b5d12       	mov ebx,ds:[ebp+18]
0f25 663e678b5516       	mov edx,ds:[ebp+22]
0f2b 663e678b4d1a       	mov ecx,ds:[ebp+26]
0f31 663e678b451e       	mov eax,ds:[ebp+30]
0f37 663e678b6d0a       	mov ebp,ds:[ebp+10]
0f3d                    
0f3d 0fa90fa1071f       	pop gs fs es ds                 ; restore segment regs
0f43 6683c420           	add esp,$20                     ; skip old general registers on stack
0f47 66cf               	iretd
0f49                    
0f49                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0f49                    int21:                                  ; watch for INT 21h AH=4Ch
0f49 80fc4c             	cmp ah,$4c                      ; AH = 4Ch?
0f4c 0f8588fd           	jne intrmatrix+$21              ; if no, go to INT 21h redirection
0f50                    
0f50 2e8e1e7a02         	mov ds,cs:selzero               ; DS -> 0 (beginning of memory)
0f55 662e8b3e5002       	mov edi,cs:codebase             ; EDI = offset of code32s from 0
0f5b                    
0f5b 662e8b1e5c02       	mov ebx,cs:oldint15vector       ; put back old INT 15h handler
0f61 66891e5400         	mov [4*$15],ebx
0f66                    
0f66 e96ffd             	jmp intrmatrix+$21              ; go to INT 21h redirection
0f69                    
0f69                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
0f69                    ; INT 31h INTERFACE
0f69                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
0f69                    
0f69                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
0f69                    int31:                                  ; protected mode INT 31h handler
0f69 fa                 	cli
0f6a fc                 	cld
0f6b 1e060fa00fa8       	push ds es fs gs                ; push regs needed
0f71 6660               	pushad
0f73 2e8e1e7a02         	mov ds,cs:selzero               ; DS -> 0 (beginning of memory)
0f78                    
0f78 53                 	push bx
0f79 bb3e00             	mov bx,(INT31FUNCNUM-1)*2   ; number of functions to check
0f7c                    int31l0:
0f7c 2e3b87f402         	cmp ax,cs:[bx+int31functbl]      ; found function value?
0f81 750a               	jne short int31l0c
0f83                    
0f83 2e8b9f3403         	mov bx,cs:[bx+int31routtbl]      ; yes, go to appropriate handler
0f88 67871c24           	xchg bx,[esp]
0f8c c3                 	ret
0f8d                    
0f8d                    int31l0c:
0f8d 83eb02             	sub bx,2                        ; no, continue loop
0f90 0f83e8ff           	jnc int31l0
0f94                    
0f94 5b                 	pop bx                          ; no function found
0f95 e95a00             	jmp int31fail8001               ; error 8001h
0f98                    
0f98                    ;-----------------------------------------------------------------------------
0f98                    int31fail8024:                          ; INT 31h return fail with error 8024h
0f98 67c744241c2480     	mov word [esp+28],$8024     ; set AX on stack to 8024h for POPAD
0f9f eb64               	jmp short int31fail
0fa1                    
0fa1                    ;-----------------------------------------------------------------------------
0fa1                    int31fail8023:                          ; INT 31h return fail with error 8023h
0fa1 67c744241c2380     	mov word [esp+28],$8023     ; set AX on stack to 8023h for POPAD
0fa8 eb5b               	jmp short int31fail
0faa                    
0faa                    ;-----------------------------------------------------------------------------
0faa                    int31fail8022:                          ; INT 31h return fail with error 8022h
0faa 67c744241c2280     	mov word [esp+28],$8022     ; set AX on stack to 8022h for POPAD
0fb1 eb52               	jmp short int31fail
0fb3                    
0fb3                    ;-----------------------------------------------------------------------------
0fb3                    int31fail8021:                          ; INT 31h return fail with error 8021h
0fb3 67c744241c2180     	mov word [esp+28],$8021     ; set AX on stack to 8021h for POPAD
0fba eb49               	jmp short int31fail
0fbc                    
0fbc                    ;-----------------------------------------------------------------------------
0fbc                    int31fail8016:                          ; INT 31h return fail with error 8016h
0fbc 67c744241c1680     	mov word [esp+28],$8016     ; set AX on stack to 8016h for POPAD
0fc3 eb40               	jmp short int31fail
0fc5                    
0fc5                    ;-----------------------------------------------------------------------------
0fc5                    int31fail8015:                          ; INT 31h return fail with error 8015h
0fc5 67c744241c1580     	mov word [esp+28],$8015     ; set AX on stack to 8015h for POPAD
0fcc eb37               	jmp short int31fail
0fce                    
0fce                    ;-----------------------------------------------------------------------------
0fce                    int31fail8013:                          ; INT 31h return fail with error 8013h
0fce 67c744241c1380     	mov word [esp+28],$8013     ; set AX on stack to 8013h for POPAD
0fd5 eb2e               	jmp short int31fail
0fd7                    
0fd7                    ;-----------------------------------------------------------------------------
0fd7                    int31fail8012:                          ; INT 31h return fail with error 8012h
0fd7 67c744241c1280     	mov word [esp+28],$8012     ; set AX on stack to 8012h for POPAD
0fde eb25               	jmp short int31fail
0fe0                    
0fe0                    ;-----------------------------------------------------------------------------
0fe0                    int31fail8011:                          ; INT 31h return fail with error 8011h
0fe0 67c744241c1180     	mov word [esp+28],$8011     ; set AX on stack to 8011h for POPAD
0fe7 eb1c               	jmp short int31fail
0fe9                    
0fe9                    ;-----------------------------------------------------------------------------
0fe9                    int31fail8010:                          ; INT 31h return fail with error 8010h
0fe9 67c744241c1080     	mov word [esp+28],$8010     ; set AX on stack to 8010h for POPAD
0ff0 eb13               	jmp short int31fail
0ff2                    
0ff2                    ;-----------------------------------------------------------------------------
0ff2                    int31fail8001:                          ; INT 31h return fail with error 8001h
0ff2 67c744241c0180     	mov word [esp+28],$8001     ; set AX on stack to 8001h for POPAD
0ff9 eb0a               	jmp short int31fail
0ffb                    
0ffb                    ;-----------------------------------------------------------------------------
0ffb                    int31failcx:                            ; INT 31h return fail with CX,AX
0ffb 67894c2418         	mov word [esp+24],cx        ; put CX onto stack for POPAD
1000                    
1000                    ;-----------------------------------------------------------------------------
1000                    int31failax:                            ; INT 31h return fail with AX
1000 678944241c         	mov word [esp+28],ax        ; put AX onto stack for POPAD
1005                    
1005                    ;-----------------------------------------------------------------------------
1005                    int31fail:                              ; INT 31h return fail, pop all regs
1005 6661               	popad
1007 0fa90fa1071f       	pop gs fs es ds
100d                    
100d                    ;-----------------------------------------------------------------------------
100d                    int31failnopop:                         ; INT 31h return fail with carry set
100d 67804c240801       	or byte [esp+8],1           ; set carry in EFLAGS on stack
1013 66cf               	iretd
1015                    
1015                    ;-----------------------------------------------------------------------------
1015                    int31okedx:                             ; INT 31h return ok with EDX,CX,AX
1015 666789542414       	mov [esp+20],edx                ; put EDX onto stack for POPAD
101b eb1a               	jmp short int31okcx
101d                    
101d                    ;-----------------------------------------------------------------------------
101d                    int31okdx:                              ; INT 31h return ok with DX,CX,AX
101d 6789542414         	mov [esp+20],dx                 ; put DX onto stack for POPAD
1022 eb13               	jmp short int31okcx
1024                    
1024                    ;-----------------------------------------------------------------------------
1024                    int31oksinoax:                          ; INT 31h return ok SI,DI,BX,CX
1024 678b44241c         	mov ax,[esp+28]                 ; get old value of AX for restore
1029                    
1029                    ;-----------------------------------------------------------------------------
1029                    int31oksi:                              ; INT 31h return ok SI,DI,BX,CX,AX
1029 6789742404         	mov [esp+4],si                  ; put SI onto stack for POPAD
102e 67893c24           	mov [esp],di                    ; put DI onto stack for POPAD
1032 67895c2410         	mov [esp+16],bx                 ; put BX onto stack for POPAD
1037                    
1037                    ;-----------------------------------------------------------------------------
1037                    int31okcx:                              ; INT 31h return ok with CX,AX
1037 67894c2418         	mov [esp+24],cx                 ; put CX onto stack for POPAD
103c                    
103c                    ;-----------------------------------------------------------------------------
103c                    int31okax:                              ; INT 31h return ok with AX
103c 678944241c         	mov [esp+28],ax                 ; put AX onto stack for POPAD
1041                    
1041                    ;-----------------------------------------------------------------------------
1041                    int31ok:                                ; INT 31h return ok, pop all regs
1041 6661               	popad
1043 0fa90fa1071f       	pop gs fs es ds
1049                    
1049                    ;-----------------------------------------------------------------------------
1049                    int31oknopop:                           ; INT 31h return ok with carry clear
1049 6780642408fe       	and byte [esp+8],$fe       ; clear carry in EFLAGS on stack
104f 66cf               	iretd
1051                    
1051                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1051                    ; DESCRIPTOR FUNCTIONS
1051                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1051                    
1051                    ;-----------------------------------------------------------------------------
1051                    int31testsel:                           ; test for valid selector BX
1051 5d                 	pop bp                          ; pop return address
1052                    
1052 2e3b1e9002         	cmp bx,cs:gdtlimit              ; selector BX out of range?
1057 0f874fff           	ja int31fail8022                ; if yes, fail with error 8022h
105b                    
105b 662e8b3e9202       	mov edi,cs:gdtbase              ; get base of GDT
1061 80e3f8             	and bl,$f8                     ; mask offset table index and RPL
1064 660fb7db           	movzx ebx,bx                    ; EBX = selector index
1068 67f6441f0610       	test byte [edi+ebx+6],$10; is descriptor used?
106e 0f8438ff           	jz int31fail8022                ; if descriptor not used, fail 8022h
1072                    
1072 ffe5               	jmp bp                          ; return ok
1074                    
1074                    ;-----------------------------------------------------------------------------
1074                    int31testaccess:                        ; test access bits in CX
1074 5d                 	pop bp                          ; pop return address
1075                    
1075 f6c520             	test ch,$20                     ; test MUST BE 0 bit in CH
1078 0f8537ff           	jnz int31fail8021               ; if not 0, error 8021h
107c                    
107c f6c190             	test cl,$90                     ; test present and MUST BE 1 bits
107f 0f8430ff           	jz int31fail8021                ; if both 0, error 8021h
1083 0f8b2cff           	jpo int31fail8021               ; if unequal, error 8021h
1087                    
1087 f6c160             	test cl,$60                     ; test DPL
108a 0f8525ff           	jnz int31fail8021               ; if not 0, error 8021h
108e                    
108e f6c108             	test cl,8                       ; if code, more tests needed
1091 740b               	jz short int31testselok       ; if data, skip code tests
1093                    
1093 f6c106             	test cl,6                       ; test conforming and readable bits
1096 0f8419ff           	jz int31fail8021                ; if both 0, error 8021h
109a 0f8a15ff           	jpe int31fail8021               ; if equal, error 8021h
109e                    
109e                    int31testselok:
109e ffe5               	jmp bp                          ; return ok
10a0                    
10a0                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
10a0                    int310000:                              ; allocate descriptors
10a0 0bc9               	or cx,cx                        ; if CX = 0, error 8021h
10a2 0f840dff           	jz int31fail8021
10a6                    
10a6 662e8b169202       	mov edx,cs:gdtbase              ; get base of GDT
10ac 662e0fb7069002     	movzx eax,word cs:gdtlimit           ; EAX = last selector index
10b3 24f8               	and al,$f8
10b5                    
10b5 8bd9               	mov bx,cx                       ; BX = number of selectors to find
10b7                    int310000l0:
10b7 67f644020610       	test byte [edx+eax+6],$10; is descriptor used?
10bd 7524               	jnz short int310000l0f0
10bf                    
10bf 4b                 	dec bx                          ; found free descriptor, dec counter
10c0 7523               	jnz short int310000l0f1       ; continue if need to find more
10c2                    
10c2 668bd8             	mov ebx,eax                     ; found all descriptors requested
10c5                    int310000l1:
10c5 6667c7041a000000   	mov long [edx+ebx],0    ; set entire new descriptor
10cd 00
10ce 6667c7441a040092   	mov long [edx+ebx+4],$109200
10d6 1000
10d8 83c308             	add bx,8                        ; increment selector index
10db 49                 	dec cx                          ; dec counter of descriptors to mark
10dc 0f85e5ff           	jnz int310000l1               ; loop if more to mark
10e0                    
10e0 e959ff             	jmp int31okax                   ; return ok, with AX
10e3                    
10e3                    int310000l0f0:
10e3 8bd9               	mov bx,cx                       ; reset number of selectors to find
10e5                    
10e5                    int310000l0f1:
10e5 2d0800             	sub ax,8                        ; dec current selector counter
10e8 3d4800             	cmp ax,8*SYSSELECTORS           ; more descriptors to go?
10eb 0f83c8ff           	jae int310000l0               ; if yes, loop
10ef                    
10ef e9eefe             	jmp int31fail8011               ; did not find descriptors
10f2                    
10f2                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
10f2                    int310001:                              ; free descriptor
10f2 e85cff             	call int31testsel               ; test for valid selector BX
10f5                    
10f5 6780641f06ef       	and byte [edi+ebx+6],$ef; mark descriptor as free
10fb                    
10fb b90400             	mov cx,4                        ; zero any segregs loaded with BX
10fe 66678d6c2420       	lea ebp,[esp+32]                ; EBP -> selectors on stack
1104                    int310001l0:
1104 67395d00           	cmp word [ebp+0],bx           ; selector = BX?
1108 7506               	jne short int310001l0f0       ; if no, continue loop
110a                    
110a 67c745000000       	mov word [ebp+0],0            ; zero selector on stack
1110                    
1110                    int310001l0f0:
1110 6683c502           	add ebp,2                       ; increment selector ptr
1114 e2ee               	loop int310001l0              ; loop
1116                    
1116 e928ff             	jmp int31ok                     ; return ok
1119                    
1119                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1119                    int310003:                              ; get selector increment value
1119 b80800             	mov ax,8                        ; selector increment value is 8
111c e91dff             	jmp int31okax                   ; return ok, with AX
111f                    
111f                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
111f                    int310006:                              ; get segment base address
111f e82fff             	call int31testsel               ; test for valid selector BX
1122                    
1122 678b541f02         	mov dx,word [edi+ebx+2]  ; low word of 32bit linear address
1127 678a4c1f04         	mov cl,byte [edi+ebx+4]  ; high word of 32bit linear address
112c 678a6c1f07         	mov ch,byte [edi+ebx+7]
1131                    
1131 e9e9fe             	jmp int31okdx                   ; return ok, with DX, CX, AX
1134                    
1134                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1134                    int310007:                              ; set segment base address
1134 e81aff             	call int31testsel               ; test for valid selector BX
1137                    
1137 6789541f02         	mov word [edi+ebx+2],dx  ; low word of 32bit linear address
113c 67884c1f04         	mov byte [edi+ebx+4],cl  ; high word of 32bit linear address
1141 67886c1f07         	mov byte [edi+ebx+7],ch
1146                    
1146 e9f8fe             	jmp int31ok                     ; return ok
1149                    
1149                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1149                    int310008:                              ; set segment limit
1149 e805ff             	call int31testsel               ; test for valid selector BX
114c                    
114c 83f90f             	cmp cx,$f                      ; limit greater than 1M?
114f 7616               	jbe short int310008f0
1151                    
1151 8bc2               	mov ax,dx                       ; yup, limit greater than 1M
1153 25ff0f             	and ax,$fff
1156 3dff0f             	cmp ax,$fff                    ; low 12 bits set?
1159 0f8556fe           	jne int31fail8021               ; if no, error 8021h
115d                    
115d 0facca0c           	shrd dx,cx,12                   ; DX = low 16 bits of page limit
1161 c1e90c             	shr cx,12                       ; CL = high 4 bits of page limit
1164 80c980             	or cl,$80                       ; set granularity bit in CL
1167                    
1167                    int310008f0:
1167 6789141f           	mov word [edi+ebx],dx    ; put low word of limit
116b 6780641f0670       	and byte [edi+ebx+6],$70 ; mask off G and high nybble of limit
1171 67084c1f06         	or byte [edi+ebx+6],cl   ; put high nybble of limit
1176                    
1176 e9c8fe             	jmp int31ok                     ; return ok
1179                    
1179                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1179                    int310009:                              ; set descriptor access rights
1179 e8d5fe             	call int31testsel               ; test for valid selector BX
117c                    
117c e8f5fe             	call int31testaccess            ; test access bits in CX
117f                    
117f 80cd10             	or ch,$10                       ; set AVL bit, descriptor used
1182 80e5f0             	and ch,$f0                     ; mask off low nybble of CH
1185 6780641f060f       	and byte [edi+ebx+6],$f ; mask off high nybble access rights
118b 67086c1f06         	or byte [edi+ebx+6],ch   ; or in high access rights byte
1190 67884c1f05         	mov byte [edi+ebx+5],cl  ; put low access rights byte
1195                    
1195 e9a9fe             	jmp int31ok                     ; return ok
1198                    
1198                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1198                    int31000a:                              ; create alias descriptor
1198 e8b6fe             	call int31testsel               ; test for valid selector BX
119b                    
119b b80000             	mov ax,$0000                    ; allocate descriptor
119e b90100             	mov cx,1
11a1 cd31               	int $31
11a3 0f8239fe           	jc int31fail8011                ; if failed, descriptor unavailable
11a7                    
11a7 50                 	push ax                         ; preserve allocated selector
11a8                    
11a8 1e                 	push ds                         ; copy descriptor and set type data
11a9 07                 	pop es
11aa 660fb7f8           	movzx edi,ax                    ; EDI = target selector
11ae 662e8b369202       	mov esi,cs:gdtbase              ; ESI -> GDT
11b4 6603fe             	add edi,esi                     ; adjust to target descriptor in GDT
11b7 6603f3             	add esi,ebx                     ; adjust to source descriptor in GDT
11ba                    
11ba 6667a5             	movs long es:[edi],long ds:[esi]      ; copy descriptor
11bd 6667ad             	lods long ds:[esi]
11c0 b492               	mov ah,$92                      ; set descriptor type - R/W up data
11c2 6667ab             	stos long es:[edi]
11c5                    
11c5 58                 	pop ax                          ; restore allocated selector
11c6                    
11c6 e973fe             	jmp int31okax                   ; return ok, with AX
11c9                    
11c9                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
11c9                    int31000b:                              ; get descriptor
11c9 e885fe             	call int31testsel               ; test for valid selector BX
11cc                    
11cc 66678d341f         	lea esi,[edi+ebx]               ; ESI -> descriptor in GDT
11d1 66678b3c24         	mov edi,[esp]                   ; get EDI buffer ptr from stack
11d6 6667a5             	movs long es:[edi],long ds:[esi]      ; copy descriptor
11d9 6667a5             	movs long es:[edi],long ds:[esi]
11dc                    
11dc e962fe             	jmp int31ok                     ; return ok
11df                    
11df                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
11df                    int31000c:                              ; set descriptor
11df e86ffe             	call int31testsel               ; test for valid selector BX
11e2                    
11e2 66678b3424         	mov esi,[esp]                   ; ESI = EDI buffer ptr from stack
11e7 26678b4e05         	mov cx,es:[esi+5]               ; get access rights from descriptor
11ec e885fe             	call int31testaccess            ; test access bits in CX
11ef                    
11ef 1e                 	push ds                         ; swap DS and ES, target and source
11f0 06                 	push es
11f1 1f                 	pop ds
11f2 07                 	pop es
11f3                    
11f3 6603fb             	add edi,ebx                     ; adjust EDI to descriptor in GDT
11f6 6667a5             	movs long es:[edi],long ds:[esi]      ; copy descriptor
11f9 6667ad             	lods long ds:[esi]
11fc 6681c800001000     	or eax,$100000                  ; set descriptor AVL bit
1203 6667ab             	stos long es:[edi]
1206                    
1206 e938fe             	jmp int31ok                     ; return ok
1209                    
1209                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1209                    int31000e:                              ; get multiple descriptors
1209 b80b00             	mov ax,$000b                    ; function 000bh, get descriptor
120c                    
120c                    ;-----------------------------------------------------------------------------
120c                    int31000ef:                             ; common to funcions 000eh and 000fh
120c 0bc9               	or cx,cx                        ; if CX = 0, return ok immediately
120e 0f842ffe           	jz int31ok
1212                    
1212 8bd1               	mov dx,cx                       ; DX = number of descriptors
1214 33c9               	xor cx,cx                       ; CX = successful counter
1216                    int31000efl0:
1216 26678b1f           	mov bx,es:[edi]                 ; BX = selector to get
121a 6683c702           	add edi,2
121e                    
121e cd31               	int $31                        ; get/set descriptor
1220 0f82d7fd           	jc int31failcx                  ; if error, fail with AX and CX
1224                    
1224 6683c708           	add edi,8                       ; increment descriptor ptr
1228 41                 	inc cx                          ; increment successful copy counter
1229 4a                 	dec dx                          ; decrement loop counter
122a 0f85e8ff           	jnz int31000efl0              ; if more descriptors to go, loop
122e                    
122e e910fe             	jmp int31ok                     ; return ok
1231                    
1231                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1231                    int31000f:                              ; set multiple descriptors
1231 b80c00             	mov ax,$000c                    ; function 000ch, set descriptor
1234                    
1234 e9d5ff             	jmp int31000ef                  ; go to common function
1237                    
1237                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1237                    ; INTERRUPT FUNCTIONS
1237                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1237                    
1237                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1237                    int310200:                              ; get real mode interrupt vector
1237 660fb6db           	movzx ebx,bl                    ; EBX = BL (interrupt number)
123b 678b149d00000000   	mov dx,[ebx*4]               ; load real mode vector offset
1243 678b0c9d02000000   	mov cx,[ebx*4+2]             ; load real mode vector segment
124b                    
124b e9cffd             	jmp int31okdx                   ; return ok, with AX, CX, DX
124e                    
124e                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
124e                    int310201:                              ; set real mode interrupt vector
124e 660fb6db           	movzx ebx,bl                    ; EBX = BL (interrupt number)
1252 6789149d00000000   	mov [ebx*4],dx               ; set real mode vector offset
125a 67890c9d02000000   	mov [ebx*4+2],cx             ; set real mode vector segment
1262                    
1262 e9dcfd             	jmp int31ok                     ; return ok
1265                    
1265                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1265                    int310204:                              ; get protected mode interrupt vector
1265 80fb03             	cmp bl,3                        ; INT 3 vector?
1268 741d               	je short int310204f00         ; if yes, go to special INT 3 handling
126a                    
126a 660fb6db           	movzx ebx,bl                    ; EBX = BL (interrupt number)
126e 66c1e303           	shl ebx,3                       ; adjust for location in IDT
1272 662e031e9802       	add ebx,cs:idtbase              ; add base of IDT
1278                    
1278 66678b5304         	mov edx,long [ebx+4]    ; get high word of offset
127d 678b13             	mov dx,word [ebx]        ; get low word of offset
1280 678b4b02           	mov cx,word [ebx+2]      ; get selector
1284                    
1284 e98efd             	jmp int31okedx                  ; return ok, with AX, CX, EDX
1287                    
1287                    int310204f00:
1287 662e8b166002       	mov edx,long cs:[int3vector]      ; get offset of INT 3
128d 2e8b0e6402         	mov cx,word cs:[int3vector+4]        ; get selector of INT 3
1292                    
1292 e980fd             	jmp int31okedx                  ; return ok, with AX, CX, EDX
1295                    
1295                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1295                    int310205:                              ; set protected mode interrupt vector
1295 87d9               	xchg bx,cx                      ; swap int number with int selector
1297 e8b7fd             	call int31testsel               ; test for valid selector BX
129a                    
129a 80f903             	cmp cl,3                        ; INT 3 vector?
129d 7420               	je short int310205f00         ; if yes, go to special INT 3 handling
129f                    
129f 660fb6c9           	movzx ecx,cl                    ; ECX = CL (interrupt number)
12a3 66c1e103           	shl ecx,3                       ; adjust for location in IDT
12a7 662e030e9802       	add ecx,cs:idtbase              ; add base of IDT
12ad                    
12ad 678911             	mov word [ecx],dx        ; set low word of offset
12b0 66c1ea10           	shr edx,16
12b4 67895106           	mov word [ecx+6],dx      ; set high word of offset
12b8 67895902           	mov word [ecx+2],bx      ; set selector
12bc                    
12bc e982fd             	jmp int31ok                     ; return ok
12bf                    
12bf                    int310205f00:
12bf 662e8b3e5002       	mov edi,cs:codebase             ; EDI = offset of code32s from 0
12c5                    
12c5 6667899760020000   	mov long [edi+int3vector],edx  ; set offset of INT 3
12cd 67899f64020000     	mov word [edi+int3vector+4],bx    ; set selector of INT 3
12d4                    
12d4 e96afd             	jmp int31ok                     ; return ok
12d7                    
12d7                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
12d7                    int310900:                              ; get and disable interrupt state
12d7 6683c426           	add esp,$26                     ; adjust stack
12db 1f                 	pop ds                          ; restore DS
12dc                    
12dc 670fba7c240809     	btc word [esp+8],9          ; test and clear IF bit in EFLAGS
12e3 0f92c0             	setc al                         ; set AL = carry (IF flag from EFLAGS)
12e6                    
12e6 e960fd             	jmp int31oknopop                ; return ok, dont pop registers
12e9                    
12e9                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
12e9                    int310901:                              ; get and enable interrupt state
12e9 6683c426           	add esp,$26                     ; adjust stack
12ed 1f                 	pop ds                          ; restore DS
12ee                    
12ee 670fba6c240809     	bts word [esp+8],9          ; test and set IF bit in EFLAGS
12f5 0f92c0             	setc al                         ; set AL = carry (IF flag from EFLAGS)
12f8                    
12f8 e94efd             	jmp int31oknopop                ; return ok, dont pop registers
12fb                    
12fb                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
12fb                    int310902:                              ; get interrupt state
12fb 6683c426           	add esp,$26                     ; adjust stack
12ff 1f                 	pop ds                          ; restore DS
1300                    
1300 670fba64240809     	bt word [esp+8],9           ; just test IF bit in EFLAGS
1307 0f92c0             	setc al                         ; set AL = carry (IF flag from EFLAGS)
130a                    
130a e93cfd             	jmp int31oknopop                ; return ok, dont pop registers
130d                    
130d                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
130d                    ; REAL/PROTECTED MODE TRANSLATION FUNCTIONS
130d                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
130d                    
130d                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
130d                    int310300:                              ; simulate real mode interrupt
130d 660fb6db           	movzx ebx,bl                    ; get real mode INT CS:IP
1311 66678b2c9d000000   	mov ebp,long [ebx*4]
1319 00
131a                    
131a eb06               	jmp short int3103               ; go to common code
131c                    
131c                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
131c                    int310301:                              ; call real mode FAR procedure
131c                    	                                ; same start as function 0302h
131c                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
131c                    int310302:                              ; call real mode IRET procedure
131c 6626678b6f2a       	mov ebp,long es:[edi+$2a]  ; get target CS:IP from structure
1322                    
1322                    ;-----------------------------------------------------------------------------
1322                    int3103:                                ; common to 0300h, 0301h, and 0302h
1322 662e8b365002       	mov esi,cs:codebase             ; ESI = offset of code32s from 0
1328                    
1328 6626670fb75f2e     	movzx ebx,word es:[edi+$2e] ; EBX = SP from register structure
132f 6626670fb75730     	movzx edx,word es:[edi+$30] ; EDX = SS from register structure
1336                    
1336 8bc3               	mov ax,bx                       ; check if caller provided stack
1338 0bc2               	or ax,dx
133a 751f               	jnz short int3103f3           ; if yes, go on to set stack
133c                    
133c 2e8b168a02         	mov dx,cs:rmstacktop            ; DX = SS for real mode redirection
1341 2e8b1eb802         	mov bx,cs:_pm_rmstacklen        ; get size of real mode stack
1346 2bd3               	sub dx,bx                       ; adjust DX to next stack location
1348                    
1348 2e3b168802         	cmp dx,cs:rmstackbase           ; exceeded real mode stack space?
134d 0f8286fc           	jb int31fail8012                ; if yes, error 8012h
1351                    
1351 6789968a020000     	mov [esi+rmstacktop],dx       ; update ptr for possible reenterancy
1358 c1e304             	shl bx,4                        ; adjust BX from paragraphs to bytes
135b                    
135b                    int3103f3:
135b 66678d3c95000000   	lea edi,[edx*4]                 ; EDI -> top of real mode stack
1363 00
1364 66678d3cbb         	lea edi,[ebx+edi*4]
1369                    
1369 8d47f8             	lea ax,[bx-8]                   ; AX = top of stack parms
136c 6787868c020000     	xchg ax,[esi+rmstackparmtop]  ; preserve and set new top of stack
1373 50                 	push ax                         ;  parms for possible reenterancy
1374                    
1374 670fb644241e       	movzx ax,byte [esp+30]      ; AX = AL of original INT 31h call
137a 2401               	and al,1                        ; if function 0301h, AL=0, else, AL=2
137c 3401               	xor al,1
137e d0e0               	shl al,1
1380 2bd8               	sub bx,ax                       ; adjust BX for possible FLAGS
1382                    
1382 660fb7c1           	movzx eax,cx                    ; EAX = length of stack parms
1386 66d1e0             	shl eax,1
1389 83eb36             	sub bx,$36                      ; adjust real mode SP for needed vars
138c 2bd8               	sub bx,ax                       ; adjust real mode SP for stack parms
138e                    
138e 678c57fe           	mov [edi-2],ss               ; store SS:ESP on real mode stack
1392 66678967fa         	mov [edi-6],esp
1397 678c47f8           	mov [edi-8],es               ; store ES on real mode stack
139b                    
139b 1e                 	push ds                         ; swap DS and ES
139c 06                 	push es
139d 1f                 	pop ds
139e 07                 	pop es
139f                    
139f fd                 	std                             ; string copy backwards
13a0                    
13a0 6683ef0a           	sub edi,10                      ; copy stack parms from protected mode
13a4 660fb7c9           	movzx ecx,cx                    ;  stack to real mode stack
13a8 66678d744c34       	lea esi,[esp+ecx*2+$36-2]
13ae f36736a5           	rep movs word es:[edi],word ss:[esi]
13b2                    
13b2 66678b742402       	mov esi,[esp+2]                 ; ESI = offset of structure from stack
13b8 678b4620           	mov ax,[esi+$20]                ; AX = FLAGS from register structure
13bc                    
13bc 26678907           	mov es:[edi],ax                 ; store data for real mode return IRET
13c0                    
13c0 67807c241e01       	cmp byte [esp+30],1         ; check AL on stack for function code
13c6 7403               	je short int3103f4            ; if function 0301h, go on
13c8                    
13c8 80e4fc             	and ah,$fc                     ; 0300h or 0302h, clear IF and TF flag
13cb                    
13cb                    int3103f4:
13cb fc                 	cld                             ; string copy forward
13cc 66678d3c95000000   	lea edi,[edx*4]                 ; EDI -> bottom of stack
13d4 00
13d5 66678d3cbb         	lea edi,[ebx+edi*4]
13da                    
13da 66b908000000       	mov ecx,8                       ; copy general regs to real mode stack
13e0 f36667a5           	rep movs long es:[edi],long ds:[esi]
13e4                    
13e4 6683c606           	add esi,6                       ; copy FS and GS to real mode stack
13e8 6667a5             	movs long es:[edi],long ds:[esi]
13eb                    
13eb 2e8b0e3501         	mov cx,cs:_code32s
13f0 2667894f08         	mov word es:[edi+8],cx   ;(DA)word code32s      ; return address from call
13f5 2667c747062214     	mov word es:[edi+6],offset int3103f1
13fc                    
13fc 2667894704         	mov es:[edi+4],ax               ; store FLAGS for real mode IRET maybe
1401 662667892f         	mov long es:[edi],ebp      ; put call address to real mode stack
1406                    
1406 678b46fa           	mov ax,[esi-6]                  ; real mode DS from register structure
140a 678b4ef8           	mov cx,[esi-8]                  ; real mode ES from register structure
140e                    
140e 2e8b363501         	mov si,word cs:_code32s               ; real mode target CS:IP
1413 bf1b14             	mov di,offset int3103f0
1416                    
1416 2eff26a402         	jmp word cs:[pmtormswrout]    ;  not seg:16bit offset
141b                    
141b                    int3103f0:                            ; real mode INT, FAR, or IRET call
141b 6661               	popad                           ; load regs with call values
141d 0fa10fa9           	pop fs gs
1421                    
1421 cf                 	iret                            ; go to call address
1422                    
1422                    int3103f1:
1422 2e8b268c02         	mov sp,cs:rmstackparmtop        ; remove stack parameters
1427                    
1427 0fa80fa01e06       	push gs fs ds es                ; store registers on stack
142d 9c                 	pushf                           ; store flags on stack
142e 6660               	pushad
1430 fa                 	cli
1431                    
1431 8cd0               	mov ax,ss                       ; EAX = linear ptr to SS
1433 660fb7c0           	movzx eax,ax
1437 66c1e004           	shl eax,4
143b 660fb7ec           	movzx ebp,sp                    ; EBP = SP
143f                    
143f 8b4e2a             	mov cx,[bp+$2a]                 ; get protected mode ES from stack
1442 668b5e2c           	mov ebx,[bp+$2c]                ; get protected mode SS:ESP from stack
1446 8b5630             	mov dx,[bp+$30]
1449                    
1449 6603e8             	add ebp,eax                     ; EBP -> stored regs on stack
144c                    
144c b81000             	mov ax,SELZERO                  ; DS selector value for protected mode
144f be0800             	mov si,SELCODE                  ; target CS:EIP in protected mode
1452 66bf5d140000       	mov edi,offset int3103f2
1458                    
1458 2eff26a202         	jmp word cs:[rmtopmswrout]             ; go back to protected mode
145d                    
145d                    int3103f2:
145d 662e8b3e5002       	mov edi,cs:codebase             ; restore old stack parameter length
1463 678f878c020000     	pop word [edi+rmstackparmtop]
146a                    
146a 66678b3c24         	mov edi,[esp]                   ; get structure offset from stack
146f 668bf5             	mov esi,ebp                     ; copy return regs from real mode
1472 66b915000000       	mov ecx,$15                     ;  stack to register structure
1478 fc                 	cld
1479 f367a5             	rep movs word es:[edi],word ds:[esi]
147c                    
147c 662667837f0400     	cmp long es:[edi+4],0      ; stack provided by caller?
1483 0f85bafb           	jne int31ok                     ; if yes, done now
1487                    
1487 662e8b3e5002       	mov edi,cs:codebase             ; restore top of real mode stack
148d 2ea1b802           	mov ax,cs:_pm_rmstacklen
1491 6701878a020000     	add [edi+rmstacktop],ax
1498                    
1498 e9a6fb             	jmp int31ok                     ; return ok
149b                    
149b                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
149b                    int310303:                              ; allocate real mode callback address
149b 2e8a1ebe02         	mov bl,cs:_pm_callbacks         ; CL = total number of callbacks
14a0 0adb               	or bl,bl                        ; are there any?
14a2 0f841ffb           	jz int31fail8015                ; if no, error 8015h
14a6                    
14a6 662e8b167402       	mov edx,cs:callbackbase         ; EDX -> base of callbacks
14ac 668bca             	mov ecx,edx                     ; for later use
14af                    
14af                    int310303l0:
14af 67837a0300         	cmp word [edx+3],0          ; is this callback free?
14b4 740d               	jz short int310303f0          ; if yes, allocate
14b6                    
14b6 6683c219           	add edx,25                      ; increment ptr to callback
14ba fecb               	dec bl                          ; decrement loop counter
14bc 0f85efff           	jnz int310303l0               ; if more callbacks to check, loop
14c0                    
14c0 e902fb             	jmp int31fail8015               ; no free callback, error 8015h
14c3                    
14c3                    int310303f0:
14c3 678b5c2426         	mov bx,[esp+38]                 ; BX = caller DS from stack
14c8 67895a03           	mov [edx+3],bx                  ; store callback parms in callback
14cc 6667897207         	mov [edx+7],esi
14d1 678c420c           	mov [edx+12],es
14d5 6667897a10         	mov [edx+16],edi
14da                    
14da 662bd1             	sub edx,ecx                     ; DX = offset of callback
14dd 66c1e904           	shr ecx,4                       ; CX = segment of callback
14e1                    
14e1 e939fb             	jmp int31okdx                   ; return ok, with DX, CX, AX
14e4                    
14e4                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
14e4                    int310304:                              ; free real mode callback address
14e4 2e3b0e7802         	cmp cx,cs:callbackseg           ; valid callback segment?
14e9 0f85abfa           	jne int31fail8024               ; if no, error 8024h
14ed                    
14ed 660fb7da           	movzx ebx,dx                    ; EBX = offset of callback
14f1                    
14f1 33c0               	xor ax,ax                       ; check if valid offset
14f3 92                 	xchg dx,ax
14f4 b91900             	mov cx,25
14f7 f7f1               	div cx
14f9                    
14f9 0bd2               	or dx,dx                        ; is there a remainder
14fb 0f8599fa           	jnz int31fail8024               ; if yes, not valid, error 8024h
14ff                    
14ff 0ae4               	or ah,ah                        ; callback index too big?
1501 0f8593fa           	jnz int31fail8024               ; if yes, not valid, error 8024h
1505                    
1505 2e3a06be02         	cmp al,cs:_pm_callbacks         ; callback index out of range?
150a 0f838afa           	jae int31fail8024               ; if yes, not valid, error 8024h
150e                    
150e 662e031e7402       	add ebx,cs:callbackbase         ; EBX -> callback
1514 67c743030000       	mov word [ebx+3],0          ; set callback as free
151a                    
151a e924fb             	jmp int31ok                     ; return ok
151d                    
151d                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
151d                    ; MISC FUNCTIONS
151d                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
151d                    
151d                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
151d                    int310305:                              ; get state save/restore addresses
151d 6683c426           	add esp,$26                     ; adjust stack
1521 1f                 	pop ds                          ; restore DS
1522                    
1522 33c0               	xor ax,ax                       ; size needed is none
1524 2e8b1e3501         	mov bx,word cs:_code32s               ; real mode seg of same RETF
1529 b9740b             	mov cx,offset vxr_saverestorerm    ; same offset of 16bit RETF
152c 8cce               	mov si,cs                       ; selector of routine is this one
152e 66bf750b0000       	mov edi,offset vxr_saverestorepm   ; offset of simple 32bit RETF
1534                    
1534 e912fb             	jmp int31oknopop                ; return ok, dont pop registers
1537                    
1537                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1537                    int310306:                              ; get raw mode switch addresses
1537 6683c426           	add esp,$26                     ; adjust stack
153b 1f                 	pop ds                          ; restore DS
153c                    
153c 8cce               	mov si,cs                       ; selector of pmtorm rout is this one
153e 662e8b3ea402       	mov edi,cs:pmtormswrout         ; offset in this seg of rout
1544 2e8b1e3501         	mov bx,word cs:_code32s               ; real mode seg of rmtopm rout
1549 2e8b0ea202         	mov cx,cs:rmtopmswrout          ; offset of rout in real mode
154e                    
154e e9f8fa             	jmp int31oknopop                ; return ok, dont pop registers
1551                    
1551                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1551                    int310400:                              ; get version
1551 6683c426           	add esp,$26                     ; adjust stack
1555 1f                 	pop ds                          ; restore DS
1556                    
1556 b80001             	mov ax,$100                     ; return version 1.0
1559 bb0300             	mov bx,3                        ; capabilities
155c 2e8a0ec002         	mov cl,cs:processortype         ; processor type
1561 2e8b16c202         	mov dx,word cs:picslave     ; master and slave PIC values
1566                    
1566 e9e0fa             	jmp int31oknopop                ; return ok, dont pop registers
1569                    
1569                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1569                    ; VCPI EXTENDED MEMORY FUNCTIONS
1569                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1569                    
1569                    ;-----------------------------------------------------------------------------
1569                    int310500vsiditoesi:                    ; convert handle SI:DI to ptr ESI
1569 5d                 	pop bp                          ; pop return address
156a                    
156a f7c70300           	test di,3                       ; is handle (ptr) aligned on dword?
156e 0f852ffa           	jnz int31fail8023               ; if no, error 8023h
1572                    
1572 66c1e610           	shl esi,16                      ; ESI = SI:DI
1576 8bf7               	mov si,di
1578                    
1578 662e3b36b002       	cmp esi,cs:pagetablefree        ; handle too low?
157e 0f821ffa           	jb int31fail8023                ; if yes, error 8023h
1582                    
1582 662e3b36ac02       	cmp esi,cs:pagetabletop         ; handle too high?
1588 0f8315fa           	jae int31fail8023               ; if yes, error 8023h
158c                    
158c 67f6460102         	test byte [esi+1],2         ; is page first in allocated block?
1591 0f840cfa           	jz int31fail8023                ; if no, error 8023h
1595                    
1595 ffe5               	jmp bp                          ; return ok
1597                    
1597                    ;-----------------------------------------------------------------------------
1597                    int310500vbxcxtoebx:                    ; convert BX:CX bytes to EBX pages
1597 5d                 	pop bp                          ; pop return address
1598                    
1598 66c1e310           	shl ebx,16                      ; EBX = BX:CX
159c 8bd9               	mov bx,cx
159e                    
159e 660bdb             	or ebx,ebx                      ; check for invalid value
15a1 0f840efa           	jz int31fail8021                ; if invalid value, error 8021h
15a5                    
15a5 6681c3ff0f0000     	add ebx,$fff                   ; convert EBX to page count
15ac 66c1eb0c           	shr ebx,12
15b0                    
15b0 ffe5               	jmp bp                          ; return ok
15b2                    
15b2                    ;-----------------------------------------------------------------------------
15b2                    int310500vpmalloc:                      ; allocate physical memory block
15b2 668bfe             	mov edi,esi                     ; EDI = ESI, ptr to linear block start
15b5 6633ed             	xor ebp,ebp                     ; EBP = running allocated page count
15b8                    
15b8                    int310500vpmallocl0:
15b8 b804de             	mov ax,$de04                   ; VCPI allocate a page
15bb 662eff1ee602       	fcall long cs:[vcpi_calleip]
15c1                    
15c1 0ae4               	or ah,ah                        ; got a page?
15c3 7411               	jz short int310500vpmallocl0f0; if yes, go on
15c5                    
15c5 6683fd01           	cmp ebp,1			; allocated any pages?
15c9 722c               	jc short int310500vpmallocdone; if no, fail immediately
15cb                    
15cb 67804ffd04         	or byte [edi-3],4		; set last allocated page as last
15d0                    
15d0 e89e00             	call int310500vfree		; free what was allocated
15d3                    
15d3 f9                 	stc				; carry set, failed
15d4 eb21               	jmp short int310500vpmallocdone	; go to done
15d6                    
15d6                    int310500vpmallocl0f0:
15d6 80e6f0             	and dh,$f0                     ; clear 4 bits of page table entry
15d9 b207               	mov dl,7                        ; set page as user/writeable/present
15db 66678917           	mov [edi],edx                   ; store page in page table
15df 6683c704           	add edi,4			; increment page table ptr
15e3                    
15e3 6645               	inc ebp 			; increment allocated page count
15e5 663beb             	cmp ebp,ebx			; allocated all needed pages?
15e8 0f82ccff           	jb int310500vpmallocl0	; if no, loop
15ec                    
15ec 67804e0102         	or byte  [esi+1],2           ; set first allocated page as first
15f1 67804ffd04         	or byte  [edi-3],4           ; set last allocated page as last
15f6 f8                 	clc                             ; carry clear, success
15f7                    
15f7                    int310500vpmallocdone:
15f7 668bc5             	mov eax,ebp                     ; EAX = number of pages allocated
15fa c3                 	ret				; return
15fb                    
15fb                    ;-----------------------------------------------------------------------------
15fb                    int310500vlmalloc:                      ; check for linear memory block
15fb 662e8b3eb002       	mov edi,cs:pagetablefree        ; EDI = search ptr in page table
1601                    
1601 662e8b0eac02       	mov ecx,cs:pagetabletop         ; ECX = count of pages to search
1607 662bcf             	sub ecx,edi
160a 66c1e902           	shr ecx,2
160e                    
160e 6633d2             	xor edx,edx                     ; EDX = largest linear block found
1611 6633c0             	xor eax,eax                     ; EAX = search unit, free entry (0)
1614                    
1614 6653               	push ebx                        ; preserve EBX, memory requested
1616                    
1616                    int310500vlmallocl0:
1616 e32f               	jecxz short int310500vlmallocdone     ; if no more entries, done
1618                    
1618 f26667af           	repne scas long es:[edi]   ; search for first next free entry
161c 7529               	jne short int310500vlmallocdone       ; if no more free, go on
161e                    
161e 668be9             	mov ebp,ecx                     ; EBP = current count
1621 66678d5ffc         	lea ebx,[edi-4]                 ; EBX = start of free block
1626                    
1626 f36667af           	repe scas long es:[edi]    ; search for end of free linear block
162a 7502               	jne short int310500vlmallocl0f0; if previous entry not free, go on
162c                    
162c 6645               	inc ebp                         ; previous entry free, extra one
162e                    
162e                    int310500vlmallocl0f0:
162e 662be9             	sub ebp,ecx                     ; EBP = number of free pages in block
1631                    
1631 663bea             	cmp ebp,edx                     ; new block larger than last largest?
1634 0f82deff           	jb int310500vlmallocl0        ; if no, loop
1638                    
1638 668bf3             	mov esi,ebx                     ; ESI = ptr to largest block found
163b 668bd5             	mov edx,ebp                     ; size of new largest block found
163e                    
163e 66673b2c24         	cmp ebp,[esp]                   ; block sufficient for memory request?
1643 0f82cfff           	jb int310500vlmallocl0        ; if no, loop
1647                    
1647                    int310500vlmallocdone:
1647 665b               	pop ebx                         ; restore EBX, memory requested
1649 c3                 	ret                             ; return
164a                    
164a                    ;-----------------------------------------------------------------------------
164a                    int310500vmalloc:                       ; allocate linear+physical mem block
164a e8aeff             	call int310500vlmalloc          ; try to allocate linear memory block
164d                    
164d 6683fa01           	cmp edx,1                       ; found ANY free linear area?
1651 721d               	jc short int310500vmallocdone ; if no, done
1653                    
1653 663bd3             	cmp edx,ebx                     ; linear block enough for request?
1656 7207               	jb short int310500vmallocf0   ; if no, go to physical memory check
1658                    
1658 e857ff             	call int310500vpmalloc          ; try to allocate physical mem
165b                    
165b b101               	mov cl,1                        ; error is not enough physical memory
165d eb11               	jmp short int310500vmallocdone; go to done
165f                    
165f                    int310500vmallocf0:
165f 668bda             	mov ebx,edx                     ; only linear block size physical mem
1662                    
1662 e84dff             	call int310500vpmalloc          ; try to allocate physical memory
1665 7207               	jc short int310500vmallocfaillinear   ; if failed, done
1667                    
1667 e80700             	call int310500vfree             ; success, so must free block
166a                    
166a 668bc3             	mov eax,ebx                     ; can allocate this much total memory
166d f9                 	stc                             ; carry set, failed
166e                    
166e                    int310500vmallocfaillinear:
166e b100               	mov cl,0                        ; error is not enough linear memory
1670                    
1670                    int310500vmallocdone:
1670 c3                 	ret                             ; return
1671                    
1671                    ;-----------------------------------------------------------------------------
1671                    int310500vfree:                         ; free linear+physical memory block
1671 668bfe             	mov edi,esi                     ; EDI = ESI, ptr to linear block start
1674                    
1674                    int310500vfreel0:
1674 6633c9             	xor ecx,ecx                     ; new page table entry is free (0)
1677 6667870f           	xchg ecx,[edi]			; swap ECX with page table entry
167b 6683c704           	add edi,4			; increment page table ptr
167f                    
167f 668bd1             	mov edx,ecx                     ; EDX = page table entry
1682 81e200f0           	and dx,$f000                   ; mask off low 12 bits
1686                    
1686 b805de             	mov ax,$de05                   ; VCPI free a page
1689 662eff1ee602       	fcall long cs:[vcpi_calleip]
168f                    
168f f6c504             	test ch,4                       ; last page of block?
1692 0f84deff           	jz int310500vfreel0           ; if no, loop
1696                    
1696 c3                 	ret                             ; return
1697                    
1697                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1697                    int310500v:                             ; VCPI get free memory information
1697 1e                 	push ds                         ; ES = DS for VCPI malloc functions
1698 07                 	pop es
1699                    
1699 66bbffffffff       	mov ebx,$ffffffff              ; try to allocate an impossible amount
169f e8a8ff             	call int310500vmalloc
16a2                    
16a2 66c1e00c           	shl eax,12                      ; returned EAX is highest possible
16a6                    
16a6 e92a02             	jmp int310500xsetbuf            ; put memory information in buffer
16a9                    
16a9                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
16a9                    int310501v:                             ; VCPI allocate memory block
16a9 1e                 	push ds                         ; ES = DS for VCPI malloc functions
16aa 07                 	pop es
16ab                    
16ab e8e9fe             	call int310500vbxcxtoebx        ; convert BX:CX bytes to EBX pages
16ae                    
16ae e899ff             	call int310500vmalloc           ; try to allocate requested amount
16b1 7309               	jnc short int310501vaddxnhandle ; if successful, go to done
16b3                    
16b3 0ac9               	or cl,cl                        ; error is not enough linear memory?
16b5 0f841ef9           	jz int31fail8012                ; if yes, error 8013h
16b9 e912f9             	jmp int31fail8013               ; error is physical, error 8013h
16bc                    
16bc                    int310501vaddxnhandle:
16bc 668bce             	mov ecx,esi                     ; figure address of block from handle
16bf 662e2b0ea802       	sub ecx,cs:pagetablebase
16c5 66c1e10a           	shl ecx,10
16c9 660fa4cb10         	shld ebx,ecx,16
16ce                    
16ce 8bfe               	mov di,si                       ; SI:DI = ESI, handle
16d0 66c1ee10           	shr esi,16
16d4                    
16d4 662ea1d002         	mov eax,cs:vcpi_cr3             ; reload CR3 to clear TLB
16d9 0f22d8             	mov cr3,eax
16dc                    
16dc e945f9             	jmp int31oksinoax               ; return ok, with SI, DI, BX, CX
16df                    
16df                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
16df                    int310502v:                             ; VCPI free memory block
16df e887fe             	call int310500vsiditoesi        ; convert handle SI:DI to ptr ESI
16e2                    
16e2 e88cff             	call int310500vfree             ; free memory block
16e5                    
16e5 662ea1d002         	mov eax,cs:vcpi_cr3             ; reload CR3 to clear TLB
16ea 0f22d8             	mov cr3,eax
16ed                    
16ed e951f9             	jmp int31ok                     ; return ok
16f0                    
16f0                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
16f0                    int310503v:                             ; VCPI resize memory block
16f0 1e                 	push ds                         ; ES = DS for VCPI malloc functions
16f1 07                 	pop es
16f2                    
16f2 e8a2fe             	call int310500vbxcxtoebx        ; convert BX:CX bytes to EBX pages
16f5                    
16f5 e871fe             	call int310500vsiditoesi        ; convert handle SI:DI to ptr ESI
16f8                    
16f8 668bfe             	mov edi,esi                     ; EDI = ESI, ptr to linear block start
16fb 6633ed             	xor ebp,ebp                     ; EBP = running block size in pages
16fe                    
16fe                    int310503vl0:
16fe 6683c704           	add edi,4                       ; increment page table ptr
1702 6645               	inc ebp                         ; increment block size
1704                    
1704 67f647fd04         	test byte [edi-3],4         ; last page of block?
1709 0f84f1ff           	jz int310503vl0               ; if no, loop
170d                    
170d 662bdd             	sub ebx,ebp                     ; EBX = change in block size
1710 0f84a8ff           	jz int310501vaddxnhandle        ; if no change, done
1714                    
1714 0f826101           	jc int310503vf0               ; if block made smaller, just free top
1718                    
1718 662e8b0eac02       	mov ecx,cs:pagetabletop         ; ECX = count of pages to search
171e 662bcf             	sub ecx,edi
1721 66c1e902           	shr ecx,2
1725                    
1725 668bd1             	mov edx,ecx                     ; EDX = current count
1728 6633c0             	xor eax,eax                     ; EAX = search unit, free entry (0)
172b                    
172b e330               	jecxz short int310503vf3      ; if no entries above, try below
172d                    
172d f36667af           	repe scas long es:[edi]    ; check for free entries above block
1731 7402               	je short int310503vf2         ; if previous entry free, go on
1733                    
1733 664a               	dec edx                         ; previous entry not free, minus one
1735                    
1735                    int310503vf2:
1735 662bd1             	sub edx,ecx                     ; EDX = number of free pages in block
1738                    
1738 663bd3             	cmp edx,ebx                     ; enough linear memory?
173b 7220               	jb short int310503vf3         ; if no, try below in linear memory
173d                    
173d 6656               	push esi                        ; preserve start of block
173f 66678d34ae         	lea esi,[esi+ebp*4]             ; ESI -> start of new block for alloc
1744                    
1744 e86bfe             	call int310500vpmalloc          ; try to allocate physical memory
1747 668bfe             	mov edi,esi                     ; EDI -> start of new block
174a 665e               	pop esi                         ; restore start of old block
174c 0f827ef8           	jc int31fail8013                ; if alloc failed, error 8013h
1750                    
1750 678067fdfb         	and byte [edi-3],$fb       ; clear last bit in old block end
1755 67806701fd         	and byte [edi+1],$fd       ; clear first bit in new block start
175a                    
175a e95fff             	jmp int310501vaddxnhandle       ; go to done
175d                    
175d                    int310503vf3:
175d 668bce             	mov ecx,esi                     ; ECX = count of pages to search up
1760 662e2b0eb002       	sub ecx,cs:pagetablefree
1766 66c1e902           	shr ecx,2
176a                    
176a 660bc9             	or ecx,ecx                      ; any linear memory below?
176d 0f84b400           	jz int310503vf1               ; if no, try to allocate
1771                    
1771 6655               	push ebp                        ; preserve size of original block
1773                    
1773 66678d7efc         	lea edi,[esi-4]                 ; EDI = ESI, ptr to linear block start
1778 668be9             	mov ebp,ecx                     ; EBP = current count
177b                    
177b fd                 	std                             ; search is up
177c f36667af           	repe scas long es:[edi]    ; check for free entries after block
1780 fc                 	cld
1781 7402               	je short int310503vf4         ; if previous entry free, go on
1783                    
1783 664d               	dec ebp                         ; previous entry not free, minus one
1785                    
1785                    int310503vf4:
1785 662be9             	sub ebp,ecx                     ; EBP = number of free pages in block
1788 66678d0415         	lea eax,[ebp+edx]               ; free size below + free size above
178d                    
178d 665d               	pop ebp                         ; restore original block size
178f                    
178f 663bc3             	cmp eax,ebx                     ; enough linear memory?
1792 0f828f00           	jb int310503vf1               ; if no, try to allocate
1796                    
1796 6656               	push esi                        ; preserve original block address
1798                    
1798 662bda             	sub ebx,edx                     ; EBX = number of pages needed below
179b 66678d049d000000   	lea eax,[ebx*4]                 ; get base of block below
17a3 00
17a4 662bf0             	sub esi,eax
17a7                    
17a7 66526655           	push edx ebp                    ; preserve some vars
17ab e804fe             	call int310500vpmalloc          ; try to allocate physical memory
17ae 665d665a           	pop ebp edx                     ; restore some vars
17b2                    
17b2 668bfe             	mov edi,esi                     ; EDI -> base of block below
17b5 665e               	pop esi                         ; restore base of original block
17b7 0f8213f8           	jc int31fail8013                ; if alloc failed, error 8013h
17bb                    
17bb 660bd2             	or edx,edx                      ; any pages needed above?
17be 742d               	jz short int310503vf6         ; if no, go on
17c0                    
17c0 665666576655       	push esi edi ebp                ; preserve some vars
17c6                    
17c6 668bda             	mov ebx,edx                     ; EBX = size of block below
17c9 66678d34ae         	lea esi,[esi+ebp*4]             ; ESI -> start of block above
17ce                    
17ce e8e1fd             	call int310500vpmalloc          ; try to allocate physical memory
17d1 665d665f665e       	pop ebp edi esi                 ; restore some vars
17d7 7309               	jnc short int310503vf5        ; if allocated ok, go on
17d9                    
17d9 668bf7             	mov esi,edi                     ; ESI -> allocated block below
17dc e892fe             	call int310500vfree             ; free allocated block below
17df                    
17df e9ecf7             	jmp int31fail8013               ; fail, error 8013h
17e2                    
17e2                    int310503vf5:
17e2 678066fdfb         	and byte [esi-3],$fb       ; clear last bit in below block end
17e7 678064ae01fd       	and byte [esi+ebp*4+1],$fd ; clear first bit in above block start
17ed                    
17ed                    int310503vf6:
17ed 67806701fd         	and byte [edi+1],$fd       ; clear first bit in below block start
17f2 678064aefdfb       	and byte [esi+ebp*4-3],$fb ; clear last bit in old block end
17f8                    
17f8 6657               	push edi                        ; preserve new block start
17fa                    
17fa 668bd7             	mov edx,edi                     ; EDX = base of move area
17fd 66678d5efc         	lea ebx,[esi-4]                 ; EBX = current location in move area
1802                    
1802                    int310503vl1:
1802 668bfb             	mov edi,ebx                     ; set up to shift up a page
1805 668bf3             	mov esi,ebx
1808 668bcd             	mov ecx,ebp
180b                    
180b 6667ad             	lods long ds:[esi]         ; shift old pages a page down in table
180e f36667a5           	rep movs long es:[edi],long ds:[esi]
1812 6667ab             	stos long es:[edi]
1815                    
1815 6683eb04           	sub ebx,4                       ; decrement to next page to shift
1819 663bda             	cmp ebx,edx                     ; more pages to shift?
181c 0f83e2ff           	jae int310503vl1              ; if yes, loop
1820                    
1820 665e               	pop esi                         ; restore new block start address
1822                    
1822 e997fe             	jmp int310501vaddxnhandle       ; go to done
1825                    
1825                    int310503vf1:
1825 6603dd             	add ebx,ebp                     ; restore EBX as requested size
1828                    
1828 66566655           	push esi ebp                    ; preserve some vars
182c e8ccfd             	call int310500vlmalloc          ; check for linear memory block
182f 665d665f           	pop ebp edi                     ; restore some vars
1833                    
1833 663bd3             	cmp edx,ebx                     ; enough linear memory?
1836 0f829df7           	jb int31fail8012                ; if no, error 8012h
183a                    
183a 662bdd             	sub ebx,ebp                     ; EBX = extra pages needed
183d 6656               	push esi                        ; preserve for later copy
183f 66678d34ae         	lea esi,[esi+ebp*4]             ; ESI -> start of extra space needed
1844                    
1844 66576655           	push edi ebp                    ; preserve some vars
1848 e867fd             	call int310500vpmalloc          ; try to allocate physical memory
184b 6659665e665f       	pop ecx esi edi                 ; restore some vars
1851 0f8279f7           	jc int31fail8013                ; if not enough mem, error 8013h
1855                    
1855 665766566651       	push edi esi ecx                ; preserve, new and old block, size
185b                    
185b f36667a5           	rep movs long es:[edi],long ds:[esi]  ; copy old block pages
185f                    
185f 678067fdfb         	and byte [edi-3],$fb       ; clear last bit in old block end
1864 67806701fd         	and byte [edi+1],$fd       ; clear first bit in new block start
1869                    
1869 6659665f           	pop ecx edi                     ; restore to clear old block
186d                    
186d 6633c0             	xor eax,eax                     ; new page table entry is free (0)
1870 f36667ab           	rep stos long es:[edi]     ; clear old page table block
1874                    
1874 665e               	pop esi                         ; restore new block address
1876                    
1876 e943fe             	jmp int310501vaddxnhandle       ; go to done
1879                    
1879                    int310503vf0:
1879 6683ef04           	sub edi,4                       ; decrement page table ptr
187d                    
187d 6633d2             	xor edx,edx                     ; new page table entry is free (0)
1880 66678717           	xchg edx,[edi]                  ; swap EDX with page table entry
1884 81e200f0           	and dx,$f000                   ; mask off low 12 bits
1888                    
1888 b805de             	mov ax,$de05                   ; VCPI free a page
188b 662eff1ee602       	fcall long cs:[vcpi_calleip]
1891                    
1891 6643               	inc ebx                         ; increment negative change counter
1893 0f85e2ff           	jnz int310503vf0              ; if more pages to free, loop
1897                    
1897 67804ffd04         	or byte [edi-3],4           ; set next page up as last of block
189c                    
189c e91dfe             	jmp int310501vaddxnhandle       ; go to done
189f                    
189f                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
189f                    int31050av:                             ; VCPI get memory block size and base
189f 660facf110         	shrd ecx,esi,16                 ; figure address of block from handle
18a4 8bcf               	mov cx,di
18a6 662e2b0ea802       	sub ecx,cs:pagetablebase
18ac 66c1e10a           	shl ecx,10
18b0 660fa4cb10         	shld ebx,ecx,16
18b5                    
18b5 e8b1fc             	call int310500vsiditoesi        ; convert handle SI:DI to ptr ESI
18b8                    
18b8 6633ff             	xor edi,edi                     ; EDI = running page count
18bb                    
18bb                    int31050avl0:
18bb 6647               	inc edi                         ; increment page count
18bd                    
18bd 6667ad             	lods long ds:[esi]         ; EAX = page table entry
18c0 f6c404             	test ah,4                       ; is this the last page of the block?
18c3 0f84f4ff           	jz int31050avl0               ; if no, loop
18c7                    
18c7 66c1e70c           	shl edi,12                      ; convert EDI pages to bytes
18cb 660fa4fe10         	shld esi,edi,16                 ; SI:DI = EDI, size in bytes
18d0                    
18d0 e951f7             	jmp int31oksinoax               ; return ok, with SI, DI, BX, CX
18d3                    
18d3                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
18d3                    ; XMS EXTENDED MEMORY FUNCTIONS
18d3                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
18d3                    
18d3                    ;-----------------------------------------------------------------------------
18d3                    int310500xsetbuf:
18d3 678e442424         	mov es,[esp+$24]                ; get ES:EDI buffer ptr from stack
18d8 66678b3c24         	mov edi,[esp]
18dd                    
18dd 6667ab             	stos long es:[edi]         ; store block size in output buffer
18e0 66b90b000000       	mov ecx,$b                     ; fill rest of buffer with 0ffffffffh
18e6 66b8ffffffff       	mov eax,$ffffffff
18ec f36667ab           	rep stos long es:[edi]
18f0                    
18f0 e94ef7             	jmp int31ok                     ; return ok
18f3                    
18f3                    ;-----------------------------------------------------------------------------
18f3                    int310500xcallxms:                      ; make a all to real mode XMS driver
18f3 5d                 	pop bp                          ; pop return address
18f4 6683ec32           	sub esp,$32                     ; stack space for register structure
18f8                    
18f8 678944241c         	mov [esp+$1c],ax                ; put AX in register structure
18fd 67895c2410         	mov [esp+$10],bx                ; put BX in register structure
1902 67894c2418         	mov [esp+$18],cx                ; put CX in register structure
1907 6789542414         	mov [esp+$14],dx                ; put DX in register structure
190c                    
190c 67c74424200000     	mov word [esp+$20],0        ; zero FLAGS in register structure
1913 6667c744242e0000   	mov long [esp+$2e],0       ; zero SS:SP in register structure
191b 0000
191d 662ea1cc02         	mov eax,long cs:xms_callip ; put XMS driver address in CS:IP in
1922 66678944242a       	mov [esp+$2a],eax               ;  regis]er structure
1928                    
1928 16                 	push ss                         ; ES:EDI -> register structure
1929 07                 	pop es
192a 668bfc             	mov edi,esp
192d                    
192d 33c9               	xor cx,cx                       ; copy 0 words as stack parameters
192f 32ff               	xor bh,bh                       ; doesnt really need to be here
1931 b80103             	mov ax,$301                     ; call real mode FAR procedure
1934 cd31               	int $31
1936                    
1936 678b44241c         	mov ax,[esp+$1c]                ; get AX from register structure
193b 678b5c2410         	mov bx,[esp+$10]                ; get BX from register structure
1940 678b4c2418         	mov cx,[esp+$18]                ; get CX from register structure
1945 678b542414         	mov dx,[esp+$14]                ; get DX from register structure
194a                    
194a 66678d642432       	lea esp,[esp+$32]               ; adjust ESP without changing FLAGS
1950 0f8295f6           	jc int31fail8010                ; if INT 31h failed, error 8010h
1954                    
1954 ffe5               	jmp bp                          ; return ok
1956                    
1956                    ;-----------------------------------------------------------------------------
1956                    int310500xbxcxtodx:                     ; convert BX:CX bytes to DX K
1956 5d                 	pop bp                          ; pop return address
1957                    
1957 8bd1               	mov dx,cx                       ; check for invalid value, BX=CX=0
1959 0bd3               	or dx,bx
195b 0f8454f6           	jz int31fail8021                ; if invalid value, error 8021h
195f                    
195f 81c10e04           	add cx,1023+15                  ; adjust for size in K and align
1963 83d300             	adc bx,0
1966                    
1966 f6c7fc             	test bh,$fc                    ; memory request too high
1969 0f8561f6           	jnz int31fail8013               ; if yes, error 8013h
196d                    
196d 0facd90a           	shrd cx,bx,10                   ; CX = memory in K
1971 8bd1               	mov dx,cx
1973                    
1973 ffe5               	jmp bp                          ; return ok
1975                    
1975                    ;-----------------------------------------------------------------------------
1975                    int310500xerror:                        ; XMS error, return with DPMI error
1975 80fba0             	cmp bl,$a0                     ; out of memory?
1978 0f8452f6           	je int31fail8013                ; if yes, error 8013h
197c                    
197c 80fba1             	cmp bl,$a1                     ; handles exhausted?
197f 0f8439f6           	je int31fail8016                ; if yes, error 8016h
1983                    
1983 80fba2             	cmp bl,$a2                     ; invalid handle?
1986 0f8417f6           	je int31fail8023                ; if yes, error 8023h
198a                    
198a e95cf6             	jmp int31fail8010               ; else, error 8010h
198d                    
198d                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
198d                    int310500x:                             ; XMS get free memory information
198d b408               	mov ah,8                        ; get largest free memory block in K
198f e861ff             	call int310500xcallxms
1992                    
1992 660fb7c0           	movzx eax,ax                    ; EAX = free memory in bytes
1996 66c1e00a           	shl eax,10
199a                    
199a 6683e80f           	sub eax,15                      ; adjust by extra alignment size
199e 0f8331ff           	jnc int310500xsetbuf            ; if no overflow, put info to buffer
19a2                    
19a2 6633c0             	xor eax,eax                     ; overflow, so no memory available
19a5 e92bff             	jmp int310500xsetbuf            ; put memory information in buffer
19a8                    
19a8                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
19a8                    int310501x:                             ; XMS allocate memory block
19a8 e8abff             	call int310500xbxcxtodx         ; convert BX:CX bytes to DX K
19ab 8bca               	mov cx,dx                       ; preserve size of block in K
19ad                    
19ad b409               	mov ah,9                        ; allocate DX K of XMS memory
19af e841ff             	call int310500xcallxms
19b2 0bc0               	or ax,ax                        ; error?
19b4 0f84bdff           	jz int310500xerror              ; if yes, convert XMS error to DPMI
19b8                    
19b8 8bf2               	mov si,dx                       ; get DPMI handle from XMS handle
19ba                    
19ba                    int310501xgotmem:
19ba b40c               	mov ah,$c                      ; lock memory block
19bc e834ff             	call int310500xcallxms
19bf 0bc0               	or ax,ax                        ; error?
19c1 750a               	jnz short int310501xf0        ; if no, go on
19c3                    
19c3 53                 	push bx                         ; yup, preserve error number
19c4                    
19c4 b40a               	mov ah,$a                      ; free block causing lock error
19c6 e82aff             	call int310500xcallxms
19c9                    
19c9 5b                 	pop bx                          ; restore error number
19ca e9a8ff             	jmp int310500xerror             ; XMS error, return with DPMI error
19cd                    
19cd                    int310501xf0:
19cd 8bf9               	mov di,cx                       ; low word of DPMI handle is size in K
19cf                    
19cf 8bcb               	mov cx,bx                       ; XMS linear address to DPMI regs
19d1 8bda               	mov bx,dx
19d3                    
19d3 83c10f             	add cx,$f                      ; align linear address on paragraph
19d6 83d300             	adc bx,0
19d9 80e1f0             	and cl,$f0
19dc                    
19dc e945f6             	jmp int31oksinoax               ; return ok, with SI, DI, BX, CX
19df                    
19df                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
19df                    int310502x:                             ; XMS free memory block
19df 8bd6               	mov dx,si                       ; get XMS handle from DPMI handle
19e1                    
19e1 b40d               	mov ah,$d                      ; unlock memory block
19e3 e80dff             	call int310500xcallxms
19e6 0bc0               	or ax,ax                        ; error?
19e8 0f8489ff           	jz int310500xerror              ; if XMS error, return with DPMI error
19ec                    
19ec b40a               	mov ah,$a                      ; free memory block
19ee e802ff             	call int310500xcallxms
19f1 0bc0               	or ax,ax                        ; error?
19f3 0f847eff           	jz int310500xerror              ; if yes, convert XMS error to DPMI
19f7                    
19f7 e947f6             	jmp int31ok                     ; return ok
19fa                    
19fa                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
19fa                    int310503x:                             ; XMS resize memory block
19fa e859ff             	call int310500xbxcxtodx         ; convert BX:CX bytes to DX K
19fd 8bca               	mov cx,dx                       ; preserve size of block in K
19ff 8bd6               	mov dx,si                       ; get XMS handle from DPMI handle
1a01                    
1a01 b40d               	mov ah,$d                      ; unlock memory block
1a03 e8edfe             	call int310500xcallxms
1a06 0bc0               	or ax,ax                        ; error?
1a08 0f8469ff           	jz int310500xerror              ; if XMS error, return with DPMI error
1a0c                    
1a0c 8bd9               	mov bx,cx                       ; BX = new size in K
1a0e b40f               	mov ah,$f                      ; resize memory block
1a10 e8e0fe             	call int310500xcallxms
1a13 8bd6               	mov dx,si                       ; get XMS handle again
1a15 0bc0               	or ax,ax                        ; error in resize?
1a17 0f859fff           	jnz int310501xgotmem            ; if no, go to memory block code
1a1b                    
1a1b 53                 	push bx                         ; yup, preserve error number
1a1c                    
1a1c b40c               	mov ah,$c                      ; lock memory block
1a1e e8d2fe             	call int310500xcallxms
1a21                    
1a21 5b                 	pop bx                          ; restore error number
1a22 e950ff             	jmp int310500xerror             ; XMS error, return with DPMI error
1a25                    
1a25                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1a25                    int31050ax:                             ; XMS get memory block size and base
1a25 8bd6               	mov dx,si                       ; get XMS handle from DPMI handle
1a27 8bf7               	mov si,di                       ; SI = size of block in K
1a29                    
1a29 b40d               	mov ah,$d                      ; unlock memory block
1a2b e8c5fe             	call int310500xcallxms
1a2e 0bc0               	or ax,ax                        ; error?
1a30 0f8441ff           	jz int310500xerror              ; if XMS error, return with DPMI error
1a34                    
1a34 b40c               	mov ah,$c                      ; lock memory block
1a36 e8bafe             	call int310500xcallxms
1a39 0bc0               	or ax,ax                        ; error?
1a3b 0f8436ff           	jz int310500xerror              ; if XMS error, return with DPMI error
1a3f                    
1a3f 33ff               	xor di,di                       ; convert size in K to size in bytes
1a41 0facf706           	shrd di,si,6
1a45 c1ee06             	shr si,6
1a48                    
1a48 8bcb               	mov cx,bx                       ; XMS linear address to DPMI regs
1a4a 8bda               	mov bx,dx
1a4c                    
1a4c 8bc1               	mov ax,cx                       ; figure out alignment stub
1a4e 48                 	dec ax
1a4f 250f00             	and ax,$f
1a52 340f               	xor al,$f
1a54                    
1a54 2bf8               	sub di,ax                       ; subtract alignment stub from size
1a56 83de00             	sbb si,0
1a59                    
1a59 83c10f             	add cx,$f                      ; align linear address on paragraph
1a5c 83d300             	adc bx,0
1a5f 80e1f0             	and cl,$f0
1a62                    
1a62 e9bff5             	jmp int31oksinoax               ; return ok, with SI, DI, BX, CX
1a65                    
1a65                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1a65                    ; RAW EXTENDED MEMORY FUNCTIONS
1a65                    ;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
1a65                    
1a65                    ;-----------------------------------------------------------------------------
1a65                    int310500rnomem:                        ; no free extended memory present
1a65 6633c0             	xor eax,eax                     ; 0 available extended memory
1a68 e968fe             	jmp int310500xsetbuf            ; put memory information in buffer
1a6b                    
1a6b                    ;-----------------------------------------------------------------------------
1a6b                    int310500rbxcxtoebx:                    ; convert BX:CX bytes to EBX bytes
1a6b 5d                 	pop bp                          ; pop return address
1a6c                    
1a6c 66c1e310           	shl ebx,16                      ; EBX = BX:CX
1a70 8bd9               	mov bx,cx
1a72                    
1a72 660bdb             	or ebx,ebx                      ; check for invalid value
1a75 0f843af5           	jz int31fail8021                ; if invalid value, error 8021h
1a79                    
1a79 6683c30f           	add ebx,$f                     ; align EBX on paragraph
1a7d 80e3f0             	and bl,$f0
1a80                    
1a80 ffe5               	jmp bp                          ; return ok
1a82                    
1a82                    ;-----------------------------------------------------------------------------
1a82                    int310500rfindmcb:                      ; find MCB for handle SI:DI
1a82 5d                 	pop bp                          ; pop return address
1a83                    
1a83 66c1e610           	shl esi,16                      ; ESI = handle SI:DI = address of MCB
1a87 8bf7               	mov si,di
1a89                    
1a89 662e8b3e8402       	mov edi,cs:rawextmemtop         ; EDI -> first memory control block
1a8f                    
1a8f                    int310500rfindmcbl0:
1a8f 663bfe             	cmp edi,esi                     ; found MCB?
1a92 750b               	jne short int310500rfindmcbl0f0       ; if no, keep looking
1a94                    
1a94 67807ffc00         	cmp byte [edi-4],0          ; memory block free?
1a99 0f8404f5           	je int31fail8023                ; if yes, error 8023h
1a9d                    
1a9d ffe5               	jmp bp                          ; return ok, found MCB
1a9f                    
1a9f                    int310500rfindmcbl0f0:
1a9f 66678b7ff4         	mov edi,[edi-12]                ; EDI -> next memory control block
1aa4 660bff             	or edi,edi                      ; is there another MCB?
1aa7 0f85e4ff           	jnz int310500rfindmcbl0       ; if yes, loop
1aab                    
1aab e9f3f4             	jmp int31fail8023               ; fail, error 8023h
1aae                    
1aae                    ;-----------------------------------------------------------------------------
1aae                    int310500radjustused:                   ; adjust INT 15h extended memory used
1aae 662ea18402         	mov eax,cs:rawextmemtop         ; EAX -> first memory control block
1ab3                    
1ab3                    int310500radjustusedl0:
1ab3 66678378f400       	cmp long [eax-12],0        ; last memory control block?
1ab9 7408               	jz short int310500radjustusedf0       ; if yes, go to set new used K
1abb                    
1abb 66678b40f4         	mov eax,[eax-12]                ; EAX -> next memory control block
1ac0 e9f0ff             	jmp int310500radjustusedl0    ; loop
1ac3                    
1ac3                    int310500radjustusedf0:
1ac3 678078fc00         	cmp byte [eax-4],0          ; memory block free?
1ac8 7405               	je short int310500radjustusedf1       ; if no, go on
1aca                    
1aca 66672b40f0         	sub eax,[eax-16]                ; used, adjust by size of block
1acf                    
1acf                    int310500radjustusedf1:
1acf 6683e810           	sub eax,$10                     ; adjust by size of MCB
1ad3 6681e000fcffff     	and eax,$fffffc00              ; align on K
1ada 662e2b068402       	sub eax,cs:rawextmemtop         ; size of extended memory used
1ae0 66f7d8             	neg eax
1ae3 66c1e80a           	shr eax,10                      ; convert from bytes to K
1ae7                    
1ae7 662e8b2e5002       	mov ebp,cs:codebase            ; EBP = offset of code32s from 0
1aed 3e6789857e020000   	mov ds:[ebp+rawextmemused],ax    ; adjust INT 15h extended memory used
1af5                    
1af5                    int310500radjustuseddone:
1af5 c3                 	ret                             ; return
1af6                    
1af6                    ;-----------------------------------------------------------------------------
1af6                    int310500rlinkmcb:                      ; link memory blocks at ESI and EDI
1af6 66678b46f0         	mov eax,[esi-16]                ; combine two block sizes
1afb 6683c010           	add eax,$10
1aff 66670147f0         	add [edi-16],eax                ; add size of next block to this one
1b04 66678b4ef4         	mov ecx,[esi-12]                ; copy next MCB field
1b09 6667894ff4         	mov [edi-12],ecx
1b0e e305               	jecxz short int310500rlinkmcbf0       ; if no next MCB, done
1b10                    
1b10 66678979f8         	mov [ecx-8],edi                 ; set prev MCB in next MCB to this MCB
1b15                    
1b15                    int310500rlinkmcbf0:
1b15 c3                 	ret                             ; return
1b16                    
1b16                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1b16                    int310500r:                             ; raw get free memory information
1b16 662e8b3e8402       	mov edi,cs:rawextmemtop         ; EDI -> first memory control block
1b1c                    
1b1c 6633c0             	xor eax,eax                     ; running highest free memory block
1b1f                    int310500rl0:
1b1f 67807ffc00         	cmp byte [edi-4],0          ; is block free?
1b24 750d               	jne short int310500rl0f0      ; if no, loop
1b26                    
1b26 66678b5ff0         	mov ebx,[edi-16]                ; EBX = size of block
1b2b 663bc3             	cmp eax,ebx                     ; last free block larger?
1b2e 7703               	ja short int310500rl0f0       ; if yes, loop
1b30                    
1b30 668bc3             	mov eax,ebx                     ; found larger block, new largest
1b33                    
1b33                    int310500rl0f0:
1b33 66678b7ff4         	mov edi,[edi-12]                ; EDI -> next memory control block
1b38 660bff             	or edi,edi                      ; is there another MCB?
1b3b 0f85e0ff           	jnz int310500rl0              ; if yes, loop
1b3f                    
1b3f e991fd             	jmp int310500xsetbuf            ; put memory information in buffer
1b42                    
1b42                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1b42                    int310501r:                             ; raw allocate memory block
1b42 e826ff             	call int310500rbxcxtoebx        ; convert BX:CX bytes to EBX bytes
1b45                    
1b45 662e8b3e8402       	mov edi,cs:rawextmemtop         ; EDI -> first memory control block
1b4b                    
1b4b                    int310501rl0:
1b4b 67807ffc00         	cmp byte [edi-4],0       ; is block free?
1b50 740f               	je short int310501rl0f2       ; if yes, check block
1b52                    
1b52                    int310501rl0f0:
1b52 66678b7ff4         	mov edi,[edi-12]                ; EDI -> next memory control block
1b57 660bff             	or edi,edi                      ; is there another MCB?
1b5a 0f85edff           	jnz int310501rl0              ; if yes, loop
1b5e                    
1b5e e96df4             	jmp int31fail8013               ; fail, error 8013h
1b61                    
1b61                    int310501rl0f2:
1b61 66678d4ff0         	lea ecx,[edi-$10]               ; ECX -> possible new MCB
1b66 662bcb             	sub ecx,ebx
1b69                    
1b69 66678b47f0         	mov eax,[edi-16]                ; EAX = size of block
1b6e 662bc3             	sub eax,ebx                     ; enough free memory in block?
1b71 72df               	jc short int310501rl0f0       ; if no, loop
1b73                    
1b73 742f               	jz short int310501rl0f1       ; if exactly same size, continue
1b75                    
1b75 6683e810           	sub eax,$10                     ; adjust for size of new created MCB
1b79 66678941f0         	mov [ecx-16],eax                ; put size of new block in new MCB
1b7e 668bc1             	mov eax,ecx                     ; set next MCB in old MCB as new one
1b81 66678747f4         	xchg [edi-12],eax               ; copy next MCB from old to new MCB
1b86 66678941f4         	mov [ecx-12],eax
1b8b 660bc0             	or eax,eax                      ; is there a next MCB?
1b8e 7405               	jz short int310501rl0f3       ; if no, go on
1b90                    
1b90 66678948f8         	mov [eax-8],ecx                 ; set prev MCB in next MCB to new MCB
1b95                    
1b95                    int310501rl0f3:
1b95 66678979f8         	mov [ecx-8],edi                 ; set prev MCB in new MCB as old one
1b9a 67c641fc00         	mov byte [ecx-4],0          ; set new MCB as free
1b9f 6667895ff0         	mov [edi-16],ebx                ; set size of allocated block
1ba4                    
1ba4                    int310501rl0f1:
1ba4 67c647fc01         	mov byte [edi-4],1          ; set block as allocated
1ba9                    
1ba9                    int310501raddxnhandle:
1ba9 660fa4cb10         	shld ebx,ecx,16                 ; BX:CX = ECX, address of block
1bae 660fa4fe10         	shld esi,edi,16                 ; SI:DI = EDI, handle (address of MCB)
1bb3                    
1bb3 e8f8fe             	call int310500radjustused       ; adjust INT 15h extended memory used
1bb6                    
1bb6 e96bf4             	jmp int31oksinoax               ; return ok, with SI, DI, BX, CX
1bb9                    
1bb9                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1bb9                    int310502r:                             ; raw free memory block
1bb9 e8c6fe             	call int310500rfindmcb          ; find MCB for handle SI:DI
1bbc                    
1bbc 67c647fc00         	mov byte [edi-4],0          ; set this memory block as free
1bc1                    
1bc1 66678b77f4         	mov esi,[edi-12]                ; ESI -> next memory control block
1bc6 660bf6             	or esi,esi                      ; is there next MCB?
1bc9 740a               	jz short int310502rf0         ; if no, go on
1bcb                    
1bcb 67807efc00         	cmp byte [esi-4],0          ; is next memory block free?
1bd0 7503               	jne short int310502rf0        ; if no, go on
1bd2                    
1bd2 e821ff             	call int310500rlinkmcb          ; link two memory blocks
1bd5                    
1bd5                    int310502rf0:
1bd5 66678b77f8         	mov esi,[edi-8]                 ; ESI -> previous memory control block
1bda 660bf6             	or esi,esi                      ; is there previous MCB?
1bdd 740d               	jz short int310502rf1         ; if no, go on
1bdf                    
1bdf 67807efc00         	cmp byte [esi-4],0          ; is previous memory block free?
1be4 7506               	jne short int310502rf1        ; if no, go on
1be6                    
1be6 6687f7             	xchg esi,edi                    ; change mcb order for function
1be9 e80aff             	call int310500rlinkmcb          ; link two memory blocks
1bec                    
1bec                    int310502rf1:
1bec e8bffe             	call int310500radjustused       ; adjust INT 15h extended memory used
1bef                    
1bef e94ff4             	jmp int31ok                     ; return ok
1bf2                    
1bf2                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1bf2                    int310503r:                             ; raw resize memory block
1bf2 e876fe             	call int310500rbxcxtoebx        ; convert BX:CX bytes to EBX bytes
1bf5 668bd3             	mov edx,ebx                     ; EDX = size of new block
1bf8                    
1bf8 e887fe             	call int310500rfindmcb          ; find MCB for handle SI:DI
1bfb                    
1bfb 1e                 	push ds                         ; ES = DS for possible block copy
1bfc 07                 	pop es
1bfd                    
1bfd 66672b5ef0         	sub ebx,[esi-16]                ; EBX = change in block size
1c02 0f84bd01           	jz int310503rf0               ; if no change, done
1c06                    
1c06 0f826501           	jc int310503rf1               ; if block made smaller, just free top
1c0a                    
1c0a 6633c0             	xor eax,eax                     ; running memory counter
1c0d                    
1c0d 66678b4ef4         	mov ecx,[esi-12]                ; ECX -> next MCB
1c12 e310               	jecxz short int310503rf4      ; if no next MCB, check previous MCB
1c14                    
1c14 678079fc00         	cmp byte [ecx-4],0          ; next MCB free?
1c19 7509               	jne short int310503rf4        ; if not, check previous MCB
1c1b                    
1c1b 66678b41f0         	mov eax,[ecx-16]                ; EAX = amount of free memory in block
1c20 6683c010           	add eax,$10                     ;  including memory control block
1c24                    
1c24                    int310503rf4:
1c24 66678b4ef8         	mov ecx,[esi-8]                 ; ECX -> previous MCB
1c29 e310               	jecxz short int310503rf5      ; if no previous MCB, check memory
1c2b                    
1c2b 678079fc00         	cmp byte [ecx-4],0          ; previous MCB free?
1c30 7509               	jne short int310503rf5        ; if not, check memory
1c32                    
1c32 66670341f0         	add eax,[ecx-16]                ; add amount of free memory in block
1c37 6683c010           	add eax,$10                     ;  including memory control block
1c3b                    
1c3b                    int310503rf5:
1c3b 663bc3             	cmp eax,ebx                     ; enough to resize within area
1c3e 0f82df00           	jb int310503rf3               ; if no, try to allocate
1c42                    
1c42 660bc9             	or ecx,ecx                      ; is there a previous MCB?
1c45 0f848200           	jz int310503rf6               ; if no, resize to next
1c49                    
1c49 678079fc00         	cmp byte [ecx-4],0          ; previous MCB free?
1c4e 757b               	jne short int310503rf6        ; if not, resize to next
1c50                    
1c50 66678b69f0         	mov ebp,[ecx-16]                ; EBP = size of previous block, try to
1c55 6683c510           	add ebp,$10                     ;  resize within previous block
1c59                    
1c59 662beb             	sub ebp,ebx                     ; EBP = prev block size - needed size
1c5c 763d               	jbe short int310503rf7        ; if prev block too small, go on
1c5e                    
1c5e 668bf9             	mov edi,ecx                     ; EDI -> new MCB for new memory block
1c61 662bfd             	sub edi,ebp                     ;  resize will fit entirely
1c64                    
1c64 66678d45f0         	lea eax,[ebp-$10]               ; EAX = new size of free block
1c69 66678941f0         	mov [ecx-16],eax                ; store mew free size in prev MCB
1c6e 66678957f0         	mov [edi-16],edx                ; store new size in new MCB
1c73 66678979f4         	mov [ecx-12],edi                ; set next MCB in prev MCB to new MCB
1c78 6667894ff8         	mov [edi-8],ecx                 ; set prev MCB in new MCB to prev MCB
1c7d 67c647fc01         	mov byte [edi-4],1          ; set new MCB as used
1c82                    
1c82 66678b4ef4         	mov ecx,[esi-12]                ; copy next MCB field
1c87 6667894ff4         	mov [edi-12],ecx
1c8c 660bc9             	or ecx,ecx                      ; is there a next MCB
1c8f 0f843001           	jz int310503rf0               ; if no, go to block readjust
1c93                    
1c93 66678979f8         	mov [ecx-8],edi                 ; set prev MCB in next MCB to new MCB
1c98                    
1c98 e92801             	jmp int310503rf0              ; go to block readjust
1c9b                    
1c9b                    int310503rf7:
1c9b 668bf9             	mov edi,ecx                     ; EDI -> new MCB for new memory block
1c9e                    
1c9e 66678d042a         	lea eax,[edx+ebp]               ; EAX = size of new block
1ca3 66678947f0         	mov [edi-16],eax                ; store mew free size in new MCB
1ca8 67c647fc01         	mov byte [edi-4],1          ; set new MCB as used
1cad                    
1cad 66678b4ef4         	mov ecx,[esi-12]                ; copy next MCB field
1cb2 6667894ff4         	mov [edi-12],ecx
1cb7 e305               	jecxz short int310503rf8      ; if no next MCB, go on
1cb9                    
1cb9 66678979f8         	mov [ecx-8],edi                 ; set prev MCB in next MCB to new MCB
1cbe                    
1cbe                    int310503rf8:
1cbe 6603eb             	add ebp,ebx                     ; EBP = size of block just acquired
1cc1 662bdd             	sub ebx,ebp                     ; EBX = new size still needed
1cc4 0f84fb00           	jz int310503rf0               ; if no more space needed, done
1cc8                    
1cc8 668bf7             	mov esi,edi                     ; ESI -> new MCB
1ccb                    
1ccb                    int310503rf6:
1ccb 66678b7ef4         	mov edi,[esi-12]                ; EDI -> next MCB
1cd0                    
1cd0 66678b4ff4         	mov ecx,[edi-12]                ; copy next MCB field
1cd5 6667894ef4         	mov [esi-12],ecx
1cda e305               	jecxz short int310503rf9      ; if no next MCB, go on
1cdc                    
1cdc 66678971f8         	mov [ecx-8],esi                 ; set prev MCB in next MCB to this MCB
1ce1                    
1ce1                    int310503rf9:
1ce1 66678b47f0         	mov eax,[edi-16]                ; EAX = size of next memory block
1ce6 6683c010           	add eax,$10
1cea                    
1cea 662bf8             	sub edi,eax                     ; EDI -> start of next memory block
1ced 662bc3             	sub eax,ebx                     ; EAX = amount of free space left
1cf0                    
1cf0 66678b4ef0         	mov ecx,[esi-16]                ; ECX = old size of this memory block
1cf5 66678956f0         	mov [esi-16],edx                ; store new size in this MCB
1cfa 67c646fc01         	mov byte [esi-4],1          ; set this MCB as used
1cff                    
1cff 662bf1             	sub esi,ecx                     ; ESI -> start of this memory block
1d02 6683ee10           	sub esi,$10
1d06                    
1d06 66c1e902           	shr ecx,2                       ; copy this memory block down in mem
1d0a f36667a5           	rep movs long es:[edi],long ds:[esi]
1d0e                    
1d0e 6683c610           	add esi,$10                     ; adjust ESI to top MCB
1d12 668bfe             	mov edi,esi                     ; EDI -> top MCB
1d15                    
1d15 668bd8             	mov ebx,eax                     ; EBX = negative of space free at top
1d18 66f7db             	neg ebx
1d1b 0f84a400           	jz int310503rf0               ; in no space free, go to done
1d1f                    
1d1f eb4e               	jmp short int310503rf1        ; set new MCBs for moved block
1d21                    
1d21                    int310503rf3:
1d21 668bef             	mov ebp,edi                     ; preserve old block MCB address
1d24 662bd3             	sub edx,ebx                     ; EDX = size of old block
1d27                    
1d27 678b5c2410         	mov bx,[esp+16]                 ; BX:CX = new block size from stack
1d2c 678b4c2418         	mov cx,[esp+24]
1d31 b80105             	mov ax,$501                     ; try to allocate new block
1d34 cd31               	int $31
1d36 0f82c6f2           	jc int31failax                  ; if could not, fail with error AX
1d3a                    
1d3a 660facf010         	shrd eax,esi,16                 ; EAX -> new block MCB
1d3f 8bc7               	mov ax,di
1d41                    
1d41 660facdf10         	shrd edi,ebx,16                 ; EDI -> start of new block
1d46 8bf9               	mov di,cx
1d48                    
1d48 66678d75f0         	lea esi,[ebp-$10]               ; ESI -> start of old block
1d4d 662bf2             	sub esi,edx
1d50                    
1d50 668bca             	mov ecx,edx                     ; copy memory from old block to new
1d53 66c1e902           	shr ecx,2
1d57 f36667a5           	rep movs long es:[edi],long ds:[esi]
1d5b                    
1d5b 668bd0             	mov edx,eax                     ; EDX -> new block MCB
1d5e                    
1d5e 660fa4ee10         	shld esi,ebp,16                 ; SI:DI = handle of old block
1d63 8bfd               	mov di,bp
1d65 b80205             	mov ax,$502                    ; free old block
1d68 cd31               	int $31
1d6a                    
1d6a 668bfa             	mov edi,edx                     ; EDI -> new block MCB for done
1d6d                    
1d6d eb54               	jmp short int310503rf0        ; go to done
1d6f                    
1d6f                    int310503rf1:
1d6f 66678d3c1e         	lea edi,[esi+ebx]               ; EDI -> new MCB for new memory block
1d74                    
1d74 66678d4310         	lea eax,[ebx+$10]               ; EAX = size of freed block
1d79 66f7d8             	neg eax
1d7c 66678946f0         	mov [esi-16],eax                ; store freed size in old MCB
1d81 66678957f0         	mov [edi-16],edx                ; store new size in new MCB
1d86                    
1d86 66678b4ef4         	mov ecx,[esi-12]                ; copy next MCB field
1d8b 6667894ff4         	mov [edi-12],ecx
1d90 e305               	jecxz short int310503rf2      ; if no next MCB, go on
1d92                    
1d92 66678979f8         	mov [ecx-8],edi                 ; set prev MCB in next MCB to new MCB
1d97                    
1d97                    int310503rf2:
1d97 6667897ef4         	mov [esi-12],edi                ; set next MCB in old MCB as new MCB
1d9c 66678977f8         	mov [edi-8],esi                 ; set prev MCB in new MCB as old MCB
1da1 67c647fc01         	mov byte [edi-4],1          ; set new MCB as used
1da6 67c646fc00         	mov byte [esi-4],0          ; set old MCB as free
1dab                    
1dab 66678b4ef8         	mov ecx,[esi-8]                 ; ECX -> prev MCB of old MCB
1db0 e311               	jecxz short int310503rf0      ; if no prev MCB, done
1db2                    
1db2 678079fc00         	cmp byte [ecx-4],0          ; is previous MCB free?
1db7 750a               	jne short int310503rf0        ; if no, dont link
1db9                    
1db9 6657               	push edi                        ; preserve new MCB
1dbb 668bf9             	mov edi,ecx                     ; top MCB = prev MCB for link function
1dbe e835fd             	call int310500rlinkmcb          ; link two memory blocks
1dc1 665f               	pop edi                         ; restore new MCB
1dc3                    
1dc3                    int310503rf0:
1dc3 66678b4ff0         	mov ecx,[edi-16]                ; ECX = base address of new block
1dc8 66f7d9             	neg ecx
1dcb 66678d4c39f0       	lea ecx,[ecx+edi-$10]
1dd1                    
1dd1 e9d5fd             	jmp int310501raddxnhandle       ; return address and handle
1dd4                    
1dd4                    ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
1dd4                    int31050ar:                             ; raw get memory block size and base
1dd4 e8abfc             	call int310500rfindmcb          ; find MCB for handle SI:DI
1dd7                    
1dd7 66678b7ef0         	mov edi,[esi-16]                ; EDI = size of memory block
1ddc 66678d4ef0         	lea ecx,[esi-$10]               ; get base address of memory block
1de1 662bcf             	sub ecx,edi
1de4                    
1de4 660fa4cb10         	shld ebx,ecx,16                 ; BX:CX = ECX, address of block
1de9 660fa4fe10         	shld esi,edi,16                 ; SI:DI = EDI, size of memory block
1dee                    
1dee e933f2             	jmp int31oksinoax               ; return ok, with SI, DI, BX, CX
1df1                    
1df1                    
1df1                    
1df1                    
1df1                    
1df1                    ;	public  _pm_selectors, _pm_pagetables, _pm_rmstacklen, _pm_rmstacks
1df1                    ;	public  _pm_callbacks, _pm_pmstacklen, _pm_pmstacks, _pm_mode
1df1                    ;	public  pmstackbase, pmstacktop, rmstackbase, rmstacktop
1df1                    ;
1df1                    ;	public  _pm_info, _pm_init,_code32s
1df1                    
1df1                    
1df1                    
1df1                    ;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
1df1                    	use32
1df1                    
1df1 1e                 start32:	push	ds
1df2 07                 	pop	es
1df3                    
1df3 e89b000000         	call	setup
1df8                    
1df8 e846010000         	call	lowinit
1dfd a10c000000         	mov	eax,_lowheapbase
1e02 81e800010000       	sub	eax,256
1e08 e853010000         	call	argcv
1e0d                    
1e0d 52                 	push	edx
1e0e 6651               	push	cx
1e10                    
1e10 ff1504000000       	call long [mainloc]			; call C code
1e16                    
1e16 6650               	push	ax
1e18                    
1e18                    _exit:
1e18 e81a000000         	call	cleanup
1e1d 8a442404           	mov	al,[esp+4]
1e21 b44c               	mov ah,$4c			; exit to DOS
1e23 cd21               	int $21
1e25                    
1e25                    
1e25 00                 ccpressed:	db	0
1e26 00                 ctrlc:	db	0
1e27 00                 div0flag:	db	0
1e28 00                 div0:	db	0
1e29 00000000           oldctrlcvect:	dw	0,0
1e2d 00000000           oldctrlbvect:	dw	0,0
1e31 000000000000       olddiv0vect:	dw	0,0,0
1e37                    
1e37 f605261e0000ff     cleanup:	test	byte ctrlc,255
1e3e 0f842c000000       	jz	noctrlc
1e44 668b15291e0000     	mov	dx,oldctrlcvect
1e4b 668b0d2b1e0000     	mov	cx,oldctrlcvect+2
1e52 66b80102           	mov	ax,$201
1e56 b323               	mov	bl,$23
1e58 cd31               	int	$31
1e5a                    
1e5a 668b152d1e0000     	mov	dx,oldctrlbvect
1e61 668b0d2f1e0000     	mov	cx,oldctrlbvect+2
1e68 66b80102           	mov	ax,$201
1e6c b31b               	mov	bl,$1b
1e6e cd31               	int	$31
1e70                    
1e70 f605281e0000ff     noctrlc:	test	byte div0,255
1e77 0f8415000000       	jz	nodiv0
1e7d 668b0d311e0000     	mov	cx,olddiv0vect
1e84 8b15331e0000       	mov	edx,olddiv0vect+2
1e8a 66b80502           	mov	ax,$205
1e8e 32db               	xor	bl,bl
1e90 cd31               	int	$31
1e92 c3                 nodiv0:	ret
1e93 66b80002           setup:	mov	ax,$200
1e97 b323               	mov	bl,$23
1e99 cd31               	int	$31
1e9b 668915291e0000     	mov	oldctrlcvect,dx
1ea2 66890d2b1e0000     	mov	oldctrlcvect+2,cx
1ea9                    
1ea9 8b0d08000000       	mov	ecx,_code32a
1eaf c1e904             	shr	ecx,4
1eb2 66ba331f           	mov	dx,offset ctrlcroutine
1eb6 66b80102           	mov	ax,$201
1eba b323               	mov	bl,$23
1ebc cd31               	int	$31
1ebe                    
1ebe 66b80002           	mov	ax,$200
1ec2 b31b               	mov	bl,$1b
1ec4 cd31               	int	$31
1ec6 6689152d1e0000     	mov	oldctrlbvect,dx
1ecd 66890d2f1e0000     	mov	oldctrlbvect+2,cx
1ed4                    
1ed4 8b0d08000000       	mov	ecx,_code32a
1eda c1e904             	shr	ecx,4
1edd 66ba331f           	mov	dx,offset ctrlcroutine
1ee1 66b80102           	mov	ax,$201
1ee5 b31b               	mov	bl,$1b
1ee7 cd31               	int	$31
1ee9 c605261e000001     	mov	byte ctrlc,1
1ef0                    
1ef0 66b80402           	mov	ax,$204
1ef4 32db               	xor	bl,bl
1ef6 cd31               	int	$31
1ef8 66890d311e0000     	mov	olddiv0vect,cx
1eff 8915331e0000       	mov	olddiv0vect+2,edx
1f05                    
1f05 8cc9               	mov	cx,cs
1f07 ba1c1f0000         	mov	edx,offset div0routine
1f0c 32db               	xor	bl,bl
1f0e 66b80502           	mov	ax,$205
1f12 cd31               	int	$31
1f14 c605281e000001     	mov	byte div0,1
1f1b                    
1f1b c3                 	ret
1f1c                    
1f1c                    
1f1c                    div0routine:
1f1c b003               	mov	al,3
1f1e 32e4               	xor	ah,ah
1f20 cd10               	int	$10
1f22 b406               	mov	ah,6
1f24 b22f               	mov	dl,'/'
1f26 cd21               	int	$21
1f28 b406               	mov	ah,6
1f2a b230               	mov	dl,'0'
1f2c cd21               	int	$21
1f2e e9e5feffff         	jmp	_exit
1f33                    
1f33                    	use16
1f33                    
1f33                    ctrlcroutine:
1f33 f8                 	clc
1f34 2ec606251e01       	mov	byte cs:ccpressed,1
1f3a cf                 	iret
1f3b                    	use32
1f3b                    
1f3b 0fb605251e0000     _cchit:	movzx	eax,byte ccpressed
1f42 c3                 	ret
1f43                    
1f43 8b350c000000       lowinit:	mov	esi,_lowheapbase
1f49 8b1510000000       	mov	edx,_lowheaplen
1f4f 33c0               	xor	eax,eax
1f51 8906               	mov	[esi],eax ;next
1f53 894604             	mov	[esi+4],eax ;prev
1f56 83ea10             	sub	edx,16
1f59 895608             	mov	[esi+8],edx
1f5c 89460c             	mov	[esi+12],eax ;flags
1f5f c3                 	ret
1f60                    
1f60                    ;input eax=256 byte buffer to use
1f60                    ;returns ecx=argc,edx=argv[];
1f60 8bf8               argcv:	mov	edi,eax
1f62 0fb73533010000     	movzx	esi,word psp
1f69 c1e604             	shl	esi,4
1f6c 81c680000000       	add	esi,128
1f72 2b3508000000       	sub	esi,_code32a
1f78 ac                 	lodsb
1f79 0fb6c8             	movzx	ecx,al
1f7c 41                 	inc	ecx
1f7d 8bd7               	mov	edx,edi
1f7f 81c780000000       	add	edi,128
1f85 8bdf               	mov	ebx,edi
1f87 882f               	mov	[edi],ch
1f89 47                 	inc	edi
1f8a f3a4               	rep movsb
1f8c 4f                 	dec	edi
1f8d 880f               	mov	[edi],cl
1f8f 8bfa               	mov	edi,edx
1f91 8bf3               	mov	esi,ebx
1f93 46                 	inc	esi
1f94 891f               	mov	[edi],ebx
1f96 83c704             	add	edi,4
1f99 41                 	inc	ecx
1f9a ac                 argcvlp:	lodsb
1f9b 0ac0               	or	al,al
1f9d 7422               	jz	short argcvdone
1f9f 3c20               	cmp	al,' '
1fa1 74f7               	jz	short argcvlp
1fa3 3c09               	cmp	al,9
1fa5 74f3               	jz	short argcvlp
1fa7 4e                 	dec	esi
1fa8 8937               	mov	[edi],esi
1faa 83c704             	add	edi,4
1fad 41                 	inc	ecx
1fae ac                 argcvlp2:	lodsb
1faf 0ac0               	or	al,al
1fb1 740e               	jz	short argcvdone
1fb3 3c20               	cmp	al,' '
1fb5 7404               	jz	short argend
1fb7 3c09               	cmp	al,9
1fb9 75f3               	jnz	short argcvlp2
1fbb c646ff00           argend:	mov	byte [esi-1],0
1fbf ebd9               	jmp	short argcvlp
1fc1 c3                 argcvdone:	ret
1fc2                    
1fc2                    	public	_main
1fc2                    	public	_cchit
1fc2                    	public	_exit
1fc2                    
1fc2 0000000000000000   	align	16
1fca 000000000000
1fd0                    endstart:
