import kernels.trellis.DownPointerSyntax
import kernels.trellis.GateLoopSource
namespace Inference.Kernels.Trellis.DownFoldSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
open DownPointerSyntax (Expr)
set_option maxRecDepth 10000

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c || c='.' then do
      let word := fun c => wordChar c || c='.'
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else if c='+' then match rest with
      | '+'::rest => do pure ("++"::(←lexAux fuel rest))
      | _ => do pure ("+"::(←lexAux fuel rest))
    else if c='=' then match rest with
      | '='::rest => do pure ("=="::(←lexAux fuel rest))
      | _ => do pure ("="::(←lexAux fuel rest))
    else if ['(',')','[',']',';','*','<','{','}',':'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def parse {α : Type} (parser : Parser α) (source : String) : Option α := do
  let (code,rest) ←parser (←lexAux (source.length+1) source.toList)
  if rest=[] then some code else none

structure Column where
  target : String
  group : String
  groupStride : Expr
  simd : String
  simdStride : Expr
  deriving DecidableEq,Repr

def columnTokens : Parser Column := fun ts => do
  let ts ←accept "uint" (←accept "const" ts)
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (group,ts) ←match ts with | g::rest => some (g,rest) | [] => none
  let ts ←accept "*" ts
  let (groupStride,ts) ←DownPointerSyntax.expression 8 2 ts
  let ts ←accept "+" ts
  let (simd,ts) ←nameToken ts
  let ts ←accept "*" ts
  let (simdStride,ts) ←DownPointerSyntax.expression 8 2 ts
  let ts ←accept ";" ts
  pure (⟨target,group,groupStride,simd,simdStride⟩,ts)

structure VectorRead where
  target : String
  pointer : Expr
  deriving DecidableEq,Repr

def vectorTokens : Parser VectorRead := fun ts => do
  let ts ←accept "float4" (←accept "const" ts)
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "(" (←accept "*" ts)
  let ts ←accept "device" (←accept "const" ts)
  let ts ←accept "*" (←accept "float4" ts)
  let ts ←accept ")" ts
  let ts ←accept "(" ts
  let (pointer,ts) ←DownPointerSyntax.expression 24 0 ts
  let ts ←accept ";" (←accept ")" ts)
  pure (⟨target,pointer⟩,ts)

structure Reduction where
  target : String
  vector : String
  index : Expr
  deriving DecidableEq,Repr

def reductionTokens : Parser Reduction := fun ts => do
  let ts ←accept "float" (←accept "const" ts)
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "(" (←accept "simd_sum" (←accept ":" (←accept ":" (←accept "metal" ts))))
  let (vector,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←DownPointerSyntax.expression 8 0 ts
  let ts ←accept ";" (←accept ")" (←accept "]" ts))
  pure (⟨target,vector,index⟩,ts)

structure Store where
  lane : String
  writer : Expr
  target : String
  index : Expr
  conversion : String
  value : String
  deriving DecidableEq,Repr

def storeTokens : Parser Store := fun ts => do
  let ts ←accept "(" (←accept "if" ts)
  let (lane,ts) ←nameToken ts
  let ts ←accept "==" ts
  let (writer,ts) ←DownPointerSyntax.expression 8 0 ts
  let ts ←accept ")" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←DownPointerSyntax.expression 8 0 ts
  let ts ←accept "=" (←accept "]" ts)
  let (conversion,ts) ←nameToken ts
  let ts ←accept "(" ts
  let (value,ts) ←nameToken ts
  let ts ←accept ";" (←accept ")" ts)
  pure (⟨lane,writer,target,index,conversion,value⟩,ts)

def laneTokens : Parser (String × String) := fun ts => do
  let ts ←accept "uint" (←accept "const" ts)
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (builtin,ts) ←nameToken ts
  let ts ←accept ";" ts
  pure ((target,builtin),ts)

def columnSource : String := "const uint col = threadgroup_position_in_grid.x * 32u + simdgroup_index_in_threadgroup * 4u;"
def vectorSource : String := "const float4 t = *(const device float4*)(partial + (ulong)lane * (ulong)C + col);"
def loopSource : String := "for (uint i = 0; i < 4u; ++i) {"
def reductionSource : String := "const float v = metal::simd_sum(t[i]);"
def storeSource : String := "if (lane == 0u) out[col + i] = T(v);"
def laneSource : String := "const uint lane = thread_index_in_simdgroup;"

def column : Column := ⟨"col","threadgroup_position_in_grid.x",.uint 32,"simdgroup_index_in_threadgroup",.uint 4⟩
def vector : VectorRead := ⟨"t",.add (.add (.variable "partial") (.multiply (.castULong (.variable "lane")) (.castULong (.variable "C")))) (.variable "col")⟩
def reduction : Reduction := ⟨"v","t",.variable "i"⟩
def store : Store := ⟨"lane",.uint 0,"out",.add (.variable "col") (.variable "i"),"T","v"⟩
def loop : GateLoopSource.Loop := ⟨"i",.literal .signed 0,"i",.literal .unsigned 4,"i",.literal .unsigned 1⟩
theorem parsed_lane : parse laneTokens laneSource=some ("lane","thread_index_in_simdgroup") := rfl
theorem parsed_column : parse columnTokens columnSource=some column := rfl
theorem parsed_vector : parse vectorTokens vectorSource=some vector := rfl
theorem parsed_reduction : parse reductionTokens reductionSource=some reduction := rfl
theorem parsed_store : parse storeTokens storeSource=some store := rfl
theorem parsed_loop : GateLoopSource.parseLoop loopSource=some loop := rfl
end Inference.Kernels.Trellis.DownFoldSyntax
