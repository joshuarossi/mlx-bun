import kernels.trellis.CodebookBitsSyntax
namespace Inference.Kernels.Trellis.GateTailSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar decimal)
set_option maxRecDepth 10000
inductive Expr where
  | variable : String → Expr
  | integer : Nat → Expr
  | floating : Nat → Nat → Expr
  | castT : Expr → Expr
  | castFloat : Expr → Expr
  | add : Expr → Expr → Expr
  | subtract : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  | divide : Expr → Expr → Expr
  | less : Expr → Expr → Expr
  | negative : Expr → Expr
  | absolute : Expr → Expr
  | exponential : Expr → Expr
  | preciseExp : Expr → Expr
  | choose : Expr → Expr → Expr → Expr
  deriving DecidableEq,Repr
inductive Statement where
  | constant : String → Expr → Statement
  | store : String → String → Expr → Statement
  deriving DecidableEq,Repr
structure Program where
  declarations : List Statement
  parameter : String
  selected : Nat
  yes : List Statement
  no : List Statement
  deriving DecidableEq,Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c || c='.' then do
      let word := fun c => wordChar c || c='.'
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else if c='=' then match rest with
      | '='::rest => do pure ("=="::(←lexAux fuel rest))
      | _ => do pure ("="::(←lexAux fuel rest))
    else if ['(',')','{','}','[',']',';',':','?','+','-','*','/','<'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def literal (token : String) : Option Expr := do
  match ←CodebookBitsSyntax.literal token with
  | .integer _ value => some (.integer value)
  | .floating mantissa scale => some (.floating mantissa scale)
  | _ => none

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "<" => some (1,Expr.less)
  | "+" => some (2,Expr.add)
  | "-" => some (2,Expr.subtract)
  | "*" => some (3,Expr.multiply)
  | "/" => some (3,Expr.divide)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0,_,_ => none
    | fuel+1,minimum,ts => do
      let (left,ts) ←primary fuel ts
      let (left,ts) ←climb fuel minimum left ts
      if minimum=0 then match ts with
        | "?"::ts => do
          let (yes,ts) ←expression fuel 0 ts
          let ts ←accept ":" ts
          let (no,ts) ←expression fuel 0 ts
          pure (.choose left yes no,ts)
        | _ => some (left,ts)
      else some (left,ts)
  def primary : Nat → Parser Expr
    | 0,_ => none
    | fuel+1,"T"::"("::ts => do
      let (value,ts) ←expression fuel 0 ts
      let ts ←accept ")" ts
      pure (.castT value,ts)
    | fuel+1,"float"::"("::ts => do
      let (value,ts) ←expression fuel 0 ts
      let ts ←accept ")" ts
      pure (.castFloat value,ts)
    | fuel+1,"metal"::":"::":"::name::"("::ts => do
      let (value,ts) ←expression fuel 0 ts
      let ts ←accept ")" ts
      if name="abs" then some (.absolute value,ts)
      else if name="exp" then some (.exponential value,ts) else none
    | fuel+1,"metal"::":"::":"::"precise"::":"::":"::"exp"::"("::ts => do
      let (value,ts) ←expression fuel 0 ts
      let ts ←accept ")" ts
      pure (.preciseExp value,ts)
    | fuel+1,"-"::ts => do
      let (value,ts) ←primary fuel ts
      pure (.negative value,ts)
    | fuel+1,"("::ts => do
      let (value,ts) ←expression fuel 0 ts
      let ts ←accept ")" ts
      pure (value,ts)
    | _+1,token::ts => match literal token with
      | some value => some (value,ts)
      | none => do
        let (name,ts) ←nameToken (token::ts)
        pure (.variable name,ts)
    | _+1,[] => none
  def climb : Nat → Nat → Expr → Parser Expr
    | 0,_,_,_ => none
    | fuel+1,minimum,left,ts => match ts with
      | token::rest => match operator token with
        | some (precedence,combine) => if minimum≤precedence then do
          let (right,rest) ←expression fuel (precedence+1) rest
          climb fuel minimum (combine left right) rest
          else some (left,ts)
        | none => some (left,ts)
      | [] => some (left,[])
end

def statement : Parser Statement
  | "const"::"T"::ts => do
    let (name,ts) ←nameToken ts
    let ts ←accept "=" ts
    let (value,ts) ←expression 64 0 ts
    let ts ←accept ";" ts
    pure (.constant name value,ts)
  | ts => do
    let (target,ts) ←nameToken ts
    let ts ←accept "[" ts
    let (index,ts) ←nameToken ts
    let ts ←accept "]" ts
    let ts ←accept "=" ts
    let (value,ts) ←expression 64 0 ts
    let ts ←accept ";" ts
    pure (.store target index value,ts)

def statements : Nat → Parser (List Statement)
  | 0,_ => none
  | _+1,"}"::ts => some ([],ts)
  | fuel+1,ts => do
    let (first,ts) ←statement ts
    let (rest,ts) ←statements fuel ts
    pure (first::rest,ts)

def program : Parser Program := fun ts => do
  let (gate,ts) ←statement ts
  let (up,ts) ←statement ts
  let ts ←accept "if" ts
  let ts ←accept "(" ts
  let ts ←accept "(" ts
  let (parameter,ts) ←nameToken ts
  let ts ←accept ")" ts
  let ts ←accept "==" ts
  let (selected,ts) ←match ts with
    | token::ts => do pure (←decimal token,ts)
    | [] => none
  let ts ←accept ")" ts
  let ts ←accept "{" ts
  let (yes,ts) ←statements 8 ts
  let ts ←accept "else" ts
  let ts ←accept "{" ts
  let (no,ts) ←statements 8 ts
  pure (⟨[gate,up],parameter,selected,yes,no⟩,ts)

def parse (source : String) : Option Program := do
  let (actual,rest) ←program (←tokenize source)
  if rest=[] then some actual else none

def source : String := "const T gateT = T(gate);\n      const T upT = T(up);\n      if ((TAIL) == 1) {\n        const T sigY = 1 / (1 + metal::exp(metal::abs(gateT)));\n        const T sigmoidT = (gateT < 0) ? sigY : 1 - sigY;\n        const T siluT = gateT * sigmoidT;\n        mid[row] = siluT * upT;\n      } else {\n        const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));\n        const T siluT = T(float(gateT) * float(sigmoidT));\n        mid[row] = T(float(siluT) * float(upT));\n      }"
open Expr in
def code : Program := ⟨[.constant "gateT" (castT (Expr.variable "gate")),.constant "upT" (castT (Expr.variable "up"))],"TAIL",1,
  [.constant "sigY" (divide (integer 1) (add (integer 1) (exponential (absolute (Expr.variable "gateT"))))),
   .constant "sigmoidT" (choose (less (Expr.variable "gateT") (integer 0)) (Expr.variable "sigY") (subtract (integer 1) (Expr.variable "sigY"))),
   .constant "siluT" (multiply (Expr.variable "gateT") (Expr.variable "sigmoidT")),
   .store "mid" "row" (multiply (Expr.variable "siluT") (Expr.variable "upT"))],
  [.constant "sigmoidT" (castT (divide (floating 10 1) (add (floating 10 1) (preciseExp (negative (castFloat (Expr.variable "gateT"))))))),
   .constant "siluT" (castT (multiply (castFloat (Expr.variable "gateT")) (castFloat (Expr.variable "sigmoidT")))),
   .store "mid" "row" (castT (multiply (castFloat (Expr.variable "siluT")) (castFloat (Expr.variable "upT"))))]⟩

theorem parsed : parse source=some code := by decide +kernel
end Inference.Kernels.Trellis.GateTailSyntax
