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
                  | IExp "+" IExp [seqstrict]
                  | IExp "-" IExp [seqstrict]
                  > IExp "*" IExp [seqstrict]
                  | IExp "/" IExp [seqstrict]
                  > IExp "^" IExp [seqstrict]
                  | Id "(" Exps ")" [strict(2)]

    syntax BExp ::= Bool

    syntax BExp ::= "(" BExp ")" [bracket]
                  | IExp "<=" IExp [seqstrict]
                  | IExp "<"  IExp [seqstrict]
                  | IExp ">=" IExp [seqstrict]
                  | IExp ">"  IExp [seqstrict]
                  | IExp "==" IExp [seqstrict]
                  | IExp "!=" IExp [seqstrict]

    syntax BExp ::= BExp "&&" BExp
                  | BExp "||" BExp

    syntax Stmt ::= 
         Id "=" IExp ";" [strict(2)]                        // Assignment
       | Stmt Stmt [left]                                   // Sequence
       | Block                                              // Block
       | "if" "(" BExp ")" Block "else" Block [strict(1)]   // If conditional
       | "while" "(" BExp ")" Block                         // While loop
       | "return" IExp ";"                    [seqstrict]   // Return statement
       | "def" Id "(" Ids ")" Block                         // Function definition

    syntax Block ::= 
         "{" Stmt "}"    // Block with statement
       | "{" "}"         // Empty block
endmodule

module PROCEDURES
    imports INT
    imports BOOL
    imports LIST
    imports MAP
    imports PROCEDURES-SYNTAX

    configuration
      <k> $PGM:Stmt </k>
      <store> .Map </store>
      <funcs> .Map </funcs>
      <stack> .List </stack>

 // -----------------------------------------------
    rule <k> I1 + I2 => I1 +Int I2 ... </k>
    rule <k> I1 - I2 => I1 -Int I2 ... </k>
    rule <k> I1 * I2 => I1 *Int I2 ... </k>
    rule <k> I1 / I2 => I1 /Int I2 ... </k>
    rule <k> I1 ^ I2 => I1 ^Int I2 ... </k>

    rule <k> I:Id => STORE[I] ... </k>
         <store> STORE </store>

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
         <store> STORE => STORE [ ID <- I ] </store>

    rule <k> { S } => S ... </k>
    rule <k> {   } => . ... </k>

    rule <k> if (true)   THEN else _ELSE => THEN ... </k>
    rule <k> if (false) _THEN else  ELSE => ELSE ... </k>

    rule <k> while ( BE ) BODY => if ( BE ) { BODY while ( BE ) BODY } else { } ... </k>

    rule <k> def FNAME ( ARGS ) BODY => . ... </k>
         <funcs> FS => FS [ FNAME <- def FNAME ( ARGS ) BODY ] </funcs>

    rule <k> FNAME ( IS:Ints ) ~> CONT => #makeBindings(ARGS, IS) ~> BODY </k>
         <funcs> ... FNAME |-> def FNAME ( ARGS ) BODY ... </funcs>
         <store> STORE => .Map </store>
         <stack> .List => ListItem(state(CONT, STORE)) ... </stack>

    rule <k> return I:Int ; ~> _ => I ~> CONT </k>
         <stack> ListItem(state(CONT, STORE)) => .List ... </stack>
         <store> _ => STORE </store>

    rule <k> return I:Int ; ~> . => I </k>
         <stack> .List </stack>

    syntax KItem ::= #makeBindings(Ids, Ints)
                   | state(continuation: K, store: Map)
 // ----------------------------------------------------
    rule <k> #makeBindings(.Ids, .Ints) => . ... </k>
    rule <k> #makeBindings((I:Id, IDS => IDS), (IN:Int, INTS => INTS)) ... </k>
         <store> STORE => STORE [ I <- IN ] </store>
endmodule
