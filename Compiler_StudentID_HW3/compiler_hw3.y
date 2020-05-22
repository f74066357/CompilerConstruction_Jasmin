/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }
    static int indexcount=0;
    static int addresscount=0;
    static int scopecount=0;
    static int f_flag=0;
    static int if_flag=0;
    static int p_flag=0;
    typedef struct Symbols {
        int index;
        char* name;
        char* type;
        int address;
        int lineno;
        char* etype;
        int scopenum;
    } Symbol;
    Symbol symbolTable[30];
    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol(int index,char* name,char* type,int address,int lineno,char* etype,int scopenum);
    static int lookup_symbol(char *name,int scopenum);
    static void dump_symbol(int scope);
    static void print_symbol();

    /* Global variables */
    bool HAS_ERROR = false;
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    float f_val;
    char *s_val;
    bool b_val;
}

/* Token without return */
%token INC DEC
%token ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token NOT
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
%token COMMA SEMICOLON NEWLINE
%token PRINT PRINTLN
%token IF ELSE FOR
%token VAR 
%token INT FLOAT BOOL STRING
/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <s_val> ID
%token <s_val> TRUE FALSE
%token <s_val> ADD SUB MUL QUO REM GTR LSS GEQ LEQ EQL NEQ LAND LOR
/* Nonterminal with return, which need to sepcify type */
%type  <s_val> Type TypeName ArrayType Literal
%type  <s_val> assign_op FORT IFT Condition PrimaryExpr ForStmt  UnaryExpr Operand
%type  <s_val> Expression Expression1 Expression2 Expression3 Expression4
/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : StatementList
;

StatementList
    : StatementList Statement
    | Statement
;

Statement
    :DeclarationStmt NEWLINE
    | SimpleStmt NEWLINE
    | Block NEWLINE
    | IfStmt NEWLINE
    | ForStmt NEWLINE   
    | PrintStmt NEWLINE
    | NEWLINE
;

DeclarationStmt
    : VAR ID Type   { 
                    }
    | VAR ID Type ASSIGN Expression     {
                                        }
;

SimpleStmt 
    : AssignmentStmt
    | ExpressionStmt
    | IncDecStmt
;
AssignmentStmt
    : Expression assign_op Expression   {
                                        }
;
assign_op
    : ASSIGN  {}  
    | ADD_ASSIGN    {}  
    | SUB_ASSIGN    {}  
    | MUL_ASSIGN    {}  
    | QUO_ASSIGN    {}  
    | REM_ASSIGN    {}  
;

ExpressionStmt
    : Expression
;

Type
    : TypeName 
    | ArrayType
;

TypeName
    : INT {}
    | FLOAT {}
    | STRING {}
    | BOOL {}
;

ArrayType
    : LBRACK Expression RBRACK Type
;

Expression
    : Expression LOR Expression1    {
                                       
                                    }
    | Expression1 
;
Expression1
    : Expression1 LAND Expression2  {
                                        
                                    }
    | Expression2
;
Expression2
    : Expression2  EQL Expression3  {
                                       
                                    }
    | Expression2  NEQ Expression3  {   
                                    }
    | Expression2  LSS Expression3  {  
                                    }
    | Expression2  LEQ Expression3  {  
                                    }
    | Expression2  GTR Expression3  {  
                                    }
    | Expression2  GEQ Expression3  {   
                                    }
    | Expression3 
;
Expression3
    : Expression3 ADD Expression4   {
                                    }
    | Expression3 SUB Expression4   {
                                       
                                    }
    | Expression4
;
Expression4
    : Expression4 MUL UnaryExpr   {}
    | Expression4 QUO UnaryExpr   {}
    | Expression4 REM UnaryExpr   {
                                    
                                  }
    | UnaryExpr     
;
UnaryExpr
    : ADD UnaryExpr  {}
    | SUB UnaryExpr  {}
    | NOT UnaryExpr  {}
    | PrimaryExpr   
;
PrimaryExpr
    : Operand                
    | IndexExpr 
    | ConversionExpr  
;
Operand
    : Literal  
    | ID    {
            }
    | LPAREN Expression RPAREN  {
                                 
                                }
;

Literal
    : INT_LIT   {}
    | FLOAT_LIT     {}
    | TRUE      {}
    | FALSE     {}
    | STRING_LIT   {}
;


IndexExpr
    : PrimaryExpr LBRACK Expression RBRACK  
;

ConversionExpr
    : Type LPAREN Expression RPAREN     {
                                            
                                        }
;

IncDecStmt
    : Expression INC    {}
    | Expression DEC    {}
;

Block
    : LBRACE1 StatementList RBRACE1  
;
LBRACE1
    :LBRACE{scopecount++;}
;
RBRACE1
    :RBRACE{dump_symbol(scopecount);scopecount--;}
;

IfStmt
    : IFT Condition Block   
    | IFT Condition Block ELSE IfStmt 
    | IFT Condition Block ELSE Block   
;

IFT
    :IF {}
;
Condition
    : Expression    {
                       
                    }
;

ForStmt
    : FORT ForClause Block 
    | FORT Condition Block   {  }
;
FORT
    :FOR {}
;
ForClause
    : InitStmt SEMICOLON Condition SEMICOLON PostStmt
;

InitStmt
    : SimpleStmt
;

PostStmt
    : SimpleStmt
;

PrintStmt
    : PRINT LPAREN Expression RPAREN    {
                                            
                                        }
    | PRINTLN LPAREN Expression RPAREN  {
                                            
                                        }
;

%%

/* C code section */
int main(int argc, char *argv[])
{
    create_symbol() ;
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    yylineno = 0;
    yyparse();
    //print_symbol();
    dump_symbol(0);
	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    if (HAS_ERROR) {
        remove("hw3.j");
    }
    return 0;
}

static void create_symbol() {
    for(int i=0;i<=9;i++){
        symbolTable[i].index=i;
        symbolTable[i].name="";
        symbolTable[i].type="";
        symbolTable[i].address=0;
        symbolTable[i].lineno=0;
        symbolTable[i].etype="";
        symbolTable[i].scopenum=-1;
    }
}

static void insert_symbol(int index,char* name,char* type,int address,int lineno,char* etype,int scopenum) {
    symbolTable[index].index=index;
    symbolTable[index].name=name;
    symbolTable[index].type=type;
    symbolTable[index].address=address;
    symbolTable[index].lineno=lineno;
    symbolTable[index].etype=etype;
    symbolTable[index].scopenum=scopenum;
    printf("> Insert {%s} into symbol table (scope level: %d)\n", name, scopenum);
}

static int lookup_symbol(char *name,int scopenum) {
    for(int i=0;i<indexcount;i++){
        if(strcmp(symbolTable[i].name,name)==0&&symbolTable[i].scopenum==scopenum){
            return symbolTable[i].index;
        }
    }
    while(scopenum!=0){
        scopenum--;
        for(int i=0;i<indexcount;i++){
        if(strcmp(symbolTable[i].name,name)==0&&symbolTable[i].scopenum==scopenum){
            return symbolTable[i].index;
        }
    }
    }
    return -1;
}

static void dump_symbol(int scope) {
    printf("> Dump symbol table (scope level: %d)\n", scope);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
    int k=0;
    for(int i=0;i<indexcount;i++){
        if(symbolTable[i].scopenum==scope){
            printf("%-10d%-10s%-10s%-10d%-10d%s\n",
                k, symbolTable[i].name, symbolTable[i].type, 
                symbolTable[i].address,symbolTable[i].lineno, symbolTable[i].etype);
            k++;
            symbolTable[i].scopenum=-1;
        }
        
    }
    
}

static void print_symbol() {
    printf("> Print\n");
    printf("%-10s%-10s%-10s%-10s%-10s%-10s%-10s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type","scope");
    for(int i=0;i<indexcount;i++){
            printf("%-10d%-10s%-10s%-10d%-10d%-10s%-10d\n",
                symbolTable[i].index, symbolTable[i].name, symbolTable[i].type, 
                symbolTable[i].address,symbolTable[i].lineno, symbolTable[i].etype,
                symbolTable[i].scopenum);
    }
    
}