// this is a test
/* so is this
*/

#include <stdio.h>
void main(void)
{
short s;
long i;
printf("char  is %d\n",sizeof(char));
printf("short is %d\n",sizeof(short));
printf("int   is %d\n",sizeof(int));
printf("lont  is %d\n",sizeof(long));
s=32767;
i=10000000L;
i++;
printf("%d %ld\n",s,i);
}
