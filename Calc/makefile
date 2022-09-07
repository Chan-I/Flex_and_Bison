#
# makefile for ccalc
#
OBJS += ccalc.o cmath.o lex.o parse.o

CC:=gcc -g -O0
# rules
%.c: %.y
	bison -vd -o $(@:%.o=%.d) $<

%.c: %.l
	flex -b -CF -p -p -o $(@:%.o=%.d) $<

# dependencies
ccalc: parse.c lex.c parse.h $(OBJS)
	@echo gcc -g -O0 -o ccalc $(OBJS)
	@gcc -g -O0 -o ccalc $(OBJS)
	@echo ' '

# source
ccalc.o: ccalc.c parse.h ccalc.h

cmath.o: cmath.c parse.h ccalc.h

lex.o: lex.c parse.h ccalc.h

parse.o: parse.c parse.h ccalc.h

parse.c: parse.y

lex.c: lex.l


.phony:clean
clean:
	rm -rf $(OBJS) *.o lex.[ch] parse.[ch] ccalc

