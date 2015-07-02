##paramsynth trace verifier

Currently only evaluates state boolean formulas.

Compile by running make (requires bison and flex)

Syntax:

Variable declaration:

```
A = true;    
B = false;    
C = 20;
//etc.... 
```

State operators:

`!`	    : 	NOT operator      
`&&` :	AND operator       
`||` : 	OR  operator       
`->`:	IMPLIES operator   

Unary LTL operators:

`X`         : 	true next state     
`G`         : 	always true (globally)     
`F`	    : 	eventually (in the future) 


Binary LTL operators:

`U`         : 	first argument must be true until the second argument becomes true 
