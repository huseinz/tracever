#include "automaton.h"

Automaton* create_node(nodetype_t nodetype, Automaton* left, Automaton* right) {

	Automaton* newnode = malloc(sizeof(Automaton));

	if(!newnode)
		return NULL;

	newnode->nodetype = nodetype;
	newnode->var = 0;
//	newnode->var_b = 0;
	newnode->operator = 0;
	newnode->constant = 0;
	newnode->left = left;
	newnode->right = right;
	newnode->accepting = false;
	newnode->num = num_nodes++;
	newnode->bound = INT_MAX;
	return newnode;
}

Automaton* create_comparator_node(const char* comp, Automaton* left, Automaton* right) {


	Automaton* COMPARE_node = create_node(COMP_N, left, right);
//	COMPARE_node->var = var_a;
//	COMPARE_node->var_b = var_b;
//	COMPARE_node->comparison_val = val;
	COMPARE_node->accepting = true;

	/* parse comparator */
	operator_t comparator = EQUAL;

	if( strcmp(comp, "<") == 0)
		comparator = LESS_THAN;
	else if( strcmp(comp, ">") == 0)
		comparator = GTR_THAN;
	else if( strcmp(comp, "<=") == 0)
		comparator = LESS_OR_EQ;
	else if( strcmp(comp, ">=") == 0)
		comparator = GTR_OR_EQ;
	else if( strcmp(comp, "==") == 0)
		comparator = EQUAL;
	else if( strcmp(comp, "!=") == 0)
		comparator = NOT_EQUAL;

	COMPARE_node->operator = comparator;

	return COMPARE_node;
}

void delete_automaton(Automaton* a) {
	if(!a)
		return;
	if(a->nodetype != TRUE_N)
		delete_automaton(a->left);
	delete_automaton(a->right);

	free(a);
}

void print_automaton(Automaton* a) {
	if(!a)
		return;
	puts(get_nodetype_literal(a));

	if(a->nodetype != TRUE_N)
		print_automaton(a->left);
	print_automaton(a->right);
}


const char* get_nodetype_literal(Automaton* a) {
	if(!a)
		return "NULL";
	switch(a->nodetype) {
	case AND_N:
		return "AND";
	case OR_N:
		return "OR";
	case TRUE_N:
		return "TRUE";
	case PARAM_N:
		return "PARAM";
	case NOT_N:
		return "NOT";
	case COMP_N:
		return "COMPARE";
	case CONST_N:
		return "CONSTANT";
	case ARITH_N:
		return "ARITH";
	default:
		fprintf(stderr, "!UNKNOWN NODE '%d'!\n", a->nodetype);
		return "ERROR";
	}
}

//helper function for DFS
bool evaluate_comparator(Automaton* a, int n) {

	double left, right;
	
	switch(a->left->nodetype){
		case PARAM_N:
			left = trace_vals[n][a->left->var];
			break;
		case CONST_N:
			left = a->left->constant;
			break;
		case ARITH_N:
			left = evaluate_arithmetic(a->left, n);
		case NULL:
			fprintf(stderr, "Comparator node has NULL child!");
			return false;
	}
	switch(a->right->nodetype){
		case PARAM_N:
			right = trace_vals[n][a->right->var];
			break;
		case CONST_N:
			right = a->right->constant;
			break;
		case ARITH_N:
			right = evaluate_arithmetic(a->right, n);
		case NULL:
			fprintf(stderr, "Comparator node has NULL child!");
			return false;
	}


	switch(a->comparator) {
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
		default:
			fprintf(stderr, "!UNKNOWN COMP VAL %d!", a->comparator);
			return false;
	}
}

bool DFS(Automaton* a, int n, int bound) {

#ifdef YYDEBUG
	printf("n = %d %s\n", n, get_nodetype_literal(a));
#endif
	DFS_calls_made++;

	if(!a)
		return true;

	switch(a->nodetype) {
	// automaton node 'a' truth value at current position

	case AND_N: 	//check if a->bound == INT_MAX (i.e. the current node's bound is unset/infinite)
		//or if bound != INT_MAX (global bound has been set/is not infinite)
		if(a->bound == INT_MAX || bound != INT_MAX)
			return DFS(a->left, n, bound) && DFS(a->right, n, bound);
		//if we've reached here, then we're
		//either at a BLTL node or the boundary has not been set
		//in both cases, set the new bound
		return DFS(a->left, n, n + a->bound) && DFS(a->right, n, n + a->bound);

	case OR_N :	//check if a->bound == INT_MAX (i.e. the current node's bound is unset/infinite)
		//or if bound != INT_MAX (global bound has been set/is not infinite)
		if(a->bound == INT_MAX || bound != INT_MAX)
			return DFS(a->left, n, bound) || DFS(a->right, n, bound);
		//if we've reached here, then we're
		//either at a BLTL node or the boundary has not been set
		//in both cases, set the new bound
		return DFS(a->left, n, n + a->bound) || DFS(a->right, n, n + a->bound);

	case NOT_N:
		return !DFS(a->left, n, bound);

	case TRUE_N:
		if(n == n_max - 1 || n + 1 == bound)
			return a->accepting;

		return DFS(a->left, n + 1, bound);

	case PARAM_N:
		return trace_vals[n][a->var];

	case COMP_N:
		return evaluate_comparator(a, n);

	default:
		fprintf(stderr, "DFS Unhandled node: %s\n", get_nodetype_literal(a));
		return false;
	}
}




