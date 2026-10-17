import kernels.trellis.GateInputSource
namespace Inference.Kernels.Trellis.GateAccumulateSource
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000

-- A selected parser for the actual conditional and the four ordered FMA
-- assignments. Operands and destinations are retained, including the old
-- accumulator read. Float32.fma is the explicit scalar platform contract.
structure Assignment where
  target : String
  weight : String
  input : String
  accumulator : String
  deriving DecidableEq, Repr
structure Branch where
  condition : CodebookWindowSyntax.Expr
  yes : List Assignment
  no : List Assignment
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','{','}',';',',',':','=','&'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def assignment : Parser Assignment := fun ts => do
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "metal" ts
  let ts ←accept ":" ts
  let ts ←accept ":" ts
  let ts ←accept "fma" ts
  let ts ←accept "(" ts
  let (weight,ts) ←nameToken ts
  let ts ←accept "," ts
  let (input,ts) ←nameToken ts
  let ts ←accept "," ts
  let (accumulator,ts) ←nameToken ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨target,weight,input,accumulator⟩,ts)

def pair : Parser (List Assignment) := fun ts => do
  let ts ←accept "{" ts
  let (first,ts) ←assignment ts
  let (second,ts) ←assignment ts
  let ts ←accept "}" ts
  pure ([first,second],ts)

def branch : Parser Branch := fun ts => do
  let ts ←accept "if" ts
  let ts ←accept "(" ts
  let (condition,ts) ←CodebookWindowSyntax.expression 8 0 ts
  let ts ←accept ")" ts
  let (yes,ts) ←pair ts
  let ts ←accept "else" ts
  let (no,ts) ←pair ts
  pure (⟨condition,yes,no⟩,ts)

def parse (source : String) : Option Branch := do
  let (actual,rest) ←branch (←tokenize source)
  if rest=[] then some actual else none

def source : String := "if (j & 1u) { gAcc2 = metal::fma(gWeight, xv, gAcc2); uAcc2 = metal::fma(uWeight, xv, uAcc2); }\n          else { gAcc = metal::fma(gWeight, xv, gAcc); uAcc = metal::fma(uWeight, xv, uAcc); }"
def code : Branch := ⟨.bitAnd (.variable "j") (.literal .unsigned 1),
  [⟨"gAcc2","gWeight","xv","gAcc2"⟩,⟨"uAcc2","uWeight","xv","uAcc2"⟩],
  [⟨"gAcc","gWeight","xv","gAcc"⟩,⟨"uAcc","uWeight","xv","uAcc"⟩]⟩
def tokens : Tokens := ["if","(","j","&","1u",")","{","gAcc2","=","metal",":",":","fma","(","gWeight",",","xv",",","gAcc2",")",";","uAcc2","=","metal",":",":","fma","(","uWeight",",","xv",",","uAcc2",")",";","}","else","{","gAcc","=","metal",":",":","fma","(","gWeight",",","xv",",","gAcc",")",";","uAcc","=","metal",":",":","fma","(","uWeight",",","xv",",","uAcc",")",";","}"]
theorem tokenized : tokenize source=some tokens := by decide +kernel
theorem parsed : parse source=some code := by
  unfold parse
  rw [tokenized]
  rfl

abbrev Environment := String → Option Float32

def assign (statement : Assignment) (environment : Environment) : Option Environment := do
  let weight ←environment statement.weight
  let input ←environment statement.input
  let accumulator ←environment statement.accumulator
  let value:=Float32.fma weight input accumulator
  pure (fun name => if name=statement.target then some value else environment name)

def execute : List Assignment → Environment → Option Environment
  | [],environment => some environment
  | first::rest,environment => do execute rest (←assign first environment)

def test (j : Nat) : CodebookWindowSyntax.Expr → Option Bool
  | .bitAnd (.variable name) (.literal .unsigned mask) =>
    if name="j" ∧ mask=1 ∧ j<2^32 then some ((BitVec.ofNat 32 j &&& BitVec.ofNat 32 mask) ≠ 0) else none
  | _ => none

def run (j : Nat) (environment : Environment) : Option Environment := do
  let actual ←parse source
  let odd ←test j actual.condition
  execute (if odd then actual.yes else actual.no) environment

theorem test_selected : ∀ j : Fin 32, test j.val code.condition=some (decide (j.val%2=1)) := by decide +kernel

abbrev Dual := GateUpExecution.Accumulators × GateUpExecution.Accumulators

def environment (gateWeight upWeight input : Float32) (acc : Dual) : Environment := fun name =>
  if name="gWeight" then some gateWeight else if name="uWeight" then some upWeight
  else if name="xv" then some input else if name="gAcc" then some acc.1.1
  else if name="gAcc2" then some acc.1.2 else if name="uAcc" then some acc.2.1
  else if name="uAcc2" then some acc.2.2 else none

def observe (state : Environment) : Option Dual := do
  pure ((←state "gAcc",←state "gAcc2"),(←state "uAcc",←state "uAcc2"))

def step (j : Nat) (gateWeight upWeight input : Float32) (acc : Dual) : Option Dual := do
  observe (←run j (environment gateWeight upWeight input acc))

-- Both projections share the original xv, with independent old accumulators.
-- This is bit-exact scalar arithmetic; no FMA is replaced by a real product/sum.
theorem step_correct (j : Nat) (bound : j<32) (gateWeight upWeight input : Float32) (acc : Dual) :
    step j gateWeight upWeight input acc=some
      (GateUpExecution.accumulate j gateWeight input acc.1,
       GateUpExecution.accumulate j upWeight input acc.2) := by
  unfold step run
  rw [parsed]
  change ((test j code.condition).bind (fun odd =>
    execute (if odd then code.yes else code.no) (environment gateWeight upWeight input acc))).bind observe=_

  rw [test_selected ⟨j,bound⟩]
  by_cases odd : j%2=1 <;>
    simp [odd,code,execute,assign,environment,observe,GateUpExecution.accumulate]

-- Compose the parsed FMA branch with the parsed staging and BF16 unpack.
-- Weight-window reads and scale multiplication are still supplied explicitly.
attribute [local irreducible] GateInputSource.readValue GateInputSource.Execution.memory step

def memoryStep (memory : Contracts.Mlx.ByteMemory.Bytes) (inputBase run q p : Nat)
    (gateWeight upWeight : Float32) (acc : Dual) : Option Dual := do
  let input ←GateInputSource.readValue memory inputBase q run p
  step (q*8+p) gateWeight upWeight input acc

theorem memory_step {input : Fin 5120 → Contracts.Mlx.ArrayStorage.BF}
    {source : Contracts.Mlx.ArrayStorage.BFBuffer input} {tableBase inputBase : Nat}
    (actual : GateInputSource.Execution source tableBase inputBase) (run q p : Nat)
    (runBound : run<160) (qBound : q<4) (pBound : p<8)
    (gateWeight upWeight : Float32) (acc : Dual) :
    memoryStep actual.memory inputBase run q p gateWeight upWeight acc=some
      (GateUpExecution.accumulate (q*8+p) gateWeight
        (GateUpExecution.widen (Contracts.Mlx.ArrayStorage.bfWords input (run*32+q*8+p))) acc.1,
       GateUpExecution.accumulate (q*8+p) upWeight
        (GateUpExecution.widen (Contracts.Mlx.ArrayStorage.bfWords input (run*32+q*8+p))) acc.2) := by
  unfold memoryStep
  rw [actual.read_original run q p runBound qBound pBound]
  exact step_correct (q*8+p) (by omega) _ _ _ _
end Inference.Kernels.Trellis.GateAccumulateSource
