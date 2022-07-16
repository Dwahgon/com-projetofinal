PROJECTNAME=compilador-projetofinal

SRCDIR=./src
OBJDIR=./objs
BINDIR=./bin

C=gcc
CFLAGS=-g -c -lm -Wall -I$(SRCDIR)
LDFLAGS=-g -Wall -lm -I$(SRCDIR)
BISON=bison
BISONFLAGS=-d -g -Wall
FLEX=flex
FLEXFLAGS=--noyywrap --nounput

CSRCS=$(wildcard $(SRCDIR)/*.c)
CSRCOBJS=$(subst .c,.o,$(subst $(SRCDIR),$(OBJDIR),$(CSRCS)))

RM=rm -rf

all: bindir objdir $(PROJECTNAME)

# Link all files 
$(PROJECTNAME): $(OBJDIR)/sin.o $(OBJDIR)/lex.o $(CSRCOBJS)
	$(C) $^ $(LDFLAGS) -o $(BINDIR)/$@

# Compile source files
$(OBJDIR)/%.o: $(SRCDIR)/%.c $(SRCDIR)/%.h
	$(C) $< $(CFLAGS) -o $@

## Syntax analyzer
# Compile syntax analyzer
$(OBJDIR)/sin.o: $(OBJDIR)/analisador_sintatico.tab.c $(OBJDIR)/analisador_sintatico.tab.h
	$(C) $< $(CFLAGS) -o $@

# Run bison on syntax analyzer
$(OBJDIR)/analisador_sintatico.tab.c: $(SRCDIR)/analisador_sintatico.y
	$(BISON) $< $(BISONFLAGS) -o $@

## Lexical analyzer
# Compile lexical analyzer
$(OBJDIR)/lex.o: $(OBJDIR)/lex.yy.c
	$(C) $< $(CFLAGS) -o $@

# Run flex on lexical analyzer
$(OBJDIR)/lex.yy.c: $(SRCDIR)/analisador_lexico.lex
	$(FLEX) $(FLEXFLAGS) -o $@ $<


# Create dirs
bindir:
	@ mkdir -p $(BINDIR)

objdir:
	@ mkdir -p $(OBJDIR)

# Clean command
clean:
	@ $(RM) $(OBJDIR) $(BINDIR)

.PHONY: all clean