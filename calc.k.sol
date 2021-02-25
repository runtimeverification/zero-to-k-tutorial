module CALC-SYNTAX
    imports INT-SYNTAX

    syntax Int ::= Int "+" Int [function]
                 | Int "-" Int [function]
                 > Int "*" Int [function]
                 | Int "/" Int [function]
                 > Int "^" Int [function]

    syntax Int ::= "(" Int ")" [bracket]
endmodule

module CALC
    imports INT
    imports CALC-SYNTAX

    rule E1 + E2 => E1 +Int E2
    rule E1 - E2 => E1 -Int E2
    rule E1 * E2 => E1 *Int E2
    rule E1 / E2 => E1 /Int E2
    rule E1 ^ E2 => E1 ^Int E2
endmodule
