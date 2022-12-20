#include "comp.h"

typedef struct aswitch
{
	short asval;
	short aslabel;
} *swptr;

#define IOBUFFLEN 4096
#define INMAX 6
#define MACMAX 8
#define BLOCKSIZE 0x6000
#define TEXTMAX 100000L
#define SWITCHMAX 10000
#define NESTMAX 64
#define INCNAME "accdir"

char *textbase=0,*texttop;
extern long himembase;

char **symtextblocks=0,*symtextpntr,*symtexttop;
char **symblocks=0;
short newsymsleft;
symptr usedsymlist,nextnewsym;
short usedsymnum;
char retval;

char *macroblock,*macrostack;

char **thingblocks=0;
short newthingsleft;
thingptr usedthinglist,nextnewthing;
short usedthingnum;

char **enodeblocks=0;
short newenodesleft;
enodeptr usedenodelist,nextnewenode;
short usedenodenum;

char **stringblocks=0;
short newstringsleft;
stringptr usedstringlist,nextnewstring;
short usedstringnum;

short sdefault=0;
unsigned short switchnum=0;

swptr switchblock,nextswitch,switchstack[NESTMAX];
short switchsp,switchnumstack[NESTMAX],switchdefaultstack[NESTMAX];

char *ststart,*topoint;

char col1,preok;
char *preproc;

char *macstack[MACMAX],*macp,*macfrees[MACMAX];
short macsp;

struct ifile
{
	char inbuff[IOBUFFLEN];
	short infile;
	char inname[64];
	unsigned short inleft;
	char *inpoint;
	unsigned short lc;
} *ifiles,*ifp;

char *outbuff;
char *outpoint;
short outhold=0;
short incount;
short outfile;
short tabc;
#define LINEMAX 80
char *pntr;
thingptr vartype;

char *regnames[]={
"","","","","","","","",
"al","bl","dl","cl","","","","",
"ax","bx","dx","cx","","","","",
"","","","","","","","",
"eax","ebx","edx","ecx","","","",""};
#define NUMREGS 4
short regfree;
char regmap[NUMREGS];
char allocregdat[1<<NUMREGS];
short numkeywords,nkwpower;
short facount,fpnum;
short success,failure,lfollow;
char numbytes[16];
thingptr lastfunc;
char lastfuncname[64];
thingptr intthing,longthing;
#define MAXLBITS 32768
char *labelbits1=0,*labelbits2=0;
char *labelbase=0;
short labelnumbase=0;
symptr *globals=0,*autos=0,*ndefs=0,*structs=0,*members=0,*typedefs=0;

thingptr paramlist[MAXPARAMS];
char opflags[128];
short infolens[16];
symptr firststring,laststring;
unsigned short breakstack[NESTMAX],contstack[NESTMAX],*breaksp,*contsp;
char insidefunc;
char *sizenames[]={"offset","byte","word","","long"};
char *opnames[]={"add","sub","imul","idiv","and","or","xor"};
unsigned short curfuncret;
char typeflags[16];


void outstr(),outch();
short realreg(reg);
short take1();

checkparmok(ath)
thingptr ath;
{
	if(*ath->thinginfo)
		error("Parameter list not allowed in this position");
}
thingptr newdeclid(name)
char *name;
{
thingptr ath;
symptr asym;

	asym=findsym(name);
	if(!asym)
	{
		asym=newsym(name);
		ath=allocthing();
		asym->symthing=ath;
		ath->thingsym=asym;
		return ath;
	} else
	{
		ath=asym->symthing;
		if(*ath->thinginfo)
		{
			ath=allocthing();
			asym=newsym(name);
			ath->thingsym=asym;
			asym->symthing=ath;
		}
		return ath;
	}
}
thingptr newid(name)
char *name;
{
symptr asym;
thingptr ath;

	if(asym=findsym(name))
		return dupthing(asym->symthing);
	ath=allocthing();
	asym=newsym(name);
	asym->symthing=ath;
	ath->thingsym=asym;
	return ath;
}

outpublics()
{
short i;
symptr *sp,asym;
thingptr ath;
short flags;

	sp=globals;
	i=256;
	while(i--)
	{
		asym=*sp++;
		while(asym)
		{
			ath=asym->symthing;
			flags=ath->thingflags;
			if(!(flags & (THINGSTATIC | THINGTYPEDEF | THINGQUIET)))
			{
				outstr(" public _");
				outstr(asym->symname);
				outch('\n');
			}
			asym=asym->symnext;
		}
	}
	outstr(" public doswitch\n");
}
extern long all;
funcstart(v1,v2)
thingptr v1,v2;
{
short i,j,k;
thingptr ath;
thingptr *p;

	lastfunc=v1;
	appendthing(v1,v2);
	v1->thingflags |= THINGFUNC;
	declare(v1);
	sprintf(lastfuncname,"_%s",v1->thingsym->symname);
	curfuncret=alloclabel();
	facount=0;
	j=8;
	p=paramlist;
	i=fpnum;
	while(i--)
	{
		ath=*p++;
		k=ath->thingvalue;
		if(k==-1)
		{
			appendthing(ath,intthing);
			insdeclare(ath);
			k=ath->thingvalue;
		}
		ath->thingvalue=j;
		j+=k;
	}
	insidefunc=1;
}
funcend()
{
	fpnum=0;
	insidefunc=0;
}

newparm(name)
char *name;
{
symptr asym;
thingptr ath;

	asym=findauto(name);
	if(asym) redef();
	else
	{
		asym=newsym(name);
		ath=allocthing();
		ath->thingsym=asym;
		asym->symthing=ath;
		ath->thingflags=THINGAUTO | THINGPASSED | THINGOUTSIDE;
		ath->thingvalue=-1;
		addauto(asym);
		if(fpnum<MAXPARAMS)
			paramlist[fpnum++]=ath;
		else
			critical("Paramlist overflow");
	}
}
ansidec(v1,v2)
thingptr v1,v2;
{
symptr asym;

	appendthing(v1,v2);
	freething(v2);

	asym=findauto(v1->thingsym->symname);
	if(asym) {redef();freesym(v1->thingsym);}
	else
	{
		v1->thingflags|=THINGAUTO | THINGPASSED | THINGOUTSIDE;
		v1->thingvalue=-1;
		addauto(v1->thingsym);
		insdeclare(v1);
		if(fpnum<MAXPARAMS)
			paramlist[fpnum++]=v1;
		else
			critical("Paramlist overflow");
	}
}

dumpstring(sp,prstr,prch)
char *sp;
void (*prstr)(),(*prch)();
{
short i,ch,mode;
char txt[16];
char *spstart;

	spstart=sp;
	i=0;
	do
	{
		if(!i) {prstr(" db ");i+=4;mode=0;}
		ch=*sp++;
		if(mode==2) {prch(',');i++;}
		if(ch<32 || ch>127 || ch=='\'')
		{
			if(mode==1) {prstr("',");i+=2;}
			sprintf(txt,"%d",ch);
			prstr(txt);i+=strlen(txt);
			mode=2;
		} else
		{
			if(mode!=1) {prch('\'');i++;}
			prch(ch);i++;
			mode=1;
		}
		if(i>60) {if(mode==1) prch('\'');prch('\n');i=0;}
	} while(ch);
	if(i) prch('\n');
	return sp-spstart;
}


dumpstrings()
{
symptr asym;
char *sp;

	while(firststring)
	{
		asym=firststring->stringsym;
		sp=firststring->stringtext;
		if(sp)
		{
			outstr(asym->symname);
			outch(':');
			dumpstring(sp,outstr,outch);
		}
		freesym(asym);
		sp=firststring;
		firststring=firststring->stringnext;
		freestring(sp);
	}
}


outfunc(str)
TEXT str;
{
	dumpstrings();
	emit(lastfuncname);
	emit(":\n");
	if(facount || fpnum)
	{
		emit(" push ebp\n mov ebp,esp\n");
		if(facount)
		{
			emit(" sub esp,");
			emitdec(-facount);
			emitcr();
		}
	}
	emitsub(str);
	qemitlabel(curfuncret);
	if(facount || fpnum)
		emit(" mov esp,ebp\n pop ebp\n");
	emit(" ret\n");
	dumptext(newstmt());
	freeautos();
	funcend();
}


thingptr appendthing(v1,v2)
thingptr v1,v2;
{
short i;
char *p1,*p2,*p3;
	v1->thingflags |= v2->thingflags;

	p1=infotail(v1);
	p2=infotail(v2);
	p3=v2->thinginfo;
	while(p3<p2) *p1++=*p3++;
	return v1;
}
cast(v1,v2)
thingptr v1,v2;
{
	bcopy(v2->thinginfo,v1->thinginfo,INFOLEN);
}

char *infotail(v1)
thingptr v1;
{
char *p;
short len;

	p=v1->thinginfo;
	while(*p) p+=infolens[*p];

	return p;
}

thingptr append(athing,what)
thingptr athing;
short what;
{
	*infotail(athing)=what;
	return athing;
}
thingptr appendarray(athing,val)
thingptr athing;
long val;
{
char *p;

	p=infotail(athing);
	*p++=ARRAYOF;
	*(long *)p=val;
	return athing;
}
enodeptr enode1(v0,v1)
short v0;
enodeptr v1;
{
enodeptr en;
thingptr th1;

	if(v1->enodetype==ENTHING)
	{
		th1=v1->enodeo1;
		if(th1->thingtype==THINGCONST)
		{
			v1->enodeo1=constop1(v0,th1);
			return v1;
		}
	}
	en=enalloc();
	en->enodetype=v0;
	en->enodeo1=v1;
	return en;
}
enodeptr enode2(v0,v1,v2)
short v0;
enodeptr v1,v2;
{
enodeptr en;
thingptr th1,th2;

	if(v1->enodetype==ENTHING && v2->enodetype==ENTHING)
	{
		th1=v1->enodeo1;
		th2=v2->enodeo1;
		if(th1->thingtype==THINGCONST && th2->thingtype==THINGCONST && v0!=ENCOMMA)
		{
			th1=constop2(v0,th1,th2);
			enfree(v2);
			v1->enodeo1=th1;
			return v1;
		}
	}

	en=enalloc();
	en->enodetype=v0;
	en->enodeo1=v1;
	en->enodeo2=v2;
	return en;
}
enodeptr enode3(v0,v1,v2,v3)
short v0;
enodeptr v1,v2,v3;
{
enodeptr en;

	en=enalloc();
	en->enodetype=v0;
	en->enodeo1=v1;
	en->enodeo2=v2;
	en->enodeo3=v3;
	return en;
}



short pushregs()
{
short i,oldregused;

	oldregused=regfree;
	if(regfree)
	{
		i=0;
		emit(" push");
		while(regfree)
		{
			if(regfree & 1)
			{
				emitch(' ');
				emitreg(i+32);
			}
			regfree>>=1;
			i++;
		}
		emitcr();
	}
	return oldregused;
}
popregs(mask)
short mask;
{
short i;

	if(mask)
	{
		regfree |=mask;
		i=5;
		emit(" pop");
		while(i>=0)
		{
			if(mask&32)
			{
				emitch(' ');
				emitreg(i+32);
			}
			mask+=mask;
			i--;
		}
		emitcr();
	}
}

allocregmask(mask)
short mask;
{
short i;
	mask|=regfree;
	i=allocregdat[mask];
	if(i<NUMREGS)
	{
		regfree |= bits[i];
		return i;
	}
	error("Ran out of registers in allocregmask");
	return -1;
}
allocregn(num)
short num;
{
short i;
	i=bits[num];
	if(regfree & i)
	{
		error("allocregn failure");
		num=-1;
	}
	else
	{
		regfree|=i;
	}
	return num;
}
allocreg()
{
short i;
	i=allocregdat[regfree];
	if(i<NUMREGS)
	{
		regfree |= bits[i];
		return i;
	}
	error("Ran out of registers");
	return -1;
}
freereg(regnum)
short regnum;
{
	regfree &= ~bits[regnum];
}

thingptr dupfix(v1,v2)
thingptr v1;
short v2;
{
thingptr ath;

	ath=dupthing(v1);
	ath->thingflags &= ~(THINGQUIET | THINGTYPEDEF);
	ath->thingflags |= v2;
	return ath;
}

thingptr dupthing(athing)
thingptr athing;
{
thingptr athing2;

	athing2=allocthing();
	fcopy(athing,athing2,sizeof(struct thing));
	return athing2;
}


thingptr alloccast()
{
thingptr th;
	th=allocthing();
	th->thingtype=THINGCAST;
	return th;
}

thingptr allocthing()
{
thingptr ath;

	if(usedthinglist)
	{
		ath=usedthinglist;
		usedthinglist=usedthinglist->thingnext;
	} else
	{
		ath=nextnewthing++;
		if(!--usedthingnum) newthingblock();
	}
	clearmem(ath,sizeof(struct thing));
	return ath;
}
freething(athing)
thingptr athing;
{

	if(!athing) return;
	if(athing->thingtype==THINGREGISTER)
	{
		freereg(athing->thingreg);
	}
	athing->thingnext=usedthinglist;
	usedthinglist=athing;
}

stringptr allocstring()
{
stringptr str;
	if(usedstringlist)
	{
		str=usedstringlist;
		usedstringlist=usedstringlist->stringnext;
	} else
	{
		str=nextnewstring++;
		if(!--usedstringnum) newstringblock();
	}
	return str;
}
freestring(astring)
stringptr astring;
{

	if(!astring) return;
	astring->stringnext=usedstringlist;
	usedstringlist=astring;
}

enodeptr enalloc()
{
enodeptr en;
	if(usedenodelist)
	{
		en=usedenodelist;
		usedenodelist=usedenodelist->enodeo1;
	} else
	{
		en=nextnewenode++;
		if(!--usedenodenum) newenodeblock();
	}
	clearmem(en,sizeof(struct enode));
	return en;
}

enfree(en)
enodeptr en;
{
	en->enodeo1=usedenodelist;
	usedenodelist=en;
}



thingptr findmember(name)
char *name;
{
short h;
symptr asym;

	h=hash8(name);

	asym=members[h];
	while(asym)
	{
		if(!strcmp(name,asym->symname)) break;
		asym=asym->symnext;
	}
	if(asym) return dupthing(asym->symthing);
	return NULL;
}
thingptr findtypedef(name)
char *name;
{
short h;
symptr asym;

	h=hash8(name);

	asym=typedefs[h];
	while(asym)
	{
		if(!strcmp(name,asym->symname)) break;
		asym=asym->symnext;
	}
	if(asym) return asym->symthing;
	return NULL;
}

symptr findstruct(name)
char *name;
{
short h;
symptr asym;

	h=hash8(name);

	asym=structs[h];
	while(asym)
	{
		if(!strcmp(name,asym->symname)) break;
		asym=asym->symnext;
	}
	return asym;
}

symptr findsym(name)
char *name;
{
short h;
symptr asym;

	h=hash8(name);

	asym=autos[h];
	while(asym)
	{
		if(!strcmp(name,asym->symname)) return asym;
		asym=asym->symnext;
	}
	asym=globals[h];
	while(asym)
	{
		if(!strcmp(name,asym->symname)) return asym;
		asym=asym->symnext;
	}
	return 0;
}
symptr findauto(name)
char *name;
{
short h;
symptr asym;
	h=hash8(name);

	asym=autos[h];
	while(asym)
	{
		if(!strcmp(name,asym->symname)) break;
		asym=asym->symnext;
	}
	return asym;
}

symptr newsym(name)
char *name;
{
struct sym *asym;

	if(usedsymlist)
	{
		asym=usedsymlist;
		usedsymlist=usedsymlist->symnext;
	} else
	{
		asym=nextnewsym++;
		if(!--newsymsleft) newsymblock();
	}

	asym->symnext=0;
	asym->symthing=0;
	asym->symname=name;

	return asym;
}
freesym(asym)
struct sym *asym;
{
thingptr athing;
	athing=asym->symthing;
	if(athing) freething(athing);
	asym->symnext=usedsymlist;
	usedsymlist=asym;
}




addtypedef(asym)
struct sym *asym;
{
short h;

	h=hash8(asym->symname);
	asym->symnext=typedefs[h];
	typedefs[h]=asym;
}
addstruct(asym)
struct sym *asym;
{
short h;

	h=hash8(asym->symname);
	asym->symnext=structs[h];
	structs[h]=asym;
}
addmember(asym)
struct sym *asym;
{
short h;

	h=hash8(asym->symname);
	asym->symnext=members[h];
	members[h]=asym;
}
addauto(asym)
struct sym *asym;
{
short h;

	h=hash8(asym->symname);
	asym->symnext=autos[h];
	autos[h]=asym;
}
addglobal(asym)
struct sym *asym;
{
short h;

	h=hash8(asym->symname);
	asym->symnext=globals[h];
	globals[h]=asym;
}
freeautos()
{
short i;
struct sym **p,*asym,*asym2;

	i=256;
	p=autos;
	while(i--)
	{
		asym=*p;
		*p++=0;
		while(asym)
		{
			asym2=asym;
			asym=asym->symnext;
			freesym(asym2);
		}
	}
}


list(athing)
thingptr athing;
{
char *p,ch;
struct sym *asym;
unsigned short j;
char str[64];
short flags;
long ar;

	printf("(%lx)",athing);
	p=athing->thinginfo;
	flags=athing->thingflags;
	if(flags & THINGTYPEDEF) printf("typedef ");
	if(flags & THINGFLREGISTER) printf("register ");
	if(flags & THINGAUTO) printf("auto ");
	if(flags & THINGEXTERN) printf("extern ");
	if(flags & THINGIND) printf("IND ");
	if(athing->thingtype==THINGCONST)
		printf("%ld is constant ",athing->thingvalue);
	else
	{
		if(athing->thingtype==THINGVARIABLE)
			printf("%s is ",athing->thingsym->symname);
		else if(athing->thingtype==THINGREGISTER)
		{
			ch=numbytes[*p];
			if(!ch) ch=4;
			printf("%s is ",regnames[regmap[athing->thingreg] + (ch<<3)]);
		} else printf("<undef>%s is ",athing->thingsym->symname);
	}
	while()
	{
		ch=*p++;
		switch(ch)
		{
		case 0:
			printf("undefined\n");
			break;
		case FUNCTIONRET:
			printf("function returning ");
			continue;
		case ARRAYOF:
			ar=*((long *)p)++;
			printf("array of %ld ",ar);
			continue;
		case POINTERTO:
			printf("pointer to ");
			continue;
		case TYPESHORT: printf("short\n");break;
		case TYPECHAR:  printf("char\n");break;
		case TYPELONG:  printf("long\n");break;
		case TYPEVOID:
			printf("void\n");
			break;
		case TYPEFLOAT:
			printf("float\n");
			break;
		case TYPEDOUBLE:
			printf("double\n");
			break;
		case TYPEMEMBER:
			ar=*((long *)p)++;
			printf("member:%ld ",ar);
			continue;
		case ASTRUCT: printf("struct\n");break;
		}
		break;
	}
}
long getscale(v1)
thingptr v1;
{
char *p,ch;
long size,ar;
short num=0;

	p=v1->thinginfo;
	if(typeflags[*p]&FARRITH) return 1;
	if(*p==POINTERTO) p++,num++;
	if(!*p) return 0;
	size=1;
	while(*p==ARRAYOF)
	{
		p++;
		ar=*((long *)p)++;
		if(num) size*=ar;
		else num++;
	}
	if(*p==ASTRUCT)
	{
		p++;
		size*=*(long *)p;
		return size;
	}
	ch=numbytes[*p];
	if(size>1) return size*ch;
	else return ch;
}
long getsize(v1)
thingptr v1;
{
char *p,ch;
long size;

	p=v1->thinginfo;
	if(!(ch=*p)) return 0;
	size=1;
	if(ch==TYPEMEMBER) p+=5;
	while(*p==ARRAYOF)
	{
		p++;
		size*=*((long *)p)++;
	}
	if(*p==ASTRUCT)
	{
		p++;
		size*=*(long *)p;
		return size;
	}
	if(ch=numbytes[*p])
		return size*ch;
	error("Illegal attempt to compute size");
	return 0;
}

short compthings(v1,v2)
thingptr v1,v2;
{
char *p1,*p2,t1,t2;
short i,ac,len;

	p1=v1->thinginfo;
	p2=v2->thinginfo;
	ac=0;
	while()
	{
		t1=*p1++;
		t2=*p2++;
		if(t1!=t2) return 1;
		if(!t1) break;
		len=infolens[t1]-1;
		if(t1==ARRAYOF)
		{
			if(!ac++)
			{
				p1+=len;
				p2+=len;
				continue;
			}
		}
		while(len--)
			if(*p1++!=*p2++) return 2;
	}
/*      i=v1->thingflags ^ v2->thingflags;
	if(i & ~THINGEXTERN) return 3;*/
	return 0;
}

thingptr def(op,v1,v2)
short op;
thingptr v1,v2;
{
char t1,i1,s1,s2,i2;
char isarray;
char name1[64],name2[64];
char txt[64];
char *optxt;
thingptr v3=0;
char fl;

	t1=v1->thingtype;
	i1=*v1->thinginfo;
	if(t1!=THINGVARIABLE && (t1!=THINGREGISTER || t1==THINGREGISTER && ~v1->thingflags & THINGIND)
		|| i1==FUNCTIONRET || i1==ARRAYOF || v1->thingflags&THINGADDROF)
		error("Crazy assignment");
	else
	{
		switch(op)
		{
		case ENADDEQ:
		case ENSUBEQ:
			optxt= op==ENADDEQ ? "add" : "sub";
			if(i1==POINTERTO)
				v2=scale(v2,v1);
			break;
		case ENANDEQ:optxt="and";break;
		case ENOREQ:optxt="or";break;
		case ENXOREQ:optxt="xor";break;
		case ENMULEQ:optxt="imul";v3=v1;v1=copytoreg(v1);break;
		case ENDEF:optxt="mov";break;
		case ENRREQ:v2=tocx(v2);optxt=v1->thingflags&THINGUNSIGNED ? "shr" : "sar";break;
		case ENLLEQ:v2=tocx(v2);optxt="shl";break;
		case ENDIVEQ:
		case ENMODEQ:
			fl=0;
			if(v1->thingflags & THINGIND)
			{
				emit(" mov esi,");
				emitreg(v1->thingreg+32);
				emitcr();
				removeind(v1);
				fl++;
			} else v3=dupthing(v1);
			if(v1->thingtype!=THINGREGISTER || v1->thingreg!=realreg(EAX))
			{
				clearreg(realreg(EAX),bits[realreg(EDX)]);
				allocregn(realreg(EAX));
				v1=toregn(v1,realreg(EAX));
			}
			if(i1==TYPELONG || i1==TYPESHORT)
			{
				clearreg(realreg(EDX),bits[realreg(EAX)]);
				if(v1->thingflags & THINGUNSIGNED)
					emit(" xor edx,edx\n");
				else
				{
					if(i1==TYPELONG)
						emit(" cdq\n");
					else
						emit(" cwd\n");
				}
			}
			else if(v1->thingflags & THINGUNSIGNED)
				emit(" xor ah,ah\n");
			else
				emit(" cbw\n");
			v2=toreg(v2);
			removeind(v2);
			i2=*v2->thinginfo;
			if(numbytes[i1]>numbytes[i2]) v2=forcetype(v2,i1);
			if(v1->thingflags & THINGUNSIGNED) emit(" div ");
			else emit(" idiv ");
			emitthing(v2);
			emitcr();
			freething(v2);
			freething(v1);
			v1=allocthing();
			*v1->thinginfo=i1;
			v1->thingtype=THINGREGISTER;
			if(op==ENDIVEQ) v1->thingreg=realreg(EAX);
			else {allocregn(realreg(EDX));v1->thingreg=realreg(EDX);}
			if(fl)
			{
				emit(" mov [esi],");
				emitthing(v1);
				emitcr();
			} else
			{
				emitdual("mov",v3,v1);
				freething(v3);
			}
			return v1;
		}
		s1=numbytes[i1];
		s2=numbytes[*v2->thinginfo];
		if(s1!=s2)
		{
			if(op==ENRREQ || op==ENLLEQ)
				s2=1;
			else
			{
				if(s1>s2)
				{
					if(s1==4) v2=totype(v2,TYPELONG);
					else v2=totype(v2,TYPESHORT);
				}
				s2=s1;
			}
			namething(v1,name1,s1);
			namething(v2,name2,s2);
			sprintf(txt," %s %s,%s\n",optxt,name1,name2);
			emit(txt);
		} else
			emitdual(optxt,v1,v2);
		if(op==ENMULEQ)
		{
			emitdual("mov",v3,v1);
			freething(v3);
		}
	}
	if(op!=ENDEF) {freething(v2);return v1;}
	freething(v1);
	return v2;
}

emitthing(athing)
thingptr athing;
{
char thname[64];

	namething(athing,thname,0);
	emit(thname);
}
namething(athing,str,opsize)
thingptr athing;
short opsize;
char *str;
{
short type;
long val;
short size,reg;
char txt[16];
short flags;
char *ti;
char *str2;
char *str3;

	if(opsize) size=opsize;
	else size=numbytes[*athing->thinginfo];
	type=athing->thingtype;
	flags=athing->thingflags;
	val=athing->thingvalue;
	ti=athing->thinginfo;
	if(type==THINGCONST)
	{
		if(val>=0)
			sprintf(str,"$%lx",val);
		else
			sprintf(str,"-$%lx",-val);
	}
	else if(type==THINGREGISTER)
	{
		reg=athing->thingreg;
/*              if(!size && (*ti==ARRAYOF || *ti==FUNCTIONRET)) size=4;*/
		if(flags & THINGIND)
		{
			sprintf(str,"%s [%s]",sizenames[size],regnames[32+regmap[reg]]);

		}
		else
			strcpy(str,regnames[(size<<3)+regmap[reg]]);
	}
	else if(type==THINGVARIABLE)
	{
		if(flags & THINGAUTO)
		{
			sprintf(txt,"[ebp%c%d]",val<0 ? '-' : '+',val<0 ? -val : val);
			if(*ti!=ARRAYOF && ~flags&THINGADDROF && *ti!=ASTRUCT)
				sprintf(str,"%s %s",sizenames[size],txt);
			else
				strcpy(str,txt);
		}
		else
		{
			str2=flags&THINGINTERNAL ? "" : "_";
			if(*ti==FUNCTIONRET || *ti==ARRAYOF || flags&THINGADDROF || *ti==ASTRUCT)
				sprintf(str,"offset %s%s",str2,athing->thingsym->symname);
			else
				sprintf(str,"%s %s%s",sizenames[size],str2,athing->thingsym->symname);
		}
	}
}
thingptr toreg(v1)
thingptr v1;
{
	if(v1->thingtype==THINGREGISTER) return v1;
	return toregn(v1,allocreg());
}

short realreg(reg)
short reg;
{
char *p;
short i;
	p=regmap;
	while(*p!=reg) p++;
	return p-regmap;
}
clearreg(reg,mask)
short reg,mask;
{
short i;
char tc;
char txt[64];
char *p;

	if(~regfree & bits[reg]) return;
	mask|=regfree;
	i=allocregdat[mask];
	if(i<NUMREGS)
	{
		tc=regmap[reg];
		regmap[reg]=regmap[i];
		regmap[i]=tc;
		sprintf(txt," mov %s,%s\n",regnames[regmap[reg]+32],regnames[tc+32]);
		emit(txt);
	} else
		error("Ran out of registers in clearreg");
}

thingptr toregn(v1,rnum)
thingptr v1;
short rnum;
{
thingptr v2;
short size;
char needlea=0;
char t1;

	t1=*v1->thinginfo;
	if(t1==ARRAYOF || t1==ASTRUCT || v1->thingflags & THINGADDROF)
	{
		size=4;
		if(v1->thingflags & THINGAUTO)
			if(t1==ARRAYOF || t1==ASTRUCT || v1->thingflags & THINGADDROF)
				needlea=1;
	} else size=numbytes[*v1->thinginfo];
	v2=dupthing(v1);
	v2->thingtype=THINGREGISTER;
	v2->thingreg=rnum;
	if(needlea) emit(" lea ");
	else emit(" mov ");
	emitreg((size<<3)+v2->thingreg);
	emitcomma();
	emitthing(v1);
	emitcr();
	freething(v1);
	return v2;
}
thingptr copytoreg(v1)
thingptr v1;
{
thingptr v2;
short size;

	size=numbytes[*v1->thinginfo];
	v2=dupthing(v1);
	v2->thingtype=THINGREGISTER;
	v2->thingreg=allocreg();
	emit(" mov ");
	emitreg((size<<3)+v2->thingreg);
	emitcomma();
	emitthing(v1);
	emitcr();
	v2->thingflags &=~THINGIND;
	return v2;

}

emitdual(str,v1,v2)
char *str;
thingptr v1,v2;
{
char name1[64],name2[64];
char txt[64];

	namething(v1,name1,0);
	namething(v2,name2,0);
	sprintf(txt," %s %s,%s\n",str,name1,name2);
	emit(txt);
}
normal(pv1,pv2)
thingptr *pv1,*pv2;
{
char t1,t2;
	t1=*(*pv1)->thinginfo;
	t2=*(*pv2)->thinginfo;
	if(~typeflags[t1]&FARRITH || ~typeflags[t2]&FARRITH)
		badop();
	else
	{
		if(t1==t2) return;
		if(t1==TYPELONG) *pv2=forcetype(*pv2,TYPELONG);
		else if(t2==TYPELONG) *pv1=forcetype(*pv1,TYPELONG);
		else if(t1==TYPESHORT) *pv2=forcetype(*pv2,TYPESHORT);
		else if(t2==TYPESHORT) *pv1=forcetype(*pv1,TYPESHORT);
	}
}
normal2(v1,v2)
thingptr v1,v2;
{
char t1,t2;
	t1=*v1->thinginfo;
	t2=*v2->thinginfo;
	if(~typeflags[t1]&FARRITH || ~typeflags[t2]&FARRITH)
		badop();
}
thingptr scale(v1,v2)
thingptr v1,v2;
{
long size;
short shift;

	size=getscale(v2);
	if(size==1) return v1;
	if(v1->thingtype==THINGCONST)
		v1->thingvalue*=size;
	else
	{
		v1=toreg(v1);
		if(!(size & size-1))
		{
			shift=0;
			size>>=1;
			while(size) {size>>=1;shift++;}
			emit(" shl ");
			emitthing(v1);
			emitcomma();
			emitdec(shift);
			emitcr();
		} else
		{
			emit(" imul ");
			emitthing(v1);
			emitcomma();
			emitdec(size);
			emitcr();
		}
	}
	return v1;
}

thingptr forcetype(v1,type)
thingptr v1;
short type;
{
thingptr rth;
	rth=totype(v1,type);
	*rth->thinginfo=type;
	return rth;
}

thingptr totype(v1,type)
thingptr v1;
short type;
{
char t1;
short reg;

	if(*v1->thinginfo==type) return v1;
	t1=v1->thingtype;
	if(t1!=THINGCONST)
	{
		if(t1==THINGREGISTER)
			reg=v1->thingreg;
		else
			reg=allocreg();
		if(numbytes[*v1->thinginfo]<numbytes[type])
			if(v1->thingflags & THINGUNSIGNED)
				emit(" movzx ");
			else
				emit(" movsx ");
		else
			emit(" mov ");
		emitreg(reg+(type==TYPELONG?32:16));
		emitcomma();
		emitthing(v1);
		emitcr();
		v1->thingtype=THINGREGISTER;
		v1->thingreg=reg;
		v1->thingflags &= ~THINGIND;
	}
	return v1;
}

check(v1)
thingptr v1;
{
char txt[64];
thingptr th;
char type;

	if(v1->thingtype==THINGUNDEF)
	{
		sprintf(txt,"Undefind symbol %s",v1->thingsym->symname);
		warn(txt);
		appendthing(v1,intthing);
		insdeclare(v1);
		th=dupthing(v1);
		th->thingsym->symthing=th;
	} else
	{
		type=*v1->thinginfo;
		if(type==TYPEVOID)
			error("Void object used in expression");
		else if(type==ASTRUCT && !(v1->thingflags & THINGIND))
			error("Illegal use of structure identifier");
	}
}

thingptr doisref(v1,v2)
thingptr v1,v2;
{
char txt[64];
char name[32];
long *val;
char t2;
long offset;

	if(*v1->thinginfo!=POINTERTO)
	{
		error("Illegal use of ->");
		return v1;
	}
	if(!v2)
	{
		error("Must have member after ->");
		return v1;
	}
	v1=toreg(v1);
	if(v1->thingflags & THINGIND) removeind(v1);

	val=v2->thinginfo+1;
	offset=*val;
	if(offset)
	{
		namething(v1,name,0);
		sprintf(txt," add %s,%ld\n",name,offset);
		emit(txt);
	}
	moveleft(v2,5);
	t2=*v2->thinginfo;
	if(t2!=ARRAYOF && t2!=ASTRUCT)
		v2->thingflags |=THINGIND;
	v2->thingtype=THINGREGISTER;
	v2->thingreg=v1->thingreg;
	v1->thingtype=THINGVARIABLE;
	freething(v1);
	return v2;
}
thingptr dosref(v1,v2)
thingptr v1,v2;
{
char txt[64];
char name[32];
long *val;
char t2;

	if(*v1->thinginfo!=ASTRUCT)
	{
		error("Must have structure before .");
		return v1;
	}
	if(!v2)
	{
		error("Must have member after .");
		return v1;
	}
	v1=toreg(v1);
	val=v2->thinginfo+1;
	if(*val)
	{
		namething(v1,name,0);
		sprintf(txt," add %s,%ld\n",name,*val);
		emit(txt);
	}
	moveleft(v2,5);
	t2=*v2->thinginfo;
	if(t2!=ARRAYOF && t2!=ASTRUCT)
		v2->thingflags|=THINGIND;
	v2->thingtype=THINGREGISTER;
	v2->thingreg=v1->thingreg;
	v1->thingtype=THINGVARIABLE;
	freething(v1);
	return v2;
}

thingptr doop(op,v1,v2)
thingptr v1,v2;
short op;
{
char flags;
thingptr th,result;
char t1,t2;
char csl1,csl2;
char reversed=0;
char *str;
long val;

	if(v1->thingflags&THINGUNSIGNED || v2->thingflags&THINGUNSIGNED)
	{
		v1->thingflags |= THINGUNSIGNED;
		v2->thingflags |= THINGUNSIGNED;
	}

	flags=opflags[op];
	check(v1);
	check(v2);
	if(~flags & OPLAZY)
	{
		t1=v1->thingtype;
		t2=v2->thingtype;
		if(t1==THINGVARIABLE && (*v1->thinginfo==ARRAYOF || v1->thingflags&THINGADDROF))
			v1=toreg(v1);
		if(t2==THINGVARIABLE && (*v2->thinginfo==ARRAYOF || v2->thingflags&THINGADDROF))
			v2=toreg(v2);

		if(flags & OPDEF)
		{
			if(op!=ENMULEQ && op!=ENDIVEQ && op!=ENMODEQ)
			{
				if(t2!=THINGCONST && t2!=THINGREGISTER)
					v2=toreg(v2);
				else if(v2->thingflags & THINGIND)
					removeind(v2);
			}
		} else
		{
			if(!(v2->thingtype==THINGCONST && flags&OPCOMP)
			 && (v1->thingtype!=THINGREGISTER || v1->thingflags&THINGIND))
			{
				if(flags&OPREVERSABLE && v2->thingtype==THINGREGISTER && ~v2->thingflags&THINGIND)
				{
					th=v1;
					v1=v2;
					v2=th;
					reversed++;
				} else
				{
					v1=toreg(v1);
					removeind(v1);
				}
			}
		}
	}
	t1=*v1->thinginfo;
	t2=*v2->thinginfo;
	csl1= typeflags[t1]&FARRITH;
	csl2= typeflags[t2]&FARRITH;
	switch(op)
	{
	case ENADD:
		if((t1==POINTERTO || t1==ARRAYOF) && csl2)
		{
			v2=forcetype(v2,TYPELONG);
			v2=scale(v2,v1);
			result=v1;
		} else if((t2==POINTERTO || t2==ARRAYOF) && csl1)
		{
			v1=forcetype(v1,TYPELONG);
			v1=scale(v1,v2);
			emitdual("add",v1,v2);
			cast(v1,v2);
			result=v1;
			break;
		} else {normal(&v1,&v2);result=v1;}
		emitdual("add",v1,v2);
		break;
	case ENSUB:
		if((t1==POINTERTO || t1==ARRAYOF) && csl2)
		{
			v2=forcetype(v2,TYPELONG);
			v2=scale(v2,v1);
			result=v1;
		} else if((t1==POINTERTO || t1==ARRAYOF) && t2==ARRAYOF)
		{
			result=dupthing(v1);
			cast(result,longthing);
		} else if(t1==POINTERTO && t2==POINTERTO)
		{
			if(compthings(v1,v2))
				warn("Pointers do not point to same object type");
			val=getscale(v1);
			result=dupthing(v1);
			cast(result,longthing);
			emitdual("sub",v1,v2);
			v1->thingtype=THINGVARIABLE; /* so don't deallocate register */
			if(val!=1)
			{
				th=allocthing();
				th->thingvalue=val;
				th->thingtype=THINGCONST;
				*th->thinginfo=TYPESHORT;
				result=doop(ENDIV,result,th);
			}
			break;
		} else {normal(&v1,&v2);result=v1;}
		emitdual("sub",v1,v2);
		break;
	case ENMOD:
	case ENDIV:
		if(v2->thingtype==THINGCONST && op==ENDIV)
		{
			val=v2->thingvalue;
			if(!(val & val-1))
			{
				v2->thingvalue=0;
				while(val>>=1) v2->thingvalue++;
				goto doenrr;
			}
		}
		normal(&v1,&v2);
		if(v1->thingtype!=THINGREGISTER || v1->thingreg!=realreg(EAX))
		{
			clearreg(realreg(EAX),bits[realreg(EDX)]);
			allocregn(realreg(EAX));
			v1=toregn(v1,realreg(EAX));
		}
		t1=*v1->thinginfo;
		if(t1==TYPELONG || t1==TYPESHORT)
		{
			clearreg(realreg(EDX),bits[realreg(EAX)]);
			if(v1->thingflags & THINGUNSIGNED)
				emit(" xor edx,edx\n");
			else
			{
				if(t1==TYPELONG)
					emit(" cdq\n");
				else
					emit(" cwd\n");
			}
		}
		else if(v1->thingflags & THINGUNSIGNED)
			emit(" xor ah,ah\n");
		else
			emit(" cbw\n");
		v2=toreg(v2);
		removeind(v2);
		if(v1->thingflags & THINGUNSIGNED) emit(" div ");
		else emit(" idiv ");
		emitthing(v2);
		emitcr();
		if(op==ENMOD)
		{
			if(t1==TYPESHORT)
				emit(" mov ax,dx\n");
			else if(t1==TYPELONG)
				emit(" mov eax,edx\n");
			else
				emit(" mov al,ah\n");
		}
		result=v1;
		break;
	case ENMUL:
	case ENAND:
	case ENOR:
	case ENXOR:
		normal(&v1,&v2);
		result=v1;
		emitdual(opnames[op-ENADD],v1,v2);
		break;
	case ENEQ:
	case ENNE:
	case ENGT:
	case ENLT:
	case ENGE:
	case ENLE:
		if((t1==POINTERTO || t1==FUNCTIONRET || t1==ARRAYOF) && (t2==POINTERTO || t2==FUNCTIONRET || t2==ARRAYOF))
		{
			;
		} else if(t1==POINTERTO && csl2)
		{
			v2=forcetype(v2,TYPELONG);
		} else if(t2==POINTERTO && csl1)
		{
			v1=forcetype(v1,TYPELONG);
		} else normal(&v1,&v2);
		result=compop(op-ENEQ + (reversed?8:0),v1,v2);
		return result;
doenrr:
	case ENRR:
	case ENLL:
		normal2(v1,v2);
		if(op==ENLL)
			str="shl";
		else if(v1->thingflags & THINGUNSIGNED)
			str="shr";
		else
			str="sar";
		if(v2->thingflags & THINGIND) removeind(v2);
		if(v2->thingtype!=THINGCONST)
		{
			*v2->thinginfo=TYPECHAR;
			if(v2->thingtype!=THINGREGISTER || v2->thingreg!=realreg(ECX))
			{
				clearreg(realreg(ECX),0);
				v2=toregn(v2,realreg(ECX));
				emitdual(str,v1,v2);
			}
		} else
			emitdual(str,v1,v2);
		result=v1;
		break;
	case ENADDEQ:
	case ENSUBEQ:
	case ENMODEQ:
	case ENDIVEQ:
	case ENMULEQ:
	case ENANDEQ:
	case ENOREQ:
	case ENXOREQ:
	case ENRREQ:
	case ENLLEQ:
	case ENDEF:
		return def(op,v1,v2);
	case ENCAST:
		t1=*v1->thinginfo;
		t2=*v2->thinginfo;
		if(numbytes[t1]<numbytes[t2])
		{
			v1=totype(v1,TYPELONG);
		}
		cast(v1,v2);
		result=v1;
		break;
	}

	if(v1!=result) freething(v1);
	if(v2!=result) freething(v2);
	return result;
}

/* +16 = if unsigned, ^8 if reversed, ^1 if negated */
char *compnames[]={
" jnz "," jz "," jle "," jg "," jge "," jl ","","",
" jnz "," jz "," jge "," jl "," jle "," jg ","","",
" jnz "," jz "," jbe "," ja "," jae "," jb ","","",
" jnz "," jz "," jae "," jb "," jbe "," ja ","",""

/*
" jnz "," jz "," jle "," jge "," jl " ," jg ","","",
" jnz "," jz "," jg " ," jl " ," jge "," jle ","","",
" jnz "," jz "," jbe "," jae "," jb " ," ja ","","",
" jnz "," jz "," ja " ," jb " ," jae "," jbe ","","",


^1 = negated, ^16 = unsigned, ^8 = reversed
!=  ==  <=   >  >=   <
!=  ==  >=   <  <=   >
*/

};

thingptr compop(op,v1,v2)
thingptr v1,v2;
short op;
{
thingptr th;
short reg;
short lct;
char t1;
	t1=*v1->thinginfo;

	if(v1->thingflags & THINGUNSIGNED) op+=16;

	if((v1->thingtype!=THINGREGISTER || v1->thingflags & THINGIND) && v2->thingtype!=THINGCONST)
	{
		if(v2->thingtype==THINGREGISTER && ~v2->thingflags& THINGIND || v1->thingtype==THINGCONST)
		{
			th=v1;
			v1=v2;
			v2=th;
			op^=8;
		} else
		{
			v1=toreg(v1);
			removeind(v1);
		}
	}
	emit(" cmp ");
	emitthing(v1);
	emitcomma();
	emitthing(v2);
	emitcr();
	freething(v1);
	freething(v2);

	if(lfollow)
	{
		if(lfollow&1)
		{
			emit(compnames[op]);
			emitref(failure);
		} else
		{
			emit(compnames[op^1]);
			emitref(success);
		}
		th=0;
	} else
	{
		th=allocthing();
		th->thingtype=THINGREGISTER;
		th->thingreg=allocreg();
		*th->thinginfo=TYPEINT;
		emit(" mov ");
		emitthing(th);
		emit(",0\n");
		lct=alloclabel();
		emit(compnames[op]);
		emitref(lct);
		emit(" inc ");
		emitthing(th);
		emitcr();
		emitlabel(lct);
	}
	return th;
}

thingptr constop1(op,th1)
thingptr th1;
short op;
{
long v1;
	v1=th1->thingvalue;
	switch(op)
	{
	case ENUNARY:v1=-v1;break;
	case ENNOT:v1=~v1;break;
	case ENNOTZ:v1= v1!=0; break;
	case ENPAREN:break;
	default: error("Unknown constop1");
	}
	th1->thingvalue=v1;
	return th1;
}
thingptr constop2(op,th1,th2)
thingptr th1,th2;
short op;
{
long v1,v2;
	v1=th1->thingvalue;
	v2=th2->thingvalue;
	switch(op)
	{
	case ENADD:v1+=v2;break;
	case ENMUL:v1*=v2;break;
	case ENSUB:v1-=v2;break;
	case ENDIV:if(v2) v1/=v2; else div0error();break;
	case ENMOD:v1%=v2;break;
	case ENEQ:v1=v1==v2;break;
	case ENNE:v1=v1!=v2;break;
	case ENLT:v1=v1<v2;break;
	case ENGT:v1=v1>v2;break;
	case ENLE:v1=v1<=v2;break;
	case ENGE:v1=v1>=v2;break;
	case ENANDAND:v1=v1 && v2;break;
	case ENOROR:v1=v1 || v2;break;
	case ENAND:v1=v1&v2;break;
	case ENOR:v1=v1|v2;break;
	case ENXOR:v1=v1^v2;break;
	case ENCOMMA:v1=v2;break;
	case ENRR: v1=v1>>v2;break;
	case ENLL: v1=v1<<v2;break;
	case ENDEF:v1=v2;lverror();break;
	default:error("Unknown constop2");
	}
	freething(th2);
	th1->thingvalue=v1;
	return th1;
}

thingptr convcs(v1)
thingptr v1;
{
short reg;

	if(v1->thingtype==THINGREGISTER)
	{
		reg=v1->thingreg;
		emit(" movsx ");
		emitreg(reg+16);
		emitcomma();
		emitreg(reg+8);
		emitcr();
		*v1->thinginfo=TYPESHORT;
		return v1;
	}
}


thingptr doaddrof(v1)
thingptr v1;
{
char *p;

	if(v1->thingflags & THINGIND)
	{
		v1->thingflags ^= THINGIND;
		goto enter;
	}
	if(v1->thingflags & THINGADDROF || v1->thingtype!=THINGVARIABLE || *v1->thinginfo==ARRAYOF)
		error("Illegal use of '&'");
	else
	{
		v1->thingflags |= THINGADDROF;
enter:
		p=v1->thinginfo;
		fcopy(p,p+1,INFOLEN-1);
		*p=POINTERTO;
	}
	return v1;
}


removeind(v1)
thingptr v1;
{
	if(~v1->thingflags & THINGIND) return;
	emit(" mov ");
	v1->thingflags ^=THINGIND;
	emitthing(v1);
	emitcomma();
	v1->thingflags ^=THINGIND;
	emitthing(v1);
	emitcr();
	v1->thingflags ^=THINGIND;
}

thingptr indirect(v1)
thingptr v1;
{
char *p;

	if(v1->thingflags & THINGADDROF)
	{
		v1->thingflags ^= THINGADDROF;
		moveleft(v1,1);
	} else if(*v1->thinginfo==POINTERTO)
	{
		if(v1->thingflags&THINGIND)
		{
			removeind(v1);
			v1->thingflags ^=THINGIND;
			moveleft(v1,1);
		} else
		{
			if(v1->thinginfo[1]!=FUNCTIONRET)
			{
				v1=toreg(v1);
				moveleft(v1,1);
				if(*v1->thinginfo!=ARRAYOF && *v1->thinginfo!=ASTRUCT)
					v1->thingflags |=THINGIND;
			}
		}
	} else if(*v1->thinginfo==ARRAYOF)
	{
		v1=toreg(v1);
		moveleft(v1,5);
		if(*v1->thinginfo!=ARRAYOF && *v1->thinginfo!=ASTRUCT) v1->thingflags |=THINGIND;
	} else
		error("Indirection error");
	return v1;
}

thingptr dosizeof(v1)
thingptr v1;
{
thingptr ath;
	ath=allocthing();
	ath->thingtype=THINGCONST;
	*ath->thinginfo=TYPEINT;
	ath->thingvalue=getsize(v1);
	freething(v1);
	return ath;
}
thingptr una(v1)
thingptr v1;
{
	v1=toreg(v1);
	removeind(v1);
	emit(" neg ");
	emitthing(v1);
	emitcr();
	return v1;
}
thingptr not(v1)
thingptr v1;
{
	v1=toreg(v1);
	removeind(v1);
	emit(" not ");
	emitthing(v1);
	emitcr();
	return v1;
}

thingptr toax(v1)
enodeptr v1;
{
short reax;
thingptr ath;

	ath=subexpr(v1,0);
	check(ath);
	reax=realreg(EAX);
	if(ath->thingtype!=THINGREGISTER || ath->thingreg!=reax)
	{
		allocregn(reax);
		ath=toregn(ath,reax);
	}
	removeind(ath);
	return ath;
}

thingptr tocx(v1)
thingptr v1;
{
short recx;

	if(v1->thingtype==THINGCONST) return v1;
	recx=realreg(ECX);
	if(v1->thingtype!=THINGREGISTER || v1->thingreg!=recx)
	{
		clearreg(recx,0);
		recx=realreg(ECX);
		allocregn(recx);
		v1=toregn(v1,recx);
	}
	removeind(v1);
	return v1;
}


doreturn(v1)
enodeptr v1;
{
char *p;
	if(v1)
	{
		v1=toax(v1);
		p=lastfunc->thinginfo;
		if(*p++==POINTERTO) p++;
		if(numbytes[*v1->thinginfo]<numbytes[*p])
			v1=totype(v1,TYPELONG);
		freething(v1);
	}
	emit(" jmp ");
	emitref(curfuncret);
}

dobreak()
{
	emit(" jmp ");
	emitbreak();
	emitcr();
}
docont()
{
	emit(" jmp ");
	emitcont();
	emitcr();
}


dogoto(v1)
char *v1;
{
	emit(" jmp ");
	emit(lastfuncname);
	emitch('_');
	emit(v1);
	emitcr();
}

dolabel(v1,v2)
char *v1;
TEXT v2;
{
	emit(lastfuncname);
	emitch('_');
	emit(v1);
	emit(":\n");
	emitsub(v2);
}


short argcount;
pushargs(en)
enodeptr en;
{
thingptr ath;
short flags;
short size;

	if(en->enodetype==ENCOMMA)
	{
		pushargs(en->enodeo2);
		pushargs(en->enodeo1);
		enfree(en);
	} else
	{
		ath=subexpr(en,0);
		check(ath);
		size=numbytes[*ath->thinginfo];
		flags=ath->thingflags;
		if(ath->thingtype==THINGVARIABLE && flags&THINGAUTO && ~flags&THINGIND && *ath->thinginfo==ARRAYOF)
			ath=toreg(ath);
		else if(size==1)
		{
			if(flags & THINGIND) removeind(ath);
			ath=forcetype(ath,TYPESHORT);
			size=2;
		}
		if(ath->thingflags & THINGADDROF)
			ath=toreg(ath);
		if(ath->thingtype==THINGCONST && *ath->thinginfo==TYPESHORT)
			emit(" push word ");
		else
			emit(" push ");
		emitthing(ath);
		emitcr();
		if(!size) size=4;
		argcount+=size;
		freething(ath);
	}
}
listsyms(sp)
symptr *sp;
{
short i;
symptr asym;

	i=256;
	while(i--)
	{
		asym=*sp++;
		while(asym)
		{
			printf("%s,",asym->symname);
			asym=asym->symnext;
		}
	}
	putchar('\n');
}

thingptr dofcall(s1,v2)
enodeptr s1;
enodeptr v2;
{
short acsave;
char *p;
short regused,reg;
thingptr lfsave;
thingptr v1;
symptr asym;

	regused=pushregs();
	acsave=argcount;
	argcount=0;
	if(v2) pushargs(v2);

	v1=subexpr(s1,0);
	if(v1->thingtype==THINGUNDEF)
	{
		if(asym=findsym(v1->thingsym->symname))
		{
			freesym(v1->thingsym);
			v1=dupthing(asym->symthing);
		} else
		{
			append(v1,FUNCTIONRET);
			appendthing(v1,intthing);
			v1->thingflags |= THINGEXTERN;
			declare(v1);
			v1=dupthing(v1);
		}
	}
/*I think this is all diag stuff*/  //JASON
//list(v1);
	p=v1->thinginfo;
	if(*p!=FUNCTIONRET && !(*p==POINTERTO && p[1]==FUNCTIONRET) || (v1->thingtype!=THINGVARIABLE && v1->thingtype!=THINGREGISTER))
		error("Illegal function call");
	emit(" call ");
	if(*p==FUNCTIONRET && !(v1->thingflags & THINGIND))
		emitname(v1->thingsym);
	else
		emitthing(v1);
	emitcr();
	if(argcount)
	{
		emit(" add esp,");
		emitdec(argcount);
		emitcr();
	}
	argcount=acsave;
	if(*p==POINTERTO)
		moveleft(v1,2);
	else
		moveleft(v1,1);
	if(v1->thingtype==THINGREGISTER)
		freereg(v1->thingreg);
	if(regused&bits[realreg(EAX)])
	{
		reg=allocregmask(regused);
		emit(" mov ");
		emitreg(reg+32);
		emit(",eax\n");
	} else reg=allocregn(realreg(EAX));
	v1->thingtype=THINGREGISTER;
	v1->thingreg=reg;
	popregs(regused);
	return v1;
}

dowhile(v1,v2)
enodeptr v1;
TEXT v2;
{
short lct1,lct2,lct3;
thingptr th;

	lct2=alloclabel();
	lct3=alloclabel();
	emitch(BREAKOPEN);
	emitshort(lct2);
	emitshort(lct3);
	emitlabel(lct3);
	if(v1)
	{
		lct1=alloclabel();
		subexpr(v1,5,lct1,lct2);
		qemitlabel(lct1);
	}
	emitsub(v2);
	emit(" jmp ");
	emitref(lct3);
	emitlabel(lct2);
	emitch(BREAKCLOSE);
}

dodowhile(v1,v2)
TEXT v1;
enodeptr v2;
{
short lct1,lct2,lct3;

	lct3=alloclabel();
	lct2=alloclabel();
	emitch(BREAKOPEN);
	emitshort(lct3);
	emitshort(lct2);
	emitlabel(lct2);
	emitsub(v1);
	if(v2)
	{
		lct1=alloclabel();
		subexpr(v2,4,lct2,lct1);
		qemitlabel(lct1);
	}
	else
	{
		emit(" jmp ");
		emitref(lct2);
	}
	emitlabel(lct3);
	emitch(BREAKCLOSE);
}


thingptr incdec(v1,sgn,type)
thingptr v1;
short sgn,type;
{
short size;
short flags;
thingptr v2;

	size=getscale(v1);
	if(type)
		v2=copytoreg(v1);
	if(size>1)
	{
		if(sgn<0)
			emit(" sub ");
		else
			emit(" add ");
		emitthing(v1);
		emitcomma();
		emitdec(size);
	} else
	{
		if(sgn<0)
			emit(" dec ");
		else
			emit(" inc ");
		emitthing(v1);
	}
	emitcr();
	if(type)
	{
		freething(v1);
		v1=v2;
	}
	return v1;
}

dofor(v1,v2,v3,v4)
enodeptr v1,v2,v3;
TEXT v4;
{
short lct1,lct2,lct3,lct4;

	if(v1) freething(subexpr(v1,0));
	lct2=alloclabel();
	lct3=alloclabel();
	lct4=alloclabel();
	emitlabel(lct3);
	if(v2)
	{
		lct1=alloclabel();
		subexpr(v2,5,lct1,lct2);
		qemitlabel(lct1);
	}
	emitch(BREAKOPEN);
	emitshort(lct2);
	emitshort(lct4);
	emitsub(v4);
	emitlabel(lct4);
	if(v3) freething(subexpr(v3,0));
	emit(" jmp ");
	emitref(lct3);
	emitlabel(lct2);
	emitch(BREAKCLOSE);
}

doif(v1,v2)
enodeptr v1;
TEXT v2;
{
thingptr th;
short lct1,lct2;

	lct1=alloclabel();
	lct2=alloclabel();
	subexpr(v1,5,lct1,lct2);
	qemitlabel(lct1);
	emitsub(v2);
	emitlabel(lct2);
}
doifelse(v1,v2,v3)
enodeptr v1;
TEXT v2,v3;
{
thingptr th;
short lct1,lct2,lct3;

	lct1=alloclabel();
	lct2=alloclabel();
	lct3=alloclabel();
	subexpr(v1,5,lct1,lct2);
	qemitlabel(lct1);
	emitsub(v2);
	emit(" jmp ");
	emitref(lct3);
	emitlabel(lct2);
	emitsub(v3);
	emitlabel(lct3);
}

thingptr subexpr(en,follow,tside,fside)
enodeptr en;
short follow,tside,fside;
{
enodeptr s1,s2,s3;
short type;
char txt[64];
thingptr r1,r2,r3,result;
short lct,lct2,tt,tf;
short reg;

	if(!en) return 0;
	type=en->enodetype;
	s1=en->enodeo1;
	s2=en->enodeo2;
	s3=en->enodeo3;
	enfree(en);
	switch(type)
	{
	case ENTHING:
		result=s1;
		break;
	case ENDEF:
	case ENADDEQ:
	case ENSUBEQ:
	case ENMODEQ:
	case ENDIVEQ:
	case ENMULEQ:
	case ENANDEQ:
	case ENOREQ:
	case ENXOREQ:
	case ENRREQ:
	case ENLLEQ:
		r2=subexpr(s2,0);
		r1=subexpr(s1,0);
		result=doop(type,r1,r2);
		break;
	case ENADD:
	case ENSUB:
	case ENMUL:
	case ENDIV:
	case ENMOD:
	case ENAND:
	case ENOR:
	case ENXOR:
	case ENRR:
	case ENLL:
		r1=subexpr(s1,0);
		r2=subexpr(s2,0);
		result=doop(type,r1,r2);
		break;
	case ENEQ:
	case ENNE:
	case ENGT:
	case ENLT:
	case ENGE:
	case ENLE:
		r1=subexpr(s1,0);
		r2=subexpr(s2,0);
		success=tside;
		failure=fside;
		lfollow=follow;
		result=doop(type,r1,r2);
		break;
	case ENSREF:
		r1=subexpr(s1,0);
		r2=s2;
		result=dosref(r1,r2);
		break;
	case ENISREF:
		r1=subexpr(s1,0);
		r2=s2;
		result=doisref(r1,r2);
		break;
	case ENCAST:
		r1=subexpr(s1,0);
		r2=s2;
		result=doop(type,r1,r2);
		break;
	case ENQC:
		lct=alloclabel();
		tt=alloclabel();
		tf=alloclabel();
		subexpr(s1,5,tt,tf);
		qemitlabel(tt);
		r2=subexpr(s2,0);
		if(*r2->thinginfo==TYPECHAR)
			r2=forcetype(r2,TYPESHORT);
		removeind(r2);
		if(r2->thingtype!=THINGREGISTER)
		{
			reg=allocreg();
			r2=toregn(r2,reg);
		} else
			reg=r2->thingreg;
		freething(r2);
		emit(" jmp ");
		emitref(lct);
		emitlabel(tf);
		r3=subexpr(s3,0);
		if(*r3->thinginfo==TYPECHAR)
			r3=forcetype(r3,TYPESHORT);
		removeind(r3);
		if(r3->thingtype!=THINGREGISTER || r3->thingreg!=reg)
		{
			allocregn(reg);
			r3=toregn(r3,reg);
		}
		emitlabel(lct);
		result=r3;
		break;
	case ENOROR:
	case ENANDAND:
		if(follow)
		{
			lct=alloclabel();
			if(type==ENANDAND)
				subexpr(s1,5,lct,fside);
			else
				subexpr(s1,4,tside,lct);
			qemitlabel(lct);
			subexpr(s2,follow,tside,fside);
			result=0;
		} else
		{
			tt=alloclabel();
			tf=alloclabel();
			lct=alloclabel();
			if(type==ENANDAND)
				subexpr(s1,5,lct,tf);
			else
				subexpr(s1,4,tt,lct);
			qemitlabel(lct);
			subexpr(s2,5,tt,tf);
intoreg01:
			qemitlabel(tt);
			lct=alloclabel();
			result=allocthing();
			result->thingtype=THINGREGISTER;
			result->thingreg=allocreg();
			*result->thinginfo=TYPEINT;
			emit(" mov ");
			emitthing(result);
			emit(",1\n jmp ");
			emitref(lct);
			emitlabel(tf);
			emit(" xor ");
			emitthing(result);
			emitcomma();
			emitthing(result);
			emitcr();
			emitlabel(lct);
		}
		break;
	case ENNOTZ:
		if(follow)
			result=subexpr(s1,follow^1,fside,tside);
		else
		{
			tt=alloclabel();
			tf=alloclabel();
			lct=alloclabel();
			subexpr(s1,4,tf,tt);
			goto intoreg01;
		}
		break;
	case ENPAREN: result=subexpr(s1,follow,tside,fside);break;
	case ENUNARY: result=una(subexpr(s1,0));break;
	case ENNOT: result=not(subexpr(s1,0));break;
	case ENIND: result=indirect(subexpr(s1,0));break;
	case ENCOMMA: freething(subexpr(s1,0));result=subexpr(s2,follow,tside,fside);break;
	case ENPREINC: result=incdec(subexpr(s1,0),1,0);break;
	case ENPOSTINC: result=incdec(subexpr(s1,0),1,1);break;
	case ENPREDEC: result=incdec(subexpr(s1,0),-1,0);break;
	case ENPOSTDEC: result=incdec(subexpr(s1,0),-1,1);break;
	case ENFCALL: result=dofcall(s1,s2);break;
	case ENADDROF: result=doaddrof(subexpr(s1,0));break;
	case ENARRAY: result=indirect(doop(ENADD,subexpr(s1,0),subexpr(s2,0)));break;
	default:
		sprintf(txt,"Unknown enode type %d",type);
		critical(txt);
		return 0;
	}

	if(follow && result)
	{
		check(result);
/*
		result=toreg(result);
		removeind(result);
		emit(" or ");
		emitthing(result);
		emitcomma();
		emitthing(result);
		emitcr();
*/
		if(result->thingtype==THINGCONST)
		{
			if(follow&1)
			{
				if(!result->thingvalue)
				{
					emit(" jmp ");
					emitref(fside);
				}
			} else
			{
				if(result->thingvalue)
				{
					emit(" jmp ");
					emitref(tside);
				}
			}
		} else
		{
			if(result->thingtype==THINGREGISTER && ~result->thingflags & THINGIND)
			{
				emit(" or ");
				emitthing(result);
				emitcomma();
				emitthing(result);
				emitcr();
			} else
			{
				emit(" cmp ");
				emitthing(result);
				emit(",0\n");
			}
			if(follow&1)
			{
				emit(" jz ");
				emitref(fside);
			}
			else
			{
				emit(" jnz ");
				emitref(tside);
			}
		}
		freething(result);
		result=0;
	}
	return result;
}


emitcomma() {emitch(',');}
emitcr() {emitch('\n');}

emitbreak() {emitch(BREAKREF);}
emitcont() {emitch(CONTREF);}
emitreg(num)
short num;
{
	num=(num&0xfff8) | regmap[num&7];
	emit(regnames[num]);
}

emitname(asym)
struct sym *asym;
{
	emitch('_');emit(asym->symname);
}
emitdec(val)
unsigned short val;
{
char ttt[16];

	sprintf(ttt,"%u",val);
	emit(ttt);
}
emitlong(val)
long val;
{
char ttt[16];

	sprintf(ttt,"%ld",val);
	emit(ttt);
}


char bits[8]={1,2,4,8,16,32,64,128};
alloclabel()
{
char *p,c,b;
short num;
	p=labelbase+(labelbits1-labelbits2);
	num=labelnumbase;
	while(*p==255) {num+=8;p++;}
	c=*p;b=1;
	while(c&b) {num++;b+=b;}
	*p |=b;
	return num;
}
allocsurelabel()
{
short num;
	num=alloclabel();
	labelbits2[num>>3]|=bits[num&7];
	while(*labelbase==255) {labelbase++;labelnumbase+=8;}
	return num;     
}
qemitlabel(num)
short num;
{
	if(labelbits2[num>>3] & bits[num&7])
		{emitlabel(num);return 1;}
	else
	{
		if(!(labelbits1[num>>3] & bits[num&7]))
			error("Label allocation error");
		labelbits1[num>>3] ^= bits[num&7];
	}
	return 0;
}
emitlabel(num)
short num;
{
	emitch(LABELCHAR);
	emitdec(num);
	emit(":\n");
	labelbits2[num>>3]|=bits[num&7];
	while(*labelbase==255) {labelbase++;labelnumbase+=8;}
}
outref(num)
short num;
{
char txt[16];
	*txt=LABELCHAR;
	sprintf(txt+1,"%d",num);
	outstr(txt);
	labelbits2[num>>3]|=bits[num&7];
	while(*labelbase==255) {labelbase++;labelnumbase+=8;}
}
/*
qoutlabel(num)
short num;
{
	if(labelbits2[num>>3] & bits[num&7])
		{outref(num);outstr(":\n");}
	else
	{
		if(!(labelbits1[num>>3] & bits[num&7]))
			error("Label allocation error");
		labelbits1[num>>3] ^= bits[num&7];
	}
}
*/
emitref(num)
short num;
{
	emitref2(num);
	emitcr();
}
emitref2(num)
short num;
{
	emitch(LABELCHAR);
	emitdec(num);
	labelbits2[num>>3]|=bits[num&7];
	while(*labelbase==255) {labelbase++;labelnumbase+=8;}
}

struct kw *findkeyword(str)
char *str;
{
short i,j,c;
struct kw *akw;

	j=nkwpower;
	i=j-1;
	akw=keywords+i;
	while(j)
	{
		j>>=1;
		if(i>=numkeywords)
		{
			i-=j;akw-=j;
		} else
		{
			c=strcmp(str,akw->kwname);
			if(!c) return akw;
			if(c<0)
			{
				i-=j;akw-=j;
			} else
			{
				i+=j;akw+=j;
			}
		}
	}
	return 0;
}

char sizelist[]={
TYPECHAR,1,
TYPESHORT,2,
TYPELONG,4,
POINTERTO,4,
FUNCTIONRET,4,
ARRAYOF,4,
ASTRUCT,4,
TYPEVOID,0,
255
};

thingptr addint(txt,type)
char *txt;
short type;
{
thingptr ath;
symptr asym;


	asym=newsym(txt);
	ath=allocthing();
	ath->thingtype=THINGVARIABLE;
	ath->thingflags=THINGTYPEDEF|THINGQUIET;
	*ath->thinginfo=type;
	ath->thingsym=asym;
	asym->symthing=ath;
	addtypedef(asym);
	return ath;
}

char infolenlist[]=
{
POINTERTO,1,
FUNCTIONRET,1,
ARRAYOF,5,
ASTRUCT,5,
TYPECHAR,1,
TYPESHORT,1,
TYPELONG,1,
TYPEVOID,1,
TYPEFLOAT,1,
TYPEDOUBLE,1,
TYPEMEMBER,5,
0
};

char opflagslist[]=
{
ENDEF,OPDEF,
ENADDEQ,OPDEF,
ENSUBEQ,OPDEF,
ENMULEQ,OPDEF,
ENDIVEQ,OPDEF,
ENRREQ,OPDEF,
ENLLEQ,OPDEF,
ENANDEQ,OPDEF,
ENOREQ,OPDEF,
ENXOREQ,OPDEF,
ENMODEQ,OPDEF,
ENADD,OPREVERSABLE,
ENSUB,0,
ENMUL,OPREVERSABLE,
ENMOD,0,
ENDIV,0,
ENAND,OPREVERSABLE,
ENOR,OPREVERSABLE,
ENXOR,OPREVERSABLE,
ENEQ,OPREVERSABLE+OPCOMP,
ENNE,OPREVERSABLE+OPCOMP,
ENGT,OPREVERSABLE+OPCOMP,
ENLT,OPREVERSABLE+OPCOMP,
ENGE,OPREVERSABLE+OPCOMP,
ENLE,OPREVERSABLE+OPCOMP,
ENRR,0,
ENLL,0,
ENCAST,OPLAZY,
0
};

char flagslist[]=
{
TYPECHAR,FARRITH,
TYPESHORT,FARRITH,
TYPELONG,FARRITH,
0
};


freeind(pntr)
char **pntr;
{
	if(*pntr)
	{
		free(*pntr);
		*pntr=0;
	}
}
freeblocks(pntr)
char **pntr;
{
char *p;
	p=*pntr;
	*pntr=0;
	pntr=p;
	while(pntr)
	{
		p=pntr;
		pntr=*pntr;
		free(p);
	}
}


freestuff()
{
	freeind(&macroblock);
	freeind(&preproc);
	freeind(&switchblock);
	freeind(&textbase);
	freeind(&labelbits1);
	freeind(&labelbits2);
	freeind(&ndefs);
	freeind(&globals);
	freeind(&autos);
	freeind(&structs);
	freeind(&members);
	freeind(&typedefs);
	freeblocks(&thingblocks);
	freeblocks(&symblocks);
	freeblocks(&enodeblocks);
	freeblocks(&stringblocks);
	freeblocks(&symtextblocks);
}

closeup(code)
{
	freestuff();
	exit(code);
}

regmapinit()
{
short i;
	for(i=0;i<NUMREGS;i++) regmap[i]=i;
	if(regfree) error("regmapinit:Didn't free something");
	regfree=0;
}

initstuff()
{
struct kw *akw;
char *p;
char index;
short i,j,k;

	textbase=mallocl(TEXTMAX+256);
	if(!textbase) nomem();
	texttop=textbase+TEXTMAX;
	symtextblocks=0;
	newsymtextblock();
	symblocks=0;
	usedsymlist=0;
	usedsymnum=0;
	newsymblock();
	thingblocks=0;
	usedthinglist=0;
	usedthingnum=0;
	newthingblock();
	enodeblocks=0;
	usedenodelist=0;
	usedenodenum=0;
	newenodeblock();
	stringblocks=0;
	usedstringlist=0;
	usedstringnum=0;
	newstringblock();
	macrostack=macroblock=malloc(BLOCKSIZE);
	if(!macroblock) nomem();
	preproc=malloc(PREMAX);
	if(!preproc) nomem();
	nextswitch=switchblock=malloc(SWITCHMAX*sizeof(struct aswitch));
	switchsp=0;
	if(!switchblock) nomem();
	switchnum=0;
	labelbits1=xalloc(MAXLBITS>>3);
	labelbits2=xalloc(MAXLBITS>>3);
	ndefs=xalloc(256*sizeof(symptr));
	globals=xalloc(256*sizeof(symptr));
	autos=xalloc(256*sizeof(symptr));
	structs=xalloc(256*sizeof(symptr));
	members=xalloc(256*sizeof(symptr));
	typedefs=xalloc(256*sizeof(symptr));

	regmapinit();
	k=1<<NUMREGS;
	for(i=0;i<k;i++)
	{
		j=0;
		while(j<NUMREGS)
			if(~i & bits[j]) break;
			else j++;
		if(j<NUMREGS) allocregdat[i]=j;
		else allocregdat[i]=99;
	}
	breaksp=breakstack;
	contsp=contstack;
	*breaksp=0;
	*contsp=0;
	firststring=0;
	clearmem(opflags,64);
	p=opflagslist;
	while(*p) {opflags[*p]|=p[1];p+=2;}

	clearmem(infolens,16);
	p=infolenlist;
	while(*p) {infolens[*p]=p[1];p+=2;}

	clearmem(typeflags,16);
	p=flagslist;
	while(*p) {typeflags[*p]=p[1];p+=2;}

	labelbits1[0]=labelbits2[0]=1;
	labelbase=labelbits2;
	labelnumbase=0;
	initstmt();
	akw=keywords;
	numkeywords=0;
	while((akw++)->kwname) numkeywords++;
	nkwpower=1;
	while(nkwpower<numkeywords) nkwpower<<=1;
	nkwpower>>=1;
	p=numbytes;index=16;while(index--) *p++=0;
	p=sizelist;
	while((index=*p++)!=255) numbytes[index]=*p++;
	addint("char",TYPECHAR)->thingflags|=THINGUNSIGNED;
	//JASON...
	intthing=dupfix(addint("int",TYPELONG),0);
	longthing=addint("long",TYPELONG);
	addint("short",TYPESHORT);
	addint("void",TYPEVOID);
	addint("float",TYPEFLOAT);
	addint("double",TYPEDOUBLE);
	predef("_ACC_");
	funcend();
}


ioend()
{
	flush();
	fclose(outfile);
}

short ifdeep=0,ifydeep=0;

skipping()
{
	while(at()>=0 && ifdeep!=ifydeep)
		take();
}

donendif()
{
	if(!ifdeep) preerror();
	if(ifydeep==ifdeep) ifydeep--;
	ifdeep--;
}

donif()
{
	if(ifydeep==ifdeep)
	{
		if(ifexpr())
			ifydeep++;
	}
	ifdeep++;
	skipping();
}
donelse()
{
	if(!ifdeep) preerror();
	if(ifydeep+1==ifdeep) ifydeep++;
	else if(ifydeep==ifdeep) ifydeep--;
	skipping();
}

donifdef()
{
char txt[64];
	if(ifydeep==ifdeep)
	{
		preskip();
		pretoken(txt);
		if(finddef(txt))
			ifydeep++;
	}
	ifdeep++;
	skipping();
}
donifndef()
{
char txt[64];
	if(ifydeep==ifdeep)
	{
		preskip();
		pretoken(txt);
		if(!finddef(txt))
			ifydeep++;
	}
	ifdeep++;
	skipping();
}

short nasmdeep=0;
donasm()
{
short ch,ch2;

	if(nasmdeep)
		preerror();
	nasmdeep++;

	while(at()>=0 && nasmdeep)
	{
		ch=take();
		outch(ch);
	}
	if(nasmdeep) {error("Unexpected EOF in asm block");nasmdeep--;}
}
donendasm()
{
	if(!nasmdeep)
		preerror();
	else
		nasmdeep--;
}

checkn(str)
char *str;
{
short len;

	len=strlen(str);
	if(!strncmp(pntr,str,len))
	{
		pntr+=len;
		return 1;
	}
	return 0;
}

dopre()
{
short ch=0,ch2;

	preok=0;
	pntr=preproc;
	while()
	{
		ch2=ch;ch=take();
		if(ch=='/' && at()=='*')
		{
			while()
			{
				ch2=ch;ch=take();
				if(ch<0 || ch2=='*' && ch=='/') break;
			}
			if(ch>=0) continue;
		}
		if(ch<0 || ch=='\n' && ch2!='\\') break;
		if(pntr<preproc+PREMAX-1) *pntr++=ch;
		else preerror();
	}
	*pntr=0;
	col1=preok=1;

	pntr=preproc;
	if(checkn("ifdef")) donifdef();
	else if(checkn("ifndef")) donifndef();
	else if(checkn("endif")) donendif();
	else if(checkn("else")) donelse();
	else if(checkn("if")) donif();
	else if(ifydeep==ifdeep)
	{
		if(checkn("define")) dondefine();
		else if(checkn("include")) doninclude();
		else if(checkn("asm")) donasm();
		else if(checkn("endasm")) donendasm();
	}
}
preskip()
{
char ch;
	while(ch=*pntr)
	{
		if(ch!=' ' && ch!='\t' && ch!=12) break;
		pntr++;
	}
}
symptr finddef(name)
char *name;
{
symptr asym;
short h;
	h=hash8(name);
	asym=ndefs[h];
	while(asym)
	{
		if(!strcmp(name,asym->symname)) break;
		asym=asym->symnext;
	}
	return asym;
}

#define PTMAX 256
#define PTNUM 32

predef(str)
char *str;
{
symptr asym;
short h;

	asym=finddef(str);
	if(!asym)
	{
		h=hash8(str);
		asym=newsym(str);
		asym->symnext=ndefs[h];
		ndefs[h]=asym;
	}
}

dondefine()
{
char str[64];
short len;
symptr asym;
short h;
char *txt;
char partext[PTMAX+2];
char *pars[PTNUM];
short pnum,i;
char *parend=partext+PTMAX;
char *tp,*pp,ch,ch2;
char *name;

	if(symtextpntr>symtexttop) newsymtextblock();
	name=symtextpntr;
	symtextpntr=pretoken(symtextpntr);
	asym=finddef(name);
	if(!asym)
	{
		h=hash8(name);
		asym=newsym(name);
		asym->symnext=ndefs[h];
		ndefs[h]=asym;
	}
	pnum=0;
	if(*pntr=='(')
	{
		pntr++;
		txt=partext;
		while()
		{
			if(pnum==PTNUM) parover();
			pars[pnum]=txt;
			preskip();
			ch=*pntr++;
			if(isalpha(ch) || ch=='_')
			{
				pnum++;
				*txt++=ch;
				while(isalpha(ch=*pntr) || isdigit(ch) || ch=='_')
				{
					if(txt>=parend) parover();
					*txt++=ch;
					pntr++;
				}
				preskip();
				ch=*pntr++;
			}
			*txt++=0;
			if(ch==',') continue;
			if(ch!=')') {--pntr;syntaxerror();}
			break;
		}
		pnum++;
	}
	preskip();
	if(symtextpntr>symtexttop) newsymtextblock();
	if(pnum)
	{
		pnum--;
		tp=pntr;
		pp=symtextpntr+1;
		while()
		{
			ch=*tp++;
			if(ch=='\\') continue;
			if(ch=='"')
			{
				*pp++=ch;
				while()
				{
					ch=*tp++;
					if(!ch) {--tp;syntaxerror();break;}
					if(ch=='\\')
					{
						*pp++=ch;
						if(*tp) *pp++=*tp++;
						else syntaxerror();
						continue;
					}
					*pp++=ch;
					if(ch=='"') break;
				}
			} else if(ch=='\'')
			{
				*pp++=ch;
				while()
				{
					ch=*tp++;
					if(!ch) {--tp;syntaxerror();break;}
					if(ch=='\\')
					{
						*pp++=ch;
						if(*tp) *pp++=*tp++;
						else syntaxerror();
						continue;
					}
					*pp++=ch;
					if(ch=='\'') break;
				}
			} else if(isalpha(ch) || ch=='_')
			{
				txt=str;
				*txt++=ch;
				while()
				{
					ch=*tp;
					if(isalpha(ch) || isdigit(ch) || ch=='_')
						{*txt++=ch;tp++;}
					else break;
				}
				*txt=0;
				for(i=0;i<pnum;i++)
					if(!strcmp(str,pars[i]))
						break;
				if(i<pnum)
				{
					*pp++=~i;
				} else
				{
					txt=str;
					while(ch=*txt++) *pp++=ch;
				}
			} else {*pp++=ch;if(!ch) break;}
		}
		pnum++;
	} else
		strcpy(symtextpntr+1,pntr);
	len=strlen(symtextpntr+1)+2;

	asym->symthing=symtextpntr;
	*symtextpntr=pnum;
	symtextpntr+=len;
}

char *pretoken(str)
char *str;
{
char ch;

	preskip();
	while(ch=*pntr)
	{
		if(!isalpha(ch) && !isdigit(ch) && ch!='_') break;
		*str++=ch;
		pntr++;
	}
	*str++=0;
	return str;
}

#define EXPRMAX 64
char exprstack[EXPRMAX];
char *exprsp;
short oppri;
short opop;
long operval;
char exprflag;
long expr2();


#define OPGET() (*pntr++)
#define OPAT() (*pntr)
#define OPBACK() (*--pntr)

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

ifexpr()
{
long eval;
char txt[64];

	exprsp=exprstack;
	exprflag=0;
	eval=expr2();
	if(exprflag) {sprintf(txt,"Error %x in <#if> expression",exprflag);error(txt);}
	return eval!=0;
}
long expr2()
{
	pushb(0);
	while()
	{
		operand();
		operator();
		if(trytop()) break;
		pushl(operval);
		pushb(opop);
		pushb(oppri);
	}
	popb();
	return operval;
}
trytop()
{
	char toppri,topop;
	long topval;

	while()
	{
		toppri=popb();
		if(oppri>toppri) {pushb(toppri);return oppri==3;}
		topop=popb();
		topval=popl();

		switch(topop)
		{
			case 0: return 1;
			case 1: /* + */
				operval+=topval;
				break;
			case 2: /* - */
				operval=topval-operval;
				break;
			case 3: /* / */
				operval=topval/operval;
				break;
			case 4: /* * */
				operval*=topval;
				break;
			case 5: /* | */
				operval|=topval;
				break;
			case 6: /* & */
				operval&=topval;
				break;
			case 7: /* << */
				operval=topval<<operval;
				break;
			case 8: /* >> */
				operval=topval>>operval;
				break;
			case 9: /* <= */
				operval=topval<=operval;
				break;
			case 10: /* < */
				operval=topval<operval;
				break;
			case 11: /* >= */
				operval=topval>=operval;
				break;
			case 12: /* > */
				operval=topval>operval;
				break;
			case 13: /* % */
				operval=topval%operval;
				break;
			case 14: /* ^ */
				operval=topval^operval;
				break;
			case 15: /* != */
				operval=topval!=operval;
				break;
			case 16: /* == */
				operval=topval==operval;
				break;
			case 17: /* && */
				operval=topval && operval;
				break;
			case 18: /* || */
				operval=topval || operval;
				break;
		}
	}
}

operator()
{
char ch;

	preskip();
	ch=OPGET();
	switch(ch)
	{
		case '+': oppri=12;opop=1;break;
		case '-': oppri=12;opop=2;break;
		case '/': oppri=13;opop=3;break;
		case '*': oppri=13;opop=4;break;
		case '%': oppri=13;opop=13;break;
		case '|':
			if(OPAT()=='|') {OPGET();oppri=4;opop=18;}
			else {oppri=6;opop=5;}
			break;
		case '&':
			if(OPAT()=='&') {OPGET();oppri=5;opop=17;}
			else {oppri=8;opop=6;}
			break;
		case '^': oppri=7;opop=14;break;
		case '<':
			ch=OPGET();
			if(ch=='=') {oppri=10;opop=9;}
			else if(ch=='<') {oppri=11;opop=7;}
			else {OPBACK();oppri=10;opop=10;}
			break;
		case '>':
			ch=OPGET();
			if(ch=='=') {oppri=10;opop=11;}
			else if(ch=='>') {oppri=11;opop=8;}
			else {OPBACK();oppri=10;opop=12;}
			break;
		case '!':
			if(OPGET()=='=') {oppri=9;opop=15;}
			else {OPBACK();OPBACK();oppri=0;opop=0;}
			break;
		case '=':
			if(OPGET()=='=') {oppri=9;opop=16;}
			else {OPBACK();OPBACK();oppri=0;opop=0;}
			break;
		default:
			OPBACK();oppri=3;opop=0;
	}
}

operand()
{
char ch;
char *p;
char negflag=0;
char optxt[64];
symptr asym;
char *pntrsave;

	preskip();
	ch=OPAT();
	if(ch=='-')
	{
		OPGET();
		preskip();
		ch=OPAT();
		negflag++;
	}
	if(isdigit(ch))
	{
		operval=0;
		if(ch=='0' && pntr[1]=='x')
		{
			pntr+=2;
			while()
			{
				ch=tolower(OPGET());
				if(ch<'0' || ch>'9' && ch<'a' || ch>'f') break;
				operval<<=4;
				if(ch<='9') ch-='0';
				else ch-='a'-10;
				operval|=ch;
			}
			OPBACK();
		} else
		{
			while(isdigit(ch=OPGET()))
			{
				operval*=10;
				operval+=ch-'0';
			}
			OPBACK();
		}
	} else if(ch=='\'')
	{
		OPGET();
		operval=0;
		while(ch=OPGET())
		{
			if(!ch) {OPBACK();exprflag|=2;break;}
			if(ch=='\'')
				if(OPGET()!='\'') {OPBACK();break;}
			operval<<=8;operval+=ch;
		}
	} else if(ch=='(')
	{
		OPGET();
		operval=expr2();
		if(OPGET()!=')') {exprflag|=1;OPBACK();}
	} else if(isalpha(ch) || ch=='_')
	{
		pretoken(optxt);
		asym=finddef(optxt);
		if(!asym) operval=0;
		else
		{
			pntrsave=pntr;
			pntr=asym->symthing;
			if(*pntr++)
			{
				exprflag|=4;
				operval=0;
			} else
				operand();
			pntr=pntrsave;
		}
	}
	if(negflag) operval=-operval;
}


char *findenv();

doninclude()
{
char name[256],*np,ch,ch2,err;
char name2[256];
short file;
char *env;

	preskip();
	ch2=*pntr++;
	err=1;
	if(ch2=='<' || ch2=='"')
	{
		if(ch2=='<') ch2='>';
		np=name;
		while(ch=*pntr++)
		{
			if(ch2==ch)
			{
				*np=0;
				err=0;
				break;
			}
			*np++=ch;
		}
	}
	if(err)
	{
		error("#include error");
		return;
	}
	if(ch2=='"')
	{
		if(file=fopen(name,"r"))
		{
			newin(name,file);
			return;
		}
	}

	env=findenv(INCNAME);
	while(env)
	{
		np=name2;
		while(*env && *env!=';')
			*np++=*env++;
		ch=np[-1];
		if(np>name2 && ch!='\\' && ch!='/')
			*np++='/';
		strcpy(np,name);
		if(file=fopen(name2,"r"))
		{
			newin(name,file);
			return;
		}
		if(*env) ++env;
		else env=0;
	}

	sprintf(name2,"#include cannot open %s",name);
	critical(name2);
}

newin(name,file)
char *name;
short file;
{

	if(incount==INMAX-1)
		critical("Too many nested input files");
	incount++;
	ifp=ifiles+incount;
	strcpy(ifp->inname,name);
	ifp->infile=file;
	ifp->lc=1;
	col1=1;preok=1;
	getmore();

}

void outstr(str)
char *str;
{
char ch;
	while(ch=*str++) outch(ch);
}

void outch(ch)
char ch;
{
	if(ch=='\n') tabc=0;
	else    if(ch=='\t') tabc++;
	else if(ch==' ' && tabc<2)
	{
		ch='\t';
		tabc++;
	}
	*outpoint++=ch;
	outhold++;
	if(outhold==IOBUFFLEN)
		flush();
}

flush()
{
	if(cchit()) ccexit();
	if(outhold) write(outfile,outbuff,outhold);
	outpoint=outbuff;
	outhold=0;
}

#define STORE1 if(txt<max) *txt++=take(); else macover()
short getpar(str,max)
char *str,*max;
{
short ch,i,deep;
char *txt=str;

	deep=0;
	while()
	{
		ch=at();
		if(!deep && (ch==',' || ch==')')) break;
		if(ch=='(') deep++;
		else if(ch==')') deep--;
		else if(ch=='"')
		{
			STORE1;
			while()
			{
				ch=at(); if(ch<0) {syntaxerror();break;}
				if(ch=='\\') {STORE1;if(at()<0) continue;}
				STORE1;
				if(ch=='"') break;
			}
			continue;
		} else if(ch=='\'')
		{
			STORE1;
			while()
			{
				ch=at(); if(ch<0) {syntaxerror();break;}
				if(ch=='\\') {STORE1;if(at()<0) continue;}
				STORE1;
				if(ch=='\'') break;
			}
			continue;
		}
		STORE1;
	}
	return txt-str;
}

newmacro(str)
char *str;
{
short len;
char partext[PTMAX+2];
short pnum,i,ch;
char *pars[PTNUM],*txt;
short parlen[PTNUM];

	if(!str) return;
	if(pnum=*str)
	{
		pnum--;
		str++;
		if(at()!='(') syntaxerror();
		take();
		i=0;txt=partext;
		while()
		{
			if(i==PTNUM) parover();
			parlen[i]=len=getpar(txt,partext+PTMAX);
			pars[i++]=txt;
			txt+=len;
			ch=take();
			if(ch==',') continue;
			if(ch!=')') syntaxerror();
			if(i==1 && !len) i--;
			break;
		}
		if(i!=pnum) parerror();
		*txt=0;
		while(i<pnum) {parlen[i]=0;pars[i++]=txt;}
		txt=str;
		i=0;
		while(ch=*txt++)
		{
			if(ch<=127) i++;
			else
			{
				ch=255-ch;
				i+=parlen[ch];
			}
		}
		if(!i) return;
		if(macsp==MACMAX || macrostack>macroblock+(BLOCKSIZE-1024))
			macover();
		macfrees[macsp]=macrostack;
		macstack[macsp++]=macp;
		macp=macrostack;
		while(ch=*str++)
		{
			if(ch<=127) *macrostack++=ch;
			else
			{
				ch=255-ch;
				i=parlen[ch];
				strncpy(macrostack,pars[ch],i);
				macrostack+=i;
			}
		}
		*macrostack++=0;
	} else if(str[1])
	{
		if(macsp==MACMAX)
			macover();
		macfrees[macsp]=0;
		macstack[macsp++]=macp;
		macp=str+1;
	}
}

getmore()
{
	if(cchit()) ccexit();
	ifp->inleft=read(ifp->infile,ifp->inbuff,IOBUFFLEN);
	ifp->inpoint=ifp->inbuff;
	if(!ifp->inleft)
	{
		fclose(ifp->infile);
		incount--;
		ifp=ifiles+incount;
	}
}

short at()
{
short nextch;
top:
	if(macp) nextch=*macp;
	else if(incount>=0) nextch=*ifp->inpoint;
	else return -1;
	if(nextch==13) {take1();goto top;}
	if(col1 && nextch=='#' && preok)
	{
		take1();
		dopre();
		goto top;
	}
	return nextch;
}

short take1()
{
short nextch;
char *mf;
	if(macp)
	{
		nextch=*macp++;
		if(!*macp)
		{
			macp=macstack[--macsp];
			if(mf=macfrees[macsp]) macrostack=mf;
		}
	} else if(incount>=0)
	{
		nextch=*ifp->inpoint++;
		if(nextch=='\n') ifp->lc++;
		if(!--ifp->inleft)
			getmore();
	} else nextch=-1;
	return nextch;
}
short take()
{
short nextch;
top:
	nextch=take1();
	if(nextch==13) goto top;
	if(col1 && nextch=='#' && preok)
	{
		dopre();
		goto top;
	}
	col1= nextch=='\n';
	return nextch;
}

critical(str)
char *str;
{
	error(str);
	flush();
	closeup(2);
}
warn(str) char *str; { emsg(str,0);}
error2(s1,s2)
char *s1,*s2;
{
char txt[80];
	sprintf(txt,"%s %s",s1,s2);
	error(txt);
}
error(str)
char *str;
{
	emsg(str,1);
}
emsg(str,type)
char *str;
{
	if(type)
		retval=1;
	if(incount>=0)
		printf("%s(%d)%s\n",ifp->inname,ifp->lc,str);
	else
		printf("%s\n",str);
}

die(str)
char *str;
{
	printf("%s\n",str);
	closeup(3);
}

thingptr appendlist(v1,v2)
thingptr v1,v2;
{
thingptr ath;
	ath=v1;
	while(v1)
	{
		appendthing(v1,v2);
		v1=v1->thingnext;
	}
	return ath;
}

addtail(v1,v2)
thingptr v1,v2;
{
thingptr ath;
	while(ath=v1->thingnext) v1=ath;
	v1->thingnext=v2;
}

thingptr makestruct(v1,v2,v3)
thingptr v1,v2;
short v3;
{
long count,max,size;
thingptr ath,oth;
char *p;

	if(v1->thingtype!=THINGUNDEF)
		redef();
	count=max=0;
	v1->thingnext=ath=v2;
	while(ath)
	{
		if(ath->thingtype!=THINGUNDEF)
			redef();
		ath->thingtype=THINGVARIABLE;
		size=getsize(ath);
		if(!size) error("Structure definition error");
		moveright(ath,5);
		*ath->thinginfo=TYPEMEMBER;
		*((long *)(ath->thinginfo+1))=count;
		if(~ath->thingflags & THINGLABEL)
			if(v3)
				count+=size;
			else
				if(size>max) max=size;
		oth=ath;
		ath=ath->thingnext;
		addmember(oth->thingsym);
	}
	if(v3) max=count;
	p=v1->thinginfo;
	*p++=ASTRUCT;
	*((long *)p)++=max;
	*p=0;
	v1->thingtype=THINGVARIABLE;
	return v1;
}

thingptr structid(v1)
char *v1;
{
symptr asym;
thingptr ath;

	if(v1)
	{
		asym=findstruct(v1);
		if(asym) return asym->symthing;
		asym=newsym(v1);
	} else
		asym=0;
	ath=allocthing();
	appendarray(ath,0L);
	append(ath,TYPECHAR);
	if(asym)
	{
		asym->symthing=ath;
		ath->thingsym=asym;
		addstruct(asym);
	}
	return ath;
}



moveleft(v1,num)
thingptr v1;
short num;
{
char *p;

	p=v1->thinginfo;
	bcopy(p+num,p,INFOLEN-num);
	clearmem(p+INFOLEN-num,num);
}

moveright(v1,num)
thingptr v1;
short num;
{
char *p;
	p=v1->thinginfo;
	fcopy(p,p+num,INFOLEN-num);
	clearmem(p,num);
}

short swcomp(v1,v2)
swptr v1,v2;
{
short t1,t2;
	t1=v1->asval;
	t2=v2->asval;
	if(t1==t2) return 0;
	if(t1<t2) return -1;
	return 1;
}


deforbreak()
{
	if(sdefault)
		emitref2(sdefault);
	else
		emitbreak();
}

newswitch()
{
	switchnumstack[switchsp]=switchnum;
	switchdefaultstack[switchsp]=sdefault;
	switchstack[switchsp]=nextswitch;
	switchsp++;
	switchnum=0;sdefault=0;
}
doswitch(v1,v2)
enodeptr v1;
TEXT v2;
{
short lct,lct2;
swptr as;
short i,j;
unsigned short min,max,diff;
swptr base;

	lct=alloclabel();
	v1=toax(v1);
	if(*v1->thinginfo==TYPECHAR) v1=totype(v1,TYPEINT);
	freething(v1);
	emitch(BREAKOPEN);
	emitshort(lct);
	emitshort(0);
	if(switchnum)
	{
		base=switchstack[switchsp-1];
		qsort(base,switchnum,sizeof(struct aswitch),swcomp);
		min=base->asval;
		max=(base+switchnum-1)->asval;
		diff=max-min;
		if(diff<8 || diff<switchnum+switchnum)
		{
			if(min)
			{
				emit(" sub ax,");
				emitdec(min);
				emitcr();
			}
			emit(" cmp ax,");
			emitdec(diff+1);
			emit("\n jnc ");
			deforbreak();
			emit("\n movzx eax,ax\n jmp long [eax*4+");
			lct2=alloclabel();
			emitref2(lct2);
			emit("]\n");
			emitref2(lct2);
			i=0;j=0;
			as=base;
			while(i<=diff)
			{
				if(!j) emit(" dd ");
				else emitcomma();
				if(min!=as->asval)
					deforbreak();
				else
				{
					emitref2(as->aslabel);
					as++;
				}
				j++;
				if(j==12) {emitcr();j=0;}
				i++;min++;
			}
			if(j) emitcr();

		} else
		{
			emit(" mov ecx,");
			emitdec(switchnum);
			emit("\n call doswitch\n");
			as=base;
			i=switchnum;
			while(i--)
			{
				emit(" dd ");
				emitref(as->aslabel);
				emit(" dw ");
				if(as->asval>=0)
					emitdec(as->asval);
				else
					{emitch('-');emitdec(-as->asval);}
				emitcr();
				as++;
			}
			emit(" dd ");
			deforbreak();
			emitcr();
		}
	}
	switchsp--;
	switchnum=switchnumstack[switchsp];
	sdefault=switchdefaultstack[switchsp];
	nextswitch=switchstack[switchsp];
	emitsub(v2);
	emitlabel(lct);
	emitch(BREAKCLOSE);
}
docase(v1,v2)
short v1;
TEXT v2;
{
short lct;
char txt[64];
swptr as;

	lct=alloclabel();
	emitlabel(lct);
	emitsub(v2);
	if(switchnum==SWITCHMAX) switchover();
	as=nextswitch++;
	as->asval=v1;
	as->aslabel=lct;
	switchnum++;
}

dodefault(v1)
TEXT v1;
{
short lct;
char txt[64];
	lct=alloclabel();
	emitlabel(lct);
	emitsub(v1);
	if(!sdefault)
		sdefault=lct;
	else
		error("Multiple defaults");
}

thingptr lastdd=0,lastdds=0;
short numinits;
long initcount;
short online;
dodeclare(v1)
thingptr v1;
{
char flag;

	appendthing(v1,vartype);
	endid();
	if(insidefunc || v1->thingflags & THINGPASSED)
	{
		insdeclare(v1);
		if(~v1->thingflags & THINGPASSED)
		{
			lastdd=v1;
			lastdds=0;
			initcount=0;
			numinits=0;
		}
	}
	else
	{
		flag=*v1->thinginfo==FUNCTIONRET || v1->thingflags & (THINGTYPEDEF | THINGEXTERN);
		declare(v1);
		if(!flag)
		{
			lastdd=v1;
			lastdds=0;
			initcount=0;
			numinits=0;
			emitname(v1->thingsym);
			emitch(':');
			online=0;
		}
	}
}
handleinit(v1,v2)
enodeptr v1;
short v2;
{
thingptr ath,temp;
short size;
char *p;
stringptr astring;
symptr asym;

	numinits++;
	if(!lastdd)
		{badinit();return;}
	if(*vartype->thinginfo==ASTRUCT /* vartype->thingnext*/ && *lastdd->thinginfo!=POINTERTO)
	{
		if(lastdds) lastdds=lastdds->thingnext;
		if(!lastdds) lastdds=vartype->thingnext;
		temp=lastdds;
	} else
		temp=lastdd;
	if(insidefunc)
	{
		if(!v2)
		{
			freething(subexpr(enode2(ENDEF,enode1(ENTHING,dupthing(temp)),v1),0));
		} else
		{
			ath=allocthing();
			ath->thingtype=THINGCONST;
			ath->thingvalue=initcount++;
			*ath->thinginfo=TYPELONG;
			freething(subexpr(enode2(ENDEF,enode2(ENARRAY,enode1(ENTHING,dupthing(temp)),enode1(ENTHING,ath)),v1),0));
		}
	} else
	{
		if(v1->enodetype!=ENTHING)
			badconst();
		else
		{
			ath=v1->enodeo1;
			enfree(v1);
			p=temp->thinginfo;
			while(*p==ARRAYOF) p+=5;
			if(*p==TYPEMEMBER) p+=5;
			size=numbytes[*p];
			if(*p==TYPECHAR && *temp->thinginfo==ARRAYOF && *ath->thinginfo==ARRAYOF && ath->thingflags & THINGINTERNAL)
			{
				if(numinits!=1) badinit();
				astring=firststring;
				asym=ath->thingsym;
				while(astring)
					if(astring->stringsym==asym) break;
				if(astring)
				{
					size=dumpstring(astring->stringtext,emit,emitch);
					astring->stringtext=0;
				} else
				{
					size=0;
					error("Inexplicable string error");
				}
			} else
			{
				if(!online)
					switch(size)
					{
						case 1:emit(" db ");break;
						case 2:emit(" dw ");break;
						case 4:emit(" dd ");break;
					}
				else emitcomma();
				if(ath->thingsym)
				{
					if(~ath->thingflags & THINGINTERNAL)
						emitch('_');
					emit(ath->thingsym->symname);
				}
				else emitlong(ath->thingvalue);
				online++;
				if(online==12 || lastdds)
					{emitcr();online=0;}
			}
			freething(ath);
			initcount+=size;
		}
	}
}


endid()
{
long size;

	if(lastdd)
	{
		if(!insidefunc && ~lastdd->thingflags & THINGPASSED)
		{
			if(online) {emitcr();online=0;}
			size=getsize(lastdd);
			if(size>initcount)
			{
				emit(" ds.b ");
				emitlong(size-initcount);
				emitcr();
			} else if(!numinits) emit(":\n");
			dumpstrings();
		}
		lastdds=lastdd=0;
	}
}

declare(v1)
thingptr v1;
{
symptr asym,asym2;
thingptr athing;
short tf;

	if(!v1) return;
	tf=v1->thingflags & THINGFUNC;
	v1->thingflags^=tf;
	if(*v1->thinginfo==FUNCTIONRET && !tf) v1->thingflags |= THINGEXTERN;
	if(v1->thingflags & THINGAUTO) autoerr();
	v1->thingtype=THINGVARIABLE;
	asym=v1->thingsym;
	if(v1->thingflags & THINGTYPEDEF)
	{
		if(findtypedef(asym->symname))
			redef();
		else
			addtypedef(asym);
	} else
	{
		if(asym2=findsym(asym->symname))
		{
			athing=asym2->symthing;
			if(compthings(athing,v1))
				error2("Declaration does not match previous:",asym2->symname);
			if(~athing->thingflags & THINGEXTERN)
			{
				if(~v1->thingflags & THINGEXTERN)
					error2("Multiply defined symbol",asym2->symname);
				else
					v1->thingflags &= ~THINGEXTERN;
			}
			if(~v1->thingflags & THINGEXTERN)
			{
				asym2->symthing=v1;
				v1->thingsym=asym2;
				asym->symthing=athing;
			}
			freesym(asym);
		} else
			addglobal(asym);
	}
}

insdeclare(v1)
thingptr v1;
{
symptr asym,asym2;
thingptr athing;
short size;

	if(!v1) return;
	asym=v1->thingsym;
	if(asym2=findauto(asym->symname))
		if(~v1->thingflags&THINGPASSED || asym2->symthing->thingvalue!=-1)
			redef();
	v1->thingtype=THINGVARIABLE;
	size=getsize(v1);
	if(size==1) size=2;
	if(v1->thingflags & THINGOUTSIDE)
	{
		if(v1->thingflags&THINGPASSED)
		{
			v1->thingvalue=size;
			if(*v1->thinginfo==ARRAYOF)
			{
				moveleft(v1,4);
				*v1->thinginfo=POINTERTO;
			}
		}
		else
			baddec();
	} else
	{
		if(v1->thingflags&THINGPASSED)
			baddec();
		if(*v1->thinginfo==FUNCTIONRET)
			error("Illegal function declaration");
		v1->thingflags|=THINGAUTO;
		facount-=size;
		v1->thingvalue=facount;
		addauto(asym);
	}
}


char *xalloc(len)
short len;
{
char *loc;

	loc=malloc(len);
	if(loc)
		clearmem(loc,len);
	else
		nomem();
	return loc;
}

/*
listmem()
{
long *z;
char ch;

	z=himembase;
	while(z)
	{
		ch=z[3]&1 ? '*' : ' ';
		printf("%08lx %08lx %08lx %08lx %c\n",z,z[0],z[1],z[2],ch);
		z=*z;
	}
}
*/

char *newstmt()
{
char *ip;
	ip=ststart;
	*topoint++=0;
	ststart=topoint;
	regmapinit();
	return ip;
}
initstmt()
{
	ststart=topoint=textbase;
}
emitsub(str)
char *str;
{
	if(str)
	{
		*topoint++=SUBCHAR;
		*((char **)topoint)++=str;
	}
}
emitshort(sh)
short sh;
{
	*((short *)topoint)++=sh;
}
emitch(ch)
char ch;
{
	if(topoint<texttop)
		*topoint++=ch;
	else toobig();
}
emit(str)
char *str;
{
	if(topoint>=texttop)
		toobig();
	strcpy(topoint,str);
	topoint+=strlen(str);
}

dumptext(str)
char *str;
{
	ldt(str);
	initstmt();
}
ldt(str)
char *str;
{
char ch;

	while(ch=*str++)
	{
		if(ch<128) outch(ch);
		else if(ch==SUBCHAR)
			ldt(*((char **)str)++);
		else if(ch==BREAKREF)
		{
			outref(*breaksp);
			if(!*breaksp) error("Naked break somewhere");
		} else if(ch==CONTREF)
		{
			outref(*contsp);
			if(!*contsp) error("Naked continue somewhere");
		}
		else if(ch==BREAKOPEN)
		{
			*++breaksp=*((short *)str)++;
			*++contsp=*((short *)str)++;
			if(!*contsp) *contsp=contsp[-1];
		}
		else if(ch==BREAKCLOSE)
		{
			--breaksp;
			--contsp;
		}
	}
}

newsymtextblock()
{
char **ns;
	ns=malloc(BLOCKSIZE+sizeof(void *));
	if(!ns) nomem();
	*ns=symtextblocks;
	symtextblocks=ns;
	symtextpntr=ns+1;
	symtexttop=symtextpntr+(BLOCKSIZE-STRINGMAX);
}
newsymblock()
{
char **ns;
	ns=malloc(BLOCKSIZE+sizeof(void *));
	if(!ns) nomem();
	*ns=symblocks;
	symblocks=ns;
	nextnewsym=ns+1;
	newsymsleft=BLOCKSIZE/sizeof(struct sym);
}
newthingblock()
{
char **ns;
	ns=malloc(BLOCKSIZE+sizeof(void *));
	if(!ns) nomem();
	*ns=thingblocks;
	thingblocks=ns;
	nextnewthing=ns+1;
	newthingsleft=BLOCKSIZE/sizeof(struct thing);
}
newenodeblock()
{
char **ns;
	ns=malloc(BLOCKSIZE+sizeof(void *));
	if(!ns) nomem();
	*ns=enodeblocks;
	enodeblocks=ns;
	nextnewenode=ns+1;
	newenodesleft=BLOCKSIZE/sizeof(struct enode);
}
newstringblock()
{
char **ns;
	ns=malloc(BLOCKSIZE+sizeof(void *));
	if(!ns) nomem();
	*ns=stringblocks;
	stringblocks=ns;
	nextnewstring=ns+1;
	newstringsleft=BLOCKSIZE/sizeof(struct string);
}


toobig() {critical("Function too big");}
syntaxerror() {error("Syntax error");}
lverror() {error("Must have lvalue");}
badop() {error("Illegal operation");}
converror() {error("Illegal combination");}
unknown() {error("Unknown identifier");}
autoerr() {error("Meaningless use of auto");}
redef() {error("Illegal redefinition");}
baddec() {error("Illegal declaration");}
badinit() {error("Illegal initializer");}
badconst() {error("Illegal constant expression");}
parover() {critical("Too many parameters or something");}
parerror() {error("Incorrect number of parameters");}
macover() {critical("Macro expansion error");}
preerror() {critical("Preprocessor directive error");}
nomem() {critical("Out of memory!");}
ccexit() {die("** Break");}
switchover() {critical("Too many case statements");}
div0error() {error("Divide by zero");}

main(argc,argv)
short argc;
char **argv;
{
char str[128],txt[128];
short file;

	if(argc<2)
	{
		printf("ACC compiler by David Ashley Copyright (c) 1997\n");
		printf("-- Please register this --\n");
		printf("USE: acc cfile [-o<outputname>]\n");
		printf("  acc adds '.c' to the input filename.\n");
		printf("  acc adds '.a' to the output filename.\n");
		return;
	}

	initstuff();

	ifiles=lalloc(INMAX*sizeof(struct ifile));
	if(!ifiles) nomem();
	outbuff=lalloc(IOBUFFLEN);
	if(!outbuff) nomem();
	outhold=0;

	macstack[macsp=0]=0;
	incount=-1;
	sprintf(str,"%s.c",argv[1]);
	file=fopen(str,"r");
	if(!file)
	{
		sprintf(txt,"Cannot open %s",str);
		critical(txt);
	}

	newin(str,file);

	if(argc>2 && argv[2][0]=='-' && argv[2][1]=='o')
		sprintf(str,"%s.a",argv[2]+2);
	else
		sprintf(str,"%s.a",argv[1]);
	outfile=fopen(str,"w");
	if(!outfile)
	{
		printf("Cannot open %s for output\n",str);
		closeup(1);
	}
	tabc=0;
	outpoint=outbuff;

	yyparse();

	outpublics();

	flush();
	fclose(outfile);

	closeup(retval);
}
