# Example 5: Control flow

In this exercise, we take the [previous exercise](../04-assignment/README.md) and extend the syntax of commands with blocks of commands and some control flow constructs, such as the `if`-`else` conditional statement and the `while` loop:

```k
   ...

   // Statements
   syntax Stmt ::= 
        Id "=" IExp ";"                    [strict(2)] // Assignment
      | Stmt Stmt                          [left]      // Sequence           
      | "{" Stmt "}"                                   // Block statement
      | "{"      "}"                                   // Empty block
      | "if" "(" BExp ")" Stmt "else" Stmt [strict(1)] // If conditional
      | "while" "(" BExp ")" Stmt                      // While loop
      
   ...
```

The semantics of commands is also extended, as follows:

```k
   // Assignment
   rule <k> ID = I:Int ; => . ... </k>
        <mem> MEM => MEM [ ID <- I ] </mem>

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
```

The block-statement rules are straightforward: the non-empty block evaluates to the command in the block, and the empty block evaluates to nothing. There are two `if`-rules, also straightforward, one per each of the branches, depending on the value of the Boolean condition. The `while` loop is transformed into an equivalent `if` statement that checks the loop condition and: if it is true, executes the sequence of the loop body, followed by the original while loop; and otherwise, exits the loop altogether. this is a common approach in small-step programming-language semantics.

## Compiling and running the exercise

Follow the instructions from the top-level [`README`](../README.md) file to compile these two exercises and run the provided tests. Create some further examples to check if they yield the expected results.

## Proving program properties

This exercise also comes with two examples that demonstrate how `K` can be used to verify program properties by means of symbolic execution, [if-spec.k](../tests/05-control-flow/if-spec.k) and [while-spec.k](../tests/05-control-flow/while-spec.k). The examples can be run by executing 

```make tests/[exercise-folder]/[test-file].kprove```

in the root folder. The proofs pass if the output equals `#Top`. Additionally, you can step through the proofs in the debugger by executing `kprove --debugger [path-to-file]`. To enable definition pretty-printing, you can run the command `alias konfig = config | kast --input kore --output pretty /dev/stdin` inside the repl.

### Proofs about `if` statements: `if-spec.k`

We first specify several programs that use `if` statements. To this end, we define several variables that we will use (`$a`, `$b`, and `$c` in the `SIMPLE-SPEC-SYNTAX` module), together with some simplifications in the `VERIFICATION` module, which we will address shortly, when describing the proofs.

```k
requires "../../05-control-flow/control-flow.k"
requires "domains.md"

module SIMPLE-SPEC-SYNTAX
    imports CONTROL-FLOW-SYNTAX

    syntax Id ::= "$a" [token]
                | "$b" [token]
                | "$c" [token]
endmodule

module VERIFICATION
    imports SIMPLE-SPEC-SYNTAX
    imports CONTROL-FLOW

    rule { MAP [ K <- V' ] #Equals MAP [ K <- V ] } => { V' #Equals V } [simplification, anywhere]

    rule maxInt(X, Y) => Y requires         X <Int Y [simplification]
    rule maxInt(X, Y) => X requires notBool X <Int Y [simplification]
endmodule
```

The first claim to prove is the following:

```k
claim 
   <k> 
      if ( 3 < 4 ) {
         $c = 1 ;
      } else {
         $c = 2 ;
      } => . ... 
   </k>
   <store> STORE => STORE [ $c <- 1 ] </store>
```

and it states that the execution of the given program only updates the value of `$c` in the variable store to `1`, which is evident, given that the "then" branch of the code will be executed since `3` is less than `4`. The second claim:

```k
claim 
   <k> 
      $a = A:Int ; $b = B:Int ;
      if (A < B) {
         $c = B ;
      } else {
         $c = A ;
      } => . ... 
   </k>
   <store> STORE => STORE [ $a <- A ] [ $b <- B ] [ $c <- ?C:Int ] </store>
   ensures A <=Int ?C andBool
           B <=Int ?C
```

introduces two symbolic integers, `A` and `B`, and states that after the execution of the given program, the store will have been updated so that the value of `$a` equals `A`, the value of `$b` equals `B`, and the value of `$c` equals *some* symbolic integer `?C` such that `A <= C` and `B <= C`. More precisely, for symbolic variables, the notation `?` denotes *existential quantification*, whereas the absence of `?` (for example, the way `A` and `B` are introduced) denotes *universal quantification*. The `ensures` clause corresponds to a post-condition of sorts, stating conditions that must hold after the execution. The last claim states precisely what the value of `?C` is, replacing it with the function `maxInt(A, B)`, defined in the `VERIFICATION` module as the greater of the two parameters.

```k
claim 
   <k> 
      $a = A:Int ; $b = B:Int ;
      if (A < B) {
         $c = B ;
      } else {
         $c = A ;
      } => . ... 
   </k>
   <store> STORE => STORE [ $a <- A ] [ $b <- B ] [ $c <- maxInt(A, B) ] </store>
```

#### Aside: Simplifications

The `maxInt` function used in the last claim is defined via two simplifications, which can be thought of as hints that `K` can use to simplify the current configuration. For example, given the `maxInt` simplifications

```k
rule maxInt(X, Y) => Y requires         X <Int Y [simplification]
rule maxInt(X, Y) => X requires notBool X <Int Y [simplification]
```

the first one states that `maxInt(X, Y)` simplifies to `Y` whenever `X` is smaller than `Y`, and the second one states that it simplifies to `X` otherwise, effectively meaning that `maxInt(X, Y)` represents the greater of the two parameters. The third simplification in the `VERIFICATION` module is more interesting:

```k
rule { MAP [ K <- V' ] #Equals MAP [ K <- V ] } => { V' #Equals V } [simplification, anywhere]
```

and what it states is that if two maps are equal, then the values for the same keys in each of them have to be the same.

### Proofs about `while` loops: `while-spec.k`

Next, we use `K` to prove, albeit indirectly, that the sum of the first `N` integers equals `(N * (N + 1)) / 2`. We do so by proving the following claim:

```k
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
```

which states that after the given `while` loop, which, in each iteration, adds the value of `$n` to `$s`, the value of `$n` equals `0` and the value of `$s` has been incremented by `(N * (N + 1)) / 2`, where `N` is the (symbolic) initial value of `$n`.