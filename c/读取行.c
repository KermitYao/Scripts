#include<stdio.h>
int main(){
	FILE *fp = fopen("/home/gnrain/test.c","r");
	FILE *sp = fopen("/home/ngrain/ttt.c", "rt+");
	int i=0;
	char str[99];
	fgets(str, 100, fp);
	printf("%s-----------------------------------fsfasdfa\n", str);
	fclose(fp);
	FILE *fc = fopen("/home/gnrain/test.c", "r");
	while(fgets(str, 100, fc) != NULL){
		printf("%s", str);
		printf("第 %d 行.\n", i++);
	}
	fclose(fc);
	return 0;
}
