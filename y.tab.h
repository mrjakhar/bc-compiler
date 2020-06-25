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
    FLOAT = 258,
    INTEGER = 259,
    VARIABLE = 260,
    WHILE = 261,
    IF = 262,
    PRINT = 263,
    FOR = 264,
    READI = 265,
    READF = 266,
    INC = 267,
    DEC = 268,
    PEQ = 269,
    MEQ = 270,
    MLEQ = 271,
    DEQ = 272,
    MOEQ = 273,
    exit_command = 274,
    IFX = 275,
    ELSE = 276,
    GE = 277,
    LE = 278,
    EQ = 279,
    NE = 280,
    UMINUS = 281
  };
#endif
/* Tokens.  */
#define FLOAT 258
#define INTEGER 259
#define VARIABLE 260
#define WHILE 261
#define IF 262
#define PRINT 263
#define FOR 264
#define READI 265
#define READF 266
#define INC 267
#define DEC 268
#define PEQ 269
#define MEQ 270
#define MLEQ 271
#define DEQ 272
#define MOEQ 273
#define exit_command 274
#define IFX 275
#define ELSE 276
#define GE 277
#define LE 278
#define EQ 279
#define NE 280
#define UMINUS 281

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 32 "custom-bc.y" /* yacc.c:1909  */

	float fValue; /* float value */
	int iValue; /* integer value */
	char *sIndex; /* variable name */
	nodeType *nPtr; /* node pointer */

#line 113 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
