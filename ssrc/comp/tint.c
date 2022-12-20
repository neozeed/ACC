unsigned size;
char *ptrs[16];

main()
{
int i,j;

printf("ints are %d\n",sizeof(int));

	listmem();
	printf("%lx,%lx %lx\n",*(int *)8,*(int *)12,*(int *)16);

size=8;
for(i=0;i<12;++i){
        ptrs[i]=lalloc(size);
        size+=size;
        printf("%d size=%u ptr=%lx\n",i,size,ptrs[i]);
	printf("%lx,%d\n",ptrs[i]);
        if(ptrs[i]==0) break;
        rci();
        }
for(j=0;j<i;++j) if(ptrs[j]) free(ptrs[j]);
}
listmem()
{
int *z;
char ch;

	z=*(int *)12;
	while(z)
	{
		ch=z[3]&1 ? '*' : ' ';
		printf("%08lx %08lx %08lx %08lx %c\n",z,z[0],z[1],z[2],ch);
		z=*z;
	}
}
