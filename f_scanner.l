%{

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "f_parser.tab.h"
	
%}
 
%option noyywrap nodefault yylineno case-insensitive

digit       [0-9]
id          [a-zA-Z][a-zA-Z0-9]*
exponent    [eE][+-]?{cst_int}
cst_int     {digit}+
cst_double  {cst_int}("."{cst_int})?{exponent}?
cst_string  \".*\"

%%


"bool"              { return TP_BOOL; }
"break"             { return BREAK; }
"Circle"            { return TO_CIRCLE; }
"const"             { return CONST; }
"deffunc"           { return DEFFUNC; }
"double"            { return TP_DOUBLE; }
"else"              { return ELSE; }
"false"             { return B_FALSE; }
"for"               { return L_FOR; }
"GLoop"             { return TO_GLOOP; }
"GStrip"            { return TO_GSTRIP; }
"if"                { return IF; }
"in"                { return IN; }
"int"               { return TP_INT; }
"Label"		    { return TO_LABEL; }
"Line"              { return TO_LINE; }
"main"              { return M_MAIN; }
"new"               { return NEW; }
"paint"             { return PAINT; }
"Point"             { return TO_POINT; }
"Polygon"           { return TO_POLYGON; }
"print"             { return PRINT; }
"Program"	    { return PROGRAM; }
"read"              { return READ; }
"return"            { return RETURN; }
"string"            { return TP_STRING; }
"true"              { return B_TRUE; }
"use"               { return USE; }
"void"              { return VOID; }
"while"             { return L_WHILE; }
"Window"            { return WINDOW; }


"this.bgc"          { return THIS_BGC; }
"this.color"        { return THIS_COLOR; }
"this.lineColor"    { return THIS_LINECOLOR; }
"this.lineWidth"    { return THIS_LINEWIDTH; }
"this.pointA"       { return THIS_POINTA; }
"this.pointB"       { return THIS_POINTB; }
"this.points"       { return THIS_POINTS; }
"this.posX"         { return THIS_POSX; }
"this.posY"         { return THIS_POSY; }
"this.radio"        { return THIS_RADIO; }
"this.size"         { return THIS_SIZE; }
"this.text"         { return THIS_TEXT; }
"this.type"         { return THIS_TYPE; }
"this.width"	    { return THIS_WIDTH; }
"this.height"       { return THIS_HEIGHT; }
"this.windowIcon"   { return THIS_WINDOWICON; }
"this.windowLabel"  { return THIS_WINDOWLABEL; }

{cst_int}           { return CST_INT; }
{cst_double}        { return CST_DOUBLE; }
{cst_string}        { return CST_STRING; }
{id}                { return ID; }


"{"		    { return LCURLYB; }
"}"		    { return RCURLYB; }
"="		    { return ASSIGN; }
"+="		    { return PLUSASSIGN; }
"-="		    { return MINUSASSIGN; }
"*="                { return TIMESASSIGN; }
"/="                { return DIVASSIGN; }
"%="                { return MODASSIGN;}
"||"		    { return OR; }
"&&"		    { return AND; }
"=="		    { return EQUAL; }
"!="		    { return UNEQUAL; }
"<"		    { return LESSTHAN; }
">"		    { return GREATERTHAN; }
"<="		    { return LESSEQUAL; }
">="		    { return GREATEREQUAL; }
"+"		    { return PLUS; }
"-"		    { return MINUS; }
"*"		    { return TIMES; }
"/"		    { return DIVISION; }
"%"		    { return MOD; }
"!"		    { return NOT; }
"++"		    { return PLUSPLUS; }
"--"		    { return LESSLESS; }
"("		    { return LPAR; }
")"		    { return RPAR; } 
","    		    { return COMMA;}
";"                 { return SEMICOLON; }
"["    		    { return LBRAC; }
"]"		    { return RBRAC; }
"."		    { return POINT; }


\n		    
\b
\t
.

%%

