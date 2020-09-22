


//code by ngrain@deepin&gcc 20171229



#include <stdio.h>
#include <winsock2.h>
#pragma comment (lib, "ws2_32.lib")
#include <string.h>
#include<dir.h>
#define c_BUF_SIZE 50
#define s_BUF_SIZE 1024

//********��������*********

int fexist(char *fn);
int ptrtype(char *str);
void pfusage();
int fpexist(char *fnp);


//********��������*********

//********ȫ�ֱ���*********

int i = 0; 

//�ļ�ָ��
FILE *c_fp, *s_fp;

//server = 0, client_put = 1, client_test = 2
int SWtype = -1;	

//�������ͳ�ʼ��		
int ptr_addr=-1;
int ptr_put=-1;
int ptr_test=-1;
				
char Sstr_buffer[s_BUF_SIZE];
char Cstr_buffer[c_BUF_SIZE];
char s_fnp[c_BUF_SIZE];

int s_count;
int c_count;
char *pcd, *pfp;
int pcd_port = 0;
char pcd_addr[254],pfp_n[254], pfp_p[254],pfp_d[254];					
					
//********ȫ�ֱ���*********
int main(int argc, char *argv[])
{
	char *pcd, *pfp;
	int pcd_port = 0;
	char pcd_addr[254],pfp_n[254], pfp_p[254],pfp_d[254];
	if(argc == 1){
		pfusage();
		return 6;	
	}else{
		if(ptrtype(argv[1])==1){
			int i = 0;
			for(i=2;i<argc;i++){
				if(ptrtype(argv[i])==4){
					if(i+1 == argc){
						printf("IP��ַ��˿ڴ���!\n");
						return 9;
					}else{
						if(iptest(argv[i+1]) == 0){
							ptr_addr=0;
							sscanf(argv[i+1], "%[^:]:%d", pcd_addr, &pcd_port);
						}else{
							printf("IP��ַ��˿ڴ���!\n");
							return 9;
						}
					}
				}else if(ptrtype(argv[i])==5){
						if(i+1 == argc){
							printf("�ļ�·������!\n");
							return 10;
						}else{
							sscanf(argv[i+1], "%[^:]:%[^\n]", pfp_n, pfp_p);
							if(access(pfp_p, 4) == 0){
								ptr_put=0;
							}else{
								printf("�ļ�·������!\n");
								return 10;
							}	
						}
				}else if(ptrtype(argv[i])==6){
					ptr_test=0;
				}
			}	
		}else if(ptrtype(argv[1])==2){
			int i = 0;
			for(i=2;i<argc;i++){
				if(ptrtype(argv[i])==4){
					if(i+1 == argc){
						printf("IP��ַ��˿ڴ���!\n");
						return 9;
					}else{
						if(iptest(argv[i+1]) == 0){							
							ptr_addr=0;
							sscanf(argv[i+1], "%[^:]:%d", pcd_addr, &pcd_port);
						}else{
							printf("IP��ַ��˿ڴ���!\n");
							return 9;
						}
					}
				}else if(ptrtype(argv[i])==5){
						if(i+1 == argc){
							printf("�洢Ŀ¼����!");
							return 8;
						}else{
							if(fpexist(argv[i+1]) == 0){
								ptr_put=0;
								strcpy(pfp_d, argv[i+1]);
							}else{
								printf("�洢Ŀ¼����!");
								return 8;
							}

						}
				}
			}
		}else if(ptrtype(argv[1])==3){
			pfusage();
			return 6;
		}else{
			printf("��������!\n");
			pfusage();
			return 5;			
		}
	}
	
	if(ptrtype(argv[1]) == 1){
		if(ptr_addr == 0 && ptr_put == 0){
			SWtype = 1;
		}else if( ptr_addr == 0 && ptr_test == 0){
			SWtype = 2;
		}
	}else if(ptrtype(argv[1]) == 2){
		if( ptr_addr == 0 && ptr_put ==0 ){
			SWtype = 0;
		}
	}
	if(SWtype < 0 ){
		printf("��������!\n");
		pfusage();
		return 5;
	}
		
	//�����׽���
	WSADATA wsadata;
	WSAStartup( MAKEWORD(2, 2), &wsadata);
	SOCKET t_sock = socket(AF_INET, SOCK_STREAM, 0);
	struct sockaddr_in t_addr;
	memset(&t_addr, 0, sizeof(t_addr));
	t_addr.sin_family = AF_INET;
	t_addr.sin_addr.s_addr = inet_addr(pcd_addr);
	t_addr.sin_port = htons(pcd_port);
	
	if(SWtype == 0){
		//�����
		printf("�ļ���������!\n");
		bind(t_sock, (struct sockaddr*)&t_addr, sizeof(t_addr));	
		listen(t_sock, 20);
		SOCKADDR_IN c_addr;
		int c_size = sizeof(c_addr);
		while(1){
			printf("���ڼ���..."); 
			SOCKET c_sock = accept(t_sock, (SOCKADDR*)&c_addr, &c_size);
			printf("\b\b\b\b\b\b\b\b\b\b\b");
			printf("����IP:[%s]\n", inet_ntoa(c_addr.sin_addr));
			memset(Cstr_buffer, 0, sizeof(char)*c_BUF_SIZE+1);
			recv(c_sock, Cstr_buffer, c_BUF_SIZE, 0);
			char* s_tmp = strtok(Cstr_buffer, "|");
			if(strcmp(Cstr_buffer, "test") == 0){
				printf("\t����:[test]\n");
				strcat(Cstr_buffer, "ok");
				send(c_sock, Cstr_buffer, sizeof(Cstr_buffer), 0);
			}else if(strcmp(Cstr_buffer, "put") == 0){
				printf("\t����:[put]\n");
				s_tmp = strtok(NULL, "|");
				memset(s_fnp, 0, sizeof(char)*c_BUF_SIZE);
				strcpy(s_fnp, pfp_d);
				strcat(s_fnp, s_tmp);
				if((s_fp=fopen(s_fnp, "wb")) != NULL ){
					send(c_sock, "put_yes", 7, 0);
					s_count = 0;
					printf("\tд���ļ�:[%s]\n", s_fnp);
					memset(Sstr_buffer, 0, sizeof(char)*s_BUF_SIZE);
					int s_num = 1024;
					while((s_count = recv(c_sock, Sstr_buffer, s_BUF_SIZE, 0)) > 0 ){
						fwrite(Sstr_buffer, s_count, 1, s_fp);
						s_num = s_num + s_count;
					}
					printf("\t�ļ���С:[%d KB]\n", s_num/1024);
					fclose(s_fp);
				}else{
					printf("\t��д����:%s\n", s_fnp);
					send(c_sock, "put_no", 7, 0);
				}
			}
			closesocket(c_sock);
			printf("\t\t----������[%d]---\n", ++i); 
		}

	}else if(SWtype == 1){
		if(connect(t_sock, (SOCKADDR*)&t_addr, sizeof(SOCKADDR)) == 0){
			char CStype[] = "put";
			strcat(strcat(CStype, "|"), pfp_n);
			send(t_sock, CStype, strlen(CStype), 0);
			memset(Cstr_buffer, 0, sizeof(char)*c_BUF_SIZE+1);
			recv(t_sock, Cstr_buffer, c_BUF_SIZE, 0);
			if(strcmp(Cstr_buffer, "put_yes") == 0){
				if((c_fp=fopen(pfp_p, "rb")) != NULL){
					c_count = 0;
					while( (c_count = fread(Sstr_buffer, 1, s_BUF_SIZE, c_fp)) > 0 ){
						send(t_sock, Sstr_buffer, c_count, 0);
					}
					shutdown(t_sock, SD_SEND);
					recv(t_sock, Sstr_buffer, s_BUF_SIZE, 0);
					fclose(c_fp);
					printf("�������!\n");
				}else{
					printf("�޷���ȡ�ļ�!\n");
					return 4;
				}			
			}else{
				printf("�ܾ�����,�޷��ϴ�!\n");
				closesocket(t_sock);
				WSACleanup();
				return 3;
			}
		}else{
			printf("�޷����ӵ�������!\n");
			WSACleanup();
			return 1;
		}
		closesocket(t_sock);
		WSACleanup();
		return 0;
	}else if(SWtype == 2){
		if(connect(t_sock, (SOCKADDR*)&t_addr, sizeof(SOCKADDR)) == 0){
			char Cstr_buffer[c_BUF_SIZE] = "test";
			send(t_sock, Cstr_buffer, strlen(Cstr_buffer), 0);
			memset(Cstr_buffer, 0, sizeof(char)*c_BUF_SIZE+1);
			recv(t_sock, Cstr_buffer, c_BUF_SIZE, 0);
			if(strcmp(Cstr_buffer, "testok") == 0){
				printf("����ͨ��!\n");
			}else{
				printf("����ʧ��!\n");
				WSACleanup();
				return 2;
			}
		}else{
			printf("�޷����ӵ�������!\n");
			WSACleanup();
			return 1;
		}		
		closesocket(t_sock);
		WSACleanup();
		return 0;	
	}
}

//�ж��ļ��Ƿ����
int fexist(char *fn)
{
	FILE *fp;
	if( (fp=fopen(fn, "r")) == NULL ) return -1;
	fclose(fp);
	return 0;
}


//�жϲ�������:C=1, S=2, help=3, ?=3, d=4, p=5, t=6, not=0
int ptrtype(char *str)
{
	if(strcmp(str, "-C")==0||strcmp(str, "/C")==0){
		return 1;	
	}else if(strcmp(str, "-S")==0||strcmp(str, "/S")==0){
		return 2;
	}else if(strcmp(str, "-help")==0||strcmp(str, "/help")==0){
		return 3;
	}else if(strcmp(str, "-?")==0||strcmp(str, "/?")==0){
		return 3;
	}else if(strcmp(str, "-d")==0||strcmp(str, "/d")==0){
		return 4;
	}else if(strcmp(str, "-p")==0||strcmp(str, "/p")==0){
		return 5;
	}else if(strcmp(str, "-t")==0||strcmp(str, "/t")==0){
		return 6;
	}else {
		return 0;
	}
}

//������Ϣ
void pfusage()
{
	printf("Usage:\n");
	printf("\t-S -d addr:port -p \"SaveDirectory\"\n");
	printf("\t-C -d addr:port -p \"\\ServerFileName:FilePath\"\n");
	printf("\t-C -d addr:port -t \n");
}


//�ж�IP�Ƿ�Ϸ�
int iptest(char *ip){
	int iptk[5];
	sscanf(ip, "%d.%d.%d.%d:%d", &iptk[0], &iptk[1], &iptk[2], &iptk[3], &iptk[4]);
	if( (iptk[0]>-1) && (iptk[0]<255) && (iptk[1]>-1) && (iptk[1]<255) && (iptk[2]>-1) && (iptk[2]<255) && (iptk[3]>-1) && (iptk[3]<255) && (iptk[4]>0) && (iptk[4]<65535) ) {
		return 0;
	}
	return -1;	
}

//���洢Ŀ¼
int fpexist(char *fnp){
	if(access(fnp, 06) == 0){
		return 0;
	}else{
		if(mkdir(fnp) == 0){
			return 0;
		}else{
			return -1;
		}
	}
}
