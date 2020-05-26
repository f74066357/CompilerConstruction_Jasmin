/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;
    FILE *file;
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
    static int assign_flag=0;
    static tag_count=0;
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
    char * typecheck(char *id);
    static void loadID(int index);
    static void store(int index);
    static void output(char* type,int ln);
    static void initial(int index);
    static void print_assign(char * type,char * op);
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
                        char * buff=strdup($2);
                        const char* delim = " ";
                        char *sepstr = buff;
                        char * name=strsep(&sepstr, delim);
                        char * dtype;
                        char * etype;
                        if(strcmp($3,"INT")==0){
                            dtype="int32";
                            etype="-";
                        }
                        else if(strcmp($3,"FLOAT")==0){
                            dtype="float32";
                            etype="-";
                        }
                        else if(strcmp($3,"STRING")==0){
                            dtype="string";
                            etype="-";
                        }
                        else if(strcmp($3,"BOOL")==0){
                            dtype="bool";
                            etype="-";
                        }
                        else{//array
                                           
                            const char* arrcut = "]";
                            char *substr = NULL;
                            substr =strsep(&sepstr, arrcut);
                            char arrtype[8]={};
                            strncpy(arrtype,sepstr,strlen(sepstr)-1);
                            arrtype[strlen(sepstr)]="\0";
                            //printf("len %d\n",strlen(sepstr));
                            //printf("type %s\n",sepstr);
                            //printf("type %s\n",arrtype);
                            //printf("hoho\n");
                            printf("name %s\n",name);
                            if(strcmp(arrtype,"int32")==0){
                                dtype="array";
                                etype="int32";
                            }
                            else if(strcmp(arrtype,"float32")==0){
                                dtype="array";
                                etype="float32";
                            }

                        }
                        
                        if(lookup_symbol(name,scopecount)==-1){
                            insert_symbol(indexcount,name,dtype,addresscount,yylineno,etype,scopecount);
                            indexcount++;
                            addresscount++;
                            int index=lookup_symbol(name,scopecount);
                            initial(index);
                            
                            if(strcmp(symbolTable[index].type,"array")==0){
                                fprintf(file,"astore %d\n",index);
                            }
                            else{
                                store(index);
                            }
                            
                        }
                        else{
                            int i=lookup_symbol(name,scopecount);
                            int p=symbolTable[i].lineno;
                            printf("error\:%d\: %s redeclared in this block. previous declaration at line %d\n",yylineno,name,p);
                            HAS_ERROR = TRUE;
                        }
                        
                    }
    | VAR ID Type ASSIGN Expression     {
                                            //int idaddress=lookup_symbol($2,)
                                            //loadID(idaddress);
                                            char * buff=strdup($2);
                                            const char* delim = " ";
                                            char *sepstr = buff;
                                            char * name=strsep(&sepstr, delim);
                                            char * dtype;
                                            char * etype;
                                            if(strcmp($3,"INT")==0){
                                                dtype="int32";
                                                etype="-";
                                            }
                                            else if(strcmp($3,"FLOAT")==0){
                                                dtype="float32";
                                                etype="-";
                                            }
                                            else if(strcmp($3,"STRING")==0){
                                                dtype="string";
                                                etype="-";
                                            }
                                            else if(strcmp($3,"BOOL")==0){
                                                dtype="bool";
                                                etype="-";
                                            }
                                            else{
                                                const char* arrcut = "]";
                                                char *substr = NULL;
                                                substr =strsep(&sepstr, arrcut);
                                                char arrtype[8]={};
                                                strncpy(arrtype,sepstr,strlen(sepstr)-1);
                                                arrtype[strlen(sepstr)]="\0";
                                                //printf("len %d\n",strlen(sepstr));
                                                //printf("type %s\n",sepstr);
                                                //printf("type %s\n",arrtype);
                                                //printf("hoho\n");
                                                if(strcmp(arrtype,"int32")==0){
                                                    dtype="array";
                                                    etype="int32";
                                                }
                                                else if(strcmp(arrtype,"float32")==0){
                                                    dtype="array";
                                                    etype="float32";
                                                }
                                                
                                            }
                                            
                                            //if(lookup_symbol(name)==-1){
                                                insert_symbol(indexcount,name,dtype,addresscount,yylineno,etype,scopecount);
                                                indexcount++;
                                                addresscount++;
                                                //print_symbol(scopecount);
                                            int index=lookup_symbol(name,scopecount);
                                            if(strcmp(symbolTable[index].type,"array")==0){
                                                fprintf(file,"astore %d\n",index);
                                            }
                                            else{
                                                store(index);
                                            }
                                        }
;

SimpleStmt 
    : AssignmentStmt
    | ExpressionStmt
    | IncDecStmt
;
AssignmentStmt
    : Expression assign_op Expression   {
                                            char* id1=NULL;
                                            char* id2=NULL;
                                            char* type1=NULL;
                                            char* type2=NULL;
                                            char * buff=strdup($1);
                                            const char* delim = " ";
                                            char *sepstr = buff;
                                            char * name=strsep(&sepstr, delim);
                                            id1=name;
                                            char temp[10]={};
                                            char temp2[10]={};
                                            strncpy(temp2,$3,strlen($3));
                                            if(strcmp(temp2,"INT_LIT")==0){
                                                id2=temp2;
                                            }
                                            else{
                                                strncpy(temp,$3,strlen($3)-1);
                                                id2=temp;
                                            }
                                            char *c=strstr(id1, "[");
                                            if(c != NULL) {
                                                const char* idcut = "[";
                                                char *sepstr = id1;
                                                id1=strsep(&sepstr, idcut);
                                                //printf("id\: %s\n",id1);
                                            }

                                            //printf("id\: %s %s\n",id1,id2);
                                            if(strcmp(id1,"INT_LIT")==0){
                                                type1="int32";
                                                printf("error\:%d\: cannot assign to %s\n",yylineno,"int32");
                                                HAS_ERROR = TRUE;
                                            }
                                            else if(strcmp(id1,"FLOAT_LIT")==0){
                                                type1="float32";
                                                printf("error\:%d\: cannot assign to %s\n",yylineno,"float32");
                                                HAS_ERROR = TRUE;
                                            }
                                            else{
                                                int i1=lookup_symbol(id1,scopecount);
                                                if(i1!=-1){
                                                        type1=typecheck(id1);
                                                        print_assign(type1,$2);
                                                        store(i1);
                                                }
                                                else{
                                                    type1=" ";
                                                }
                                            }
                                            if(strcmp(id2,"INT_LIT")==0){
                                                type2="int32";
                                            }
                                            else if(strcmp(id2,"FLOAT_LIT")==0){
                                                type2="float32";
                                            }
                                            else{
                                                int i2=lookup_symbol(id2,scopecount);
                                                if(i2!=-1){
                                                    type2=typecheck(id2);
                                                    print_assign(type1,$2);
                                                    store(i2);
                                                }
                                                else{
                                                    type2=" ";
                                                }
                                                
                                            }
                                            //printf("type : %s %s\n",type1,type2);
                                            if(strcmp(type1,type2)!=0){
                                                if(strcmp(type1," ")!=0 && strcmp(type2," ")!=0){
                                                    printf("error\:%d\: invalid operation\: %s (mismatched types %s and %s)\n",yylineno,$2,type1,type2);
                                                    HAS_ERROR = TRUE;
                                                }
                                            }
                                            printf("%s\n",$2);
                                            
                                        }
;
assign_op
    : ASSIGN  {$$ = "ASSIGN";if(assign_flag==1){assign_flag=0;}}  
    | ADD_ASSIGN    {$$ = "ADD_ASSIGN";if(assign_flag==1){assign_flag=0;} 
                        //fprintf(file,"iadd\n");
                    }  
    | SUB_ASSIGN    {$$ = "SUB_ASSIGN";if(assign_flag==1){assign_flag=0;}
                        //fprintf(file,"isub\n");
    
                    } 
    | MUL_ASSIGN    {$$ = "MUL_ASSIGN";if(assign_flag==1){assign_flag=0;}} 
    | QUO_ASSIGN    {$$ = "QUO_ASSIGN";if(assign_flag==1){assign_flag=0;}}
    | REM_ASSIGN    {$$ = "REM_ASSIGN";if(assign_flag==1){assign_flag=0;}}  
;

ExpressionStmt
    : Expression
;

Type
    : TypeName 
    | ArrayType
;

TypeName
    : INT {$$ = "INT";}
    | FLOAT {$$ = "FLOAT";}
    | STRING {$$ = "STRING";}
    | BOOL {$$ = "BOOL";}
;

ArrayType
    : LBRACK Expression RBRACK Type
;

Expression
    : Expression LOR Expression1    {
                                        //printf("first %s\n",$1);
                                        //printf("third %s\n",$3);
                                        if(strcmp($1,"INT_LIT")==0||strcmp($3,"INT_LIT")==0){
                                            if(strcmp($3,"TRUE")!=0&&strcmp($3,"FALSE")!=0){
                                                printf("error\:%d\: invalid operation\: (operator LOR not defined on int32)\n",yylineno);
                                                HAS_ERROR = TRUE;
                                            }
                                            
                                        }
                                        //$$="LOR";
                                        printf("%s\n","LOR");
                                        fprintf(file,"ior\n");
                                    }
    | Expression1 
;
Expression1
    : Expression1 LAND Expression2  {
                                        if(strcmp($1,"INT_LIT")==0||strcmp($3,"INT_LIT")==0){
                                            printf("error\:%d\: invalid operation\: (operator LAND not defined on int32)\n",yylineno);
                                            HAS_ERROR = TRUE;
                                        }
                                        //$$="LAND";
                                        printf("%s\n","LAND");
                                        fprintf(file,"iand\n");
                                    }
    | Expression2
;
Expression2
    : Expression2  EQL Expression3  {
                                        //$$="EQL";
                                        printf("%s\n","EQL");
                                        if(p_flag==-1){p_flag=1;}
                                        if(f_flag==-1){f_flag=1;}
                                        if(if_flag==-1){if_flag=1;}
                                    }
    | Expression2  NEQ Expression3  {   //$$="NEQ";
                                        printf("%s\n","NEQ");
                                        if(p_flag==-1){p_flag=1;}
                                        if(f_flag==-1){f_flag=1;}
                                        if(if_flag==-1){if_flag=1;}
                                    }
    | Expression2  LSS Expression3  {   //$$="LSS";
                                        printf("%s\n","LSS");
                                        if(p_flag==-1){p_flag=1;}
                                        if(f_flag==-1){f_flag=1;}
                                        if(if_flag==-1){if_flag=1;}
                                    }
    | Expression2  LEQ Expression3  {   //$$="LEQ";
                                        printf("%s\n","LEQ");
                                        if(p_flag==-1){p_flag=1;}
                                        if(f_flag==-1){f_flag=1;}
                                        if(if_flag==-1){if_flag=1;}
                                    }
    | Expression2  GTR Expression3  {   //$$="GTR";
                                        printf("%s\n","GTR");
                                        if(p_flag==-1){p_flag=1;}
                                        if(f_flag==-1){f_flag=1;}
                                        if(if_flag==-1){if_flag=1;}
                                        //outputcompare("GTR");
                                        //printf("1 %s\n",$1);
                                        //printf("3 %s\n",$3);

                                        int temp_tag=tag_count;
                                        if(strcmp("INT_LIT",$1)==0){
                                            fprintf(file,"isub\n");
                                        }
                                        if(strcmp("FLOAT_LIT",$1)==0){
                                            fprintf(file,"fcmpl\n");
                                        }
                                        fprintf(file,"ifgt L_cmp_%d\n",temp_tag);//0
                                        fprintf(file,"iconst_0\n");
                                        fprintf(file,"goto L_cmp_%d\n",temp_tag+1);//1
                                        fprintf(file,"L_cmp_%d :\n",temp_tag);//0
                                        fprintf(file,"iconst_1\n");
                                        fprintf(file,"L_cmp_%d :\n",temp_tag+1);//1
                                        tag_count+=2;
                                    }
    | Expression2  GEQ Expression3  {   //$$="GEQ";
                                        printf("%s\n","GEQ");
                                        if(p_flag==-1){p_flag=1;}
                                        if(f_flag==-1){f_flag=1;}
                                        if(if_flag==-1){if_flag=1;}
                                    }
    | Expression3 
;
Expression3
    : Expression3 ADD Expression4   {
                                        //$$="ADD";
                                        char* id1=NULL;
                                        char* id2=NULL;
                                        char* type1=NULL;
                                        char* type2=NULL;
                                        char *c=strstr($1," ");
                                        if(c == NULL) {
                                            id1=$1;
                                            id2=$3;
                                        }
                                        else{
                                            char * buff=strdup($1);
                                            const char* delim = " ";
                                            char *sepstr = buff;
                                            char * name=strsep(&sepstr, delim);
                                            id1=name;
                                            char temp[10]={};
                                            char temp2[10]={};
                                            strncpy(temp2,$3,strlen($3));
                                            if(strcmp(temp2,"INT_LIT")==0){
                                                id2=temp2;
                                            }
                                            else{
                                                strncpy(temp,$3,strlen($3)-1);
                                                id2=temp;
                                            }
                                        }
                                        //printf("111 %s\n222 %s\n",id1,id2);
                                        //if()
                                        type1=typecheck(id1);
                                        type2=typecheck(id2);
                                        //printf("%s %s\n",type1,type2);
                                        if(strcmp(type1,type2)!=0){
                                            if(strcmp(type1," ")!=0 && strcmp(type2," ")!=0){
                                                printf("error\:%d\: invalid operation\: %s (mismatched types %s and %s)\n",yylineno,"ADD",type1,type2);
                                                HAS_ERROR = TRUE;
                                            }
                                        }
                                        printf("%s\n","ADD");
                                        if(strcmp(type1,"int32")==0||strcmp(type2,"int32")==0){
                                            fprintf(file,"iadd\n");
                                        }
                                        if(strcmp(type1,"float32")==0||strcmp(type2,"float32")==0){
                                            fprintf(file,"fadd\n");
                                        }

                                    }
    | Expression3 SUB Expression4   {
                                        //$$="SUB";
                                        char* id1=NULL;
                                        char* id2=NULL;
                                        char* type1=NULL;
                                        char* type2=NULL;
                                        char *c=strstr($1," ");
                                        if(c == NULL) {
                                            id1=$1;
                                            id2=$3;
                                        }
                                        else{
                                            char * buff=strdup($1);
                                            const char* delim = " ";
                                            char *sepstr = buff;
                                            char * name=strsep(&sepstr, delim);
                                            id1=name;
                                            char temp[10]={};
                                            char temp2[10]={};
                                            strncpy(temp2,$3,strlen($3));
                                            if(strcmp(temp2,"INT_LIT")==0){
                                                id2=temp2;
                                            }
                                            else{
                                                strncpy(temp,$3,strlen($3)-1);
                                                id2=temp;
                                            }
                                        }
                                        //printf("%s %s\n",id1,id2);
                                        type1=typecheck(id1);
                                        type2=typecheck(id2);
                                        //printf("%s %s\n",type1,type2);
                                        if(strcmp(type1,type2)!=0){
                                            if(strcmp(type1," ")!=0 && strcmp(type2," ")!=0){
                                                printf("error\:%d\: invalid operation\: %s (mismatched types %s and %s)\n",yylineno,"SUB",type1,type2);
                                                HAS_ERROR = TRUE;
                                            }
                                        }
                                        printf("%s\n","SUB");
                                        if(strcmp(type1,"int32")==0&&strcmp(type2,"int32")==0){
                                            fprintf(file,"isub\n");
                                        }
                                        else if(strcmp(type1,"float32")==0&&strcmp(type2,"float32")==0){
                                            fprintf(file,"fsub\n");
                                        }
                                    }
    | Expression4
;
Expression4
    : Expression4 MUL UnaryExpr   {//$$="MUL";
                                    char* id1=NULL;
                                    char* id2=NULL;
                                    char* type1=NULL;
                                    char* type2=NULL;
                                    char *c=strstr($1," ");
                                    if(c == NULL) {
                                        id1=$1;
                                        id2=$3;
                                    }
                                    else{
                                        char * buff=strdup($1);
                                        const char* delim = " ";
                                        char *sepstr = buff;
                                        char * name=strsep(&sepstr, delim);
                                        id1=name;
                                        char temp[10]={};
                                        char temp2[10]={};
                                        strncpy(temp2,$3,strlen($3));
                                        if(strcmp(temp2,"INT_LIT")==0){
                                            id2=temp2;
                                        }
                                        else{
                                            strncpy(temp,$3,strlen($3)-1);
                                            id2=temp;
                                        }
                                    }
                                    //printf("%s %s\n",id1,id2);
                                    type1=typecheck(id1);
                                    type2=typecheck(id2);
                                    printf("%s\n","MUL");
                                    if(strcmp(type1,"int32")==0){
                                        fprintf(file,"imul\n");
                                    }
                                    else if(strcmp(type1,"float32")==0){
                                        fprintf(file,"fmul\n");
                                    }

                                }
    | Expression4 QUO UnaryExpr   {//$$="QUO";
                                    char* id1=NULL;
                                    char* id2=NULL;
                                    char* type1=NULL;
                                    char* type2=NULL;
                                    char *c=strstr($1," ");
                                    if(c == NULL) {
                                        id1=$1;
                                        id2=$3;
                                    }
                                    else{
                                        char * buff=strdup($1);
                                        const char* delim = " ";
                                        char *sepstr = buff;
                                        char * name=strsep(&sepstr, delim);
                                        id1=name;
                                        char temp[10]={};
                                        char temp2[10]={};
                                        strncpy(temp2,$3,strlen($3));
                                        if(strcmp(temp2,"INT_LIT")==0){
                                            id2=temp2;
                                        }
                                        else{
                                            strncpy(temp,$3,strlen($3)-1);
                                            id2=temp;
                                        }
                                    }
                                    //printf("%s %s\n",id1,id2);
                                    type1=typecheck(id1);
                                    type2=typecheck(id2);
                                    printf("%s\n","QUO");
                                    if(strcmp(type1,"int32")==0&&strcmp(type2,"int32")==0){
                                        fprintf(file,"idiv\n");
                                    }
                                    else if(strcmp(type1,"float32")==0&&strcmp(type2,"float32")==0){
                                        fprintf(file,"fdiv\n");
                                    }
                                    }
    | Expression4 REM UnaryExpr   {
                                    //$$="REM";
                                    char* id1=NULL;
                                    char* id2=NULL;
                                    char* type1=NULL;
                                    char* type2=NULL;
                                    char *c=strstr($1," ");
                                    if(c == NULL) {
                                        id1=$1;
                                        id2=$3;
                                    }
                                    else{
                                        char * buff=strdup($1);
                                        const char* delim = " ";
                                        char *sepstr = buff;
                                        char * name=strsep(&sepstr, delim);
                                        id1=name;
                                        char temp[10]={};
                                        char temp2[10]={};
                                        strncpy(temp2,$3,strlen($3));
                                        if(strcmp(temp2,"INT_LIT")==0){
                                            id2=temp2;
                                        }
                                        else{
                                            strncpy(temp,$3,strlen($3)-1);
                                            id2=temp;
                                        }
                                    }
                                    //printf("%s %s\n",id1,id2);
                                    type1=typecheck(id1);
                                    type2=typecheck(id2);
                                    //printf("%s %s\n",type1,type2);
                                    if(strcmp(type1,"float32")==0||strcmp(type2,"float32")==0){
                                        printf("error\:%d\: invalid operation\: (operator REM not defined on float32)\n",yylineno);
                                        HAS_ERROR = TRUE;
                                    }
                                    printf("%s\n","REM");
                                    if(strcmp(type1,"int32")==0&&strcmp(type2,"int32")==0){
                                        fprintf(file,"irem\n");
                                    }
                                  }
    | UnaryExpr     
;
UnaryExpr
    : ADD UnaryExpr  {
                        printf("%s\n","POS");
                        
                        $$=$2;
                        }
    | SUB UnaryExpr  {
                        printf("%s\n","NEG");
                        //printf("222 %s\n",$2);
                        if(strcmp($2,"INT_LIT")==0){
                             fprintf(file,"ineg\n");
                        }
                        if(strcmp($2,"FLOAT_LIT")==0){
                             fprintf(file,"fneg\n");
                        }
                        $$=$2;
                        }
    | NOT UnaryExpr  {
                        printf("%s\n","NOT");
                        $$=$2;
                        fprintf(file,"iconst_1\n");
                        fprintf(file,"ixor\n");
                        }
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
                char ident[100];
                char nameforlook[30]={};
                strcpy(nameforlook,$1);
                //printf("%s\n",nameforlook);
                int idaddress=lookup_symbol(nameforlook,scopecount);
                if(idaddress!=-1){
                    printf("IDENT (name=%s, address=%d)\n",$1,idaddress);
                    if(assign_flag!=1){
                        loadID(idaddress);
                    }
                    
                }
                else{
                    printf("error\:%d\: undefined\: %s\n",yylineno+1,nameforlook);
                    HAS_ERROR = TRUE;
                }
                $$=$1;
            }
    | LPAREN Expression RPAREN  {
                                    $$=$2;
                                }
;

Literal
    : INT_LIT   {printf("INT_LIT %d\n",$1);$$="INT_LIT";fprintf(file,"ldc %d\n",yylval);}
    | FLOAT_LIT     {printf("FLOAT_LIT %6f\n",$1);$$="FLOAT_LIT";fprintf(file,"ldc %f\n",yylval);}
    | TRUE      {printf("TRUE\n"); $$="TRUE";fprintf(file,"%s\n","iconst_1");}
    | FALSE     {printf("FALSE\n");$$="FALSE";fprintf(file,"%s\n","iconst_0");}
    | STRING_LIT   {printf("STRING_LIT %s\n",$1);$$="STRING_LIT";fprintf(file,"ldc \"%s\"\n",yylval);}
;


IndexExpr
    : PrimaryExpr LBRACK Expression RBRACK  
;

ConversionExpr
    : Type LPAREN Expression RPAREN     {
                                            //printf("111%s\n",$1);
                                            char *conv=NULL;
                                            if(strcmp($1,"INT")==0){
                                                conv="I";
                                                fprintf(file,"f2i\n");
                                            }
                                            else if(strcmp($1,"FLOAT")==0){
                                                conv="F";
                                                fprintf(file,"i2f\n");
                                            } 
                                            char * convo=NULL;
                                            if(strcmp($3,"INT_LIT")==0){
                                                convo="I";
                                            }
                                            else if(strcmp($3,"FLOAT_LIT")==0){
                                                convo="F";
                                            } 
                                            else{
                                                char * buff=strdup($3);
                                                char * idid;
                                                const char* idcut = ")";
                                                char *sepstr = buff;
                                                idid=strsep(&sepstr, idcut);
                                                int k=lookup_symbol(idid,scopecount);
                                                char* ptype=NULL;
                                                ptype=symbolTable[k].type;
                                                if(strcmp(ptype,"int32")==0){
                                                    convo="I";
                                                }
                                                else if(strcmp(ptype,"float32")==0){
                                                    convo="F";
                                                } 
                                            }
                                            
                                            printf("%s to %s\n",convo,conv);

                                        }
;

IncDecStmt
    : Expression INC    {
                            printf("%s\n","INC");
                            //printf("inc\: %s\n",$1);
                            const char* idcut = "+";
                            char *sepstr = strdup($1);
                            char *idid=strsep(&sepstr, idcut);
                            int index=lookup_symbol(idid,scopecount);
                            char *type=symbolTable[index].type;
                            if(strcmp(type,"int32")==0){
                                fprintf(file,"ldc 1\n");
                                fprintf(file,"iadd\n");
                            }
                            if(strcmp(type,"float32")==0){
                                fprintf(file,"ldc 1.0\n");
                                fprintf(file,"fadd\n");
                            }
                            store(index);
                        }
    | Expression DEC    {
                            printf("%s\n","DEC");

                            const char* idcut = "-";
                            char *sepstr = strdup($1);
                            char *idid=strsep(&sepstr, idcut);
                            int index=lookup_symbol(idid,scopecount);
                            char *type=symbolTable[index].type;
                            if(strcmp(type,"int32")==0){
                                fprintf(file,"ldc 1\n");
                                fprintf(file,"isub\n");
                            }
                            if(strcmp(type,"float32")==0){
                                fprintf(file,"ldc 1.0\n");
                                fprintf(file,"fsub\n");
                            }
                            store(index);

                        }
;

Block
    : LBRACE1 StatementList RBRACE1  
;
LBRACE1
    :LBRACE {scopecount++;}
;
RBRACE1
    :RBRACE {dump_symbol(scopecount);scopecount--;}
;

IfStmt
    : IFT Condition Block   {if_flag=0;}
    | IFT Condition Block ELSE IfStmt   {if_flag=0;}
    | IFT Condition Block ELSE Block    {if_flag=0;}
;

IFT
    :IF {if_flag=-1;}
;
Condition
    : Expression    {
                        if(if_flag==-1){
                            if(strcmp($1,"INT_LIT")==0){
                                printf("error\:%d\: non-bool (type int32) used as for condition\n",yylineno+1);
                                HAS_ERROR=TRUE;
                            }
                            else if(strcmp($1,"FLOAT_LIT")==0){
                                printf("error\:%d\: non-bool (type float32) used as for condition\n",yylineno+1);
                                HAS_ERROR=TRUE;
                            }
                            else{
                                char * buff=strdup($1);
                                const char* delim = " ";
                                char *sepstr = buff;
                                char * name=strsep(&sepstr, delim);
                                char * type=NULL;
                                int i=lookup_symbol(name,scopecount);
                                type=symbolTable[i].type;
                                if(strcmp(type,"int32")==0){
                                    printf("error\:%d\: non-bool (type int32) used as for condition\n",yylineno+1);
                                    HAS_ERROR=TRUE;
                                }
                                else if(strcmp(type,"float32")==0){
                                    printf("error\:%d\: non-bool (type float32) used as for condition\n",yylineno+1);
                                    HAS_ERROR=TRUE;
                                }
                            }
                        }
                        if(f_flag==-1){
                            if(strcmp($1,"INT_LIT")==0){
                                printf("error\:%d\: non-bool (type int32) used as for condition\n",yylineno+1);
                                HAS_ERROR=TRUE;
                            }
                            else if(strcmp($1,"FLOAT_LIT")==0){
                                printf("error\:%d\: non-bool (type float32) used as for condition\n",yylineno+1);
                                HAS_ERROR=TRUE;
                            }
                            else{
                                char * buff=strdup($1);
                                const char* delim = " ";
                                char *sepstr = buff;
                                char * name=strsep(&sepstr, delim);
                                char * type=NULL;
                                int i=lookup_symbol(name,scopecount);
                                type=symbolTable[i].type;
                                if(strcmp(type,"int32")==0){
                                    printf("error\:%d\: non-bool (type int32) used as for condition\n",yylineno+1);
                                    HAS_ERROR=TRUE;
                                }
                                else if(strcmp(type,"float32")==0){
                                    printf("error\:%d\: non-bool (type float32) used as for condition\n",yylineno+1);
                                    HAS_ERROR=TRUE;
                                }
                            }
                        }
                    }
;

ForStmt
    : FORT ForClause Block 
    | FORT Condition Block   {  
                        f_flag=0;
                    }
;
FORT
    :FOR {f_flag=-1;}
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
    : PRINT {p_flag=-1;} LPAREN Expression RPAREN    {
                                            char * buff=strdup($4);
                                            char * idid;
                                            
                                            char *c=strstr(buff, "[");
                                            if(c == NULL) {
                                                const char* idcut1 = ")";
                                                char *sepstr = buff;
                                                idid=strsep(&sepstr, idcut1);
                                            }
                                            else{
                                                const char* idcut2 = "[";
                                                char *sepstr = buff;
                                                idid=strsep(&sepstr, idcut2);
                                            }
                                            //printf("oaoa1 :%s\n",idid);
                                            //print_symbol(0);
                                            char *d=strstr(buff, " ");
                                            if(d != NULL) {
                                                const char* idcut = " ";
                                                char *sepstr = idid;
                                                idid=strsep(&sepstr, idcut);
                                            }
                                            //printf("oaoa : %s\n",idid);
                                            int k=lookup_symbol(idid,scopecount);
                                            char* ptype=NULL;
                                            if(p_flag==1){
                                                ptype="bool";
                                            }
                                            else if(symbolTable[k].type=="array"){
                                                ptype=symbolTable[k].etype;
                                            }
                                            else if(k!=-1){//ID
                                                ptype=symbolTable[k].type;
                                            }
                                            else if(strcmp(idid,"FLOAT_LIT")==0){//float_lit
                                                ptype= "float32";
                                            }
                                            else if(strcmp(idid,"INT_LIT")==0){//int_lit
                                                ptype= "int32";
                                            }
                                            else{
                                                ptype="string";
                                            }
                                            printf("PRINT %s\n",ptype);
                                            output(ptype,0);
                                            p_flag=0;
                                        }
    | PRINTLN{p_flag=-1;} LPAREN Expression RPAREN  {
                                            //printf("oaoa :%s\n",$4);
                                            char * buff=strdup($4);
                                            char * idid;
                                            
                                            char *c=strstr(buff, "[");
                                            if(c == NULL) {
                                                const char* idcut1 = ")";
                                                char *sepstr = buff;
                                                idid=strsep(&sepstr, idcut1);
                                            }
                                            else{
                                                const char* idcut2 = "[";
                                                char *sepstr = buff;
                                                idid=strsep(&sepstr, idcut2);
                                            }
                                            //printf("oaoa1 :%s\n",idid);
                                            //print_symbol(0);
                                            char *d=strstr(buff, " ");
                                            if(d != NULL) {
                                                const char* idcut = " ";
                                                char *sepstr = idid;
                                                idid=strsep(&sepstr, idcut);
                                            }
                                            //printf("oaoa0 :%s\n",idid);

                                            int k=lookup_symbol(idid,scopecount);
                                            //printf("oaoa12 :%d %d\n",scopecount,k);
                                            char* ptype=NULL;
                                            if(p_flag==1){
                                                ptype="bool";
                                            }
                                            else if(symbolTable[k].type=="array"){
                                                ptype=symbolTable[k].etype;
                                            }
                                            else if(k!=-1){//ID
                                                ptype=symbolTable[k].type;
                                            }
                                            else if(strcmp(idid,"FLOAT_LIT")==0){//float_lit
                                                ptype= "float32";
                                            }
                                            else if(strcmp(idid,"INT_LIT")==0){//int_lit
                                                ptype= "int32";
                                            }
                                            else{
                                                ptype="string";
                                            }
                                            printf("PRINTLN %s\n",ptype);
                                            output(ptype,1);
                                            p_flag=0;
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
    file = fopen("hw3.j","w");
    fprintf(file,    
                    ".source hw3.j\n"
                    ".class public Main\n"
                    ".super java/lang/Object\n"
                    ".method public static main([Ljava/lang/String;)V\n"
                    ".limit stack 100\n"
                    ".limit locals 100\n"
            );
    yylineno = 0;
    yyparse();
    fprintf(file,
                        "   return\n"
                        ".end method"
        ); 
    //print_symbol();
    dump_symbol(0);
	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    fclose(file);
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
    printf("%-10s%-10s%-10s%-10s%-10s%-10s%-50s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type","scope");
    for(int i=0;i<indexcount;i++){
            printf("%-10d%-10s%-10s%-10d%-10d%-10s%-50d\n",
                symbolTable[i].index, symbolTable[i].name, symbolTable[i].type, 
                symbolTable[i].address,symbolTable[i].lineno, symbolTable[i].etype,
                symbolTable[i].scopenum);
    }
    
}
static void loadID(int index){
    if(strcmp(symbolTable[index].type,"string")==0){
        fprintf(file,"aload %d\n",index);
    }
    if(strcmp(symbolTable[index].type,"float32")==0){
        fprintf(file,"fload %d\n",index);
    }
    if(strcmp(symbolTable[index].type,"int32")==0){
        fprintf(file,"iload %d\n",index);
    }
    if(strcmp(symbolTable[index].type,"array")==0){
        fprintf(file,"aload %d\n",index);
    }
}
static void outputbool(int ln){
    int temp_tag=tag_count;
    fprintf(file,"ifne L_cmp_%d\n",temp_tag);
    fprintf(file,"ldc \"false\"\n");
    fprintf(file,"goto L_cmp_%d\n",temp_tag+1);
    fprintf(file,"L_cmp_%d:\n",temp_tag);
    fprintf(file,"ldc \"true\"\n");
    fprintf(file,"L_cmp_%d :\n",temp_tag+1);
    tag_count+=2;
    fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n");
    fprintf(file,"swap\n");
    if(ln==1){
        fprintf(file,"invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
    }
    else{
        fprintf(file,"invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
    }
}

static void output(char* type,int ln){
    
    if(ln==1){
        if(strcmp(type,"bool")==0){
            outputbool(1);
        }
        else{
            fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(file,"swap\n");
            if(strcmp(type,"string")==0){
                fprintf(file,"invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
            }
            if(strcmp(type,"float32")==0){
                fprintf(file,"invokevirtual java/io/PrintStream/println(F)V\n");
            }
            if(strcmp(type,"int32")==0){
                fprintf(file,"invokevirtual java/io/PrintStream/println(I)V\n");
            }
        }
    }
    else{
         if(strcmp(type,"bool")==0){
            outputbool(0);
        }
        else{
            fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(file,"swap\n");
            if(strcmp(type,"string")==0){
                fprintf(file,"invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
            }
            if(strcmp(type,"float32")==0){
                fprintf(file,"invokevirtual java/io/PrintStream/print(F)V\n");
            }
            if(strcmp(type,"int32")==0){
                fprintf(file,"invokevirtual java/io/PrintStream/print(I)V\n");
            }
        }
    }
}
static void store(int index){
    if(index==-1){

    }
    if(strcmp(symbolTable[index].type,"string")==0){
        fprintf(file,"astore %d\n",index);
    }
    if(strcmp(symbolTable[index].type,"float32")==0){
        fprintf(file,"fstore %d\n",index);
    }
    if(strcmp(symbolTable[index].type,"int32")==0){
        fprintf(file,"istore %d\n",index);
    }
    if(strcmp(symbolTable[index].type,"array")==0){
        if(strcmp(symbolTable[index].etype,"int32")==0){
            fprintf(file,"iastore\n");
        }
        if(strcmp(symbolTable[index].etype,"float32")==0){
            fprintf(file,"fastore %d\n",index);
        }
        
    }
}
char * typecheck(char *id){
    char *type = malloc(5);
    if(strcmp(id,"FLOAT_LIT")==0||strcmp(id,"FLOAT")==0){
        type="float32";
    }
    else if(strcmp(id,"INT_LIT")==0||strcmp(id,"IN")==0){
        type="int32";
    }
    else{
        int i=lookup_symbol(id,scopecount);
        if(i!=-1){
            if(strcmp(symbolTable[i].type,"array")==0){
                type=symbolTable[i].etype;
            }
            else{
                type=symbolTable[i].type;
            }
            
        }
        else{
            type=" ";
        }
    }
    return type;
}

static void initial(int index){
    if(strcmp(symbolTable[index].type,"string")==0){
        fprintf(file,"ldc \"\"\n");
    }
    if(strcmp(symbolTable[index].type,"float32")==0){
        fprintf(file,"ldc 0.0\n");
    }
    if(strcmp(symbolTable[index].type,"int32")==0){
        fprintf(file,"ldc 0\n");
    }
    if(strcmp(symbolTable[index].type,"bool")==0){
        fprintf(file,"iconst_0\n");
    }
    if(strcmp(symbolTable[index].type,"array")==0){
        fprintf(file,"newarray int\n");        
    }
}

static void print_assign(char * type,char * op){
    if(strcmp(type,"float32")==0){
        if(strcmp(op,"ADD_ASSIGN")==0){
            fprintf(file,"fadd\n");
        }
        if(strcmp(op,"SUB_ASSIGN")==0){
            fprintf(file,"fsub\n");
        }
        if(strcmp(op,"MUL_ASSIGN")==0){
            fprintf(file,"fmul\n");
        }
        if(strcmp(op,"QUO_ASSIGN")==0){
            fprintf(file,"fdiv\n");
        }
    }
    if(strcmp(type,"int32")==0){
        if(strcmp(op,"ADD_ASSIGN")==0){
            fprintf(file,"iadd\n");
        }
        if(strcmp(op,"SUB_ASSIGN")==0){
            fprintf(file,"isub\n");
        }
        if(strcmp(op,"MUL_ASSIGN")==0){
            fprintf(file,"imul\n");
        }
        if(strcmp(op,"QUO_ASSIGN")==0){
            fprintf(file,"idiv\n");
        }
        if(strcmp(op,"REM_ASSIGN")==0){
            fprintf(file,"irem\n");
        }
    }
}