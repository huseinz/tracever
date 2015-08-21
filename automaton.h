//automata node definition
#ifndef AUTOMATON_H
#define AUTOMATON_H 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_INPUT_SIZE 5000
#define MAX_PARAMS     60	

/* input data table */
double sym_vals[MAX_INPUT_SIZE][MAX_PARAMS];

/* number of traces */
int n_max;

/* DFS call counter */
long DFS_calls_made;

int num_nodes;

/* node types */
typedef enum {
	AND_N,
	OR_N,
	TRUE_N,
	IDENT_N,
	NOT_N,
	COMP_N,
}nodetype_t;

/* comparator types */
typedef enum{
	GTR_THAN = COMP_N + 1,
	LESS_THAN,
	GTR_OR_EQ,
	LESS_OR_EQ,
	EQUAL,
	NOT_EQUAL
}comparator_t;

/* Automaton node declaration */
typedef struct Automaton{
	
	int num;
	//the node's type
	nodetype_t nodetype;
	//if node is testing a variable, this contains
	//its index in the symbol table
	int var;
	//secondary variable index, used in COMP_N nodes
	//for comparing two variables
	int var_b;   
	//comparator operator, used in COMP_N nodes
	comparator_t comparator;
	//whether this is an accepting state or not 
	bool accepting;
	//value to compare against, used in COMP_N nodes
	//that compare against a constant
	double     comparison_val;
	//left child, this is the 'default'
	struct Automaton* left;
	//right child
	struct Automaton* right;

}Automaton;

/* pointer to the completed automaton */
/* this is a bad place to put this */
Automaton* final_automaton;

/**
*	@brief 	generates a new automaton node and initializes common params 
*
*		other params (such as var, accepting, comparator, etc)
*		need to be set manually 
*	
*	@param nodetype 
*		type of node to be created, defined in enum nodetype_t 
*	@param var 
*		location of variable in question. this is usually 0 
*		for everything except IDENTIFIER_N and COMP_N
*	@param left 
*		pointer to left child 
*	@param right 
*		pointer to right child 
*
*	@return pointer to new node 
*/
Automaton* create_node(nodetype_t nodetype, Automaton* left, Automaton* right);

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

/**	@brief 	helper function for DFS 
*		evaluates COMP_N node value 
*	
*	@param a
*		COMP_N node 
*	@param n
*		trace n to be tested 
*	@return 
*		comparator bool 
*/
bool evaluate_comparator(Automaton* a, int n);

/** 	@brief returns string containing node's type
*	
*	@param a
*		Automaton
*
*	@return 
*		string containing node's type
*/
const char* get_nodetype_literal(Automaton* a);

#endif
