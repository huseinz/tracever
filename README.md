##paramsynth trace verifier

Verifies a given input using linear temporal logic formulas.

Compile by running make (requires bison and flex)

####Synopsis

`tracever [file]`

will read from stdin if no file given

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
(G !A) && (G B) && (F C);
A B C 
20.2 10.1 0.0 
21.1 1000.2 0.0 
18.3 20.5 0.0 
234.2 20.2 0.0 
60.3 23232.3 0.0 
3223.3 3234232.2 1.0 
123.2 123.5 1.0 
564.5 233.1 1.0 
```
