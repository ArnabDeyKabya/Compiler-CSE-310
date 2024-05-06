%option noyywrap

%x string_state
%x single_line_comment
%x multi_line_comment
%x char_state

%{
#include "2005112_symbolTable.h"
#include "2005112_symbolInfo.h"
#include "2005112_node.h"
#include "y.tab.h"
using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
extern FILE *logout;
void yyerror(char *);
int line_count=1;
int error_count=0;
int key_line;
string strtoken="";
string strlex="";
string token_name;
int line_start;
string chartok;

char *upper(char *str)
{
    for(int i=0;str[i]!='\0';i++)
    str[i]=toupper(str[i]);
    return str;
}

char special_char(char *str)
{
    if(str[0]=='\\')
    {
        if(str[1]=='a')
        return '\a';
        else if(str[1]=='b')
        return '\b';
        else if(str[1]=='f')
        return '\f';
        else if(str[1]=='n')
        return '\n';
        else if(str[1]=='r')
        return '\r';
        else if(str[1]=='t')
        return '\t';
        else if(str[1]=='v')
        return '\v';
        else if(str[1]=='\'')
        return '\'';
        else if(str[1]=='\"')
        return '\"';
        else if(str[1]=='0')
        return '\0';
        else if(str[1]=='\\')
        return '\\';
        else
        return str[0];
   }  
    else if(str[0]=='\'')
    {
        if(str[1]=='\\')
      {
        if(str[2]=='a')
        return '\a';
        else if(str[2]=='b')
        return '\b';
        else if(str[2]=='f')
        return '\f';
        else if(str[2]=='n')
        return '\n';
        else if(str[2]=='r')
        return '\r';
        else if(str[2]=='t')
        return '\t';
        else if(str[2]=='v')
        return '\v';
        else if(str[2]=='\'')
        return '\'';
        else if(str[2]=='\"')
        return '\"';
        else if(str[2]=='0')
        return '\0';
        else if(str[2]=='\\')
        return '\\';
        else
        return 'a';
      }
      else
      return str[1];  
    }
    else 
    return str[0];
}

void endFile(){
    
}

%}

whitespace [ \t\f\r\v]+ 
letter [a-zA-Z]
digit [0-9]
special_char [\\][abfnrtv0\'\"\\]
CHAR {special_char}|{digit}|{letter}
multichar \'{CHAR}{CHAR}+\'
unfinished_char \'{CHAR}*|\'\\\'
empty_char \'\'
keyword if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue|println
FLOAT {digit}+(\.{digit}+)?([Ee][-+]?{digit}+)?
id ({letter}|_)({letter}|{digit}|_)*
newline (\r)?[\n]

%%

{whitespace} {}

{newline} {line_count++;}


{keyword} {
            string ss=yytext;
            char *str=upper(yytext);
            SymbolInfo *s= new  SymbolInfo(ss,str,line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_count,str,ss.c_str());
            if(ss=="if") {return IF;}
else if(ss=="else") {return ELSE;}
else if(ss=="for") {return FOR;}
else if(ss=="while") {return WHILE;}
else if(ss=="int") {return INT;}
else if(ss=="float") {return FLOAT;}
else if(ss=="double") {return DOUBLE;}
else if(ss=="char") {return CHAR;}
else if(ss=="return") {return RETURN;}
else if(ss=="void") {return VOID;}
//else if(ss=="main")	{return MAIN;}
else if(ss=="println")	{return PRINTLN;}

		}

"+"|"-" {
           SymbolInfo *s= new  SymbolInfo(yytext,  "ADDOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			return ADDOP;
        }		

"*"|"/"|"%" {
			SymbolInfo *s= new  SymbolInfo(yytext,  "MULOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
			return MULOP;
		}

"++"  {
            SymbolInfo *s= new  SymbolInfo(yytext,  "INCOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
			return INCOP;
}

"--" {
            SymbolInfo *s= new  SymbolInfo(yytext,  "DECOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <DECOP> Lexeme %s found\n",line_count,yytext);
			return DECOP;
}

"<"|"<="|">"|">="|"=="|"!="  {
            SymbolInfo *s= new  SymbolInfo(yytext,  "RELOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
			return RELOP;
}

"="    {
           SymbolInfo *s= new  SymbolInfo(yytext,  "ASSIGNOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext); 
			return ASSIGNOP;
}	

"&&"|"||"  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "LOGICOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext); 
			return LOGICOP;
}

"&"|"|"|"^"|"<<"|">>"  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "BITOP",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext); 
			return BITOP;
}

"!"  {
          SymbolInfo *s= new  SymbolInfo(yytext,  "NOT",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
			return NOT;
}

"("  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "LPAREN",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
			return LPAREN; 
}
")"  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "RPAREN",line_count);
			yylval.symbol=s;
             fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
			return RPAREN;
}

"{"  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "LCURL",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
			return LCURL;
}

"}"  {
          SymbolInfo *s= new  SymbolInfo(yytext,  "RCURL",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
			return RCURL;
}

"["  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "LSQUARE",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
			return LSQUARE;
}

"]"  {
          SymbolInfo *s= new  SymbolInfo(yytext,  "RSQUARE",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
			return RSQUARE;
}

","  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "COMMA",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
			return COMMA;
}

";"  {
           SymbolInfo *s= new  SymbolInfo(yytext,  "SEMICOLON",line_count);
			yylval.symbol=s;
            fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			return SEMICOLON;
}

{unfinished_char} {
           error_count++;
           fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",line_count,yytext);
}		  

{multichar} {
           error_count++;
           fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n",line_count,yytext);
}

{empty_char} {
           error_count++;
           fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n",line_count,yytext);
}

[\']{CHAR}[\'] {
           char chartok=special_char(yytext);
		   fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",line_count,chartok);
}

"\""  {
           BEGIN string_state;
           strlex.append(yytext);
           token_name="SINGLE LINE STRING";
           line_start=line_count; 
}

<string_state>{special_char}  {
          strlex.append(yytext);
          char c=special_char(yytext);
          strtoken.append(1,c);
}

<string_state>[^\\\"]{newline}  {
          line_count++;
          error_count++;
          string s(1,special_char(yytext));
          strlex.append(s);
          fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_start,strlex.c_str());
          strtoken="";
          strlex="";
          BEGIN INITIAL;
}

<string_state>[\\]{newline}  {
          line_count++;
          strlex.append(yytext);
          token_name="MULTI LINE STRING";
}

<string_state>"\""  {
          strlex.append(yytext);
          fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_start,token_name.c_str(),strlex.c_str());
          BEGIN INITIAL;
          strtoken="";
          strlex="";
}

<string_state><<EOF>> {
          error_count++;
          fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_start,strlex.c_str());
          endFile();
          return 0;
}

<string_state>.  {
          strlex.append(yytext);
          strtoken.append(yytext);
}			  

"\/\/"  {
           BEGIN single_line_comment;
           line_start=line_count;
            
}   

<single_line_comment>{newline} {
           line_count++;
          // fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n",line_start,strlex.c_str());
           BEGIN INITIAL;
           strlex="";
} 

<single_line_comment>[\\]{newline} {
           line_count++;
           strlex.append(yytext);
}

<single_line_comment>. {
          strlex.append(yytext);
}

"\/\*" {
          BEGIN multi_line_comment;
          strlex.append(yytext);
          line_start=line_count;
}
<multi_line_comment>{newline} {
          line_count++;
          strlex.append(yytext);
}
<multi_line_comment>"\*\/" {
          strlex.append(yytext);
         // fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",line_start,strlex.c_str());
          BEGIN INITIAL;
          strlex="";
}

<multi_line_comment><<EOF>> {
          error_count++;
         // fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n",line_start,strlex.c_str()); 
          BEGIN INITIAL;
          strlex="";
          endFile();
          return 0;
}

<multi_line_comment>. {
          strlex.append(yytext);
}

{digit}+ 	{
            SymbolInfo *s= new  SymbolInfo(yytext,  "CONST_INT",line_count);
            fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
			yylval.symbol=s;
			return CONST_INT;
			}

{FLOAT}  {
           SymbolInfo *s= new  SymbolInfo(yytext,"CONST_FLOAT",line_count);
           fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
			yylval.symbol=s;
			return CONST_FLOAT;
}


{digit}+(\.{digit}+)?[Ee][-+]?{digit}+\.{digit}* {
         error_count++;
         fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);
}

{FLOAT}+[\.]({digit}|\.)+ {
         error_count++;
         fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",line_count,yytext);
}

{id}  {
               fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
				SymbolInfo *s= new SymbolInfo(yytext,"ID",line_count);
				yylval.symbol=s;		
				return ID;
}

{digit}+{id} {
    error_count++;
    fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",line_count,yytext);
}

. {
	error_count++;
	fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",line_count,yytext);
}

<<EOF>> {
	endFile();
    return 0;
}

%%

/*int yywrap(void)
{
	return 1;
}*/