%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include "2005112_symbolTable.h"
#include "2005112_symbolInfo.h"
#include "2005112_node.h"
#include "2005112_functionInfo.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern int error_count;
extern int key_line;

FILE *fp,*logout,*errorout,*parsetree;
vector<SymbolInfo *>var_list;
vector<VarInfo *>parameterList;
vector<string>arg_list;
string return_type;
SymbolTable *table;
Node *root;

void checkParameter(FunctionInfo *func)
{
	int len=parameterList.size();
	vector<VarInfo *>a=func->parameterList;
	for(int i=0;i<len;i++)
	{
		if(a[i]->getDataType()!=parameterList[i]->getDataType())
		{
			fprintf(errorout,"Line# %d: Type mismatch for argument %d of '%s'\n",a[i]->getLine(),i+1,func->getName().c_str());
		}
	}
}

void yyerror(char *s)
{
	
	//write your code
}


%}

%union{
	SymbolInfo *symbol;
	Node *node;
}

%token <symbol> IF FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTLN 
%token <symbol> ID ADDOP MULOP INCOP DECOP ASSIGNOP LOGICOP RELOP BITOP NOT COMMA SEMICOLON LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE CONST_INT CONST_FLOAT

%type <node> start declaration_list type_specifier var_declaration unit program func_declaration func_definition parameter_list factor variable expression logic_expression argument_list arguments rel_expression simple_expression term unary_expression statement statements compound_statement expression_statement new_scope
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%
start : program
	{
		 $$=new Node("start : program",$1->getType(),$1->getLine(),$1->getEnd());
          $$->add($1);
		
		root=$$;
        fprintf(logout,"start : program\n");
	}
	;

program : program unit
{
	  $$=new Node("program : program unit",$1->getType(),$1->getLine(),$2->getEnd());
	  $$->add($1);
	  $$->add($2);	
   fprintf(logout,"program : program unit\n");
}
	| unit
	{
		 $$=new Node("program : unit",$1->getType(),$1->getLine(),$1->getEnd());
		  $$->add($1);
		
        fprintf(logout,"program : unit\n");
	}
	;
	
unit : var_declaration
{
   $$=new Node("unit : var_declaration",$1->getType(),$1->getLine(),$1->getEnd());
   $$->add($1);
   fprintf(logout,"unit : var_declaration\n");
}
     | func_declaration
	 {
		$$=new Node("unit : func_declaration",$1->getType(),$1->getLine(),$1->getEnd());
		$$->add($1);
		fprintf(logout,"unit : func_declaration\n");
	 }
     | func_definition
	 {
		$$=new Node("unit : func_definition",$1->getType(),$1->getLine(),$1->getEnd());
		$$->add($1);
		fprintf(logout,"unit : func_definition\n");
	 }
     ;  
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
{
	        $$=new Node("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",$1->getType(),$1->getLine(),$6->getLine());
			SymbolInfo *temp=table->lookUp($2->getName());
			if(temp==NULL)
			{
				FunctionInfo *func=new FunctionInfo($2->getName(),"FUNCTION",$2->getLine(),$1->getType());
				for(int i=0;i<parameterList.size();i++)
				{
					for(int j=0;j<i;j++)
					{
						if(parameterList[i]->getName()==parameterList[j]->getName())
						{
							fprintf(errorout,"Line# %d: Redefinition of parameter '%s'\n",parameterList[i]->getLine(),parameterList[i]->getName().c_str());
							error_count++;
						}
					}
					VarInfo *v=new VarInfo(parameterList[i]->getName(),parameterList[i]->getType(),parameterList[i]->getLine(),parameterList[i]->getDataType());
					func->addParameter(v);
				}				
				table->insert(func);
			}
			else
			{
				fprintf(errorout,"Line# %d: Redeclaration of function '%s'\n",temp->getLine(),temp->getName().c_str());
				error_count++;
			}
			parameterList.clear();
			$$->add($1);
			$$->add(new Node($2));
			$$->add(new Node($3));
			$$->add($4);
			$$->add(new Node($5));
			$$->add(new Node($6));
			fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");
}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			$$=new Node("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",$1->getType(),$1->getLine(),$5->getLine());
			SymbolInfo *temp=table->lookUp($2->getName());
			if(temp==NULL)
			{
				FunctionInfo *func=new FunctionInfo($2->getName(),"FUNCTION",$2->getLine(),$1->getType());
				table->insert(func);
			}
			else
			{
				fprintf(errorout,"Line# %d: Redeclaration of function '%s'\n",temp->getLine(),temp->getName().c_str());
				error_count++;
			}
			$$->add($1);
			$$->add(new Node($2));
			$$->add(new Node($3));
			$$->add(new Node($4));
			$$->add(new Node($5));
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN
{
	SymbolInfo *temp=table->lookUp($2->getName());
			if(temp==NULL)
			{
				FunctionInfo *func=new FunctionInfo($2->getName(),"FUNCTION",$2->getLine(),$1->getType());
				for(int i=0;i<parameterList.size();i++)
				{
					for(int j=0;j<i;j++)
					{
						if(parameterList[i]->getName()==parameterList[j]->getName())
						{
							fprintf(errorout,"Line# %d: Redefinition of parameter '%s'\n",parameterList[i]->getLine(),parameterList[i]->getName().c_str());
							error_count++;
						}
					}
					VarInfo *v=new VarInfo(parameterList[i]->getName(),parameterList[i]->getType(),parameterList[i]->getLine(),parameterList[i]->getDataType());
					func->addParameter(v);
				}
					table->insert(func);			
			}
			else
			{
				if(temp->getType()=="FUNCTION")
				{
				FunctionInfo *func=(FunctionInfo *)temp;
				if(!func->isDefined())
				{
					if(func->getReturnType()!=$1->getType())
					{
						fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",$2->getLine(),func->getName().c_str());
						error_count++;
					}
					if(func->parameterList.size()==parameterList.size())
					{
						checkParameter(func);
					}
					else
					{
						fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",$2->getLine(),func->getName().c_str());
						error_count++;
					}
					
					func->setDefined(true);
				}
				else
				{
					fprintf(errorout,"Line# %d: Redefinition of function '%s'\n",func->getLine(),func->getName().c_str());
					error_count++;
				}
			}
			else{
				fprintf(errorout,"Line# %d: '%s' redeclared as different kind of symbol\n",$2->getLine(),$2->getName().c_str());
				error_count++;
			}
			}
			return_type=$1->getType();
		
} compound_statement
{
	$$=new Node("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",$1->getType(),$1->getLine(),$7->getEnd());
	$$->add($1);
			$$->add(new Node($2));
			$$->add(new Node($3));
			$$->add($4);
			$$->add(new Node($5));
			$$->add($7);
			fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
}

		| type_specifier ID LPAREN RPAREN
		{
	        SymbolInfo *temp=table->lookUp($2->getName());
			if(temp==NULL)
			{
				FunctionInfo *func=new FunctionInfo($2->getName(),"FUNCTION",$2->getLine(),$1->getType());
				table->insert(func);
			}
			else
			{
				 FunctionInfo *func=(FunctionInfo *)temp;
				if(!func->isDefined())
				{
					if(func->getReturnType()!=$1->getType())
					{
						fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",func->getLine(),func->getName().c_str());
						error_count++;
					}
					func->setDefined(true);
				}
				else
				{
					fprintf(errorout,"Line# %d: Redefinition of function '%s'\n",func->getLine(),func->getName().c_str());
					error_count++;
				} 
			} 
			return_type=$1->getType();
			
		} compound_statement
		{
			$$=new Node("func_definition : type_specifier ID LPAREN RPAREN compound_statement",$1->getType(),$1->getLine(),$6->getEnd());
			$$->add($1);
			$$->add(new Node($2));
			$$->add(new Node($3));
			$$->add(new Node($4));
			$$->add($6);
			fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
		}
		| type_specifier ID LPAREN parameter_list error RPAREN compound_statement
		{
			$$=new Node("parameter_list : error",$2->getType(),$2->getLine(),$7->getEnd());
			$$->add($1);
			$$->add(new Node($2));
			$$->add(new Node($3));
			$$->add(new Node("parameter_list : error",$2->getType(),$2->getLine(),$2->getLine()));
			$$->add(new Node($6));
			$$->add($7);
			fprintf(errorout,"Line# %d: Syntax error at parameter list of function definition\n",$1->getLine());
			error_count++;
		}
 		;				
parameter_list  : parameter_list COMMA type_specifier ID
{
	        $$=new Node("parameter_list : parameter_list COMMA type_specifier ID",$1->getType(),$1->getLine(),$4->getLine());
			$$->add($1);
			$$->add(new Node($2));
			$$->add($3);

			VarInfo *v=new VarInfo($4->getName(),$4->getType(),$4->getLine(),$3->getType());
			parameterList.push_back(v);
			$$->add(new Node($4));
			fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier ID\n");
}
		| parameter_list COMMA type_specifier
		{
			$$=new Node("parameter_list : parameter_list COMMA type_specifier",$1->getType(),$1->getLine(),$3->getEnd());
			$$->add($1);
			$$->add(new Node($2));
			$$->add($3);
			fprintf(logout,"parameter_list : parameter_list COMMA type_specifier\n");
		}
 		| type_specifier ID
		{
			$$=new Node("parameter_list : type_specifier ID",$1->getType(),$1->getLine(),$2->getLine());
			$$->add($1);
			VarInfo *v=new VarInfo($2->getName(),$2->getType(),$2->getLine(),$1->getType());
			parameterList.push_back(v);
			$$->add(new Node($2));
			fprintf(logout,"parameter_list  : type_specifier ID\n");
		}
		| type_specifier
		{
			$$=new Node("parameter_list : type_specifier",$1->getType(),$1->getLine(),$1->getEnd());
			$$->add($1);
			fprintf(logout,"parameter_list : type_specifier\n");
		}
		
 		;

 		
compound_statement : new_scope statements RCURL
{
	$$=new Node("compound_statement : LCURL statements RCURL",$2->getType(),$1->getLine(),$3->getLine());
			$$->add($1);
			$$->add($2);
			$$->add(new Node($3));
			//parameterList.clear();
		   fprintf(logout,"compound_statement : LCURL statements RCURL\n");
		   string str=table->printAllScope();
			fprintf(logout,"%s\n",str.c_str());
			table->exitScope();
}
 		    | new_scope RCURL
			{
				$$=new Node("compound_statement : LCURL RCURL",$1->getType(),$1->getLine(),$2->getLine());
			$$->add($1);
			$$->add(new Node($2));

			//parameterList.clear();
		   fprintf(logout,"compound_statement : LCURL RCURL\n");

		   string str=table->printAllScope();
			fprintf(logout,"%s\n",str.c_str());
			table->exitScope();
			}
 		    ;
new_scope : LCURL
{
	$$=new Node($1);
	table->enterScope();
	if(!parameterList.empty())
	{
		for(VarInfo *v:parameterList)
		{
			table->insert(v);
		}
		parameterList.clear();
	}
}
;
var_declaration : type_specifier declaration_list SEMICOLON
{
	 $$=new Node("var_declaration : type_specifier declaration_list SEMICOLON",$1->getType(),$1->getLine(),$3->getLine());
	 string type=$1->getType();
	if($1->getType()=="VOID")
	{
		string str="";
		for(SymbolInfo *v:var_list){
			if (str.size() != 0) str += ", ";
			str+=v->getName();
		}
		fprintf(errorout,"Line# %d: Variable or field \'%s\' declared void\n",$2->getLine(),str.c_str());
		error_count++;
	}
	else
	{
	   for(SymbolInfo *s:var_list)
	   {
		 SymbolInfo *temp=table->lookUpCurrent(s->getName());
		 if(temp==NULL)
		 {
			VarInfo *v=new VarInfo(s->getName(),s->getType(),s->getLine(),$1->getType());
			table->insert(v);
			delete s;
		 }
		 else
		 {
			VarInfo *v=(VarInfo *)temp;
			if(v->getDataType()!=$1->getType())
			{
				fprintf(errorout,"Line# %d: Conflicting types for '%s'\n",s->getLine(),s->getName().c_str());
				error_count++;
			}
		 }
	   }
	}
	var_list.clear();
	$$->add($1);
	$$->add($2);
	$$->add(new Node($3));
	fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON\n");
}
     | type_specifier declaration_list error SEMICOLON
{
	$$=new Node("var_declaration : type_specifier declaration_list SEMICOLON",$1->getType(),$1->getLine(),$4->getLine());
	$$->add($1);
	$$->add(new Node("declaration_list : error",$2->getType(),$1->getLine(),$1->getLine()));
	$$->add(new Node($4));
	fprintf(errorout,"Line# %d: Syntax error at declaration list of variable declaration\n",$1->getLine());
	fprintf(logout,"Error at line no %d : syntax error\n",$1->getLine());
	error_count++;
}
 		 ;
 		 
type_specifier	: INT
{
	$$=new Node("type_specifier : INT","INT",$1->getLine(),$1->getLine());
	$$->add(new Node($1));
	fprintf(logout,"type_specifier	: INT\n");
}
 		| FLOAT
		{
			$$=new Node("type_specifier : FLOAT","FLOAT",$1->getLine(),$1->getLine());
			$$->add(new Node($1));
		   fprintf(logout,"type_specifier	: FLOAT\n");
		}
 		| VOID
		{
           $$=new Node("type_specifier : VOID",$1->getType(),$1->getLine(),$1->getLine());
		   $$->add(new Node($1));
		   fprintf(logout,"type_specifier	: VOID\n");
		}
 		;
 		
declaration_list : declaration_list COMMA ID
{
	         $$=new Node("declaration_list : declaration_list COMMA ID",$1->getType(),$1->getLine(),$3->getLine());
			  $$->add($1);
		      $$->add(new Node($2));

			var_list.push_back($3);
			 $$->add(new Node($3));
			fprintf(logout,"declaration_list : declaration_list COMMA ID\n");
}
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
		  {
			 $$=new Node("declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE","INT",$1->getLine(),$6->getLine());
			  $$->add($1);
		      $$->add(new Node($2));
			  $3->setType("ARRAY");
			  var_list.push_back($3);
			  $$->add(new Node($3));
			  $$->add(new Node($4));
			  $$->add(new Node($5));
			  $$->add(new Node($6));
			
			fprintf(logout,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE","\n");
		  }
 		  | ID
		  {
			$$=new Node("declaration_list : ID",$1->getType(),$1->getLine(),$1->getLine());	
			var_list.push_back($1);
			$$->add(new Node($1));
			fprintf(logout,"declaration_list : ID\n");
		  }
 		  | ID LSQUARE CONST_INT RSQUARE
		  {
			$$=new Node("declaration_list : ID LSQUARE CONST_INT RSQUARE",$1->getType(),$1->getLine(),$4->getLine());
			$1->setType("ARRAY");
		   var_list.push_back($1);
		   $$->add(new Node($1));
		   $$->add(new Node($2));
		   $$->add(new Node($3));
		   $$->add(new Node($4));
		   fprintf(logout,"declaration_list : ID LSQUARE CONST_INT RSQUARE\n");
		  }
 		  ;
 		  
statements : statement
{
	$$=new Node("statements : statement",$1->getType(),$1->getLine(),$1->getEnd());
		$$->add($1);
		fprintf(logout,"statements : statement\n");
}
	   | statements statement
	   {
		$$=new Node("statements : statements statement",$1->getType(),$1->getLine(),$2->getEnd());
		$$->add($1);
		$$->add($2);
		fprintf(logout,"statements : statements statement\n");
	   }
	   ;
	   
statement : var_declaration
{
	$$=new Node("statement : var_declaration",$1->getType(),$1->getLine(),$1->getEnd());
		$$->add($1);
		fprintf(logout,"statement : var_declaration\n");
}
	  | expression_statement
	  {
		$$=new Node("statement : expression_statement",$1->getType(),$1->getLine(),$1->getEnd());
		$$->add($1);
		fprintf(logout,"statement : expression_statement\n");
	  }
	  
	  | compound_statement
	  {
		$$=new Node("statement : compound_statement",$1->getType(),$1->getLine(),$1->getEnd());
		$$->add($1);
		fprintf(logout,"statement : compound_statement\n");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
		$$=new Node("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",$3->getType(),$1->getLine(),$7->getEnd());
		$$->add(new Node($1));
		$$->add(new Node($2));
		$$->add($3);
		$$->add($4);
		$$->add($5);
		$$->add(new Node($6));
		$$->add($7);
		fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
		$$=new Node("statement : IF LPAREN expression RPAREN statement",$3->getType(),$1->getLine(),$5->getEnd());
		$$->add(new Node($1));
		$$->add(new Node($2));
		$$->add($3);
		$$->add(new Node($4));
		$$->add($5);
		fprintf(logout,"statement : IF LPAREN expression RPAREN statement\n");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
		$$=new Node("statement : IF LPAREN expression RPAREN statement ELSE statement",$3->getType(),$1->getLine(),$7->getEnd());
		$$->add(new Node($1));
		$$->add(new Node($2));
		$$->add($3);
		$$->add(new Node($4));
		$$->add($5);
		$$->add(new Node($6));
		$$->add($7);
		fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement\n");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
		$$=new Node("statement : WHILE LPAREN expression RPAREN statement",$3->getType(),$1->getLine(),$5->getEnd());
		$$->add(new Node($1));
		$$->add(new Node($2));
		$$->add($3);
		$$->add(new Node($4));
		$$->add($5);
		fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement\n");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		$$=new Node("statement : PRINTLN LPAREN ID RPAREN SEMICOLON",$3->getType(),$1->getLine(),$5->getLine());
		$$->add(new Node($1));
		$$->add(new Node($2));
		$$->add(new Node($3));
		$$->add(new Node($4));
		$$->add(new Node($5));
		fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
	  }
	  | RETURN expression SEMICOLON
	  {
		if($2->getType()!=return_type)
		{
			fprintf(errorout,"Line# %d: Return type mismatch\n",$1->getLine());
			error_count++;
		}
		$$=new Node("statement : RETURN expression SEMICOLON",$2->getType(),$2->getLine(),$1->getLine());
		$$->add(new Node($1));
		$$->add($2);
		$$->add(new Node($3));
		fprintf(logout,"statement : RETURN expression SEMICOLON\n");
	  }
	  ;
	  
expression_statement 	: SEMICOLON
{
	$$=new Node("expression_statement : SEMICOLON",$1->getType(),$1->getLine(),$1->getLine());
	$$->add(new Node($1));
	fprintf(logout,"expression_statement : SEMICOLON\n");
}		
			| expression SEMICOLON
			{
				$$=new Node("expression_statement : expression SEMICOLON",$1->getType(),$1->getLine(),$1->getLine());
		        $$->add($1);
				$$->add(new Node($2));
	            fprintf(logout,"expression_statement : expression SEMICOLON\n");
			}
			 | expression error
			{
				$$=new Node("expression : error",$1->getType(),$1->getLine(),$1->getLine());
				$$->add($1);
	  		} 
			;
	  
variable : ID
{
	SymbolInfo *temp= table->lookUp($1->getName());
	string str=$1->getType();
	if(temp==NULL)
	{
		 fprintf(errorout,"Line# %d: Undeclared variable '%s'\n",$1->getLine(),$1->getName().c_str());
		 error_count++;
	}
	else
	{
		if(temp->getType()=="ID"||temp->getType()=="ARRAY")
		{
			VarInfo *v=(VarInfo *)temp;
			str=v->getDataType();
		}
		else
		{
			fprintf(errorout,"Line# %d: '%s' is a function\n",$1->getLine(),$1->getName().c_str());
		}
	}
	$$=new Node("variable : ID",str,$1->getLine(),$1->getLine());
	$$->add(new Node($1));
	fprintf(logout,"variable : ID\n");
}
	 | ID LSQUARE expression RSQUARE
	 {
		SymbolInfo *temp= table->lookUp($1->getName());
	string str=$1->getType();
	if(temp==NULL)
	{
		 fprintf(errorout,"Line# %d: Undeclared variable '%s'\n",$1->getLine(),$1->getName().c_str());
		 error_count++;
	}
	else
	{
		if(temp->getType()=="ARRAY")
		{
			VarInfo *v=(VarInfo *)temp;
			str=v->getDataType();
			if($3->getType()!="INT")
			{
				fprintf(errorout,"Line# %d: Array subscript is not an integer\n",$1->getLine(),$1->getName().c_str());
				error_count++;
			}
		}
		else {
			fprintf(errorout,"Line# %d: '%s' is not an array\n",$1->getLine(),$1->getName().c_str());
			error_count++;
		}
		
	}
		    fprintf(logout,"variable : ID LSQUARE expression RSQUARE\n");
		    $$=new Node("variable : ID LSQUARE expression RSQUARE",str,$1->getLine(),$4->getLine());
			$$->add(new Node($1));
			$$->add(new Node($2));
			$$->add($3);
			$$->add(new Node($4));
	 }
	 | ID LSQUARE RSQUARE
	 {
		fprintf(errorout,"Line# %d: there is no index with array %s\n",$1->getLine(),$1->getName().c_str());
		 $$=new Node("variable : ID LSQUARE RSQUARE",$1->getType(),$1->getLine(),$3->getLine());
			$$->add(new Node($1));
			$$->add(new Node($2));
			$$->add(new Node($3));
	 }
	;
 
 expression : logic_expression
 {
	$$=new Node("expression : logic_expression",$1->getType(),$1->getLine(),$1->getEnd());
	$$->add($1);
	fprintf(logout,"expression  : logic_expression\n");
 }
	   | variable ASSIGNOP logic_expression
	   {
		    fprintf(logout,"expression : variable ASSIGNOP logic_expression\n");
			if($3->getType()=="VOID")
			{
				fprintf(errorout,"Line# %d: Void cannot be used in expression\n",$3->getLine());
				error_count++;
			}
		    if($1->getType()!=$3->getType())
			{

				if($1->getType()=="INT" && $3->getType()=="FLOAT")
				{
					fprintf(errorout,"Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n",$3->getLine());
					error_count++;
				}
			}
			$$=new Node("expression : variable ASSIGNOP logic_expression",$1->getType(),$1->getLine(),$3->getEnd());
			  $$->add($1);
		      $$->add(new Node($2));
			  $$->add($3);
	   }
	    | variable ASSIGNOP error
	   {
		fprintf(errorout,"Line# %d: Syntax error at expression of expression statement\n",$2->getLine());
		$$=new Node("expression : error",$1->getType(),$1->getLine(),$1->getEnd());
		$$->add($1);
	   } 
	   ;
			
logic_expression : rel_expression
{
	$$=new Node("logic_expression : rel_expression",$1->getType(),$1->getLine(),$1->getEnd());
	$$->add($1);
	fprintf(logout,"logic_expression : rel_expression\n");
}
		 | rel_expression LOGICOP rel_expression
		 {
			 $$=new Node("logic_expression : rel_expression LOGICOP rel_expression","INT",$1->getLine(),$3->getEnd());
			  $$->add($1);
		      $$->add(new Node($2));
			  $$->add($3);
			
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression\n");
		 }	
		 ;
			
rel_expression	: simple_expression
{
   $$=new Node("rel_expression : simple_expression",$1->getType(),$1->getLine(),$1->getEnd());
   $$->add($1);
	fprintf(logout,"rel_expression	: simple_expression\n");
}
		| simple_expression RELOP simple_expression
		{
			 $$=new Node("rel_expression : simple_expression RELOP simple_expression","INT",$1->getLine(),$3->getEnd());
			  $$->add($1);
		      $$->add(new Node($2));
			  $$->add($3);
			
			fprintf(logout,"rel_expression : simple_expression RELOP simple_expression\n");
		}
		;
				
simple_expression : term
{
   $$=new Node("simple_expression : term",$1->getType(),$1->getLine(),$1->getEnd());
   $$->add($1);
	fprintf(logout,"simple_expression : term\n");
}
		  | simple_expression ADDOP term
		  {
       string s;
	    if($1->getType()=="VOID"||$3->getType()=="VOID")
		{
			s="VOID";
			//fprintf(errorout,"Line# %d: Void cannot be used in expression\n",$3->getLine());
		}
		else if($1->getType()=="FLOAT"||$3->getType()=="FLOAT")
		   s="FLOAT";
		else
		   s="INT";
		 $$=new Node("simple_expression : simple_expression ADDOP term",s,$1->getLine(),$3->getEnd());
		  $$->add($1);
		  $$->add(new Node($2));
		  $$->add($3);
		
        fprintf(logout,"simple_expression : simple_expression ADDOP term\n");
		  }
		  ;
					
term :	unary_expression
{
	$$=new Node("term : unary_expression",$1->getType(),$1->getLine(),$1->getEnd());
	$$->add($1);
	fprintf(logout,"term :	unary_expression\n");
}
     |  term MULOP unary_expression
	 {
		string s;
		if($2->getName()=="%")
		{
			if($3->zero)
			{
				fprintf(errorout,"Line# %d: Warning: division by zero i=0f=1Const=0\n",$3->getLine());
				error_count++;
			}
			else if($1->getType()!="INT"||$3->getType()!="INT")
			{
				fprintf(errorout,"Line# %d: Operands of modulus must be integers\n",$3->getLine());
				error_count++;
			}
		}
		else if($2->getName()=="/")
		{
			if($3->zero)
			{
				fprintf(errorout,"Line# %d: Warning: division by zero i=0f=1Const=0\n",$3->getLine());
				error_count++;
			}
		}
		else if($1->getType()=="VOID"||$3->getType()=="VOID")
		{
			s="VOID";
			//fprintf(errorout,"Line# %d: Void cannot be used in expression\n",$3->getLine());
		}
		else if($1->getType()=="FLOAT"||$3->getType()=="FLOAT")
		   s="FLOAT";
		else
		   s="INT";
		 $$=new Node("term : term MULOP unary_expression",s,$1->getLine(),$3->getEnd());
		  $$->add($1);
		  $$->add(new Node($2));
		  $$->add($3);
		
		fprintf(logout,"term : term MULOP unary_expression\n");
	 }
	  /* | error unary_expression
	 {
		fprintf(errorout,"Line# %d: Syntax error at expression of expression statement\n",$2->getLine());
		$$=new Node("term : error unary_expression",$2->getType(),$2->getLine(),$2->getLine());
		$$->add($2);
	 }  */
     ;

unary_expression : ADDOP unary_expression
{
		if($2->getType()=="VOID")
		{
			fprintf(errorout,"Line# %d: Void cannot be used in expression\n",$2->getLine());
			error_count++;
		}
	 $$=new Node("unary_expression : ADDOP unary_expression",$2->getType(),$1->getLine(),$2->getEnd());
		      $$->add(new Node($1));
			  $$->add($2);
			
			fprintf(logout,"unary_expression : ADDOP unary_expression\n");
}
		 | NOT unary_expression
		 {
			if($2->getType()=="VOID")
		{
			//fprintf(errorout,"Line# %d: Void cannot be used in expression\n",$2->getLine());
		}
			 $$=new Node("unary_expression : NOT unary_expression",$2->getType(),$1->getLine(),$2->getEnd());
		      $$->add(new Node($1));
			  $$->add($2);
			
			fprintf(logout,"unary_expression : NOT unary_expression\n");
		 }
		 | factor
		 {
			$$=new Node("unary_expression : factor",$1->getType(),$1->getLine(),$1->getEnd());
			$$->zero=$1->zero;
			$$->add($1);
			fprintf(logout,"unary_expression : factor\n");
		 }
		  
		 ;
	
factor	: variable
         {
           $$=new Node("factor : variable",$1->type,$1->getLine(),$1->getEnd());
		   $$->add($1);
		   fprintf(logout,"factor	: variable\n");
         }
	| ID LPAREN argument_list RPAREN
	{
		 SymbolInfo *temp=table->lookUp($1->getName());
		 string str=$1->getType();
		 if(temp==NULL)
		 {
			fprintf(errorout,"Line# %d: Undeclared function '%s'\n",$1->getLine(),$1->getName().c_str());
			error_count++;
		 }
		 else{
			if(temp->getType()=="FUNCTION")
			{
			FunctionInfo *func=(FunctionInfo *)temp;
			vector<VarInfo *>list=func->parameterList;
			if(arg_list.size()==list.size())
			{
				for(int i=0;i<arg_list.size();i++)
				{
					if(arg_list[i]!=func->parameterList[i]->getDataType())
					{
						fprintf(errorout,"Line# %d: Type mismatch for argument %d of '%s'\n",$1->getLine(),i+1,$1->getName().c_str());
					}
				}
			}
			else if(arg_list.size()>func->parameterList.size())
			{
				fprintf(errorout,"Line# %d: Too many arguments to function '%s'\n",$1->getLine(),$1->getName().c_str());
			}
			else{
				fprintf(errorout,"Line# %d: Too few arguments to function '%s'\n",$1->getLine(),$1->getName().c_str());
			}
			str=func->getReturnType();
			}
			else
			{
				fprintf(errorout,"Line# %d: '%s' is not a function\n",$1->getLine(),$1->getName().c_str());
			}
		 }
		 arg_list.clear();
		 $$=new Node("factor : ID LPAREN argument_list RPAREN",str,$1->getLine(),$4->getLine());
		  $$->add(new Node($1));
		  $$->add(new Node($2));
		  $$->add($3);
		  $$->add(new Node($4));
		
		fprintf(logout,"factor : LPAREN expression RPAREN\n");
	}
	| LPAREN expression RPAREN
	{
		 $$=new Node("factor : LPAREN expression RPAREN",$2->getType(),$1->getLine(),$3->getLine());
		  $$->add(new Node($1));
		  $$->add($2);
		  $$->add(new Node($3));
		
		fprintf(logout,"factor : LPAREN expression RPAREN\n");
	}
	| CONST_INT
	{
		 $$=new Node("factor : CONST_INT","INT",$1->getLine(),$1->getLine());
		 if($1->getName()=="0")
		 $$->zero=1;
		  $$->add(new Node($1));
		
		fprintf(logout,"factor	: CONST_INT\n");
	}
	| CONST_FLOAT
	{
		 $$=new Node("factor : CONST_FLOAT","FLOAT",$1->getLine(),$1->getLine());
		 if($1->getName()=="0.0")
		 $$->zero=1;
		  $$->add(new Node($1));
		
		fprintf(logout,"factor	: CONST_FLOAT\n");
	}
	| variable INCOP
	{
         $$=new Node("factor : variable INCOP",$1->getType(),$1->getLine(),$2->getLine());
		 $$->add($1);
		 $$->add(new Node($2));
		
		fprintf(logout,"factor : variable INCOP\n");
	}
	| variable DECOP
	{
		
         $$=new Node("factor : variable DECOP",$1->getType(),$1->getLine(),$2->getLine());
		 $$->add($1);
		 $$->add(new Node($2));
		
		fprintf(logout,"factor : variable DECOP\n");
	}
	;
	
argument_list : arguments
               {
                   $$=new Node("argument_list : arguments",$1->getType(),$1->getLine(),$1->getEnd());
				   $$->add($1);
				  
				  fprintf(logout,"argument_list : arguments\n");
               }
			  |
			  {
				$$=new Node("","EMPTY RULE",line_count,line_count);
			  }
			  ;
	
arguments : arguments COMMA logic_expression
{
	     arg_list.push_back($3->getType());
	     $$=new Node("arguments : arguments COMMA logic_expression",$1->getType(),$1->getLine(),$3->getEnd());
		 $$->add($1);
		 $$->add(new Node($2));
		 $$->add($3);
		
		fprintf(logout,"arguments : arguments COMMA logic_expression\n");
}
	      | logic_expression
		  {
			 	arg_list.push_back($1->getType());
			    $$=new Node("arguments : logic_expression",$1->getType(),$1->getLine(),$1->getEnd());
				$$->add($1);
				fprintf(logout,"arguments : logic_expression\n");
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	table=new SymbolTable();
	logout= fopen("log.txt","w");
	parsetree= fopen("parsetree.txt","w");
	errorout=fopen("error.txt","w");

	yyin=fp;
	yyparse();
	
    dfs(root,parsetree,0);
	string str=table->printAllScope();
	fprintf(logout,"%s\n",str.c_str());
	fprintf(logout,"Total lines: %d\n",line_count);
	fprintf(logout,"Total errors: %d\n",error_count);
	delete table;
	fclose(fp);
	fclose(logout);
	fclose(parsetree);
	fclose(errorout);
	return 0;
}

