//automata node definition
#ifndef AUTOMATON_H
#define AUTOMATON_H 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_INPUT_SIZE 1000
#define MAX_PARAMS     20	

double sym_vals[MAX_INPUT_SIZE][MAX_PARAMS];

int n_max;
long DFS_calls_made;

typedef enum {
	AND_N,
	OR_N,
	TRUE_N,
	IDENT_N,
	NOT_N,
	COMPARATOR_N
}nodetype_t;

typedef enum{
	GTR_THAN = COMPARATOR_N + 1,
	LESS_THAN,
	GTR_OR_EQ,
	LESS_OR_EQ,
	EQUAL,
	NOT_EQUAL
}comparator_t;

typedef struct Automaton{
	
	//the node's type
	nodetype_t nodetype;
	//if node is testing a variable, this contains
	//its index in the symbol table
	int 	   var;
	//comparator operator, used in COMPARATOR_N nodes
	comparator_t comparator;
	//whether this is an accepting state or not 
	bool accepting;
	//value to compare against, used in COMPARATOR_N nodes
	double     comparison_val;
	//left child, this is the 'default'
	struct Automaton* left;
	//right child
	struct Automaton* right;

}Automaton;

/* bad place to put this*/
Automaton* final_automaton;

Automaton* create_node(nodetype_t nodetype, int var, Automaton* left, Automaton* right);

void delete_automaton(Automaton* a);

void print_automaton(Automaton* a);

bool DFS(Automaton* a, int n);

#endif
