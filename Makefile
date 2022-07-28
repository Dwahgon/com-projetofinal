PROJECTNAME=compilador-projetofinal

SRCDIR=./src
OBJDIR=./objs
BINDIR=./bin
EXMDIR=./examples

C=gcc
CFLAGS=-g -c -lm -Wall -I$(SRCDIR)
LDFLAGS=-g -Wall -lm -I$(SRCDIR)
BISON=bison
BISONFLAGS=-d -g -Wall
FLEX=flex
FLEXFLAGS=--noyywrap --nounput
JAVA=java
JASMIN=./jasmin/jasmin.jar

TARGET=$(EXMDIR)/teste.txt
TARGET_J=$(addsuffix .j,$(addprefix $(OBJDIR)/,$(notdir $(basename $(TARGET)))))
TARGET_CLASS=$(subst .j,.class,$(subst $(OBJDIR),$(BINDIR), $(TARGET_J)))

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

compile_and_assemble: all $(TARGET_CLASS)

$(TARGET_CLASS): $(TARGET_J)
	$(JAVA) -jar $(JASMIN) -d $(BINDIR) $(TARGET_J)

$(TARGET_J): $(TARGET)
	$(BINDIR)/$(PROJECTNAME) $(TARGET) $(TARGET_J)

.PHONY: all clean compile_and_assemble
