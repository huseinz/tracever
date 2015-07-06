//automata node definition

typedef enum {
	AND_N,
	OR_N,
	TRUE_N,
	GLOBAL_N,
	FUTURE_N,
	UNTILA_N,
	UNTILB_N,
	NEXT_N,
	IDENT_N,
	NOT_N,
	IMPLIES_N
}nodetype_t;

typedef struct Automata{
	
	nodetype_t nodetype;
	int 	   var;
	struct Automata* left;
	struct Automata* right;

}Automata;

Automata* create_node(nodetype_t nodetype, int var, Automata* left, Automata* right){

	Automata* newnode = malloc(sizeof(Automata));
	
	if( !newnode )
		//throw some fatal error
		return NULL;
	
	newnode->nodetype = nodetype;
	newnode->var = var;
	newnode->left = left;
	newnode->right = right;

	return newnode;
}

void delete_automata(Automata* a){
	if ( !a )
		return;

	delete_automata(a->left);
	delete_automata(a->right);

	free(a);
}

void print_automata(Automata* a){
	if( !a )
		return;
	if( a->nodetype == TRUE_N){
		puts("TRUE NODE");
		return;
	}
	print_automata(a->left);
	if(a)
	switch(a->nodetype){
		case AND_N: puts("AND Automata node"); break;
		case OR_N: puts("OR Automata node"); break;
		case TRUE_N: puts("TRUE Automata node"); break;
		case GLOBAL_N: puts("GLOBAL Automata node"); break;
		case FUTURE_N: puts("FUTURE Automata node"); break;
		case UNTILA_N: puts("UNTILA Automata node"); break;
		case UNTILB_N: puts("UNTILB Automata node"); break;
		case IDENT_N: puts("IDENT Automata node"); break;
	}
	print_automata(a->right);
}
