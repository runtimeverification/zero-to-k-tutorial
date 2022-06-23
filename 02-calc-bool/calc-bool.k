// Expression calculator syntax
module CALC-BOOL-SYNTAX
    imports INT-SYNTAX  // Int is the K built-in integer sort
    imports BOOL-SYNTAX // Bool is the K built-in Boolean sort

    // Expressions are either integers or Booleans
    syntax Exp ::= Int | Bool

    // Integer arithmetic syntax
    syntax Int ::= 
        "(" Int ")" [bracket]   
      > left:                   // left: indicates left associativity 
        Int "^" Int [function]  // and > indicates lower priority of below productions
      > left:                   
        Int "*" Int [function] 
      | Int "/" Int [function]
      > left:
        Int "+" Int [function]  
      | Int "-" Int [function] 

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
      left: 
        Bool "&&" Bool [function]
      | Bool "||" Bool [function]
endmodule

// Expression calculator semantics
module CALC-BOOL
    imports INT
    imports BOOL
    imports CALC-BOOL-SYNTAX

    // Integer arithmetic semantics
    rule I1 + I2 => I1 +Int I2
    rule I1 - I2 => I1 -Int I2
    rule I1 * I2 => I1 *Int I2
    rule I1 / I2 => I1 /Int I2
    rule I1 ^ I2 => I1 ^Int I2

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
