//automata node definition
#ifndef AUTOMATON_H
#define AUTOMATON_H 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <limits.h>

#define MAX_INPUT_SIZE 5000
#define MAX_PARAMS     60	

/* input data table */
double trace_vals[MAX_INPUT_SIZE][MAX_PARAMS];

/* number of traces */
int n_max;

/* DFS call counter */
long DFS_calls_made;

/* total number of nodes */
int num_nodes;

/* operator types */
typedef enum{
	GTR_THAN,
	LESS_THAN,
	GTR_OR_EQ,
	LESS_OR_EQ,
	EQUAL,
	NOT_EQUAL,
	ADD,
	SUB,
	MUL,
	DIV
}operator_t;

/* node types */
typedef enum {
	AND_N = DIV + 1,
	OR_N,
	TRUE_N,
	NOT_N,
	PARAM_N,
	CONST_N,
	OPER_N
}nodetype_t;

/* Automaton node declaration */
typedef struct Automaton{

	//node's number, used for graph printing	
	int num;
	//the node's type
	nodetype_t nodetype;
	//if node is testing a variable, this contains
	//its index in the symbol table
	int var;
	//comparator operator, used in OPER_N nodes
	operator_t operator;
	//whether this is an accepting state or not 
	bool accepting;
	//bound for BLTL
	int bound;
	//value to compare against, used in CONST_N nodes
	int constant;
	//left child
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
*		for everything except PARAM_N and COMP_N
*	@param left 
*		pointer to left child 
*	@param right 
*		pointer to right child 
*
*	@return pointer to new node 
*/
Automaton* create_node(nodetype_t nodetype, Automaton* left, Automaton* right);

/**
*	@brief generates a new operator node and set relevant fields
*
*	@param comp
*		string containing desired comparison operator 
*	@param left
*		left operand
*	@param right
*		right operand
*	
*	@return 
*		pointer to new node
*
*/
Automaton* create_operator_node(const char* op, Automaton* left, Automaton* right);

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
bool DFS(Automaton* a, int n, int bound);

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
double evaluate_operator(Automaton* a, int n);

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
