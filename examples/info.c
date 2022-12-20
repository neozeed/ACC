main()
{
long absbase;
long lowmembase;
long lowmemsize;
long mainloc;

	mainloc=*(long *)4;
	absbase=*(long *)8;
	lowmembase=*(long *)12;
	lowmemsize=*(long *)16;

	printf("Absolute address of code block is %lx\n",absbase);
	printf("Absolute address of PSP is %lx\n",absbase-0x100);
	printf("Absolute address of lowmem start is %lx\n",lowmembase+absbase);
	printf("Size of lowmem is %lx\n",lowmemsize);
	printf("Absolute address of main is %lx\n",mainloc+absbase);
}
