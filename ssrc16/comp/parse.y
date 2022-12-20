%{
#include "comp.h"
#define YYDEBUG 0
#ifdef _ACC_
#define YYSTYPE long
#endif

%}
%token IF ELSE 
%token SWITCH CASE BREAK FOR WHILE DO CONTINUE
%token DEFAULT GOTO RETURN
%token NUM SYMBOL STRING ATYPEDEF STRUCTUNION SCSPEC
%left ','
%right '=' DEFOP   /* = += -= *= /= %= &= |= ^= >>= <<= */
%left '?' ':'
%left OROR
%left ANDAND
%left '|'
%left '^'
%left '&'
%left EQ NE
%left '<' '>' LE GE
%left RR LL
%left '+' '-'
%left '*' '/' '%'
%right IND ADDROF '~' PLPL MIMI INV UNARY SIZEOF CAST NOTZ
%left FCALL ARRAY RA DOT
%expect 7
%%

program:
	/* nothing */
	| prog2
	;

prog2:
	external_definition
	| prog2 external_definition
	;

external_definition:
	 function_definition
	| init_declaration {dumptext($1)}
/*	| '?' SYMBOL ';' {list(findsym($2)->symthing)}*/
	;

function_definition:
	function_header compound {outfunc($2)}
	;

function_header:
	var_type declarator opt_declaration_list {funcstart($2,$1);freething($1)}
	| declarator opt_declaration_list {funcstart($1,intthing)}
	;

opt_declaration_list:
	/* nothing */
	| declaration_list
	;

compound:
	'{' init_declaration_list statement_list '}' {emitsub($2);emitsub($3);$$=newstmt()}
	| '{' statement_list '}' {$$=$2}
	| '{' init_declaration_list '}' {$$=$2}
	| '{' '}' {$$=0}
	;

parameter:
	SYMBOL {newparm($1)}
	| var_type2 declarator {ansidec($2,$1)}
	| var_type2 abstract {freething($1);freething($2)}
	| var_type2 {freething($1)}
	;

parameter_list:
	parameter
	| parameter ',' parameter_list
	;

declarator:
	SYMBOL {$$=newdeclid($1)}
	| declarator '(' parameter_list ')' %prec FCALL {checkparmok($1);append($1,FUNCTIONRET)}
	| declarator '(' ')' %prec FCALL {append($1,FUNCTIONRET)}
	| '*' declarator %prec IND {$$=$2;append($2,POINTERTO)}
	| '(' declarator ')' {$$=$2}
	| declarator '[' cexprop ']' %prec ARRAY {appendarray($1,$3)}
	;

type_name:
	var_type2 abstract {$$=appendthing($2,$1);freething($1)}
	| var_type2 {$$=appendthing(alloccast(),$1);freething($1)}
	;

abstract:
	'(' abstract ')' {$$=$2}
	| '*' abstract {$$=append($2,POINTERTO)}
	| '*' {$$=append(alloccast(),POINTERTO)}
	| abstract '(' ')' {$$=append($1,FUNCTIONRET)}
	| '(' ')' {$$=append(alloccast(),FUNCTIONRET)}
	| abstract '[' cexpr ']' {$$=appendarray($1,$3)}
	| '[' cexpr ']' {$$=appendarray(alloccast(),$2)}
	;

sizeofobj:
	SIZEOF '(' type_spec abstract ')' {$$=appendthing($4,$3)}
	| SIZEOF '(' var_type2 ')' {$$=$3}
	;

cexprop:
	/* nothing */ {$$=0}
	| cexpr
	;
cexpr:
	NUM {$$=((thingptr)$1)->thingvalue;freething($1)}
	| cexpr '+' cexpr {$$=$1+$3}
	| cexpr '-' cexpr {$$=$1-$3}
	| cexpr '*' cexpr {$$=$1*$3}
	| cexpr '/' cexpr {$$=$1/$3}
	| cexpr LL cexpr {$$=$1<<$3}
	| cexpr RR cexpr {$$=$1>>$3}
	| '-' cexpr %prec UNARY {$$=-$2}
	| '(' cexpr ')' {$$=$2}
	;

statement_list:
	statement
	| statement_list statement {emitsub($1);emitsub($2);$$=newstmt()}
	;

var_type2:
	sc_specifier type_spec {$$=dupfix($2,$1)}
	| type_spec {$$=dupfix($1,0)}
	| sc_specifier {$$=dupfix(intthing,$1)}
	;

var_type:
	var_type2 {vartype=$1}
	;

sc_specifier:
	SCSPEC
	| sc_specifier SCSPEC {$$=$1 | $2}
	;

type_spec:
	ATYPEDEF
	| STRUCTUNION '{' struct_list '}' {$$=makestruct(structid(NULL),$3,$1)}
	| STRUCTUNION SYMBOL '{' struct_list '}' {$$=makestruct(structid($2),$4,$1)}
	| STRUCTUNION SYMBOL {$$=structid($2)}
	;

struct_list:
	struct_decl
	| struct_list struct_decl {addtail($1,$2)}
	;

struct_decl:
	var_type2 struct_decl_list ';' {$$=appendlist($2,$1);freething($1)}
	;

struct_decl_list:
	declarator
	| struct_decl_list ',' declarator {addtail($1,$3)}
	;

declaration_list:
	declaration
	| declaration_list declaration
	;

declaration:
	var_type declarator_list ';' {freething($1)}
	;

declarator_list:
	declarator {((thingptr)$1)->thingflags |= THINGOUTSIDE;dodeclare($1)}
	| declarator_list ',' declarator {((thingptr)$1)->thingflags |= THINGOUTSIDE;dodeclare($3)}
	;

init_declaration_list:
	init_declaration
	| init_declaration_list init_declaration {emitsub($1);emitsub($2);$$=newstmt()}
	;

init_declaration:
	var_type init_declarator_list ';' {endid();freething($1);$$=newstmt()}
	;

init_declarator_list:
	/* nothing */ {$$=0}
	| init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator:
	declarator {dodeclare($1)}
	| init_dec2 expr {handleinit($2,0)}
	| init_dec2 '{' initlist '}'
	;

init_dec2:
	declarator '=' {dodeclare($1)}
	;

initlist:
	expr {handleinit($1,1)}
	| initlist ',' expr {handleinit($3,1)}
	;

statement:
	';' {$$=0}
	| SYMBOL ':' statement {dolabel($1,$3);$$=newstmt()}
	| RETURN opexpr ';' {doreturn($2);$$=newstmt()}
	| CONTINUE ';' {docont();$$=newstmt()}
	| BREAK ';' {dobreak();$$=newstmt()}
	| GOTO SYMBOL ';' {dogoto($2);$$=newstmt()}
	| commaexpr ';'  {freething(subexpr($1,0));$$=newstmt()}
	| compound
	| IF cond statement {doif($2,$3);$$=newstmt()}
	| IF cond statement ELSE statement {doifelse($2,$3,$5);$$=newstmt()}
	| WHILE cond statement {dowhile($2,$3);$$=newstmt()}
	| FOR '(' opexpr ';' opexpr ';' opexpr ')' statement {dofor($3,$5,$7,$9);$$=newstmt()}
	| DO statement WHILE cond ';' {dodowhile($2,$4);$$=newstmt()}
	| switchkw '(' expr ')' statement {doswitch($3,$5);$$=newstmt()}
	| CASE cexpr ':' statement {docase((int)$2,$4);$$=newstmt()}
	| DEFAULT ':' statement {dodefault($3);$$=newstmt()}
	;

switchkw:
	SWITCH {newswitch()}
	;

cond:
	'(' opexpr ')' {$$=$2}
	;

commaexpr:
	expr
	| commaexpr ',' commaexpr {$$=enode2(ENCOMMA,$1,$3)}
	;

expr:
	primary

	| expr '+' expr {$$ = enode2(ENADD,$1,$3)}
	| expr '-' expr {$$ = enode2(ENSUB,$1,$3)}

	| expr '/' expr {$$ = enode2(ENDIV,$1,$3)}
	| expr '%' expr {$$ = enode2(ENMOD,$1,$3)}
	| expr '*' expr {$$ = enode2(ENMUL,$1,$3)}

	| expr RR expr  {$$ = enode2(ENRR,$1,$3)}
	| expr LL expr  {$$ = enode2(ENLL,$1,$3)}

	| expr '&' expr {$$ = enode2(ENAND,$1,$3)}

	| expr '|' expr {$$ = enode2(ENOR,$1,$3)}

	| expr '^' expr {$$ = enode2(ENXOR,$1,$3)}

	| expr EQ expr {$$ = enode2(ENEQ,$1,$3)}
	| expr NE expr {$$ = enode2(ENNE,$1,$3)}

	| expr '<' expr {$$ = enode2(ENLT,$1,$3)}
	| expr '>' expr {$$ = enode2(ENGT,$1,$3)}
	| expr GE expr {$$ = enode2(ENGE,$1,$3)}
	| expr LE expr {$$ = enode2(ENLE,$1,$3)}

	| expr ANDAND expr {$$ = enode2(ENANDAND,$1,$3)}

	| expr OROR expr {$$ = enode2(ENOROR,$1,$3)}

	| expr '?' expr ':' expr {$$=enode3(ENQC,$1,$3,$5)}

	| expr DEFOP expr {$$=enode2((int)($2),$1,$3)}
	| expr '=' expr  {$$=enode2(ENDEF,$1,$3)}

	| PLPL expr {$$=enode1(ENPREINC,$2)}
	| expr PLPL {$$=enode1(ENPOSTINC,$1)}
	| MIMI expr {$$=enode1(ENPREDEC,$2)}
	| expr MIMI {$$=enode1(ENPOSTDEC,$1)}
	| '(' type_name ')' expr %prec CAST {$$=enode2(ENCAST,$4,$2)}
	| '&' expr %prec ADDROF {$$=enode1(ENADDROF,$2)}
	| '*' expr  %prec IND {$$ = enode1(ENIND,$2)}
	| '-' expr %prec UNARY {$$=enode1(ENUNARY,$2)}
	| '~' expr %prec INV {$$=enode1(ENNOT,$2)}
	| '!' expr %prec NOTZ {$$=enode1(ENNOTZ,$2)}
	;

primary:
	SYMBOL {$$=enode1(ENTHING,newid($1))}
	| STRING {$$=enode1(ENTHING,$1)}
	| NUM {$$=enode1(ENTHING,$1)}
	| '(' expr ')'   {$$=enode1(ENPAREN,$2)}
	| primary '(' opexpr ')' {$$=enode2(ENFCALL,$1,$3)}
	| primary '[' expr ']' {$$=enode2(ENARRAY,$1,$3)}
	| sizeofobj {$$=enode1(ENTHING,dosizeof($1))}
	| primary RA SYMBOL {$$ = enode2(ENISREF,$1,findmember($3))}
	| primary '.' SYMBOL %prec DOT {$$ = enode2(ENSREF,$1,findmember($3))}
	;

opexpr:
	/* nothing */ {$$=0}
	| commaexpr
	;

%%

struct kw keywords[]={
"auto",SCSPEC,THINGAUTO,
"break",BREAK,0,
"case",CASE,0,
"continue",CONTINUE,0,
"default",DEFAULT,0,
"do",DO,0,
"else",ELSE,0,
"extern",SCSPEC,THINGEXTERN,
"for",FOR,0,
"goto",GOTO,0,
"if",IF,0,
"label",SCSPEC,THINGLABEL,
"register",SCSPEC,THINGFLREGISTER,
"return",RETURN,0,
"sizeof",SIZEOF,0,
"static",SCSPEC,THINGSTATIC,
"struct",STRUCTUNION,1,
"switch",SWITCH,0,
"typedef",SCSPEC,THINGTYPEDEF,
"union",STRUCTUNION,0,
"unsigned",SCSPEC,THINGUNSIGNED,
"while",WHILE,0,
0,0
};

int skipwhite()
{
int ch;
	for(;;)
	{
		while((ch=take()) && ISWHITE(ch));
		if(ch!='/' || at()!='*') break;
		preok=0;
		for(;;)
		{
			ch=take();
			if(ch=='*' && at()=='/') {take();break;}
		}
		preok=1;
	}
	return ch;
}

char *symadvance;
int token(ch2)
char ch2;
{
int ch;
char *p;
	if(symtextpntr>symtexttop) newsymtextblock();
	p=symtextpntr;
	*p++=ch2;
	while(isalpha(ch=at()) || isdigit(ch) || ch=='_') *p++=take();
	*p++=0;
	symadvance=p;
}

skipcr()
{
	while(at()!=10) take();
}

getoct()
{
int val;
	val=0;
	while(isdigit(at())) {val<<=3;val+=take()-'0';}
	return val;
}

yylex()
{
int ch;
int ch2;
char *p;
symptr asym;
stringptr astring;
thingptr athing;
long val;
char str[STRINGMAX];
char islong=0;
struct kw *akw;

top:
	ch=skipwhite();
	ch2=at();
	switch(ch)
	{
	case 0: return -1;
	case '0': case '1': case '2': case '3': case '4':
	case '5': case '6': case '7': case '8': case '9':
		if(ch=='0' && ch2=='x')
		{
			val=0;
			take();
			while(isdigit(ch=tolower(at())) || ch>='a' && ch<='f')
			{
				val<<=4;
				val+=ch<'a' ? ch-'0' : ch-'a'+10;
				take();
			}
		} else if(ch=='0')
		{
			val=0;
			while((ch=at())>='0' && ch<='7') {val<<=3;val+=ch-'0';take();}
		} else
		{
			val=ch-'0';
			while(isdigit(ch=at())) {val*=10;val+=ch-'0';take();}
		}
		if(ch=='l' || ch=='L') {take();islong=1;}
aconst:
		athing=allocthing();
		athing->thingtype=THINGCONST;
		athing->thingvalue=val;
		yylval=athing;
		if(islong)
			*athing->thinginfo=TYPELONG;
		else
		{
			*athing->thinginfo=TYPESHORT;
			if(val<-0x8000 || val>0xffff) warn("Numeric constant overflow");
		}
		return NUM;
	case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g': case 'h': case 'i':
	case 'j': case 'k': case 'l': case 'm': case 'n': case 'o': case 'p': case 'q': case 'r':
	case 's': case 't': case 'u': case 'v': case 'w': case 'x': case 'y': case 'z': case '_':
	case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G': case 'H': case 'I':
	case 'J': case 'K': case 'L': case 'M': case 'N': case 'O': case 'P': case 'Q': case 'R':
	case 'S': case 'T': case 'U': case 'V': case 'W': case 'X': case 'Y': case 'Z':
		token(ch);
		if(akw=findkeyword(symtextpntr))
		{
			yylval=akw->kwyylval;
			return akw->kwval;
		} else if(asym=finddef(symtextpntr))
		{
			newmacro(asym->symthing);
			goto top;
		} else if(yylval=findtypedef(symtextpntr))
			return ATYPEDEF;
		yylval=symtextpntr;
		symtextpntr=symadvance;
		return SYMBOL;
	case '\'':
		if(ch2=='\\')
		{
			take();
			ch=take();
			if(ch=='t') val=9;
			else if(ch=='n') val=10;
			else if(ch=='r') val=13;
			else if(ch=='0')
				val=getoct();
			else val=ch;
		} else
			val=take();
		ch=at();
		if(ch!='\'')
			error("Character constant error");
		else
			take();
		goto aconst;
	case '"':
		athing=allocthing();
		if(symtextpntr>symtexttop) newsymtextblock();
		p=symtextpntr;
		sprintf(symtextpntr,"%c%d",LABELCHAR,allocsurelabel());
		symtextpntr+=strlen(symtextpntr)+1;
		athing->thingsym=asym=newsym(p);
		athing->thingflags|=THINGINTERNAL;
		athing->thingtype=THINGVARIABLE;

		if(symtextpntr>symtexttop) newsymtextblock();
		p=symtextpntr;

		val=1;
		while()
		{
			ch=take();
			if(ch=='"') break;
			if(ch=='\\')
			{
				ch=take();
				if(ch=='\n') continue;
				if(ch=='n') ch='\n';
				else if(ch=='t') ch='\t';
				else if(ch=='r') ch=13;
				else if(ch=='0') ch=getoct();
			} else if(ch=='\n')
			{
				error("Missing second \" in string constant");
				break;
			}
			*symtextpntr++=ch;val++;if(val==STRINGMAX) critical("String too long");
		}
		*symtextpntr++=0;
		astring=allocstring();
		if(!firststring)
			firststring=astring;
		else
			laststring->stringnext=astring;
		laststring=astring;
		astring->stringnext=NULL;
		astring->stringsym=asym;
		astring->stringtext=p;
		appendarray(athing,val);
		append(athing,TYPECHAR);
		yylval=athing;
		return STRING;
	case '=': if(ch2=='=') {take();return EQ;}
		break;
	case '!': if(ch2=='=') {take();return NE;}
		break;
	case '-': if(ch2=='-') {take();return MIMI;}
		else if(ch2=='>') {take();return RA;}
		else if(ch2=='=') {take();yylval=ENSUBEQ;return DEFOP;}
		break;
	case '+': if(ch2=='+') {take();return PLPL;}
		else if(ch2=='=') {take();yylval=ENADDEQ;return DEFOP;}
		break;
	case '>': if(ch2=='=') {take();return GE;}
		else if(ch2=='>')
		{
			take();
			if(at()=='=')
				{take();yylval=ENRREQ;return DEFOP;}
			else return RR;
		}
		break;
	case '<': if(ch2=='=') {take();return LE;}
		else if(ch2=='<')
		{
			take();
			if(at()=='=')
				{take();yylval=ENLLEQ;return DEFOP;}
			else return LL;
		}
		break;
	case '&': if(ch2=='&') {take();return ANDAND;}
		else if(ch2=='=') {take();yylval=ENANDEQ; return DEFOP;}
		break;
	case '|': if(ch2=='|') {take();return OROR;}
		else if(ch2=='=') {take();yylval=ENOREQ;return DEFOP;}
		break;
	case '^': if(ch2=='=') {take();yylval=ENXOREQ;return DEFOP;}
		break;
	case '*': if(ch2=='=') {take();yylval=ENMULEQ;return DEFOP;}
		break;
	case '/': if(ch2=='=') {take();yylval=ENDIVEQ;return DEFOP;}
		break;
	case '%': if(ch2=='=') {take();yylval=ENMODEQ;return DEFOP;}
		break;
	default:
		break;
	}
	return ch;
}
yyerror(msg)
char *msg;
{
	critical(msg);
}
