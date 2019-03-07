%{
#include <iostream>
#include <string>
using namespace std;
#define YYSTYPE string

#include <stdio.h>
#include "pb.tab.h"
extern "C"{
    int yywrap(void);
    int yylex(void);
};
%}

%x _IMPORT_FILE
%x _MESSAGE_NAME
%x _MESSAGE_BODY
%x _VAR_DEFINE _VAR_TYPE _VAR_NAME

comment_line "[ \t]*//".*
comment_area "[ \t]*/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"
%%

comment_line {yylval=yytext; return COMMENT;}
comment_area {yylval=yytext; return COMMENT;}

[ \t]*"import"[ \t]+[\"]   {BEGIN _IMPORT_FILE; return IMPORT_START;}
<_IMPORT_FILE>[^\"]*       {yylval=yytext; return IMPORT_FILE;}
<_IMPORT_FILE>[\"][ \t]*;  {BEGIN INITIAL; return IMPORT_END;}


"message"[ \t]+             {BEGIN _MESSAGE_NAME; return MESSAGE_START;}
<_MESSAGE_NAME>[a-zA-Z0-9]* {yylval=yytext; BEGIN _MESSAGE_BODY; return MESSAGE_NAME;}
<_MESSAGE_BODY>[ \t\n]*"{"  {BEGIN _VAR_DEFINE;}
<_VAR_DEFINE>[ \t]*\}       {return MESSAGE_END;}

<_VAR_DEFINE>[ \t]*optional            {yylval=yytext; BEGIN _VAR_TYPE; return VAR_REQUIRE;}
<_VAR_TYPE>[ \t]+[a-zA-z]+[a-zA-z0-9]* {yylval=yytext; BEGIN _VAR_NAME; return VAR_TYPE;}
<_VAR_NAME>[ \t]+[a-zA-z]+[a-zA-z0-9]* {yylval=yytext; return VAR_NAME;}
<_VAR_NAME>[ \t]+=[ \t]*[0-9]+;        {yylval=yytext; cout<<"1111"<<endl; return VAR_NUM;}
<_VAR_NAME>comment_line                {yylval=yytext; cout<<"2222"<<endl; return COMMENT;}
<_VAR_NAME>comment_area                {yylval=yytext; cout<<"3333"<<endl; return COMMENT;}
<_VAR_NAME>[\n]+                       {BEGIN _VAR_DEFINE;}


\n+   {yylval="\n"; return *yytext;}
[ \t] {;}
.     {;}

%%

int yywrap(void) {
    return 1;
}