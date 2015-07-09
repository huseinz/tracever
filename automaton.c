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
	switch(a->nodetype){
		case AND_N: puts("AND node"); break;
		case OR_N: puts("OR node"); break;
		//return early if TRUE_N node 
		case TRUE_N: puts("TRUE node"); return;
		case IDENT_N: puts("IDENT node"); break;
		case NOT_N: puts("NOT node");	break;
		case COMPARATOR_N: puts("COMPARE node"); break;
		default: fprintf(stderr, "!UNKNOWN NODE '%d'!\n", a->nodetype); 
	}
	print_automaton(a->left);
	print_automaton(a->right);
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
	printf("n = %d ", n);
	switch(a->nodetype){
		case AND_N: puts("AND"); break;
		case OR_N: puts("OR"); break;
		case TRUE_N: puts("TRUE"); break;
		case IDENT_N: puts("IDENT"); break;
		case NOT_N: puts("NOT");	break;
		case COMPARATOR_N: puts("COMPARE"); break;
		default: puts("!UNKNOWN NODE!"); break;
	}
#endif
#ifdef VERBOSE
	DFS_calls_made++;
#endif

	if(a == NULL)
		return false; //questionable
	if(a->nodetype == AND_N)
		return DFS(a->left, n) && DFS(a->right, n);
	else if(a->nodetype == OR_N)
		return DFS(a->left, n) || DFS(a->right, n);
	else{
		if(n < n_max){
			if( n + 1 == n_max)
				return a->accepting;

			switch(a->nodetype){
				case TRUE_N:		return DFS(a->left, n + 1);
				case IDENT_N:		return sym_vals[n][a->var];
				case NOT_N:		return !DFS(a->left, n);
				case COMPARATOR_N:	return evaluate_comparator(a, n);
				//should never happen
				case AND_N: 		//fallthrough
				case OR_N:  		//fallthrough
				default:		fprintf(stderr, "DFS: unhandled node type %d", a->nodetype);
			}
		}
		else
			return false;
	}
	return false;
}



