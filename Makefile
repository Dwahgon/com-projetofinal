PROJECTNAME=compilador-projetofinal

SRCDIR=./src
OBJDIR=./objs
BINDIR=./bin

C=gcc
CFLAGS=-g -c -lm -Wall
LDFLAGS=-g -Wall -lm
BISON=bison
BISONFLAGS=-d -g -Wall
FLEX=flex
FLEXFLAGS=--noyywrap --nounput

RM=rm -rf

all: bindir objdir cpheaders $(PROJECTNAME)

$(PROJECTNAME): $(OBJDIR)/sin.o $(OBJDIR)/lex.o $(OBJDIR)/cl.o #$(OBJDIR)/ts.o 
	$(C) $^ $(LDFLAGS) -o $(BINDIR)/$@

$(OBJDIR)/sin.o: $(OBJDIR)/analisador_sintatico.tab.c $(OBJDIR)/analisador_sintatico.tab.h
	$(C) $< $(CFLAGS) -o $@

$(OBJDIR)/analisador_sintatico.tab.c: $(SRCDIR)/analisador_sintatico.y
	$(BISON) $< $(BISONFLAGS) -o $@

$(OBJDIR)/lex.o: $(OBJDIR)/lex.yy.c
	$(C) $< $(CFLAGS) -o $@

$(OBJDIR)/lex.yy.c: $(SRCDIR)/analisador_lexico.lex
	$(FLEX) $(FLEXFLAGS) -o $@ $<

$(OBJDIR)/cl.o: $(SRCDIR)/contador_linha.c $(SRCDIR)/contador_linha.h
	$(C) $< $(CFLAGS) -o $@

# $(OBJDIR)/ts.o: $(SRCDIR)/tabela_simbolos.c $(SRCDIR)/tabela_simbolos.h
# 	$(C) $< $(CFLAGS) -o $@

bindir:
	@ mkdir -p $(BINDIR)

objdir:
	@ mkdir -p $(OBJDIR)

cpheaders:
	@ cp $(SRCDIR)/*.h -t $(OBJDIR)

clean:
	@ $(RM) $(OBJDIR) $(BINDIR)

.PHONY: all clean