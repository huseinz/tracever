//automata node definition
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

double sym_vals[4];
typedef enum {
	AND_N,
	OR_N,
	TRUE_N,
//	GLOBAL_N,
//	FUTURE_N,
//	UNTILA_N,
//	UNTILB_N,
//	NEXT_N,
	IDENT_N,
	NOT_N,
	COMPARATOR_N
}nodetype_t;

typedef enum{
	GTR_THAN,
	LESS_THAN,
	GTR_OR_EQ,
	LESS_OR_EQ,
	EQUAL,
	NOT_EQUAL,
}comparator_t;

typedef struct Automata{
	
	//the node's type
	nodetype_t nodetype;
	//if node is testing a variable, this contains
	//its index in the symbol table
	int 	   var;
	//comparator operator, used in COMPARATOR_N nodes
	comparator_t comparator;
	//value to compare against, used in COMPARATOR_N nodes
	double     comparison_val;
	//left child, this is the 'default'
	struct Automata* left;
	//right child
	struct Automata* right;

}Automata;

Automata* create_node(nodetype_t nodetype, int var, Automata* left, Automata* right){
	sym_vals[1] = 19.01;
	sym_vals[2] = 1.00;
	sym_vals[3] = 0;
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
	if( a == NULL )
		return;
	if( a->nodetype == TRUE_N){
		puts("TRUE NODE");
		return;
	}
	print_automata(a->left);
	print_automata(a->right);
	if(a)
	switch(a->nodetype){
		case AND_N: puts("AND Automata node"); break;
		case OR_N: puts("OR Automata node"); break;
		case TRUE_N: puts("TRUE Automata node"); break;
		//case GLOBAL_N: puts("GLOBAL Automata node"); break;
		//case FUTURE_N: puts("FUTURE Automata node"); break;
		//case UNTILA_N: puts("UNTILA Automata node"); break;
		//case UNTILB_N: puts("UNTILB Automata node"); break;
		case IDENT_N: puts("IDENT Automata node"); break;
		case NOT_N: puts("NOT Automata node");	break;
		case COMPARATOR_N: puts("COMPARE Automata node"); break;
		//case NEXT_N: puts("NOT automata node"); break;
	}
}

bool DFS(Automata* a, int n){
	if(a == NULL)
		return NULL;
	if(n == 1)
		return true;
	switch(a->nodetype){
		case AND_N:
			return DFS(a->left, n) && DFS(a->right, n);
		case OR_N:
			return DFS(a->left, n) || DFS(a->right, n);
		case TRUE_N: 
			return DFS(a->left, n + 1);
//		case GLOBAL_N:  break;
//		case FUTURE_N:  break;
//		case UNTILA_N:  break;
//		case UNTILB_N:  break;
		case IDENT_N:  
			return sym_vals[a->var];
		case NOT_N: 	
			return !DFS(a->left, n);
		case COMPARATOR_N:  
			switch(a->comparator){
				case GTR_THAN:
					return sym_vals[a->var] > a->comparison_val;
				case LESS_THAN:
					return sym_vals[a->var] < a->comparison_val;
				case GTR_OR_EQ:
					return sym_vals[a->var] >= a->comparison_val;
				case LESS_OR_EQ:
					return sym_vals[a->var] <= a->comparison_val;
				case EQUAL:
					return sym_vals[a->var] == a->comparison_val;
			}
			break; 
	}
	return false;
}
