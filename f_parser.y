%{


#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "f_shared.h"


int yylineno;

void yyerror(const char * s) {
  fprintf(stderr, "error: '%s' - LINE '%d'\n", s, yylineno);
}

int main() {
	yyparse();
}

%}

%start program

%union {
	float cst_double;
	int cst_int;
	char *cst_string;
}

%error-verbose

%token TP_BOOL BREAK TO_CIRCLE CONST DEFFUNC <cst_double>TP_DOUBLE ELSE B_FALSE L_FOR TO_GLOOP TO_GSTRIP IF IN
%token <cst_int>TP_INT TO_LABEL TO_LINE M_MAIN NEW PAINT TO_POINT TO_POLYGON PRINT PROGRAM READ RETURN <cst_string>TP_STRING
%token B_TRUE USE VOID L_WHILE WINDOW THIS_BGC THIS_COLOR THIS_LINECOLOR THIS_LINEWIDTH THIS_POINTA
%token THIS_POINTB THIS_POINTS THIS_POSX THIS_POSY THIS_RADIO THIS_SIZE THIS_TEXT THIS_TYPE THIS_WIDTH
%token THIS_HEIGHT THIS_WINDOWICON THIS_WINDOWLABEL CST_INT CST_DOUBLE CST_STRING ID LCURLYB RCURLYB ASSIGN
%token PLUSASSIGN MINUSASSIGN TIMESASSIGN DIVASSIGN MODASSIGN OR AND EQUAL UNEQUAL LESSTHAN GREATERTHAN LESSEQUAL
%token GREATEREQUAL PLUS MINUS TIMES DIVISION MOD NOT PLUSPLUS LESSLESS LPAR RPAR COMMA SEMICOLON LBRAC RBRAC POINT



%%

program: 		PROGRAM ID LCURLYB imports header_var_decl method_decl main_method RCURLYB
	 		;

imports: 		imports USE ID SEMICOLON 
	 		|
	 		;

header_var_decl:	header_var_decl type decl_location simple_assign more_decl SEMICOLON
			|
			;

type: 			type_prim 
			| type_obj
			;

type_prim:		TP_DOUBLE 
			| TP_INT 
			| TP_BOOL
			| TP_STRING
			;

type_obj:		TO_CIRCLE 
			| TO_GLOOP 
			| TO_GSTRIP  
			| TO_LINE
			| TO_POINT 
			| TO_POLYGON 
			| TO_LABEL
			;
	  
decl_location:		ID dl 
			| LBRAC RBRAC ID
			;

dl:			LBRAC RBRAC 
			|
			;
	
simple_assign:		ASSIGN sa 
			|
			;
  		    	 
sa:			exp 
			| assign_obj
			;

exp: 			exp OR join 
			| join
			;

join: 			join AND equalitty 
			| equalitty
			;
  	 
equalitty: 		equalitty EQUAL rel 
			| equalitty UNEQUAL rel 
			| rel
			;

rel:			exp1 LESSTHAN exp1 
			| exp1 LESSEQUAL exp1 
			| exp1 GREATEREQUAL exp1 
			| exp1 GREATERTHAN exp1 
			| exp1
			;
  	  	 
exp1: 			exp1 PLUS term 
			| exp1 MINUS term 
			| term
			;

term: 			term TIMES unary 
			| term DIVISION unary 
			| term MOD unary 
			| unary
			;

unary:			NOT unary 
			| MINUS unary 
			| PLUSPLUS factor 
			| LESSLESS factor 
			| factor PLUSPLUS 
			| factor LESSLESS 
			| factor
			;	
  	  	
factor:			LPAR exp RPAR 
			| location 
			| method_call 
			| CST_INT 
			| CST_DOUBLE 
			| CST_STRING 
			| B_TRUE 
			| B_FALSE
			;

location: 		ID loc2 loc3
			;

loc2:			loc4 
			| 
			;
  	   	 
loc3: 			POINT location 
			| 
			;

loc4: 			LBRAC exp RBRAC
			;
  	    
method_call: 		ID method_c LPAR method_params RPAR
			;

method_c:  		POINT ID 
			|
			;

method_params:		exp more_params
			|
			;

more_params: 		more_params COMMA exp
			|
			;


assign_obj:		NEW obj
			;

obj:			type_prim loc4 
			| obj1
			;
  	 	 
obj1:			TO_CIRCLE objC
			| TO_GLOOP objGL
			| TO_GSTRIP objGS
			| TO_LINE objL 
			| TO_POINT objP 
			| TO_POLYGON objPol 
			| TO_LABEL objLab
			;
  	 	       
objC: 			loc4 
			| LCURLYB objC1 RCURLYB
			;
  	 	 
objC1:			THIS_RADIO simple_assign COMMA 
			THIS_POSX simple_assign COMMA 
			THIS_POSY simple_assign COMMA 
			THIS_LINEWIDTH simple_assign COMMA 
			THIS_LINECOLOR simple_assign COMMA 
			THIS_BGC simple_assign
			;

objGL: 			loc4 
			| LCURLYB objGL1 RCURLYB
			;

objGL1:			THIS_POINTS simple_assign COMMA 
			THIS_LINEWIDTH simple_assign COMMA 
			THIS_LINECOLOR simple_assign COMMA 
			THIS_BGC simple_assign
			;

objGS:			loc4 
			| LCURLYB objGS1 RCURLYB
			;


objGS1:			THIS_POINTS simple_assign COMMA
			THIS_LINEWIDTH simple_assign COMMA 
			THIS_LINECOLOR simple_assign 	 
			;

objL:			loc4 
			| LCURLYB objL1 RCURLYB 
			;

objL1:			THIS_POINTA simple_assign COMMA 
			THIS_POINTB simple_assign COMMA
			THIS_LINEWIDTH simple_assign COMMA 
			THIS_LINECOLOR simple_assign
			;

objP:			loc4 
			| LCURLYB objP1 RCURLYB
	          	;

objP1:			THIS_POSX simple_assign COMMA 
			THIS_POSY simple_assign COMMA 
			THIS_SIZE simple_assign COMMA 
			THIS_COLOR simple_assign 
			;

objPol:			loc4 
			| LCURLYB objPol1 RCURLYB
			;

objPol1:		THIS_POINTS simple_assign COMMA
			THIS_LINEWIDTH simple_assign COMMA 
			THIS_LINECOLOR simple_assign COMMA
			THIS_BGC simple_assign
			;

objLab:			loc4 
			| LCURLYB objLab1 RCURLYB
			;
  	  	    
objLab1:		THIS_TEXT simple_assign COMMA
			THIS_POSX simple_assign COMMA 
			THIS_POSY simple_assign COMMA 
			THIS_SIZE simple_assign COMMA 
			THIS_COLOR simple_assign COMMA
			THIS_TYPE simple_assign
			;

more_decl:		more_decl COMMA dl simple_assign
 			|
 			;

method_decl:		method_decl DEFFUNC method_type ID LPAR method_par_decl RPAR method_block
			|
			;

method_type:		VOID 
  	    		| type dl
  	    		;

method_par_decl:	ref type decl_location mpd
			|
			;

ref:			CONST 
	            	|
	            	;
		      	
mpd:			mpd COMMA method_par_decl
     			|
      			;

method_block:		LCURLYB header_var_decl statements RCURLYB
       			;

statements: 		statements statement 
			| statement
			;

statement:		assign_var SEMICOLON 
   	  		| method_call SEMICOLON
   	  		| cond	
			| else_cond
   	  		| loop
       	  		| BREAK SEMICOLON
   	      		| RETURN exp SEMICOLON
			| paint SEMICOLON
			| print SEMICOLON
			| read SEMICOLON
			| window
			;

assign_var:		location assign_var1
			| PLUSPLUS location
			| LESSLESS location
			| location PLUSPLUS
			| location LESSLESS
			;

assign_var1: 		simple_assign
			| assing_op exp
			;

assing_op:		PLUSASSIGN 
			| MINUSASSIGN 
			| TIMESASSIGN 
			| DIVASSIGN 
			| MODASSIGN
			;

block:			LCURLYB statements RCURLYB	
			;

cond:			IF LPAR exp RPAR block
			;

else_cond:		cond ELSE block 
			;

loop:			for 
			| while
			;

for:			L_FOR LPAR type ID IN ID RPAR block
			;

while:			L_WHILE LPAR exp RPAR block
			;

paint:			PAINT location
			;

print:			PRINT exp print1
			;

print1: 		PLUS exp
			|
			;

read:			READ location
			;

window:			NEW WINDOW LCURLYB window_prop  block RCURLYB
			;

window_prop: 		THIS_WIDTH simple_assign COMMA
			THIS_HEIGHT simple_assign COMMA
			THIS_POSX simple_assign COMMA 
			THIS_POSY simple_assign COMMA 
			THIS_WINDOWICON simple_assign COMMA 
			THIS_WINDOWLABEL simple_assign COMMA
			;

main_method :  		DEFFUNC VOID M_MAIN LPAR RPAR method_block
			;

%%
