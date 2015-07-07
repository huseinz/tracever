##paramsynth trace verifier

Verifies a given input using linear temporal logic formulas.

####Synopsis

`./tracever formula_file data_file`

####Syntax 

Begin the input file with your desired formula, using the following operators.    
End it with a semicolon.    
List your parameters in the order that they will appear in the input data.
Then, list your input data. 

State operators:

`!`	: NOT    
`&&`	: AND    
`||`    : OR     
`->`    : IMPLIES       

Unary LTL operators:

`X`     : **N**ext  (not implemented, probably doesn't need to be) 
`G`     : **G**lobally    
`F`     : **F**uture    

Binary LTL operators:

`U`     : **U**ntil     

Numerical comparison operators:

`<`, `>`, `<=`, `>=`, `==`, `!=`     


Use `(` and `)` to make statements unambiguous.

Example input file

```
(G !A) && (G B) && (F C);
```

Example input file
```
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

Just run `make`.

Addition targets:
```
clean
verbose
debug
fast
graph
```


