%{

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
	
%}
 
%option noyywrap nodefault yylineno case-insensitive

digit       [0-9]
id          [a-zA-Z][a-zA-Z0-9]*
exponent    [eE][+-]?{cst_int}
cst_int     {digit}+
cst_double  {cst_int}("."{cst_int})?{exponent}?
cst_string  \"(\\.|[^\\"])*\"

%%

"/*"		    { handle_comment(); }

"bool"              { yylval.cst_string = strdup(yytext); return TP_BOOL; }
"break"             { return BREAK; }
"Circle"            { yylval.cst_string = strdup(yytext); return TO_CIRCLE; }
"const"             { return CONST; }
"deffunc"           { return DEFFUNC; }
"double"            { yylval.cst_string = strdup(yytext);  return TP_DOUBLE; }
"else"              { return ELSE; }
"false"             { yylval.cst_string = strdup(yytext); return B_FALSE; }
"for"               { return L_FOR; }
"GLoop"             { yylval.cst_string = strdup(yytext); return TO_GLOOP; }
"GStrip"            { yylval.cst_string = strdup(yytext); return TO_GSTRIP; }
"if"                { return IF; }
"in"                { return IN; }
"int"               { yylval.cst_string = strdup(yytext); return TP_INT; }
"Label"		    { yylval.cst_string = strdup(yytext); return TO_LABEL; }
"Line"              { yylval.cst_string = strdup(yytext); return TO_LINE; }
"main"              { yylval.cst_string = strdup(yytext); return M_MAIN; }
"new"               { return NEW; }
"paint"             { return PAINT; }
"Point"             { yylval.cst_string = strdup(yytext); return TO_POINT; }
"Polygon"           { yylval.cst_string = strdup(yytext); return TO_POLYGON; }
"print"             { return PRINT; }
"Program"	    { yylval.cst_string = strdup(yytext); return PROGRAM; }
"read"              { return READ; }
"return"            { return RETURN; }
"string"            { yylval.cst_string = strdup(yytext); return TP_STRING; }
"true"              { yylval.cst_string = strdup(yytext); return B_TRUE; }
"use"               { return USE; }
"void"              { yylval.cst_string = strdup(yytext); return VOID; }
"while"             { return L_WHILE; }
"Window"            { yylval.cst_string = strdup(yytext); return WINDOW; }

"this.bgc"          { yylval.cst_string = strdup(yytext); return THIS_BGC; }
"this.color"        { yylval.cst_string = strdup(yytext); return THIS_COLOR; }
"this.lineColor"    { yylval.cst_string = strdup(yytext); return THIS_LINECOLOR; }
"this.lineWidth"    { yylval.cst_string = strdup(yytext); return THIS_LINEWIDTH; }
"this.pointA"       { yylval.cst_string = strdup(yytext); return THIS_POINTA; }
"this.pointB"       { yylval.cst_string = strdup(yytext); return THIS_POINTB; }
"this.points"       { yylval.cst_string = strdup(yytext); return THIS_POINTS; }
"this.posX"         { yylval.cst_string = strdup(yytext); return THIS_POSX; }
"this.posY"         { yylval.cst_string = strdup(yytext); return THIS_POSY; }
"this.radio"        { yylval.cst_string = strdup(yytext); return THIS_RADIO; }
"this.size"         { yylval.cst_string = strdup(yytext); return THIS_SIZE; }
"this.text"         { yylval.cst_string = strdup(yytext); return THIS_TEXT; }
"this.type"         { yylval.cst_string = strdup(yytext); return THIS_TYPE; }
"this.width"	    { yylval.cst_string = strdup(yytext); return THIS_WIDTH; }
"this.height"       { yylval.cst_string = strdup(yytext); return THIS_HEIGHT; }
"this.windowIcon"   { yylval.cst_string = strdup(yytext); return THIS_WINDOWICON; }
"this.windowLabel"  { yylval.cst_string = strdup(yytext); return THIS_WINDOWLABEL; }

{cst_int}           { yylval.cst_int = atoi(yytext); return CST_INT; }
{cst_double}        { yylval.cst_double = atof(yytext); return CST_DOUBLE; }
{cst_string}        { yylval.cst_string = strdup(yytext); return CST_STRING; }
{id}                { yylval.cst_string = strdup(yytext); return ID; }

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

handle_comment() {
	char c, c1;

loop:
	while ((c = input()) != '*' && c != 0);
	if ((c1 = input()) != '/' && c != 0) {
		unput(c1);
		goto loop;
	}
}
