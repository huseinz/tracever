##paramsynth trace verifier

Currently only evaluates state boolean formulas.

Compile by running make (requires bison and flex)

####Syntax:

Variable declaration:

```
A = true;    #1
B = false;   #0
C = 20;
#etc.... 
```

State operators:

`!`	: NOT    
`&&`	: AND    
`||`    : OR     
`->`    : IMPLIES       
`<->`   : EQUIV      

Unary LTL operators:

`X`     : **N**ext   
`G`     : **G**lobally    
`F`     : **F**uture    


Binary LTL operators:

`U`     : **U**ntil     
`R`     : **R**elease     
