%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "define.h"
	extern int yydebug;
	FILE* fp = NULL;
	int allouer = 0;
	int function = 0;
	int tabulation_ = 0;
	void tabulation();
%}
%union {int ival;}
%token <ival>cst 
%token <ival>plus 
%token <ival>moins
%token <ival>decg
%token <ival>decd
%token <ival>egal
%token <ival>buffer
%token <ival>goto_
%token <ival>if_
%token <ival>label_
%token <ival>end_
%token <ival>print_
%token <ival>scan_
%token <ival>f_
%token <ival>fonction
%token <ival>exit_
%token <ival>main_
%token <ival>end_function

%type <ival>MAIN
%type <ival>INSTR_
%type <ival>INSTR
%type <ival>END_FUNCTION
%type <ival>EXP
%type <ival>BUF
%type <ival>LABEL
%type <ival>GOTO
%type <ival>IF
%type <ival>END
%type <ival>PRINT
%type <ival>SCAN
%type <ival>OP
%type <ival>ENTETE
%type <ival>F
%type <ival>EXIT
%type <ival>ALLOUER 
%start PROGRAMME
%%
PROGRAMME	:	ALLOUER LISTE	EXIT	{
							fprintf(fp,"\treturn 0;\n}");
							exit(0);
						}
		;
	
LISTE	:	LISTE_FONCTION MAIN	LISTE_INSTR
	|
	;
	
LISTE_FONCTION	:	FONCTION	LISTE_FONCTION
		|
		;

FONCTION	:	ENTETE	LISTE_INSTR	END_FUNCTION
		;


LISTE_INSTR	:	INSTR_	LISTE_INSTR
		|
		;
	
INSTR_	:	INSTR';'	{
					if($1 != _LABEL_ && $1 != _END_ && $1 != _IF_)
					{
						fprintf(fp,";");
					}
					fprintf(fp,"\n");
				}
	;
	
INSTR	:	OP	{
				tabulation();
				switch($1)
				{
					case _DECD_:
						fprintf(fp,"i = (i+1)%%max");
						break;
					case _DECG_:
						fprintf(fp,"i = (i-1)%%max");
						break;
					case _PLUS_:
						fprintf(fp,"tab[i]++");
						break;
					case _MOINS_:
						fprintf(fp,"tab[i]--");
						break;
					case _EGAL_:
						fprintf(fp,"buf = tab[i]");
						break;
				}
			}
	|	BUF	OP	EXP	
	|	LABEL	' '	EXP	{
						tabulation();
						tabulation_++;
						fprintf(fp,"label%d:",$3);
					}
	|	IF	EXP	'<'	EXP
	|	END
	|	GOTO	' '	EXP	{
						tabulation_--;
						tabulation();
						fprintf(fp,"goto label%d",$3);
					}
	|	PRINT	EXP
	|	SCAN	EXP
	|	INSTR' '
	|	F	'('	EXP	')'
	;
	
OP	:	plus
	|	moins
	|	decg
	|	decd
	|	egal
	|	OP' '
	;
	
F	:	f_
	;

ENTETE	:	F	{
				tabulation_++;
				fprintf(fp,"void fonction%d()\n{\n",function);
			}
	;
	
BUF	:	buffer
	;
	
EXP	:	cst	{$$ = $1;}
	|	EXP' '
	;

ALLOUER	:	EXP	{
				allouer = $1;
				fprintf(fp,"int max = %d;\n",$1);
			}
	;
	
LABEL	:	label_
	;
	
GOTO	:	goto_
	;
	
IF	:	if_
	;

END	:	end_	{
				tabulation_--;
				fprintf(fp,"}\n");
			}
	;

END_FUNCTION	:	end_function	{
						tabulation_--;
						fprintf(fp,"}\n");
					}
		;
	
PRINT	:	print_
	;
	
SCAN	:	scan_
	;

EXIT	:	exit_
	;

MAIN	:	main_	{
				tabulation_++;
				fprintf(fp,"int main(void)\n{\n");
			}
	;

%%
void tabulation()
{
	int i;
	if(tabulation_ > 0)
	{
		char* chaine = (char*)malloc(sizeof(char)*tabulation_);
		for(i = 0; i < tabulation_;i++)
		{
			chaine[i] = '\t';
		}
		fprintf(fp,"%s",chaine);
		free(chaine);
	}
}

void creation_source()
{
	fprintf(fp,"#include <stdlib>\n");
	fprintf(fp,"#include <stdio>\n");
	fprintf(fp,"int* tab = NULL;\n");
	fprintf(fp,"int i = 0;\n");
	fprintf(fp,"int buf = 0;\n");
}
void yyerror(char const *s)
{
	fprintf(stderr, "%s\n",s);
}
int main()
{
	yydebug = 1;
	fp = fopen("source.c","a");
	if(fp != NULL)
	{
		creation_source();
	}
	else
	{
		exit(0);
	}
	yyparse();
}
