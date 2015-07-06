##paramsynth trace verifier

Verifies a given input using linear temporal logic formulas.

Compile by running make (requires bison and flex)

####Synopsis

`tracever [file]`

will read from stdin if no file given

####Syntax 

Begin the input file with your desired formulas, using the following operators.    
Separate formulas and data with the keyword `DATA`.    
Beneath `DATA`, list your parameters in the order that they will appear in the input data.
Then, list your input data. 

State operators:

`!`	: NOT    
`&&`	: AND    
`||`    : OR     
`->`    : IMPLIES       

Unary LTL operators:

`X`     : **N**ext   
`G`     : **G**lobally    
`F`     : **F**uture    

Binary LTL operators:

`U`     : **U**ntil     

Numerical comparison operators:

`<`, `>`, `<=`, `>=`, `==`      
Use `!(p0 == p1)` to check for inequality.

Other:

Use `(` and `)`.

Example input file

```
(G !A) && (G B) && (F C)

DATA
A B C

0 2 0
0 3 0
0 4 0
0 5 0
0 2 1 
0 2 1
```

Output : true



