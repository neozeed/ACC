This is the GPL version of the ACC compiler set, written by David Ashley.

You can find his original work here:
http://www.xdr.com/dash/davedos.html


I have been graciously given permission by David Ashley to release this as open source:

"You are free to use ACC and the source as you see fit. Consider it under the
GPL license, if you modify it you need to include your source."

There are a few minor improvements I’ve made over the original source, the first being the inclusion of the C++ style of commenting (the // ‘s).  Also I’ve started trying to change the int size from being a 16bit integer into a 32bit integer.


Contents:
This package contains several pieces of software that work together.

ENV.BAT  This will setup the environment for both the 16bit & 32bit integer compilers.

EXE directory
ACC:  This is the C compiler.  ACC.exe is my attempt at making ACC a 32bit compiler.
ACC16:  This is the ‘original’ sized compiler.  Its integers are 16bit, although it produces 32bit code.  ACC16 will pull in a different include directory so its headers will not clash.
ASM: This is the assembler that can assemble the output from ACC.
LINK: This is the linker for the package.  By default it will link in _lib.o & _start.o .

LIB directory
_lib.o: This is a minature libc written in assembly
_start.o: This is a port of Tran’s PMODE 3.07 into ACC’s assembler.


Included in this is Tran's PMODE dos extender 3.07.  It is my understanding that this is ‘free’ as long as you are not building a DOS Extender.  Since it is from the BBS days there is no real ‘homepage’ for it.


Building a test exe.

I’m using DOSBox for my building & testing.  I have had no luck with NTVDM on Windows NT, nor OS/2’s MS-DOS emulation.  Virtual PC ought to work as well.  First unzip the archive, then cd into the ACC directory.  Then run the env.bat file.  This will setup all the variables as needed.    Now you can run the size.bat file.  This will go about compiling the x.c file with both the 16 & 32bit integer compilers and outputting the size of primitive types.  If everything goes well, you’ll get:
------8<------8<------8<------8<

C:\ACC>asm x

C:\ACC>link x

C:\ACC>x
char   is 1
short  is 2
int is 4
long is 4
32767 10000001

C:\ACC>acc16 x

C:\ACC>asm x

C:\ACC>link16 x

C:\ACC>x
char   is 1
short  is 2
int is 2
long is 4
32767 10000001

------8<------8<------8<------8<

Ok, everything looks fine.  As you can see the steps in building an exe are quite simple.  First you run the compiler, then the assembler, then finally the linker.  The linker can accept multiple files, so you can build multi-file programs.  


Examples:
There are several example programs that show off a few features… maze & fire are some of the best to be found.   The mouse in the fire demo doesn’t work when built with the 32bit compiler, however the mouse demo runs with the 32bit compiler… Stack/Heap issues?

 I’ve also take the ‘life’ program from DeSmet-C, changing the idle procedure and ported it along with enough of the pcio library to run on ACC.

Sources:
I’ve broken the sources up to a 16/32bit split until I get the 32bit version working more… correctly.  ACC is self hosting, which is also a quick way to test things.  

ACC
The compiler is in the comp directory.  The yacc file is parsed with bison 1.11.  As far as I can tell it has been then manually massaged into something ACC can deal with.  Your best bet is to either skip this step completely, or make a backup of parse.c and diff the output from bison with the backup to see what changes were made.  From there simply compile comp.c & parse.c and link them together.  I’ve automated this with the bcomp batchfile.

LINK
This is a a single file nlink.c  Simply compile & link it.  This will produce the nlink.exe (or new link).

NASM
This is the assembler.  Don’t confuse it with the more popular NASM project.  This is the assembler for ACC.  Compiler & build asm.c & x86.c





Limitations:
There is NO floating point.  The assembler doesn’t understand FP instructions, so that’ll have to get fixed first.

There is no debugger.  When things go haywire you are on your own.

At this moment there is no ‘ar’ type tool to make libraries out of multiple objects.

There is no ‘driver’ program to the toolchain, like cl.exe or gcc.

Large numbers need to be defined as LONG otherwise the parser will not like them.  Thus assigning something like:

long j;
j = 1000000;

Will give an error, it’s a trivial fix to:

long j;
j = 1000000L;

The libc support is FAR from complete, and there are TONNES of unintended consequences of my attempt to move the int type as a 32bit integer.  Certainly ‘rely’ on the 16bit acc16 more then the 32bit acc.

Also consult the original readme, README-old.txt for more notes…
