import kernels.trellis.DownDispatchSource
namespace Inference.Kernels.Trellis.DownControlSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000
inductive Expr where
  | variable : String → Expr
  | uint : Nat → Expr
  | castUInt : Expr → Expr
  | add : Expr → Expr → Expr
  | subtract : Expr → Expr → Expr
  | divide : Expr → Expr → Expr
  | modulo : Expr → Expr → Expr
  | bitAnd : Expr → Expr → Expr
  | less : Expr → Expr → Expr
  | greaterEqual : Expr → Expr → Expr
  | equal : Expr → Expr → Expr
  | logicalNot : Expr → Expr
  | logicalAnd : Expr → Expr → Expr
  | minimum : Expr → Expr → Expr
  | conditional : Expr → Expr → Expr → Expr
  deriving DecidableEq,Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['<','>','=','&'].contains c then match rest with
      | d::tail => if d=c ∨ d='=' then do pure (String.ofList [c,d]::(←lexAux fuel tail))
        else do pure (String.singleton c::(←lexAux fuel rest))
      | [] => some [String.singleton c]
    else if ['(',')',';','+','-','/','%','?',':','!',','].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def literal (token : String) : Option Expr := do
  match ←CodebookIntegerSyntax.literal token with
  | .literal .unsigned n => some (.uint n)
  | _ => none

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "&&" => some (1,Expr.logicalAnd)
  | "==" => some (3,Expr.equal)
  | "<" => some (4,Expr.less)
  | ">=" => some (4,Expr.greaterEqual)
  | "&" => some (2,Expr.bitAnd)
  | "+" => some (5,Expr.add)
  | "-" => some (5,Expr.subtract)
  | "/" => some (6,Expr.divide)
  | "%" => some (6,Expr.modulo)
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
    | fuel+1,"("::"uint"::")"::rest => do
      let (value,rest) ←primary fuel rest
      pure (.castUInt value,rest)
    | fuel+1,"!"::rest => do
      let (value,rest) ←primary fuel rest
      pure (.logicalNot value,rest)
    | fuel+1,"metal"::":"::":"::"min"::"("::rest => do
      let (left,rest) ←expression fuel 0 rest
      let rest ←accept "," rest
      let (right,rest) ←expression fuel 0 rest
      let rest ←accept ")" rest
      pure (.minimum left right,rest)
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
  boolean : Bool
  value : Expr
  deriving DecidableEq,Repr

def parse (source : String) : Option Declaration := do
  let tokens ←lexAux (source.length+1) source.toList
  let rest ←accept "const" tokens
  let (boolean,rest) ←match rest with
    | "uint"::rest => some (false,rest)
    | "bool"::rest => some (true,rest)
    | _ => none
  let (name,rest) ←nameToken rest
  let rest ←accept "=" rest
  let (value,rest) ←expression 32 0 rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨name,boolean,value⟩ else none

def activeSource : String := "const bool active = colGroup < SGS && blk < NB;"
def shiftedSource : String := "const bool shifted = !ALIGNED && (li & 1u);"
def rowsSource : String := "const uint rows = !active ? 0u : (uint)R % (uint)SPLITS == 0u ? ROWS_PER : r0 >= (uint)R ? 0u : metal::min(ROWS_PER, (uint)R - r0);"
private def v := Expr.variable
open Expr in
def active : Declaration := ⟨"active",true,logicalAnd (less (v "colGroup") (v "SGS")) (less (v "blk") (v "NB"))⟩
open Expr in
def shifted : Declaration := ⟨"shifted",true,logicalAnd (logicalNot (v "ALIGNED")) (bitAnd (v "li") (uint 1))⟩
open Expr in
def rows : Declaration := ⟨"rows",false,conditional (logicalNot (v "active")) (uint 0)
  (conditional (equal (modulo (castUInt (v "R")) (castUInt (v "SPLITS"))) (uint 0)) (v "ROWS_PER")
    (conditional (greaterEqual (v "r0") (castUInt (v "R"))) (uint 0)
      (minimum (v "ROWS_PER") (subtract (castUInt (v "R")) (v "r0")))))⟩
theorem parsed_active : parse activeSource=some active := by decide +kernel
theorem parsed_shifted : parse shiftedSource=some shifted := by decide +kernel
theorem parsed_rows : parse rowsSource=some rows := by decide +kernel
end Inference.Kernels.Trellis.DownControlSyntax
