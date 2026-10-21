namespace Metal

/-! # Metal tokens

Tokens of the Metal Shading Language subset that MLX compiles for the route's
custom kernels: MLX's generated signature and instantiation, the kernel header
and the kernel body (proofs/metal/Lexer.lean produces them from the exact
source characters; proofs/metal/Preprocess.lean expands macros over them).

Numeric literals keep their exact value: an integer literal its value and
suffix, a floating literal the decimal `mantissa · 10^exponent` it spells, so
elaboration can round it to the literal's type as the compiler does. -/

inductive Tok where
  /-- Identifier or keyword (`for`, `const`, `device`, … are identifiers here;
  the parser tells them apart). -/
  | ident (name : List Char)
  /-- Integer literal: value, `u` suffix, `l` suffix, and whether it was spelled
  in hexadecimal (C++ gives unsuffixed hexadecimal literals unsigned types
  when they do not fit `int`). -/
  | int (value : Nat) (unsigned long hex : Bool)
  /-- Floating literal `mantissa · 10^exponent`, with its `f` suffix. -/
  | float (mantissa : Nat) (exponent : Int) (single : Bool)
  /-- String literal (MLX's `host_name("…")`), escapes resolved. -/
  | str (chars : List Char)
  /-- Operator or punctuation, longest match: `::` `->` `++` `--` `<<=` `>>=`
  `<<` `>>` `<=` `>=` `==` `!=` `&&` `||` `+=` `-=` `*=` `/=` `%=` `&=` `|=`
  `^=` and single characters `( ) [ ] { } , ; : . ? + - * / % & | ^ ~ ! = < >`. -/
  | punct (text : List Char)
  /-- `#pragma` with its remaining tokens (loop-unrolling hints). -/
  | pragma (tokens : List Tok)
  /-- `#define name body` (object-like) — removed by preprocessing. -/
  | defineObject (name : List Char) (body : List Tok)
  /-- `#define name(params) body` (function-like) — removed by preprocessing. -/
  | defineFunction (name : List Char) (params : List (List Char)) (body : List Tok)
  /-- Lexical error at the remaining characters. -/
  | err (rest : List Char)
deriving Repr, Inhabited

end Metal
