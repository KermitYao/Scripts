#include<stdio.h>
int main(){
	FILE *fp = fopen("/home/gnrain/test.c", "r");
	char c;
	while ((c=fgetc(fp)) != EOF){
		printf("%c", c);
	}
	printf("\n");
	return 0;
}
