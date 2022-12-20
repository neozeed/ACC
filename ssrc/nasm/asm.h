#define M68000 0
#define Z80 1
#define X86 2
#define MAXIN 3
#define EXPRMAX 256
#define MACDEPTH 10
#define LF 10
#define ATTRWHITE 1
#define ATTRSYM 2
#define ATTRFSYM 4
#define ATTROP 8
#define ATTRNUM 16
#define ATTRHEX 32
#define CHUNK 0xffff
#define LOCAL '.'
/* leave 1.5K for macro expansion */
#define MACSIZE 0x600
#define MAXDB 65536L
#define SYMMAX 64

#define iswhite(ch) (attr[ch] & ATTRWHITE)
#define isokfirst(ch) (attr[ch] & ATTRFSYM)
#define isoksym(ch) (attr[ch] & ATTRSYM)
#define isokop(ch) (attr[ch] & ATTROP)
#define isoknum(ch) (attr[ch] & ATTRNUM)
#define ishex(ch) (attr[ch] & ATTRHEX)
#define tohex(ch) (ch<'A' ? ch-'0' : (ch&15)+9)

#define ERR 99
#define ABSTYPE 0
#define RELTYPE 1
#define REGTYPE 2
#define XREFTYPE 3
#define MACTYPE 4
#define NOTHING 98

struct anopcode
{
	char *opcodename;
	int (*opcodehandler)();
};

struct reference
{
	struct reference *refnext;
	long refoff;
	short reftype;
};

struct sym
{
	char *symtext;
	struct sym *symnext;
	long symvalue;
	char symtype;
	char symflags;
	unsigned int symnum;
	unsigned int symunique;
	struct reference *symref;
	struct sym *sympublic;
	long symdelta;
};
/* sym flags */
#define APUBLIC 1
#define ADEF 2


struct oplist
{
	struct anopcode *listopcodes;
	int numops,powerops;
};

extern struct oplist z80list,scanlist,directlist,x86list,*currentlist;
int (*scan())();
/*extern struct anopcode scantab[];
extern struct anopcode z80codes[];*/
extern struct anopcode directs[];
extern struct anopcode x86codes[];

extern long exprval; /* expr fills in */

extern char exprstack[EXPRMAX];
extern char *exprsp;

extern int eaword1; /* effectaddr fills in */
extern int eaword2;
extern int ealen;
extern int eabits;
extern int eaop;
extern int earel;

extern long operval;
extern long soffset;
extern struct sym *nextsym;
extern unsigned nexttext;
extern unsigned maxlines;
extern int numopen;
extern char options[26];
extern int outfile,listfile;
extern long pcount,pcmax,z80zero;
extern long pline;
extern int pass;
extern int cline;
extern char *macstack;
extern char *macpars[10];
extern int maclens[10];
extern char attr[128];
extern int symcount;
extern int errorfile;
extern int errorcount;
extern char **xdefhead;
extern char **xrefhead;
extern char **blockhead;
extern long blockcount;
extern struct sym *lastxref;

/*-----------------All chars follow------*/
extern char alabel; /* flag, 1 if this line had a label */
extern struct sym linelabel,symbol,symbol2,opsym;
extern char ltext[SYMMAX+2];
extern char stext[SYMMAX+2];
extern char stext2[SYMMAX+2];
extern char opcode[80];
extern char variant;
extern char optl,opto;
extern char exprtype;
extern char exprflag;
extern char opertype;
extern char phase;
extern char storing;
extern char oppri;
extern char opop;
extern char depth,ydepth;
extern char expanding;
extern char inmac;
extern char cpu;
extern char xrdflag;
extern char filename[80];
extern char origname[80];
extern char umac[3];
extern char *TREAD;
extern char *TWRITE;
extern extern struct sym *symbols;

extern struct sym *findsym();
extern struct sym *addsym();
extern char *inpoint;
#define at() (*inpoint)
#define get() (*inpoint++)
#define back() (*--inpoint)
char *storeline();
extern char *textpoint;
char *removecr();
