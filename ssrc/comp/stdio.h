/*	STDIO.H		Include file for C88 input/output.	*/

/*	a 'FILE' is simply an integer is this implimentation	*/

typedef short  FILE;

/*	Standard input, standard output and standard error.	*/

#define stdin	0
#define stdout	1
#define	stderr	2
#define stdprn	4

#define	NULL	0L
#define TRUE	1
#define FALSE	0
#define EOF		(-1)
#define ERR		(-1)
