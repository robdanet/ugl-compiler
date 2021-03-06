%{
/*  ugly.y,v 0.1 08/12/2013 Antonio Molinaro 
*
* Parser specification for ugl-compiler
*/
#include <stdio.h> /* for (f)printf() */
#include <stdlib.h> /* for exit() */

#include "symbol.h"

int  lineno = 1; /* number of current source line */
extern int yylex(); /* lexical analyzer generated from lex.l */
extern char *yytext; /* last token, defined in lex.l  */

void
yyerror(char *s) {
  fprintf(stderr, "Syntax error on line #%d: %s\n", lineno, s);
  fprintf(stderr, "Last token was \"%s\"\n", yytext);
  exit(1);
}
int cs = 1;
#define PROLOGUE "\
.section .text\n\
.globl _start\n\
\n\
_start:\n\
	call main \n\
	jmp exit\n\
.globl main\n\
.type main, @function\n\
main:\n\
	pushl %ebp /* save base(frame) pointer on stack */\n\
	movl %esp, %ebp /* base pointer is stack pointer */\n\
"

#define EPILOGUE "\
	movl %ebp, %esp\n\
	popl %ebp /* restore old frame pointer */\n\
	ret\n\
.type exit, @function\n\
exit:\n\
	movl $0, %ebx\n\
	movl $1, %eax\n\
	int $0x80\n\
"

%}

%union {
 int idx;
 int value;
 int i_value;
 }

%token NAME
%token NUMBER
 
 
 
 
%token DECLARE WHILE THEN FI WRITE IF READ LET
  
%token LPAREN RPAREN LBRACE RBRACE COMMA  SEMICOLON

%nonassoc IFX WHFX
%nonassoc ELSE  END

%nonassoc GT
%nonassoc EQ
%nonassoc LT
%nonassoc NE
%nonassoc GE
%nonassoc LE

 
%left PLUS MINUS
%left MULT DIV
%right ASSIGN

%type <idx>   NAME  var
%type <value> NUMBER  

%%
program         : LBRACE { puts(".section .data\n");
		           puts("FRM1:\t.string \"%d\\n\"\n");
		         } 
		  declaration_list { puts(PROLOGUE); } 
		  statement_list 
                  RBRACE { puts(EPILOGUE); }
                  |
                ;
declaration_list  : declaration SEMICOLON declaration_list  
                | /* empty */
                ;

statement_list  :  
	         statement SEMICOLON statement_list
              	| /* empty */
                ;

statement       : assignment
                | read_statement
                | write_statement
                | if_statement
                | else_part
                | while_loop_statement
                | end_part  
		| LBRACE statement  RBRACE                
                ;
 

declaration     : DECLARE NAME  
                  { 
                     if (symbol_declared($2)) {
                       fprintf(stderr, 
                               "Variable \"%s\" already declared (line %d)\n",
                               symbol_name($2), lineno);
                       exit(1);
                     }
                     else {
		       printf(".lcomm %s, 4\n", symbol_name($2));
                       symbol_declare($2); 
                     }
                  }
          | declaration COMMA NAME
          	   { 
                     if (symbol_declared($3)) {
                       fprintf(stderr, 
                               "Variable \"%s\" already declared (line %d)\n",
                               symbol_name($3), lineno);
                       exit(1);
                     }
                     else {
		       printf(".lcomm %s, 4\n", symbol_name($3));
                       symbol_declare($3); 
                     }
                  }
		;

assignment      : var ASSIGN expression 
                  {
                     
	            		/* we assume that the expresion value is (%esp) */
                		 printf("\tpopl %s\n", symbol_name($1));
                 		//   symbol_setValue($3, $1);  
                  }
                  
                  ;  
               
                  

read_statement  : READ var 
		{
		  		 /* aggiunto 29 9 2013 */
 
				printf("\tpushl $%s \n", symbol_name($2));
				puts("\tpushl $FRM\n");
				puts("\tcall scanf\n"); 
				puts("\taddl $8, %esp\n"); 
 
	         }
		 ;

write_statement : WRITE expression { puts("\tpushl $FRM1\n\tcall printf\n"); }
            ;
 
if_statement :  IF LPAREN expression RPAREN  LBRACE  statement_list  RBRACE    %prec IFX  {  }
									    
	    |	IF LPAREN expression RPAREN   LBRACE statement  RBRACE    else_part   { } 
	    ;
else_part:  ELSE   LBRACE statement  RBRACE      { }
	    ;
 	
	
while_loop_statement :  WHILE LPAREN loop_expression RPAREN   statement    %prec WHFX { }
	    |	WHILE LPAREN loop_expression RPAREN    statement  end_part    
	    ;
end_part:  END   { }
	;	
	
 
	
expression      : term
		| term PLUS term { puts("\tpopl %eax\n\taddl %eax, (%esp)\n"); } /* aggiunto 13 10 2013 */
                | term MINUS term { puts("\tpopl %eax\n\tsubl %eax, (%esp)\n"); }
               	| term MULT term  {
               				
      					puts("\tpopl %eax\n");
      					puts("\tpopl %edx");
        				
					puts("\timull %edx, %eax\n");
					puts("\tpushl    %eax\n");
               
               		          }
               
                | term DIV term	{	puts("\tpopl %edx\n\tpopl %eax\n"); /* aggiunto 13 10 2013 */
                		        puts("\tmovl %edx,-20(%ebp)\n");
        			        puts("\tmovl %eax, %edx\n");
					puts("\tsarl $31, %edx\n");
					puts("\tidivl -20(%ebp)\n");
					puts("\tpushl %eax\n");
                
                 		}
                | term GT term        
				
		| term EQ term  
				
		| term LT term  	 
					
		| term NE term		 
				
		| term GE term          
				
		| term LE term     
				
		;		



term            : NUMBER { printf("\tpushl $%d\n", $1); }
                | var { printf("\tpushl %s\n", symbol_name($1)); }
                |  LPAREN expression  RPAREN
 
		;
var             : NAME
                  {
                    if (!symbol_declared($1)) {
                      fprintf(stderr, 
                              "Variable \"%s\" not declared (line %d)\n", 
                              symbol_name($1), lineno);
                      exit(1);
                    }
                    $$ = $1;
                     
                  }
                ;
%%

int
main(int argc,char *argv[]) {
  return yyparse();
} 
