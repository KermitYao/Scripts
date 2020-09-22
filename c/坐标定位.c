#include<stdio.h>
int main(){
	int x=30,y=30,i,j,inx,iny;
	int str,c[2]={1,2};
	printf("请输入坐标(x,y):");
	scanf("%d,%d", &iny, &inx);
	printf("--------------start----------------\n");
	for(j=1;j<=y;j++){
		for(i=1;i<=x;i++){
		if(i==inx && j==iny) str=c[1]; else str=c[0];
		printf("%d", str);
		}
		printf("\n");
	}
	printf("---------------end-----------------\n");
	return 0;
}

