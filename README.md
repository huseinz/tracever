##paramsynth trace verifier

Verifies a given input using linear temporal logic formulas.

####Synopsis

`./tracever data_file`

####Syntax 

The data file should begin with the LTL formula you want to check your input data against.   
Below this, give a list of parameter names in the order they appear in each line of input data.     
Below this, begin listing your input data. Input data is currently limited to 1000 lines and the number of parameters is limited to 20.   
This can be changed by editing the defines in automata.h

State operators:

`!`	: NOT    
`&&`	: AND    
`||`    : OR     
`->`    : IMPLIES       

Unary LTL operators:

`G`     : **G**lobally    
`F`     : **F**uture    

Binary LTL operators:

`U`     : **U**ntil     

Numerical comparison operators:

`<`, `>`, `<=`, `>=`, `==`, `!=`     


Use `(` and `)` to make statements unambiguous.

Example data file
```
G( (B > 3) && (A > 4) && (B U C) && F C)
A B C 
20.2 	10.1 	0.0 
21.1 	1000.2 	0.0 
18.3	20.5 	0.0 
234.2 	20.2 	0.0 
60.3 	23232.3 0.0 
3223.3 	322.2 	1.0 
123.2 	123.5 	1.0 
564.5 	233.1 	1.0 
```

####Compiling

Requires flex, bison > 3.0, gcc

Just run `make`

Addition targets:
```
clean
verbose
debug
fast
graph
```


