    #include<stdio.h>
    int main(){
        FILE *fp;
        char ch;
        //�ж��ļ��Ƿ�ɹ���
        if( (fp=fopen("D:\\demo.txt","wt+")) == NULL ){
            printf("Cannot open file, press any key to exit!\n");
            getch();
            exit(1);
        }
        printf("Input a string:\n");
        //ÿ�δӼ��̶�ȡһ���ַ���д���ļ�
        while ( (ch=getchar()) != '\n' ){
            fputc(ch,fp);
        }
        fclose(fp);
        return 0;
    }
