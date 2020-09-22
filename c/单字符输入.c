#include <stdio.h>
int main(){
	char ch;
	char str[11];
	int i = 0;
	for(i = 0; i<=10; i++){
		scanf("%c", &ch);
		str[i] = ch;
	}
	for(i = 0; i<=10; i++){
		printf("%c\n", str[i]);
	}
	getch();
	return 0;
}
