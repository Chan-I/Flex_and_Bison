
CC=gcc -g -O0
main:test.o

test.c:test.l
	flex $^

mem:
	valgrind --leak-check=full \
		--track-origins=yes \
		--leak-check=full \
		--show-leak-kinds=all ./main 

.phony:clean mem
clean:
	rm -rf test.[ch] main *.o
