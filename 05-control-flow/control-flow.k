module CONTROL-FLOW-SYNTAX
   imports INT-SYNTAX   // Int is the K built-in integer sort
   imports BOOL-SYNTAX  // Bool is the K built-in Boolean sort
   imports ID           // Id is the K built-in sort for identifiers (variables)

   // Expressions are either integer or Boolean expressions
   syntax Exp ::= IExp | BExp

   // An integer expression is either an integer value or a variable identifier
   syntax IExp ::= Int | Id 
   // or any of the arithmetic operators
   syntax IExp ::=  IExp "^" IExp [seqstrict]
                  | IExp "*" IExp [seqstrict]
                  | IExp "/" IExp [seqstrict]
                  > IExp "+" IExp [seqstrict]
                  | IExp "-" IExp [seqstrict]
   // or a bracketed integer expression
   syntax IExp ::= "(" IExp ")" [bracket]
                  
   // A Boolean expression is either a Boolean value
   syntax BExp ::= Bool
   // or any of the comparison operators
   syntax BExp ::=  IExp "<=" IExp [seqstrict]
                  | IExp "<"  IExp [seqstrict]
                  | IExp ">=" IExp [seqstrict]
                  | IExp ">"  IExp [seqstrict]
                  | IExp "==" IExp [seqstrict]
                  | IExp "!=" IExp [seqstrict]
   // or any of the  propositional connectives
   syntax BExp ::=  BExp "&&" BExp [seqstrict]
                  | BExp "||" BExp [seqstrict]
   // or a bracketed Boolean expression
   syntax BExp ::= "(" BExp ")" [bracket]

   // Signal when expression evaluation should stop
   syntax KResult ::= Int | Bool
   
   // Statements
   syntax Stmt ::= 
        Id "=" IExp ";"                    [strict(2)] // Assignment
      | Stmt Stmt                          [left]      // Sequence           
      | "{" Stmt "}"                                   // Block statement
      | "{"      "}"                                   // Empty block
      | "if" "(" BExp ")" Stmt "else" Stmt [strict(1)] // If conditional
      | "while" "(" BExp ")" Stmt                      // While loop
endmodule

module CONTROL-FLOW
    imports INT
    imports BOOL
    imports MAP
    imports CONTROL-FLOW-SYNTAX

    configuration
      // K cell, containing the statement to be executed
      <k> $PGM:Stmt </k>
      // Variable store, modelled as a K map, initially empty
      <store> .Map </store>

   // Expression evaluation
   
   // Base case: Variables evaluate to their values in the store
   rule 
     <k> I:Id => STORE[I] ... </k>
     <store> STORE </store>

   // Arithmetic operators 
   rule <k> I1 + I2 => I1 +Int I2 ... </k>
   rule <k> I1 - I2 => I1 -Int I2 ... </k>
   rule <k> I1 * I2 => I1 *Int I2 ... </k>
   rule <k> I1 / I2 => I1 /Int I2 ... </k>
   rule <k> I1 ^ I2 => I1 ^Int I2 ... </k>

   // Comparison operators
   rule <k> I1 <= I2 => I1  <=Int I2 ... </k>
   rule <k> I1  < I2 => I1   <Int I2 ... </k>
   rule <k> I1 >= I2 => I1  >=Int I2 ... </k>
   rule <k> I1  > I2 => I1   >Int I2 ... </k>
   rule <k> I1 == I2 => I1  ==Int I2 ... </k>
   rule <k> I1 != I2 => I1 =/=Int I2 ... </k>

   // Propositional connectives
   rule <k> B1 && B2 => B1 andBool B2 ... </k>
   rule <k> B1 || B2 => B1  orBool B2 ... </k>

   // Assignment
   rule <k> ID = I:Int ; => . ... </k>
        <store> STORE => STORE [ ID <- I ] </store>

   // Sequencing
   rule <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

   // Block statements
   rule <k> { S } => S ... </k>
   rule <k> {   } => . ... </k>

   // If conditional
   rule <k> if (true)   THEN else _ELSE => THEN ... </k>
   rule <k> if (false) _THEN else  ELSE => ELSE ... </k>

   // While loop
   rule <k> while ( BE ) BODY => if ( BE ) { BODY while ( BE ) BODY } else { } ... </k>
endmodule