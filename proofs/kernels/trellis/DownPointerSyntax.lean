import kernels.trellis.GatePointerSyntax
namespace Inference.Kernels.Trellis.DownPointerSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000
inductive Expr where
  | variable : String → Expr
  | uint : Nat → Expr
  | ulong : Nat → Expr
  | castULong : Expr → Expr
  | add : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  | divide : Expr → Expr → Expr
  | modulo : Expr → Expr → Expr
  | logicalNot : Expr → Expr
  | conditional : Expr → Expr → Expr → Expr
  deriving DecidableEq,Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')',';','=','+','*','/','%','?',':','!'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def literal (token : String) : Option Expr :=
  let chars := token.toList
  if chars.getLast?=some 'l' ∧ chars.dropLast.getLast?=some 'u' then
    (Copy.ScalarCopySyntax.decimal (String.ofList chars.dropLast.dropLast)).map Expr.ulong
  else if chars.getLast?=some 'u' then
    (Copy.ScalarCopySyntax.decimal (String.ofList chars.dropLast)).map Expr.uint
  else none

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "+" => some (1,Expr.add)
  | "*" => some (2,Expr.multiply)
  | "/" => some (2,Expr.divide)
  | "%" => some (2,Expr.modulo)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0,_,_ => none
    | fuel+1,minimum,ts => do
      let (left,rest) ←primary fuel ts
      let (left,rest) ←climb fuel minimum left rest
      if minimum=0 then match rest with
        | "?"::rest => do
          let (yes,rest) ←expression fuel 0 rest
          let rest ←accept ":" rest
          let (no,rest) ←expression fuel 0 rest
          pure (.conditional left yes no,rest)
        | _ => some (left,rest)
      else some (left,rest)
  def primary : Nat → Parser Expr
    | 0,_ => none
    | fuel+1,"("::"ulong"::")"::rest => do
      let (value,rest) ←primary fuel rest
      pure (.castULong value,rest)
    | fuel+1,"!"::rest => do
      let (value,rest) ←primary fuel rest
      pure (.logicalNot value,rest)
    | fuel+1,"("::rest => do
      let (value,rest) ←expression fuel 0 rest
      let rest ←accept ")" rest
      pure (value,rest)
    | _+1,token::rest => match literal token with
      | some value => some (value,rest)
      | none => do
        let (name,rest) ←nameToken (token::rest)
        pure (.variable name,rest)
    | _+1,[] => none
  def climb : Nat → Nat → Expr → Parser Expr
    | 0,_,_,_ => none
    | fuel+1,minimum,left,ts => match ts with
      | token::rest => match operator token with
        | some (precedence,combine) =>
          if minimum≤precedence then do
            let (right,rest) ←expression fuel (precedence+1) rest
            climb fuel minimum (combine left right) rest
          else some (left,ts)
        | none => some (left,ts)
      | [] => some (left,[])
end
structure Declaration where
  name : String
  value : Expr
  deriving DecidableEq,Repr

def parse (pointer : Bool) (source : String) : Option Declaration := do
  let tokens ←lexAux (source.length+1) source.toList
  let rest ←if pointer then do
    let rest ←accept "const" tokens
    let rest ←accept "device" rest
    let rest ←accept "uint32_t" rest
    accept "*" rest
    else do
      let rest ←accept "constexpr" tokens
      accept "ulong" rest
  let (name,rest) ←nameToken rest
  let rest ←accept "=" rest
  let (value,rest) ←expression 32 0 rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨name,value⟩ else none

def strideSource : String := "constexpr ulong ROWW = INTERLEAVE ? 2ul * WPB : (ulong)NB * WPB;"
def blockSource : String := "const device uint32_t* blockWords = codes + (!active ? 0ul : INTERLEAVE\n    ? (ulong)(blk / 2u) * (ulong)R * 2ul * WPB + (blk % 2u) * WPB : (ulong)blk * WPB);"
def pairSource : String := "const device uint32_t* rowWords = blockWords + (ulong)(r0 + r + u) * ROWW;"
def tailSource : String := "const device uint32_t* rowWords = blockWords + (ulong)(r0 + r) * ROWW;"
private def v := Expr.variable
open Expr in
def stride : Declaration := ⟨"ROWW",conditional (v "INTERLEAVE") (multiply (ulong 2) (v "WPB")) (multiply (castULong (v "NB")) (v "WPB"))⟩
open Expr in
def block : Declaration := ⟨"blockWords",add (v "codes")
  (conditional (logicalNot (v "active")) (ulong 0)
    (conditional (v "INTERLEAVE")
      (add (multiply (multiply (multiply (castULong (divide (v "blk") (uint 2))) (castULong (v "R"))) (ulong 2)) (v "WPB"))
        (multiply (modulo (v "blk") (uint 2)) (v "WPB")))
      (multiply (castULong (v "blk")) (v "WPB"))))⟩
open Expr in
def pair : Declaration := ⟨"rowWords",add (v "blockWords")
  (multiply (castULong (add (add (v "r0") (v "r")) (v "u"))) (v "ROWW"))⟩
open Expr in
def tail : Declaration := ⟨"rowWords",add (v "blockWords")
  (multiply (castULong (add (v "r0") (v "r"))) (v "ROWW"))⟩
theorem parsed_stride : parse false strideSource=some stride := by decide +kernel
theorem parsed_block : parse true blockSource=some block := by decide +kernel
theorem parsed_pair : parse true pairSource=some pair := by decide +kernel
theorem parsed_tail : parse true tailSource=some tail := by decide +kernel
end Inference.Kernels.Trellis.DownPointerSyntax
