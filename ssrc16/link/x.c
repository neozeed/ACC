
//char *findenv(),*malloc(),*malloc(),*malloc();
long lseek();

#define INCNAME "LINKDIR"
#define DATABLOCKSIZE 0x40000L
#define IOBLOCKSIZE 30000
#define OUTBLOCKSIZE 0x80000L
#define MAXIN 256
#define CODE 0
#define BSS 1
#define UNDEF 255

struct define {
	struct define *defnext;
	char *deftext;
	char deftype;
	char deffile;
	long defoffset;
	struct use *defuse;
};
struct use {
	struct use *usenext;
	char usetype;
	char usefile;
	long useoffset;
};

struct sym {
	struct sym *symnext;
	char *symtext;
	long symval;
	char symfile;
	char sympad;
};
struct input
{
	char inputname[80];
	char inputtype;
	char *inputloc;
	long    codelen;
	long    bsslen;
	long    codedelta;
	long    bssdelta;
};


unsigned short *headerlen=2;
long *mainaddr=4;
char mainname[]="_main";
int unresolved=0;


/*
char *TOPCODE="_topcode";
char *TOPBSS="_topbss";*/


int infile;
int outfile;
char *filepoint;
struct input *ins=0;
char *datablock=0;
char *datapoint;
char *ioblock=0;
int incount;
char scr1[80];
struct define **headers=0;
char *outname[64];
long *longp;
short *wordp;
char multflag=1;

char *outbuff=0;
char *outpoint,*outend;

char *codeloc;

long maxcode;
long maxbss;
long dummy;
long options=0;
#define OPTH 1
#define OPTS 2
#define OPTU 4
#define OPTF 8
#define OPTM 16
struct sym *symhead;
/*int topcode,topbss;*/
char *inctext;
char *TREAD="r";

skip(len)
long len;
{
	filepoint+=len<<2;
}

struct define *newdef()
{
struct define *t;
	t=datapoint;
	datapoint+=sizeof(struct define);
	return t;
}
struct sym *newsym()
{
struct sym *t;
	t=datapoint;
	datapoint+=sizeof(struct sym);
	return t;
}
struct use *newuse()
{
struct use *t;
	t=datapoint;
	datapoint+=sizeof(struct use);
	return t;
}
char *addtext(str)
char *str;
{
char *t;
int len;
	t=datapoint;
	len=strlen(str)+1;
	len+=len&1;
	datapoint+=len;
	strcpy(t,str);
	return t;
}

revword(val)
unsigned int val;
{
	return (val>>8) | (val<<8);
}
long revlong(val)
unsigned long val;
{
	return ((val&0xff000000L)>>24) | ((val&0xff0000L)>>8) | ((val&0xff00)<<8) | ((val&0xff)<<24);
}

lout(val)
long val;
{
	*((long *)outpoint)++=revlong(val);
}

outw(val)
short val;
{
	*((short *)outpoint)++=val;
}

long readlong()
{
long val;
char *p;

	p=&val;
	p+=3;
	*p--=*filepoint++;
	*p--=*filepoint++;
	*p--=*filepoint++;
	*p=*filepoint++;
	return val;
}

symbol(v)
int v;
{
int t;

	t=v<<2;

	bcopy(filepoint,scr1,t);
	filepoint+=t;
	scr1[t]=0;
}


struct define *finddef(str)
char *str;
{
struct define *h;

	h=headers[hash8(str)];
	while(h)
	{
		if(!strcmp(str,h->deftext)) break;
		h=h->defnext;
	}
	return h;
}

/*
linksym(str)
char *str;
{
int h,hl,o;
	o=defoff;
	h=hash8(str);
	hl=headers[h];
	headers[h]=defoff;
	defww(defoff+DEFNEXT,hl);
	defww(defoff+DEFTEXT,textoff);
	defwb(defoff+DEFTYPE,1);
	defwb(defoff+DEFFILE,0);
	defwl(defoff+DEFOFFSET,0L);
	defww(defoff+DEFUSE,0);
	defoff+=DEFSIZE;
	addtext(str);
	return o;
}
*/

freeind(addr)
char **addr;
{
	if(*addr)
	{
		free(*addr);
		*addr=0;
	}
}

freestuff()
{
int i;
	if(ins)
	{
		for(i=0;i<incount;i++)
			freeind(&ins[i].inputloc);
	}

	freeind(&ins);
	freeind(&ioblock);
	freeind(&datablock);
	freeind(&outbuff);
	freeind(&headers);
}

nomem()
{
	freestuff();
	printf("Out of memory\n");
	exit(1);
}

missing(str)
char *str;
{
	if(!unresolved)
		puts("Unresolved references:\n");
	printf("%s\n",str);
	unresolved++;
}


main(argc,argv)
int argc;
char *argv[];
{
int i,j;
long exelen;
struct define *d;
struct use *t1;
char ch,*p1;
int chunk;
long left;
struct use *ause;

	if(argc<2)
	{
		puts("LINK Copyright (c) 1997 by David Ashley\n");
		puts("-- Please register this --\n");
		puts("Use: link [-OPT] [-ffilespec] <obj1> <obj2> <obj3>...\n");
		puts("-h   Do not use _start and _lib headers\n");
		puts("-m   Warn of multiple definitions\n");
		puts("-s   Pass symbol table information through\n");
		puts("-u   Display usage information\n");
		return 0;
	}

	incount=0;
	ins=malloc(MAXIN*sizeof(struct input));
	if(!ins) nomem();
	clearmem(ins,MAXIN*sizeof(struct input));
	datablock=malloc(DATABLOCKSIZE);
	if(!datablock) nomem();
	datapoint=datablock;
	outbuff=malloc(OUTBLOCKSIZE);
	if(!outbuff) nomem();
	outpoint=outbuff;
	outend=outbuff+OUTBLOCKSIZE;
	ioblock=malloc(IOBLOCKSIZE);
	if(!ioblock) nomem();
	headers=malloc(256*sizeof(struct define *));
	if(!headers) nomem();

	symhead=0;
	for(i=0;i<256;i++) headers[i]=0;

/*      topcode=linksym(TOPCODE);
	topbss=linksym(TOPBSS);*/

	options=0;
	for(i=1;i<argc;i++)
	{
		if(argv[i][0]=='-')
		{
			switch(argv[i][1])
			{
			case 's':
				options|=OPTS;break;
			case 'h':
				options|=OPTH;break;
			case 'u':
				options|=OPTU;break;
			case 'f':
				break;
			case 'm':
				options|=OPTM;break;
			default:
				printf("Unknown option %c\n",argv[i][1]);
			}
		}
	}

	if(~options&OPTH)
		scan("_start");

	multflag=1;
	*outname=0;
	for(i=1;i<argc;i++)
	{
		if(argv[i][0]!='-')
			scan(argv[i]);
		else if(argv[i][1]=='f')
			handlefile(argv[i]+2);
	}
	multflag=0;
	if(~options&OPTH)
		scan("_lib");
#ifdef DEBUG
	for(i=0;i<incount;i++)
	{
		printf("file:%s\n",ins[i].inputname);
		printf(" CODE=%08lx,BSS=%08lx\n",ins[i].codelen,ins[i].bsslen);
	}
#endif
	unresolved=0;
	for(i=0;i<256;i++)
	{
		if(d=headers[i])
			while(d)
			{
				if(d->deftype==UNDEF)
					missing(d->deftext);
				d=d->defnext;
			}
	}
	if(unresolved) goto abort;
	if(!incount) {printf("Nothing to do\n");goto abort;}

	maxbss=0;
	maxcode=0;

	for(i=0;i<incount;i++)
	{
		ins[i].codedelta=maxcode;
		ins[i].bssdelta=maxbss;
		maxcode+=ins[i].codelen;
		maxbss-=ins[i].bsslen;
	}

/*      defwl(topcode+DEFOFFSET,maxcode);
	defwl(topbss+DEFOFFSET,maxbss);*/

	strcat(outname,".exe");
	outfile=fopen(outname,"w");
	if(!outfile) {printf("Cannot open output file %s\n",outname);goto abort;}

	exelen=maxcode+0x20;
	i=exelen&0x1ff;
	j=exelen >> 9;
	if(!i) i=0x200;
	else j++;
	outw(0x5a4d); /* EXE sig */
	outw(i); /* # of bytes in last page */
	outw(j); /* # of 512 byte pages */
	outw(0); /* # of reloc items */
	outw(2); /* # of paragraphs of header */
	outw(0x400); /* min alloc */
	outw(0xffff); /* max alloc */
	outw((short)(maxcode+15>>4)); /* ss */
	outw(0); /* sp */
	outw(0); /* checksum */
	outw(0); /* PC */
	outw(0); /* cs */
	outw(0); /* offset to reloc tab */
	outw(0); /* overlay # */
	lout(0x44415645L);

	for(i=0;i<incount;i++) fix(i);
	if(options&OPTS) dosymbols();

	p1=outbuff;
	left=outpoint-outbuff;
	while(left)
	{
		chunk=left<IOBLOCKSIZE ? left : IOBLOCKSIZE;
		bcopy(p1,ioblock,chunk);
		write(outfile,ioblock,chunk);
		p1+=chunk;
		left-=chunk;
	}

	fclose(outfile);

#ifdef DEBUG
	for(i=0;i<256;i++)
		if(d=headers[i])
			while(d)
			{
				printf("%08lx ",ins[d->deffile].codedelta+d->defoffset);
				puts(d->deftext);
				putchar('\n');
/*                              t1=d->defuse;
				while(t1)
				{
					printf(" %d:%08lx",t1->usefile,t1->useoffset);
					t1=t1->usenext;
				}
				putchar('\n');*/
				d=d->defnext;
			}
#endif

abort:
	if(options&OPTU)
	{
		printf("%08lx Memory used for data\n",datapoint-datablock);
		printf("Code:%06lx BSS:%06lx\n",maxcode,maxbss);
	}
	freestuff();
	exit(0);
}

dosymbols()
{
int i;
long base;
char type,num;
int count;
struct define *d,*od;

	count=0;
	for(i=0;i<256;i++)
	{
		d=headers[i];
		while(d)
		{
			type=d->deftype;
			num=d->deffile;
			if(type==CODE) base=ins[num].codedelta;
			else if(type==BSS) base=ins[num].bssdelta;
			else continue;
			base+=d->defoffset;
			if(!count) lout(0x3f0L);
			count++;
			symout(d->deftext);
			lout(base);
			d=d->defnext;
		}
	}
	while(symhead)
	{
		if(!finddef(symhead->symtext))
		{
			if(!count) lout(0x3f0L);
			count++;
			symout(symhead->symtext);
			lout(symhead->symval+ins[symhead->symfile].codedelta);
		}
		symhead=symhead->symnext;
	}
	if(count) lout(0L);
}

symout(str)
char *str;
{
int len;
	len=strlen(str);
	bcopy(str,outpoint,len);
	outpoint+=len;
	while(len++ &3) *outpoint++=0;
}

#define FILEMAX 4096
handlefile(str)
char *str;
{
int file;
char filearea[FILEMAX+1];
int len;
char name[256],ch,*p,*p2;

	file=fopen(str,"r");
	if(!file)
	{
		printf("Cannot open parameter file %s\n",str);
		return;
	}
	len=read(file,filearea,FILEMAX);
	fclose(file);
	filearea[len]=0;
	if(len==FILEMAX)
		printf("Parameter file %s truncated to %d bytes\n",str,FILEMAX);
	p=filearea;
	while(1)
	{
		while((ch=*p) && (ch==' ' || ch==13 || ch==10 || ch==9)) p++;
		if(!*p) break;
		p2=name;
		while((ch=*p) && ch!=' ' && ch!=13 && ch!=10 && ch!=9) *p2++=*p++;
		*p2=0;
		scan(name);
	}
}


scan(str)
char *str;
{
long    v1,v2,v3;
int t,type;
struct use *t2;
int htype;
int hashval;
struct define *def1;
char iname[80];
char *pntr,*p2;
char namecopy[64];
long filelen;
struct define *adef;
struct sym *asym;
struct use *ause;
int chunk;
char thisfile;


	sprintf(namecopy,"%s.o",str);
	strcpy(ins[incount].inputname,namecopy);
	ins[incount].codelen=0;
	ins[incount].bsslen=0;

	infile=fopen(namecopy,TREAD);
	if(!infile)
	{
		if(inctext=findenv(INCNAME))
		{
			pntr=inctext;
			while(*pntr)
			{
				p2=iname;
				while(*pntr && *pntr!=';') *p2++=*pntr++;
				if(*pntr) pntr++;
				if(p2>iname && p2[-1]!='/' && p2[-1]!='\\') *p2++='\\';
				*p2=0;
				strcat(iname,namecopy);
				if(infile=fopen(iname,TREAD)) break;
			}
		}
		if(!infile)
		{
			printf("Unable to open file %s\n",namecopy);
			return 1;
		}
		strcpy(ins[incount].inputname,iname);
	}
	if(options&OPTH)
		strcpy(outname,str);
	else
		if(!*outname) strcpy(outname,str);

	filelen=lseek(infile,0L,2);
	rewind(infile);
	filepoint=malloc(filelen+4);
	if(!filepoint) nomem();
	ins[incount].inputloc=filepoint;
	pntr=filepoint;
	while(filelen)
	{
		chunk=filelen>IOBLOCKSIZE ? IOBLOCKSIZE : filelen;
		read(infile,ioblock,chunk);
		bcopy(ioblock,pntr,chunk);
		pntr+=chunk;
		filelen-=chunk;
	}
	*(long *)pntr=0xffffffffL;
	fclose(infile);
	thisfile=incount;
	incount++;

	while(1)
	{
		v1=readlong();
		switch((int)v1)
		{
		case 0x3f3:
			printf("Cannot link executable %s\n",str);
			return 2;
		case    0x3eb: /* hunk_bss */
			htype=BSS;
			ins[thisfile].bsslen=readlong()*4L;
			break;
		case 0x3f2: /* hunk_end */
			break;
		case 0x3e8: /* hunk_name */
			skip(readlong());
			break;
		case 0x3ea: /* hunk_data */
		case 0x3e9: /* hunk_code */
			htype=CODE;
			v1=readlong();
			ins[thisfile].codelen=v1<<2;
			skip(v1);
			break;
		case 0x3cd: /* hunk_16reloc */
		case 0x3cc: /* hunk_32reloc */
		case 0x3ed: /* hunk_reloc16 */
		case 0x3ec: /* hunk_reloc32 */
			while(v1=readlong()) skip(v1+1);
			break;
		case 0x3f0: /* hunk_symbol */
			while(v1=readlong())
			{
				symbol((int)v1);
				asym=newsym();
				asym->symnext=symhead;
				asym->symtext=addtext(scr1);
				asym->symval=readlong();
				asym->symfile=thisfile;
				symhead=asym;
			}
			break;
		case    0x3f1: /* hunk_debug */
			v1=readlong(); skip(v1);
			break;
		case 0x3e7: /* hunk_unit */
			if(v1=readlong()) skip(v1);
			break;
		case 0x3ef: /* hunk_ext */
			while(v1=readlong())
			{
				type=(unsigned long)v1>>24L;
				v1&=0xffffffL;
				symbol((int)v1);
				switch(type)
				{
				case 1: /* def */
					def1=finddef(scr1);
					if(def1)
					{
						v1=readlong();
						if(def1->deftype==UNDEF)
						{
							def1->defoffset=v1;
							def1->deffile=thisfile;
							def1->deftype=htype;
						}
						else
							if(options&OPTM || multflag) printf("Multiply defined symbol %s\n",scr1);
					}
					else
					{
						hashval=hash8(scr1);
						adef=newdef();
						adef->defnext=headers[hashval];
						headers[hashval]=adef;
						adef->deftext=addtext(scr1);
						adef->deftype=htype;
						adef->deffile=thisfile;
						adef->defoffset=readlong();
						adef->defuse=0;
					}
					break;
				case 0x91: /* 32ref */
				case 0x93: /* 16ref */
				case 0x99: /* 32rel */
				case 0x9b: /* 16rel */
				case 0x81: /* ref32 129 */
				case 0x83: /* ref16 131 */
				case 0x8b: /* rel16 139 was 140?? */
					def1=finddef(scr1);
					if(!def1)
					{
						def1=newdef();
						hashval=hash8(scr1);
						def1->defnext=headers[hashval];
						headers[hashval]=def1;
						def1->deftext=addtext(scr1);
						def1->deftype=UNDEF;
						def1->defuse=0;
					}
					t=readlong();
					t2=def1->defuse;
					while(t--)
					{
						ause=newuse();
						ause->usenext=t2;
						t2=ause;
						ause->usetype=type;
						ause->usefile=thisfile;
						ause->useoffset=readlong();
					}
					def1->defuse=t2;
					break;
				}
			}
			break;
		default:
			if(v1==0xffffffffL) return 0;
			printf("Unknown code %08lx in file %s\n",
				v1,ins[thisfile].inputname);
			return 1;
		}
	}
}
fix(which)
int which;
{
long v1,v2,v3;
int htype,t;
int chunk;
char *p;

	filepoint=ins[which].inputloc;
	while(1)
	{
		v1=readlong();
		switch((int)v1)
		{
		case    0x3eb: /* hunk_bss */
			htype=BSS;
			readlong();
			break;
		case 0x3f2: /* hunk_end */
			if(htype==CODE)
			{
				v1=ins[which].codelen;
				p=codeloc;
				while(v1)
				{
					chunk= v1>0x7ffcL ? 0x7ffc : v1;
					bcopy(p,outpoint,chunk);
					p+=chunk;
					outpoint+=chunk;
					v1-=chunk;
				}
			}
			break;
		case 0x3e8: /* hunk_name */
			skip(readlong());
			break;
		case 0x3ea: /* hunk_data */
		case 0x3e9: /* hunk_code */
			htype=CODE;
			v1=readlong();
			codeloc=filepoint;
			filepoint+=v1<<2;
			patch(which);
			break;
		case 0x3cd: /* hunk_16reloc */
			while(v1=readlong())
			{
				v2=readlong();
				v2=ins[which+(int)v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					wordp=codeloc+v3;
					*wordp+=v2;
				}
			}
			break;
		case 0x3ed: /* hunk_reloc16 */
			while(v1=readlong())
			{
				v2=readlong();
				v2=ins[which+(int)v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					wordp=codeloc+v3;
					*wordp=revword(revword(*wordp)+v2);
				}
			}
			break;
		case 0x3cc: /* hunk_32reloc */
			while(v1=readlong())
			{
				v2=readlong();
				v2=ins[which+(int)v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					longp=codeloc+v3;
					*longp+=v2;
				}
			}
			break;
		case 0x3ec: /* hunk_reloc32 */
			while(v1=readlong())
			{
				v2=readlong();
				v2=ins[which+(int)v2].codedelta;
				while(v1--)
				{
					v3=readlong();
					longp=codeloc+v3;
					*longp=revlong(revlong(*longp)+v2);
				}
			}
			break;
		case 0x3f0: /* hunk_symbol */
			while(v1=readlong()) skip(v1+1);
			break;
		case    0x3f1: /* hunk_debug */
			v1=readlong(); skip(v1);
			break;
		case 0x3e7: /* hunk_unit */
			if(v1=readlong()) skip(v1);
			break;
		case 0x3ef: /* hunk_ext */
			while(v1=readlong())
			{
				t=(unsigned long)v1>>24L;
				v1&=0xffffffL;
				skip(v1);
				switch(t)
				{
				case 1: /* def */
				case 2:
				case 3:
					readlong();
					break;
				case 0x81: /* ref32 129 */
				case 0x83: /* ref16 131 */
				case 0x84: /* ref8 132 */
				case 0x8b: /* rel16 140 */
				case 0x91: /* 32ref */
				case 0x93: /* 16ref */
				case 0x99: /* 32rel */
				case 0x9b: /* 16rel */
				default:
					v1=readlong();
					skip(v1);
					break;
				}
			}
			break;
		default:
			if(v1==0xffffffffL) return 0;
			return 1;
		}
	}
}

patch(num)
int num;
{
int i,t,n;
struct define *d;
long loc;
long dest,t2;
struct use *t1;
long thishunk;

	for(i=0;i<256;i++)
		if(d=headers[i])
			while(d)
			{
				n=d->deffile;
				t=d->deftype;
				if(t==CODE) dest=ins[n].codedelta;
				else if(t==BSS) dest=ins[n].bssdelta;
				else continue;
				thishunk=ins[num].codedelta;
				dest+=d->defoffset;

				t1=d->defuse;
				while(t1)
				{
					if(t1->usefile==num)
					{
						loc=t1->useoffset;
						t=t1->usetype;
						switch(t)
						{
						case 0x91: /* 32ref */
							longp=codeloc+loc;
							*longp+=dest;
							break;
						case 0x93: /* 16ref */
							wordp=codeloc+loc;
							t2=(unsigned)*wordp+dest;
							if(t2<0 || t2>0xffffL)
								rangeerr(num,loc,d);
							*wordp=t2;
							break;
						case 0x99: /* 32rel */
							longp=codeloc+loc;
							*longp+=dest-thishunk;
							break;
						case 0x9b: /* 16rel */
							wordp=codeloc+loc;
							t2=*wordp+dest-thishunk;
							if(t2<-0x8000L || t2>0x7fffL)
								rangeerr(num,loc,d);
							*wordp=t2;
							break;
						case 0x81: /* ref32 */
							longp=codeloc+loc;
							*longp=revlong(revlong(*longp)+dest);
							break;
						case 0x83: /* ref16 */
							wordp=codeloc+loc;
							t2=revword(*wordp)+dest;
							if(t2<-0x8000L || t2>0x7fffL)
								rangeerr(num,loc,d);
							*wordp=revword((short)t2);
							break;
						case 0x8b: /* rel16 was 8c??? */
							wordp=codeloc+loc;
							t2=revword(*wordp)+dest-loc-thishunk;
							if(t2<-0x8000L || t2>0x7fffL)
								rangeerr(num,loc,d);
							*wordp=revword((short)t2);
							break;
						}
					}
					t1=t1->usenext;
				}
				d=d->defnext;
			}
}
rangeerr(num,loc,def)
int num,loc;
struct define *def;
{
	printf("Range error in %s,offset %x, symbol=%s\n",
		ins[num].inputname,loc,def->deftext);
}
