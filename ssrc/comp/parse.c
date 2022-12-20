
/*  A Bison parser, made from parse.y  */

#define IF      258
#define ELSE    259
#define SWITCH  260
#define CASE    261
#define BREAK   262
#define FOR     263
#define WHILE   264
#define DO      265
#define CONTINUE        266
#define DEFAULT 267
#define GOTO    268
#define RETURN  269
#define NUM     270
#define SYMBOL  271
#define STRING  272
#define ATYPEDEF        273
#define STRUCTUNION     274
#define SCSPEC  275
#define DEFOP   276
#define OROR    277
#define ANDAND  278
#define EQ      279
#define NE      280
#define LE      281
#define GE      282
#define RR      283
#define LL      284
#define IND     285
#define ADDROF  286
#define PLPL    287
#define MIMI    288
#define INV     289
#define UNARY   290
#define SIZEOF  291
#define CAST    292
#define NOTZ    293
#define FCALL   294
#define ARRAY   295
#define RA      296
#define DOT     297

#line 1 "parse.y"

#include "comp.h"
#define YYDEBUG 0
#ifdef _ACC_
#define YYSTYPE long
#endif


#ifndef YYLTYPE
typedef
  struct yyltype
    {
      short timestamp;
      short first_line;
      short first_column;
      short last_line;
      short last_column;
      char *text;
   }
  yyltype;

#define YYLTYPE yyltype
#endif

#ifndef YYSTYPE
#define YYSTYPE short
#endif
#include <stdio.h>

#ifndef __STDC__
#define const
#endif



#define YYFINAL         279
#define YYFLAG          -32768
#define YYNTBASE        67

#define YYTRANSLATE(x) ((unsigned)(x) <= 297 ? yytranslate[x] : 106)

static const char yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,    65,     2,     2,     2,    43,    30,     2,    60,
    61,    41,    39,    21,    40,    66,    42,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,    25,    64,    33,
    22,    34,    24,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
    62,     2,    63,    29,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,    58,    28,    59,    46,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     2,     3,     4,     5,
     6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
    16,    17,    18,    19,    20,    23,    26,    27,    31,    32,
    35,    36,    37,    38,    44,    45,    47,    48,    49,    50,
    51,    52,    53,    54,    55,    56,    57
};

#if YYDEBUG != 0
static const short yyrline[] = { 0,
    31,    33,    36,    38,    41,    43,    47,    51,    53,    56,
    58,    61,    63,    64,    65,    68,    70,    71,    72,    75,
    77,    80,    82,    83,    84,    85,    86,    89,    91,    94,
    96,    97,    98,    99,   100,   101,   104,   106,   109,   111,
   113,   115,   116,   117,   118,   119,   120,   121,   122,   125,
   127,   130,   132,   133,   136,   140,   142,   145,   147,   148,
   149,   152,   154,   157,   161,   163,   166,   168,   171,   175,
   177,   180,   182,   185,   189,   191,   192,   195,   197,   198,
   201,   205,   207,   210,   212,   213,   214,   215,   216,   217,
   218,   219,   220,   221,   222,   223,   224,   225,   226,   229,
   233,   237,   239,   242,   245,   246,   248,   249,   250,   252,
   253,   255,   257,   259,   261,   262,   264,   265,   266,   267,
   269,   271,   273,   275,   276,   278,   279,   280,   281,   282,
   283,   284,   285,   286,   287,   290,   292,   293,   294,   295,
   296,   297,   298,   299,   302,   304
};

static const char * const yytname[] = {     0,
"error","$illegal.","IF","ELSE","SWITCH","CASE","BREAK","FOR","WHILE","DO",
"CONTINUE","DEFAULT","GOTO","RETURN","NUM","SYMBOL","STRING","ATYPEDEF","STRUCTUNION","SCSPEC",
"','","'='","DEFOP","'?'","':'","OROR","ANDAND","'|'","'^'","'&'",
"EQ","NE","'<'","'>'","LE","GE","RR","LL","'+'","'-'",
"'*'","'/'","'%'","IND","ADDROF","'~'","PLPL","MIMI","INV","UNARY",
"SIZEOF","CAST","NOTZ","FCALL","ARRAY","RA","DOT","'{'","'}'","'('",
"')'","'['","']'","';'","'!'","'.'","program"
};
#endif

static const short yyr1[] = {     0,
    67,    67,    68,    68,    69,    69,    70,    71,    71,    72,
    72,    73,    73,    73,    73,    74,    74,    74,    74,    75,
    75,    76,    76,    76,    76,    76,    76,    77,    77,    78,
    78,    78,    78,    78,    78,    78,    79,    79,    80,    80,
    81,    81,    81,    81,    81,    81,    81,    81,    81,    82,
    82,    83,    83,    83,    84,    85,    85,    86,    86,    86,
    86,    87,    87,    88,    89,    89,    90,    90,    91,    92,
    92,    93,    93,    94,    95,    95,    95,    96,    96,    96,
    97,    98,    98,    99,    99,    99,    99,    99,    99,    99,
    99,    99,    99,    99,    99,    99,    99,    99,    99,   100,
   101,   102,   102,   103,   103,   103,   103,   103,   103,   103,
   103,   103,   103,   103,   103,   103,   103,   103,   103,   103,
   103,   103,   103,   103,   103,   103,   103,   103,   103,   103,
   103,   103,   103,   103,   103,   104,   104,   104,   104,   104,
   104,   104,   104,   104,   105,   105
};

static const short yyr2[] = {     0,
     0,     1,     1,     2,     1,     1,     2,     3,     2,     0,
     1,     4,     3,     3,     2,     1,     2,     2,     1,     1,
     3,     1,     4,     3,     2,     3,     4,     2,     1,     3,
     2,     1,     3,     2,     4,     3,     5,     4,     0,     1,
     1,     3,     3,     3,     3,     3,     3,     2,     3,     1,
     2,     2,     1,     1,     1,     1,     2,     1,     4,     5,
     2,     1,     2,     3,     1,     3,     1,     2,     3,     1,
     3,     1,     2,     3,     0,     1,     3,     1,     2,     4,
     2,     1,     3,     1,     3,     3,     2,     2,     3,     2,
     1,     3,     5,     3,     9,     5,     5,     4,     3,     1,
     3,     1,     3,     1,     3,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
     3,     3,     5,     3,     3,     2,     2,     2,     2,     4,
     2,     2,     2,     2,     2,     1,     1,     1,     3,     4,
     4,     1,     3,     3,     0,     1
};

static const short yydefact[] = {     1,
    22,    58,     0,    56,     0,     0,     2,     3,     5,     0,
    10,    55,    75,    54,    53,     6,    61,     0,    25,     0,
     4,     0,     7,     0,    39,     9,     0,    11,    67,    78,
     0,    76,     0,    57,    52,     0,     0,     0,    62,    26,
     0,   100,     0,     0,     0,     0,     0,     0,     0,     0,
   145,   138,   136,   137,     0,     0,     0,     0,     0,     0,
     0,    15,     0,    84,     0,    91,   142,     0,    75,     0,
    72,    50,     0,     0,   102,   104,    16,    24,    20,     0,
    19,    41,     0,     0,     0,    40,    70,     0,    68,    81,
     8,     0,    74,   136,     0,    79,     0,    65,     0,    59,
    63,   145,     0,     0,    88,   145,     0,     0,    87,     0,
     0,   146,     0,     0,   131,   133,   132,   134,   126,   128,
     0,     0,    29,     0,   135,    13,    51,    78,    14,     0,
    73,     0,     0,    90,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,   127,   129,     0,   145,     0,
     0,     0,    23,    32,     0,     0,    17,    18,    48,     0,
    27,     0,     0,     0,     0,     0,     0,     0,    69,    77,
     0,    82,    60,     0,    64,     0,    92,     0,     0,    94,
     0,    99,    89,    86,    85,     0,    53,     0,    32,     0,
    28,   139,    12,     0,   103,   125,   124,     0,   122,   121,
   113,   114,   112,   115,   116,   117,   118,   120,   119,   110,
   111,   105,   106,   109,   107,   108,   143,     0,     0,   144,
    21,    31,    34,     0,     0,     0,     0,    49,    47,    46,
    42,    43,    44,    45,    71,     0,    80,    66,   101,     0,
    98,   145,     0,    38,     0,   130,     0,     0,   140,   141,
    30,    36,    33,     0,    83,    93,     0,    96,    37,    97,
   123,    35,   145,     0,     0,    95,     0,     0,     0
};

static const short yydefgoto[] = {   277,
     7,     8,     9,    10,    26,    66,    79,    80,    11,   122,
   232,    67,    85,    86,    68,    12,    27,    14,    15,    38,
    39,    99,    28,    29,    88,    70,    16,    31,    32,    33,
   181,    72,    73,   103,    74,    75,    76,   113
};

static const short yypact[] = {   217,
-32768,-32768,    22,-32768,    29,    29,   217,-32768,-32768,   -36,
   172,-32768,    29,    57,-32768,-32768,   -18,   278,    38,   265,
-32768,   235,-32768,    34,    -1,-32768,    29,   278,-32768,   140,
    -2,-32768,   509,-32768,-32768,   278,    29,   -10,-32768,-32768,
   -14,-32768,    -1,   -22,    24,   -14,   487,    18,    65,    77,
   546,-32768,   113,-32768,   546,   546,   546,   546,   546,   546,
    79,-32768,   166,-32768,   546,-32768,-32768,   361,    29,   298,
-32768,-32768,    82,    14,   727,   218,-32768,-32768,   122,    91,
    32,-32768,    -1,    -1,    98,   376,    38,    67,-32768,-32768,
-32768,    29,-32768,-32768,   546,   727,   128,    38,    76,-32768,
-32768,   546,   487,   183,-32768,   546,   487,   161,-32768,   487,
   115,   152,   125,   487,   -35,   -35,   -35,   -35,   -35,   -35,
   278,   132,   109,   624,   -35,-32768,-32768,   106,-32768,   424,
-32768,   546,   546,-32768,   546,   546,   546,   546,   546,   546,
   546,   546,   546,   546,   546,   546,   546,   546,   546,   546,
   546,   546,   546,   546,   546,-32768,-32768,   185,   546,   546,
   188,   137,-32768,    32,    25,    -1,    38,   116,-32768,   282,
-32768,    -1,    -1,    -1,    -1,    -1,    -1,    29,-32768,-32768,
    15,   727,-32768,    29,-32768,   138,   201,   487,   145,-32768,
   -14,-32768,-32768,-32768,-32768,   150,   109,   546,   109,   103,
   116,-32768,-32768,   660,-32768,   727,   727,   700,   772,   793,
   813,   832,   850,   346,   346,   293,   293,   293,   293,   312,
   312,   356,   356,   -35,   -35,   -35,-32768,   155,   586,-32768,
-32768,   116,-32768,   362,   222,   158,    -1,-32768,   248,   248,
   -11,   -11,-32768,-32768,    38,   546,-32768,    38,-32768,   487,
-32768,   546,   165,-32768,   382,   -35,   487,   546,-32768,-32768,
-32768,-32768,-32768,   229,   727,-32768,   192,-32768,-32768,-32768,
   750,-32768,   546,   169,   487,-32768,   257,   272,-32768
};

static const short yypgoto[] = {-32768,
-32768,   266,-32768,-32768,   249,   281,-32768,   167,    10,-32768,
   -20,-32768,-32768,   -40,   232,    33,    11,-32768,     6,   301,
   -32,-32768,-32768,   314,-32768,-32768,   -15,-32768,   255,-32768,
-32768,   -47,-32768,   -42,   -34,   -31,-32768,  -101
};


#define YYLAST          898


static const short yytable[] = {   108,
   186,    96,   104,   107,   189,   101,    71,     2,     3,     4,
    13,   156,   157,    82,    19,    20,   112,    13,    92,    35,
   127,    22,    30,   115,   116,   117,   118,   119,   120,   176,
   177,   124,    69,   125,   133,   246,    87,    17,    83,    36,
     1,   105,   169,   170,     1,   102,    98,     1,   100,    77,
    37,     2,     3,     4,   131,   187,    81,   228,    84,   190,
   168,    93,   192,   182,   101,   164,   195,   112,    37,     5,
    37,   112,   164,   247,     2,     3,    34,   134,   128,    18,
    69,   109,   127,   106,   165,   233,   166,   178,     6,   110,
   167,   165,   111,   166,    78,   123,   184,    24,   205,    25,
   204,   128,   201,   206,   207,   208,   209,   210,   211,   212,
   213,   214,   215,   216,   217,   218,   219,   220,   221,   222,
   223,   224,   225,   226,   112,   235,   197,    90,   229,    37,
   179,   239,   240,   241,   242,   243,   244,   114,   121,   185,
   251,   132,   162,   199,   234,     2,     3,     4,   253,   199,
   267,   163,    77,   196,     2,     3,     4,     2,     3,     4,
   171,    90,   200,   233,   166,    24,   256,    25,   200,   191,
   166,   274,   133,    19,    20,   236,   255,   237,   193,   234,
    52,    94,    54,     2,     3,     4,   183,   245,   194,     2,
     3,     4,   198,   248,    81,    55,   264,   -10,   249,    24,
   227,    25,   266,   230,   250,    56,    57,   188,   252,   270,
   254,    58,    59,    60,   265,   259,    61,   112,   263,   172,
   173,   174,   175,   176,   177,    63,   271,   276,   268,   275,
    65,    24,     1,    25,     2,     3,     4,    41,   112,    42,
    43,    44,    45,    46,    47,    48,    49,    50,    51,    52,
    53,    54,     2,     3,     4,   273,   278,     5,   172,   173,
   174,   175,   176,   177,    55,   172,   173,   174,   175,   176,
   177,   279,    21,   158,    56,    57,     6,   159,    91,   160,
    58,    59,    60,   161,   262,    61,   174,   175,   176,   177,
    23,   272,    22,    62,    63,     2,     3,     4,    64,    65,
    41,   130,    42,    43,    44,    45,    46,    47,    48,    49,
    50,    51,    52,    53,    54,     2,     3,     4,   172,   173,
   174,   175,   176,   177,    24,    40,    25,    55,   231,   149,
   150,   151,   152,   153,   154,   155,    97,    56,    57,   156,
   157,    89,   238,    58,    59,    60,   180,     0,    61,     0,
   151,   152,   153,   154,   155,    22,   129,    63,   156,   157,
     0,    64,    65,    41,     0,    42,    43,    44,    45,    46,
    47,    48,    49,    50,    51,    52,    53,    54,   145,   146,
   147,   148,   149,   150,   151,   152,   153,   154,   155,     0,
    55,     0,   156,   157,     0,     0,   153,   154,   155,     0,
    56,    57,   156,   157,     0,     0,    58,    59,    60,     0,
     0,    61,   172,   173,   174,   175,   176,   177,    22,   126,
    63,   236,   261,   237,    64,    65,    41,     0,    42,    43,
    44,    45,    46,    47,    48,    49,    50,    51,    52,    53,
    54,   236,   269,   237,     0,     0,     0,     0,     0,     0,
     0,     0,     0,    55,     0,     0,     0,     0,     0,     0,
     0,     0,     0,    56,    57,     0,     0,     0,     0,    58,
    59,    60,     0,     0,    61,     0,     0,     0,     0,     0,
     0,    22,   203,    63,     0,     0,     0,    64,    65,    41,
     0,    42,    43,    44,    45,    46,    47,    48,    49,    50,
    51,    52,    53,    54,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,    55,     0,     0,     0,
     0,     0,     0,    52,    94,    54,    56,    57,     0,     0,
     0,     0,    58,    59,    60,     0,     0,    61,    55,     0,
     0,     0,     0,     0,    22,     0,    63,     0,    56,    57,
    64,    65,     0,     0,    58,    59,    60,     0,     0,    61,
    52,    94,    54,     0,     0,     0,    95,     0,    63,     0,
     0,     0,     0,    65,     0,    55,     0,     0,     0,     0,
     0,     0,     0,     0,     0,    56,    57,     0,     0,     0,
     0,    58,    59,    60,     0,     0,    61,     0,     0,     0,
     0,     0,     0,     0,     0,    63,     0,   135,   136,   137,
    65,   138,   139,   140,   141,   142,   143,   144,   145,   146,
   147,   148,   149,   150,   151,   152,   153,   154,   155,     0,
     0,     0,   156,   157,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,   135,   136,   137,   260,   138,
   139,   140,   141,   142,   143,   144,   145,   146,   147,   148,
   149,   150,   151,   152,   153,   154,   155,     0,     0,     0,
   156,   157,     0,     0,     0,     0,     0,     0,     0,     0,
     0,   135,   136,   137,   202,   138,   139,   140,   141,   142,
   143,   144,   145,   146,   147,   148,   149,   150,   151,   152,
   153,   154,   155,     0,     0,     0,   156,   157,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
   257,   135,   136,   137,   258,   138,   139,   140,   141,   142,
   143,   144,   145,   146,   147,   148,   149,   150,   151,   152,
   153,   154,   155,     0,     0,     0,   156,   157,   135,   136,
   137,     0,   138,   139,   140,   141,   142,   143,   144,   145,
   146,   147,   148,   149,   150,   151,   152,   153,   154,   155,
     0,     0,     0,   156,   157,   138,   139,   140,   141,   142,
   143,   144,   145,   146,   147,   148,   149,   150,   151,   152,
   153,   154,   155,     0,     0,     0,   156,   157,   139,   140,
   141,   142,   143,   144,   145,   146,   147,   148,   149,   150,
   151,   152,   153,   154,   155,     0,     0,     0,   156,   157,
   140,   141,   142,   143,   144,   145,   146,   147,   148,   149,
   150,   151,   152,   153,   154,   155,     0,     0,     0,   156,
   157,   141,   142,   143,   144,   145,   146,   147,   148,   149,
   150,   151,   152,   153,   154,   155,     0,     0,     0,   156,
   157,   142,   143,   144,   145,   146,   147,   148,   149,   150,
   151,   152,   153,   154,   155,     0,     0,     0,   156,   157,
   143,   144,   145,   146,   147,   148,   149,   150,   151,   152,
   153,   154,   155,     0,     0,     0,   156,   157
};

static const short yycheck[] = {    47,
   102,    33,    43,    46,   106,    38,    22,    18,    19,    20,
     0,    47,    48,    15,     5,     6,    51,     7,    21,    14,
    68,    58,    13,    55,    56,    57,    58,    59,    60,    41,
    42,    63,    22,    65,    21,    21,    27,    16,    40,    58,
    16,    64,    83,    84,    16,    60,    37,    16,    59,    16,
    18,    18,    19,    20,    70,   103,    24,   159,    60,   107,
    81,    64,   110,    95,    97,    41,   114,   102,    36,    41,
    38,   106,    41,    59,    18,    19,    20,    64,    69,    58,
    70,    64,   130,    60,    60,    61,    62,    21,    60,    25,
    81,    60,    16,    62,    61,    63,    21,    60,   133,    62,
   132,    92,   123,   135,   136,   137,   138,   139,   140,   141,
   142,   143,   144,   145,   146,   147,   148,   149,   150,   151,
   152,   153,   154,   155,   159,   166,   121,    22,   160,    97,
    64,   172,   173,   174,   175,   176,   177,    25,    60,    64,
   188,    60,    21,    41,   165,    18,    19,    20,   191,    41,
   252,    61,    16,   121,    18,    19,    20,    18,    19,    20,
    63,    22,    60,    61,    62,    60,   198,    62,    60,     9,
    62,   273,    21,   164,   165,    60,   197,    62,    64,   200,
    15,    16,    17,    18,    19,    20,    59,   178,    64,    18,
    19,    20,    61,   184,   162,    30,   237,    58,    61,    60,
    16,    62,   250,    16,     4,    40,    41,    25,    64,   257,
    61,    46,    47,    48,   246,    61,    51,   252,    61,    37,
    38,    39,    40,    41,    42,    60,   258,   275,    64,    61,
    65,    60,    16,    62,    18,    19,    20,     3,   273,     5,
     6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
    16,    17,    18,    19,    20,    64,     0,    41,    37,    38,
    39,    40,    41,    42,    30,    37,    38,    39,    40,    41,
    42,     0,     7,    56,    40,    41,    60,    60,    30,    62,
    46,    47,    48,    66,    63,    51,    39,    40,    41,    42,
    10,    63,    58,    59,    60,    18,    19,    20,    64,    65,
     3,    70,     5,     6,     7,     8,     9,    10,    11,    12,
    13,    14,    15,    16,    17,    18,    19,    20,    37,    38,
    39,    40,    41,    42,    60,    61,    62,    30,   162,    37,
    38,    39,    40,    41,    42,    43,    36,    40,    41,    47,
    48,    28,    61,    46,    47,    48,    92,    -1,    51,    -1,
    39,    40,    41,    42,    43,    58,    59,    60,    47,    48,
    -1,    64,    65,     3,    -1,     5,     6,     7,     8,     9,
    10,    11,    12,    13,    14,    15,    16,    17,    33,    34,
    35,    36,    37,    38,    39,    40,    41,    42,    43,    -1,
    30,    -1,    47,    48,    -1,    -1,    41,    42,    43,    -1,
    40,    41,    47,    48,    -1,    -1,    46,    47,    48,    -1,
    -1,    51,    37,    38,    39,    40,    41,    42,    58,    59,
    60,    60,    61,    62,    64,    65,     3,    -1,     5,     6,
     7,     8,     9,    10,    11,    12,    13,    14,    15,    16,
    17,    60,    61,    62,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    30,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    40,    41,    -1,    -1,    -1,    -1,    46,
    47,    48,    -1,    -1,    51,    -1,    -1,    -1,    -1,    -1,
    -1,    58,    59,    60,    -1,    -1,    -1,    64,    65,     3,
    -1,     5,     6,     7,     8,     9,    10,    11,    12,    13,
    14,    15,    16,    17,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,
    -1,    -1,    -1,    15,    16,    17,    40,    41,    -1,    -1,
    -1,    -1,    46,    47,    48,    -1,    -1,    51,    30,    -1,
    -1,    -1,    -1,    -1,    58,    -1,    60,    -1,    40,    41,
    64,    65,    -1,    -1,    46,    47,    48,    -1,    -1,    51,
    15,    16,    17,    -1,    -1,    -1,    58,    -1,    60,    -1,
    -1,    -1,    -1,    65,    -1,    30,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    40,    41,    -1,    -1,    -1,
    -1,    46,    47,    48,    -1,    -1,    51,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    60,    -1,    22,    23,    24,
    65,    26,    27,    28,    29,    30,    31,    32,    33,    34,
    35,    36,    37,    38,    39,    40,    41,    42,    43,    -1,
    -1,    -1,    47,    48,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    22,    23,    24,    63,    26,
    27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
    37,    38,    39,    40,    41,    42,    43,    -1,    -1,    -1,
    47,    48,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    22,    23,    24,    61,    26,    27,    28,    29,    30,
    31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
    41,    42,    43,    -1,    -1,    -1,    47,    48,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    61,    22,    23,    24,    25,    26,    27,    28,    29,    30,
    31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
    41,    42,    43,    -1,    -1,    -1,    47,    48,    22,    23,
    24,    -1,    26,    27,    28,    29,    30,    31,    32,    33,
    34,    35,    36,    37,    38,    39,    40,    41,    42,    43,
    -1,    -1,    -1,    47,    48,    26,    27,    28,    29,    30,
    31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
    41,    42,    43,    -1,    -1,    -1,    47,    48,    27,    28,
    29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
    39,    40,    41,    42,    43,    -1,    -1,    -1,    47,    48,
    28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
    38,    39,    40,    41,    42,    43,    -1,    -1,    -1,    47,
    48,    29,    30,    31,    32,    33,    34,    35,    36,    37,
    38,    39,    40,    41,    42,    43,    -1,    -1,    -1,    47,
    48,    30,    31,    32,    33,    34,    35,    36,    37,    38,
    39,    40,    41,    42,    43,    -1,    -1,    -1,    47,    48,
    31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
    41,    42,    43,    -1,    -1,    -1,    47,    48
};
#define YYPURE 1

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         -2
#define YYEOF           0
#define YYACCEPT        return(0)
#define YYABORT         return(1)
#define YYERROR         goto yyerrlab1

#define YYTERROR        1
#define YYERRCODE       256

#define YYLEX           yylex()

short   yychar;
YYSTYPE yylval;

short yynerrs;

#ifndef YYINITDEPTH
#define YYINITDEPTH 200
#endif

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 10000
#endif

short yyn;
YYSTYPE *yyvsp,yyval;
short *yyssp;
short *yyss;

short yyparse()
{
  register short yystate;
  short yyerrstatus;    /*  number of tokens to shift before error messages enabled */
  short yychar1;                /*  lookahead token as an internal (translated) token number */

  short yyssa[YYINITDEPTH];     /*  the state stack                     */
  YYSTYPE yyvsa[YYINITDEPTH];   /*  the semantic value stack            */

  YYSTYPE *yyvs;

#define YYPOPSTACK   (yyvsp--, yysp--)

  short yystacksize = YYINITDEPTH;

  short yylen;


  yyss = yyssa;
  yyvs = yyvsa;

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;             /* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.  */

  yyssp = yyss - 1;
  yyvsp = yyvs;

/* Push a new state, which is found in  yystate  .  */
/* In all cases, when you get here, the value and location stacks
   have just been pushed. so pushing a state here evens the stacks.  */
yynewstate:
  *++yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
printf("Ran out of stack, sucker!\n");
exit();
    }

 yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)              /* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;           /* Don't call YYLEX any more */

    }
  else
    {
      yychar1 = YYTRANSLATE(yychar);
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */


  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;

  /* count tokens shifted since error; after three, turn off error status.  */
  if (yyerrstatus) yyerrstatus--;

  yystate = yyn;
  goto yynewstate;

/* Do the default action for the current state.  */
yydefault:

  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;

/* Do a reduction.  yyn is the number of a rule to reduce with.  */
yyreduce:
  yylen = yyr2[yyn];
  yyval = yyvsp[1-yylen]; /* implement default value of the action */


  switch (yyn) {

case 6:
#line 43 "parse.y"
{dumptext(yyvsp[0]);
    break;}
case 7:
#line 48 "parse.y"
{outfunc(yyvsp[0]);
    break;}
case 8:
#line 52 "parse.y"
{funcstart(yyvsp[-1],yyvsp[-2]);freething(yyvsp[-2]);
    break;}
case 9:
#line 53 "parse.y"
{funcstart(yyvsp[-1],intthing);
    break;}
case 12:
#line 62 "parse.y"
{emitsub(yyvsp[-2]);emitsub(yyvsp[-1]);yyval=newstmt();
    break;}
case 13:
#line 63 "parse.y"
{yyval=yyvsp[-1];
    break;}
case 14:
#line 64 "parse.y"
{yyval=yyvsp[-1];
    break;}
case 15:
#line 65 "parse.y"
{yyval=0;
    break;}
case 16:
#line 69 "parse.y"
{newparm(yyvsp[0]);
    break;}
case 17:
#line 70 "parse.y"
{ansidec(yyvsp[0],yyvsp[-1]);
    break;}
case 18:
#line 71 "parse.y"
{freething(yyvsp[-1]);freething(yyvsp[0]);
    break;}
case 19:
#line 72 "parse.y"
{freething(yyvsp[0]);
    break;}
case 22:
#line 81 "parse.y"
{yyval=newdeclid(yyvsp[0]);
    break;}
case 23:
#line 82 "parse.y"
{checkparmok(yyvsp[-3]);append(yyvsp[-3],FUNCTIONRET);
    break;}
case 24:
#line 83 "parse.y"
{append(yyvsp[-2],FUNCTIONRET);
    break;}
case 25:
#line 84 "parse.y"
{yyval=yyvsp[0];append(yyvsp[0],POINTERTO);
    break;}
case 26:
#line 85 "parse.y"
{yyval=yyvsp[-1];
    break;}
case 27:
#line 86 "parse.y"
{appendarray(yyvsp[-3],yyvsp[-1]);
    break;}
case 28:
#line 90 "parse.y"
{yyval=appendthing(yyvsp[0],yyvsp[-1]);freething(yyvsp[-1]);
    break;}
case 29:
#line 91 "parse.y"
{yyval=appendthing(alloccast(),yyvsp[0]);freething(yyvsp[0]);
    break;}
case 30:
#line 95 "parse.y"
{yyval=yyvsp[-1];
    break;}
case 31:
#line 96 "parse.y"
{yyval=append(yyvsp[0],POINTERTO);
    break;}
case 32:
#line 97 "parse.y"
{yyval=append(alloccast(),POINTERTO);
    break;}
case 33:
#line 98 "parse.y"
{yyval=append(yyvsp[-2],FUNCTIONRET);
    break;}
case 34:
#line 99 "parse.y"
{yyval=append(alloccast(),FUNCTIONRET);
    break;}
case 35:
#line 100 "parse.y"
{yyval=appendarray(yyvsp[-3],yyvsp[-1]);
    break;}
case 36:
#line 101 "parse.y"
{yyval=appendarray(alloccast(),yyvsp[-1]);
    break;}
case 37:
#line 105 "parse.y"
{yyval=appendthing(yyvsp[-1],yyvsp[-2]);
    break;}
case 38:
#line 106 "parse.y"
{yyval=yyvsp[-1];
    break;}
case 39:
#line 110 "parse.y"
{yyval=0;
    break;}
case 41:
#line 114 "parse.y"
{yyval=((thingptr)yyvsp[0])->thingvalue;freething(yyvsp[0]);
    break;}
case 42:
#line 115 "parse.y"
{yyval=yyvsp[-2]+yyvsp[0];
    break;}
case 43:
#line 116 "parse.y"
{yyval=yyvsp[-2]-yyvsp[0];
    break;}
case 44:
#line 117 "parse.y"
{yyval=yyvsp[-2]*yyvsp[0];
    break;}
case 45:
#line 118 "parse.y"
{yyval=yyvsp[-2]/yyvsp[0];
    break;}
case 46:
#line 119 "parse.y"
{yyval=yyvsp[-2]<<yyvsp[0];
    break;}
case 47:
#line 120 "parse.y"
{yyval=yyvsp[-2]>>yyvsp[0];
    break;}
case 48:
#line 121 "parse.y"
{yyval=-yyvsp[0];
    break;}
case 49:
#line 122 "parse.y"
{yyval=yyvsp[-1];
    break;}
case 51:
#line 127 "parse.y"
{emitsub(yyvsp[-1]);emitsub(yyvsp[0]);yyval=newstmt();
    break;}
case 52:
#line 131 "parse.y"
{yyval=dupfix(yyvsp[0],yyvsp[-1]);
    break;}
case 53:
#line 132 "parse.y"
{yyval=dupfix(yyvsp[0],0);
    break;}
case 54:
#line 133 "parse.y"
{yyval=dupfix(intthing,yyvsp[0]);
    break;}
case 55:
#line 137 "parse.y"
{vartype=yyvsp[0];
    break;}
case 57:
#line 142 "parse.y"
{yyval=yyvsp[-1] | yyvsp[0];
    break;}
case 59:
#line 147 "parse.y"
{yyval=makestruct(structid(NULL),yyvsp[-1],yyvsp[-3]);
    break;}
case 60:
#line 148 "parse.y"
{yyval=makestruct(structid(yyvsp[-3]),yyvsp[-1],yyvsp[-4]);
    break;}
case 61:
#line 149 "parse.y"
{yyval=structid(yyvsp[0]);
    break;}
case 63:
#line 154 "parse.y"
{addtail(yyvsp[-1],yyvsp[0]);
    break;}
case 64:
#line 158 "parse.y"
{yyval=appendlist(yyvsp[-1],yyvsp[-2]);freething(yyvsp[-2]);
    break;}
case 66:
#line 163 "parse.y"
{addtail(yyvsp[-2],yyvsp[0]);
    break;}
case 69:
#line 172 "parse.y"
{freething(yyvsp[-2]);
    break;}
case 70:
#line 176 "parse.y"
{((thingptr)yyvsp[0])->thingflags |= THINGOUTSIDE;dodeclare(yyvsp[0]);
    break;}
case 71:
#line 177 "parse.y"
{((thingptr)yyvsp[-2])->thingflags |= THINGOUTSIDE;dodeclare(yyvsp[0]);
    break;}
case 73:
#line 182 "parse.y"
{emitsub(yyvsp[-1]);emitsub(yyvsp[0]);yyval=newstmt();
    break;}
case 74:
#line 186 "parse.y"
{endid();freething(yyvsp[-2]);yyval=newstmt();
    break;}
case 75:
#line 190 "parse.y"
{yyval=0;
    break;}
case 78:
#line 196 "parse.y"
{dodeclare(yyvsp[0]);
    break;}
case 79:
#line 197 "parse.y"
{handleinit(yyvsp[0],0);
    break;}
case 81:
#line 202 "parse.y"
{dodeclare(yyvsp[-1]);
    break;}
case 82:
#line 206 "parse.y"
{handleinit(yyvsp[0],1);
    break;}
case 83:
#line 207 "parse.y"
{handleinit(yyvsp[0],1);
    break;}
case 84:
#line 211 "parse.y"
{yyval=0;
    break;}
case 85:
#line 212 "parse.y"
{dolabel(yyvsp[-2],yyvsp[0]);yyval=newstmt();
    break;}
case 86:
#line 213 "parse.y"
{doreturn(yyvsp[-1]);yyval=newstmt();
    break;}
case 87:
#line 214 "parse.y"
{docont();yyval=newstmt();
    break;}
case 88:
#line 215 "parse.y"
{dobreak();yyval=newstmt();
    break;}
case 89:
#line 216 "parse.y"
{dogoto(yyvsp[-1]);yyval=newstmt();
    break;}
case 90:
#line 217 "parse.y"
{freething(subexpr(yyvsp[-1],0));yyval=newstmt();
    break;}
case 92:
#line 219 "parse.y"
{doif(yyvsp[-1],yyvsp[0]);yyval=newstmt();
    break;}
case 93:
#line 220 "parse.y"
{doifelse(yyvsp[-3],yyvsp[-2],yyvsp[0]);yyval=newstmt();
    break;}
case 94:
#line 221 "parse.y"
{dowhile(yyvsp[-1],yyvsp[0]);yyval=newstmt();
    break;}
case 95:
#line 222 "parse.y"
{dofor(yyvsp[-6],yyvsp[-4],yyvsp[-2],yyvsp[0]);yyval=newstmt();
    break;}
case 96:
#line 223 "parse.y"
{dodowhile(yyvsp[-3],yyvsp[-1]);yyval=newstmt();
    break;}
case 97:
#line 224 "parse.y"
{doswitch(yyvsp[-2],yyvsp[0]);yyval=newstmt();
    break;}
case 98:
#line 225 "parse.y"
{docase((int)yyvsp[-2],yyvsp[0]);yyval=newstmt();
    break;}
case 99:
#line 226 "parse.y"
{dodefault(yyvsp[0]);yyval=newstmt();
    break;}
case 100:
#line 230 "parse.y"
{newswitch();
    break;}
case 101:
#line 234 "parse.y"
{yyval=yyvsp[-1];
    break;}
case 103:
#line 239 "parse.y"
{yyval=enode2(ENCOMMA,yyvsp[-2],yyvsp[0]);
    break;}
case 105:
#line 245 "parse.y"
{yyval = enode2(ENADD,yyvsp[-2],yyvsp[0]);
    break;}
case 106:
#line 246 "parse.y"
{yyval = enode2(ENSUB,yyvsp[-2],yyvsp[0]);
    break;}
case 107:
#line 248 "parse.y"
{yyval = enode2(ENDIV,yyvsp[-2],yyvsp[0]);
    break;}
case 108:
#line 249 "parse.y"
{yyval = enode2(ENMOD,yyvsp[-2],yyvsp[0]);
    break;}
case 109:
#line 250 "parse.y"
{yyval = enode2(ENMUL,yyvsp[-2],yyvsp[0]);
    break;}
case 110:
#line 252 "parse.y"
{yyval = enode2(ENRR,yyvsp[-2],yyvsp[0]);
    break;}
case 111:
#line 253 "parse.y"
{yyval = enode2(ENLL,yyvsp[-2],yyvsp[0]);
    break;}
case 112:
#line 255 "parse.y"
{yyval = enode2(ENAND,yyvsp[-2],yyvsp[0]);
    break;}
case 113:
#line 257 "parse.y"
{yyval = enode2(ENOR,yyvsp[-2],yyvsp[0]);
    break;}
case 114:
#line 259 "parse.y"
{yyval = enode2(ENXOR,yyvsp[-2],yyvsp[0]);
    break;}
case 115:
#line 261 "parse.y"
{yyval = enode2(ENEQ,yyvsp[-2],yyvsp[0]);
    break;}
case 116:
#line 262 "parse.y"
{yyval = enode2(ENNE,yyvsp[-2],yyvsp[0]);
    break;}
case 117:
#line 264 "parse.y"
{yyval = enode2(ENLT,yyvsp[-2],yyvsp[0]);
    break;}
case 118:
#line 265 "parse.y"
{yyval = enode2(ENGT,yyvsp[-2],yyvsp[0]);
    break;}
case 119:
#line 266 "parse.y"
{yyval = enode2(ENGE,yyvsp[-2],yyvsp[0]);
    break;}
case 120:
#line 267 "parse.y"
{yyval = enode2(ENLE,yyvsp[-2],yyvsp[0]);
    break;}
case 121:
#line 269 "parse.y"
{yyval = enode2(ENANDAND,yyvsp[-2],yyvsp[0]);
    break;}
case 122:
#line 271 "parse.y"
{yyval = enode2(ENOROR,yyvsp[-2],yyvsp[0]);
    break;}
case 123:
#line 273 "parse.y"
{yyval=enode3(ENQC,yyvsp[-4],yyvsp[-2],yyvsp[0]);
    break;}
case 124:
#line 275 "parse.y"
{yyval=enode2((int)(yyvsp[-1]),yyvsp[-2],yyvsp[0]);
    break;}
case 125:
#line 276 "parse.y"
{yyval=enode2(ENDEF,yyvsp[-2],yyvsp[0]);
    break;}
case 126:
#line 278 "parse.y"
{yyval=enode1(ENPREINC,yyvsp[0]);
    break;}
case 127:
#line 279 "parse.y"
{yyval=enode1(ENPOSTINC,yyvsp[-1]);
    break;}
case 128:
#line 280 "parse.y"
{yyval=enode1(ENPREDEC,yyvsp[0]);
    break;}
case 129:
#line 281 "parse.y"
{yyval=enode1(ENPOSTDEC,yyvsp[-1]);
    break;}
case 130:
#line 282 "parse.y"
{yyval=enode2(ENCAST,yyvsp[0],yyvsp[-2]);
    break;}
case 131:
#line 283 "parse.y"
{yyval=enode1(ENADDROF,yyvsp[0]);
    break;}
case 132:
#line 284 "parse.y"
{yyval = enode1(ENIND,yyvsp[0]);
    break;}
case 133:
#line 285 "parse.y"
{yyval=enode1(ENUNARY,yyvsp[0]);
    break;}
case 134:
#line 286 "parse.y"
{yyval=enode1(ENNOT,yyvsp[0]);
    break;}
case 135:
#line 287 "parse.y"
{yyval=enode1(ENNOTZ,yyvsp[0]);
    break;}
case 136:
#line 291 "parse.y"
{yyval=enode1(ENTHING,newid(yyvsp[0]));
    break;}
case 137:
#line 292 "parse.y"
{yyval=enode1(ENTHING,yyvsp[0]);
    break;}
case 138:
#line 293 "parse.y"
{yyval=enode1(ENTHING,yyvsp[0]);
    break;}
case 139:
#line 294 "parse.y"
{yyval=enode1(ENPAREN,yyvsp[-1]);
    break;}
case 140:
#line 295 "parse.y"
{yyval=enode2(ENFCALL,yyvsp[-3],yyvsp[-1]);
    break;}
case 141:
#line 296 "parse.y"
{yyval=enode2(ENARRAY,yyvsp[-3],yyvsp[-1]);
    break;}
case 142:
#line 297 "parse.y"
{yyval=enode1(ENTHING,dosizeof(yyvsp[0]));
    break;}
case 143:
#line 298 "parse.y"
{yyval = enode2(ENISREF,yyvsp[-2],findmember(yyvsp[0]));
    break;}
case 144:
#line 299 "parse.y"
{yyval = enode2(ENSREF,yyvsp[-2],findmember(yyvsp[0]));
    break;}
case 145:
#line 303 "parse.y"
{yyval=0;
    break;}
}
   /* the action file gets copied in in place of this dollarsign */

  yyvsp -= yylen;
  yyssp -= yylen;

  *++yyvsp = yyval;

  /* Now "shift" the result of the reduction.
     Determine what state that goes to,
     based on the state we popped back to
     and the rule number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;

yyerrlab:   /* here on detecting error */

  if (! yyerrstatus)
    /* If not already recovering from an error, report this error.  */
    {
	++yynerrs;
	yyerror("parse error");
    }

yyerrlab1:   /* here on error raised explicitly by an action */

  if (yyerrstatus == 3)
    {
      /* if just tried and failed to reuse lookahead token after an error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYABORT;

      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token
     after shifting the error token.  */

  yyerrstatus = 3;              /* Each real token shifted decrements this */

  goto yyerrhandle;

yyerrdefault:  /* current state does not do anything special for the error token. */

yyerrpop:   /* pop the current state because it cannot handle the error token */

  if (yyssp == yyss) YYABORT;
  yyvsp--;
  yystate = *--yyssp;

yyerrhandle:

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;

  yystate = yyn;
  goto yynewstate;
}
#line 307 "parse.y"


struct kw keywords[]={
"auto",SCSPEC,THINGAUTO,
"break",BREAK,0,
"case",CASE,0,
"continue",CONTINUE,0,
"default",DEFAULT,0,
"do",DO,0,
"else",ELSE,0,
"extern",SCSPEC,THINGEXTERN,
"for",FOR,0,
"goto",GOTO,0,
"if",IF,0,
"label",SCSPEC,THINGLABEL,
"register",SCSPEC,THINGFLREGISTER,
"return",RETURN,0,
"sizeof",SIZEOF,0,
"static",SCSPEC,THINGSTATIC,
"struct",STRUCTUNION,1,
"switch",SWITCH,0,
"typedef",SCSPEC,THINGTYPEDEF,
"union",STRUCTUNION,0,
"unsigned",SCSPEC,THINGUNSIGNED,
"while",WHILE,0,
0,0
};

short skipwhite()
{
short ch;
	for(;;)
	{
		while((ch=take()) && ISWHITE(ch));
		if( (ch!='/' || at()!='*') && (ch!='/' || at()!='/') )
			break;
		preok=0;
		if(at()=='*')
		for(;;)
		{
			ch=take();
			if(ch=='*' && at()=='/') {take();break;}
		}
		else
		for(;;)
		{
			ch=take();
			if(ch==10) {break;}
		}

		preok=1;
	}
	return ch;
}

char *symadvance;
short token(ch2)
char ch2;
{
short ch;
char *p;
	if(symtextpntr>symtexttop) newsymtextblock();
	p=symtextpntr;
	*p++=ch2;
	while(isalpha(ch=at()) || isdigit(ch) || ch=='_') *p++=take();
	*p++=0;
	symadvance=p;
}

skipcr()
{
	while(at()!=10) take();
}

getoct()
{
short val;
	val=0;
	while(isdigit(at())) {val<<=3;val+=take()-'0';}
	return val;
}

yylex()
{
short ch;
short ch2;
char *p;
symptr asym;
stringptr astring;
thingptr athing;
long val;
char str[STRINGMAX];
char islong=0;
struct kw *akw;

top:
	ch=skipwhite();
	ch2=at();
	switch(ch)
	{
	case 0: return -1;
	case '0': case '1': case '2': case '3': case '4':
	case '5': case '6': case '7': case '8': case '9':
		if(ch=='0' && ch2=='x')
		{
			val=0;
			take();
			while(isdigit(ch=tolower(at())) || ch>='a' && ch<='f')
			{
				val<<=4;
				val+=ch<'a' ? ch-'0' : ch-'a'+10;
				take();
			}
		} else if(ch=='0')
		{
			val=0;
			while((ch=at())>='0' && ch<='7') {val<<=3;val+=ch-'0';take();}
		} else
		{
			val=ch-'0';
			while(isdigit(ch=at())) {val*=10;val+=ch-'0';take();}
		}
		if(ch=='l' || ch=='L') {take();islong=1;} //casting I think...
		//if(ch=='i' || ch=='I') {take();islong=1;} //I/ints?
		
aconst:
		athing=allocthing();
		athing->thingtype=THINGCONST;
		athing->thingvalue=val;
		yylval=athing;
		if(islong)
			*athing->thinginfo=TYPELONG;
		else
		{
			*athing->thinginfo=TYPESHORT;
			if(val<-0x8000 || val>0xffff) warn("Numeric constant overflow");
		}
		return NUM;
	case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g': case 'h': case 'i':
	case 'j': case 'k': case 'l': case 'm': case 'n': case 'o': case 'p': case 'q': case 'r':
	case 's': case 't': case 'u': case 'v': case 'w': case 'x': case 'y': case 'z': case '_':
	case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G': case 'H': case 'I':
	case 'J': case 'K': case 'L': case 'M': case 'N': case 'O': case 'P': case 'Q': case 'R':
	case 'S': case 'T': case 'U': case 'V': case 'W': case 'X': case 'Y': case 'Z':
		token(ch);
		if(akw=findkeyword(symtextpntr))
		{
			yylval=akw->kwyylval;
			return akw->kwval;
		} else if(asym=finddef(symtextpntr))
		{
			newmacro(asym->symthing);
			goto top;
		} else if(yylval=findtypedef(symtextpntr))
			return ATYPEDEF;
		yylval=symtextpntr;
		symtextpntr=symadvance;
		return SYMBOL;
	case '\'':
		if(ch2=='\\')
		{
			take();
			ch=take();
			if(ch=='t') val=9;
			else if(ch=='n') val=10;
			else if(ch=='r') val=13;
			else if(ch=='0')
				val=getoct();
			else val=ch;
		} else
			val=take();
		ch=at();
		if(ch!='\'')
			error("Character constant error");
		else
			take();
		goto aconst;
	case '"':
		athing=allocthing();
		if(symtextpntr>symtexttop) newsymtextblock();
		p=symtextpntr;
		sprintf(symtextpntr,"%c%d",LABELCHAR,allocsurelabel());
		symtextpntr+=strlen(symtextpntr)+1;
		athing->thingsym=asym=newsym(p);
		athing->thingflags|=THINGINTERNAL;
		athing->thingtype=THINGVARIABLE;

		if(symtextpntr>symtexttop) newsymtextblock();
		p=symtextpntr;

		val=1;
		while()
		{
			ch=take();
			if(ch=='"') break;
			if(ch=='\\')
			{
				ch=take();
				if(ch=='\n') continue;
				if(ch=='n') ch='\n';
				else if(ch=='t') ch='\t';
				else if(ch=='r') ch=13;
				else if(ch=='0') ch=getoct();
			} else if(ch=='\n')
			{
				error("Missing second \" in string constant");
				break;
			}
			*symtextpntr++=ch;val++;if(val==STRINGMAX) critical("String too long");
		}
		*symtextpntr++=0;
		astring=allocstring();
		if(!firststring)
			firststring=astring;
		else
			laststring->stringnext=astring;
		laststring=astring;
		astring->stringnext=NULL;
		astring->stringsym=asym;
		astring->stringtext=p;
		appendarray(athing,val);
		append(athing,TYPECHAR);
		yylval=athing;
		return STRING;
	case '=': if(ch2=='=') {take();return EQ;}
		break;
	case '!': if(ch2=='=') {take();return NE;}
		break;
	case '-': if(ch2=='-') {take();return MIMI;}
		else if(ch2=='>') {take();return RA;}
		else if(ch2=='=') {take();yylval=ENSUBEQ;return DEFOP;}
		break;
	case '+': if(ch2=='+') {take();return PLPL;}
		else if(ch2=='=') {take();yylval=ENADDEQ;return DEFOP;}
		break;
	case '>': if(ch2=='=') {take();return GE;}
		else if(ch2=='>')
		{
			take();
			if(at()=='=')
				{take();yylval=ENRREQ;return DEFOP;}
			else return RR;
		}
		break;
	case '<': if(ch2=='=') {take();return LE;}
		else if(ch2=='<')
		{
			take();
			if(at()=='=')
				{take();yylval=ENLLEQ;return DEFOP;}
			else return LL;
		}
		break;
	case '&': if(ch2=='&') {take();return ANDAND;}
		else if(ch2=='=') {take();yylval=ENANDEQ; return DEFOP;}
		break;
	case '|': if(ch2=='|') {take();return OROR;}
		else if(ch2=='=') {take();yylval=ENOREQ;return DEFOP;}
		break;
	case '^': if(ch2=='=') {take();yylval=ENXOREQ;return DEFOP;}
		break;
	case '*': if(ch2=='=') {take();yylval=ENMULEQ;return DEFOP;}
		break;
	case '/': if(ch2=='=') {take();yylval=ENDIVEQ;return DEFOP;}
		break;
	case '%': if(ch2=='=') {take();yylval=ENMODEQ;return DEFOP;}
		break;
	default:
		break;
	}
	return ch;
}
yyerror(msg)
char *msg;
{
	critical(msg);
}
