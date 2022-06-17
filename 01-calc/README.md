# Example 1: Calculator

Our first example is that of a calculator that works with simple integer arithmetic, that is, addition, subtraction, multiplication, division, and exponentiation, and the first step is to define the appropriate syntax. This can be done in `K` as follows:

```k
// Calculator syntax
module CALC-SYNTAX
    imports INT-SYNTAX  // Int is the K built-in integer sort

    // Integer arithmetic syntax
    syntax Int ::= 
        "(" Int ")" [bracket]   
      > left:                   // left: indicates left associativity 
        Int "^" Int [function]  // and > indicates lower priority of below productions
      > left:                   
        Int "*" Int [function] 
      | Int "/" Int [function]
      > left:
        Int "+" Int [function]  
      | Int "-" Int [function] 
endmodule
```

The next step is to define the calculator semantics by providing the set of appropriate rewriting rules of the format `[LHS] => [RHS]`, as follows:

```k
// Calculator semantics
module CALC
    imports INT
    imports CALC-SYNTAX 

    // Integer arithmetic semantics
    rule E1 + E2 => E1 +Int E2
    rule E1 - E2 => E1 -Int E2
    rule E1 * E2 => E1 *Int E2
    rule E1 / E2 => E1 /Int E2
    rule E1 ^ E2 => E1 ^Int E2
endmodule
```

`K` applies these rewriting rules, informally, by matching the `[LHS]` to the current expression and then rewriting that matched part to `[RHS]`. For example, `1 + 2` matches `E1 + E2` syntactically (with `1` matching `E1`, `+` matching `+` and `2` matching `E2`), which then, by the first rule, is rewritten to `1 +Int 2`, and then further evaluated via semantic integer addition to `3`.

## Compiling and running the calculator

Follow the instructions from the top-level [`README`](../README.md) file to compile the calculator and run the first test. This yields the following output:

```
Input
=====
1 + 2 + 3

Output
======
<k>
  6 ~> .
</k>
```

which you can interpret, ignoring the `<k> ... <./k>` wrapper and the `~> .` in the `Output` portion, as "the expression `1 + 2 + 3` was successfully evaluated/rewritten to `6`".

You can experiment with modifying the tests, but also with modifying operator associativity and priority: for example, running `1.calc` with `+` not declared as left-associative (that is, `> Int "+" Int [function]` or `2.calc` with all operators being of the same priority (using `|` instead of `>`), both of which should result in parsing ambiguity errors. You would then have to use parentheses to manually disambiguate the parsing.