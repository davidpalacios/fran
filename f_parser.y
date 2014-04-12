%{


#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "f_shared.h"


int yylineno;

F_Types current_type;
F_Modifiers current_modifier;

void yyerror(const char * s) {
	fprintf(stderr, "error: line %d: '%s' \n", yylineno, s);
}

void convert_type_to_array( F_Types type ) {

	switch ( type ) {
	
		case t_int: 
			current_type = t_array_int; 
			break;
		case t_double: 
			current_type = t_array_double; 
			break;
		case t_string: 
			current_type = t_array_string; 
			break;
		case t_boolean: 
			current_type = t_array_boolean; 
			break;
		case o_circle: 
			current_type = o_array_circle; 
			break;
		case o_gloop: 
			current_type = o_array_gloop; 
			break;
		case o_gstrip: 
			current_type = o_array_gstrip; 
			break;
		case o_line: 
			current_type = o_array_line; 
			break;
		case o_point: 
			current_type = o_array_point;
			break;
		case o_polygon:	
			current_type = o_array_polygon;
			break;
		case o_label: 
			current_type = o_array_label;
			break;
	}
}

void convert_array_to_type( F_Types type ) {

	switch ( type ) {
	
		case t_array_int: 
			current_type = t_int; 
			break;
		case t_array_double: 
			current_type = t_double; 
			break;
		case t_array_string: 
			current_type = t_string; 
			break;
		case t_array_boolean: 
			current_type = t_boolean; 
			break;
		case o_array_circle: 
			current_type = o_circle; 
			break;
		case o_array_gloop: 
			current_type = o_gloop; 
			break;
		case o_array_gstrip: 
			current_type = o_gstrip; 
			break;
		case o_array_line: 
			current_type = o_line; 
			break;
		case o_array_point: 
			current_type = o_point;
			break;
		case o_array_polygon:	
			current_type = o_polygon;
			break;
		case o_array_label: 
			current_type = o_label;
			break;
	}
}

int main() {
	init_semantics();
	yyparse();
	print_fran_final_status();
	free_memory();
	return (0);
}

%}

%start program

%union {
	float cst_double;
	int cst_int;
	char *cst_string;
}

%error-verbose

%token TP_BOOL BREAK TO_CIRCLE CONST DEFFUNC TP_DOUBLE ELSE B_FALSE L_FOR TO_GLOOP TO_GSTRIP IF IN
%token TP_INT TO_LABEL TO_LINE M_MAIN NEW PAINT TO_POINT TO_POLYGON PRINT PROGRAM READ RETURN TP_STRING
%token B_TRUE USE VOID L_WHILE WINDOW THIS_BGC THIS_COLOR THIS_LINECOLOR THIS_LINEWIDTH THIS_POINTA
%token THIS_POINTB THIS_POINTS THIS_POSX THIS_POSY THIS_RADIO THIS_SIZE THIS_TEXT THIS_TYPE THIS_WIDTH
%token THIS_HEIGHT THIS_WINDOWICON THIS_WINDOWLABEL CST_INT CST_DOUBLE CST_STRING ID LCURLYB RCURLYB ASSIGN
%token PLUSASSIGN MINUSASSIGN TIMESASSIGN DIVASSIGN MODASSIGN OR AND EQUAL UNEQUAL LESSTHAN GREATERTHAN LESSEQUAL
%token GREATEREQUAL PLUS MINUS TIMES DIVISION MOD NOT PLUSPLUS LESSLESS LPAR RPAR COMMA SEMICOLON LBRAC RBRAC POINT



%%

program: 		imports PROGRAM ID { add_program(yylval.cst_string); } LCURLYB header_var_decl method_decl main_method RCURLYB
	 		;

imports: 		imports USE ID SEMICOLON 
	 		|
	 		;

header_var_decl:	header_var_decl ref type decl_location { add_global_to_current_program(yylval.cst_string, current_modifier, current_type ); } simple_assign more_decl SEMICOLON
			|
			;

type: 			type_prim 
			| type_obj
			;

type_prim:		TP_DOUBLE   { current_type = t_double; } 
			| TP_INT    { current_type = t_int; }
			| TP_BOOL   { current_type = t_boolean; } 
			| TP_STRING { current_type = t_string; } 
			;

type_obj:		TO_CIRCLE   { current_type = o_circle; } 
			| TO_GLOOP  { current_type = o_gloop; } 
			| TO_GSTRIP { current_type = o_gstrip; } 
			| TO_LINE   { current_type = o_line; } 
			| TO_POINT  { current_type = o_point; } 
			| TO_POLYGON{ current_type = o_polygon; } 
			| TO_LABEL  { current_type = o_label; } 
			;
	  
decl_location:		ID dl 
			| LBRAC RBRAC ID { convert_type_to_array( current_type ); }
			;

dl:			LBRAC RBRAC { convert_type_to_array( current_type ); } 
			| { convert_array_to_type( current_type ); } 
			;

assign:			ASSIGN sa
			;
	
simple_assign:		assign 
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

more_decl:		more_decl COMMA ID dl { add_global_to_current_program(yylval.cst_string, current_modifier, current_type ); } simple_assign
 			|
 			;

method_decl:		method_decl DEFFUNC method_type ID { add_procedure_to_current_program( yylval.cst_string, current_type ); } LPAR method_par_decl RPAR method_block
			|
			;

method_type:		VOID { current_type = t_void; }
  	    		| type dl
  	    		;

method_par_decl:	ref type decl_location { add_param_to_current_procedure(yylval.cst_string, current_modifier, current_type ); } mpd
			|
			;

ref:			CONST { current_modifier = constant; } 
	            	|     { current_modifier = nonconstant; }
	            	;
		      	
mpd:			mpd COMMA method_par_decl
     			|
      			;

more_local_decl:	more_local_decl COMMA ID dl { add_local_to_current_procedure( yylval.cst_string, current_modifier, current_type ); } simple_assign
			|
			;

method_local_var: 	method_local_var ref type decl_location { add_local_to_current_procedure( yylval.cst_string, current_modifier, current_type ); } simple_assign more_local_decl SEMICOLON
			|
			;


method_block:		LCURLYB method_local_var statements RCURLYB
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

assign_var1: 		assign
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

main_method :  		DEFFUNC VOID { current_type = t_void; } M_MAIN { add_procedure_to_current_program( yylval.cst_string, current_type ); } LPAR RPAR method_block
			;

%%
