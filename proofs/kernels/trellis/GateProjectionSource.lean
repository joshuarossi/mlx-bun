import kernels.trellis.GateLaneBridge
namespace Inference.Kernels.Trellis.GateProjectionSource
open Contracts.Mlx Contracts.Mlx.M1Max GateAccumulateSource
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000

structure Initializer where
  target : String
  literal : String
  deriving DecidableEq,Repr
structure Reduction where
  target : String
  first : String
  second : String
  deriving DecidableEq,Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c || c='.' then do
      let word := fun c => wordChar c || c='.'
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else if ['(',')',';',',',':','=','+'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def initializer : Parser Initializer := fun ts => do
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  match ts with
  | literal::ts => pure (⟨target,literal⟩,ts)
  | [] => none

def initializers : Parser (List Initializer) := fun ts => do
  let ts ←accept "float" ts
  let (g,ts) ←initializer ts
  let ts ←accept "," ts
  let (g2,ts) ←initializer ts
  let ts ←accept "," ts
  let (u,ts) ←initializer ts
  let ts ←accept "," ts
  let (u2,ts) ←initializer ts
  let ts ←accept ";" ts
  pure ([g,g2,u,u2],ts)

def reduction : Parser Reduction := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "float" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "metal" ts
  let ts ←accept ":" ts
  let ts ←accept ":" ts
  let ts ←accept "simd_sum" ts
  let ts ←accept "(" ts
  let (first,ts) ←nameToken ts
  let ts ←accept "+" ts
  let (second,ts) ←nameToken ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨target,first,second⟩,ts)

def parseInitial (source : String) : Option (List Initializer) := do
  let (actual,rest) ←initializers (←tokenize source)
  if rest=[] then some actual else none

def parseReduction (source : String) : Option Reduction := do
  let (actual,rest) ←reduction (←tokenize source)
  if rest=[] then some actual else none

def initialSource : String := "float gAcc = 0.0f, gAcc2 = 0.0f, uAcc = 0.0f, uAcc2 = 0.0f;"
def gateSource : String := "const float gate = metal::simd_sum(gAcc + gAcc2);"
def upSource : String := "const float up = metal::simd_sum(uAcc + uAcc2);"
def initialAST : List Initializer := [⟨"gAcc","0.0f"⟩,⟨"gAcc2","0.0f"⟩,⟨"uAcc","0.0f"⟩,⟨"uAcc2","0.0f"⟩]
def reductionAST (isUp : Bool) : Reduction := ⟨if isUp then "up" else "gate",if isUp then "uAcc" else "gAcc",if isUp then "uAcc2" else "gAcc2"⟩
theorem parsed_initial : parseInitial initialSource=some initialAST := by decide +kernel
theorem parsed_reductions : ∀ isUp : Bool,
    parseReduction (if isUp then upSource else gateSource)=some (reductionAST isUp) := by decide +kernel

-- Selected finite decimal literal: positive binary32 zero. Other literals fail.
def initializeState : List Initializer → Environment → Option Environment
  | [],state => some state
  | first::rest,state =>
    if first.literal="0.0f" then
      initializeState rest (fun name => if name=first.target then some 0 else state name)
    else none

def initial : Option Dual := do
  observe (←initializeState (←parseInitial initialSource) (fun _ => none))

theorem initial_zero : initial=some ((0,0),(0,0)) := by
  unfold initial
  rw [parsed_initial]
  rfl

def field (state : Fin 32 → Dual) (name : String) : Option (Fin 32 → Float32) :=
  if name="gAcc" then some (fun lane => (state lane).1.1)
  else if name="gAcc2" then some (fun lane => (state lane).1.2)
  else if name="uAcc" then some (fun lane => (state lane).2.1)
  else if name="uAcc2" then some (fun lane => (state lane).2.2) else none

-- Addition rounds separately before the supplied SIMD primitive. Its native
-- reduction tree remains the explicit SimdReduction contract.
def evaluateReduction (state : Fin 32 → Dual) (reduce : DownExecution.SimdReduction) (code : Reduction) : Option Float32 := do
  if code.target="gate" ∨ code.target="up" then
    let first ←field state code.first
    let second ←field state code.second
    pure (reduce (fun lane => first lane+second lane))
  else none

def reductions (state : Fin 32 → Dual) (reduce : DownExecution.SimdReduction) : Option (Float32 × Float32) := do
  let gate ←evaluateReduction state reduce (←parseReduction gateSource)
  let up ←evaluateReduction state reduce (←parseReduction upSource)
  pure (gate,up)

theorem reductions_correct (state : Fin 32 → Dual) (reduce : DownExecution.SimdReduction) :
    reductions state reduce=some
      (reduce (fun lane => (state lane).1.1+(state lane).1.2),reduce (fun lane => (state lane).2.1+(state lane).2.2)) := by
  have gateParse : parseReduction gateSource=some (reductionAST false) := parsed_reductions false
  have upParse : parseReduction upSource=some (reductionAST true) := parsed_reductions true
  simp [reductions,gateParse,upParse,evaluateReduction,reductionAST,field]

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}
open PackedArrayMaterialization GateLaneBridge

def initializedLane (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row lane : Nat) (load : ThreadgroupLoad) : Option Dual := do
  GateLoopSource.memoryLane input actual row lane load (←initial)

def states (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) : Fin 32 → Dual := fun lane =>
  (initializedLane input actual row lane.val load).getD ((0,0),(0,0))

theorem getD_map {α β : Type} (actual : Option α) (f : α → β) (expected : β)
    (mapped : actual.map f=some expected) (fallback : α) : f (actual.getD fallback)=expected := by
  cases actual with
  | none => contradiction
  | some value => exact Option.some.inj mapped

theorem state_sums (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (lane : Fin 32) :
    ((states input actual row load lane).1.1+(states input actual row load lane).1.2,
     (states input actual row load lane).2.1+(states input actual row load lane).2.2)=
      (GateUpExecution.referenceLane (input.matrix false) kg (scale input false) (ArrayStorage.bfWords activation) row lane.val,
       GateUpExecution.referenceLane (input.matrix true) ku (scale input true) (ArrayStorage.bfWords activation) row lane.val) := by
  have bridge:=lane_sums input actual row lane.val rowBound lane.isLt load hardware
  unfold laneSums at bridge
  unfold states initializedLane
  rw [initial_zero]
  exact getD_map _ _ _ bridge ((0,0),(0,0))

-- Default values in states are unreachable: state_sums uses successful parsed
-- executions for every launched lane, established by the lane bridge.
def projection (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction) : Option (Float32 × Float32) :=
  reductions (states input actual row load) reduce

theorem projection_correct (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load)
    (reduce : DownExecution.SimdReduction) :
    projection input actual row load reduce=some
      (reduce (fun lane => GateUpExecution.referenceLane (input.matrix false) kg (scale input false) (ArrayStorage.bfWords activation) row lane.val),
       reduce (fun lane => GateUpExecution.referenceLane (input.matrix true) ku (scale input true) (ArrayStorage.bfWords activation) row lane.val)) := by
  unfold projection
  rw [reductions_correct]
  have gate : (fun lane : Fin 32 => (states input actual row load lane).1.1+(states input actual row load lane).1.2)=
      (fun lane => GateUpExecution.referenceLane (input.matrix false) kg (scale input false) (ArrayStorage.bfWords activation) row lane.val) := by
    funext lane
    exact congrArg Prod.fst (state_sums input actual row rowBound load hardware lane)
  have up : (fun lane : Fin 32 => (states input actual row load lane).2.1+(states input actual row load lane).2.2)=
      (fun lane => GateUpExecution.referenceLane (input.matrix true) ku (scale input true) (ArrayStorage.bfWords activation) row lane.val) := by
    funext lane
    exact congrArg Prod.snd (state_sums input actual row rowBound load hardware lane)
  rw [gate,up]
end Inference.Kernels.Trellis.GateProjectionSource
