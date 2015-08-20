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
%token <ival>inf_

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
%type <ival>ENTETE_IF
%type <ival>STRUCTURE_IF
%type <ival>INF
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
					if($1 != _LABEL_ && $1 != _END_ && $1 != _IF_ && $1 != _IN_)
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
	|	BUF	' '	OP	' '	EXP	{
								tabulation();
								switch($3)
								{
									case _DECD_:
										fprintf(fp,"buf = buf >> %d %%32",$5);
										break;
									case _DECG_:
										fprintf(fp,"buf = buf << %d %%32",$5);
										break;
									case _PLUS_:
										fprintf(fp,"buf += %d",$5);
										break;
									case _MOINS_:
										fprintf(fp,"buf -= %d",$5);
										break;
									case _EGAL_:
										fprintf(fp,"buf = %d",$5);
										break;
								}
							}
										
	|	LABEL	' '	EXP	{
						tabulation();
						fprintf(fp,"label%d:",$3);
					}
	|	STRUCTURE_IF
	|	GOTO	' '	EXP	{
						tabulation();
						fprintf(fp,"goto label%d",$3);
					}
	|	PRINT	' '	EXP	{
						tabulation();
						fprintf(fp,"printf(\"%%c\",(char)tab[i])");
					}
	|	SCAN	' '	EXP	{
						tabulation();
						fprintf(fp,"if(scanf(\"%%d\",&tab[%d]) == -1)\n",$3);
						tabulation();
						fprintf(fp,"{\n");
						tabulation();
						fprintf(fp,"\tperror(\"\nErreur scan\")");
						tabulation();
						fprintf(fp,"}");
					}
	|	INSTR' '
	|	F	'('	EXP	')'	{
							tabulation();
							fprintf(fp,"fonction%d()",$3);
						}
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
				tabulation();
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
				tabulation();
				fprintf(fp,"tab = (int*)malloc(sizeof(int)*max);\n");
			}
	;

ENTETE_IF	:	IF	' '	EXP	INF	' '	BUF	{
										tabulation();
										fprintf(fp,"if(%d < buf)\n",$3);
										tabulation();
										tabulation_++;
										fprintf(fp,"{\n");
									}
		|	IF	' '	BUF	INF	' '	EXP	{
										tabulation();
										fprintf(fp,"if(buf < %d)\n",$6);
										tabulation();
										tabulation_++;
										fprintf(fp,"{\n");
									}
		|	IF	' '	EXP	INF	' '	EXP	{
										tabulation();
										fprintf(fp,"if(tab[%d] < tab[%d])\n",$3,$6);
										tabulation();
										tabulation_++;
										fprintf(fp,"{\n");
									}
		;

LISTE_IF	:	INSTR_	LISTE_IF
		|
		;

STRUCTURE_IF	:	ENTETE_IF	LISTE_IF	END
		;

INF	:	inf_
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
	fprintf(fp,"#include <stdlib.h>\n");
	fprintf(fp,"#include <stdio.h>\n");
	fprintf(fp,"int* tab = NULL;\n");
	fprintf(fp,"int i = 0;\n");
	fprintf(fp,"int buf = 0;\n");
}
void yyerror(char const *s)
{
	fprintf(stderr, "%s\n",s);
}
extern FILE* yyin;
int main(int argc, char* argv[])
{
	yydebug = 1;
	if(argc < 2)
	{
		exit(0);
	}
	yyin = fopen(argv[1],"r");
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
