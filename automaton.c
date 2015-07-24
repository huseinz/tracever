#include "automaton.h"

Automaton* create_node(nodetype_t nodetype, Automaton* left, Automaton* right){
	Automaton* newnode = malloc(sizeof(Automaton));
	
	if( !newnode )
		return NULL;
	
	newnode->nodetype = nodetype;
	newnode->var = 0;
	newnode->var_b = 0;
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
	if( !a )
		return;
	puts(get_nodename_literal(a));

	if(a->nodetype != TRUE_N)
		print_automaton(a->left);
	print_automaton(a->right);
}


char* get_nodename_literal(Automaton* a){	
	if(!a)
		return "NULL";
	switch(a->nodetype){
		case AND_N: return ("AND"); 
		case OR_N: return ("OR"); 
		case TRUE_N: return ("TRUE"); 
		case IDENT_N: return ("IDENT"); 
		case NOT_N: return ("NOT");	
		case COMPARATOR_N: return ("COMPARE"); 
		default: fprintf(stderr, "!UNKNOWN NODE '%d'!\n", a->nodetype); 
			return "ERROR";
	}
}

//helper function for DFS 
bool evaluate_comparator(Automaton* a, int n){

	double left = sym_vals[n][a->var];
	double right = a->var_b ? sym_vals[n][a->var_b] : a->comparison_val; 
	
	switch(a->comparator){
		case GTR_THAN:
			return left > right;
		case LESS_THAN:
			return left < right;
		case GTR_OR_EQ:
			return left >= right;
		case LESS_OR_EQ:
			return left <= right;
		case EQUAL:
			return left == right;
		case NOT_EQUAL:
			return left != right;
		default: fprintf(stderr, "!UNKNOWN COMPARATOR VAL %d!", a->comparator);
			 return false;
	}	
}

bool DFS(Automaton* a, int n){

#ifdef YYDEBUG
        printf("n = %d %s\n", n, get_nodename_literal(a));
#endif
        DFS_calls_made++;

        if( !a )
                return true; 
        if(a->nodetype == AND_N)
                return DFS(a->left, n) && DFS(a->right, n);
        else if(a->nodetype == OR_N)
                return DFS(a->left, n) || DFS(a->right, n);
        else{
		bool b = false;
                switch(a->nodetype){
                        case TRUE_N:            
				b = true;
				break;
                        case IDENT_N:           
				b = sym_vals[n][a->var];
				break;
                        case NOT_N:             
				b = !DFS(a->left, n);
				break;
                        case COMPARATOR_N:      
				b = evaluate_comparator(a, n);
				break;
                        default: 
				fprintf(stderr, "DFS: unhandled node type %d", a->nodetype);
			
                }
		if( b )
			return n == n_max - 1  ? a->accepting : DFS(a->left, n + 1);
		else 
			return false;
        }
        return false;
}



