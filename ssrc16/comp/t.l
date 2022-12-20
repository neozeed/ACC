0000                    _main:
0000 55                 	push	ebp
0001 8bec               	mov	ebp,esp
0003 83ec08             	sub	esp,8
0006 8b45f8             	mov	eax,long [ebp-8]
0009 8b4010             	mov	eax,long [eax+16]
000c c7400804000000     	mov	long [eax+8],$4
0013 8b45f8             	mov	eax,long [ebp-8]
0016 c7400804000000     	mov	long [eax+8],$4
001d 8b45f8             	mov	eax,long [ebp-8]
0020 8b4010             	mov	eax,long [eax+16]
0023 83c008             	add	eax,8
0026 8945fc             	mov	long [ebp-4],eax
0029 8b45f8             	mov	eax,long [ebp-8]
002c 83400804           	add	long [eax+8],$4
0030 8b45f8             	mov	eax,long [ebp-8]
0033 8b5df8             	mov	ebx,long [ebp-8]
0036 8b400c             	mov	eax,long [eax+12]
0039 034304             	add	eax,long [ebx+4]
003c 8b5df8             	mov	ebx,long [ebp-8]
003f 894308             	mov	long [ebx+8],eax
0042 8b45f8             	mov	eax,long [ebp-8]
0045 ff7004             	push	long [eax+4]
0048 e8b3ffffff         	call	_rout
004d 83c404             	add	esp,4
0050 8be5               	mov	esp,ebp
0052 5d                 	pop	ebp
0053 c3                 	ret
0054                    	public	_rout
0054                    	public	_main
0054                    	public	doswitch
