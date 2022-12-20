acc2.exe: comp.o parse.o start.o lib.o
	link -h start lib parse comp
	copy comp.exe acc2.exe

parse.o:	parse.c
	acc parse
	a86 parse

comp.o: comp.c comp.h
	acc comp
	a86 comp

lib.o:	lib.a
	a86 lib

start.o: start.a
	a86 start

parse.c:	parse.y bison.sim comp.h
	bison parse.y -o parse.c -v

comp.h:

comp.c:

parse.y:

bison.sim:

lib.a:

start.a:
