%{
// -----------------------------
// Arquivo do Bison (parser)
// -----------------------------
// Este arquivo descreve a gramática da linguagem FOCA e, junto com as ações
// semânticas (blocos { ... }), gera uma "tradução" (string) que vira código C.
//
// Estrutura típica do .y:
// 1) Prologue %{ ... %}  -> código C/C++ copiado para o arquivo gerado (y.tab.c)
// 2) Declarações Bison    -> %token, %left, %start, etc.
// 3) Gramática            -> regras e ações semânticas
// 4) Epilogue (após %%)   -> mais código C/C++ copiado ao final do y.tab.c

#include <iostream>
#include <string>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
int linha = 1;
string codigo_gerado;

struct atributos
{
	string label;
	string traducao;
};

int yylex(void);
void yyerror(string);
string gentempcode();
string gen_temp_declarations();
%}

%token TK_NUM

%start S

%left '+' '-'
%left '*' '/'


%%

S 			: E
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";

				codigo_gerado += gen_temp_declarations();

				codigo_gerado += $1.traducao;

				codigo_gerado += "\treturn 0;"
							"\n}\n";
			}
			;

E 			: E '+' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " / " + $3.label + ";\n";	
			}
			| TK_NUM
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

// TODO: Fazer essa função declarar corretamente variáveis que não são do tipo int.
string gen_temp_declarations()
{
	string declarations;
	for (int i = 1; i <= var_temp_qnt; i++)
		declarations += "\tint t" + to_string(i) + ";\n";
	if (var_temp_qnt > 0)
		declarations += "\n";
	return declarations;
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0)
		cout << codigo_gerado;

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
