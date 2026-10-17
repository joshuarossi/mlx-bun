import kernels.trellis.CodebookIntegerSyntax

namespace Inference.Kernels.Quantization.MlxQmvDot4Syntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
abbrev Index := Trellis.CodebookIntegerSyntax.Expr
set_option maxRecDepth 10000

-- Restricted syntax for the actual four-bit accumulation statement. Integer
-- subscripts, masks, multiplication and left-associated addition are retained.
inductive Expr where
  | input : String → Index → Expr
  | masked : String → Index → Nat → Expr
  | multiply : Expr → Expr → Expr
  | add : Expr → Expr → Expr
  deriving DecidableEq, Repr
structure Statement where
  target : String
  value : Expr
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','[',']',';','=','+','*','&'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none
def tokenize (source : String) := lexAux (source.length+1) source.toList

def mask (token : String) : Option Nat :=
  match token.toList with
  | '0'::'x'::digits => Trellis.CodebookIntegerSyntax.hex digits
  | _ => none

def indexed : Parser (String × Index) := fun tokens => do
  let (array,rest) ←nameToken tokens
  let rest ←accept "[" rest
  let (index,rest) ←Trellis.CodebookIntegerSyntax.expression 8 0 rest
  let rest ←accept "]" rest
  pure ((array,index),rest)

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "+" => some (1,Expr.add)
  | "*" => some (2,Expr.multiply)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0,_,_ => none
    | fuel+1,minimum,tokens => do
      let (first,rest) ←primary fuel tokens
      climb fuel minimum first rest
  def primary : Nat → Parser Expr
    | 0,_ => none
    | _+1,"("::"ws"::"["::rest => do
      let (index,rest) ←Trellis.CodebookIntegerSyntax.expression 8 0 rest
      let rest ←accept "]" rest
      let rest ←accept "&" rest
      let token::rest := rest | none
      let value ←mask token
      let rest ←accept ")" rest
      pure (.masked "ws" index value,rest)
    | fuel+1,"("::rest => do
      let (value,rest) ←expression fuel 0 rest
      let rest ←accept ")" rest
      pure (value,rest)
    | _+1,rest => do
      let ((array,index),rest) ←indexed rest
      pure (.input array index,rest)
  def climb : Nat → Nat → Expr → Parser Expr
    | 0,_,_,_ => none
    | fuel+1,minimum,left,tokens => match tokens with
      | token::rest => match operator token with
        | some (precedence,combine) =>
          if minimum≤precedence then do
            let (right,rest) ←expression fuel (precedence+1) rest
            climb fuel minimum (combine left right) rest
          else some (left,tokens)
        | none => some (left,tokens)
      | [] => some (left,[])
end

def parseTokens (tokens : Tokens) : Option Statement := do
  let (target,rest) ←nameToken tokens
  let rest ←accept "+" rest
  let rest ←accept "=" rest
  let (value,rest) ←expression 16 0 rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨target,value⟩ else none

def parse (source : String) : Option Statement := (tokenize source).bind parseTokens

def sourceBody : String := "accum +=\n          (x_thread[4 * i] * (ws[i] & 0x000f) +\n           x_thread[4 * i + 1] * (ws[i] & 0x00f0) +\n           x_thread[4 * i + 2] * (ws[i] & 0x0f00) +\n           x_thread[4 * i + 3] * (ws[i] & 0xf000));"
def index (offset : Fin 4) : Index :=
  let base : Index := .multiply (.literal .signed 4) (.variable "i")
  if offset.val=0 then base else .add base (.literal .signed offset.val)
def product (offset : Fin 4) : Expr := .multiply (.input "x_thread" (index offset))
  (.masked "ws" (.variable "i") (15*2^(4*offset.val)))
def body : Statement := ⟨"accum",.add (.add (.add (product 0) (product 1)) (product 2)) (product 3)⟩
def sourceTokens : Tokens := ["accum","+","=","(","x_thread","[","4","*","i","]","*","(","ws","[","i","]","&","0x000f",")","+","x_thread","[","4","*","i","+","1","]","*","(","ws","[","i","]","&","0x00f0",")","+","x_thread","[","4","*","i","+","2","]","*","(","ws","[","i","]","&","0x0f00",")","+","x_thread","[","4","*","i","+","3","]","*","(","ws","[","i","]","&","0xf000",")",")",";"]
theorem lexed : tokenize sourceBody=some sourceTokens := by decide +kernel
theorem parsed_body : parse sourceBody=some body := by
  rw [parse,lexed,Option.bind_some]
  decide +kernel

end Inference.Kernels.Quantization.MlxQmvDot4Syntax
