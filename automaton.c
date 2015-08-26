#include "automaton.h"

Automaton* create_node(nodetype_t nodetype, Automaton* left, Automaton* right){
	
	Automaton* newnode = malloc(sizeof(Automaton));
	
	if(!newnode)
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
	newnode->bound = INT_MAX;
	return newnode;
}

Automaton* create_comparator_node(int var_a, const char* comp, int var_b, double val, bool invert){

	
	Automaton* COMPARE_node = create_node(COMP_N, NULL, NULL);
	COMPARE_node->var = var_a;
	COMPARE_node->var_b = var_b; 
	COMPARE_node->comparison_val = val;
	COMPARE_node->accepting = true;
	
	/* parse comparator */
	comparator_t comparator = EQUAL;
	
	if( strcmp(comp, "<") == 0)
		comparator = invert ? GTR_THAN : LESS_THAN;	
	else if( strcmp(comp, ">") == 0)
		comparator = invert ? LESS_THAN : GTR_THAN;	
	else if( strcmp(comp, "<=") == 0)
		comparator = invert ? GTR_OR_EQ : LESS_OR_EQ;	
	else if( strcmp(comp, ">=") == 0)
		comparator = invert ? LESS_OR_EQ : GTR_OR_EQ;	
	else if( strcmp(comp, "==") == 0)
		comparator = EQUAL;	
	else if( strcmp(comp, "!=") == 0)
		comparator = NOT_EQUAL;
	
	COMPARE_node->comparator = comparator;
	
	return COMPARE_node;
}

void delete_automaton(Automaton* a){
	if(!a)
		return;
	if(a->nodetype != TRUE_N)
		delete_automaton(a->left);
	delete_automaton(a->right);

	free(a);
}

void print_automaton(Automaton* a){
	if(!a)
		return;
	puts(get_nodetype_literal(a));

	if(a->nodetype != TRUE_N)
		print_automaton(a->left);
	print_automaton(a->right);
}


const char* get_nodetype_literal(Automaton* a){	
	if(!a)
		return "NULL";
	switch(a->nodetype){
		case AND_N: return "AND"; 
		case OR_N: return "OR"; 
		case TRUE_N: return "TRUE"; 
		case IDENT_N: return "IDENT"; 
		case NOT_N: return "NOT";	
		case COMP_N: return "COMPARE"; 
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
		default: fprintf(stderr, "!UNKNOWN COMP VAL %d!", a->comparator);
			 return false;
	}	
}

bool DFS(Automaton* a, int n, int bound){

#ifdef YYDEBUG
        printf("n = %d %s\n", n, get_nodetype_literal(a));
#endif
        DFS_calls_made++;

        if(!a)
                return true; 

	switch(a->nodetype){
		// automaton node 'a' truth value at current position
		bool b;

		case AND_N: 
				//check if a->bound == INT_MAX (i.e. the current node's bound is unset/infinite)
				//or if bound != INT_MAX (global bound has been set/is not infinite) 
				if(a->bound == INT_MAX || bound != INT_MAX)
					return DFS(a->left, n, bound) && DFS(a->right, n, bound);
				//if we've reached here, then we're 
				//either at a BLTL node or the boundary has not been set
				//in both cases, set the new bound
				return DFS(a->left, n, n + a->bound) && DFS(a->right, n, n + a->bound); 
				
        	case OR_N : 
				//check if a->bound == INT_MAX (i.e. the current node's bound is unset/infinite)
				//or if bound != INT_MAX (global bound has been set/is not infinite) 
				if(a->bound == INT_MAX || bound != INT_MAX)
					return DFS(a->left, n, bound) || DFS(a->right, n, bound);
				//if we've reached here, then we're 
				//either at a BLTL node or the boundary has not been set
				//in both cases, set the new bound
				return DFS(a->left, n, n + a->bound) || DFS(a->right, n, n + a->bound); 

		case NOT_N: 	return !DFS(a->left, n, bound);
        
		default: 
			b = false;
	                switch(a->nodetype){
        	                case TRUE_N:            
					b = true;
					break;
		                case IDENT_N:           
					b = sym_vals[n][a->var];
					break;
                	        case COMP_N:      
					b = evaluate_comparator(a, n);
					break;
				default:
					fprintf(stderr, "DFS Unhandled node: %s\n", 
						get_nodetype_literal(a));
                	}

			if(b) 
				return n == n_max - 1 || n + 1 == bound ? a->accepting : DFS(a->left, n + 1, bound);
			return false;
        }
}



