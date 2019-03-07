%{
#include <iostream>
#include <string>
using namespace std;
#define YYSTYPE string
#include <stdio.h>
#include "pb.tab.h"

extern "C"{
    int yyerror(const char* s);
    int yylex(void);

}
extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;

int indent_line = 0;
string outstr;

string indent_n(int count);
string write_import(string data);
string write_comment(string data);
string write_message(string mname, string vals);
string write_vardefine(string vrequire, string vtype, string vname, string num);
%}


%token IMPORT_START
%token IMPORT_FILE
%token IMPORT_END

%token COMMENT

%token MESSAGE_START MESSAGE_NAME MESSAGE_END
%token VAR_REQUIRE VAR_TYPE VAR_NAME VAR_NUM

%%
program:
    |program stmt {fputs($2.c_str(), yyout);}
    ;
stmt:
    '\n'     {$$="\n";}
    |import  {$$=$1;}
    |message {$$=$1;}
    |comment {$$="";}
    ;
import:
    IMPORT_START IMPORT_FILE IMPORT_END {$$=write_import($2);}
    ;
message:
    MESSAGE_START MESSAGE_NAME varlist MESSAGE_END {$$=write_message($2, $3);}
    ;
varlist:
    var {$$=$1;}
    ;
var:
    VAR_REQUIRE VAR_TYPE VAR_NAME VAR_NUM COMMENT {$$=write_vardefine($1, $2, $3, $4);}
    |VAR_REQUIRE VAR_TYPE VAR_NAME VAR_NUM        {$$=write_vardefine($1, $2, $3, $4);}
comment:
    COMMENT {}
    ;
%%

int main(){
    FILE *fp1=fopen("common.proto", "r");
    FILE *fp2=fopen("output.html", "w");
    yyin=fp1;
    yyout=fp2;
    return yyparse();
}

int yyerror(const char* s){
    fprintf(stderr,"parse err: line=%d err=%s\n", yylineno, s);
    return 1;
}

string write_import(string data){
    string var="import \""+data+"\";";
    return var;
}

string write_comment(string data){
    return data;
}

string write_message(string mname, string vals){
    string var="message "+mname+"\n{\n"+vals+"\n}\n";
    return var;
}

string write_vardefine(string vrequire, string vtype, string vname, string num){
    string var=vrequire+vtype+vname+num;
    return var;
}