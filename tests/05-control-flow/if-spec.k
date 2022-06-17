requires "../../05-control-flow/control-flow.k"
requires "domains.md"

module IF-SPEC-SYNTAX
    imports CONTROL-FLOW-SYNTAX

    syntax Id ::= "$a" [token]
                | "$b" [token]
                | "$c" [token]
endmodule

module VERIFICATION
    imports IF-SPEC-SYNTAX
    imports CONTROL-FLOW

    rule maxInt(X, Y) => Y requires         X <Int Y [simplification]
    rule maxInt(X, Y) => X requires notBool X <Int Y [simplification]

    rule { MAP [ K <- V' ] #Equals MAP [ K <- V ] } => { V' #Equals V } [simplification, anywhere]
endmodule

module IF-SPEC
    imports VERIFICATION

    claim <k> if ( 3 < 4 ) {
                $c = 1 ;
              } else {
                $c = 2 ;
              }
           => . ... </k>
          <store> STORE => STORE [ $c <- 1 ] </store>

    claim <k> $a = A:Int ; $b = B:Int ;
              if (A < B) {
                $c = B ;
              } else {
                $c = A ;
              }
           => . ... </k>
          <store> STORE => STORE [ $a <- A ] [ $b <- B ] [ $c <- ?C:Int ] </store>
      ensures A <=Int ?C
      andBool B <=Int ?C

    claim <k> $a = A:Int ; $b = B:Int ;
              if (A < B) {
                $c = B ;
              } else {
                $c = A ;
              }
           => . ... </k>
          <store> STORE => STORE [ $a <- A ] [ $b <- B ] [ $c <- maxInt(A, B) ] </store>

endmodule
