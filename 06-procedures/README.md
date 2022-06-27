# Example 6: Procedures

In this exercise, we take the [previous exercise](../05-control-flow/README.md) and extend the language with procedures and procedure calls. In particular, the syntax of statements is as follows:

```k
   ...

    syntax Stmt ::= 
         Id "=" IExp ";" [strict(2)]                        // Assignment
       | Stmt Stmt [left]                                   // Sequence
       | Block                                              // Block
       | "if" "(" BExp ")" Block "else" Block [strict(1)]   // If conditional
       | "while" "(" BExp ")" Block                         // While loop
       | "return" IExp ";"                    [seqstrict]   // Return statement
       | "def" Id "(" Ids ")" Block                         // Function definition

    syntax Block ::= 
         "{" Stmt "}"    // Block with statement
       | "{" "}"         // Empty block

   ...
```

where `Ids` represent, without going into too much `K`-related detail, a comma-separated list of identifiers. This means that we have two new statements: the return statement, `return ie`, which terminates function execution, returning the (integer) expression `ie`; and the functions declarations statement, `def fid(x1, ..., xn) { fbody }`, which declares a new function with identifier `fid`, parameters `x1, ..., xn`, and body `fbody`. Integer expressions are also extended with function calls

```k
syntax IExp ::= 
     ...
   | Id "(" Exps ")" [strict(2)]
```

where `Exps` represent a comma-separated list of expressions. When it comes to the semantics, configurations are extended with: a functiont table that stores all of the declared functions, denoted by `funcs`; and a call stack,  denoted by `stack`, which contains a list whose elements are statement-store pairs:

```k
configuration
   <k> $PGM:Stmt </k>
   <store> .Map </store>
   <funcs> .Map </funcs>
   <stack> .List </stack>
```

The function table gets updated with every function definition, as follows:

```k
rule <k> def FNAME ( ARGS ) BODY => . ... </k>
   <funcs> FS => FS [ FNAME <- def FNAME ( ARGS ) BODY ] </funcs>
```

The statement-store pairs of the call stack are meant to represent the continuation and the associated store at each call site, and we can see how they are managed in the rule for calling functions and the return rules. The function call rule is as follows

```k
rule <k> FNAME ( IS:Ints ) ~> CONT => #makeBindings(ARGS, IS) ~> BODY </k>
   <funcs> ... FNAME |-> def FNAME ( ARGS ) BODY ... </funcs>
   <store> STORE => .Map </store>
   <stack> .List => ListItem(state(CONT, STORE)) ... </stack>
```

placing the current continuation `CONT` and store `STORE` on top of the call stack (using `ListItem`), as well as  setting up the execution of the function being called. This is done by getting the function arguments (`ARGS`) and body (`BODY`) from the function table, setting the store to the empty store, and setting the evaluation to `#makeBindings(ARGS, IS) ~> BODY`, where the former, defined by

```k
rule <k> #makeBindings(.Ids, .Ints) => . ... </k>

rule <k> #makeBindings((I:Id, IDS => IDS), (IN:Int, INTS => INTS)) ... </k>
   <store> STORE => STORE [ I <- IN ] </store>
```

fills the store with the function arguments mapped to their passed values.
On the other hand, there are two rules for the `return` statement:

```k
rule <k> return I:Int ; ~> _ => I ~> CONT </k>
   <stack> ListItem(state(CONT, STORE)) => .List ... </stack>
   <store> _ => STORE </store>

rule <k> return I:Int ; ~> . => I </k>
   <stack> .List </stack>
```

The first return rule handles the case in which the call stack is non-empty. 
By matching on the first stack frame (using `ListItem`), we obtain the continuation `CONT` and the calling store `STORE`, at the same time removing said stack frame by rewriting it to `.`. Then, we set the remaining evaluation to the return value followed by the continuation, `I ~> CONT`, and reset the store to the calling store. The second return rule deals with the case in which the call stack is empty (by matching on `.List`), meaning that we are returning from the top-level function, in which case we only return `I`.

## Compiling and running the exercise

Follow the instructions from the top-level [`README`](../README.md) file to compile these two exercises and run the provided tests. Create some further examples to check if they yield the expected results.

## Proving program properties

For this exercise, we re-use the `while` loop from the [previous exercise](../05-control-flow/README.md), together with its specification, wrap it in a function, then call that function and reason about the obtained result. Using slightly different identifiers and symbolic variables, the specification of the `while` loop is as follows:

```
claim 
   <k> 
      while ( 0 < NID ) {
         SID = SID + NID ;
          NID = NID - 1 ;
      }
   => . ... </k>
   <store> 
      SID |-> (S:Int => S +Int ((N +Int 1) *Int N /Int 2))
      NID |-> (N:Int => 0)
   </store>
requires N >=Int 0
```

and the main program, together with its specification, is as follows:

```
claim 
   <k> 
      def $sum($n, .Ids) {
         $s = 0 ;
         while (0 < $n) {
            $s = $s + $n ;
            $n = $n - 1 ;
         }
         return $s ;
      }
      $n := $sum(N:Int, .Ints) ;
   => . ... </k>
   <funcs> .Map => ?_ </funcs>
   <store> $n |-> (_ => ((N +Int 1) *Int N /Int 2)) </store>
   <stack> .List </stack>
   requires N >=Int 0
```

The specification states that this program, which consists of declaring a function `$sum` and then calling it with a non-negative symbolic integer `N`, ends up storing the sum of first `N` integers in the variable `$n`.