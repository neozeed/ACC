#define NULL 0L
#define STRINGMAX 2048

#define ISWHITE(x) ((x)==' ' || (x)=='\t' || (x)=='\n' || (x)==12)

typedef struct string {
	struct string *stringnext;
	struct sym *stringsym;
	char *stringtext;
} *stringptr;

typedef struct sym {
	struct sym *symnext;
	struct thing *symthing;
	char *symname;
} *symptr;
struct kw {
	char *kwname;
	short kwval;
	short kwyylval;
};
#define INFOLEN 32
typedef struct thing {
	char thingtype;
	char thingreg;
	struct thing *thingnext;
	struct sym *thingsym;
	long thingvalue;
	short thingflags;
	char thinginfo[INFOLEN];
} *thingptr;
typedef struct enode {
	short enodetype;
	void *enodeo1;
	void *enodeo2;
	void *enodeo3;
} *enodeptr;

#define FARRITH 1

#define THINGUNDEF 0
#define THINGCONST 1
#define THINGVARIABLE 2
#define THINGREGISTER 3
#define THINGCAST 4

#define TYPECHAR 1
#define TYPESHORT 2
#define TYPELONG 3
#define TYPEINT TYPESHORT
#define POINTERTO 4
#define ARRAYOF 5
#define ASTRUCT 6
#define FUNCTIONRET 7
#define TYPEMEMBER 8
#define TYPEFLOAT 9
#define TYPEDOUBLE 10
#define TYPEVOID 11

/* thingflags */
#define THINGPASSED 1
#define THINGAUTO 2
#define THINGSTATIC 4
#define THINGEXTERN 8
#define THINGFLREGISTER 16
#define THINGTYPEDEF 32
#define THINGUNSIGNED 64
#define THINGADDROF 128
#define THINGIND 256
#define THINGINTERNAL 512
#define THINGFUNC 1024
#define THINGQUIET 2048
#define THINGOUTSIDE 4096
#define THINGLABEL 8192

#define ENTHING 0
#define ENFCALL 1
#define ENDEF 2
#define ENADD 3
#define ENSUB 4
#define ENMUL 5
#define ENDIV 6
#define ENAND 7
#define ENOR 8
#define ENXOR 9
#define ENIND 10
#define ENPREINC 11
#define ENPOSTINC 12
#define ENPREDEC 13
#define ENPOSTDEC 14
#define ENPAREN 15
#define ENCOMMA 16
#define ENUNARY 17
#define ENADDROF 18
#define ENEQ 19
#define ENNE 20
#define ENGT 21
#define ENLE 22
#define ENLT 23
#define ENGE 24
#define ENANDAND 25
#define ENOROR 26
#define ENQC 27
#define ENNOT 28
#define ENARRAY 29
#define ENCAST 30
#define ENNOTZ 31
#define ENRR 32
#define ENLL 33
#define ENMOD 34
#define ENISREF 35
#define ENSREF 36
#define ENADDEQ 37
#define ENSUBEQ 38
#define ENDIVEQ 39
#define ENMULEQ 40
#define ENANDEQ 41
#define ENOREQ 42
#define ENXOREQ 43
#define ENRREQ 44
#define ENLLEQ 45
#define ENMODEQ 46

#define OPDEF 1
#define OPOPDEF 2
#define OPREVERSABLE 4
#define OPCOMP 8
#define OPLAZY 16

enodeptr enode1(),enode2(),enode3(),enalloc();
symptr findsym(),addsym(),newsym(),finddef(),findstruct(),findauto();
thingptr append(),appendthing(),appendarray(),appendlist(),makestruct(),findmember(),findtypedef();
thingptr toreg(),toregn(),copytoreg(),binop(),reduce(),incdec(),def(),indirect(),una(),doisref();
thingptr compop(),toax(),tocx(),structid();
thingptr subexpr(),safeexpr();
extern thingptr intthing;
thingptr constop1(),constop2();
char *infotail();
extern thingptr vartype;

thingptr allocthing(),dupthing(),alloccast(),newdeclid(),dupfix(),newid();
stringptr allocstring();
short skipwhite();

struct kw *findkeyword();
extern char *compnames[];
extern char *regnames[];
extern stringptr firststring,laststring;

extern short numkeywords,nkwpower;
extern struct kw keywords[];
extern short facount,fpcount;
extern thingptr lastfunc;
extern char opflags[];
short at(),take();
char *xalloc();
#define MAXPARAMS 64
#define LABELCHAR 'x'
extern short infolens[];
extern symptr *ndefs,*globals,*autos;
long getsize(),getscale();
thingptr totype(),forcetype(),doop(),dosizeof(),scale();
extern unsigned short curfuncret;
#define SUBCHAR 0xff
#define BREAKREF 0xfe
#define BREAKOPEN 0xfd
#define BREAKCLOSE 0xfc
#define CONTREF 0xfb
#define RETREF 0xfa
#define EAX 0
#define EBX 1
#define EDX 2
#define ECX 3
extern char bits[];
typedef char *TEXT;
extern char flagslist[];
extern char insidefunc;
extern char numbytes[];
extern char preok;
extern unsigned short textseg;
extern char *preproc;
#define PREMAX 2048
extern unsigned short *breaksp,*contsp;
char *newstmt();
char *malloc(),*mallocl(),*lalloc();
extern char *symtextpntr,*symtexttop;
char *pretoken();
