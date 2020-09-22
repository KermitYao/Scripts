#include <stdio.h>
#define PER 2
int main()
{
	struct test
	{
		char name[10];
		char gender[4];
		int  age;
		int  math;
		int chinese;
		int english;
	}stu[PER];
	int i,j,k;
	for(i = 0; i < PER; i++)
	{	
		j = i+1;
		printf("\t\t第[%d]个学生信息.\n", j);
		printf("\n\n请输入姓名:");
		scanf("%s", &stu[i].name);
		printf("请输入性别:");	
		scanf("%s", &stu[i].gender);
		printf("请输入年龄:");
		scanf("%d", &stu[i].age);
		printf("请输入数学:");
		scanf("%d", &stu[i].math);
		printf("请输入语文:");
		scanf("%d", &stu[i].chinese);
		printf("请输入英语:");
		scanf("%d", &stu[i].english);
	}
	int x = 0,y,z;
	for(i = 0; i < PER; i++)
	{
	x = stu[i].math + stu[i].chinese + stu[i].english + x;
	
	}
	printf("共计录入[%d]个学生信息;总计分数[%d];总计平均分数[%d]\n", i, x, x/PER);
	for(i = 0; i < PER; i++)
	{
	printf("姓名:[%s]\n", stu[i].name);
	printf("性别:[%s]\n", stu[i].gender);
	printf("年龄:[%d]\n", stu[i].age);
	printf("数学:[%d]\n", stu[i].math);
	printf("语文:[%d]\n", stu[i].chinese);
	printf("英语:[%d]\n", stu[i].english);
	printf("------------------------\n");
	}
	return 0;

}
