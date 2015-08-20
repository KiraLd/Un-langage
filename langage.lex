%{
	#include <stdlib.h>
	#include "define.h"
	#include "y.tab.h"
%}
NOMBRE [0-9]+
ESPACE	[ \t]
%%
ESPACE
^{ESPACE}+	
{ESPACE}+$	
{ESPACE}+	{return yytext[0];}
=	{	yylval.ival = _EGAL_;
		return egal;
	}
\+	{
		yylval.ival = _PLUS_;
		return plus;
	}
\-	{
		yylval.ival = _MOINS_;
		return moins;
	}
\<	{
		yylval.ival = _DECG_;
		return decg;
	}
\>	{
		yylval.ival = _DECD_;
		return decd;
	}
\@	{
		yylval.ival = _BUF_;
		return buffer;
	}
function	{
			yylval.ival = _FONCTION_;
			return f_;
		}
if	{
		yylval.ival = _IF_;
		return if_;
	}
goto	{
		yylval.ival = _GOTO_;
		return goto_;
	}
label	{
		yylval.ival = _LABEL_;
		return label_;
	}
in	{
		yylval.ival = _IN_;
		return scan_;
	}
out	{
		yylval.ival = _OUT_;
		return print_;
	}
end	{
		yylval.ival = _END_;
		return end_;
	}
end_function	{
			yylval.ival = _END_FUNCTION_;
			return end_function;
		}
exit	{
		yylval.ival = _EXIT_;
		return exit_;
	}
main	{
		yylval.ival = _MAIN_;
		return main_;
	}

inf	{
		yylval.ival = _INF_;
		return inf_;
	}
\;	{return yytext[0];}
\)	{return yytext[0];}
\(	{return yytext[0];}
{NOMBRE}	{
		yylval.ival = atoi(yytext);
		return	cst;
	}
.
