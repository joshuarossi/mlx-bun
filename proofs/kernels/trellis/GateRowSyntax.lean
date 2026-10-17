import kernels.trellis.GateTailSyntax
import kernels.trellis.GateInputSyntax

namespace Inference.Kernels.Trellis.GateRowSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
set_option maxRecDepth 10000
inductive Expr where
  | variable : String → Expr
  | builtin : String → String → Expr
  | literal : CodebookIntegerSyntax.LiteralKind → Nat → Expr
  | castUInt : Expr → Expr
  | add : Expr → Expr → Expr
  | multiply : Expr → Expr → Expr
  deriving DecidableEq,Repr
structure Constant where
  target : String
  value : Expr
  deriving DecidableEq,Repr
structure Loop where
  counter : String
  initial : Expr
  test : String
  bound : Expr
  step : String
  increment : Expr
  deriving DecidableEq,Repr
structure Writer where
  lane : String
  selected : Expr
  deriving DecidableEq,Repr

def operator : String → Option (Nat × (Expr → Expr → Expr))
  | "+" => some (1,Expr.add)
  | "*" => some (2,Expr.multiply)
  | _ => none
mutual
  def expression : Nat → Nat → Parser Expr
    | 0,_,_ => none
    | fuel+1,minimum,ts => do
      let (left,ts) ←primary fuel ts
      climb fuel minimum left ts
  def primary : Nat → Parser Expr
    | 0,_ => none
    | fuel+1,"("::"uint"::")"::ts => do
      let (value,ts) ←primary fuel ts
      pure (.castUInt value,ts)
    | _+1,builtin::"."::component::ts => do
      let (builtin,_) ←nameToken [builtin]
      let (component,_) ←nameToken [component]
      pure (.builtin builtin component,ts)
    | _+1,token::ts => match CodebookIntegerSyntax.literal token with
      | some (.literal kind value) => some (.literal kind value,ts)
      | _ => do
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

def constantTokens : Parser Constant := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "uint" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (value,ts) ←expression 16 0 ts
  let ts ←accept ";" ts
  pure (⟨target,value⟩,ts)

def loopTokens : Parser Loop := fun ts => do
  let ts ←accept "for" ts
  let ts ←accept "(" ts
  let ts ←accept "uint" ts
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (initial,ts) ←expression 16 0 ts
  let ts ←accept ";" ts
  let (test,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←expression 16 0 ts
  let ts ←accept ";" ts
  let (step,ts) ←nameToken ts
  let ts ←accept "+=" ts
  let (increment,ts) ←expression 16 0 ts
  let ts ←accept ")" ts
  pure (⟨counter,initial,test,bound,step,increment⟩,ts)

def writerTokens : Parser Writer := fun ts => do
  let ts ←accept "if" ts
  let ts ←accept "(" ts
  let (lane,ts) ←nameToken ts
  -- GateInputSyntax lexes the equality as two '=' tokens.
  let ts ←accept "=" ts
  let ts ←accept "=" ts
  let (selected,ts) ←expression 8 0 ts
  let ts ←accept ")" ts
  pure (⟨lane,selected⟩,ts)

def parseConstant (source : String) : Option Constant := do
  let (actual,rest) ←constantTokens (←GateInputSyntax.tokenize source)
  if rest=[] then some actual else none

def parseLoop (source : String) : Option Loop := do
  let (actual,rest) ←loopTokens (←GateInputSyntax.tokenize source)
  if rest=[] then some actual else none

def parseWriter (source : String) : Option Writer := do
  let (actual,rest) ←writerTokens (←GateInputSyntax.tokenize source)
  if rest=[] then some actual else none

def laneSource : String := "const uint lane = thread_index_in_simdgroup;"
def laneAST : Constant := ⟨"lane",.variable "thread_index_in_simdgroup"⟩
theorem parsed_lane : parseConstant laneSource=some laneAST := by decide +kernel

def constantSource : String := "const uint rowStep = threadgroups_per_grid.y * (uint)ROWS_TG;"
def loopSource : String := "for (uint row = thread_position_in_grid.y * (uint)ROWS_TG + simdgroup_index_in_threadgroup; row < (uint)R; row += rowStep)"
def writerSource : String := "if (lane == 0u)"
def constantAST : Constant := ⟨"rowStep",.multiply (.builtin "threadgroups_per_grid" "y") (.castUInt (.variable "ROWS_TG"))⟩
def loopAST : Loop := ⟨"row",.add (.multiply (.builtin "thread_position_in_grid" "y") (.castUInt (.variable "ROWS_TG")))
  (.variable "simdgroup_index_in_threadgroup"),"row",.castUInt (.variable "R"),"row",.variable "rowStep"⟩
def writerAST : Writer := ⟨"lane",.literal .unsigned 0⟩
theorem parsed_constant : parseConstant constantSource=some constantAST := by decide +kernel
theorem parsed_loop : parseLoop loopSource=some loopAST := by decide +kernel
theorem parsed_writer : parseWriter writerSource=some writerAST := by decide +kernel
end Inference.Kernels.Trellis.GateRowSyntax
