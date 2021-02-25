module CALC-BOOL-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX

    syntax Exp ::= Int | Bool

    syntax Int ::= "(" Int ")" [bracket]
                  | Int "+" Int [function]
                  | Int "-" Int [function]
                  > Int "*" Int [function]
                  | Int "/" Int [function]
                  > Int "^" Int [function]

    syntax Bool ::= "(" Bool ")" [bracket]
                  | Int "<=" Int [function]
                  | Int "<"  Int [function]
                  | Int ">=" Int [function]
                  | Int ">"  Int [function]
                  | Int "==" Int [function]
                  | Int "!=" Int [function]

    syntax Bool ::= Bool "&&" Bool [function]
                  | Bool "||" Bool [function]
endmodule

module CALC-BOOL
    imports INT
    imports BOOL
    imports CALC-BOOL-SYNTAX

    rule I1 + I2 => I1 +Int I2
    rule I1 - I2 => I1 -Int I2
    rule I1 * I2 => I1 *Int I2
    rule I1 / I2 => I1 /Int I2
    rule I1 ^ I2 => I1 ^Int I2

    rule I1 <= I2 => I1  <=Int I2
    rule I1  < I2 => I1   <Int I2
    rule I1 >= I2 => I1  >=Int I2
    rule I1  > I2 => I1   >Int I2
    rule I1 == I2 => I1  ==Int I2
    rule I1 != I2 => I1 =/=Int I2

    rule B1 && B2 => B1 andBool B2
    rule B1 || B2 => B1  orBool B2
endmodule
