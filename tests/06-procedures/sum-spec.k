requires "../../06-procedures/procedures.k"
requires "domains.md"

module SUM-SPEC-SYNTAX
    imports PROCEDURES-SYNTAX

    syntax Id ::= "$n" [token] | "$s" [token] | "$sum" [token]
endmodule

module VERIFICATION
    imports K-EQUAL
    imports SUM-SPEC-SYNTAX
    imports PROCEDURES

    rule ((K |->  V) _M) [ K' ] => V         requires K  ==K K' [simplification]
    rule ((K |-> _V)  M) [ K' ] => M [ K' ]  requires K =/=K K' [simplification]

    rule ((K |-> _V) M) [ K' <- V' ] => (K |-> V') M               requires K  ==K K' [simplification]
    rule ((K |->  V) M) [ K' <- V' ] => (K |-> V) (M [ K' <- V' ]) requires K =/=K K' [simplification]
endmodule

module SUM-SPEC
    imports VERIFICATION

    claim <k> while ( 0 < NID ) {
                SID = SID + NID ;
                NID = NID - 1 ;
              }
           => . ... </k>
          <store> SID |-> (S:Int => S +Int ((N +Int 1) *Int N /Int 2))
                NID |-> (N:Int => 0)
          </store>
      requires N >=Int 0
       andBool S >=Int 0

    claim <k> def $sum($n, .Ids) {
                $s = 0 ;
                while (0 < $n) {
                  $s = $s + $n ;
                  $n = $n - 1 ;
                }
                return $s ;
              }
              return $sum(N:Int, .Ints) ;
           => return (N +Int 1) *Int N /Int 2 ;
          </k>
          <funcs> .Map => ?_ </funcs>
          <store> .Map => ?_ </store>
          <stack> .List </stack>
      requires N >=Int 0

endmodule

