#include <stdio.h>
int main()
{
	FILE *fp, *fs;
	char str[99+1];
	if ( (fp = fopen("d:\\1.txt", "r")) == NULL )
	{
		printf("This is a null file1.");
	}else{
		 if ( (fs = fopen("d:\\test.txt", "r")) == NULL )
		 {
			 printf("This is a null file2.");
		 }else{
		 	while(fgets(str, 99, fp) !=NULL)
			{
				printf("%s\n", str);
				fputs(str, fs);
			}
				fclose(fs);	
		 }
	}

	fclose(fp);
	return 0;
}
