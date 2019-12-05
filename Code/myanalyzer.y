%{
#include <stdarg.h>
#include <stdio.h>	
#include "cgen.h"

extern int yylex(void);
extern char* yytext;

extern int line_num;

%}

%union
{
	char* crepr;
	 int num;

}

//tokens are terminals
//types are non terminals

%token <crepr> IDENT
%token <crepr> POSINT 
%token <crepr> REAL 
%token <crepr> STRING

%token ASSIGN

%token KW_ELSE 
%token KW_FOR 
%token KW_FUNCTION 
%token KW_GOTO 
%token KW_IF 
%token KW_NOT 
%token KW_VAR 
%token KW_OF 
%token KW_OR 
%token KW_WHILE 
%token KW_PROCEDURE 
%token KW_REPEAT 
%token KW_TO 
%token KW_RESULT 
%token KW_RETURN 
%token KW_THEN 
%token KW_UNTIL 
%token KW_DOWNTO 
%token KW_TYPE 
%token OP_PLUS 
%token OP_MINUS 
%token OP_MULT 
%token OP_DIV 
%token KW_MOD 
%token KW_DIV
%token KW_BREAK
%token KW_CONTINUE

%token KW_INT 
%token KW_REAL 

%token SEMICLN 
%token CLN 
%token EQ
%token DOT 
%token COMMA 
%token L_HOOK 
%token R_HOOK 
%token L_PARENTH
%token R_PARENTH

%token EXCL_MARK
%token CMPR_LESS 
%token CMPR_LESSEQ 
%token CMPR_GRTR
%token CMPR_GRTREQ 
%token CMPR_DIFF 
%token OP_AND 
%token OP_OR 

%token BOOL_TRUE 
%token BOOL_FALSE 

%token KW_DO 
%token KW_CHAR 
%token KW_PROGRAM 
%token KW_BEGIN 
%token KW_END 
%token KW_AND 
%token KW_ARRAY 
%token KW_BOOLEAN 

%start program

%type <crepr> program_decl main_body statements statement_list
%type <crepr> statement profunc_call arguments
%type <crepr> arglist expression table_exp
%type <crepr> if_statement
%type <crepr> else_statement
%type <crepr> for_statement
%type <crepr> while_statement
%type <crepr> repeat_statement
%type <crepr> label_statement
%type <crepr> goto_statement
%type <crepr> statement_cont 
%type <crepr> body_d
%type <crepr> body_decl
%type <crepr> var_decl
%type <crepr> var_decl_section
%type <crepr> var_type
%type <crepr> var_type_complex
%type <crepr> hooks
%type <crepr> ident_list
%type <crepr> type_decl
%type <crepr> type_decl_section
%type <crepr> profunc
%type <crepr> profunc_head_var
%type <crepr> profunc_head_var_list
%type <crepr> profunc_head_var_one

%type <crepr> profunc_head_pro
%type <crepr> profunc_head_func

// Low to High priority
%left OP_AND OP_OR
%left KW_AND KW_OR
%left EQ CMPR_GRTR CMPR_LESS CMPR_GRTREQ CMPR_LESSEQ CMPR_DIFF
%left OP_MINUS OP_PLUS
%left OP_MULT OP_DIV KW_DIV KW_MOD
%left EXCL_MARK KW_NOT


%%

program: 
		program_decl main_body  DOT 
			{
				if(yyerror_count==0) {
					printf("\n");
					printf("/* ---------------Analyzed Program-------------*/\n");
					puts(c_prologue);
					printf("/* program  %s */\n\n", $1);
					printf("%s", $2);
				}
				else {
					yyerror("\n", line_num);
				}
			}
;


program_decl : KW_PROGRAM IDENT SEMICLN  	{ $$ = $2; };

// body declarations ---------------------------------------------------
main_body: KW_BEGIN statements KW_END   					{ $$ = template("int main() {\nint result;\n%s\n}", $2); } // no pre_body
		 | body_decl KW_BEGIN statements KW_END  			{ $$ = template("\n%s \nint main() {\nint result;\n%s\n}", $1, $3); } // body + pre_body
		 | KW_BEGIN statements KW_END body_decl  			{ $$ = template("int main() {\nint result;\n%s\n}\n%s \n", $2, $4); } // body + pre_body
		 | body_decl KW_BEGIN statements KW_END body_decl  	{ $$ = template("\n%s \nint main() {\nint result;\n%s\n}\n%s \n", $1, $3, $5); } // body + pre_body
		 ;

body_decl: body_d
		 | body_decl body_d { $$ = template("%s%s", $1, $2); } 
		 ;

body_d: type_decl_section
	  | var_decl_section			 
	  | profunc SEMICLN
	  ;

// statement declarations ----------------------------------------------
statements: %empty			{ $$ = template(""); };
 		  | statement_list 	{ $$ = $1; };

statement_list: statement 						  { $$ = template("%s", $1); }
			  | statement_list SEMICLN statement  { $$ = template("%s\n%s", $1, $3); }
			  ; 

statement: 		
		   statement_cont
		 | if_statement
		 | while_statement
		 | for_statement
		 | repeat_statement
		 | label_statement
		 | goto_statement
	 	 ;

profunc_call: IDENT L_PARENTH arguments R_PARENTH 	{ $$ = template("%s(%s)", $1, $3); }
		 ;

if_statement: KW_IF expression KW_THEN statement_cont { $$ = template("if (%s)  {\n%s\n} ", $2, $4); }
			| if_statement else_statement 	  { $$ = template("%s %s", $1, $2); }	
			;

else_statement: KW_ELSE statement_cont 	  						{ $$ = template("else {\n%s\n}", $2); }
			  | KW_ELSE	 KW_IF expression KW_THEN statement_cont { $$ = template("else if (%s)  {\n%s\n}", $3, $5); }
			  ;

for_statement: KW_FOR IDENT ASSIGN expression KW_TO expression KW_DO statement_cont 
			   { $$ = template("for (%s = %s; %s<%s; %s++) {\n%s\n}", $2, $4, $2, $6, $2, $8); }
			 | KW_FOR IDENT ASSIGN expression KW_DOWNTO expression KW_DO statement_cont 
			   { $$ = template("for (%s = %s; %s>%s; %s--) {\n%s\n}", $2, $4, $2, $6, $2, $8); } 
			   ;

while_statement: KW_WHILE expression KW_DO statement_cont { $$ = template("while (%s)  {\n%s\n}", $2, $4); }
			   ;

repeat_statement: KW_REPEAT statement_cont KW_UNTIL expression { $$ = template("do {\n%s\n} while (!(%s));", $2, $4); }
				;

label_statement: IDENT CLN statement_cont { $$ = template("%s : %s", $1, $3); }
				;

goto_statement: KW_GOTO IDENT { $$ = template("goto %s;", $2); }
				;

statement_cont: // same as statement, but can only call "if","while","for","repeat" etc as a complex statement.
				// simple statements ----------------------------------------------
				KW_RETURN				{ $$ = template("return result;"); }
		 	  | KW_RETURN expression	{ $$ = template("return %s;", $2); }  
			  | KW_RESULT ASSIGN expression 		{ $$ = template(" result = %s;", $3); }
			  | KW_RESULT ASSIGN L_PARENTH var_type R_PARENTH  expression 		{ $$ = template(" result = (%s)%s;", $4,$6); }
			  | IDENT ASSIGN expression	 			{ $$ = template("%s = %s;", $1, $3); }
			  | IDENT ASSIGN L_PARENTH var_type R_PARENTH  expression	 			{ $$ = template("%s = (%s)%s;", $1, $4,$6); }
	     	  | IDENT table_exp ASSIGN expression	{ $$ = template("%s%s = %s;", $1, $2, $4); }  
			  | KW_RESULT OP_PLUS ASSIGN expression		{ $$ = template("result += %s;", $4); }
	     	  | KW_RESULT OP_MINUS ASSIGN expression	{ $$ = template("result -= %s;", $4); }
	     	  | IDENT OP_PLUS ASSIGN expression	 		{ $$ = template("%s += %s;", $1, $4); }
			  | IDENT OP_MINUS ASSIGN expression	 	{ $$ = template("%s -= %s;", $1, $4); }
	     	  | IDENT table_exp OP_PLUS ASSIGN expression  	{ $$ = template("%s%s += %s;", $1, $2, $5); }
			  | IDENT table_exp OP_MINUS ASSIGN expression 	{ $$ = template("%s%s -= %s;", $1, $2, $5); }			  
			  | KW_BREAK	{ $$ = template("break;"); }
          	  | KW_CONTINUE {$$ = template("continue;"); }
			  | profunc_call  							{ $$ = template("%s;", $1); }

			  // complex statement ----------------------------------------------
			  | KW_BEGIN statement_list KW_END  		{ $$ = template("%s", $2); } 
		  	  ;

arguments :	%empty		{ $$ = template(""); }
	 	  | arglist 	{ $$ = $1; }
	 	  |var_type 
	 	  ;

arglist: expression							{ $$ = $1; }
		| arglist COMMA expression 			{ $$ = template("%s,%s", $1, $3);  }
	    ;

expression: POSINT 							/* Default action: $$ = $1 */
          | REAL
          | IDENT
          | IDENT table_exp					{ $$ = template("%s%s", $1, $2); }
          | KW_RESULT						{ $$ = template("result"); }
          | profunc_call			
          | expression EXCL_MARK expression { $$ = template("%s ! %s", $1, $3); }
          | expression KW_NOT expression 	{ $$ = template("%s not %s", $1, $3); }
          | L_PARENTH expression R_PARENTH 	{ $$ = template("(%s)", $2); }
          | expression OP_MULT expression 	{ $$ = template("%s * %s", $1, $3); }
		  | expression OP_DIV expression 	{ $$ = template("%s / %s", $1, $3); }
		  | expression KW_DIV expression 	{ $$ = template("%s / %s", $1, $3); }
		  | expression KW_MOD expression 	{ $$ = template("%s %/**/ %s", $1, $3); }		  
          | OP_PLUS expression 				{ $$ = template("+ %s", $2); }
		  | OP_MINUS expression 			{ $$ = template("- %s", $2); }
		  | expression OP_PLUS expression 	{ $$ = template("%s + %s", $1, $3); }
		  | expression OP_MINUS expression 	{ $$ = template("%s - %s", $1, $3); }
		  | expression EQ expression 			{ $$ = template("%s == %s", $1, $3); }
		  | expression CMPR_DIFF expression 	{ $$ = template("%s <> %s", $1, $3); }
		  | expression CMPR_LESS expression 	{ $$ = template("%s < %s", $1, $3); }
		  | expression CMPR_LESSEQ expression 	{ $$ = template("%s <= %s", $1, $3); }
		  | expression CMPR_GRTR expression 	{ $$ = template("%s > %s", $1, $3); }
		  | expression CMPR_GRTREQ expression 	{ $$ = template("%s >= %s", $1, $3); }
		  | expression KW_AND expression 	{ $$ = template("%s && %s", $1, $3); }
		  | expression OP_AND expression 	{ $$ = template("%s && %s", $1, $3); }
		  | expression KW_OR expression 	{ $$ = template("%s || %s", $1, $3); }
		  | expression OP_OR expression 	{ $$ = template("%s || %s", $1, $3); }
          | BOOL_FALSE	{ $$ = template("0"); }
          | BOOL_TRUE 	{ $$ = template("1"); }
		  | STRING 							{ $$ = string_ptuc2c($1); }
         ;

table_exp: L_HOOK expression R_HOOK { $$ = template("[%s]",  $2); }
		 | table_exp L_HOOK expression R_HOOK {  $$ = template("%s [%s]", $1, $3); }
		 ;

// variable declarations ---------------------------------------------------------------
var_decl_section: KW_VAR var_decl  				  	{  $$ = template("%s\n", $2); } 
			 	| var_decl_section var_decl 	    {  $$ = template("%s%s\n", $1, $2); } 
			 	;

var_decl: ident_list CLN var_type SEMICLN 			{ $$ = template("%s %s;", $3, $1); }
		| ident_list CLN var_type_complex SEMICLN 	{ $$ = template("%s %s;", $3, $1); }
		| ident_list CLN KW_ARRAY hooks KW_OF var_type SEMICLN { $$ = template("%s %s%s;", $6, $1, $4); } // for proper .c file
		| ident_list CLN IDENT SEMICLN			 	{ $$ = template("%s %s;", $3, $1); }
		;

var_type: KW_INT	{ $$ = template("int"); }
		| KW_BOOLEAN{ $$ = template("int"); }
		| KW_CHAR	{ $$ = template("char"); }
		| KW_REAL	{ $$ = template("double"); }
		;

var_type_complex: KW_ARRAY KW_OF var_type		{ $$ = template("%s%s", $3, "*"); }
				//| KW_ARRAY hooks KW_OF var_type { $$ = template("%s%s", $4, $2); }
				;

hooks : L_HOOK POSINT R_HOOK 		{ $$ = template("[%s]", $2); } // Single hooks
      | hooks L_HOOK POSINT R_HOOK 	{ $$ = template("%s[%s]", $1, $3); } // Multiple hooks
	  ;

// type definitions - typedef ---------------------------------------------------------
type_decl_section: KW_TYPE type_decl SEMICLN 					 { $$ = template("typedef %s;\n", $2); } /// COMMA ???? 
			 	 | type_decl_section type_decl SEMICLN    { $$ = template("%stypedef %s;\n", $1, $2); } 
			 	 ;

type_decl: ident_list EQ var_type 			{ $$ = template("%s %s", $3, $1); }
		 | ident_list EQ var_type_complex 	{ $$ = template("%s %s", $3, $1); }
		 | ident_list EQ KW_FUNCTION L_PARENTH profunc_head_var R_PARENTH CLN var_type	{ $$ = template("%s (*%s)(%s)", $8, $1, $5); }
		 ;
		 
ident_list: IDENT 							
		  | ident_list COMMA IDENT  { $$ = template("%s, %s", $1, $3); }
		  ;

// procedures & functions  ------------------------------------------------------------

profunc:  // bodyless  
		  profunc_head_pro 	SEMICLN					{ $$ = template("%s;\n", $1); }
		| profunc_head_func 	SEMICLN					{ $$ = template("%s;\n", $1); }
		  // with body 
	 	| profunc_head_pro SEMICLN KW_BEGIN statements KW_END    { $$ = template("\n%s {\n%s\n}\n", $1, $4); }
	 	| profunc_head_func SEMICLN KW_BEGIN statements KW_END   { $$ = template("\n%s {\nint result;\n%s\n}\n", $1, $4); }
	 	  // with declarations
	 	| profunc_head_pro SEMICLN body_decl    { $$ = template("\n%s {\n\n%s\n}\n", $1, $3); }
	 	| profunc_head_func SEMICLN body_decl   { $$ = template("\n%s {\nint result;\n%s\n}\n", $1, $3); }
	 	  // with declarations & body
	 	| profunc_head_pro SEMICLN body_decl  KW_BEGIN statements KW_END    { $$ = template("\n%s{\n \n%s \n%s\n}\n", $1, $3,$5); }
	 	| profunc_head_func SEMICLN body_decl  KW_BEGIN statements KW_END   { $$ = template("\n%s{\nint result;\n%s \n%s\n}\n", $1, $3,$5); }
	    ;


profunc_head_pro: KW_PROCEDURE IDENT L_PARENTH profunc_head_var R_PARENTH 				{ $$ = template("void %s (%s)", $2, $4); }
				;

profunc_head_func: KW_FUNCTION IDENT L_PARENTH profunc_head_var R_PARENTH CLN var_type   		{ $$ = template("%s %s (%s)",$7, $2, $4); }
				 | KW_FUNCTION IDENT L_PARENTH profunc_head_var R_PARENTH CLN var_type_complex   { $$ = template("%s %s (%s)",$7, $2, $4); }
				 ;

profunc_head_var: %empty				{ $$ = template(""); }
				| profunc_head_var_list 	{ $$ = template("%s", $1); }
		 		;

profunc_head_var_list: profunc_head_var_one 
					 | profunc_head_var_one SEMICLN profunc_head_var_list { $$ = template("%s, %s", $1, $3); }
					 ;

profunc_head_var_one: IDENT CLN var_type 		  	  { $$ = template("%s %s", $3, $1); }
			   	    | IDENT CLN var_type_complex	   	  { $$ = template("%s %s", $3, $1); }
			   	    | IDENT COMMA IDENT CLN var_type 		{ $$ = template("%s %s, %s %s", $5, $1, $5, $3); } 
			   	    | IDENT COMMA IDENT CLN var_type_complex { $$ = template("%s %s, %s %s", $5, $1, $5, $3); } 
			   	    | IDENT CLN IDENT 	 		  	  { $$ = template("%s %s", $3, $1); }
			   	    ;

%%

int main ()
{

 if (yyparse()==0) {
 	if (yyerror_count==0)
 		printf("\n/***** Accepted! *****/\n");
 	else {
 		printf("\n\n/***** Rejected *****/\n\n"); // due to lexical error
  	}
 }
 else {
 	printf("\n\n/** Syntax error in line %d */", line_num);
 	printf("\n\n/***** Rejected *****/\n\n"); 	  // due to syntax error
 } 
}

