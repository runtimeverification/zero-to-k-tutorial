requires "../../control-flow.k"
requires "domains.md"

module LOOPING-SPEC-SYNTAX
    imports CONTROL-FLOW-SYNTAX

    syntax Id ::= "$a" [token]
                | "$b" [token]
                | "$c" [token]
                | "$x" [token]
                | "$y" [token]
                | "$z" [token]
                | "$s" [token]
                | "$n" [token]
endmodule

module VERIFICATION
    imports LOOPING-SPEC-SYNTAX
    imports CONTROL-FLOW
endmodule

module LOOPING-SPEC
    imports VERIFICATION

    claim <k> while ( 0 < $n ) {
                $s = $s + $n ;
                $n = $n - 1 ;
              }
           => . ... </k>
          <mem> $s |-> (S:Int => S +Int ((N +Int 1) *Int N /Int 2))
                $n |-> (N:Int => 0)
          </mem>
      requires N >=Int 0
       andBool S >=Int 0

endmodule

