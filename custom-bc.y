%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <stdarg.h>
#include "bc.h"

nodeType *opr(int oper, int nops, ...);
nodeType *id(char s[]);
nodeType *con(int value);
nodeType *fnum(float value);
void freeNode(nodeType *p);
int ex(nodeType *p); 
int symbolVal(char name[]);
void updateSymbolVal(char name[], int val);

int yylex(void);
void yyerror(char *s);
sym_tab sym[100]; /* symbol table */
symbols sb[26];
int var_count=0;
int stc=1;

%}



%union {
	float fValue; /* float value */
	int iValue; /* integer value */
	char *sIndex; /* variable name */
	nodeType *nPtr; /* node pointer */
};
%token <fValue> FLOAT
%token <iValue> INTEGER
%token <sIndex> VARIABLE
%token WHILE IF PRINT FOR READI READF INC DEC PEQ MEQ MLEQ DEQ MOEQ exit_command
%nonassoc IFX
%nonassoc ELSE
%right '='
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%right '^'
%left '(' ')'
%nonassoc UMINUS
%type <nPtr> stmt expr stmt_list 

%%


program	:	function 						{ exit(0); }
 			;


function:	function stmt 				{ ex($2); freeNode($2); }
			| /* NULL */
 			;


stmt:	';' 								{ $$ = opr(';', 2, NULL, NULL); }
		| exit_command						{ exit(0);}
	    | expr ';' 							{ $$ = $1; }
	    | PRINT expr ';' 					{ $$ = opr(PRINT, 1, $2); }
	    | READI '(' VARIABLE ')' ';'			{ $$ = opr(READI, 1, id($3)); }
	    | READF '(' VARIABLE ')' ';'			{ $$ = opr(READF, 1, id($3)); }
	    | VARIABLE '=' expr ';' 			{ $$ = opr('=', 2, id($1), $3); }
	    | WHILE '(' expr ')' stmt 			{ $$ = opr(WHILE, 2, $3, $5); }
	    | FOR '('stmt expr ';' expr ')' stmt 	{$$ = opr(FOR,4, $3, $4, $6, $8);}
	    | IF '(' expr ')' stmt %prec IFX 	{ $$ = opr(IF, 2, $3, $5); }
	    | IF '(' expr ')' stmt ELSE stmt    { $$ = opr(IF, 3, $3, $5, $7); }
	    | '{' stmt_list '}' 				{ $$ = $2; }
	    ;


stmt_list:
	    stmt 				{ $$ = $1; }
	    | stmt_list stmt 	{ $$ = opr(';', 2, $1, $2); }
	    ;


expr:
	 INTEGER 			{ $$ = con($1); }
	 | FLOAT 			{ $$ = fnum($1);}
	 | VARIABLE 		{ $$ = id($1); }
	 | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
	 | expr '+' expr 		{ $$ = opr('+', 2, $1, $3); }
	 | expr '-' expr 		{ $$ = opr('-', 2, $1, $3); }
	 | expr '*' expr 		{ $$ = opr('*', 2, $1, $3); }
	 | expr '/' expr 		{ $$ = opr('/', 2, $1, $3); }
	 | expr '%' expr 		{ $$ = opr('%', 2, $1, $3); }
	 | expr '<' expr 		{ $$ = opr('<', 2, $1, $3); }
	 | expr '>' expr 		{ $$ = opr('>', 2, $1, $3); }
	 | expr GE expr 		{ $$ = opr(GE, 2, $1, $3); }
	 | expr LE expr 		{ $$ = opr(LE, 2, $1, $3); }
	 | expr NE expr 		{ $$ = opr(NE, 2, $1, $3); }
	 | expr EQ expr 		{ $$ = opr(EQ, 2, $1, $3); }
	 | expr PEQ expr 		{ $$ = opr(PEQ, 2, $1, $3); }
	 | expr MEQ expr 		{ $$ = opr(MEQ, 2, $1, $3); }
	 | expr MLEQ expr 		{ $$ = opr(MLEQ, 2, $1, $3); }
	 | expr DEQ expr 		{ $$ = opr(DEQ, 2, $1, $3); }
	 | expr MOEQ expr 		{ $$ = opr(MOEQ, 2, $1, $3); }
	 | '(' expr ')' 		{ $$ = $2; }
	 | INC expr				{ $$ = opr(INC, 1, $2);}
	 | DEC expr				{ $$ = opr(DEC, 1, $2);}
	 | expr	INC				{ $$ = opr(INC, 2, $1, NULL);}
	 | expr	DEC				{ $$ = opr(DEC, 2, $1, NULL);}
	 ; 


 %%



#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)
nodeType *con(int value) {
	 nodeType *p;
	 /* allocate node */
	 if ((p = malloc(sizeof(nodeType))) == NULL)
	 	yyerror("out of memory");
	 /* copy information */
	 p->type = typeCon;
	 p->con.value = value;
	 return p;
}
nodeType *fnum(float value) {
	 nodeType *p;
	 /* allocate node */
	 if ((p = malloc(sizeof(nodeType))) == NULL)
	 	yyerror("out of memory");
	 /* copy information */
	 p->type = typeFloat;
	 p->fnum.value = value;
	 return p;
}
nodeType *id(char s[]) {
	 nodeType *p;
	 /* allocate node */
	 if ((p = malloc(sizeof(nodeType))) == NULL)
	 	yyerror("out of memory");
	 /* copy information */
	 p->type = typeId;
	 strcpy(p->id.i,s);
	 return p;
} 



nodeType *opr(int oper, int nops, ...) {
	 va_list ap;
	 nodeType *p;
	 int i;
	 /* allocate node */
	 if ((p = malloc(sizeof(nodeType))) == NULL)
	 	yyerror("out of memory");
	 if ((p->opr.op = malloc(nops * sizeof(nodeType))) == NULL)
	 	yyerror("out of memory");
	 /* copy information */
	 p->type = typeOpr;
	 p->opr.oper = oper;
	 p->opr.nops = nops;
	 va_start(ap, nops);
	 for (i = 0; i < nops; i++)
	 	p->opr.op[i] = va_arg(ap, nodeType*);
	 va_end(ap);
	 return p;
}


int symbolVal(char name[])
{
	int flag=0;
	for ( int i=0; i<var_count ;i++)
	{
		if(strcmp(sb[i].name,name)==0)
		{
			return sb[i].ind;
		}
	}
	updateSymbolVal(name,0);
	return 0;
}

void updateSymbolVal(char name[], int val)
{
	int flag=1;
	for ( int i=0; i<var_count ;i++)
	{
		if(strcmp(sb[i].name,name)==0)
		{
			sb[i].ind = val;
			flag=0;
			break;
		}
	}
	if(flag)
	{
		strcpy(sb[var_count].name,name);
		sb[var_count].ind = val;
		var_count++;
	}
}


int ex(nodeType *p) {
 	if (!p) return 0;
 	int a,b,c;
 	float fl;
 	switch(p->type) {
		 case typeCon: 	sym[stc].type=typeCon;
		 				sym[stc].i= p->con.value;
		 				stc++;
		 				return stc-1;
		 case typeFloat:    sym[stc].type=typeFloat;
			 				sym[stc].f= p->fnum.value;
			 				stc++;
			 				return stc-1;
		 case typeId: return symbolVal(p->id.i);
		 case typeOpr:
		 switch(p->opr.oper) {
			 
			case PRINT: a = ex(p->opr.op[0]);
			 			switch(sym[a].type){
			 				case typeCon: printf("%d\n", sym[a].i);
			 								return 0;
			 				case typeFloat : printf("%f\n", sym[a].f);
			 								return 0;
			 			}
			 			return 0;
			case READI: scanf("%d", &b);
						a = ex(con(b));
						updateSymbolVal(p->opr.op[0]->id.i,a);
						return 0;

			case READF: scanf("%f", &fl);
						a = ex(fnum(fl));
						updateSymbolVal(p->opr.op[0]->id.i,a);
						return 0;

			case IF: 	if(sym[ex(p->opr.op[0])].i){
						 	ex(p->opr.op[1]);
						}
						else if (p->opr.nops > 2){
						 	ex(p->opr.op[2]);
						}
						return 0;

			case WHILE: while(sym[ex(p->opr.op[0])].i){
							 ex(p->opr.op[1]);
						}
						return 0;

			case FOR : 	for(ex(p->opr.op[0]); sym[ex(p->opr.op[1])].i; ex(p->opr.op[2])){
			 				ex(p->opr.op[3]);
			 			}
			 			return 0;

			case ';':   ex(p->opr.op[0]); return ex(p->opr.op[1]);
			case '=':   a = ex(p->opr.op[1]);
			 			updateSymbolVal(p->opr.op[0]->id.i,a);
			 			return a;
			case UMINUS: a = ex(p->opr.op[0]);
			 			  switch(sym[a].type){
			 				case typeCon: sym[a].i = -sym[a].i;
			 								return a;
			 				case typeFloat : sym[a].f = -sym[a].f;
			 								return a;
			 			}
			 			return a;
			case '+':   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i+sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= sym[a].i+sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeFloat;
											 				  sym[stc].f= sym[a].f+sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= sym[a].f+sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}
			case '-':   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i-sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= (float)sym[a].i-sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeFloat;
											 				  sym[stc].f= sym[a].f-(float)sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= sym[a].f-sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}

			case '*':   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i*sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= (float)sym[a].i*sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeFloat;
											 				  sym[stc].f= sym[a].f*(float)sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= sym[a].f*sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}

			case '/':   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeFloat;
											 				  sym[stc].f= (float)sym[a].i/sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= (float)sym[a].i/sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeFloat;
											 				  sym[stc].f= sym[a].f/(float)sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeFloat;
											 				  	 sym[stc].f= sym[a].f/sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}
			case '%':   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i%sym[b].i;
											 				  stc++;
											 				  return stc-1;
											 	case typeFloat : printf("error: invalid operands to binary %s %s have ‘int’ and ‘float’ %s\n", "%","(", ")");
											 					return 0;
											}
							case typeFloat :  switch(sym[b].type){
								 				case typeCon: printf("error: invalid operands to binary %s %s have ‘float’ and ‘int’ %s\n", "%","(", ")");
											 				  return 0;
											 	case typeFloat : printf("error : invalid operands to binary %s %s have 'float' and 'float' %s\n","%","(", ")");
											 					return 0;
											}	

			 			}

			case '>':   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i>sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].i>sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].f>sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].f>sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}
			case '<':   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i<sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].i<sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].f<sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].f<sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}

			case INC:	a = ex(p->opr.op[0]);
			 			  switch(sym[a].type){
			 				case typeCon: 	sym[a].i = sym[a].i+1;
			 							  	sym[stc].type=typeCon;
										  	sym[stc].i= sym[a].i;
										  	if(p->opr.nops>1){
										  		sym[stc].i = sym[stc].i-1;
										  		ex(p->opr.op[0]);
										  	}
										  	stc++;
										  	return stc-1;
			 				case typeFloat: sym[a].f = sym[a].f+1;
			 							  	sym[stc].type=typeFloat;
										  	sym[stc].f= sym[a].f;
										  	if(p->opr.nops>1){
										  		sym[stc].f = sym[stc].f-1;
										  		ex(p->opr.op[0]);
										  	}
										  	stc++;
										  	return stc-1;
			 			}

			case DEC:	a = ex(p->opr.op[0]);
			 			  switch(sym[a].type){
			 				case typeCon: 	sym[a].i = sym[a].i-1;
			 							  	sym[stc].type=typeCon;
										  	sym[stc].i= sym[a].i;
										  	if(p->opr.nops>1){
										  		sym[stc].i = sym[stc].i+1;
										  		ex(p->opr.op[0]);
										  	}
										  	stc++;
										  	return stc-1;
			 				case typeFloat: sym[a].f = sym[a].f-1;
			 							  	sym[stc].type=typeFloat;
										  	sym[stc].f= sym[a].f;
										  	if(p->opr.nops>1){
										  		sym[stc].f = sym[stc].f+1;
										  		ex(p->opr.op[0]);
										  	}
										  	stc++;
										  	return stc-1;
			 			}

			case GE :   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i>=sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].i>=sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].f>=sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].f>=sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}
			case LE :   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i<=sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].i<=sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].f<=sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].f<=sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}

			case NE :   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i!=sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].i!=sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].f!=sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].f!=sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}
			case EQ :   a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].i==sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].i==sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[stc].type=typeCon;
											 				  sym[stc].i= sym[a].f==sym[b].i;
											 				  stc++;
											 				  return stc-1;
								 				case typeFloat : sym[stc].type=typeCon;
											 				  	 sym[stc].i= sym[a].f==sym[b].f;
											 				  	 stc++;
											 				  	 return stc-1;
								 			}
			 			}

			case PEQ :  a = ex(p->opr.op[0]); 
						b = ex(p->opr.op[1]);
						switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[a].i= sym[a].i+sym[b].i;
											 				  return a;
								 				case typeFloat : sym[a].i= sym[a].i+(int)sym[b].f;
											 				  	 return a;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[a].f= sym[a].f+sym[b].i;
											 				  return a;
								 				case typeFloat : sym[a].f= sym[a].f+sym[b].f;
											 				  	 return a;
								 			}
			 			}
			case MEQ :  a = ex(p->opr.op[0]); 
						b = ex(p->opr.op[1]);
						switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[a].i= sym[a].i-sym[b].i;
											 				  return a;
								 				case typeFloat : sym[a].i= sym[a].i-(int)sym[b].f;
											 				  	 return a;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[a].f= sym[a].f-sym[b].i;
											 				  return a;
								 				case typeFloat : sym[a].f= sym[a].f-sym[b].f;
											 				  	 return a;
								 			}
			 			}
			case MLEQ : a = ex(p->opr.op[0]); 
						b = ex(p->opr.op[1]);
						switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[a].i= sym[a].i*sym[b].i;
											 				  return a;
								 				case typeFloat : sym[a].i= sym[a].i*sym[b].f;
											 				  	 return a;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[a].f= sym[a].f*sym[b].i;
											 				  return a;
								 				case typeFloat : sym[a].f= sym[a].f*sym[b].f;
											 				  	 return a;
								 			}
			 			}
			case DEQ :  a = ex(p->opr.op[0]); 
						b = ex(p->opr.op[1]);
						switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: c = sym[a].i;
								 							  sym[a].i=0;
								 							  sym[a].type= typeFloat;
								 							  sym[a].f= (float)c/sym[b].i;
											 				  return a;
								 				case typeFloat : c = sym[a].i;
								 							     sym[a].i=0;
								 							     sym[a].type= typeFloat;
								 							     sym[a].f= (float)c/sym[b].f;
											 				     return a;
								 			}
			 				case typeFloat : switch(sym[b].type){
								 				case typeCon: sym[a].f= sym[a].f/sym[b].i;
											 				  return a;
								 				case typeFloat : sym[a].f= sym[a].f/sym[b].f;
											 				  	 return a;
								 			}
			 			}

			case MOEQ : a = ex(p->opr.op[0]); 
					    b = ex(p->opr.op[1]);
					    switch(sym[a].type){
			 				case typeCon: switch(sym[b].type){
								 				case typeCon: sym[a].i= sym[a].i%sym[b].i;
											 				  return a;
											 	case typeFloat : printf("error: invalid operands to binary %s %s have ‘int’ and ‘float’ %s\n", "%","(", ")");
											 					return 0;
											}
							case typeFloat :  switch(sym[b].type){
								 				case typeCon: printf("error: invalid operands to binary %s %s have ‘float’ and ‘int’ %s\n", "%","(", ")");
											 				  return 0;
											 	case typeFloat : printf("error : invalid operands to binary %s %s have 'float' and 'float' %s\n","%","(", ")");
											 					return 0;
											}	

			 			}


			 
		}

 	}
 return 0;
} 


void freeNode(nodeType *p) {
	 int i;
	 if (!p) return;
	 if (p->type == typeOpr) {
	 	for (i = 0; i < p->opr.nops; i++)
	 		freeNode(p->opr.op[i]);
	 	free(p->opr.op);
	 }
	 free (p); 
}

void yyerror(char *s) {
 	fprintf(stdout, "%s\n", s);
}
int main(void) {
	 yyparse();
	 return 0;
} 
