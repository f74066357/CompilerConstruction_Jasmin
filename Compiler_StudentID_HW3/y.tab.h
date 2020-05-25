/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INC = 258,
    DEC = 259,
    ASSIGN = 260,
    ADD_ASSIGN = 261,
    SUB_ASSIGN = 262,
    MUL_ASSIGN = 263,
    QUO_ASSIGN = 264,
    REM_ASSIGN = 265,
    NOT = 266,
    LPAREN = 267,
    RPAREN = 268,
    LBRACK = 269,
    RBRACK = 270,
    LBRACE = 271,
    RBRACE = 272,
    COMMA = 273,
    SEMICOLON = 274,
    NEWLINE = 275,
    PRINT = 276,
    PRINTLN = 277,
    IF = 278,
    ELSE = 279,
    FOR = 280,
    VAR = 281,
    INT = 282,
    FLOAT = 283,
    BOOL = 284,
    STRING = 285,
    INT_LIT = 286,
    FLOAT_LIT = 287,
    STRING_LIT = 288,
    ID = 289,
    TRUE = 290,
    FALSE = 291,
    ADD = 292,
    SUB = 293,
    MUL = 294,
    QUO = 295,
    REM = 296,
    GTR = 297,
    LSS = 298,
    GEQ = 299,
    LEQ = 300,
    EQL = 301,
    NEQ = 302,
    LAND = 303,
    LOR = 304
  };
#endif
/* Tokens.  */
#define INC 258
#define DEC 259
#define ASSIGN 260
#define ADD_ASSIGN 261
#define SUB_ASSIGN 262
#define MUL_ASSIGN 263
#define QUO_ASSIGN 264
#define REM_ASSIGN 265
#define NOT 266
#define LPAREN 267
#define RPAREN 268
#define LBRACK 269
#define RBRACK 270
#define LBRACE 271
#define RBRACE 272
#define COMMA 273
#define SEMICOLON 274
#define NEWLINE 275
#define PRINT 276
#define PRINTLN 277
#define IF 278
#define ELSE 279
#define FOR 280
#define VAR 281
#define INT 282
#define FLOAT 283
#define BOOL 284
#define STRING 285
#define INT_LIT 286
#define FLOAT_LIT 287
#define STRING_LIT 288
#define ID 289
#define TRUE 290
#define FALSE 291
#define ADD 292
#define SUB 293
#define MUL 294
#define QUO 295
#define REM 296
#define GTR 297
#define LSS 298
#define GEQ 299
#define LEQ 300
#define EQL 301
#define NEQ 302
#define LAND 303
#define LOR 304

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 54 "compiler_hw3.y" /* yacc.c:1909  */

    int i_val;
    float f_val;
    char *s_val;
    bool b_val;

#line 159 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
