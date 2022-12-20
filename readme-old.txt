Everything here created and Copyright (C) 1997 by David Ashley
dave@xdr.com
http://www.xdr.com/dash

David Ashley
159 Dale Ave
Newbury Park, CA 91320

DISCLAIMER:

I am not liable for any damages resulting from the use or misuse of these
programs and files. No warranty is implied for any purpose whatsoever.
Use at your own risk.

REGISTRATION:

If these programs are of any use to you, please send me some $$$
by registering. Registration will entitle you to newer versions with
fewer bugs, you can complain about bugs and have a chance of getting
them fixed, and you'll reserve a place for yourself in programmer heaven.

You should *REALLY* register this software if any of these are true:
1) It becomes the dominant programming software you use.
2) You allow any other human being access to a program created with
   this software. This includes demos, commercial software, shareware,
   software you give away free. If another human being besides yourself
   gets hold of a program created with this software, you must register
   this software.  <NOTE: If you do distribute a program created with
   this software, somewhere you must tell people that you used this
   software. Give credit where credit is due. Also put in a note about
   it using Tran's pmode extender.>
3) You wish to include it with any distribution where you charge a fee.
4) You keep a copy of this software on your machine for longer than 1
   month.

NOTE: This is a fully working set of programs, nothing is crippled.
If you register this, I'll do my best to make you satisfied with this
product. You're probably used to big software houses where they laugh
when you report bugs and they tell you to just live with it. I really
care, and if you find a bug chances are I'll fix it within a day or two.

I'm eventually going to write a cool symbolic debugger that will work
perfectly with this package. That will only be available to registered
users, and it will probably be free.

NOTE: If not enough people register this, I won't spend any more time
on it and it won't evolve any, at least regarding the public version.

HOW TO COMPENSATE THE AUTHOR:
Send me a post card from where you are. My address is up on top there.
You might also send me one of the smallest pieces of paper money in your
local currency, but that's not as exciting as the post card. I'd love to
get some post cards! Mention ACC on the back.

---------------------------------------------------------------------
DESCRIPTION OF CONTENTS:

ACC  (pronounced by naming the letters A, C and C) is a near-C compiler
for the IBMPC line of computers for MSDOS programs. The compiler and
compiled programs will run on any 386 or above PC running MSDOS.
Included with the compiler are a 386 assembler and a linker for combining
multiple object files. There are also two libraries, which are a protected
mode dos extender (Based on Thomas Pytel's (aka Tran's) PMODE30B + PMODE307
dos extenders), and a library of useful functions callable by C programs.
Pointers are 4 bytes, and can access all available memory. You can
allocate blocks as large as you want (megabytes) as long as there is
memory available.

The compiler, assembler and linker are all very small and fast. The
code generated is adequate for most programming needs, but time critical
stuff should be written in assembler. The compiler supports easy inline
asm with the #asm, #endasm directives. The assembler syntax is very
similiar to TASM's.

I suspect that the people most interested in this package would be:
1) People who write cool demos but have to write in 100% asm because
   dev tools are so slow + ungainly, except for TASM which is pretty quick.
2) People who think Borland, DJGPP, WATCOM and other compilers are just
   too big and complicated for their needs, as well as being too slow
   for quick turnarounds.
3) People who use other development tools but find it too difficult to
   access low level functions with them.
4) People who want to code things very quickly.
5) People who up to now used the free DeSmet C compiler or other 16
   bit compiler and were limited to 16 bit segmented programs.
6) People who use other free compilers but want something better.

People who would not be interested in this package would be:
1) People who are used to the compiler holding their hand all the
   time, checking every little thing, and warning them all the time.
2) People who want C++.
3) People who don't care if a compilation takes several minutes.
4) People who are just apathetic in general about new things,
   regardless of how cool or slick they are.
5) People who use existing libraries in .OBJ format. The object
   format is completely nonstandard with this compiler.
6) People who have huge libraries of C code and don't want to spend
   any time getting it to compile under this compiler.

COMPILER LIMITATIONS:
In this version there is NO FLOATING POINT support. The assembler
won't recognize the floating point instructions even, so inline asm
won't help much.

The compiler doesn't do type checking of arguments to function calls.

#if <expr> : The expression cannot make use of the MACRO preprocessor
feature of C. For example you can't do:
#define NEG(x) (-(x))
#if NEG(4)==4
But you CAN do
#define WIDTH 80
#if WIDTH>=80

Complicated variable initialization for extern variables won't work. For
example, you can't do:
char zzz[]="This is a string";
long k5;
char *pnt=zzz;    -OR- char *pnt=&k5;
Also nested {} for array initialization won't work. There can be just 1
level of {}, and entries get placed into arrays in the order given.

Keywords "static", "register" and "auto" are pretty much ignored.

#pragma ---I have no idea what this means or is supposed to do, so it's
not implemented.

All char variables are unsigned.

Bitfields are not supported. (That's the : stuff in structures).

Inline asm only works properly if it appears outside a function
definition.

In expressions, if the compiler runs out of 386 registers, it prints
out "alloc register failure" or something like that and throws up its
hands. This as opposed to say pushing registers, doing some more
operation, then poping registers. This would only happen in really
complicated expressions. I've never seen it. The solution is to break
up expressions into smaller pieces. I wouldn't even be able to give you
an example of a realistic expression that would cause this problem.

sizeof() cannot take an expression as an argument, and sizeof <expr>
doesn't work. For example you can't do:
int a,b;
	a=sizeof b;
OR
long *p;
int a;
	a=sizeof(*p);
YOU CAN DO:
int a,b;
	a=sizeof(int);
OR
long *p;
int a;
	a=sizeof(long *);

typedef'd names cannot be used as variable names. Example:

typedef int distance;
int distance;   ---NOPE!!!!---

You can use structure names and names of members as normal variables.
Inside a function you can reuse the name of an external identifier.

Inside a block {} you can declare variables, but they stay around
until the end of the entire function.

You can declare arguments K&R or ansi style, or in combination:
main(int argc, char **argv) <=> main(argc,argv) int argc;char **argv;

A note on bugs:
This software is pretty robust right now. But I'm certain there are lots
of bugs in it, and probably more than 1 crash bug. The compiler, assembler
and linker are all compiled with the compiler itself, so this alone is
a pretty good system of testing. One particular weak spot that worries
me is the pmode header. While I think Tran's original version was probably
rock-solid, I've had to modify it extensively to get it to work with this
package. I've probably introduced some bugs just because I don't understand
everything about what the code is doing, and I haven't tested it in all
possible configurations. I've tried it under VCPI, DPMI and raw XMS, and
everything worked. But in the real world...

------------------------------------------------------------------------
Look in the DOCS directory for more doc files.
-----------------------------------------------------------------------

Future improvements:

o I'd like to have a symbolic debugger for the protected mode programs.
  The debuggers I've seen all suck, and don't handle 32 bit disassembly
  properly. They choke on the $66 and $67 prefix bytes.

o I will probably port this to Win95 since it would be so easy. Then
  we'd have a quick and dirty inexpensive C compiler for win95.

o I may port it to Linux also. This would probably be easier than porting
  to win95. The whole thing is in the linker--creating the correct
  executable format.

o I'd like to have floating point capability.

o I'd like to have more C stdlib functions in the library. I'm not
  interested in C versions of the STD lib. I want hand coded ASM versions.
  At least the library can be *fast* and small.

o I may create an optomizer stage that goes between the compiler and
  the assembler. There are lots of cases where instructions can be
  rolled together into one, or where there is a jmp to the location
  following the jmp itself, or where a variable is pulled from memory
  when it is already in one of the registers. Sometimes variables are
  loaded into a register and never used, for example in the case
  int a=4;  a++;  The variable a will first be put into a register,
  then incremented. It is put into a register just in case it needs to
  be used, as in the case of b=a++;

o I'd like to have a profiler.

o Argument type checking would be nice, it would catch some nasty bugs.
