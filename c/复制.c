#include<stdio.h>

int main(){

	int b[7547],c;

	int i, size = sizeof(int);

	FILE *fp = fopen("E:\新软件测试.exe","rb+");

	FILE *sp = fopen("E:\新软件测试1.exe", "wb+");

	if(fp == NULL){

		printf("error file is null.\n");

	}else{

		fread(b, 7547 , 1, fp);


		printf("%s", b);

		fwrite(b, 7547, 1, sp);
	
	}

	printf("\n");

	fclose(fp);
	
return 0;


}
