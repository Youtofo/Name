#include<stdio.h>
#include<conio.h>

int fun(int j)
{
if(j==0)
return 1;
else
return 2*fun(j-1);
}

int generate()
{
int a,i,j=0,f,num[6],n,r=0;
char ch[6];
for(j=0;j<=5;j++)
{
gotoxy(1,7);
f=fun(j);

for(i=1;i<=63;i++)
{
a=i & f;
if(a==f)
{
printf("\t%d",i);
}
}
printf("\n Let Me Remind You If The Number Is Present Then Press 'P' ");
printf("\n Otherwisw Press 'N' ");
printf("\n Enter Your Answer: ");

ch[j]=getch();
printf("\n Press Any Key To Continue....... ");

if(ch[j]=='p' || ch[j]=='P')
{
num[j]=1;
n=fun(j);
r=r+n;
}
else
num[j]=0;
getch();
clrscr();
}
{
printf(" %d ",num[j]);
}
printf(" %d ",r);
return r;
}



void main()
{
int i,a,r;
clrscr();
gotoxy(10,10);
printf("\n WELCOME YOU ! In The Jargon Of Number.......");
printf("\n Press Any Key To Continue......");
getch();
clrscr();
gotoxy(15,8);
printf("\n Just Think A Number Between 1 To 63 In Your Mind");
printf("\n Think On One");
printf("\n Do Not Enter That Number");
printf("\n I Will Find That Number On Your Mind......");
printf("\n Press Any Key To Continue..");
getch();
clrscr();
gotoxy(20,7);
printf("\n By Just Answering Few Questions......");
printf("\n If Your Number Is Present In The Numbers");
printf("\n Shown In Your Screen, Then Press 'P' And If Not Present");
printf("\n Then Press 'N' ");
printf("\n But Please Be Honest While Entering The Answer.....");
printf("\n Press Any Key To Continue...");
getch();
clrscr();
r=generate();
if(r==0)
{
gotoxy(20,11);
printf("\n You Didn't Think Of Any Number Between 1 To 63");
printf("\n So Try Again...");
}
else
{
gotoxy(30,11);
printf("\n Your Number Is %d ",r);
printf("\n SURPRISED ! but Friends It Is Not A Magic,");
printf("\n It Just Involves Some Mathematical Computation....");
printf("\n THANK YOU !");
getch();
}
}

