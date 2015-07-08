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

/**
*	@brief generates a new automaton node and initializes common params 
*	
*	@param nodetype 
*		type of node to be created, defined in enum nodetype_t 
*	@param var 
*		location of variable in question. this is usually 0 
*		for everything except IDENTIFIER_N and COMPARATOR_N
*	@param left 
*		pointer to left child 
*	@param right 
*		pointer to right child 
*	@return pointer to new node 
*/
Automaton* create_node(nodetype_t nodetype, int var, Automaton* left, Automaton* right);

/** 	@brief deletes an automaton
*
*	@param a pointer to root of automaton 
*/
void delete_automaton(Automaton* a);

/**	@brief prints automaton in preorder format 
*
*	@param a pointer to root of automaton
*/
void print_automaton(Automaton* a);

/**	@brief performs alternating automaton verification using a DFS
*
*	@param a
*		pointer to automaton
*	@param n
*		index of trace record, usually 0
*	@return 
*		boolean indicating if trace is valid 
*/
bool DFS(Automaton* a, int n);

#endif
