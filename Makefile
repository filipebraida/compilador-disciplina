all: 	
		clear
		lex lexico.l
		yacc -d sintatico.y
		g++ -o glf y.tab.c -ll

		./glf < exemplo.foca

debug:
		clear
		lex lexico.l
		yacc -d sintatico.y -Wcounterexamples
		g++ -o glf y.tab.c -ll

		./glf < exemplo.foca

clean:
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c
	rm glf