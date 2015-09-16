##paramsynth trace verifier

Verifies a given input using bounded linear temporal logic formulas.

####Synopsis

`./tracever data_file`

####Syntax 

The first line of the data file must contain the BLTL formula you want to check the trace against.   
Below this, give the list of parameter names in the order they appear in each line of input data.     
Below this, begin listing your trace data. Trace data is currently limited to 5000 lines and the number of parameters is limited to 60.   
This can be changed by editing the defines in automata.h    
You can add comments to the data file with '#' but the first line MUST be the LTL formula.   


State operators:

`!`	: NOT    
`&&`	: AND    
`||`    : OR     
`->`    : IMPLIES       

Unary LTL operators:

`G:N`     : **G**lobally    
`F:N`     : **F**uture    

Binary LTL operators:

`U:N`     : **U**ntil     

where N is the bound ( 0 indicates infinity ) 

Numerical comparison operators:

`<`, `>`, `<=`, `>=`, `==`, `!=`     

Arithmetic Operators 

`+`, `-`, `*`, `/`


Use `(` and `)` to make statements unambiguous.

Example data file
```
G:5( (B > 3) && (A > 4) && F:0 C )
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

Example data files can be found in the 'examples' directory.

####Compiling

Requires flex, bison > 3.0, gcc

Just run `make`

Additional targets:
```
clean
verbose
debug
```


