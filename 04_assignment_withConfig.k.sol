module ASSIGNMENT-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID

    syntax Exp ::= IExp | BExp

    syntax IExp ::= Id | Int

    syntax IExp ::= "(" IExp ")" [bracket]
                  | IExp "+" IExp
                  | IExp "-" IExp
                  > IExp "*" IExp
                  | IExp "/" IExp
                  > IExp "^" IExp

    syntax BExp ::= Bool

    syntax BExp ::= "(" BExp ")" [bracket]
                  | IExp "<=" IExp
                  | IExp "<"  IExp
                  | IExp ">=" IExp
                  | IExp ">"  IExp
                  | IExp "==" IExp
                  | IExp "!=" IExp

    syntax BExp ::= BExp "&&" BExp
                  | BExp "||" BExp

    syntax Stmt ::= Id "=" IExp ";"
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

    rule <k> IE:IExp => evalI(IE) ... </k> requires notBool isInt(IE)
    rule <k> BE:BExp => evalB(BE) ... </k> requires notBool isBool(BE)

    syntax Int ::= evalI ( IExp ) [function]
 // ----------------------------------------------
    rule evalI(I1 + I2) => evalI(I1) +Int evalI(I2)
    rule evalI(I1 - I2) => evalI(I1) -Int evalI(I2)
    rule evalI(I1 * I2) => evalI(I1) *Int evalI(I2)
    rule evalI(I1 / I2) => evalI(I1) /Int evalI(I2)
    rule evalI(I1 ^ I2) => evalI(I1) ^Int evalI(I2)

    rule evalI(I:Int) => I

    rule [[ evalI(I:Id)  => {MEM [ I ]}:>Int ]]
         <mem> MEM </mem>

    syntax Bool ::= evalB ( BExp ) [function]
 // -----------------------------------------------
    rule evalB(I1 <= I2) => evalI(I1)  <=Int evalI(I2)
    rule evalB(I1  < I2) => evalI(I1)   <Int evalI(I2)
    rule evalB(I1 >= I2) => evalI(I1)  >=Int evalI(I2)
    rule evalB(I1  > I2) => evalI(I1)   >Int evalI(I2)
    rule evalB(I1 == I2) => evalI(I1)  ==Int evalI(I2)
    rule evalB(I1 != I2) => evalI(I1) =/=Int evalI(I2)

    rule evalB(B1 && B2) => evalB(B1) andBool evalB(B2)
    rule evalB(B1 || B2) => evalB(B1)  orBool evalB(B2)

    rule evalB(true ) => true
    rule evalB(false) => false

    rule <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

    rule <k> ID = IE ; => . ... </k>
         <mem> MEM => MEM [ ID <- evalI(IE) ] </mem>
endmodule
