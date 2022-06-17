# Example 2: Calculator with Boolean Expressions

In this exercise, we extend the calculator of Exercise 1 to include Boolean expressions, such as the standard propositional connectives and integer comparisons. The syntax extension is straightforward, introducing the `Bool` built-in sort for Booleans, and defining top-level expressions as either integers or Booleans:

```k
// Expression calculator syntax
module CALC-BOOL-SYNTAX
    imports INT-SYNTAX  // Int is the K built-in integer sort
    imports BOOL-SYNTAX // Bool is the K built-in Boolean sort

    // Expressions are either integers or Booleans
    syntax Exp ::= Int | Bool

    // Integer arithmetic syntax from Exercise 1
    syntax Int ::= 
        ...

    // Integer comparison syntax
    syntax Bool ::= 
        "(" Bool ")" [bracket]
      | Int "<=" Int [function]
      | Int "<"  Int [function]
      | Int ">=" Int [function]
      | Int ">"  Int [function]
      | Int "==" Int [function]
      | Int "!=" Int [function]

    // Propositional connective syntax
    syntax Bool ::= 
        Bool "&&" Bool [function]
      | Bool "||" Bool [function]
endmodule
```

The semantics is also straightforwardly extended to the newly defined operators:

```k
// Expression calculator semantics
module CALC-BOOL
    imports INT
    imports BOOL
    imports CALC-BOOL-SYNTAX

    // Integer arithmetic semantics
    ...

    // Integer comparison semantics
    rule I1 <= I2 => I1  <=Int I2
    rule I1  < I2 => I1   <Int I2
    rule I1 >= I2 => I1  >=Int I2
    rule I1  > I2 => I1   >Int I2
    rule I1 == I2 => I1  ==Int I2
    rule I1 != I2 => I1 =/=Int I2

    // Propositional connective semantics
    rule B1 && B2 => B1 andBool B2
    rule B1 || B2 => B1  orBool B2
endmodule
```

## Compiling and running the expression calculator

Follow the instructions from the top-level [`README`](../README.md) file to compile the expression calculator and run the provided tests. Create some further examples to check if they yield expected results.