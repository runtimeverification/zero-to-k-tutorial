module ASSIGNMENT-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID

    syntax Exp ::= IExp | BExp

    syntax IExp ::= Id | Int

    syntax KResult ::= Int | Bool

    syntax IExp ::= "(" IExp ")" [bracket]
                  | IExp "+" IExp [strict]
                  | IExp "-" IExp [strict]
                  > IExp "*" IExp [strict]
                  | IExp "/" IExp [strict]
                  > IExp "^" IExp [strict]

    syntax BExp ::= Bool

    syntax BExp ::= "(" BExp ")" [bracket]
                  | IExp "<=" IExp [strict]
                  | IExp "<"  IExp [strict]
                  | IExp ">=" IExp [strict]
                  | IExp ">"  IExp [strict]
                  | IExp "==" IExp [strict]
                  | IExp "!=" IExp [strict]

    syntax BExp ::= BExp "&&" BExp [strict]
                  | BExp "||" BExp [strict]

    syntax Stmt ::= Id "=" IExp ";" [strict(2)]
                  | Stmt Stmt [left]
endmodule

module ASSIGNMENT
    imports INT
    imports BOOL
    imports MAP
    imports ASSIGNMENT-SYNTAX

    configuration
      <k> $PGM:Stmt </k>
      <mem> .Map </mem>

 // -----------------------------------------------
    rule <k> I1 + I2 => I1 +Int I2 ... </k>
    rule <k> I1 - I2 => I1 -Int I2 ... </k>
    rule <k> I1 * I2 => I1 *Int I2 ... </k>
    rule <k> I1 / I2 => I1 /Int I2 ... </k>
    rule <k> I1 ^ I2 => I1 ^Int I2 ... </k>

    rule <k> I:Id => MEM[I] ... </k>
         <mem> MEM </mem>

 // ------------------------------------------------
    rule <k> I1 <= I2 => I1  <=Int I2 ... </k>
    rule <k> I1  < I2 => I1   <Int I2 ... </k>
    rule <k> I1 >= I2 => I1  >=Int I2 ... </k>
    rule <k> I1  > I2 => I1   >Int I2 ... </k>
    rule <k> I1 == I2 => I1  ==Int I2 ... </k>
    rule <k> I1 != I2 => I1 =/=Int I2 ... </k>

    rule <k> B1 && B2 => B1 andBool B2 ... </k>
    rule <k> B1 || B2 => B1  orBool B2 ... </k>

    rule <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

    rule <k> ID = I:Int ; => . ... </k>
         <mem> MEM => MEM [ ID <- I ] </mem>
endmodule
