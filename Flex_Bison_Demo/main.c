#include "module.h"

int main(int argc, char **argv)
{

	module *mod;
	int i, res;
#if 0
	mod = new_module_from_string("(add 1 2 (\"test\" 3 4) 5)");
	res = parse_module(mod);
	delete_module(mod);
	return res;

	if (argc == 1)
	{
		mod = new_module_from_stdin();
		return parse_module(mod);
	}

	for (i = 1; i < argc; i++)
	{
		mod = new_module_from_file(argv[i]);
		res = parse_module(mod);
		if (res != 0)
		{
			return res;
		}
	}
#else
	char *cypher = "(add 1 2 (\"test\" 3 4) ( 5)";
	mod = raw_parser(cypher);
	if (!mod->yyresult)
	{
		printf("success!\n");
		print_node_sexp(mod->root);
	}
	else
	{
		exit(0);
	}
	delete_module(mod);
#endif
	return 0;
}
