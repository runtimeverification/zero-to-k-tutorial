module SUBST-SYNTAX
   imports INT-SYNTAX   // Int is the K built-in integer sort
   imports BOOL-SYNTAX  // Bool is the K built-in Boolean sort
   imports ID           // Id is the K built-in sort for identifiers (variables)

   // Expressions are either integer or Boolean expressions
   syntax Exp ::= IExp | BExp

   // An integer expression is either an integer value or a variable identifier
   syntax IExp ::= Int | Id 
   // or any of the arithmetic operators
   syntax IExp ::=  IExp "^" IExp
                  | IExp "*" IExp
                  | IExp "/" IExp
                  > IExp "+" IExp
                  | IExp "-" IExp
   // or a bracketed integer expression
   syntax IExp ::= "(" IExp ")" [bracket]
                  
   // A Boolean expression is either a Boolean value
   syntax BExp ::= Bool
   // or any of the comparison operators
   syntax BExp ::=  IExp "<=" IExp
                  | IExp "<"  IExp
                  | IExp ">=" IExp
                  | IExp ">"  IExp
                  | IExp "==" IExp
                  | IExp "!=" IExp
   // or any of the propositional connectives
   syntax BExp ::=  BExp "&&" BExp
                  | BExp "||" BExp
   // or a bracketed Boolean expression
   syntax BExp ::= "(" BExp ")" [bracket]
endmodule

module SUBST
   imports INT
   imports BOOL
   imports MAP
   imports SUBST-SYNTAX

   configuration
      // K cell, containing the expression to be evaluated
      <k> $PGM:Exp </k>
      // Variable store, modelled as a K map
      <store> 
         #token("a", "Id") |-> 16
         #token("b", "Id") |-> 8
         #token("c", "Id") |-> 4
         #token("d", "Id") |-> 2
      </store>


   // Integer expression evaluation via explicit substitution 
   rule 
      <k> IE:IExp => substI(IE, STORE) ... </k>
      <store> STORE </store>
      requires notBool isInt(IE)

   // Boolean expression evaluation via explicit substitution 
   rule 
      <k> BE:BExp => substB(BE, STORE) ... </k>
      <store> STORE </store>
      requires notBool isBool(BE)

   // Integer expression substitution
   syntax Int ::= substI ( IExp , Map ) [function]
 
   // Base case: integer values evaluate to themselves
   rule substI(I:Int, _SUBST) => I

   // Base case: identifiers evaluate to their value in the store
   rule substI(I:Id, SUBST) => {SUBST [ I ]}:>Int

   // Inductive cases 
   rule substI(I1 + I2, SUBST) => substI(I1, SUBST) +Int substI(I2, SUBST)
   rule substI(I1 - I2, SUBST) => substI(I1, SUBST) -Int substI(I2, SUBST)
   rule substI(I1 * I2, SUBST) => substI(I1, SUBST) *Int substI(I2, SUBST)
   rule substI(I1 / I2, SUBST) => substI(I1, SUBST) /Int substI(I2, SUBST)
   rule substI(I1 ^ I2, SUBST) => substI(I1, SUBST) ^Int substI(I2, SUBST)

   // Boolean expression substitution
   syntax Bool ::= substB ( BExp , Map ) [function]

   // Base case: Boolean values evaluate to themselves
   rule substB(B:Bool , _SUBST) => B

   // Inductive cases 
   rule substB(I1 <= I2, SUBST) => substI(I1, SUBST)  <=Int substI(I2, SUBST)
   rule substB(I1  < I2, SUBST) => substI(I1, SUBST)   <Int substI(I2, SUBST)
   rule substB(I1 >= I2, SUBST) => substI(I1, SUBST)  >=Int substI(I2, SUBST)
   rule substB(I1  > I2, SUBST) => substI(I1, SUBST)   >Int substI(I2, SUBST)
   rule substB(I1 == I2, SUBST) => substI(I1, SUBST)  ==Int substI(I2, SUBST)
   rule substB(I1 != I2, SUBST) => substI(I1, SUBST) =/=Int substI(I2, SUBST)
   rule substB(B1 && B2, SUBST) => substB(B1, SUBST) andBool substB(B2, SUBST)
   rule substB(B1 || B2, SUBST) => substB(B1, SUBST)  orBool substB(B2, SUBST)
endmodule
