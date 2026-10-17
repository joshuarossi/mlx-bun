import kernels.trellis.GateInputSemantics
namespace Inference.Kernels.Trellis.GateInputContext
open Copy.ScalarCopySyntax (Parser accept nameToken)
open GateInputSyntax
set_option maxRecDepth 10000
structure Declaration where
  target : String
  dimension : PackedArraySyntax.Expr
  deriving Repr
structure Chunk where
  target : String
  source : String
  index : PackedArraySyntax.Expr
  deriving Repr

def declarationTokens : Parser Declaration := fun ts => do
  let ts ←accept "threadgroup" ts
  let ts ←accept "uint4" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (dimension,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept "]" ts
  let ts ←accept ";" ts
  pure (⟨target,dimension⟩,ts)
def chunkTokens : Parser Chunk := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "uint4" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (source,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept "]" ts
  let ts ←accept ";" ts
  pure (⟨target,source,index⟩,ts)
def parseDeclaration (source : String) : Option Declaration := do
  let (actual,rest) ←declarationTokens (←tokenize source)
  if rest=[] then some actual else none
def parseChunk (source : String) : Option Chunk := do
  let (actual,rest) ←chunkTokens (←tokenize source)
  if rest=[] then some actual else none

def declarationSource : String := "threadgroup uint4 xs[C / 8];"
def chunkSource : String := "const uint4 chunk = xs[q * N_RUNS + run];"
def declarationAST : Declaration := ⟨"xs",.divide (v "C") (.literal .signed 8)⟩
def chunkAST : Chunk := ⟨"chunk","xs",.add (.multiply (v "q") (v "N_RUNS")) (v "run")⟩
theorem parsed_declaration : parseDeclaration declarationSource=some declarationAST := rfl
theorem parsed_chunk : parseChunk chunkSource=some chunkAST := rfl

def dimension (code : Declaration) : Option Nat := do
  if code.target="xs" then
    match ←PackedArraySemantics.evaluate 16 ⟨[("C",.signed 5120)],[],[]⟩ code.dimension with
    | .unsigned value => some value.toNat
    | .signed value => if 0≤value then some value.toNat else none
    | _ => none
  else none

theorem dimension_selected : dimension declarationAST=some 640 := by decide +kernel

def index (code : Chunk) (q run : Nat) : Option Nat := do
  if code.target="chunk" ∧ code.source="xs" then
    match ←PackedArraySemantics.evaluate 16
      ⟨[("q",.unsigned (BitVec.ofNat 32 q)),("run",.unsigned (BitVec.ofNat 32 run)),("N_RUNS",.unsigned 160)],[],[]⟩ code.index with
    | .unsigned value => if value.toNat<640 then some value.toNat else none
    | _ => none
  else none

theorem index_selected : ∀ q : Fin 4, ∀ run : Fin 160, index chunkAST q.val run.val=some (q.val*160+run.val) := by
  decide +kernel

structure Constant where
  target : String
  value : PackedArraySyntax.Expr
  deriving Repr

def constantTokens : Parser Constant := fun ts => do
  let ts ←accept "constexpr" ts
  let ts ←accept "uint" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (value,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept ";" ts
  pure (⟨target,value⟩,ts)
def parseConstant (source : String) : Option Constant := do
  let (actual,rest) ←constantTokens (←tokenize source)
  if rest=[] then some actual else none

def constantSource : String := "constexpr uint N_RUNS = (uint)C / 32u;"
def constantAST : Constant := ⟨"N_RUNS",.divide (.castUInt (v "C")) (u 32)⟩
theorem parsed_constant : parseConstant constantSource=some constantAST := rfl
theorem constant_selected : constantAST.target="N_RUNS" ∧
    GateInputSemantics.uint GateInputSyntax.loopAST 0 constantAST.value=some 160 := by decide +kernel
end Inference.Kernels.Trellis.GateInputContext
