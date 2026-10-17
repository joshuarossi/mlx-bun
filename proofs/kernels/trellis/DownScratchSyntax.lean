import kernels.trellis.DownInitialSource
namespace Inference.Kernels.Trellis.DownScratchSyntax
open Copy.ScalarCopySyntax (Parser accept nameToken)
open PackedArraySyntax
set_option maxRecDepth 10000
structure Alias where
  target : String
  source : String
  deriving DecidableEq,Repr
structure Barrier where
  function : String
  library : String
  flags : String
  scope : String
  deriving DecidableEq,Repr
structure StoreLoop where
  counter : String
  start : Expr
  test : String
  bound : Expr
  increment : String
  target : String
  index : Expr
  value : Expr
  deriving Repr

def aliasTokens : Parser Alias := fun ts => do
  let ts ←accept "threadgroup" ts
  let ts ←accept "float" ts
  let ts ←accept "*" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (source,ts) ←nameToken ts
  let ts ←accept ";" ts
  pure (⟨target,source⟩,ts)

def barrierTokens : Parser Barrier := fun ts => do
  let (function,ts) ←nameToken ts
  let ts ←accept "(" ts
  let (library,ts) ←nameToken ts
  let ts ←accept ":" (←accept ":" ts)
  let (flags,ts) ←nameToken ts
  let ts ←accept ":" (←accept ":" ts)
  let (scope,ts) ←nameToken ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨function,library,flags,scope⟩,ts)

def storeTokens : Parser StoreLoop := fun ts => do
  let ts ←accept "uint" (←accept "(" (←accept "for" ts))
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (start,ts) ←expression 16 0 ts
  let ts ←accept ";" ts
  let (test,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←expression 16 0 ts
  let ts ←accept ";" ts
  let ts ←accept "++" ts
  let (increment,ts) ←nameToken ts
  let ts ←accept ")" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←expression 16 0 ts
  let ts ←accept "]" ts
  let ts ←accept "=" ts
  let (value,ts) ←expression 16 0 ts
  let ts ←accept ";" ts
  pure (⟨counter,start,test,bound,increment,target,index,value⟩,ts)

def parse {α : Type} (parser : Parser α) (source : String) : Option α := do
  let (code,rest) ←parser (←tokenize source)
  if rest=[] then some code else none

def barrierSource : String := "threadgroup_barrier(metal::mem_flags::mem_threadgroup);"
def aliasSource : String := "threadgroup float* sums = codebook;"
def columnsSource : String := "constexpr uint SG_COLS = 32u * (uint)P;"
def localSource : String := "const uint local = (lane / LB) * 256u + 255u - li * (uint)P;"
def storeSource : String := "for (uint i = 0; i < (uint)P; ++i) sums[sg * SG_COLS + local - i] = acc[i];"
def aliasCode : Alias := ⟨"sums","codebook"⟩
def barrier : Barrier := ⟨"threadgroup_barrier","metal","mem_flags","mem_threadgroup"⟩
private def v := Expr.variable
open Expr in
def store : StoreLoop := ⟨"i",literal .signed 0,"i",castUInt (v "P"),"i","sums",
  subtract (add (multiply (v "sg") (v "SG_COLS")) (v "local")) (v "i"),index "acc" [v "i"]⟩
theorem parsed_alias : parse aliasTokens aliasSource=some aliasCode := rfl
theorem parsed_barrier : parse barrierTokens barrierSource=some barrier := rfl
theorem parsed_store : parse storeTokens storeSource=some store := rfl
end Inference.Kernels.Trellis.DownScratchSyntax
