%{
#include <stdlib.h>
#include "bc.h"
#include "y.tab.h"
void yyerror (char *s);
int yylex();
char *str;
%}
%%
"print"					{return PRINT;}
"readi"					{return READI;}
"readf"					{return READF;}
"if"					{return IF;}
"else"					{return ELSE;}
"exit"					{return exit_command;}
"while"					{return WHILE;}
"for"					{return FOR;}
[/]{1}[*]{1}(.|\n)*[*]{1}[/]{1} 	;

[0-9]*[.][0-9]* 		{
							yylval.fValue = atof(yytext);
						 	return FLOAT;
						}
0 						{
							yylval.iValue = atoi(yytext);
							return INTEGER;
						}

[1-9][0-9]* 			{
						 yylval.iValue = atoi(yytext);
						 return INTEGER;
						}
[a-z][_a-z0-9]*			{
							str=(char*)calloc((strlen(yytext)+1),sizeof(char));
							strcpy(str,yytext);
							yylval.sIndex=str;
							return VARIABLE;
						}
[-+*/%^=><(){};]		{return yytext[0];}

[ \t\n] 				;
"!="					{return NE;}
"=="					{return EQ;}
">="					{return GE;}
"<="					{return LE;}
"++"					{return INC;}
"--"					{return DEC;}
"+="					{return PEQ;}
"-="					{return MEQ;}
"*="					{return MLEQ;}
"/="					{return DEQ;}
"%="					{return MOEQ;}
.						{	ECHO; 
							yyerror ("unexpected character");
						}

%%
int yywrap (void) {
	return 1;
}
