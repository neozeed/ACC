#include "asm.h"

char *malloc(),*mallocl(),*lalloc(),*findenv();
long readl(),writel();

#define BLOCKSIZE 0x40000L
#define IOBLOCKSIZE 30000
#define MACROMAX 16384
#define MAXSYMS 16384
#define FORCEOBJ 1
#define LISTBOTH 0

char *outblock=0;
char *outoff;
char *textblock=0;
char *listbuff=0;
char *textpoint;
char *macroblock=0;
char **filelist=0;
struct sym *publichead;

struct reference *reloc16head=0,*reloc32head=0;
short reloc32num=0,reloc16num=0;


char *listpoint,*listend;

struct sym *heresym;

long lseek();


struct oplist z80list,scanlist,directlist,x86list,*currentlist;

extern domacro();
extern doendm();
extern doinclude();
extern setyes();
extern setno();
extern doset();
extern doequ();

struct sym **headers=0;
long exprval;

char *inpoint;

char exprstack[EXPRMAX];
char *exprsp;
extern failerr();

#define INCNAME "A86INC"

short dom68000();
short dox86();
short doz80();

struct sym *lastref;
long operval;
long soffset;
struct sym *nextsym;
unsigned maxlines;
short numopen;
char options[26];
short outfile=0,listfile=0;
long pcount,pcmax;
short pass,passlist;
short cline;
char *macstack;
char *macpars[10];
short maclens[10];
char attr[128];
short symcount;
short errorfile=0;
short errorcount,warncount;
char **blockhead;
long blockcount;
struct sym *symbols;

/*-----------------All chars follow------*/
char alabel; /* flag, 1 if this line had a label */
struct sym linelabel,symbol,symbol2,opsym;
char ltext[SYMMAX+2];
char stext[SYMMAX+2];
char stext2[SYMMAX+2];
char opcode[80];
char variant;
char exprtype;
char exprflag;
char opertype;
char phase;
char storing;
char oppri;
char opop;
char depth,ydepth;
char expanding;
char inmac;
char xrdflag;
char filename[80];
char origname[80];
char umac[3];
char *TREAD="r";
char *TWRITE="w";

/* abs=0, rel=1, reg=2, xref=3, mac=4 */
char cnone[5][5]={
	ABSTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};
char cplus[5][5]={
	ABSTYPE,RELTYPE,ERR,XREFTYPE,ERR,
	RELTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	XREFTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};
char cminus[5][5]={
	ABSTYPE,ERR,ERR,ERR,ERR,
	RELTYPE,ABSTYPE,ERR,ERR,ERR,
	ERR,ERR,REGTYPE,ERR,ERR,
	XREFTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};
char cdivide[5][5]={
	ABSTYPE,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,REGTYPE,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR,
	ERR,ERR,ERR,ERR,ERR};



long gettime();

long gtime()
{
	long otime;
	short hour,minute,second,hundredth;

	otime=gettime();
	hour=otime>>24;
	minute=(otime>>16)&0xff;
	second=(otime>>8)&0xff;
	hundredth=otime&0xff;
	otime=hundredth+second*100+minute*6000L+hour*360000L;
	return otime;
}




makename(to,from,ch)
char *to,*from,*ch;
{
	while(*to++=*from++);
	to--;
	*to++='.';
	do {*to++=*ch;} while(*ch++);
	*to=0;
}




struct sym *addsym(asym)
struct sym *asym;
{
	struct sym *pntr;
	short h;

	h=hash8(asym->symtext);
	nextsym->symnext=headers[h];
	headers[h]=nextsym;
	nextsym->symvalue=asym->symvalue;
	nextsym->symtype=asym->symtype;
	nextsym->symnum=asym->symnum;
	nextsym->symunique=asym->symunique;
	nextsym->symflags=asym->symflags;
	nextsym->symref=0;
	nextsym->symtext=textpoint;
	nextsym++; /* bounds check */
	addtext(asym->symtext);
	return nextsym-1;
}



fixattr(orval,str)
short orval;
char *str;
{
	char ch;

	while(ch=*str++)
		attr[ch]|=orval;
}
phaserr() {error2("Phase error");}
failerr() {error2("FAIL directive");}
unbalancedq() {error2("Unbalanced '");}
unbalanced() {error2("Unbalanced ()");}
badreg() {error2("Illegal register");}
badchar() {error2("Illegal Character");}
illegalop() {error2("Illegal op code");}
syntaxerr() {error2("Syntax error");}
absreq() {error2("Absolute data required");}
badmode() {error2("Illegal effective address");}
outofrange() {error2("Operand out of range");}
div0() {error2("Divide by zero");}
unknownerr(str)
char *str;
{
char temp[80];
	strcpy(temp,"Undefined symbol ");
	strcat(temp,str);
	error2(temp);
}
duplicate() {error1("Duplicate label");}
badoperation() {error2("Illegal operation");}
badsize() {error2("Illegal opcode size");}
error2(emsg)
char *emsg;
{
	if(pass) {errorcount++;error(emsg);}
}
error1(emsg)
char *emsg;
{
	if(!pass) {errorcount++;error(emsg);}
}
warn2(emsg)
char *emsg;
{
	if(pass) {warncount++;error(emsg);}
}
error(emsg)
char *emsg;
{
	if(errorfile) fprintf(errorfile,"%d:%s\n",cline,emsg);
	else printf("%s(%d) %s\n",filename,cline,emsg);
}

nomem(num)
{
	printf("Not enough memory %d\n",num);
	closeall();
	exit(num);
}
freeind(addr)
char **addr;
{
	if(*addr)
	{
		free(*addr);
		*addr=0;
	}
}
ccexit()
{
	closeall();
	printf("*** Break\n");
	exit(1);
}
freestuff()
{
char *p;

	freeind(&headers);
	freeind(&listbuff);
	freeind(&outblock);
	freeind(&textblock);
	freeind(&macroblock);
	freeind(&symbols);

	while(filelist)
	{
		p=filelist;
		filelist=*filelist;
		free(p);
	}
}



countops(list,tab)
struct oplist *list;
struct anopcode *tab;
{
short i,j;
	i=0;
	list->listopcodes=tab;
	while((tab++) ->opcodename) i++;
	j=1;
	while(j<=i) j+=j;
	j>>=1;
	list->numops=i;
	list->powerops=j;
}
dox86()
{
	currentlist=&x86list;
}
doz80()
{
/*	currentlist=&z80list;*/
	syntaxerr();
}
dom68000()
{
/*	currentlist=&scanlist;*/
	syntaxerr();
}

main(argc,argv)
short argc;
char *argv[];
{
	char temp[80];
	char *pntr,ch;
	short sfile;
	short i,j;
	long	time1,time2,lpm;
	long pcmaxt;

	time1=gtime();
	errorcount=0;warncount=0;
	errorfile=0;
	listfile=0;
	blockhead=0;
	blockcount=0;
	outfile=0;
	publichead=0;
	xrdflag=FORCEOBJ;
	filelist=0;

	if(argc<2)
	{
		puts("A86 Copyright (C) 1997 by David Ashley\n");
		puts("-- Please register this --\n");
		puts("A86 <inputfile> [options]\n");
		puts("Options:\n");
		puts("b    Produce binary file\n");
		puts("e    Send errors to <inputfile>.err\n");
		puts("l    Produce listing file <inputfile>.l\n");
		puts("o    Inhibit creation of object file\n");
		puts("s    Include symbol table information in output\n");
		puts("u    Display statistics on usage and speed\n");
		return 1;
	}

	headers=malloc(256*sizeof(struct sym *));
	if(!headers) nomem(11);
	clearmem(headers,256*sizeof(struct sym *));
	outblock=mallocl(BLOCKSIZE);
	if(!outblock) nomem(1);
	textblock=mallocl(BLOCKSIZE);
	if(!textblock) nomem(2);
	textpoint=textblock;
	listbuff=lalloc(IOBLOCKSIZE);
	if(!listbuff) nomem(10);
	listpoint=listbuff;
	listend=listbuff+IOBLOCKSIZE-256;
	macroblock=malloc(MACROMAX);
	if(!macroblock) nomem(4);
	macstack=macroblock;
	symbols=mallocl((long)sizeof(struct sym) * MAXSYMS);
	if(!symbols) nomem(6);
	nextsym=symbols;
	heresym=nextsym++;
	clearmem(heresym,sizeof(struct sym));
	heresym->symtype=RELTYPE;

/*	countops(&scanlist,scantab);
	countops(&z80list,z80codes);*/
	countops(&directlist,directs);
	countops(&x86list,x86codes);

	for(i=0;i<128;i++)
		attr[i]=0;
	fixattr(ATTRWHITE,"\t \015");
	fixattr(ATTRSYM+ATTRFSYM+ATTROP,
		"abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ");
	fixattr(ATTRFSYM+ATTROP,".");
	fixattr(ATTRFSYM,"@");
	fixattr(ATTRSYM+ATTRNUM+ATTRHEX+ATTROP,"0123456789");
	fixattr(ATTRHEX,"abcdefABCDEF");
	linelabel.symtext=ltext;
	symbol.symtext=stext;
	symbol2.symtext=stext2;
	opsym.symtext=opcode;

	strcpy(origname,argv[1]);
	makename(filename,origname,"a");
	sfile=fopen(filename,TREAD);
	if(!sfile) {printf("Cannot open %s\n",filename);closeall();return 1;}
	fclose(sfile);
	for(i=0;i<26;i++)options[i]=0;
	if(argc==3)
	{
		pntr=argv[2];
		while(ch=*pntr++)
			if(ch>='a' && ch<='z')
				options[ch-'a']=1;
	}	
	if(options['e'-'a'])
	{
		makename(temp,origname,"err");
		errorfile=fopen(temp,TWRITE);
	}
	if(options['l'-'a'])
	{
		makename(temp,origname,"l");
		listfile=fopen(temp,TWRITE);
		if(!listfile)
		{
			printf("Cannot open listing file %s\n",temp);
			closeall();
			return 1;
		}
	}

	outoff=outblock;
	phase=0;
	pass=0;
	passlist=LISTBOTH;
	if(dopass()) goto skip2;
	outoff=outblock;
	pass=1;
	passlist=1;

	if(!options['o'-'a'])
	{
		strcpy(temp,origname);
		if(options['b'-'a']) strcat(temp,".com");
		else strcat(temp,".o");
		outfile=fopen(temp,TWRITE);
		if(!outfile)
		{
			printf("Cannot open output file %s\n",temp);
			closeall();
			return 1;
		}
	}

	if(!options['b'-'a']) headout();
	dopass();
	pcmaxt=pcmax;
	if(options['s'-'a'] && !options['b'-'a'])
		symsout();
	outrelocs();
	if(xrdflag)
		outpublics();
	if(!options['b'-'a']) tailout();
	flush();
	if(listfile && 0)
	{
		for(i=0;i<256;i++)
		{
			pntr=headers[i];
			while(pntr)
			{
				putc(pntr->symtype+'0',listfile);
				putc(':',listfile);
				pntr=pntr->symtext;
				while(ch=*pntr++) putc(ch,listfile);
				fprintf(listfile,"=%lx\n",(long)pntr->symvalue);
				pntr=pntr->symnext;
			}
		}
	}
	time2=gtime();
	time2-=time1;if(time2==0) time2++;

	lpm=(maxlines*6000L)/time2;

	if(options['u'-'a'])
	{
		printf("%06lx/%06lx Macro/symbol text/xdef/xref used\n",textpoint-textblock,BLOCKSIZE);
		printf("%04x/%04x     Symbols\n",(short)(nextsym-symbols),MAXSYMS);
		printf("%06lx        Object code bytes\n",pcmaxt);
		printf("%-11d   Lines\n",maxlines);
		printf("%-11ld   Lines/minute\n",lpm);
	}

skip2:
	closeall();
	if(errorcount) printf("%d error%s\n",errorcount,
		errorcount==1 ? "" : "s");
	if(warncount) printf("%d warning%s\n",warncount,
		warncount==1 ? "" : "s");
	exit(0);
}

closeall()
{
	if(listfile) {flushlist();fclose(listfile);}
	if(outfile) fclose(outfile);
	if(errorfile) fclose(errorfile);
	freestuff();
}


flush()
{
char *p;
long left;

	if(outfile)
		writel(outfile,outblock,outoff-outblock);
	outoff=outblock;
}



dopass()
{

	umac[0]='a'-1;umac[1]=umac[2]='a';
	symcount=1;
	x86init();
/*	z80init();*/
	dox86();
	storing=0;
	pcmax=0;
	depth=0;ydepth=0;
	pcount=0;
	maxlines=0;
	expanding=0;inmac=0;
	numopen=0;
	dofile();
	while(pcmax&15)
		bout(0);
	return 0;
}
long filelen(file)
short file;
{
long len,loc;
	loc=lseek(file,0L,1);
	len=lseek(file,0L,2);
	lseek(file,loc,0);
	return len;
}
dofile()
{
short file,piece;
long len;
char *addr,*p,*p2,ch;
char **fl;
short i;

	cline=0;
	if(!pass)
	{
		file=fopen(filename,"r");
		if(!file)
		{
			printf("Cannot open input file %s\n",filename);
			return 1;
		}
		len=filelen(file);
		addr=mallocl(len+65);
		if(!addr) nomem(5);
		fl=filelist;
		filelist=addr;
		*filelist=fl;
		strcpy(filelist+1,filename);

		addr+=64;
		len=readl(file,addr,len);
		addr[len]=0;
		removecr(addr);

		fclose(file);
	} else
	{
		fl=filelist;
		while(fl)
		{
			if(!strcmp(fl+1,filename))
			{
				addr=fl;
				addr+=64;
				break;
			}
			fl=*fl;
		}
		if(!fl)
		{
			printf("Pass 2: File %s not seen in pass 1\n",filename);
			return 1;
		}
	}
	numopen++;
	assemble(addr);
	maxlines+=cline;
	numopen--;
}


expect(ch)
char ch;
{
	if(get()==ch) return 0;
	syntaxerr();back();return 1;
}
expects(str)
char *str;
{
	while(*str)
		if(get()!=*str++)
			{syntaxerr();back();return 1;}
	return 0;
}

assemble(str)
char *str;
{
	inpoint=str;

	while(at())
	{
		++cline;
		aline();
		while(get()!=LF);
		if(cchit()) ccexit();
	}
}

aline()
{
	short (*func)();
	char *toff1,*toff2;
	char *ooff1;
	char ch,eo,lflag;
	short pcsave;
	char *save;
	short xpos,cnt,i,j;
	struct sym *pntr;
	char *mactop,*cursave;
	char *p,*p2;

	heresym->symvalue=pcount;
	toff1=inpoint;
	ooff1=outoff;
	pcsave=pcount;

	alabel=0;
	ch=at();
	if(!storing && !iswhite(ch))
	{
		if(ch==';') goto printline;

		if(isokfirst(ch))
		{
			if(ch!=LOCAL && ch!='@') ++symcount;
			ch=token(&linelabel);
			alabel=1;
			if(ch==':') get();

			linelabel.symtype=RELTYPE;
			linelabel.symvalue=pcount; /*-z80zero;*/
			linelabel.symnum= symcount;
		}
	}
	if(storing && !iswhite(at())) {if(!pass) inpoint=storeline(toff1);goto printline;}
	ch=skipwhite();
	if(isokfirst(ch))
	{
		ch=gather(opcode);
		variant=0;
		skipwhite();

		func=scan(opcode,currentlist);

		if(!func) func=scan(opcode,&directlist);

		if(storing)
		{
			if(func==doendm) {storing=0;if(!pass) endstore();}
			else if(!pass) inpoint=storeline(toff1);
			goto printline;
		}
		if(func)
		{
			if(func==doinclude && depth==ydepth)
			{
				if(listfile && passlist)
					listline(toff1,ooff1,pcsave); /*{save=inpoint;listline(toff1,ooff1,pcsave);inpoint=save;}*/
				doinclude();
				return;
			}
			if(depth==ydepth)
			{
				if(alabel) handlelabel(func);
				func();
			}
			else if(func>setyes && func<setno) func();
		} else
		{
			if(pntr=findsym(&opsym))
			{
				if(pntr->symtype==MACTYPE);
				{
					umac[0]++;
					if(umac[0]=='z'+1)
					{
						umac[0]='a';
						umac[1]++;
						if(umac[1]=='z'+1)
						{
							umac[1]='a';
							umac[2]++;
						}
					}
					mactop=macstack;
					maclens[0]=0;
					for(i=1;i<10;i++)
					{
						macpars[i]=inpoint;
						maclens[i]=0;
						while()
						{
							ch=at();
							if(ch==LF) break;
							if(iswhite(ch)) break;
							get();
							if(ch==',') break;
							maclens[i]++;
						}
					}
					if(listfile && passlist && expanding)
						listline(toff1,ooff1,pcsave);
					if(inmac==MACDEPTH)
						{error("Macro overflow");return;}
					inmac++;
					p=pntr->symvalue;
					while(ch=*p++)
					{
						if(ch=='\\')
						{
							if(isoknum(ch=*p))
							{
								p++;
								ch-='0';
								j=maclens[ch];
								p2=macpars[ch];
								while(j--) *macstack++=*p2++;
							} else if(ch=='@')
							{
								i++;
								*macstack++=umac[2];
								*macstack++=umac[1];
								*macstack++=umac[0];
							}
						} else *macstack++=ch;
					}
					*macstack++=0;

					cursave=inpoint;
					inpoint=mactop;
					while(at())
					{
						aline();
						while(get()!=LF);
					}
					inpoint=cursave;
					macstack=mactop;inmac--;
					if(expanding) return;
				}
			} else
				illegalop();
		}
	} else if(alabel && depth==ydepth) handlelabel(0);

printline:
	if(listfile && passlist) listline(toff1,ooff1,pcsave);
}

handlelabel(func)
short (*func)();
{
struct sym *pntr;

	if(!pass)
	{
		if(pntr=findsym(&linelabel))
		{
			if(func!=doset)
			{
				if(pntr->symflags&ADEF)
					duplicate();
				else
				{
					pntr->symvalue=linelabel.symvalue;
					pntr->symtype=linelabel.symtype;
					pntr->symnum=linelabel.symnum;
					pntr->symflags|=ADEF;
					pntr->symunique=linelabel.symunique;
				}
			}
		} else
		{
			linelabel.symflags=ADEF;
			addsym(&linelabel);
		}
	} else
	{
		pntr=findsym(&linelabel);
		if(pntr->symvalue!=linelabel.symvalue)
		{
			if(func!=doset && func!=doequ && func!=domacro && !phase)
			{
				phase=1;
				phaserr();
			}
		}
	}
}

flushlist()
{
	write(listfile,listbuff,(short)(listpoint-listbuff));
	listpoint=listbuff;
}
listadvance() {while(*listpoint) ++listpoint;}

listline(toff1,ooff1,pcsave)
char *toff1;
char *ooff1;
short pcsave;
{
	char *ooff2;
	char eo,ch,lflag;
	short xpos,cnt;
	char *toff2;
	char *save;
	char buff[128];

	if(!expanding && inmac) return;

	if(listpoint>listend)
		flushlist();

	save=inpoint;
	ooff2=outoff;
	outoff=ooff1;
	lflag=0;
	while()
	{
		sprintf(listpoint,"%04x",pcsave);
		listadvance();
		xpos=5;
		eo=0;
		cnt=0;
		*listpoint++=inmac ? '+' : ' ';
		while(outoff<ooff2)
		{
			sprintf(listpoint,"%02x",*outoff++);
			listadvance();
			pcsave++;
			xpos+=2;
			cnt++;
			if(cnt==8) break;
		}
		if(!lflag)
		{
			lflag++;
			while(xpos<24) {xpos++; *listpoint++=' ';}
			toff2=inpoint;
			inpoint=toff1;
			while((ch=get())!=LF) *listpoint++=ch;
			back();
		}
		*listpoint++='\n';
		if(outoff==ooff2) break;
	}
	inpoint=save;
}




pushl(val)
long val;
{
	*(long *)exprsp=val;
	exprsp+=4;
}
pushb(val)
char val;
{
	*exprsp++=val;
}
long popl()
{
	exprsp-=4;
	return *(long *)exprsp;
}
popb()
{
	return *--exprsp;
}

rexpr()
{
char flags;
	exprsp=exprstack;
	exprflag=0;
	lastref=0;
	expr2();
	if(exprflag & 1) unbalanced();
	if(exprflag & 2) badoperation();
/*
	if(pass && exprtype==RELTYPE)
	{
		flags=((struct sym *)exprval)->symflags;
		if(flags & APUBLIC && ~flags&ADEF)
			printf("Reference to extrn %s\n",((struct sym *)exprval)->symtext);
	}
*/
}
expr()
{
	rexpr();
	if(exprtype==RELTYPE)
		exprval=((struct sym *)exprval)->symvalue+((struct sym *)exprval)->symdelta;
}
/*char opchars[]={'+','-','/','*','|','&','<<','>>','!'};*/
expr2()
{
	pushb(0);
/*
	if(at()=='-')
	{
		get();
		pushl(0L);
		pushb(ABSTYPE);
		pushb(1);
		pushb(0x10);
	}
*/
	while()
	{
		if(at()=='(')
		{
			get();
			expr2();
			if(get()!=')') {exprflag|=1;back();}
			operval=exprval;
			opertype=exprtype;
		} else operand();
		operator();
		if(trytop()) break;
		pushl(operval);
		pushb(opertype);
		pushb(opop);
		pushb(oppri);
	}
	exprval=operval;
	exprtype=opertype;
	popb();
}
trytop()
{
	char toppri,topop,toptype;
	long topval;
struct sym *sym1,*sym2;

	while()
	{
		toppri=popb();
		if(oppri>toppri) {pushb(toppri);return oppri==8;}
		topop=popb();
		toptype=popb();
		topval=popl();
		switch(topop)
		{
		case 0: /* + */
			if(toptype==RELTYPE)
			{
				((struct sym *)topval)->symdelta+=operval;
				operval=topval;
			} else if(opertype==RELTYPE)
			{
				((struct sym *)operval)->symdelta+=topval;
			} else
				operval+=topval;
			opertype=cplus[toptype][opertype];
			break;
		case 1: /* - */
			if(toptype==RELTYPE)
			{
				if(opertype==RELTYPE)
				{
					sym1=topval;sym2=operval;
					if(pass && ~sym2->symflags & ADEF && sym2->symflags & APUBLIC)
					{
						opertype=ERR;
						break;
					}
					if(sym1->symflags & APUBLIC && ~sym1->symflags & ADEF)
					{
						sym1->symdelta-=sym2->symvalue+sym2->symdelta;
						operval=sym1;
						opertype=RELTYPE;
					} else
					{
						operval=sym1->symvalue+sym1->symdelta - sym2->symvalue-sym2->symdelta;
						opertype=ABSTYPE;
					}
					break;
				}
				else
				{
					sym1=topval;
					sym1->symdelta-=operval;
					operval=sym1;
				}
			} else
				operval=topval-operval;
			opertype=cminus[toptype][opertype];
			break;
		case 2: /* / */
			opertype=cdivide[toptype][opertype];
			if(!operval) {div0();operval=1;}
			operval=topval/operval;
			break;
		case 3: /* * */
			operval*=topval;
			opertype=cnone[toptype][opertype];
			break;
		case 4: /* | */
			operval|=topval;
			opertype=cnone[toptype][opertype];
			break;
		case 5: /* & */
			operval&=topval;
			opertype=cnone[toptype][opertype];
			break;
		case 6: /* << */
			operval=topval<<operval;
			opertype=cnone[toptype][opertype];
			break;
		case 7: /* >> */
			operval=topval>>operval;
			opertype=cnone[toptype][opertype];
			break;
		case 8: return 1;
		}
		if(opertype==ERR) {opertype=ABSTYPE;exprflag|=2;}
	}
}

operator()
{
	char ch;

	ch=get();
	switch(ch)
	{
		case '+': oppri=16;opop=0;break;
		case '-': oppri=16;opop=1;break;
		case '/': oppri=24;opop=2;break;
		case '*': oppri=24;opop=3;break;
		case '|': oppri=32;opop=4;break;
		case '&': oppri=40;opop=5;break;
		case '<':
			if(get()!='<') back();
			oppri=48;opop=6;break;
		case '>':
			if(get()!='>') back();
			oppri=32;opop=7;break;
		default:
			back();oppri=8;opop=8;
	}
}

/*
+ 010
- 110
/ 218,20f
* 318
| 420
& 528
<< 630
>> 730
. , ( ) white ; 008
*/



/* fills in operval and opertype, leaves pointer on character stopped on */
operand()
{
	char ch;
	struct sym *pntr;
	char *p;

	ch=at();
	if(ch=='-')
	{
		get();
		operand();
		if(opertype==ABSTYPE) operval=-operval;
		else error2("Illegal use of unary -");
		return;
	} else if(ch=='~')
	{
		get();
		operand();
		if(opertype==ABSTYPE) operval=~operval;
		else error2("Illegal use of unary ~");
		return;
	} else if(isokfirst(ch))
	{
		token(&symbol);
		p=stext;
		ch=*p++;
		if(pntr=findsym(&symbol))
		{
			opertype=pntr->symtype;
			if(opertype==RELTYPE)
			{
				operval=pntr;
				pntr->symdelta=0;
			}
			else
				operval=pntr->symvalue;
			if(pass && !(pntr->symflags&(APUBLIC|ADEF))) unknownerr(pntr->symtext);
		} else
		{
			operval=0;opertype=RELTYPE;
			symbol.symvalue=0;
			symbol.symtype=RELTYPE;
			symbol.symnum=0xffff;
			symbol.symflags=0;
			operval=pntr=addsym(&symbol);
			pntr->symdelta=0;
			if(pass)
				unknownerr(symbol.symtext);
		}
	} else if(isoknum(ch))
	{
		operval=0;
		while(isoknum(ch=get())) {operval*=10;operval+=ch-'0';}
		opertype=ABSTYPE;
		back();
		ch=tolower(ch);
		if(ch=='h' || ch>='a' && ch<='f') error2("Old fashioned 'h' stuff");
	} else if(ch=='$')
	{
		get();
		operval=0;
		while(ishex(ch=get())) {operval<<=4;operval+=tohex(ch);}
		opertype=ABSTYPE;
		back();
	} else if(ch=='\'')
	{
		get();
		opertype=ABSTYPE;
		operval=0;
		while(ch=get())
		{
			if(ch==LF) {back();unbalancedq();break;}
			if(ch=='\'')
				if(get()!='\'') {back();break;}
			operval<<=8;operval+=ch;
		}
	} else if(ch=='*')
	{
		get();
		opertype=RELTYPE;
		operval=heresym;
		heresym->symdelta=0;
	} else
	{
		operval=0;
		opertype=NOTHING;
	}
}


char *storeline(str)
char *str;
{
char ch;
	do
	{
		ch=*str++;
		*textpoint++=ch;
	} while(ch!=10);
	return str-1;
}
endstore()
{
	*textpoint++=0;
	if((long)textpoint&1) textpoint++;
}
addword(val)
short val;
{
	*((short *)textpoint)++=val;
}
addpntr(val)
char *val;
{
	*((char **)textpoint)++=val;
}
addlong(val)
long val;
{
	*((long *)textpoint)++=val;
}
addtext(str)
char *str;
{
short len;
	len=(strlen(str)+2)&0xfffe;
	bcopy(str,textpoint,len);
	textpoint+=len;
}

predef(name,value)
char *name;
long value;
{
	strcpy(symbol2.symtext,name);
	symbol2.symtype=ABSTYPE;
	symbol2.symvalue=value;
	symbol2.symunique=0;
	symbol2.symnum=0xffff;
	symbol2.symflags=ADEF;
	if(!findsym(&symbol2)) addsym(&symbol2);
}



comma() {if(get()==',') return 0; else back();syntaxerr();return 1;}
numsign() {if(get()=='#') return 0; else back();syntaxerr();return 1;}
squote() {if(get()=='\'') return 0; else back(); return 1;}


dodcb()
{
	char ch;
	while()
	{
		ch=at();
		if(ch==LF) break;
		if(ch==',') {syntaxerr();return;}
		if(ch=='\'')
		{
			get();
			while((ch=get())!=LF)
			{
				if(ch=='\'')
				{
					if((ch=get())!='\'') break;
					bout(ch);continue;
				}
				bout(ch);
			}
			back();
		} else
		{
			expr();
			bout((char)exprval);
		}
		ch=skipwhite();
		if(ch!=',') break;
		get();
		skipwhite();
	}
}
doworddata(wo)
void (*wo)();
{
	char ch;
	while()
	{
		rexpr();
		checkref(2);
		wo((short)exprval);
		ch=skipwhite();
		if(ch!=',') break;
		get();
		skipwhite();
	}
}

dolongdata(lo)
void (*lo)();
{
	char ch;
	while()
	{
		rexpr();
		checkref(4);
		lo(exprval);
		ch=skipwhite();
		if(ch!=',') break;
		get();
		skipwhite();
	}
}

checkref(size)
short size;
{
struct sym *asym;

	if(exprtype==RELTYPE)
	{
		asym=exprval;
		exprval=asym->symvalue+asym->symdelta;
		if(pass)
			if(asym->symflags & APUBLIC && ~asym->symflags & ADEF)
				addref(asym,size,0);
			else
				addreloc(asym,size);
	}
}

void outw(),wout(),outl(),lout();

dodw() {doworddata(outw);}
dodcw() {doworddata(wout);}
dodd() {dolongdata(outl);}
dodcl() {dolongdata(lout);}



dodsb()
{
	expr();
	zeros(exprval);
}
dodsw()
{
	expr();
	zeros(exprval<<1);
}
dodsl()
{
	expr();
	zeros(exprval<<2);
}
zeros(size)
long size;
{
	if(size>MAXDB || size<0) outofrange();
	else while(size--) bout(0);
}

doalign()
{
long v1,v2;
	expr();
	v1=exprval;
	v2=pcount%v1;
	if(v2) zeros(v1-v2);
}

/* all conditionals are between setyes and setno */
setyes(){if(depth==ydepth) ++ydepth;++depth;}
doifeq(){expr();if(!exprval) setyes(); else setno();}
doifne(){expr();if(exprval) setyes(); else setno();}
doifge(){expr();if(exprval>=0) setyes(); else setno();}
doifgt(){expr();if(exprval>0) setyes(); else setno();}
doifle(){expr();if(exprval<=0) setyes(); else setno();}
doiflt(){expr();if(exprval<0) setyes(); else setno();}
doifc(){if(!cnc()) setyes(); else setno();}
doifnc(){if(cnc()) setyes(); else setno();}
doifd(){if(dnd()) setyes(); else setno();}
doifnd(){if(!dnd()) setyes(); else setno();}
doelse()
{
	if(!depth) illegalop();
	else
	{
		if(depth==ydepth) --ydepth;
		else
		if(depth==ydepth+1) ++ydepth;
	}
}
doendc(){if(!depth) illegalop();else {if(depth==ydepth) --ydepth;--depth;}}
setno(){++depth;}
/* all conditionals are between setyes and setno */
dnd()
{
	struct sym *dndsym;
	token(&symbol2);
	dndsym=findsym(&symbol2);
	if(!dndsym) return 0;

	if(!pass) return 1;

	if(dndsym->symnum < symcount) return 0;
	return 1;
}
cnc()
{
char ch;
char str1[80],str2[80];

	if(fetchstr(str1)) {syntaxerr();return 0;}
	if(comma()) return 0;
	if(fetchstr(str2)) {syntaxerr();return 0;}
	return strcmp(str1,str2);
}
fetchstr(str)
char *str;
{
char ch;
	if(squote()) return 1;
	while()
	{
		ch=get();
		if(ch==LF || ch==0) {back();return 1;}
		*str++=ch;
		if(ch!='\'') continue;
		*--str=0;break;
	}
	return 0;
}
doorg(){expr();pcount=exprval;}

dobss()
{
	struct sym *s;
	char *t;

	xrdflag=1;
	if(pass) return;
	token(&symbol2);
	s=findsym(&symbol2);
	if(s) duplicate();
	else
	{
		if(comma()) return;
		expr();
		if(exprval>1 && (blockcount&1)) blockcount++;
		blockcount+=exprval;
		symbol2.symvalue=-blockcount;
		symbol2.symtype=XREFTYPE;
		symbol2.symnum=symcount;
		symbol2.symflags=0;
		s=addsym(&symbol2);
		t=blockhead;
		blockhead=textpoint;
		addpntr(t);
		addpntr(s);
	}
}

dopublic()
{
struct sym *s;
	if(pass) return;
	while()
	{
		skipwhite();
		token(&symbol2);
		s=findsym(&symbol2);
		if(s)
		{
			if(~s->symflags & APUBLIC)
			{
				s->symflags|=APUBLIC;
				s->sympublic=publichead;
				publichead=s;
			}
		} else
		{
			symbol2.symvalue=0;
			symbol2.symtype=RELTYPE;
			symbol2.symnum=symcount;
			symbol2.symflags=APUBLIC;
			s=addsym(&symbol2);
			s->sympublic=publichead;
			publichead=s;
		}
/*
		if(skipwhite()==':')
		{
			get();
			skipwhite();
			while(isoksym(at())) get();
		}
*/
		if(skipwhite()!=',') break;
		get();
	}
}

doendm(){;}
domacro()
{
	struct sym *pntr;

	storing++;
	if(pass) return;
	pntr=findsym(&linelabel);
	pntr->symtype=MACTYPE;
	pntr->symvalue=textpoint;
}
doexpon(){expanding=1;}
doexpoff(){expanding=0;}
doinclude()
{
char	iname[80];
char	namesave[80];
short linesave;
short	macsave;
char *pntr,ch,*p2;
short	sfile;
char *save;
char *env;

	if(numopen==MAXIN) {error("Too many nested includes");return;}

	ch=at();
	if(ch!='\'' && ch!='"') {syntaxerr();return;}
	get();
	pntr=iname;
	while()
	{
		ch=get();if(ch==LF) {back();break;}
		if(ch=='\'' || ch=='"' || iswhite(ch)) break;
		*pntr++=ch;
	}
	*pntr=0;
	sfile=fopen(iname,TREAD);
	if(!sfile)
	{
		if(env=findenv(INCNAME))
		{
			strcpy(namesave,iname);
			pntr=env;
			while(*pntr)
			{
				p2=iname;
				while(*pntr && *pntr!=';') *p2++=*pntr++;
				if(*pntr) pntr++;
				*p2=0;
				strcat(iname,namesave);
				if(sfile=fopen(iname,TREAD)) break;
			}
		}
		if(!sfile)
			{error("Cannot open file");return;}
	}
	fclose(sfile);
	strcpy(namesave,filename);
	strcpy(filename,iname);
	linesave=cline;

	save=inpoint;
	macsave=macstack;
	dofile();
	macstack=macsave;
	inpoint=save;
	strcpy(filename,namesave);
	cline=linesave;
}

donds()
{
	token(&symbol2);
	if(comma()) return;
	expr();
	soffset-=exprval;
	symbol2.symvalue=soffset;
	symbol2.symtype=ABSTYPE;
	symbol2.symflags=0;
	if(findsym(&symbol2))
		{if(!pass) duplicate();}
	else
		addsym(&symbol2);
}
domds()
{
	token(&symbol2);
	if(comma()) return;
	expr();
	symbol2.symvalue=soffset;
	soffset+=exprval;
	symbol2.symtype=ABSTYPE;
	symbol2.symflags=0;
	if(findsym(&symbol2))
		{if(!pass) duplicate();}
	else
		addsym(&symbol2);
}

dostructure()
{
	token(&symbol2);
	if(comma()) return;
	expr();
	soffset=exprval;
}


doinit()
{
	expr();
	soffset=exprval;
}
dolabel() {varsize(0);}
dobyte() {varsize(1);}
doword() {varsize(2);}
dolong() {varsize(4);}

varsize(size)
short size;
{
	token(&symbol2);
	symbol2.symvalue=soffset;
	soffset+=size;
	symbol2.symtype=ABSTYPE;
	symbol2.symflags=ADEF;
	symbol2.symunique=0;
	symbol2.symnum=0xffff;
	symbol2.symref=0;
	symbol2.sympublic=0;
	if(findsym(&symbol2))
		{if(!pass) duplicate();}
	else
		addsym(&symbol2);
}

doset()
{
	struct sym *pntr;

	expr();
	pntr=findsym(&linelabel);
	pntr->symtype=exprtype;
	pntr->symvalue=exprval;
}

doequ()
{
	struct sym *pntr;

	expr();
	pntr=findsym(&linelabel);
	pntr->symtype=exprtype;
	if(pass && pntr->symvalue!=exprval) phaserr();
	pntr->symvalue=exprval;
}

doeven() {if(pcount&1) bout(0);}
dosteven() {if(soffset&1) soffset++;}

headout()
{
	long temp;
	char *p1,*p2,ch,txt[80];
	short t;

	temp=pcmax;
	if(!xrdflag)
	{
		lout(0x3f3L);
		lout(0L);
		lout(1L);
		lout(0L);
		lout(0L);
		lout(temp>>2);
	}
/*
	else
	{
		lout(0x3e7L);
		strcpy(txt,origname);
		strcat(txt,".o");
		p2=txt;
		while(*p2) p2++;
		while(p2>txt)
		{
			ch=*--p2;
			if(ch!='/' && ch!=':' && ch!='\\') continue;
			++p2;break;
		}
		p1=p2;
		while(*p1) p1++;
		while((p1-p2)&3) *p1++=0;
		t=p1-p2;
		lout((long)t>>2);
		p1=p2;
		while(t--) bout(*p1++);
	}
*/
	lout(0x3e9L);
	lout(temp>>2);
}
tailout(){lout(0x3f2L);} /* hunk_end */
symsout()
{
	short i,j;
	char ch;
	struct sym *pntr;
	short p2;

	lout(0x3f0L);
	for(i=0;i<256;i++)
	{
		pntr=headers[i];
		while(pntr)
		{
			if(pntr->symtype==RELTYPE && !pntr->symunique)
			{
				symout(pntr->symtext,0);
				lout(pntr->symvalue);
			}
			pntr=pntr->symnext;
		}
	}
	lout(0L);
}

symout(s,d)
char *s;
short d;
{
short j;
char text[80],*p,ch;

	p=text;
	while(ch=*s++) *p++=ch;
	while((p-text)&3) *p++=0;
	j=p-text;
	p=text;
	bout(d);
	wout(0);
	bout(j>>2);
	while(j--) bout(*p++);
}

/* type=0 for ref, !=0 for rel */
addref(asym,size,type)
struct sym *asym;
short size,type;
{
char *t;
	t=textpoint;
	addpntr(asym->symref);
	asym->symref=t;
	addlong(pcount);
	if(type) size|=8;
	addword(size);
}
addreloc(asym,size)
struct sym *asym;
short size;
{
char *t;
	t=textpoint;
	if(size==2)
	{
		addpntr(reloc16head);
		addpntr(pcount);
		addword(2);
		reloc16head=t;
		++reloc16num;
	} else
	{
		addpntr(reloc32head);
		addpntr(pcount);
		addword(4);
		reloc32head=t;
		++reloc32num;
	}
}
outrelocs()
{
	outreloclist(0x3cd,reloc16head,reloc16num);
	outreloclist(0x3cc,reloc32head,reloc32num);
}
outreloclist(hunktype,head,num)
struct reference *head;
short num,hunktype;
{
	if(!num) return;
	lout((long)hunktype);
	lout((long)num);
	lout(0L);
	while(head)
	{
		lout(head->refoff);
		head=head->refnext;
	}
	lout(0L);
}



outpublics()
{
struct sym *asym;
struct reference *aref,*ref2,*t;
short count,type;
char exttype;

	if(!publichead) return;
	lout(0x3efL); /* hunk_ext */
	asym=publichead;
	while(asym)
	{

		if(asym->symflags & ADEF)
		{
			symout(asym->symtext,1);
			lout(asym->symvalue);
		}
		asym=asym->sympublic;
	}
	asym=publichead;
	while(asym)
	{
		if(~asym->symflags & ADEF)
		{
			while(aref=asym->symref)
			{
				type=aref->reftype;
				count=0;
				while(aref)
				{
					if(aref->reftype==type) count++;
					aref=aref->refnext;
				}

				exttype= (type&7)==2 ? 0x93 : 0x91;
				if(type&8) exttype+=8;
				symout(asym->symtext,exttype); /* 16ref & 32ref */
				lout((long)count);
				ref2=0;
				aref=asym->symref;
				while(aref)
				{
					t=aref;
					aref=aref->refnext;
					if(t->reftype==type) lout(t->refoff);
					else
					{
						t->refnext=ref2;
						ref2=t;
					}
				}
				asym->symref=ref2;
			}
		}
		asym=asym->sympublic;
	}
	lout(0L);
}


donothing() {}

struct anopcode directs[]={
"align",doalign,
"aptr",dolong,
"bool",doword,
"bptr",dolong,
"bss",dobss,
"byte",dobyte,
"cptr",doword,
"dc",dodcw,
"dc.b",dodcb,
"dc.l",dodcl,
"dc.w",dodcw,
"dd",dodd,
"ds",dodsw,
"ds.b",dodsb,
"ds.l",dodsl,
"ds.w",dodsw,
"dw",dodw,
"else",doelse,
"end",donothing,
"endc",doendc,
"endm",doendm,
"equ",doequ,
"even",doeven,
"expoff",doexpoff,
"expon",doexpon,
"fail",failerr,
"float",dolong,
"if",doifne,
"ifc",doifc,
"ifd",doifd,
"ifeq",doifeq,
"ifge",doifge,
"ifgt",doifgt,
"ifle",doifle,
"iflt",doiflt,
"ifnc",doifnc,
"ifnd",doifnd,
"ifne",doifne,
"include",doinclude,
"init",doinit,
"label",dolabel,
"long",dolong,
"m68000",dom68000,
"macro",domacro,
"mds",domds,
"nds",donds,
"org",doorg,
"public",dopublic,
"rptr",dolong,
"set",doset,
"short",doword,
"steven",dosteven,
"struct",domds,
"structure",dostructure,
"ubyte",dobyte,
"ulong",dolong,
"ushort",doword,
"uword",doword,
"word",doword,
"x86",dox86,
"z80",doz80,
0};



#ifdef USEHIGH
short (*scan(code,list))()
char *code;
struct oplist *list;
{
struct anopcode *op;
struct anopcode *table;
short num,power;
short way,n;

	table=list->listopcodes;
	num=list->numops;
	power=list->powerops;
	n=power-1;
	op=table+n;
	while()
	{
		power>>=1;
		if(n>=num) way=-1;
		else
			if(!(way=strcmp(code,op->opcodename))) return op->opcodehandler;
		if(!power) return 0;
		if(way<0) {op-=power;n-=power;}
		else {op+=power;n+=power;}
	}
}
lout(val)
long val;
{
	wout((short)(val>>16));
	wout((short)val);
}
outw(val)
short val;
{
	bout(val);
	bout(val>>8);
}
wout(val)
short val;
{
	bout(val>>8);
	bout(val);
}
bout(val)
char val;
{
	*outoff++=val;
	pcount++;
	pcmax++;
}

struct sym *findsym(asym)
struct sym *asym;
{
	struct sym *pntr;
	char *p;

	p=asym->symtext;
	pntr=headers[hash8(p)];
	while(pntr && strcmp(pntr->symtext,p))
		pntr=pntr->symnext;
	return pntr;
}
token(asym)
struct sym *asym;
{
	char *pntr,endch;
	pntr=asym->symtext;
	while(isoksym(endch=get()))
		*pntr++=endch;
	*pntr=0;
	return back();
}
gather(str)
char *str;
{
	char ch;
	while(isokop(ch=get())) *str++=ch;
	*str=0;
	return back();
}
skipwhite()
{
	while(iswhite(get()));
	return back();
}
#else
#asm

_removecr:
	mov	esi,[esp+4]
	mov	edi,esi
	mov	bl,13
rcrlp:
	lodsb
	or	al,al
	jz	short rcrdone
	cmp	al,bl
	jz	short rcrlp
	stosb
	jmp	short rcrlp
rcrdone:
	stosb
	ret

	public	_removecr


	public	_inpoint

_skipwhite:
	mov	esi,_inpoint
swlp:
	lodsb
	cmp	al,9
	jz	short swlp
	cmp	al,' '
	jz	short swlp
	dec	esi
	mov	_inpoint,esi
	movzx	eax,al
	ret

	public _skipwhite,_attr

_token:
	mov	edi,[esp+4]
	mov	edi,[edi] ;symtext at offset 0
	mov	esi,_inpoint
	xor	eax,eax
	mov	ebx,offset _attr
tokenlp:
	lodsb
	test	byte [ebx+eax],2 ;attrsym
	jz	short tokendone
	stosb
	jmp	short tokenlp
tokendone:
	dec	esi
	mov	_inpoint,esi
	mov	[edi],ah
	ret
	public _token

_gather:
	mov	edi,[esp+4]
	mov	esi,_inpoint
	xor	eax,eax
	mov	ebx,offset _attr
gatherlp:
	lodsb
	test	byte [ebx+eax],8 ;attrop
	jz	short gatherdone
	stosb
	jmp	short gatherlp
gatherdone:
	dec	esi
	mov	_inpoint,esi
	mov	[edi],ah
	ret
	public _gather

	public	_hash8,_headers
_findsym:
	mov	esi,[esp+4]
	mov	esi,[esi]
	push	esi esi
	call	_hash8
	add	esp,4
	shl	eax,2
	add	eax,long _headers
	mov	eax,[eax]
	pop	ebx
	xor	edx,edx
findsymlp:
	or	eax,eax
	jz	short fsdone
	mov	esi,[eax]
	mov	edi,ebx
fscomp:
	cmpsb
	jnz	short fsnext
	cmp	dl,[esi-1]
	jnz	short fscomp
	jmp	short fsdone
fsnext:
	mov	eax,[eax+4]
	jmp	short findsymlp
fsdone:
	ret
	public	_findsym

	public	_pcmax,_outoff,_pcount

_bout:
	inc	long _pcmax
	inc	long _pcount
	mov	edi,_outoff
	mov	al,[esp+4]
	stosb
	mov	_outoff,edi
	ret
_wout:
	add	long _pcmax,2
	add	long _pcount,2
	mov	edi,_outoff
	mov	ax,[esp+4]
	xchg	ah,al
	stosw
	mov	_outoff,edi
	ret
_outw:
	add	long _pcmax,2
	add	long _pcount,2
	mov	edi,_outoff
	mov	ax,[esp+4]
	stosw
	mov	_outoff,edi
	ret
_lout:
	add	long _pcmax,4
	add	long _pcount,4
	mov	edi,_outoff
	mov	ax,[esp+6]
	xchg	ah,al
	stosw
	mov	ax,[esp+4]
	xchg	ah,al
	stosw
	mov	_outoff,edi
	ret
_outl:
	add	long _pcmax,4
	add	long _pcount,4
	mov	edi,_outoff
	mov	eax,[esp+4]
	stosd
	mov	_outoff,edi
	ret


;  scan(char *, struct oplist *);
;  oplist = struct anopcode *listopcodes;int numops,powerops;
_scan:
	mov	ebx,[esp+4] ;string
	mov	esi,[esp+8]
	mov	eax,[esi] ;table
	movzx	edx,word [esi+4] ;numops
	movzx	ecx,word [esi+6] ;powerops
	shl	edx,3
	shl	ecx,3
	add	edx,eax
	add	eax,ecx
	sub	eax,8
scanlp:
	shr	ecx,1
	cmp	eax,edx
	jnc	short takeleft
	mov	esi,ebx
	mov	edi,[eax]
scancomp:
	cmpsb
	jc	short takeleft
	jnz	short takeright
	cmp	byte [esi-1],0
	jnz	short scancomp
	mov	eax,[eax+4]
	ret
takeleft:
	cmp	ecx,8
	jc	short scanfail
	sub	eax,ecx
	jmp	short scanlp
takeright:
	cmp	ecx,8
	jc	short scanfail
	add	eax,ecx
	jmp	short scanlp
scanfail:
	xor	eax,eax
	ret

	public	_bout
	public	_wout,_outw
	public	_lout,_outl
	public	_scan
#endasm
#endif
