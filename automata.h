//automata node definition
#ifndef AUTOMATA_H
#define AUTOMATA_H 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

double sym_vals[100][10];

int n_max;

typedef enum {
	AND_N,
	OR_N,
	TRUE_N,
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
	NOT_EQUAL
}comparator_t;

typedef struct Automata{
	
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
	struct Automata* left;
	//right child
	struct Automata* right;

}Automata;

/* bad place to put this*/
Automata* final_automata;

Automata* create_node(nodetype_t nodetype, int var, Automata* left, Automata* right);

void delete_automata(Automata* a);

void print_automata(Automata* a);

bool DFS(Automata* a, int n);

#endif
