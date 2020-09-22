#include <stdio.h>
int main()
{

	int a,b,c,d;

	c=1;

	for(a=1;a<=9;a++){

		for (b=1;b<=a;b++){

			c=a*b;

			printf("%d*%d=%d\t", b, a, c);

		}

		printf("\n");

	}

	return 0;

}

