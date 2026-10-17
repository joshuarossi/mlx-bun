import kernels.trellis.DownScratchMemory
namespace Inference.Kernels.Trellis.DownPartialSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c || c='.' then do
      let word := fun c => wordChar c || c='.'
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else if ['<','>','=','+'].contains c then match rest with
      | d::tail => if d=c ∨ d='=' then do pure (String.ofList [c,d]::(←lexAux fuel tail))
        else do pure (String.singleton c::(←lexAux fuel rest))
      | [] => some [String.singleton c]
    else if ['(',')','[',']',';','-','*','/','%','{','}'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none
structure OutputLoop where
  counter : String
  builtin : String
  test : String
  bound : PackedArraySyntax.Expr
  increment : String
  step : PackedArraySyntax.Expr
  deriving Repr
structure SumLoop where
  counter : String
  start : PackedArraySyntax.Expr
  test : String
  bound : PackedArraySyntax.Expr
  increment : String
  target : String
  value : PackedArraySyntax.Expr
  deriving Repr
structure Store where
  target : String
  index : DownPointerSyntax.Expr
  value : String
  deriving Repr

def outputTokens : Parser OutputLoop := fun ts => do
  let ts ←accept "uint" (←accept "(" (←accept "for" ts))
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (builtin,ts) ←match ts with | token::rest => some (token,rest) | [] => none
  let ts ←accept ";" ts
  let (test,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept ";" ts
  let (increment,ts) ←nameToken ts
  let ts ←accept "+=" ts
  let (step,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept "{" (←accept ")" ts)
  pure (⟨counter,builtin,test,bound,increment,step⟩,ts)

def guardTokens : Parser DownControlSyntax.Expr := fun ts => do
  let ts ←accept "(" (←accept "if" ts)
  let (condition,ts) ←DownControlSyntax.expression 16 0 ts
  let ts ←accept ";" (←accept "continue" (←accept ")" ts))
  pure (condition,ts)

def zeroTokens : Parser (String × GateTailSyntax.Expr) := fun ts => do
  let ts ←accept "float" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (value,ts) ←GateTailSyntax.expression 16 0 ts
  let ts ←accept ";" ts
  pure ((target,value),ts)

def sumTokens : Parser SumLoop := fun ts => do
  let ts ←accept "uint" (←accept "(" (←accept "for" ts))
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (start,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept ";" ts
  let (test,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept ";" ts
  let (increment,ts) ←nameToken (←accept "++" ts)
  let ts ←accept ")" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (value,ts) ←PackedArraySyntax.expression 32 0 ts
  let ts ←accept ";" ts
  pure (⟨counter,start,test,bound,increment,target,value⟩,ts)

def storeTokens : Parser Store := fun ts => do
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←DownPointerSyntax.expression 16 0 ts
  let ts ←accept "=" (←accept "]" ts)
  let (value,ts) ←nameToken ts
  let ts ←accept ";" ts
  pure (⟨target,index,value⟩,ts)

def parse {α : Type} (parser : Parser α) (source : String) : Option α := do
  let (code,rest) ←parser (←lexAux (source.length+1) source.toList)
  if rest=[] then some code else none

def outputSource : String := "for (uint c = thread_position_in_threadgroup.x; c < 2u * SG_COLS; c += (uint)THREADS) {"
def groupSource : String := "const uint group2 = c / SG_COLS, col = (2u * (ty / 32u) + group2) * SG_COLS + c % SG_COLS;"
def guardSource : String := "if (col >= (uint)C) continue;"
def zeroSource : String := "float t = 0.0f;"
def sumSource : String := "for (uint k = 0; k < 4u; ++k) t = sums[(group2 * 4u + k) * SG_COLS + c % SG_COLS] + t;"
def storeSource : String := "partial[(ulong)y * (ulong)C + col] = t;"
private def v := PackedArraySyntax.Expr.variable
open PackedArraySyntax.Expr in
def output : OutputLoop := ⟨"c","thread_position_in_threadgroup.x","c",multiply (literal .unsigned 2) (v "SG_COLS"),"c",castUInt (v "THREADS")⟩
def guard : DownControlSyntax.Expr := .greaterEqual (.variable "col") (.castUInt (.variable "C"))
def zero : String × GateTailSyntax.Expr := ("t",.floating 0 1)
open PackedArraySyntax.Expr in
def sum : SumLoop := ⟨"k",literal .signed 0,"k",literal .unsigned 4,"k","t",
  add (index "sums" [add (multiply (add (multiply (v "group2") (literal .unsigned 4)) (v "k")) (v "SG_COLS")) (modulo (v "c") (v "SG_COLS"))]) (v "t")⟩
open DownPointerSyntax.Expr in
def store : Store := ⟨"partial",add (multiply (castULong (DownPointerSyntax.Expr.variable "y")) (castULong (DownPointerSyntax.Expr.variable "C"))) (DownPointerSyntax.Expr.variable "col"),"t"⟩
theorem parsed_output : parse outputTokens outputSource=some output := rfl
theorem parsed_guard : parse guardTokens guardSource=some guard := rfl
theorem parsed_zero : parse zeroTokens zeroSource=some zero := rfl
theorem parsed_sum : parse sumTokens sumSource=some sum := rfl
theorem parsed_store : parse storeTokens storeSource=some store := rfl
end Inference.Kernels.Trellis.DownPartialSyntax
