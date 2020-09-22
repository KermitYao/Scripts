#include <stdio.h>
#include <string.h>
int main(){
	int arr[5]={0},max,min,i;
	for(i=0; i<5; i++){
		scanf("%d", &arr[i]);
	}
	max = arr[0], min = arr[0];
	for(i=0; i<5; i++){
		 if(max < arr[i]){
		 	max = arr[i];
		 }
		 if(min > arr[i]){
		 	min = arr[i];
		 }
	}
	printf("最大值是:%d,最小值是:%d\n", max, min);
	return 0;
}

