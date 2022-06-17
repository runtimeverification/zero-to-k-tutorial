# Example 4: Assignment

In this exercise, we take the [previous exercise](../03-subst/README.md) and build a simple programming language on top of the expression evaluator, starting from a variable assignment command and command sequencing. 

## Version 1: Assignment with explicit substitution

For the first attempt (cf. [assignment.k](assignment.k)), we still evaluate expressions using an explicit substitution. We extend the syntax of the previous exercise with statements, as follows:

```k
   ...

   // A statement is
   syntax Stmt ::=  
      // either an assignment
      Id "=" IExp ";"
      // or a (left-associative) sequence of statements 
      | Stmt Stmt [left]

   ...
```

For the semantics, the `K` cell needs to contain the statement to be executed, and we also no longer hard-code the store variables, but instead start from an empty store (denoted by `.Map`):

```k
   configuration
      // K cell, containing the stmt to be evaluated
      <k> $PGM:Stmt </k>
      // Variable store, modelled as a K map, initially empty
      <store> .Map </store>
```

The evaluation of expressions remains the same, and is followed by the evaluation of statements, defined as follows:

```k
   // Assignment
   rule 
      <k> ID = IE ; => . ... </k>
      <mem> MEM => MEM [ ID <- substI(IE, MEM) ] </mem>

   // Sequencing
   rule 
      <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>
```

The assignment rule features a rewriting rule in both components of the configuration. In the `K` cell, it "consumes" the leading assignment command, `ID = IE;`, leaving `.` behind (more on this shortly). The value of the variable being assigned to, `ID`, is updated in the variable store to the evaluation of the expression being assigned, `IE`, in the current store, `STORE`.

The sequencing rule simply sets up the evaluation so that the statement `S1` is evaluated first and the statement `S2` second. To illustrate this better, consider the sequence `X = 5; Y = 3; Z = 2;` and consider only the contents of the `K` cell during its evaluation. First, recalling that sequencing is left-associative, the sequencing rule rewrites the given sequence to `X = 5; ~> Y = 3; Z = 2;`. Then, the assignment rule executes `X = 5`, leaving `. ~> Y = 3; Z = 2;` (and updating the variable store appropriately). Finally, using a built-in rewriting rule, `. ~> S => S`, `K` rewrites this to `Y = 3; Z = 2;` and the evaluation continues with the next assignment.

## Version 2: Assignment with deterministic evaluation order

Writing the substitution explicitly is tedious, and would not scale for larger languages. For this reason, `K` provides mechanisms that significantly automate this process, which we illustrate in [assignment-strict.k](assignment-strict.k)). 

First, in the syntax, we annotate operators with the `seqstrict` attribute (given below for integer arithmetic expressions):

```k
   // An integer expression is either an integer value or a variable identifier
   syntax IExp ::= Int | Id 
   // or any of the arithmetic operators
   syntax IExp ::=  IExp "^" IExp [seqstrict]
                  | IExp "*" IExp [seqstrict]
                  | IExp "/" IExp [seqstrict]
                  > IExp "+" IExp [seqstrict]
                  | IExp "-" IExp [seqstrict]
   // or a bracketed integer expression
   syntax IExp ::= "(" IExp ")" [bracket]
```

which, essentially, means that the sub-expressions of the given binary operators are to be evaluated deterministically, left-to-right. To make the order non-deterministic, you could use the `strict` attribute instead. We also need to tell `K` when the evaluation should stop (in this case, when we've reached an integer or a Boolean value), and this is done by extending the `K` built-in `KResult` sort, as follows:

```k
   syntax KResult ::= Int | Bool
```

The semantics is substantially simplified in that there is no more substitution, and the expression evaluation is formulated straightforwardly, as illusatrated by the following excerpt:

```k
   // Base case: Variables evaluate to their values in the store
   rule 
      <k> I:Id => STORE[I] ... </k>
      <store> STORE </store>

   // Arithmetic operators 
   rule <k> I1 + I2 => I1 +Int I2 ... </k>
   rule <k> I1 - I2 => I1 -Int I2 ... </k>
   ...
```

In particular, operator evaluation has the same complexity (simplicity) as in the [first](../01-calc/README.md) and [second](../02-calc-bool/README.md) exercises, with the only difference being that they explicitly make use of the `K` cell (`<k> ... </k>`). The semantics of the assignment is also slightly modified to state that the value being assigned is an integer, rather than an integer expression:

```k
   // Assignment
   rule 
      <k> ID = I:Int ; => . ... </k>
      <store> STORE => STORE [ ID <- I ] </store>
```

## Compiling and running the exercise(s)

Follow the instructions from the top-level [`README`](../README.md) file to compile these two exercises and run the provided tests. Create some further examples to check if the two approaches return the same (and expected) results. 