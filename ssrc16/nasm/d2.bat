@copy r:x86.exe r:k
@acc x86 -or:\x86
@x86 r:\x86
@acc asm -or:\asm
@x86 r:\asm
@link r:\x86 r:\asm
@del r:\x86.a
@del r:\x86.o
@del r:\asm.a
@del r:\asm.o
@diff r:k r:x86.exe