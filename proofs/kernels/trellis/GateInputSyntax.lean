import kernels.trellis.PackedArraySyntax
namespace Inference.Kernels.Trellis.GateInputSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000

-- Integer subexpressions retain their parsed operands. Vector pointer cast
-- and float reinterpret are explicit selected syntax, not inferred from a hash.
structure Loop where
  counter : String
  builtin : String
  component : String
  test : String
  bound : PackedArraySyntax.Expr
  step : String
  increment : PackedArraySyntax.Expr
  target : String
  targetIndex : PackedArraySyntax.Expr
  input : String
  sourceIndex : PackedArraySyntax.Expr
  deriving Repr
structure Unpack where
  target : String
  condition : CodebookWindowSyntax.Expr
  yes : CodebookWindowSyntax.Expr
  no : CodebookWindowSyntax.Expr
  deriving Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['<','>','+','&'].contains c then
      match rest with
      | d::tail => if d=c ∨ d='=' then do pure (String.ofList [c,d]::(←lexAux fuel tail))
        else do pure (String.singleton c::(←lexAux fuel rest))
      | [] => some [String.singleton c]
    else if ['(',')','[',']',';','-','*','/','%','?',':','=','.',','].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def loopTokens : Parser Loop := fun ts => do
  let ts ←accept "for" ts
  let ts ←accept "(" ts
  let ts ←accept "uint" ts
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (builtin,ts) ←nameToken ts
  let ts ←accept "." ts
  let (component,ts) ←nameToken ts
  let ts ←accept ";" ts
  let (test,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept ";" ts
  let (step,ts) ←nameToken ts
  let ts ←accept "+=" ts
  let (increment,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept ")" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (targetIndex,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept "]" ts
  let ts ←accept "=" ts
  let ts ←accept "(" ts
  let ts ←accept "(" ts
  let ts ←accept "const" ts
  let ts ←accept "device" ts
  let ts ←accept "uint4" ts
  let ts ←accept "*" ts
  let ts ←accept ")" ts
  let (input,ts) ←nameToken ts
  let ts ←accept ")" ts
  let ts ←accept "[" ts
  let (sourceIndex,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept "]" ts
  let ts ←accept ";" ts
  pure (⟨counter,builtin,component,test,bound,step,increment,target,targetIndex,input,sourceIndex⟩,ts)

def unpackTokens : Parser Unpack := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "float" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "as_type" ts
  let ts ←accept "<" ts
  let ts ←accept "float" ts
  let ts ←accept ">" ts
  let ts ←accept "(" ts
  let (condition,ts) ←CodebookWindowSyntax.expression 8 0 ts
  let ts ←accept "?" ts
  let (yes,ts) ←CodebookWindowSyntax.expression 8 0 ts
  let ts ←accept ":" ts
  let (no,ts) ←CodebookWindowSyntax.expression 8 0 ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨target,condition,yes,no⟩,ts)

def parseLoop (source : String) : Option Loop := do
  let (actual,rest) ←loopTokens (←tokenize source)
  if rest=[] then some actual else none

def parseUnpack (source : String) : Option Unpack := do
  let (actual,rest) ←unpackTokens (←tokenize source)
  if rest=[] then some actual else none

def loopSource : String := "for (uint c = thread_position_in_threadgroup.x; c < (uint)C / 8u; c += (uint)THREADS)\n    xs[c] = ((const device uint4*)x)[(c % N_RUNS) * 4u + c / N_RUNS];"
def unpackSource : String := "const float xv = as_type<float>((p & 1u) ? chunk[p >> 1] & 0xFFFF0000u : chunk[p >> 1] << 16);"
def u (n : Nat) : PackedArraySyntax.Expr := .literal .unsigned n
def v (name : String) : PackedArraySyntax.Expr := .variable name

def loopAST : Loop := ⟨"c","thread_position_in_threadgroup","x","c",
  .divide (.castUInt (v "C")) (u 8),"c",.castUInt (v "THREADS"),"xs",v "c","x",
  .add (.multiply (.modulo (v "c") (v "N_RUNS")) (u 4)) (.divide (v "c") (v "N_RUNS"))⟩
def unpackAST : Unpack := ⟨"xv",.bitAnd (.variable "p") (.literal .unsigned 1),
  .bitAnd (.index "chunk" (.shiftRight (.variable "p") (.literal .signed 1))) (.literal .unsigned 4294901760),
  .shiftLeft (.index "chunk" (.shiftRight (.variable "p") (.literal .signed 1))) (.literal .signed 16)⟩

def loopTokenList : Tokens := ["for","(","uint","c","=","thread_position_in_threadgroup",".","x",";","c","<","(","uint",")","C","/","8u",";","c","+=","(","uint",")","THREADS",")","xs","[","c","]","=","(","(","const","device","uint4","*",")","x",")","[","(","c","%","N_RUNS",")","*","4u","+","c","/","N_RUNS","]",";"]
theorem tokenize_loop : tokenize loopSource=some loopTokenList := by decide +kernel
def unpackTokenList : Tokens := ["const","float","xv","=","as_type","<","float",">","(","(","p","&","1u",")","?","chunk","[","p",">>","1","]","&","0xFFFF0000u",":","chunk","[","p",">>","1","]","<<","16",")",";"]
theorem tokenize_unpack : tokenize unpackSource=some unpackTokenList := by decide +kernel

theorem parsed_loop : parseLoop loopSource=some loopAST := by
  unfold parseLoop
  rw [tokenize_loop]
  rfl
theorem parsed_unpack : parseUnpack unpackSource=some unpackAST := by
  unfold parseUnpack
  rw [tokenize_unpack]
  rfl
end Inference.Kernels.Trellis.GateInputSyntax
