requires "../../control-flow.k"
requires "domains.md"

module SIMPLE-SPEC-SYNTAX
    imports CONTROL-FLOW-SYNTAX

    syntax Id ::= "$a" [token]
                | "$b" [token]
                | "$c" [token]
                | "$x" [token]
                | "$y" [token]
                | "$z" [token]
endmodule

module VERIFICATION
    imports SIMPLE-SPEC-SYNTAX
    imports CONTROL-FLOW

    rule maxInt(X, Y) => Y requires         X <Int Y [simplification]
    rule maxInt(X, Y) => X requires notBool X <Int Y [simplification]
endmodule

module SIMPLE-SPEC
    imports VERIFICATION

    claim <k> 3 + 4 => 7 ... </k>

    claim <k> if ( 3 < 4 ) {
                $c = 1 ;
              } else {
                $c = 2 ;
              }
           => . ... </k>
          <mem> MEM => MEM [ $c <- 1 ] </mem>

    claim <k> $a = A:Int ; $b = B:Int ;
              if (A < B) {
                $c = B ;
              } else {
                $c = A ;
              }
           => . ... </k>
          <mem> MEM => MEM [ $a <- A ] [ $b <- B ] [ $c <- ?C:Int ] </mem>
      requires A <=Int ?C
       andBool B <=Int ?C

    claim <k> $a = A:Int ; $b = B:Int ;
              if (A < B) {
                $c = B ;
              } else {
                $c = A ;
              }
           => . ... </k>
          <mem> MEM => MEM [ $a <- A ] [ $b <- B ] [ $c <- maxInt(A, B) ] </mem>

endmodule
