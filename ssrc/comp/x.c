#include <stdio.h>
void main(void)
{
long i;
short s;
printf("char  is %d\n",sizeof(char));
printf("short is %d\n",sizeof(short));
printf("int   is %d\n",sizeof(int));
printf("lont  is %d\n",sizeof(long));
s=32000;
i=100000000L;
//i=s;
i++;
if(i>100000L)
        printf("i is gt 100k\n");
printf("i is %ld\n",i);
printf("s is %d\n",s);
}
