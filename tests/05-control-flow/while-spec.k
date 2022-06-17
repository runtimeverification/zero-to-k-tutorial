requires "../../05-control-flow/control-flow.k"
requires "domains.md"

module WHILE-SPEC-SYNTAX
    imports CONTROL-FLOW-SYNTAX

    syntax Id ::= "$s" [token]
                | "$n" [token]
endmodule

module VERIFICATION
    imports WHILE-SPEC-SYNTAX
    imports CONTROL-FLOW
endmodule

module WHILE-SPEC
    imports VERIFICATION

    claim 
        <k> 
            while ( 0 < $n ) {
                $s = $s + $n ;
                $n = $n - 1 ;
              } => . ... 
        </k>
        <store> 
            $s |-> (S:Int => S +Int ((N +Int 1) *Int N /Int 2))
            $n |-> (N:Int => 0)
        </store>
        requires N >=Int 0
endmodule

