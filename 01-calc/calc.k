// Calculator syntax
module CALC-SYNTAX
    imports INT-SYNTAX  // Int is the K built-in integer sort

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
endmodule

// Calculator semantics
module CALC
    imports INT         
    imports CALC-SYNTAX

    // Calculator semantics
    rule E1 + E2 => E1 +Int E2
    rule E1 - E2 => E1 -Int E2
    rule E1 * E2 => E1 *Int E2
    rule E1 / E2 => E1 /Int E2
    rule E1 ^ E2 => E1 ^Int E2
endmodule