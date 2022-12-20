#include <regs.h>

void _doint(){}

/***
Curson ON/OFF 
***/
void scr_curson(){}
void scr_cursoff(){}

/******
Returns a key if one is press
otherwise returns 0
*******/
char scr_csts()
{
char key;
if(kr())
        while(kr())
                key=rci()&255;
else key=0;
return(key);
}

/*output a single char*/
void scr_co(char c)
{
putchar(c);
}

void srand(){randomize();}

#asm
v86r_edi
v86r_di	dw	0,0
v86r_esi
v86r_si	dw	0,0
v86r_ebp
v86r_bp	dw	0,0
	dd	0
v86r_ebx
v86r_bx
v86r_bl	db	0
v86r_bh	db	0,0,0
v86r_edx
v86r_dx
v86r_dl	db	0
v86r_dh	db	0,0,0
v86r_ecx
v86r_cx
v86r_cl	db	0
v86r_ch	db	0,0,0
v86r_eax
v86r_ax
v86r_al	db	0
v86r_ah	db	0,0,0
v86r_fl	dw	0
v86r_es	dw	0
v86r_ds	dw	0
v86r_fs	dw	0
v86r_gs	dw	0
	dw	0
	dw	0
v86r_sp	dw	0
v86r_ss	dw	0

dosint:	mov	ax,$300
	xor	cx,cx
	xor	bh,bh
	mov	edi,offset v86r_edi
	int	$31
	mov	ah,byte v86r_fl
	sahf
	ret

_clearscreen: mov	dl,[esp+6]
	mov	dh,[esp+4]
	mov	word v86r_dx,dx
	mov	byte v86r_al,3
	mov	byte v86r_ah,0
	mov	bl,$10
	call	dosint
	ret

_retrace:
	mov	dx,$3da
	in	al,dx
	movzx eax,al
	and	al,8
	ret

#endasm

void scr_rowcol(short x,short y)
{
curpos(x,y);
}

void scr_setup(){}
/*clear screen*/
void scr_clr()
{
clearscreen();

}