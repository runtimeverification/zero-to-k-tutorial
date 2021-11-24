module PROCEDURES-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID

    syntax Exp ::= IExp | BExp

    syntax IExp ::= Id | Int

    syntax KResult ::= Int | Bool | Ints

    // Take this sort structure:
    //
    //     IExp
    //    /    \
    // Int      Id
    //
    // Through the List{_, ","} functor.
    // Must add a `Bot`, for a common subsort for the empty list.

    syntax Bot
    syntax Bots ::= List{Bot, ","} [klabel(exps)]
    syntax Ints ::= List{Int, ","} [klabel(exps)]
                  | Bots
    syntax Ids  ::= List{Id, ","}  [klabel(exps)]
                  | Bots
    syntax Exps ::= List{Exp, ","} [klabel(exps), seqstrict]
                  | Ids | Ints

    syntax IExp ::= "(" IExp ")" [bracket]
                  | IExp "+" IExp [strict]
                  | IExp "-" IExp [strict]
                  > IExp "*" IExp [strict]
                  | IExp "/" IExp [strict]
                  > IExp "^" IExp [strict]
                  | Id "(" Exps ")" [strict(2)]

    syntax BExp ::= Bool

    syntax BExp ::= "(" BExp ")" [bracket]
                  | IExp "<=" IExp [strict]
                  | IExp "<"  IExp [strict]
                  | IExp ">=" IExp [strict]
                  | IExp ">"  IExp [strict]
                  | IExp "==" IExp [strict]
                  | IExp "!=" IExp [strict]

    syntax BExp ::= BExp "&&" BExp
                  | BExp "||" BExp

    syntax Stmt ::= Id "=" IExp ";" [strict(2)]
                  | Stmt Stmt [left]
                  | Block
                  | "if" "(" BExp ")" Block "else" Block [strict(1)]
                  | "while" "(" BExp ")" Block
                  | "return" IExp ";"                    [strict]
                  | "def" Id "(" Ids ")" Block

    syntax Block ::= "{" Stmt "}" | "{" "}"
endmodule

module PROCEDURES
    imports INT
    imports BOOL
    imports MAP
    imports LIST
    imports PROCEDURES-SYNTAX

    configuration
      <k> $PGM:Stmt </k>
      <mem> .Map </mem>
      <funcs> .Map </funcs>
      <stack> .List </stack>

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

    rule <k> { S } => S ... </k>
    rule <k> {   } => . ... </k>

    rule <k> if (true)   THEN else _ELSE => THEN ... </k>
    rule <k> if (false) _THEN else  ELSE => ELSE ... </k>

    rule <k> while ( BE ) BODY => if ( BE ) { BODY while ( BE ) BODY } else { } ... </k>

    rule <k> def FNAME ( ARGS ) BODY => . ... </k>
         <funcs> FS => FS [ FNAME <- def FNAME ( ARGS ) BODY ] </funcs>

    rule <k> FNAME ( IS:Ints ) ~> CONT => #makeBindings(ARGS, IS) ~> BODY </k>
         <funcs> ... FNAME |-> def FNAME ( ARGS ) BODY ... </funcs>
         <mem> MEM => .Map </mem>
         <stack> .List => ListItem(state(CONT, MEM)) ... </stack>

    rule <k> return I:Int ; ~> _ => I ~> CONT </k>
         <stack> ListItem(state(CONT, MEM)) => .List ... </stack>
         <mem> _ => MEM </mem>

    rule <k> return I:Int ; ~> . => I </k>
         <stack> .List </stack>

    syntax KItem ::= #makeBindings(Ids, Ints)
                   | state(continuation: K, memory: Map)
 // ----------------------------------------------------
    rule <k> #makeBindings(.Ids, .Ints) => . ... </k>
    rule <k> #makeBindings((I:Id, IDS => IDS), (IN:Int, INTS => INTS)) ... </k>
         <mem> MEM => MEM [ I <- IN ] </mem>
endmodule
