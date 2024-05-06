%option noyywrap
%x STRING_STATE
%x single_line_comment
%x multi_line_comment

%{
#include "2005112_symbol_table.cpp"
FILE *logout;
FILE *tokenout;
int line_count=1;
int error_count=0;
symbol_table table;
string str_token="";
string strlex="";
string token_name;
int line_start;
string char_tok;
char *upper(char *str) {
    char *ptr = str;
    while (*ptr != '\0') {
        *ptr = toupper(*ptr);
        ptr++;
    }
    return str;
}
void endFile(){
	string str;
	str=table.print_all_scope();
	fprintf(logout,"%s",str.c_str());
	fprintf(logout,"Total lines: %d\n",line_count);
	fprintf(logout,"Total errors: %d\n",error_count);
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

void print_error(string flag, char* s)
{
    if(flag=="UNFINISHED_CONST_CHAR")
    {
        fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",line_count,s);
    }
    else if(flag=="MULTICHAR_CONST_CHAR")
    {
        fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n",line_count,s);
    }
    else if(flag=="EMPTY_CONST_CHAR")
    {
        fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n",line_count,s);
    }
    else if(flag=="UNFINISHED_STRING")
    {
        fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_count,s);
    }
    else if(flag=="ILLFORMED_NUMBER")
    {
        fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,s);
    }
    else if(flag=="TOO_MANY_DECIMAL_POINTS")
    {
        fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",line_count,s);
    }
    else if(flag=="INVALID_ID_SUFFIX_NUM_PREFIX")
    {
        fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",line_count,s);
    }
    else if(flag=="UNRECOGNIZED_CHAR")
    {
        fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",line_count,s);
    }
    else if(flag=="UNFINISHED_COMMENT")
    {
        fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n",line_count,s);
    }
}

void tokenout_print(string flag, char* s)
{
    if(flag=="ADDOP")
    {
        fprintf(tokenout,"<ADDOP, %s>\n",s);
    }
    else if(flag=="MULOP")
    {
        fprintf(tokenout,"<MULOP, %s>\n",s);
    }
    else if(flag=="INCOP")
    {
        fprintf(tokenout,"<INCOP, %s>\n",s);
    }
    else if(flag=="RELOP")
    {
        fprintf(tokenout,"<RELOP, %s>\n",s);
    }
    else if(flag=="ASSIGNOP")
    {
        fprintf(tokenout,"<ASSIGNOP, %s>\n",s);
    }
    else if(flag=="LOGICOP")
    {
        fprintf(tokenout,"<LOGICOP, %s>\n",s);
    }
    else if(flag=="BITOP")
    {
        fprintf(tokenout,"<BITOP, %s>\n",s);
    }
    else if(flag=="NOT")
    {
        fprintf(tokenout,"<NOT, %s>\n",s);
    }
    else if(flag=="LPAREN")
    {
        fprintf(tokenout,"<LPAREN, %s>\n",s);
    }
    else if(flag=="RPAREN")
    {
        fprintf(tokenout,"<RPAREN, %s>\n",s);
    }
    else if(flag=="LCURL")
    {
        fprintf(tokenout,"<LCURL, %s>\n",s);
    }
    else if(flag=="RCURL")
    {
        fprintf(tokenout,"<RCURL, %s>\n",s);
    }
    else if(flag=="LSQUARE")
    {
        fprintf(tokenout,"<LSQUARE, %s>\n",s);
    }
    else if(flag=="RSQUARE")
    {
        fprintf(tokenout,"<RSQUARE, %s>\n",s);
    }
    else if(flag=="COMMA")
    {
        fprintf(tokenout,"<COMMA, %s>\n",s);
    }
    else if(flag=="SEMICOLON")
    {
        fprintf(tokenout,"<SEMICOLON, %s>\n",s);
    }
}


%}

WHITESPACES [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
special_char [\\][abfnrtv0\'\"\\]
CHAR {special_char}|{DIGIT}|{LETTER}
MULTICHAR \'{CHAR}{CHAR}+([^\'\\]|\\{CHAR})*\'
unfinished_char \'{CHAR}*|\'\\\'
empty_char \'\'
keyword if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue
FLOAT {DIGIT}+(\.{DIGIT}+)?([Ee][-+]?{DIGIT}+)?
id ({LETTER}|_)({LETTER}|{DIGIT}|_)*
newline (\r)?[\n]
CONST_INT {DIGIT}+
ILLFORMED_NUMBER {DIGIT}+(\.{DIGIT}+)?[Ee][-+]?({DIGIT}+)?\.{DIGIT}*
TOO_MANY_DECIMAL_POINTS {FLOAT}+[\.]({DIGIT}|\.)+([Ee][-+]?{DIGIT}+)?
%%
{WHITESPACES} {}

{newline} {line_count++;}
{keyword} {
            string s=yytext;
            char *str=upper(yytext);
			fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_count,str,s.c_str());
			fprintf(tokenout,"<%s, %s>\n",str,s.c_str());
}
"+"|"-" {
        tokenout_print("ADDOP",yytext);
		fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
}

"*"|"/"|"%" {
            tokenout_print("MULOP",yytext);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
		}

 "++"|"--"  {
            tokenout_print("INCOP",yytext);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
}

"<"|"<="|">"|">="|"=="|"!="  {
            tokenout_print("RELOP",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
}

"="    {
              tokenout_print("ASSIGNOP",yytext);
		   fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext); 
}	

"&&"|"||"  {
              tokenout_print("LOGICOP",yytext);
		   fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext); 
}

"&"|"|"|"^"|"<<"|">>"  {
                tokenout_print("BITOP",yytext);
		   fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext); 
}

"!"  {
                tokenout_print("NOT",yytext);
		   fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext); 
}

"("  {
                tokenout_print("LPAREN",yytext);
		   fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext); 
}
")"  {
                tokenout_print("RPAREN",yytext);
		   fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext); 
}

"{"  {
                tokenout_print("LCURL",yytext);
		   fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
           table.enter_scope();
}

"}"  {
                tokenout_print("RCURL",yytext);
		   fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
           table.exit_scope(); 
}

"["  {
                tokenout_print("LSQUARE",yytext);
		   fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext); 
}

"]"  {
                tokenout_print("RSQUARE",yytext);
		   fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext); 
}

","  {
                tokenout_print("COMMA",yytext);
		   fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext); 
}

";"  {
           tokenout_print("SEMICOLON",yytext);
		   fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext); 
}
{unfinished_char} {
           error_count++;
}		  print_error("UNFINISHED_CONST_CHAR",yytext);

{MULTICHAR} {
           error_count++;
            print_error("MULTICHAR_CONST_CHAR",yytext);
}

{empty_char} {
           error_count++;
            print_error("EMPTY_CONST_CHAR",yytext);
}
[\']{CHAR}[\'] {
           char chartok=special_char(yytext);
           fprintf(tokenout,"<CONST_CHAR, %c>\n",chartok);
		   fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",line_count,chartok);
}

"\""  {
           BEGIN STRING_STATE;
           strlex.append(yytext);
           token_name="SINGLE LINE STRING";
           line_start=line_count; 
}

<STRING_STATE>{special_char}  {
          strlex.append(yytext);
          char ch=special_char(yytext);
          str_token.append(1,ch);
}
<STRING_STATE>{newline} {
    error_count++;
    string s(1, special_char(yytext));
    strlex.append(s);
    char* st = new char[strlex.length() + 1];
    strcpy(st, strlex.c_str());
    print_error("UNFINISHED_STRING",st);
    line_count++;
    str_token = "";
    strlex = "";
    BEGIN INITIAL;
}
<STRING_STATE>[^\\\"]{newline}  {
          error_count++;
          string s(1,special_char(yytext));
          strlex.append(s);
        char* st = new char[strlex.length() + 1];
        strcpy(st, strlex.c_str());
        print_error("UNFINISHED_STRING",st);
        line_count++;
          str_token="";
          strlex="";
          BEGIN INITIAL;
}
<STRING_STATE>[\\]{newline}  {
          line_count++;
          strlex.append(yytext);
          token_name="MULTI LINE STRING";
}

<STRING_STATE>"\""  {
          strlex.append(yytext);
          fprintf(tokenout,"<%s, %s>\n",token_name.c_str(),str_token.c_str());
          fprintf(logout,"Line# %d: Token <%s> Lexeme %s found\n",line_start,token_name.c_str(),strlex.c_str());
          BEGIN INITIAL;
          str_token="";
          strlex="";
}

<STRING_STATE><<EOF>> {
          error_count++;
            char* st = new char[strlex.length() + 1];
            strcpy(st, strlex.c_str());
            print_error("UNFINISHED_STRING",st);
          endFile();
          return 0;
}

<STRING_STATE>.  {
          strlex.append(yytext);
          str_token.append(yytext);
}

"\/\/"  {
           BEGIN single_line_comment;
           line_start=line_count;
            
}  

<single_line_comment>{newline} {
           line_count++;
           fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme //%s found\n",line_start,strlex.c_str());
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
    fprintf(logout, "Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n", line_start, strlex.c_str());
    BEGIN INITIAL;
    strlex = "";
}

<multi_line_comment><<EOF>> {
    error_count++;
    fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT %s\n", line_count, strlex.c_str());
    BEGIN INITIAL;
    strlex = "";
    endFile();
    return 0;
}

<multi_line_comment>. {
    strlex.append(yytext);
}

{CONST_INT} 	{
				fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
			}

{FLOAT}  {
           fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
		   fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
}

{ILLFORMED_NUMBER} {
         error_count++;
         print_error("ILLFORMED_NUMBER",yytext);
}

{TOO_MANY_DECIMAL_POINTS} {
         error_count++;
         print_error("TOO_MANY_DECIMAL_POINTS",yytext);
}

{id}  {
         fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
         fprintf(tokenout,"<ID, %s>\n",yytext);
         if(table.Insert(yytext,"ID"))
         {
            string str=table.print_all_scope();
            fprintf(logout,"%s",str.c_str());
         }
         else
         {
            fprintf(logout,"\t%s already exists in the current ScopeTable\n",yytext);
         }
}

{DIGIT}+{id} {
    error_count++;
        print_error("INVALID_ID_SUFFIX_NUM_PREFIX",yytext);
}

. {
	error_count++;
    print_error("UNRECOGNIZED_CHAR",yytext);
}

<<EOF>> {
	endFile();
    return 0;
}





%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");
	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}