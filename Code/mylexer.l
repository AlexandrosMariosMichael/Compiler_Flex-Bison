%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "myanalyzer.tab.h"
#include "cgen.h"

#define MAXMACRO 32

/* 
	A primitive macro facility:
	just one macro is allowed to be defined! 
*/

int line_num = 1;
char* mactable[MAXMACRO][2];
int mactable_size = 0;

/* Return 1 on success, 0 on failure (macro table full) */
int set_macro(char* name, char* def);

/* Return def for macro, or NULL if no such macro is defined. */
char* get_macro(char* name);

%}

ID [a-zA-Z_][0-9a-zA-Z_]*
DIGIT  [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL    {DECIMAL}([eE][+-]?{NUMBER})?
STRING   ('[^'\n]*')|(\"(\\.|[^"\\])*\")    

%x comment
%x line_comment
%x macro

%%

program             { printf("//token KW_PROGRAM: %s\n", yytext);
                      return KW_PROGRAM;}
begin               { printf("//token KW_BEGIN: %s\n", yytext);
                      return KW_BEGIN;}
end                 { printf("//token KW_END: %s\n", yytext);
                      return KW_END;}
and                 { printf("//token KW_AND: %s\n", yytext);
                      return KW_AND;}
array               { printf("//token KW_ARRAY: %s\n", yytext);
                      return KW_ARRAY;}
do                  { printf("//token KW_DO: %s\n", yytext);
                      return KW_DO;}
else                { printf("//token KW_ELSE: %s\n", yytext);
                      return KW_ELSE;}
for                 { printf("//token KW_FOR: %s\n", yytext);
                      return KW_FOR;}
function            { printf("//token KW_FUNCTION: %s\n", yytext);
                      return KW_FUNCTION;}
goto                { printf("//token KW_GOTO: %s\n", yytext);
                      return KW_GOTO;}
if                  { printf("//token KW_IF: %s\n", yytext);
                      return KW_IF;}
var                 { printf("//token KW_VAR: %s\n", yytext);
                      return KW_VAR;}
not                 { printf("//token KW_NOT: %s\n", yytext);
                      return KW_NOT;}
of                  { printf("//token KW_OF: %s\n", yytext);
                      return KW_OF;}
or                  { printf("//token KW_OR: %s\n", yytext);
                      return KW_OR;}
while               { printf("//token KW_WHILE: %s\n", yytext);
                      return KW_WHILE;}
procedure           { printf("//token KW_PROCEDURE: %s\n", yytext);
                      return KW_PROCEDURE;}
repeat              { printf("//token KW_REPEAT: %s\n", yytext);
                      return KW_REPEAT;}
to                  { printf("//token KW_TO: %s\n", yytext);
                      return KW_TO;}
result              { printf("//token KW_RESULT: %s\n", yytext);
                      return KW_RESULT;}
return              { printf("//token KW_RETURN: %s\n", yytext);
                      return KW_RETURN;}
then                { printf("//token KW_THEN: %s\n", yytext);
                      return KW_THEN;}
until               { printf("//token KW_UNTIL: %s\n", yytext);
                      return KW_UNTIL;}
downto              { printf("//token KW_DOWNTO: %s\n", yytext);
                      return KW_DOWNTO;}
type                { printf("//token KW_TYPE: %s\n", yytext);
                      return KW_TYPE;}

integer             { printf("//token KW_INT: %s\n", yytext);
                      return KW_INT;}
boolean             { printf("//token KW_BOOLEAN: %s\n", yytext);
                      return KW_BOOLEAN;}
char                { printf("//token KW_CHAR: %s\n", yytext);
                      return KW_CHAR;}
real               { printf("//token KW_REAL: %s\n", yytext);
                      return KW_REAL;}


":=" 					{	printf("//token ASSIGN : %s\n", yytext);	
							return ASSIGN;}

"+"					  	{ 	printf("//token OP_PLUS : %s\n", yytext);	
							return OP_PLUS;}

"-"					  	{ 	printf("//token OP_MINUS: %s\n", yytext);	
							return OP_MINUS; }

"*"						{ 	printf("//token OP_MULT: %s\n", yytext);	
							return OP_MULT; }

"/"						{ 	printf("//token OP_DIV: %s\n", yytext);	
							return OP_DIV; }

mod						{ 	printf("//token KW_MOD: %s\n", yytext);	
							return KW_MOD; }

div						{ 	printf("//token KW_DIV: %s\n", yytext);	
							return KW_DIV; }

"!"						{ 	printf("//token EXCL_MARK: %s\n", yytext);	
							return EXCL_MARK; }

";"						{ 	printf("//token SEMICLN: %s\n", yytext);	
							return SEMICLN; }

":"						{ 	printf("//token CLN: %s\n", yytext);	
							return CLN; }

"="						{ 	printf("//token EQ: %s\n", yytext);	
							return EQ; }

"."						{ 	printf("//token DOT: %s\n", yytext);	
							return DOT; }

","						{ 	printf("//token COMMA: %s\n", yytext);	
							return COMMA; }

"["						{ 	printf("//token L_HOOK: %s\n", yytext);	
							return L_HOOK; }

"]"						{ 	printf("//token R_HOOK: %s\n", yytext);	
							return R_HOOK; }

"("						{ 	printf("//token L_PARENTH: %s\n", yytext);	
							return L_PARENTH; }

")"						{ 	printf("//token R_PARENTH: %s\n", yytext);	
							return R_PARENTH; }

"<"						{ 	printf("//token CMPR_LESS: %s\n", yytext);	
							return CMPR_LESS; }

"<="					{ 	printf("//token CMPR_LESSEQ: %s\n", yytext);	
							return CMPR_LESSEQ; }

">"						{ 	printf("//token CMPR_GRTR: %s\n", yytext);	
							return CMPR_GRTR; }

">="					{ 	printf("//token CMPR_GRTREQ: %s\n", yytext);	
							return CMPR_GRTREQ; }

"<>"					{ 	printf("//token CMPR_DIFF: %s\n", yytext);	
							return CMPR_DIFF; }

"&&"					{ 	printf("//token OP_AND: %s\n", yytext);	
							return OP_AND; }

"||"					{ 	printf("//token OP_OR: %s\n", yytext);	
							return OP_OR; }


true 					{ 	printf("//token BOOL_TRUE: %s\n", yytext);	
							return BOOL_TRUE; }

false 					{ 	printf("//token BOOL_FALSE: %s\n", yytext);	
							return BOOL_FALSE; }

break 					{ 	printf("//token KW_BREAK: %s\n", yytext);	
							return KW_BREAK; }

continue 				{	printf("//token KW_CONTINUE: %s\n", yytext);	
							return KW_CONTINUE; }



@defmacro[ \r\t]+       BEGIN(macro);
<macro>{ID}             {
							/* Store macro name */
							char* name = strdup(yytext);
							char* def = NULL;
							size_t deflen = 0;
							char c;

							FILE* deff = open_memstream(&def, &deflen);
							while((c=input())!='\n')
								if (c != '(' && c != ')')
								   	fputc(c, deff);
							fclose(deff);

							if(!set_macro(name, def))
								yyerror("lexer error: failed to define macro '%s'\n", name);
							BEGIN(INITIAL);
						};



{ID}  					{
						   char* def = get_macro(yytext);
						   if(def==NULL) {
						   	   printf( "//token IDENTIFIER: %s\n", yytext);
						   		yylval.crepr = strdup(yytext);
						   		return IDENT;
						   	}
						   	else {
						   		int i;
						   		for(i=strlen(def); i>0; i--) {
						   	  		unput(def[i-1]);
						   	}
						   
						   }
						} 						

{NUMBER}				{   printf( "//token POS_INTEGER: %s\n", yytext);
                   yylval.crepr = strdup(yytext); 
							return POSINT; }
{REAL}					{  printf( "//token POS_REAL: %s\n", yytext);
                  yylval.crepr = strdup(yytext); 
							return REAL; }
{STRING}				{  printf( "//token STRING: %s\n", yytext);
                yylval.crepr = strdup(yytext); 
							return STRING; }



"(*"					BEGIN(comment);
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*)\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             ++line_num;
<comment>"*"+")"        BEGIN(INITIAL);



[ \r\t]					/* skip whitespace */
\n 						++line_num;
"//"[^\n]*					
<<EOF>> 				return EOF;

.        { printf("\n\n/** Lexical error in line %d **/\n", line_num); 
		   yyerror("unrecognised literal : '%s' \n", yytext); }

%%

int set_macro(char* name, char* def)
{
	/* Check to see if macro already defined, and redefine it. */
	int i;
	for(i=0; i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0) {
			/* found ! */
			free(name);
			free(mactable[i][1]);
			mactable[i][1] = def;
			break;
		}
	}
	if(i<mactable_size)
		return 1;
	else if(mactable_size < MAXMACRO) {
		/* new entry */
		assert(i==mactable_size);
		mactable[i][0] = name;
		mactable[i][1] = def;
		mactable_size++;
		return 1;
	}
	else
		return 0;
}

char* get_macro(char* name)
{

	for(int i=0;i<mactable_size; i++) {
		if(strcmp(mactable[i][0], name)==0)
			return mactable[i][1];
	}
	return NULL;
}


