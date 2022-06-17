# Example 3: Variables in Expressions, Explicit Substitution

In this exercise, we take the expression calculator of the [previous exercise](../02-calc-bool/README.md) and extend the syntax of integer expressions with variables. To evaluate such expressions, we move from the functional to the stateful fragment of K, using configurations to model a variable store (hard-coded for this example), and evaluate expressions using explicit substitution. In the syntax, variables are modelled using the `K` built-in `Id` sort, and the integer and Boolean expressions contain all of the previously seen operators:

```k
module SUBST-SYNTAX
   imports INT-SYNTAX   // Int is the K built-in integer sort
   imports BOOL-SYNTAX  // Bool is the K built-in Boolean sort
   imports ID           // Id is the K built-in sort for identifiers (variables)

   // Expressions are either integer or Boolean expressions
   syntax Exp ::= IExp | BExp

   // An integer expression is either an integer value or a variable identifier
   syntax IExp ::= Int | Id 
   // or any of the arithmetic operators
   syntax IExp ::=  IExp "^" IExp
                  > IExp "*" IExp
                  | IExp "/" IExp
                  > IExp "+" IExp
                  | IExp "-" IExp
   // or a bracketed integer expression
   syntax IExp ::= "(" IExp ")" [bracket]
                  
   // A Boolean expression is either a Boolean value
   syntax BExp ::= Bool
   // or any of the comparison operators
   syntax BExp ::=  IExp "<=" IExp
                  | IExp "<"  IExp
                  | IExp ">=" IExp
                  | IExp ">"  IExp
                  | IExp "==" IExp
                  | IExp "!=" IExp
   // or any of the propositional connectives
   syntax BExp ::=  BExp "&&" BExp
                  | BExp "||" BExp
   // or a bracketed Boolean expression
   syntax BExp ::= "(" BExp ")" [bracket]
endmodule
```

The semantics, on the other hand, becomes more involved. First, we have to model the variable store, which we do using `K` configurations. In particular, our configuration is of the form:

```k
   configuration
      // K cell, containing the expression to be evaluated
      <k> $PGM:Exp </k>
      // Variable store, modelled as a K map
      <store> 
         #token("a", "Id") |-> 16
         #token("b", "Id") |-> 9
         #token("c", "Id") |-> 4
         #token("d", "Id") |-> 2
      </store>
```

and contains two components. The first is a `K` cell, which contains the expression to be evaluated and which is initially populated with the contents of the passed input file (denoted by `$PGM`). The second is the variable store, which is modelled as a `K` map, and which contains some hard-coded variables (`a`, `b`, `c`, and `d`) with their values.

Next, we declare that expressions should be evaluated, with each type of expressions having its dedicated substitution (`substI` and `substB`):

```k
    // Integer expression evaluation via explicit substitution 
    rule 
      <k> IE:IExp => substI(IE, STORE) ... </k>
      <store> STORE </store>
      requires notBool isInt(IE)

   // Boolean expression evaluation via explicit substitution 
   rule 
      <k> BE:BExp => substB(BE, STORE) ... </k>
      <store> STORE </store>
      requires notBool isBool(BE)
```

The first rule states that, given a configuration containing an integer expression `IE` and store `STORE`, if `IE` is not an integer value, then it should be rewritten to the result of the substitution given on the right hand side, and the store should remain the same. The second rule is analogous. The side conditions, given by the `requires` clauses,  are there to ensure that the evaluation terminates.[^1]

The actual integer substitution function is defined as follows (with some non-instructive cases elided):

```k
    // Integer expression substitution
    syntax Int ::= substI ( IExp , Map ) [function]
 
    // Base case: integer values evaluate to themselves
    rule substI(I:Int, _SUBST) => I

    // Base case: identifiers evaluate to their value in the store
    rule substI(I:Id, SUBST) => {SUBST [ I ]}:>Int

    // Inductive cases 
    rule substI(I1 + I2, SUBST) => substI(I1, SUBST) +Int substI(I2, SUBST)
    rule substI(I1 - I2, SUBST) => substI(I1, SUBST) -Int substI(I2, SUBST)
    ...
```

The substitution is defined as a function mapping an integer expression (`IExp`) and a variable store (`Map`) to an integer. It has two base cases, which state that integers evaluate to themselves, and that variables evaluate to their value in the store (denoted by `[SUBST [I]]`). The cases for all of the arithmetic operators are straightforward, that is, the substitution is simply applied to the operands inductively. The Boolean substitution function is defined analogously, using the integer substitution function where required (for example, in the comparison operators).

[^1] One might think, given the base cases of the substitutions in which integers and Booleans evaluate to themselves, that these side conditions are not necessary. However, if they were removed, `K` would simply keep attempting to rewrite the final obtained value using the substitution, and this would keep succeeding, the value would keep being  rewritten to itself, and the evaluation wound not terminate.

## Compiling and running the exercise

Follow the instructions from the top-level [`README`](../README.md) file to compile this exercise and run the provided tests. Create some further examples and/or change the hard-coded variables and their values to check if you get back the expected results. 