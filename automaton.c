#include "automaton.h"

Automaton* create_node(nodetype_t nodetype, Automaton* left, Automaton* right){
	Automaton* newnode = malloc(sizeof(Automaton));
	
	if( !newnode )
		//throw some fatal error
		return NULL;
	
	newnode->nodetype = nodetype;
	newnode->var = 0;
	newnode->comparator = 0;
	newnode->comparison_val = 0;
	newnode->left = left;
	newnode->right = right;
	newnode->accepting = false;
	newnode->num = num_nodes++;
	return newnode;
}

void delete_automaton(Automaton* a){
	if( !a )
		return;
	if( a->nodetype != TRUE_N)
		delete_automaton(a->left);
	delete_automaton(a->right);

	free(a);
}

void print_automaton(Automaton* a){
	if( a == NULL )
		return;
	puts(get_nodename_literal(a));

	if(a->nodetype != TRUE_N)
		print_automaton(a->left);
	print_automaton(a->right);
}


char* get_nodename_literal(Automaton* a){	
	switch(a->nodetype){
		case AND_N: return ("AND"); 
		case OR_N: return ("OR"); 
		case TRUE_N: return ("TRUE"); 
		case IDENT_N: return ("IDENT"); 
		case NOT_N: return ("NOT");	
		case COMPARATOR_N: return ("COMPARE"); 
		case FUTURE_N: return ("FUTURE");
		default: fprintf(stderr, "!UNKNOWN NODE '%d'!\n", a->nodetype); 
			return "ERROR";
	}
}

//helper function for DFS 
bool evaluate_comparator(Automaton* a, int n){
	switch(a->comparator){
		case GTR_THAN:
			return sym_vals[n][a->var] > a->comparison_val;
		case LESS_THAN:
			return sym_vals[n][a->var] < a->comparison_val;
		case GTR_OR_EQ:
			return sym_vals[n][a->var] >= a->comparison_val;
		case LESS_OR_EQ:
			return sym_vals[n][a->var] <= a->comparison_val;
		case EQUAL:
			return sym_vals[n][a->var] == a->comparison_val;
		case NOT_EQUAL:
			return sym_vals[n][a->var] != a->comparison_val;
		default: fprintf(stderr, "!UNKNOWN COMPARATOR VAL %d!", a->comparator);
			 return false;
	}	
}

bool DFS(Automaton* a, int n){

#ifdef YYDEBUG
	printf("n = %d %s\n", n, get_nodename_literal(a));
#endif
	DFS_calls_made++;

	if(a == NULL)
		return false; //questionable
	if(a->nodetype == AND_N)
		return DFS(a->left, n) && DFS(a->right, n);
	else if(a->nodetype == OR_N)
		return DFS(a->left, n) || DFS(a->right, n);
	else if(a->nodetype == FUTURE_N){
		if( n == n_max )
			return a->accepting;
		bool b = DFS(a->left, n) || DFS(a->right, n);
		if(b)
			a->accepting = b;
		return b;
	}
	else{
			if( n  == n_max)
				return a->accepting;

			switch(a->nodetype){
				case TRUE_N:		return DFS(a->left, n + 1);
				case IDENT_N:		return sym_vals[n][a->var];
				case NOT_N:		return !DFS(a->left, n);
				case COMPARATOR_N:	return evaluate_comparator(a, n);
				default:		fprintf(stderr, "DFS: unhandled node type %d", a->nodetype);
			}
	}
	return false;
}



