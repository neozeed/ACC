#define MAZEX 317
#define MAZEY 197
#define MAXDEPTH 16383
#define pixel(x,y,c) video[(x)+mul320[y]]=(c)

#define UP -320
#define DOWN 320
#define LEFT -1
#define RIGHT 1

char *lalloc();

int deltas[]=
{
UP,DOWN,LEFT,RIGHT,
UP,DOWN,RIGHT,LEFT,
UP,LEFT,RIGHT,DOWN,
UP,LEFT,DOWN,RIGHT,
UP,RIGHT,LEFT,DOWN,
UP,RIGHT,DOWN,LEFT,
DOWN,UP,LEFT,RIGHT,
DOWN,UP,RIGHT,LEFT,
DOWN,LEFT,UP,RIGHT,
DOWN,LEFT,RIGHT,UP,
DOWN,RIGHT,UP,LEFT,
DOWN,RIGHT,LEFT,UP,
LEFT,RIGHT,UP,DOWN,
LEFT,RIGHT,DOWN,UP,
LEFT,UP,DOWN,RIGHT,
LEFT,UP,RIGHT,DOWN,
LEFT,DOWN,UP,RIGHT,
LEFT,DOWN,RIGHT,UP,
RIGHT,LEFT,UP,DOWN,
RIGHT,LEFT,DOWN,UP,
RIGHT,UP,LEFT,DOWN,
RIGHT,UP,DOWN,LEFT,
RIGHT,DOWN,LEFT,UP,
RIGHT,DOWN,UP,LEFT
};


#asm
_setmode:
	movzx eax,byte [esp+4]
	int $10
	ret
_inretrace:
	mov	dx,$3da
	in	al,dx
	movzx eax,al
	and	al,8
	ret

_loadmap:
	mov	dx,$3c8
	mov	al,1
	out	dx,al
	inc	dx
	mov	al,15
	out	dx,al
	out	dx,al
	out	dx,al
	dec	dx
	mov	eax,$80
	out	dx,al
	inc	dx
	mov	ecx,eax
	mov	bl,[esp+4]
lmlp:
	xor	al,al
	test	bl,24
	jnz	short lmb
	mov	al,63
	mov	bh,bl
	and	bh,7
	cmp	bh,7
	jz	short lmb
	mov	al,16
	add	al,bh
	add	al,bh
	add	al,bh
lmb:
	out	dx,al
	xor	al,al
	out	dx,al
	out	dx,al
	inc	bl
	loop	lmlp
	ret
#endasm


nomem()
{
	printf("Not enough low memory!\n");
	exit(1);
}

main()
{
unsigned int i,j,k;
int *ip,delta;
char *video;
int oldmode;
unsigned int pixleft;
unsigned int pos,endpos;
unsigned int *mazeblock,*mazesp,*bestpath,bestlen;
unsigned int *mul320;

	mul320=lalloc(200*sizeof(int));
	if(!mul320) nomem();
	mazeblock=lalloc(MAXDEPTH*sizeof(int));
	if(!mazeblock) nomem();
	bestpath=lalloc(MAXDEPTH*sizeof(int));
	if(!bestpath) nomem();
	mazesp=0;

	oldmode=getseg()&255;
	setmode(0x13);
	video=0xa0000L-*(long *)8;

	for(i=0;i<200;i++) mul320[i]=i*320;

	loadmap(0);
	while()
	{
		for(j=1;j<MAZEY+1;j++)
			for(i=1;i<MAZEX+1;i++)
				pixel(i,j,1);
		pos=mul320[2]+2;
		endpos=mul320[MAZEY-1]+MAZEX-1;
		video[pos]=0;
		mazesp=mazeblock;
		pixleft=(MAZEX>>1)*(MAZEY>>1)-1;
		bestlen=0;
		while(pixleft)
		{
			while((i=rand()&0x7c)>=96);
			ip=deltas+i;
			i=4;
			while(i)
			{
				delta=*ip++;
				if(video[pos+delta+delta])
				{
					*mazesp++=pos;
					pos+=delta;
					video[pos]=0;
					pos+=delta;
					video[pos]=0;
					--pixleft;
					if(pos==endpos)
					{
						bestlen=mazesp-mazeblock;
						bcopy(mazeblock,bestpath,bestlen+bestlen);
						bestpath[bestlen]=pos;
						++bestlen;
					}
					break;
				}
				--i;
			}
			if(!i) pos=*--mazesp;
		}
		mazesp=bestpath;
		pos=*mazesp;
		j=0x80;
		while(bestlen)
		{
			endpos=*mazesp++;
			video[(long)endpos+pos>>1]=j++ | 0x80;
			video[endpos]=j++ | 0x80;
			pos=endpos;
			--bestlen;
		}
		while(!kr())
		{
			while(!inretrace()) rand();
			while(inretrace()) rand();
			loadmap(--j>>2);
		}
		i=rci()&255;
		if(i==0x1b) break;
	}
	setmode(oldmode);
/* Don't bother to free mul320 and mazeblock since they're in low mem */

	return 0;
}
