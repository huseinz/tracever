##paramsynth trace verifier

Currently parses LTL formulas but ignores the LTL operators and only evaluates the state portion.

Compile by running make (requires bison and flex)

Syntax:

Variable declaration:
`
A = true;
B = false;
//etc....
`
State operators:

`!`	    : 	NOT operator 
`&` or `&&` :	AND operator 
`|` or `||` : 	OR  operator 
`->` or `->`:	IMPLIES operator  

Unary LTL operators:

`X`         : 	true next state 
`G`         : 	always true (globally)
`F`	    : 	eventually (in the future) 

Binary LTL operators:

`U`         : 	first argument must be true at least until the second argument becomes true 
