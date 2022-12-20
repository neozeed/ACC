
/*      LIFE.C          The much implemented game of Life invented by
John Conway

				This version was written to illustrate the
use of the C88
				screen and keyboard interface. Use C option
for color display.

				To generate:
				A>C88 B:LIFE
				A>ASM88 B:PCIO
				A>BIND B:LIFE B:PCIO            */

/*Modified October 17, 1986 to allow speed control. This seemed necessary
if the program was to be amusing over the range of PC's from PC to 16 MHZ AT.
Changes by Kevin Jones, 351 Lestertown Road, Groton, CT 06340; 203/445-1709.
This modification includes delay(), getspeed(), getsec(), all lines marked
kj1 and appropriate instruction text. */

/*
  global constant and data declarations
*/

#define ROWS    24
#define COLS    80

/* control key translations */
#define up_char 30
#define down_char       31
#define left_char 29
#define right_char 28
#define bol_char 200
#define eol_char 201
#define pageup_char 202
#define pagedown_char 203
#define bof_char 204
#define eof_char 205
#define Ins_char 206
#define Del_char 207
#define NextWord_char 208
#define PrevWord_char 209

/* function keys */
#define M1 210
#define M2 211
#define M3 212
#define M4 213
#define M5 214
#define M6 215
#define M7 216
#define M8 217
#define M9 218
#define M10 219


char world[ROWS][COLS],create_mode=1,quit_flag;
short  population,crow,ccol;
long generation;
char color_opt,color;
int ndel;                                       /*kj1*/

main(argc,argv)
	short argc;
	char *argv[];
{
	if (argc > 1 && toupper(*argv[1]) == 'C') color_opt=1;
	scr_setup();
	scr_clr();
	instruct();
	ndel = getspeed();              /*kj1*/
	setup();
	do
	{
		generation++;
		cycle();
		screen();
		delay(ndel);
		/*delay(ndel);    kj1.  Starts generations about 1 second apart*/
	}
	while (population && !quit_flag);
		scr_rowcol(ROWS,10);
	if (population == 0)
		puts("\nNobody left, sorry about that.");
	else puts("\nbye");
	scr_curson();
}                                               /*End main*/

instruct()
{               /*      print instructions      */
	puts("                The game of Life by John Conway\n\n");
	puts("                 Use LIFE C with color monitor.\n\n");
	puts(" If started with a number, a random pattern starts the game.\n\n");
	puts("  Otherwise, move cursor with the 4 arrow keys to create life.\n\n");
	puts("    DEL changes cursor movement to mean that cells are deleted\n\n");
	puts("                 INS flips back to create mode.\n\n");
	puts("          The 's' key will toggle the game on or off.\n\n");
	puts("       A + will speed generations up, a - will slow them.\n\n");
	puts("         Repeat +'s or -'s until the speed suits you.\n\n");
	puts("                     Tap ESC to bail out.\n\n");
	puts("            Enter starting number of cells or tap CR   ");
}

setup()
{
	short rnumber;
	short i,row,col,seed,rnum;
	char ch;

	rnumber=0;
	while (1) {
		while ((ch=scr_csts()) == 0) seed++;
		if (ch < '0' || ch > '9') break;
		scr_co(ch);
		rnumber*=10;
		rnumber+=ch-'0';
		}
	scr_cursoff();
	scr_clr();
	scr_rowcol(ROWS,0);             /*kj1 modified.  Print population message. */
	puts("Generation    0  Population    0");
	scr_rowcol(ROWS,35);                                                    /*kj1*/
	puts("ESC=quit. + speeds. - slows. S stops&starts.");   /*kj1*/
	srand(seed);            /*      initilize random number generator*/

	for (i=0; i < rnumber; i++) {
		rnum=rand();
		row=rnum%ROWS;
		col=(rnum/ROWS)%COLS;
		world[row][col]='X'; /* put in a cell */
		scr_rowcol(row,col);
		/*if (color_opt) 
			scr_aputs("\2",++color | 0X80);
		else                                   */
			scr_co(2);
		}
	if (rnumber == 0) create(1);
}                                                               /*End setup */

screen()
{       /* update the screen and set world back to x's*/
	short  row,col;
	char cell;

	population=0;
	for (row=0; row < ROWS; row++)
	{
		for (col=0; col < COLS; col++)
		{
			cell=world[row][col];
			/* stay alive if 3 neighbors, born if next to 2 or 3 */
			if (cell && (cell == 3 || cell == 'X'+2 || cell == 'X'+3))
			{
				population++;
				if (cell < 'X')
				{
					scr_rowcol(row,col);
					/*if (color_opt) 
						scr_aputs("\2",++color | 0X80);
					else */
						scr_co(2);
				}
				cell='X';
			}
			else
			{
				if (cell >= 'X')
				{
					scr_rowcol(row,col);
					scr_co(' ');
				}
				cell=0;
			}
			world[row][col]=cell;
		}
	}
	scr_rowcol(ROWS,11);            /*kj1 changed display*/
	printf("%4d",generation);
	scr_rowcol(ROWS,28);            /*kj1 changed display*/
	printf("%4d",population);
}                                                       /*End screen*/


create(suspend)                 /*      see if need to create or kill
cells   */
	char suspend; {
	char ch,wait;

	while ((ch=scr_csts()) || suspend) {
		switch (ch) {
			case up_char:   crow=crow ? crow-1: ROWS-1;
							break;
			case down_char: crow=crow == ROWS-1 ? 0: crow+1;
							break;
			case left_char: ccol=ccol ? ccol-1: COLS-1;
							break;
			case right_char:ccol=ccol == COLS-1 ? 0: ccol+1;
							break;
			case bol_char:  ccol=0;
							break;
			case eol_char:  ccol=COLS-1;
							break;
			case 'S':                                               /*kj1*/
			case 's':               suspend=!suspend;       /*kj1*/
							continue;
			case '+':               ndel -= ndel/10;        /*kj1 decreases delay 10% */
							continue;               /*kj1 */
			case '-':               ndel += ndel/10;        /*kj1 increases delay 10% */
							continue;               /*kj1 */
			case Ins_char:  create_mode=1;
							continue;
			case Del_char:  create_mode=0;
							continue;
			case 0x1b:              quit_flag=1;    /* flag for stop */
							return;
			default:                continue;
			}
		world[crow][ccol]= create_mode ? 'X': 0;
		scr_rowcol(crow,ccol);
		if (create_mode) {
			/*if (color_opt) 
				scr_aputs("\2",++color | 0X80);
			else*/ 
			scr_co(2);                                                                                                                                                                                               
			population++;
			}
		else {
			wait=30;
			while (wait--) {
				/*if (color_opt) 
					scr_aputs("\1",++color | 0X80);
				else */
					scr_co(1);
				scr_rowcol(crow,ccol);
				}
			scr_co(' ');
			}
		}
	}

cycle() {                               /* cycle to the next generation */
	short  row,col;

	create(0);
	/*      take care of left and right column first        */
	for (row=0; row < ROWS; row++) {
		if (world[row][0] >= 'X') add8(row,0);
		if (world[row][COLS-1] >= 'X') add8(row,COLS-1);
		}

	/*      take care of top and bottom line        */
	for (col=1; col < COLS-1;col++) {
		if (world[0][col] >= 'X') add8(0,col);
		if (world[ROWS-1][col] >= 'X') add8(ROWS-1,col);
		}

	/*      fill in the box, ignoring border conditions     */
	for (row=1; row < ROWS-1; row++) {
		for (col=1; col < COLS-1; col++) {
			if (world[row][col] >= 'X' ) {
				world[row-1][col-1]++;
				world[row-1][col]++;
				world[row-1][col+1]++;
				world[row][col-1]++;
				world[row][col+1]++;
				world[row+1][col-1]++;
				world[row+1][col]++;
				world[row+1][col+1]++;
				}
			}
		}
	}


add8(row,col)
	short  row,col; {
	short  rrow,ccol,rr,cc;

	for (rr=row-1; rr <= row+1; rr++) {
		for (cc=col-1; cc <= col+1; cc++) {
			rrow=rr != -1 ? rr : ROWS-1;
			ccol=cc != -1 ? cc : COLS-1;
			if (rrow >= ROWS) rrow=0;
			if (ccol >= COLS) ccol=0;
			world[rrow][ccol]++;
			}
		}
	world[row][col]--;
	}



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


#asm
_retrace:
	mov	dx,$3da
	in	al,dx
	movzx eax,al
	and	al,8
	ret

_nope:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ret


#endasm

int delay(n)
int n;
{
int roll;
int roll2;

			for(roll=0;roll<n;roll++)
				for(roll2=0;roll2<101;roll2++)
					nope();

/*printf("delay() n %d roll %d\n	",n,roll);*/

}


int getspeed()
{
long stime;
int ticks;
int n;


stime=gtime();
stime=stime+60;

		while(stime>gtime())
			{
			for(n=0;n<101;n++)
				nope();
			ticks++;
			}
/*printf("getspeed() %d\n",ticks);*/
return(ticks);
}

