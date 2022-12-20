0000                    sloc1:	equ	132*10+61
0000                    sloc2:	equ	sloc1+132
0000                    sloc3:	equ	sloc2+132
0000                    sloc4:	equ	sloc3+132
0000                    
0000                    
0000                    _code32a:	equ	8
0000                    _lowheapbase:	equ	12
0000                    _lowheaplen:	equ	16
0000                    
0000                    
0000                    
0000                    v86r_edi
0000 00000000           v86r_di	dw	0,0
0004                    v86r_esi
0004 00000000           v86r_si	dw	0,0
0008                    v86r_ebp
0008 00000000           v86r_bp	dw	0,0
000c 00000000           	dd	0
0010                    v86r_ebx
0010                    v86r_bx
0010 00                 v86r_bl	db	0
0011 000000             v86r_bh	db	0,0,0
0014                    v86r_edx
0014                    v86r_dx
0014 00                 v86r_dl	db	0
0015 000000             v86r_dh	db	0,0,0
0018                    v86r_ecx
0018                    v86r_cx
0018 00                 v86r_cl	db	0
0019 000000             v86r_ch	db	0,0,0
001c                    v86r_eax
001c                    v86r_ax
001c 00                 v86r_al	db	0
001d 000000             v86r_ah	db	0,0,0
0020 0000               v86r_fl	dw	0
0022 0000               v86r_es	dw	0
0024 0000               v86r_ds	dw	0
0026 0000               v86r_fs	dw	0
0028 0000               v86r_gs	dw	0
002a 0000               	dw	0
002c 0000               	dw	0
002e 0000               v86r_sp	dw	0
0030 0000               v86r_ss	dw	0
0032                    
0032                    TEMPSIZE:	equ	64
0032 0000000000000000   temp:	ds.b	TEMPSIZE
003a 0000000000000000
0042 0000000000000000
004a 0000000000000000
0052 0000000000000000
005a 0000000000000000
0062 0000000000000000
006a 0000000000000000
0072                    
0072 66b80003           dosint:	mov	ax,$300
0076 6633c9             	xor	cx,cx
0079 32ff               	xor	bh,bh
007b bf00000000         	mov	edi,offset v86r_edi
0080 cd31               	int	$31
0082 8a2520000000       	mov	ah,byte v86r_fl
0088 9e                 	sahf
0089 c3                 	ret
008a                    
008a 8a442404           _exit:	mov	al,[esp+4]
008e b44c               	mov ah,$4c			; exit to DOS
0090 cd21               	int $21
0092                    
0092                    
0092                    ;	call	setup
0092                    ;	call	cleanup
0092 00                 ccpressed	db	0
0093 00                 ctrlc	db	0
0094 00000000           oldctrlcvect	dw	0,0
0098 f60593000000ff     cleanup:	test	byte ctrlc,255
009f 0f8431000000       	jz	noctrlc
00a5 66a196000000       	mov	ax,oldctrlcvect+2
00ab 66a324000000       	mov	word v86r_ds,ax
00b1 668b1594000000     	mov	dx,oldctrlcvect
00b8 66891514000000     	mov	word v86r_dx,dx
00bf 66c7051c00000023   	mov	word v86r_ax,$2523
00c7 25
00c8 b321               	mov	bl,$21
00ca e8a3ffffff         	call	dosint
00cf c6059300000000     	mov	byte ctrlc,0
00d6 c3                 noctrlc:	ret
00d7 66c7051c00000023   setup:	mov	word v86r_ax,$3523
00df 35
00e0 b321               	mov	bl,$21
00e2 e88bffffff         	call	dosint
00e7 66a122000000       	mov	ax,v86r_es
00ed 66a396000000       	mov	oldctrlcvect+2,ax
00f3 66a110000000       	mov	ax,v86r_bx
00f9 66a394000000       	mov	oldctrlcvect,ax
00ff                    
00ff a108000000         	mov	eax,long [_code32a]
0104 c1e804             	shr	eax,4
0107 66a324000000       	mov	word v86r_ds,ax
010d 66c705140000002e   	mov	word v86r_dx,offset ctrlcroutine
0115 01
0116 66c7051c00000023   	mov	word v86r_ax,$2523
011e 25
011f b321               	mov	bl,$21
0121 e84cffffff         	call	dosint
0126 c6059300000001     	mov	byte ctrlc,1
012d c3                 	ret
012e                    
012e                    
012e                    	use16
012e                    ctrlcroutine:
012e f8                 	clc
012f 2ec606920001       	mov	byte cs:ccpressed,1
0135 cf                 	iret
0136                    	use32
0136                    
0136 0fb60592000000     _cchit:	movzx	eax,byte ccpressed
013d c3                 	ret
013e                    
013e                    
013e                    
013e 8a442404           _putchar:	mov	al,[esp+4]
0142 3c0a               pc:	cmp	al,10
0144 7509               	jnz	short pc2
0146 b00d               	mov	al,13
0148 e802000000         	call	pc2
014d b00a               	mov	al,10
014f b406               pc2:	mov	ah,6
0151 8ad0               	mov	dl,al
0153 cd21               	int	$21
0155 c3                 	ret
0156 8b742404           _puts:	mov	esi,[esp+4]
015a 8a06               pstrlp:	mov	al,[esi]
015c 0ac0               	or	al,al
015e 7408               	jz	short pstrdone
0160 46                 	inc	esi
0161 e8dcffffff         	call	pc
0166 ebf2               	jmp	short pstrlp
0168 c3                 pstrdone:	ret
0169                    
0169 00000000           pfpoint	dd	0
016d 00000000           pfrout	dd	0
0171 00000000           spfpoint	dd	0
0175                    
0175 55                 _sprintf:	push	ebp
0176 8bec               	mov	ebp,esp
0178 83ec20             	sub	esp,32
017b fc                 	cld
017c 8d7d08             	lea	edi,[ebp+8]
017f 8b37               	mov	esi,[edi]
0181 893571010000       	mov	spfpoint,esi
0187 83c704             	add	edi,4
018a 8b37               	mov	esi,[edi]
018c 83c704             	add	edi,4
018f 893d69010000       	mov	pfpoint,edi
0195 c7056d010000a401   	mov	long pfrout,offset spfrout
019d 0000
019f e906010000         	jmp	pfenter
01a4 8b3d71010000       spfrout:	mov	edi,spfpoint
01aa aa                 	stosb
01ab 893d71010000       	mov	spfpoint,edi
01b1 c60700             	mov	byte [edi],0
01b4 c3                 	ret
01b5                    
01b5 0000               fpffile	dw	0
01b7 00                 fpfin	db	0
01b8 55                 _fprintf:	push	ebp
01b9 8bec               	mov	ebp,esp
01bb 83ec20             	sub	esp,32
01be fc                 	cld
01bf 8d7d08             	lea	edi,[ebp+8]
01c2 668b07             	mov	ax,[edi]
01c5 66a3b5010000       	mov	word fpffile,ax
01cb 83c702             	add	edi,2
01ce 8b37               	mov	esi,[edi]
01d0 83c704             	add	edi,4
01d3 893d69010000       	mov	pfpoint,edi
01d9 c7056d010000f901   	mov	long pfrout,offset fpfrout
01e1 0000
01e3 c705710100003200   	mov	long spfpoint,offset temp
01eb 0000
01ed c605b701000000     	mov	byte fpfin,0
01f4 e9b1000000         	jmp	pfenter
01f9 3c0a               fpfrout:	cmp	al,10
01fb 7509               	jnz	short fpfnotnl
01fd b00d               	mov	al,13
01ff e802000000         	call	fpfnotnl
0204 b00a               	mov	al,10
0206 8b3d71010000       fpfnotnl:	mov	edi,spfpoint
020c aa                 	stosb
020d 893d71010000       	mov	spfpoint,edi
0213 fe05b7010000       	inc	byte fpfin
0219 803db701000040     	cmp	byte fpfin,TEMPSIZE
0220 7546               	jnz	short noflush
0222 0fb605b7010000     fpflush:	movzx	eax,byte fpfin
0229 0ac0               	or	al,al
022b 743b               	jz	short noflush
022d c605b701000000     	mov	byte fpfin,0
0234 66a318000000       	mov	word v86r_cx,ax
023a 60                 	pushad
023b 668b1db5010000     	mov	bx,fpffile
0242 66891d10000000     	mov	word v86r_bx,bx
0249 ba32000000         	mov	edx,offset temp
024e 891571010000       	mov	spfpoint,edx
0254 e8de050000         	call	setdsdx
0259 c6051d00000040     	mov	byte v86r_ah,$40
0260 b321               	mov	bl,$21
0262 e80bfeffff         	call	dosint
0267 61                 	popad
0268 c3                 noflush:	ret
0269                    
0269 55                 _printf:	push	ebp
026a 8bec               	mov	ebp,esp
026c 83ec20             	sub	esp,32
026f fc                 	cld
0270 8d7d08             	lea	edi,[ebp+8]
0273 8b37               	mov	esi,[edi]
0275 83c704             	add	edi,4
0278 893d69010000       	mov	long pfpoint,edi
027e c7056d010000f901   	mov	long pfrout,offset fpfrout
0286 0000
0288 c705710100003200   	mov	long spfpoint,offset temp
0290 0000
0292 c605b701000000     	mov	byte fpfin,0
0299 66c705b501000001   	mov	word fpffile,1
02a1 00
02a2 eb06               	jmp	short pfenter
02a4 ff156d010000       pflp:	call	long [pfrout]
02aa ac                 pfenter:	lodsb
02ab 0ac0               	or	al,al
02ad 0f843e020000       	jz	printfdone
02b3 3c25               	cmp	al,'%'
02b5 7417               	jz	short pfcontrol
02b7 3c5c               	cmp	al,'\\'
02b9 75e9               	jnz	short pflp
02bb ac                 	lodsb
02bc 3c6e               	cmp	al,'n'
02be 740a               	jz	short pfcr
02c0 3c74               	cmp	al,'t'
02c2 7402               	jz	short pftab
02c4 ebde               	jmp	short pflp
02c6 b009               pftab:	mov	al,9
02c8 ebda               	jmp	short pflp
02ca b00a               pfcr:	mov	al,10
02cc ebd6               	jmp	short pflp
02ce 32d2               pfcontrol:	xor	dl,dl
02d0 33db               	xor	ebx,ebx
02d2 ac                 pfgather:	lodsb
02d3 3c30               	cmp	al,'0'
02d5 0f8473000000       	jz	printf0
02db 7224               	jc	short pfnn
02dd 3c3a               	cmp	al,'9'+1
02df 7320               	jnc	short pfnn
02e1 2c30               pfback:	sub	al,'0'
02e3 f6c202             	test	dl,2
02e6 740b               	jz	short pfbl
02e8 02ff               	add	bh,bh
02ea 02c7               	add	al,bh
02ec c0e702             	shl	bh,2
02ef 02f8               	add	bh,al
02f1 ebdf               	jmp	short pfgather
02f3 02db               pfbl:	add	bl,bl
02f5 02c3               	add	al,bl
02f7 c0e302             	shl	bl,2
02fa 02d8               	add	bl,al
02fc e9d1ffffff         	jmp	pfgather
0301 3c2d               pfnn:	cmp	al,'-'
0303 0f846e000000       	jz	printfminus
0309 3c2e               	cmp	al,'.'
030b 0f845e000000       	jz	printfdot
0311 3c6c               	cmp	al,'l'
0313 0f844e000000       	jz	printfl
0319 3c4c               	cmp	al,'L'
031b 0f8446000000       	jz	printfl
0321 3c73               	cmp	al,'s'
0323 0f84dd000000       	jz	printfs
0329 3c64               	cmp	al,'d'
032b 0f8482000000       	jz	printfd
0331 3c75               	cmp	al,'u'
0333 0f8477000000       	jz	printfu
0339 3c78               	cmp	al,'x'
033b 0f843e000000       	jz	printfx
0341 3c63               	cmp	al,'c'
0343 0f848d010000       	jz	printfc
0349 e956ffffff         	jmp	pflp
034e f6c202             printf0:	test	dl,2
0351 0f858affffff       	jnz	pfback
0357 0adb               	or	bl,bl
0359 0f8582ffffff       	jnz	pfback
035f 80ca04             	or	dl,4	;4='0'
0362 e96bffffff         	jmp	pfgather
0367 80ca08             printfl:	or	dl,8	;8='l'
036a e963ffffff         	jmp	pfgather
036f 80ca02             printfdot:	or	dl,2	;2='.'
0372 e95bffffff         	jmp	pfgather
0377 80ca01             printfminus:	or	dl,1	;1='-'
037a e953ffffff         	jmp	pfgather
037f 80ca10             printfx:	or	dl,16	;16=unsigned
0382 e80d010000         	call	getnum
0387 56                 	push	esi
0388 8d75fc             	lea	esi,[ebp-4]
038b 4e                 	dec	esi
038c c60600             	mov	byte [esi],0
038f 52                 	push	edx
0390 8bd0               ho:	mov	edx,eax
0392 83e20f             	and	edx,15
0395 8a9256050000       	mov	dl,[edx+digits]
039b 4e                 	dec	esi
039c 8816               	mov	[esi],dl
039e c1e804             	shr	eax,4
03a1 0f85e9ffffff       	jnz	ho
03a7 5a                 	pop	edx
03a8 8bc6               pfxdone:	mov	eax,esi
03aa 5e                 	pop	esi
03ab e965000000         	jmp	printeax
03b0 80ca10             printfu:	or	dl,16	;16='u'
03b3 e8dc000000         printfd:	call	getnum
03b8 56                 	push	esi
03b9 32f6               	xor	dh,dh
03bb 0bc0               	or	eax,eax
03bd 0f8d0d000000       	jge	pfpos
03c3 f6c210             	test	dl,16
03c6 0f8504000000       	jnz	pfpos
03cc f7d8               	neg	eax
03ce fec6               	inc	dh
03d0 52                 pfpos:	push	edx
03d1 8d75fc             	lea	esi,[ebp-4]
03d4 33d2               	xor	edx,edx
03d6 4e                 	dec	esi
03d7 c60600             	mov	byte [esi],0
03da b90a000000         	mov	ecx,10
03df f7f1               pfdlp:	div	ecx
03e1 80c230             	add	dl,'0'
03e4 4e                 	dec	esi
03e5 8816               	mov	[esi],dl
03e7 33d2               	xor	edx,edx
03e9 0bc0               	or	eax,eax
03eb 0f85eeffffff       	jnz	pfdlp
03f1 5a                 	pop	edx
03f2 0af6               	or	dh,dh
03f4 0f8404000000       	jz	pfpos2
03fa 4e                 	dec	esi
03fb c6062d             	mov	byte [esi],'-'
03fe 8bc6               pfpos2:	mov	eax,esi
0400 5e                 	pop	esi
0401 e90f000000         	jmp	printeax
0406 8b3d69010000       printfs:	mov	edi,long pfpoint
040c 8b07               	mov	eax,[edi]
040e 83056901000004     	add	long pfpoint,4
0415 56                 printeax:	push	esi
0416 8bf0               	mov	esi,eax
0418 e8f1000000         	call	strlen
041d 0aff               	or	bh,bh
041f 0f840a000000       	jz	pfnolimit
0425 3ac7               	cmp	al,bh
0427 0f8202000000       	jc	pfnolimit
042d 8ac7               	mov	al,bh
042f 8af0               pfnolimit:	mov	dh,al	;dh=# of string chars to print
0431 0adb               	or	bl,bl
0433 0f842c000000       	jz	pfnopadl
0439 f6c201             	test	dl,1
043c 0f8523000000       	jnz	pfnopadl
0442 0fb6cb             	movzx	ecx,bl
0445 2ace               	sub	cl,dh
0447 0f8218000000       	jc	pfnopadl
044d f6c204             	test	dl,4
0450 0f840a000000       	jz	lsp
0456 e8ea000000         	call	zeroes
045b e905000000         	jmp	pfnopadl
0460 e8cf000000         lsp:	call	spaces
0465 0fb6ce             pfnopadl:	movzx	ecx,dh
0468 e8b7000000         	call	outstr
046d 0adb               	or	bl,bl
046f 0f8419000000       	jz	pfnopadr
0475 f6c201             	test	dl,1
0478 0f8410000000       	jz	pfnopadr
047e 0fb6cb             	movzx	ecx,bl
0481 2ace               	sub	cl,dh
0483 0f8205000000       	jc	pfnopadr
0489 e8a6000000         	call	spaces
048e 5e                 pfnopadr:	pop	esi
048f e916feffff         	jmp	pfenter
0494 f6c208             getnum:	test	dl,8
0497 0f8414000000       	jz	pfw
049d 8b3d69010000       	mov	edi,pfpoint
04a3 8b07               	mov	eax,[edi]
04a5 83056901000004     	add	long pfpoint,4
04ac e924000000         	jmp	pfl
04b1 8b3d69010000       pfw:	mov	edi,pfpoint
04b7 668b07             	mov	ax,[edi]
04ba 83056901000002     	add	long pfpoint,2
04c1 f6c210             	test	dl,16
04c4 0f8408000000       	jz	gns
04ca 0fb7c0             	movzx	eax,ax
04cd e903000000         	jmp	pfl
04d2 0fbfc0             gns:	movsx	eax,ax
04d5 c3                 pfl:	ret
04d6 8b3d69010000       printfc:	mov	edi,pfpoint
04dc 668b07             	mov	ax,[edi]
04df 83056901000002     	add	long pfpoint,2
04e6 ff156d010000       	call	long [pfrout]
04ec e9b9fdffff         	jmp	pfenter
04f1                    
04f1 813d6d010000f901   printfdone:	cmp	long pfrout,offset fpfrout
04f9 0000
04fb 0f8505000000       	jnz	notryfpflush
0501 e81cfdffff         	call	fpflush
0506 8be5               notryfpflush:	mov	esp,ebp
0508 5d                 	pop	ebp
0509 c3                 	ret
050a                    
050a 8b742404           _strlen:	mov	esi,[esp+4]
050e b9ffffffff         strlen:	mov	ecx,-1
0513 fc                 	cld
0514 41                 strlenlp:	inc	ecx
0515 ac                 	lodsb
0516 0ac0               	or	al,al
0518 0f85f6ffffff       	jnz	strlenlp
051e 8bc1               	mov	eax,ecx
0520 2bf1               	sub	esi,ecx
0522 4e                 	dec	esi
0523 c3                 	ret
0524                    
0524 41                 outstr:	inc	ecx
0525 e907000000         	jmp	outstr2
052a ac                 outlp:	lodsb
052b ff156d010000       	call	long [pfrout]
0531 e2f7               outstr2:	loop	outlp
0533 c3                 	ret
0534                    
0534 41                 spaces:	inc	ecx
0535 e908000000         	jmp	spaces2
053a b020               spacelp:	mov	al,' '
053c ff156d010000       	call	long [pfrout]
0542 e2f6               spaces2:	loop	spacelp
0544 c3                 	ret
0545                    
0545 41                 zeroes:	inc	ecx
0546 e908000000         	jmp	zeroes2
054b b030               zeroeslp:	mov	al,'0'
054d ff156d010000       	call	long [pfrout]
0553 e2f6               zeroes2:	loop	zeroeslp
0555 c3                 	ret
0556 3031323334353637   digits	db	'0123456789abcdef'
055e 3839616263646566
0566                    
0566                    ;ax=val
0566                    ;ecx=# of entries
0566 8b3424             doswitch:	mov	esi,[esp]
0569 83c404             	add	esp,4
056c 0bc9               	or	ecx,ecx
056e 0f8413000000       	jz	dsdone
0574 bb06000000         	mov	ebx,6
0579 663b4604           dsloop:	cmp	ax,[esi+4]
057d 0f8404000000       	jz	dsdone
0583 03f3               	add	esi,ebx
0585 e2f2               	loop	dsloop
0587 ff26               dsdone:	jmp	long [esi]
0589                    
0589 8b7c2404           _strcpy:	mov	edi,[esp+4]
058d 8b742408           	mov	esi,[esp+8]
0591 fc                 	cld
0592 ac                 strcpylp:	lodsb
0593 aa                 	stosb
0594 0ac0               	or	al,al
0596 0f85f6ffffff       	jnz	strcpylp
059c c3                 	ret
059d                    
059d 8b7c2404           _strncpy:	mov	edi,[esp+4]
05a1 8b742408           	mov	esi,[esp+8]
05a5 0fb74c240c         	movzx	ecx,word [esp+12]
05aa 0bc9               	or	ecx,ecx
05ac 0f8404000000       	jz	sncpydone
05b2 fc                 	cld
05b3 a4                 strncpylp:	movsb
05b4 e2fd               	loop	strncpylp
05b6                    sncpydone:
05b6 c3                 	ret
05b7                    
05b7                    
05b7 8b742404           _strcmp:	mov	esi,[esp+4]
05bb 8b7c2408           	mov	edi,[esp+8]
05bf fc                 	cld
05c0 ac                 strcmplp:	lodsb
05c1 8a1f               	mov	bl,[edi]
05c3 47                 	inc	edi
05c4 2ac3               	sub	al,bl
05c6 0f8508000000       	jnz	strcmpdiff
05cc 0adb               	or	bl,bl
05ce 0f85ecffffff       	jnz	strcmplp
05d4 0fbec0             strcmpdiff:	movsx	eax,al
05d7 c3                 	ret
05d8                    
05d8 8b742404           _strncmp:	mov	esi,[esp+4]
05dc 8b7c2408           	mov	edi,[esp+8]
05e0 0fb744240c         	movzx	eax,word [esp+12]
05e5 0bc0               	or	eax,eax
05e7 0f8412000000       	jz	sncmpdone
05ed fc                 	cld
05ee ac                 strncmplp:	lodsb
05ef 8a1f               	mov	bl,[edi]
05f1 47                 	inc	edi
05f2 2ac3               	sub	al,bl
05f4 0f8502000000       	jnz	strncmpdiff
05fa e2f2               	loop	strncmplp
05fc 0fbec0             strncmpdiff:	movsx	eax,al
05ff c3                 sncmpdone:	ret
0600                    
0600 0fb6442404         _tolower:	movzx	eax,byte [esp+4]
0605 3c41               	cmp	al,'A'
0607 0f820a000000       	jc	tlsame
060d 3c5b               	cmp	al,'Z'+1
060f 0f8302000000       	jnc	tlsame
0615 0420               	add	al,$20
0617 c3                 tlsame:	ret
0618                    
0618 0fb6442404         _toupper:	movzx	eax,byte [esp+4]
061d 3c61               	cmp	al,'a'
061f 0f820a000000       	jc	tusame
0625 3c7b               	cmp	al,'z'+1
0627 0f8302000000       	jnc	tusame
062d 2c20               	sub	al,$20
062f c3                 tusame:	ret
0630                    
0630 8a442404           _isalpha:	mov	al,[esp+4]
0634 3c41               	cmp	al,'A'
0636 0f8266000000       	jc	r0
063c 3c5b               	cmp	al,'Z'+1
063e 0f8261000000       	jc	r1
0644 3c61               	cmp	al,'a'
0646 0f8256000000       	jc	r0
064c 3c7b               	cmp	al,'z'+1
064e 0f8251000000       	jc	r1
0654 33c0               	xor	eax,eax
0656 c3                 	ret
0657 8a442404           _isalnum:	mov	al,[esp+4]
065b 3c30               	cmp	al,'0'
065d 0f823f000000       	jc	r0
0663 3c3a               	cmp	al,'9'+1
0665 0f823a000000       	jc	r1
066b 3c41               	cmp	al,'A'
066d 0f822f000000       	jc	r0
0673 3c5b               	cmp	al,'Z'+1
0675 0f822a000000       	jc	r1
067b 3c61               	cmp	al,'a'
067d 0f821f000000       	jc	r0
0683 3c7b               	cmp	al,'z'+1
0685 0f821a000000       	jc	r1
068b 33c0               	xor	eax,eax
068d c3                 	ret
068e 8a442404           _isdigit:	mov	al,[esp+4]
0692 3c30               	cmp	al,'0'
0694 0f8208000000       	jc	r0
069a 3c3a               	cmp	al,'9'+1
069c 0f8203000000       	jc	r1
06a2 33c0               r0:	xor	eax,eax
06a4 c3                 	ret
06a5 b801000000         r1:	mov	eax,1
06aa c3                 	ret
06ab 8b7c2404           _clearmem:	mov	edi,[esp+4]
06af 0fb74c2408         	movzx	ecx,word [esp+8]
06b4 0bc9               	or	ecx,ecx
06b6 7405               	jz	short cmdone
06b8 32c0               	xor	al,al
06ba fc                 	cld
06bb f3aa               	rep	stosb
06bd c3                 cmdone:	ret
06be                    
06be 8b4c240c           _fcopyl:	mov	ecx,[esp+12]
06c2 eb05               	jmp	short fc
06c4 0fb74c240c         _fcopy:	movzx	ecx,word [esp+12]
06c9 0bc9               fc:	or	ecx,ecx
06cb 742d               	jz	short fcdone
06cd 8b742404           	mov	esi,[esp+4]
06d1 8b7c2408           	mov	edi,[esp+8]
06d5 03f1               	add	esi,ecx
06d7 03f9               	add	edi,ecx
06d9 fd                 	std
06da 8bd9               	mov	ebx,ecx
06dc c1e902             	shr	ecx,2
06df 740e               	jz	short fcunder4
06e1 83ee04             	sub	esi,4
06e4 83ef04             	sub	edi,4
06e7 f3a5               	rep	movsd
06e9 83c604             	add	esi,4
06ec 83c704             	add	edi,4
06ef 83e303             fcunder4:	and	ebx,3
06f2 7406               	jz	short fcdone
06f4 8bcb               	mov	ecx,ebx
06f6 4e                 	dec	esi
06f7 4f                 	dec	edi
06f8 f3a4               	rep	movsb
06fa fc                 fcdone:	cld
06fb c3                 	ret
06fc                    
06fc 8b4c240c           _bcopyl:	mov	ecx,[esp+12]
0700 e905000000         	jmp	bc
0705 0fb74c240c         _bcopy:	movzx	ecx,word [esp+12]
070a 0bc9               bc:	or	ecx,ecx
070c 741b               	jz	short bcdone
070e 8b742404           	mov	esi,[esp+4]
0712 8b7c2408           	mov	edi,[esp+8]
0716 fc                 	cld
0717 8bd9               	mov	ebx,ecx
0719 c1e902             	shr	ecx,2
071c 7402               	jz	short bcunder4
071e f3a5               	rep	movsd
0720 83e303             bcunder4:	and	ebx,3
0723 7404               	jz	short bcdone
0725 8bcb               	mov	ecx,ebx
0727 f3a4               	rep	movsb
0729 c3                 bcdone:	ret
072a                    
072a 0000000000000000   namearea	ds.b	256
0732 0000000000000000
073a 0000000000000000
0742 0000000000000000
074a 0000000000000000
0752 0000000000000000
075a 0000000000000000
0762 0000000000000000
076a 0000000000000000
0772 0000000000000000
077a 0000000000000000
0782 0000000000000000
078a 0000000000000000
0792 0000000000000000
079a 0000000000000000
07a2 0000000000000000
07aa 0000000000000000
07b2 0000000000000000
07ba 0000000000000000
07c2 0000000000000000
07ca 0000000000000000
07d2 0000000000000000
07da 0000000000000000
07e2 0000000000000000
07ea 0000000000000000
07f2 0000000000000000
07fa 0000000000000000
0802 0000000000000000
080a 0000000000000000
0812 0000000000000000
081a 0000000000000000
0822 0000000000000000
082a                    
082a bf2a070000         intoname:	mov	edi,offset namearea
082f 8bd7               	mov	edx,edi
0831 ac                 inlp:	lodsb
0832 aa                 	stosb
0833 0ac0               	or	al,al
0835 75fa               	jnz	short inlp
0837 031508000000       setdsdx:	add	edx,long [_code32a]
083d 8bc2               	mov	eax,edx
083f c1e804             	shr	eax,4
0842 66a324000000       	mov	word v86r_ds,ax
0848 6683e20f           	and	dx,15
084c 66891514000000     	mov	word v86r_dx,dx
0853 c3                 	ret
0854                    
0854 8b742404           _fopen:	mov	esi,[esp+4]
0858 e8cdffffff         	call	intoname
085d 8b742408           	mov	esi,[esp+8]
0861 ac                 	lodsb
0862 33c9               	xor	ecx,ecx
0864 3c77               	cmp	al,'w'
0866 740f               	jz	short opencreate
0868 3c57               	cmp	al,'W'
086a 740b               	jz	short opencreate
086c 66c7051c00000000   	mov	word v86r_ax,$3d00
0874 3d
0875 eb10               	jmp	short openread
0877 66c7051800000000   opencreate:	mov	word v86r_cx,0
087f 00
0880 c6051d0000003c     	mov	byte v86r_ah,$3c
0887 b321               openread:	mov	bl,$21
0889 e8e4f7ffff         	call	dosint
088e 0fb7051c000000     	movzx	eax,word v86r_ax
0895 7302               	jnc	short opengood
0897 33c0               	xor	eax,eax
0899 c3                 opengood:	ret
089a                    
089a 668b5c2404         _fclose:	mov	bx,[esp+4]
089f 66891d10000000     	mov	word v86r_bx,bx
08a6 c6051d0000003e     	mov	byte v86r_ah,$3e
08ad b321               	mov	bl,$21
08af e9bef7ffff         	jmp	dosint
08b4                    
08b4                    
08b4 668b5c2404         _read:	mov	bx,[esp+4]
08b9 66891d10000000     	mov	word v86r_bx,bx
08c0 8b542406           	mov	edx,[esp+6]
08c4 e86effffff         	call	setdsdx
08c9 668b4c240a         	mov	cx,[esp+10]
08ce 66890d18000000     	mov	word v86r_cx,cx
08d5 c6051d0000003f     	mov	byte v86r_ah,$3f
08dc b321               	mov	bl,$21
08de e88ff7ffff         	call	dosint
08e3 0fb7051c000000     	movzx	eax,word v86r_ax
08ea c3                 	ret
08eb                    
08eb 8d442404           _putc:	lea	eax,[esp+4]
08ef 668b5c2406         	mov	bx,[esp+6]
08f4 66b90100           	mov	cx,1
08f8 6651               	push	cx
08fa 50                 	push	eax
08fb 6653               	push	bx
08fd e804000000         	call	_write
0902 83c408             	add	esp,8
0905 c3                 	ret
0906                    
0906 668b5c2404         _write:	mov	bx,[esp+4]
090b 66891d10000000     	mov	word v86r_bx,bx
0912 8b542406           	mov	edx,[esp+6]
0916 e81cffffff         	call	setdsdx
091b 668b4c240a         	mov	cx,[esp+10]
0920 66890d18000000     	mov	word v86r_cx,cx
0927 c6051d00000040     	mov	byte v86r_ah,$40
092e b321               	mov	bl,$21
0930 e83df7ffff         	call	dosint
0935 0fb7051c000000     	movzx	eax,word v86r_ax
093c c3                 	ret
093d                    
093d 00000000           qsrout	dd	0
0941 00000000           qsswap	dd	0
0945 0000               qslen	dw	0
0947 32000000           xitem	dd	temp
094b                    ;        4    8       10           12
094b                    ;qsort2(block,swnum,sizeof(void *),swcomp);
094b 66837c240802       _qsort:	cmp	word [esp+8],2
0951 0f8280000000       	jc	qs2done2
0957 8b44240c           	mov	eax,[esp+12]
095b a33d090000         	mov	qsrout,eax
0960 668b44240a         	mov	ax,[esp+10]
0965 660bc0             	or	ax,ax
0968 746d               	jz	short qs2done2
096a 66a345090000       	mov	qslen,ax
0970 663d0100           	cmp	ax,1
0974 7418               	jz	short qs21
0976 663d0200           	cmp	ax,2
097a 741e               	jz	short qs22
097c 663d0400           	cmp	ax,4
0980 7424               	jz	short qs24
0982 c70541090000dd0a   	mov	long qsswap,offset qsswapany
098a 0000
098c eb22               	jmp	short qs2enter
098e c70541090000be0a   qs21:	mov	long qsswap,offset qsswap1
0996 0000
0998 eb16               	jmp	short qs2enter
099a c70541090000c70a   qs22:	mov	long qsswap,offset qsswap2
09a2 0000
09a4 eb0a               	jmp	short qs2enter
09a6 c70541090000d40a   qs24:	mov	long qsswap,offset qsswap4
09ae 0000
09b0 0fb7442408         qs2enter:	movzx	eax,word [esp+8]
09b5 48                 	dec	eax
09b6 0fb754240a         	movzx	edx,word [esp+10]
09bb 0fafc2             	imul	eax,edx
09be 8b542404           	mov	edx,[esp+4]
09c2 03c2               	add	eax,edx
09c4 50                 	push	eax
09c5 52                 	push	edx
09c6 e812000000         	call	qs2do
09cb 83c408             	add	esp,8
09ce 33c0               	xor	eax,eax
09d0 c3                 qs2done:	ret
09d1 b801000000         qs2done1:	mov	eax,1
09d6 c3                 	ret
09d7 b802000000         qs2done2:	mov	eax,2
09dc c3                 	ret
09dd                    
09dd c8080000           qs2do:	enter	8,0
09e1 8b5508             	mov	edx,[ebp+8]
09e4 8b450c             	mov	eax,[ebp+12]
09e7 8955fc             	mov	[ebp-4],edx
09ea 8bf2               	mov	esi,edx
09ec 8945f8             	mov	[ebp-8],eax
09ef 2bc2               	sub	eax,edx
09f1 33d2               	xor	edx,edx
09f3 0fb70d45090000     	movzx	ecx,word qslen
09fa f7f9               	idiv	ecx
09fc d1e8               	shr	eax,1
09fe 0fafc1             	imul	eax,ecx
0a01 03f0               	add	esi,eax
0a03 8b3d47090000       	mov	edi,xitem
0a09 f3a4               	rep	movsb
0a0b ff3547090000       qs2lp:	push	long xitem
0a11 ff75fc             	push	long [ebp-4]
0a14 ff153d090000       	call	long [qsrout]
0a1a 83c408             	add	esp,8
0a1d 660bc0             	or	ax,ax
0a20 0f8d0f000000       	jge	q2e1
0a26 0fb70545090000     	movzx	eax,word qslen
0a2d 0145fc             	add	[ebp-4],eax
0a30 e9d6ffffff         	jmp	qs2lp
0a35 ff75f8             q2e1:	push	long [ebp-8]
0a38 ff3547090000       	push	long xitem
0a3e ff153d090000       	call	long [qsrout]
0a44 83c408             	add	esp,8
0a47 660bc0             	or	ax,ax
0a4a 0f8d0f000000       	jge	q2e2
0a50 0fb70545090000     	movzx	eax,word qslen
0a57 2945f8             	sub	[ebp-8],eax
0a5a e9d6ffffff         	jmp	q2e1
0a5f 8b75fc             q2e2:	mov	esi,[ebp-4]
0a62 8b7df8             	mov	edi,[ebp-8]
0a65 3bf7               	cmp	esi,edi
0a67 0f8f13000000       	jg	q2e3
0a6d ff1541090000       	call	long [qsswap]
0a73 0fb70545090000     	movzx	eax,word qslen
0a7a 0145fc             	add	[ebp-4],eax
0a7d 2945f8             	sub	[ebp-8],eax
0a80 8b45fc             q2e3:	mov	eax,[ebp-4]
0a83 3b45f8             	cmp	eax,[ebp-8]
0a86 0f8e7fffffff       	jle	qs2lp
0a8c 8b4508             	mov	eax,[ebp+8]
0a8f 8b55f8             	mov	edx,[ebp-8]
0a92 3bc2               	cmp	eax,edx
0a94 0f8d0a000000       	jge	q2n1
0a9a 52                 	push	edx
0a9b 50                 	push	eax
0a9c e83cffffff         	call	qs2do
0aa1 83c408             	add	esp,8
0aa4 8b45fc             q2n1:	mov	eax,[ebp-4]
0aa7 8b550c             	mov	edx,[ebp+12]
0aaa 3bc2               	cmp	eax,edx
0aac 0f8d0a000000       	jge	q2n2
0ab2 52                 	push	edx
0ab3 50                 	push	eax
0ab4 e824ffffff         	call	qs2do
0ab9 83c408             	add	esp,8
0abc c9                 q2n2:	leave
0abd c3                 	ret
0abe 8a06               qsswap1:	mov	al,[esi]
0ac0 8a1f               	mov	bl,[edi]
0ac2 881e               	mov	[esi],bl
0ac4 8807               	mov	[edi],al
0ac6 c3                 	ret
0ac7 668b06             qsswap2:	mov	ax,[esi]
0aca 668b1f             	mov	bx,[edi]
0acd 66891e             	mov	[esi],bx
0ad0 668907             	mov	[edi],ax
0ad3 c3                 	ret
0ad4 8b06               qsswap4:	mov	eax,[esi]
0ad6 8b1f               	mov	ebx,[edi]
0ad8 891e               	mov	[esi],ebx
0ada 8907               	mov	[edi],eax
0adc c3                 	ret
0add 668b1545090000     qsswapany:	mov	dx,qslen
0ae4 668bca             	mov	cx,dx
0ae7 66c1e902           	shr	cx,2
0aeb 0f8413000000       	jz	qsanolongs
0af1 bb04000000         	mov	ebx,4
0af6 8b06               qsal:	mov	eax,[esi]
0af8 8b1f               	mov	ebx,[edi]
0afa 891e               	mov	[esi],ebx
0afc 8907               	mov	[edi],eax
0afe 03f3               	add	esi,ebx
0b00 03fb               	add	edi,ebx
0b02 e2f2               	loop	qsal
0b04 668bca             qsanolongs:	mov	cx,dx
0b07 6683e103           	and	cx,3
0b0b 0f840c000000       	jz	qsadone
0b11 8a06               qsab:	mov	al,[esi]
0b13 8a1f               	mov	bl,[edi]
0b15 881e               	mov	[esi],bl
0b17 8807               	mov	[edi],al
0b19 46                 	inc	esi
0b1a 47                 	inc	edi
0b1b e2f4               	loop	qsab
0b1d c3                 qsadone:	ret
0b1e                    
0b1e 00000000           _errcode	dd	0
0b22                    
0b22 8b5c2404           _mallocl:	mov	ebx,[esp+4]
0b26 e905000000         	jmp	malow
0b2b 0fb75c2404         _malloc:	movzx	ebx,word [esp+4]
0b30 83c310             malow:	add	ebx,16
0b33 668bcb             	mov	cx,bx
0b36 c1eb10             	shr	ebx,16
0b39 66b80105           	mov	ax,$501
0b3d cd31               	int	$31
0b3f 66a90080           	test	ax,$8000
0b43 0f8522000000       	jnz	mafail
0b49 668bc3             	mov	ax,bx
0b4c c1e010             	shl	eax,16
0b4f 668bc1             	mov	ax,cx
0b52 2b0508000000       	sub	eax,long [_code32a]
0b58 668938             	mov	[eax],di
0b5b 66897002           	mov	[eax+2],si
0b5f c6400c01           	mov	byte [eax+12],1
0b63 83c010             	add	eax,16
0b66 e907000000         	jmp	madone
0b6b a31e0b0000         mafail:	mov	_errcode,eax
0b70 33c0               	xor	eax,eax
0b72 c3                 madone:	ret
0b73 8b442404           _free:	mov	eax,[esp+4]
0b77 0bc0               	or	eax,eax
0b79 0f841a000000       	jz	nofree
0b7f 83e810             	sub	eax,16
0b82 f6400c02           	test	byte [eax+12],2
0b86 0f8590000000       	jnz	lowfree
0b8c 668b38             	mov	di,[eax]
0b8f 668b7002           	mov	si,[eax+2]
0b93 66b80205           	mov	ax,$502
0b97 cd31               	int	$31
0b99 c3                 nofree:	ret
0b9a                    
0b9a                    
0b9a                    
0b9a 0fb7542404         _lalloc:	movzx	edx,word [esp+4]
0b9f 8b350c000000       	mov	esi,long [_lowheapbase]
0ba5 83c21f             alow:	add	edx,31
0ba8 83e2f0             	and	edx,$fffffff0
0bab f6460c01           lafind:	test	byte [esi+12],1
0baf 0f854b000000       	jnz	lanext
0bb5 395608             	cmp	[esi+8],edx
0bb8 0f8242000000       	jc	lanext
0bbe 0f850c000000       	jnz	lasplit
0bc4 c6460c03           	mov	byte [esi+12],3
0bc8 8d4610             	lea	eax,[esi+16]
0bcb e93c000000         	jmp	ladone
0bd0 8bfe               lasplit:	mov	edi,esi
0bd2 295608             	sub	[esi+8],edx
0bd5 037e08             	add	edi,[esi+8]
0bd8 895708             	mov	[edi+8],edx
0bdb 8b16               	mov	edx,[esi]
0bdd 893e               	mov	[esi],edi
0bdf 8917               	mov	[edi],edx
0be1 897704             	mov	[edi+4],esi
0be4 c7470c03000000     	mov	long [edi+12],3
0beb 8d4710             	lea	eax,[edi+16]
0bee 0bd2               	or	edx,edx
0bf0 0f8416000000       	jz	ladone
0bf6 8bf2               	mov	esi,edx
0bf8 897e04             	mov	[esi+4],edi
0bfb e90c000000         	jmp	ladone
0c00 8b36               lanext:	mov	esi,[esi]
0c02 0bf6               	or	esi,esi
0c04 0f85a1ffffff       	jnz	lafind
0c0a 33c0               	xor	eax,eax
0c0c c3                 ladone:	ret
0c0d                    
0c0d                    
0c0d 8b442404           _lfree:	mov	eax,[esp+4]
0c11 0bc0               	or	eax,eax
0c13 0f8462000000       	jz	fdone
0c19 83e810             	sub	eax,16
0c1c 8bf0               lowfree:	mov	esi,eax
0c1e 80660cfe           	and	byte [esi+12],$fe
0c22 8b7e04             	mov	edi,[esi+4]
0c25 0bff               	or	edi,edi
0c27 0f8423000000       	jz	fnoprev
0c2d f6470c01           	test	byte [edi+12],1
0c31 0f8519000000       	jnz	fnoprev
0c37 8b4608             	mov	eax,[esi+8]
0c3a 014708             	add	[edi+8],eax
0c3d 8b06               	mov	eax,[esi]
0c3f 8907               	mov	[edi],eax
0c41 8bf7               	mov	esi,edi
0c43 0bc0               	or	eax,eax
0c45 0f8405000000       	jz	fnoprev
0c4b 8bf8               	mov	edi,eax
0c4d 897704             	mov	[edi+4],esi
0c50 8b3e               fnoprev:	mov	edi,[esi]
0c52 0bff               	or	edi,edi
0c54 0f8421000000       	jz	fdone
0c5a f6470c01           	test	byte [edi+12],1
0c5e 0f8517000000       	jnz	fdone
0c64 8b4708             	mov	eax,[edi+8]
0c67 014608             	add	[esi+8],eax
0c6a 8b07               	mov	eax,[edi]
0c6c 8906               	mov	[esi],eax
0c6e 0bc0               	or	eax,eax
0c70 0f8405000000       	jz	fdone
0c76 8bf8               	mov	edi,eax
0c78 897704             	mov	[edi+4],esi
0c7b c3                 fdone:	ret
0c7c                    
0c7c                    	ifeq	1
0c7c                    _realloc:	movzx	edx,word [esp+8]
0c7c                    	mov	esi,_himembase
0c7c                    	call	alow
0c7c                    	or	eax,eax
0c7c                    	jz	rafail
0c7c                    	mov	esi,[esp+4]
0c7c                    	mov	edi,eax
0c7c                    	mov	ecx,[esi-8]
0c7c                    	mov	edx,[edi-8]
0c7c                    	cmp	ecx,edx
0c7c                    	jbe	ecxsmaller
0c7c                    	mov	ecx,edx
0c7c                    ecxsmaller:	sub	ecx,16
0c7c                    	rep	movsb
0c7c                    	mov	esi,[esp+4]
0c7c                    	push	eax
0c7c                    	call	esifree
0c7c                    	pop	eax
0c7c                    	ret
0c7c                    rafail:	mov	eax,[esp+4]
0c7c                    	ret
0c7c                    	endc
0c7c                    
0c7c dacabaaa           seed	dd	$aabacada
0c80                    
0c80 a17c0c0000         _rand:	mov	eax,seed
0c85 c1c010             	rol	eax,16
0c88 8bd0               	mov	edx,eax
0c8a c1c203             	rol	edx,3
0c8d 33d0               	xor	edx,eax
0c8f 668bc2             	mov	ax,dx
0c92 a37c0c0000         	mov	seed,eax
0c97 0fb7c0             	movzx	eax,ax
0c9a c3                 	ret
0c9b                    
0c9b c6051d0000002c     _gettime:	mov	byte v86r_ah,$2c
0ca2 b321               	mov	bl,$21
0ca4 e8c9f3ffff         	call	dosint
0ca9 0fb70514000000     	movzx	eax,word v86r_dx
0cb0 0fb70d18000000     	movzx	ecx,word v86r_cx
0cb7 c1e110             	shl	ecx,16
0cba 0bc1               	or	eax,ecx
0cbc c3                 	ret
0cbd                    
0cbd 668b5c2404         _rewind:	mov	bx,[esp+4]
0cc2 66891d10000000     	mov	word v86r_bx,bx
0cc9 6633c0             	xor	ax,ax
0ccc 66a318000000       	mov	word v86r_cx,ax
0cd2 66a314000000       	mov	word v86r_dx,ax
0cd8 66c7051c00000000   	mov	word v86r_ax,$4200
0ce0 42
0ce1 b321               	mov	bl,$21
0ce3 e88af3ffff         	call	dosint
0ce8 0fb7051c000000     	movzx	eax,word v86r_ax
0cef 0fb71514000000     	movzx	edx,word v86r_dx
0cf6 c1e210             	shl	edx,16
0cf9 0bc2               	or	eax,edx
0cfb c3                 	ret
0cfc 668b5c2404         _lseek:	mov	bx,[esp+4]
0d01 66891d10000000     	mov	word v86r_bx,bx
0d08 8b542406           	mov	edx,[esp+6]
0d0c 8bca               	mov	ecx,edx
0d0e c1e910             	shr	ecx,16
0d11 66890d18000000     	mov	word v86r_cx,cx
0d18 66891514000000     	mov	word v86r_dx,dx
0d1f 8a44240a           	mov	al,[esp+10]
0d23 b442               	mov	ah,$42
0d25 66a31c000000       	mov	word v86r_ax,ax
0d2b b321               	mov	bl,$21
0d2d e840f3ffff         	call	dosint
0d32 0f8214000000       	jc	retm1
0d38 0fb7051c000000     	movzx	eax,word v86r_ax
0d3f 0fb71514000000     	movzx	edx,word v86r_dx
0d46 c1e210             	shl	edx,16
0d49 0bc2               	or	eax,edx
0d4b c3                 	ret
0d4c b8ffffffff         retm1:	mov	eax,-1
0d51 c3                 	ret
0d52 8b542404           _unlink:	mov	edx,[esp+4]
0d56 e8dcfaffff         	call	setdsdx
0d5b c6051d00000041     	mov	byte v86r_ah,$41
0d62 b321               	mov	bl,$21
0d64 e809f3ffff         	call	dosint
0d69 0fb7051c000000     	movzx	eax,word v86r_ax
0d70 c3                 	ret
0d71 c3                 _fflush:	ret
0d72 8b742404           _atoi:	mov	esi,[esp+4]
0d76 33d2               	xor	edx,edx
0d78 33c0               	xor	eax,eax
0d7a ac                 atoilp:	lodsb
0d7b 2c30               	sub	al,'0'
0d7d 0f8218000000       	jc	atoidone
0d83 3c0a               	cmp	al,10
0d85 0f8310000000       	jnc	atoidone
0d8b 03d2               	add	edx,edx
0d8d 8bda               	mov	ebx,edx
0d8f c1e202             	shl	edx,2
0d92 03d3               	add	edx,ebx
0d94 03d0               	add	edx,eax
0d96 e9dfffffff         	jmp	atoilp
0d9b 8bc2               atoidone:	mov	eax,edx
0d9d c3                 	ret
0d9e                    
0d9e 8b742404           _index:	mov	esi,[esp+4]
0da2 8a542408           	mov	dl,[esp+8]
0da6 b909000000         	mov	ecx,9
0dab 41                 indexlp:	inc	ecx
0dac 0fb606             	movzx	eax,byte [esi]
0daf 46                 	inc	esi
0db0 0ac0               	or	al,al
0db2 0f840a000000       	jz	indexfail
0db8 3ac2               	cmp	al,dl
0dba 0f85ebffffff       	jnz	indexlp
0dc0 8bc1               	mov	eax,ecx
0dc2 c3                 indexfail:	ret
0dc3                    
0dc3 0020202020202020   __ctype	db	0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$28,$28
0dcb 20202828
0dcf 2828282020202020   	db	$28,$28,$28,$20,$20,$20,$20,$20,$20,$20,$20,$20
0dd7 20202020
0ddb 2020202020202020   	db	$20,$20,$20,$20,$20,$20,$20,$20,$20,$48,$10,$10
0de3 20481010
0de7 1010101010101010   	db	$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
0def 10101010
0df3 1084848484848484   	db	$10,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$10
0dfb 84848410
0dff 1010101010108181   	db	$10,$10,$10,$10,$10,$10,$81,$81,$81,$81,$81,$81
0e07 81818181
0e0b 0101010101010101   	db	$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1
0e13 01010101
0e17 0101010101010101   	db	$1,$1,$1,$1,$1,$1,$1,$1,$10,$10,$10,$10
0e1f 10101010
0e23 1010828282828282   	db	$10,$10,$82,$82,$82,$82,$82,$82,$2,$2,$2,$2
0e2b 02020202
0e2f 0202020202020202   	db	$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2
0e37 02020202
0e3b 0202020210101010   	db	$2,$2,$2,$2,$10,$10,$10,$10,$20,0,0,0
0e43 20000000
0e47 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0e4f 00000000
0e53 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0e5b 00000000
0e5f 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0e67 00000000
0e6b 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0e73 00000000
0e77 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0e7f 00000000
0e83 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0e8b 00000000
0e8f 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0e97 00000000
0e9b 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0ea3 00000000
0ea7 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0eaf 00000000
0eb3 0000000000000000   	db	0,0,0,0,0,0,0,0,0,0,0,0
0ebb 00000000
0ebf 0000000000         	db	0,0,0,0,0
0ec4 8b742404           _hash8:	mov	esi,[esp+4]
0ec8 32e4               	xor	ah,ah
0eca ac                 hashlp:	lodsb
0ecb d0c4               	rol	ah,1
0ecd 32e0               	xor	ah,al
0ecf 0ac0               	or	al,al
0ed1 0f85f3ffffff       	jnz	hashlp
0ed7 0fb6c4             	movzx	eax,ah
0eda c3                 	ret
0edb 8b7c2404           _strcat:	mov	edi,[esp+4]
0edf 8b742408           	mov	esi,[esp+8]
0ee3 4f                 	dec	edi
0ee4 47                 scfindend:	inc	edi
0ee5 8a07               	mov	al,[edi]
0ee7 0ac0               	or	al,al
0ee9 0f85f5ffffff       	jnz	scfindend
0eef 33c0               	xor	eax,eax
0ef1 a4                 sclp:	movsb
0ef2 3846ff             	cmp	[esi-1],al
0ef5 0f85f6ffffff       	jnz	sclp
0efb c3                 	ret
0efc c6051d00000001     _kr:	mov	byte v86r_ah,1
0f03 b316               	mov	bl,22
0f05 e868f1ffff         	call	dosint
0f0a b800000000         	mov	eax,0
0f0f 0f8401000000       	jz	nokey
0f15 48                 	dec	eax
0f16 c3                 nokey:	ret
0f17                    
0f17 66c7051c00000000   _rci:	mov	word v86r_ax,0
0f1f 00
0f20 b316               	mov	bl,22
0f22 e84bf1ffff         	call	dosint
0f27 0fb7051c000000     	movzx	eax,word v86r_ax
0f2e c3                 	ret
0f2f c6051d00000002     _rqual:	mov	byte v86r_ah,2
0f36 b316               	mov	bl,22
0f38 e835f1ffff         	call	dosint
0f3d 0fb6051c000000     	movzx	eax,byte v86r_al
0f44 c3                 	ret
0f45 c6051100000000     _getseg:	mov	byte v86r_bh,0
0f4c c6051d0000000f     	mov	byte v86r_ah,15
0f53 b310               	mov	bl,$10
0f55 e818f1ffff         	call	dosint
0f5a 0fb7051c000000     	movzx	eax,word v86r_ax
0f61 c3                 	ret
0f62                    
0f62 c6051100000000     _getcurpos:	mov	byte v86r_bh,0
0f69 c6051d00000003     	mov	byte v86r_ah,3
0f70 b310               	mov	bl,$10
0f72 e8fbf0ffff         	call	dosint
0f77 0fb70514000000     	movzx	eax,word v86r_dx
0f7e c3                 	ret
0f7f 8a542406           _curpos:	mov	dl,[esp+6]
0f83 8a742404           	mov	dh,[esp+4]
0f87 66891514000000     	mov	word v86r_dx,dx
0f8e c6051100000000     	mov	byte v86r_bh,0
0f95 c6051d00000002     	mov	byte v86r_ah,2
0f9c b310               	mov	bl,$10
0f9e e8cff0ffff         	call	dosint
0fa3 c3                 	ret
0fa4 c6051d0000002a     _getdate:	mov	byte v86r_ah,$2a
0fab b321               	mov	bl,$21
0fad e8c0f0ffff         	call	dosint
0fb2 0fb70518000000     	movzx	eax,word v86r_cx
0fb9 81e8bc070000       	sub	eax,$7bc
0fbf c1e018             	shl	eax,24
0fc2 0fb61515000000     	movzx	edx,byte v86r_dh
0fc9 c1e210             	shl	edx,16
0fcc 0bc2               	or	eax,edx
0fce 8a2514000000       	mov	ah,v86r_dl
0fd4 a01c000000         	mov	al,v86r_al
0fd9 c3                 	ret
0fda                    
0fda 8b542404           _findenv:	mov	edx,[esp+4]
0fde 0fb7352cffffff     	movzx	esi,word [$2c-$100]
0fe5 0bf6               	or	esi,esi
0fe7 743d               	jz	short noenvs
0fe9 c1e604             	shl	esi,4
0fec 2b3508000000       	sub	esi,[_code32a]
0ff2 803e00             fenvlp1:	cmp	byte [esi],0
0ff5 742f               	jz	short noenvs
0ff7 8bfa               	mov	edi,edx
0ff9 ac                 fenvlp2:	lodsb
0ffa 3c3d               	cmp	al,'='
0ffc 7425               	jz	short foundenv
0ffe 3c41               	cmp	al,'A'
1000 7206               	jc	short fe1
1002 3c5b               	cmp	al,'Z'+1
1004 7302               	jnc	short fe1
1006 0420               	add	al,$20
1008 8a27               fe1:	mov	ah,[edi]
100a 47                 	inc	edi
100b 80fc41             	cmp	ah,'A'
100e 7208               	jc	short fe2
1010 80fc5b             	cmp	ah,'Z'+1
1013 7303               	jnc	short fe2
1015 80c420             	add	ah,$20
1018 3ae0               fe2:	cmp	ah,al
101a 74dd               	jz	short fenvlp2
101c ac                 fe3:	lodsb
101d 0ac0               	or	al,al
101f 75fb               	jnz	short fe3
1021 ebcf               	jmp	short fenvlp1
1023 8bc6               foundenv:	mov	eax,esi
1025 c3                 	ret
1026 33c0               noenvs:	xor	eax,eax
1028 c3                 	ret
1029                    
1029                    
1029                    
1029                    
1029                    
1029                    
1029                    
1029                    	public	doswitch
1029                    	public	_putchar
1029                    	public	_puts
1029                    	public	_printf
1029                    	public	_strcpy
1029                    	public	_strncpy
1029                    	public	_strlen
1029                    	public	_strcmp
1029                    	public	_strncmp
1029                    	public	_tolower
1029                    	public	_toupper
1029                    	public	_isdigit
1029                    	public	_isalpha
1029                    	public	_clearmem
1029                    	public	_bcopy
1029                    	public	_fcopy
1029                    	public	_sprintf
1029                    	public	_fopen
1029                    	public	_fclose
1029                    	public	_read
1029                    	public	_write
1029                    	public	_qsort
1029                    	public	_malloc
1029                    	public	_mallocl
1029                    	public	_lfree
1029                    	public	_free
1029                    	public	_lalloc
1029                    ;	public	_realloc
1029                    	public	_rand
1029                    	public	_gettime
1029                    	public	_rewind
1029                    	public	_lseek
1029                    	public	_unlink
1029                    	public	_fflush
1029                    	public	_isalnum
1029                    	public	_atoi
1029                    	public	_index
1029                    	public	__ctype
1029                    	public	_hash8
1029                    	public	_strcat
1029                    	public	_kr
1029                    	public	_rci
1029                    	public	_rqual
1029                    	public	_getseg
1029                    	public	_fcopyl
1029                    	public	_bcopyl
1029                    	public	_curpos
1029                    	public	_getcurpos
1029                    	public	_getdate
1029                    	public	_exit
1029                    	public	_errcode
1029                    	public	_cchit
1029                    	public	_putc
1029                    	public	_fprintf
1029                    	public	_findenv
