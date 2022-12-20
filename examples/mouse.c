#include <regs.h>

#define MOUSEFRAC 2
#define MOUSEXMAX (302<<MOUSEFRAC)
#define MOUSEYMAX (181<<MOUSEFRAC)
#define MAXBLOBS 512
#define BLOBFRAC 6
#define BLOBGRAVITY 5
#define THRESHOLD 20
#define SMALLSIZE 2
#define BIGSIZE 4
	
#define ABS(x) ((x)<0 ? -(x) : (x))

int explodenum;

char sizes[7]={1,2,3,4,5,4,3,2};


struct blob {
	struct blob *blobnext;
	int blobx;
	int bloby;
	int blobdx;
	int blobdy;
	int bloblife;
	int blobsize;
} *blobs,*freeblobs,*activeblobs;

char *lalloc();
int rand();
REGS xr;
short mousethere,mousebuttons,mouseabsx,mouseabsy,mousex,mousey;

char *video;
int *mul320;
int oldmode;
char *offscreen;
char *offscreen2;

char sqrt[]={
0,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3,
4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,
5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,
6,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10,
10,10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,
11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,
12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,
12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,
13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,
13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,
14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,
14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
};


initmouse()
{
	xr.AX=0;
	int86(&xr,0x33);
	mousethere=xr.AX;
printf("initmouse() %d\n",mousethere);
printf("ah %d\nAl %d\n",xr.AH,xr.AL);

	if(!mousethere) return 0;
	xr.AX=0x1a;
	xr.BX=xr.CX=40;
	xr.DX=0;
	int86(&xr,0x33);
	xr.AX=0x20;
	int86(&xr,0x33);
	mouseabsx=0<<MOUSEFRAC;
	mouseabsy=190<<MOUSEFRAC;
	return 1;
}
readmouse()
{
	if(!mousethere) return;
	xr.AX=3;
	int86(&xr,0x33);
	mousebuttons=xr.BX;
	xr.AX=0x0b;
	int86(&xr,0x33);
	mouseabsx+=xr.CX;
	mouseabsy+=xr.DX;
	if(mouseabsx<0) mouseabsx=0;
	if(mouseabsy<0) mouseabsy=0;
	if(mouseabsx>MOUSEXMAX) mouseabsx=MOUSEXMAX;
	if(mouseabsy>MOUSEYMAX) mouseabsy=MOUSEYMAX;
	mousex=(mouseabsx>>MOUSEFRAC)+8;
	mousey=(mouseabsy>>MOUSEFRAC)+9;
}


#asm
_setmode:
	movzx eax,byte [esp+4]
	int $10
	ret
_retrace:
	mov     dx,$3da
	in      al,dx
	movzx eax,al
	and     al,8
	ret

;loadcolor(num,r,g,b)
_loadcolor:
	mov     dx,$3c8
	mov     al,[esp+4]
	out     dx,al
	inc     dx
	mov     al,[esp+6]
	out     dx,al
	mov     al,[esp+8]
	out     dx,al
	mov     al,[esp+10]
	out     dx,al
	ret

_loadmap:
	mov     dx,$3c8
	xor     al,al
	out     dx,al
	inc     dx
	mov     ecx,256*3
	mov     esi,[esp+4]
lmlp:
	lodsb
	out     dx,al
	loop    lmlp
	ret
#endasm

nomem()
{
	printf("Not enough low memory!\n");
	exit(1);
}

#asm
_fire:
	mov     edi,[esp+8]
	mov     esi,[esp+4]
	mov     edx,[esp+12]
	add     edi,320
	mov     ecx,64000-640
	add     esi,320
	xor     eax,eax
firelp:
	movzx ebx,byte [esi-320]
	mov     al,[esi+320]
	add     ebx,eax
	mov     al,[esi-1]
	add     ebx,eax
	mov     al,[esi+1]
	add     ebx,eax
	mov     al,[esi]
	add     ebx,eax
	mov     al,[esi-321]
	add     ebx,eax
	mov     al,[esi-319]
	add     ebx,eax
	mov     al,[esi-322]
	add     ebx,eax
	mov     al,[esi-318]
	add     ebx,eax
	mov     bl,[edx+ebx]
	mov     [edi],bl
	inc     esi
	inc     edi
	loop    firelp
	ret
#endasm

disk(x,y,rad)
{
char *p;
int i,j,k,aj;
int rad2=rad*rad;
int w;


	for(j=-rad;j<=rad;j++)
	{
		w=sqrt[rad2-j*j];
		aj=ABS(j)<<2;
		if(w)
		{
			p=offscreen+mul320[y+j]+x-w;
			k=w+w+1;
			i=-w;
			while(k--) {*p++=255-(ABS(i)<<2)-aj;i++;}
		}
	}
}

addblob()
{
int dx,dy;
struct blob *ablob;

	if(!freeblobs) return;
	dx=(rand()&255)-128;
	dy=(rand()&127)+230;
	ablob=freeblobs;
	freeblobs=freeblobs->blobnext;
	ablob->bloblife=(rand()&511)+256;
	ablob->blobdx=dx;
	ablob->blobdy=dy;
	ablob->blobx=(128+(rand()&63))<<BLOBFRAC;
	ablob->bloby=2<<BLOBFRAC;
	ablob->blobnext=activeblobs;
	ablob->blobsize=BIGSIZE;
	activeblobs=ablob;
}
moveblobs()
{
struct blob **lastblob,*ablob;
int x,y;

	lastblob=&activeblobs;
	while(ablob=*lastblob)
	{
		x=ablob->blobx>>BLOBFRAC;
		y=ablob->bloby>>BLOBFRAC;
		if(!--ablob->bloblife || y<0 || x<10 || x>310)
		{
			*lastblob=ablob->blobnext;
			ablob->blobnext=freeblobs;
			freeblobs=ablob;
			continue;
		}
		ablob->blobx+=ablob->blobdx;
		ablob->bloby+=ablob->blobdy;
		ablob->blobdy-=BLOBGRAVITY;
		lastblob=&ablob->blobnext;
	}
}
putblobs()
{
struct blob *ablob,*ablob2,*temp;
int x,y,dy;
int i,size;
long x2,y2,vel;

	ablob=activeblobs;
	activeblobs=0;
	while(ablob)
	{
		dy=ablob->blobdy;
		if(ablob->blobsize!=SMALLSIZE && (dy>-THRESHOLD && dy<THRESHOLD && !(rand()&7) || !(rand()&63)))
		{
			i=explodenum;
			while(i-- && freeblobs)
			{
				ablob2=freeblobs;
				freeblobs=freeblobs->blobnext;
				ablob2->blobx=ablob->blobx;
				ablob2->bloby=ablob->bloby;
				while()
				{
					x2=(rand()&511)-256;
					y2=(rand()&511)-256;
					vel=x2*x2+y2*y2;
					if(vel>0x3000 && vel<0x10000L) break;
				}
				ablob2->blobdx=ablob->blobdx+x2;
				ablob2->blobdy=ablob->blobdy+y2;
				ablob2->bloblife=16+(rand()&31);
				ablob2->blobsize=SMALLSIZE;
				ablob2->blobnext=activeblobs;
				activeblobs=ablob2;
				ablob->bloblife=1;
			}                       
		}
		x=ablob->blobx>>BLOBFRAC;
		y=ablob->bloby>>BLOBFRAC;
		size=ablob->blobsize;
		if(size==BIGSIZE && ablob->blobdy>0 && ablob->blobdy<200)
			size=sizes[ablob->bloblife&7];
		if(x>10 && x<310 && y>10 && y<190)
			disk(x,199-y,size);
		temp=ablob;
		ablob=ablob->blobnext;
		temp->blobnext=activeblobs;
		activeblobs=temp;
	}
}



long gettime();

long gtime()
{
	long otime;
	int hour,minute,second,hundredth;

	otime=gettime();
	hour=otime>>24;
	minute=(otime>>16)&0xff;
	second=(otime>>8)&0xff;
	hundredth=otime&0xff;
	otime=hundredth+second*100+minute*6000L+hour*360000L;
	return otime;
}

#define RATE 1
normal(char *map)
{
int i,j;
	for(i=0;i<8192;i++)
	{
		j=i/9;
		map[i]=j<256 ? (j>=RATE ? j-RATE : 0) : 255;
	}
}
bright(char *map)
{
int i;
	for(i=0;i<8192;i++) map[i]=i>>3<255 ? (i>>3) : 255;
}



loadcolors(unsigned int which)
{
short i,j;
short r,g,b;

	which%=12;
	if(!which) {setmode(0x13);return;}
	for(i=0;i<256;i++)
	{
		switch(which)
		{
		case 1:
			if(i<64) loadcolor(i,0,0,0);
			else if(i<128)  loadcolor(i,i-64,0,0);
			else if(i<192) loadcolor(i,63,i-128,0);
			else loadcolor(i,63,63,i-192);
			break;
		case 2:
			if(i<64) loadcolor(i,0,0,0);
			else if(i<128)  loadcolor(i,0,0,i-64);
			else loadcolor(i,(i-128)>>1,(i-128)>>1,63);
			break;
		case 3:
			loadcolor(i,i>>2,i>>2,i>>2);
			break;
		case 4:
			r=rand()&0x3f;
			g=rand()&0x3f;
			b=rand()&0x3f;
			loadcolor(i,r*i>>8,g*i>>8,b*i>>8);
			break;
		case 5:
			loadcolor(i,i>>2,0,0);
			break;
		case 6:
			loadcolor(i,0,i>>2,0);
			break;
		case 7:
			loadcolor(i,0,0,i>>2);
			break;
		case 8:
			j=i&15;
			if(i&16) j=15-j;
			j=(i>>2)*j/16;
			loadcolor(i,j,j,j);
			break;
		case 9:
			j=0;
			if(i>8 && i<128) j=63;
			loadcolor(i,j,j,j);
			break;
		case 10:
			j=31-(i&31)<<1;
			r=i&32 ? j : 0;
			g=i&64 ? j : 0;
			b=i&128 ? j : 0;
			loadcolor(i,r,g,b);
			break;
		case 11:
			j=(i&15)<<2;
			if(i&16) j=63-j;
			r=i&32 ? j : 0;
			g=i&64 ? j : 0;
			b=i&128 ? j : 0;
			loadcolor(i,r,g,b);
			break;
		}
	}
}

main()
{
int i,j,k,color;
char *remap,*remap2;
char *p;
long time=0;
long stime;
long frames;
int flash;
int whichmap;
int key;
char paused;

	initmouse();
	while (!kr()) 
		{
		readmouse();
		printf("mousex %d mousey %d mousebuttons %d\t\r",mousex,mousey,mousebuttons);
		}
	return 0;
}
