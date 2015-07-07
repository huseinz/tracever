//automata node definition
#include "automata.h"

Automata* create_node(nodetype_t nodetype, int var, Automata* left, Automata* right){
	Automata* newnode = malloc(sizeof(Automata));
	
	if( !newnode )
		//throw some fatal error
		return NULL;
	
	newnode->nodetype = nodetype;
	newnode->var = var;
	newnode->left = left;
	newnode->right = right;
	newnode->accepting = false;
	return newnode;
}

void delete_automata(Automata* a){
	if( !a || a->nodetype == TRUE_N)
		return;
	delete_automata(a->left);
	delete_automata(a->right);

	free(a);
}

void print_automata(Automata* a){
	if( a == NULL )
		return;
	if( a->nodetype == TRUE_N){
		puts("TRUE node");
		return;
	}
	print_automata(a->left);
	print_automata(a->right);
	if(a)
	switch(a->nodetype){
		case AND_N: puts("AND node"); break;
		case OR_N: puts("OR node"); break;
		case TRUE_N: puts("TRUE node"); break;
		case IDENT_N: puts("IDENT node"); break;
		case NOT_N: puts("NOT node");	break;
		case COMPARATOR_N: puts("COMPARE node"); break;
	}
}

bool DFS(Automata* a, int n){

#ifdef VERBOSE
	printf("n = %d\n", n);
#endif

	if(a == NULL)
		return true;
	if(a->nodetype == AND_N)
		return DFS(a->left, n) && DFS(a->right, n);
	else if(a->nodetype == OR_N)
		return DFS(a->left, n) || DFS(a->right, n);
	else{
		if(n != n_max){
			if( a->nodetype == TRUE_N && n + 1 == n_max)
				return a->accepting;

			switch(a->nodetype){
				case TRUE_N:
					return DFS(a->left, n + 1);
				case IDENT_N:
					return sym_vals[n][a->var];
				case NOT_N:
					return !DFS(a->left, n);
				case COMPARATOR_N:
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
					}
					break; 
				case AND_N: return false;
				case OR_N:  return false;
			}
		}
		else
			return false;
	}
	return false;
}
