import kernels.trellis.GateTailSyntax
import kernels.trellis.GateProjectionSource
import kernels.trellis.GateUpSplitTail
import kernels.trellis.GateUpTailFlushToZero
namespace Inference.Kernels.Trellis.GateTailSource
open Contracts.Mlx GateTailSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Typed selected overload interpretation. Native BF16 operators and the two
-- exp overloads remain explicit platform bindings, as in existing tail specs.
abbrev BF := BFloat16Arithmetic.Value
inductive Value where
  | f32 : Float32 → Value
  | bf16 : BF → Value
  | integer : Nat → Value
  | boolean : Bool → Value
abbrev Environment := String → Option Value

structure FloatOperations where
  add : Float32 → Float32 → Float32
  subtract : Float32 → Float32 → Float32
  multiply : Float32 → Float32 → Float32
  divide : Float32 → Float32 → Float32

def standard : FloatOperations := ⟨(·+·),(·-·),(·*·),(·/·)⟩
def flushing : FloatOperations := ⟨FlushToZero.add,(fun a b => FlushToZero.add a (-b)),FlushToZero.mul,FlushToZero.div⟩

def toT : Value → Option BF
  | .f32 value => some (BFloat16.narrow value)
  | .bf16 value => some value
  | .integer value => if value=0 then some GateUpSplitTail.zero else if value=1 then some BFloat16Arithmetic.one else none
  | _ => none

def toFloat : Value → Option Float32
  | .f32 value => some value
  | .bf16 value => some (BFloat16.widen value)
  | _ => none

inductive Operation where | add | subtract | multiply | divide

def binary (floatOps : FloatOperations) (op : Operation) (first second : Value) : Option Value :=
  match first,second with
  | .f32 a,.f32 b => some (.f32 (match op with
    | .add => floatOps.add a b | .subtract => floatOps.subtract a b
    | .multiply => floatOps.multiply a b | .divide => floatOps.divide a b))
  | .bf16 a,.bf16 b => some (.bf16 (match op with
    | .add => BFloat16Arithmetic.add a b | .subtract => BFloat16Arithmetic.sub a b
    | .multiply => BFloat16Arithmetic.mul a b | .divide => BFloat16Arithmetic.div a b))
  | .integer a,.bf16 b => do
    let a ←toT (.integer a)
    pure (.bf16 (match op with
      | .add => BFloat16Arithmetic.add a b | .subtract => BFloat16Arithmetic.sub a b
      | .multiply => BFloat16Arithmetic.mul a b | .divide => BFloat16Arithmetic.div a b))
  | _,_ => none

def evaluate (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF)
    (state : Environment) : Expr → Option Value
  | .variable name => state name
  | .integer n => some (.integer n)
  | .floating mantissa scale => if mantissa=10^scale then some (.f32 1) else none
  | .castT expression => do pure (.bf16 (←toT (←evaluate ops expPrecise expAbs state expression)))
  | .castFloat expression => do pure (.f32 (←toFloat (←evaluate ops expPrecise expAbs state expression)))
  | .add a b => do binary ops .add (←evaluate ops expPrecise expAbs state a) (←evaluate ops expPrecise expAbs state b)
  | .subtract a b => do binary ops .subtract (←evaluate ops expPrecise expAbs state a) (←evaluate ops expPrecise expAbs state b)
  | .multiply a b => do binary ops .multiply (←evaluate ops expPrecise expAbs state a) (←evaluate ops expPrecise expAbs state b)
  | .divide a b => do binary ops .divide (←evaluate ops expPrecise expAbs state a) (←evaluate ops expPrecise expAbs state b)
  | .negative expression => do
    match ←evaluate ops expPrecise expAbs state expression with
    | .f32 value => some (.f32 (-value))
    | _ => none
  | .preciseExp expression => do
    match ←evaluate ops expPrecise expAbs state expression with
    | .f32 value => some (.f32 (expPrecise value))
    | _ => none
  | .exponential (.absolute expression) => do
    match ←evaluate ops expPrecise expAbs state expression with
    | .bf16 value => some (.bf16 (expAbs value))
    | _ => none
  | .less expression (.integer 0) => do
    match ←evaluate ops expPrecise expAbs state expression with
    | .bf16 value => some (.boolean (decide (GateUpSplitTail.negative value)))
    | _ => none
  | .choose condition yes no => do
    match ←evaluate ops expPrecise expAbs state condition with
    | .boolean condition => if condition then evaluate ops expPrecise expAbs state yes else evaluate ops expPrecise expAbs state no
    | _ => none
  | _ => none

structure State where
  values : Environment
  output : Option BF

def execute (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) : List Statement → State → Option State
  | [],state => some state
  | .constant name expression::rest,state => do
    let value ←toT (←evaluate ops expPrecise expAbs state.values expression)
    execute ops expPrecise expAbs rest ⟨(fun key => if key=name then some (.bf16 value) else state.values key),state.output⟩
  | .store target index expression::rest,state => do
    if target="mid" ∧ index="row" then
      let value ←toT (←evaluate ops expPrecise expAbs state.values expression)
      execute ops expPrecise expAbs rest ⟨state.values,some value⟩
    else none

def initial (gate up : Float32) : State := ⟨fun name =>
  if name="gate" then some (.f32 gate) else if name="up" then some (.f32 up) else none,none⟩

def run (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF)
    (tail : Nat) (gate up : Float32) : Option BF := do
  let code ←parse source
  if code.parameter="TAIL" then
    let state ←execute ops expPrecise expAbs code.declarations (initial gate up)
    let state ←execute ops expPrecise expAbs (if tail=code.selected then code.yes else code.no) state
    state.output
  else none

-- Only the final BF16 value is widened for comparison with the established
-- tail spec; no intermediate cast or arithmetic operation is removed.
theorem standard_tail (expPrecise : Float32 → Float32) (expAbs : BF → BF) (gate up : Float32) :
    (run standard expPrecise expAbs 0 gate up).map BFloat16.widen=some
      (GateUpTail.tail (fun x => expPrecise (-x)) (BFloat16.cast gate) (BFloat16.cast up)) := by
  unfold run
  rw [parsed]
  rfl

theorem flushing_tail (expPrecise : Float32 → Float32) (expAbs : BF → BF) (gate up : Float32) :
    (run flushing expPrecise expAbs 0 gate up).map BFloat16.widen=some
      (GateUpTailFlushToZero.tail (fun x => expPrecise (-x)) (BFloat16.cast gate) (BFloat16.cast up)) := by
  unfold run
  rw [parsed]
  rfl

theorem split_tail (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (gate up : Float32) :
    run ops expPrecise expAbs 1 gate up=some
      (GateUpSplitTail.tail expAbs (BFloat16.narrow gate) (BFloat16.narrow up)) := by
  unfold run
  rw [parsed]
  by_cases negative : GateUpSplitTail.negative (BFloat16.narrow gate) <;>
    simp [code,execute,initial,evaluate,toT,binary,GateUpSplitTail.tail,GateUpSplitTail.sigmoidValue,
      GateUpSplitTail.sigY,GateUpSplitTail.denominator,negative]

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}
open PackedArrayMaterialization GateLaneBridge M1Max

def projectionValues (input : GateInput kg ku) (row : Nat) (reduce : DownExecution.SimdReduction) : Float32 × Float32 :=
  (reduce (fun lane => GateUpExecution.referenceLane (input.matrix false) kg (scale input false)
    (ArrayStorage.bfWords activation) row lane.val),
   reduce (fun lane => GateUpExecution.referenceLane (input.matrix true) ku (scale input true)
    (ArrayStorage.bfWords activation) row lane.val))

def output (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (tail : Nat) : Option BF := do
  let pair ←GateProjectionSource.projection input actual row load reduce
  run ops expPrecise expAbs tail pair.1 pair.2

attribute [local irreducible] run

theorem output_from_original (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (tail : Nat) :
    output input actual row load reduce ops expPrecise expAbs tail=
      run ops expPrecise expAbs tail (projectionValues (activation:=activation) input row reduce).1
        (projectionValues (activation:=activation) input row reduce).2 := by
  unfold output
  rw [GateProjectionSource.projection_correct input actual row rowBound load hardware reduce]
  rfl

theorem output_standard (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (expPrecise : Float32 → Float32) (expAbs : BF → BF) :
    (output input actual row load reduce standard expPrecise expAbs 0).map BFloat16.widen=some
      (GateUpTail.tail (fun x => expPrecise (-x))
        (BFloat16.cast (projectionValues (activation:=activation) input row reduce).1)
        (BFloat16.cast (projectionValues (activation:=activation) input row reduce).2)) := by
  rw [output_from_original input actual row rowBound load hardware reduce]
  exact standard_tail expPrecise expAbs _ _

theorem output_flushing (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (expPrecise : Float32 → Float32) (expAbs : BF → BF) :
    (output input actual row load reduce flushing expPrecise expAbs 0).map BFloat16.widen=some
      (GateUpTailFlushToZero.tail (fun x => expPrecise (-x))
        (BFloat16.cast (projectionValues (activation:=activation) input row reduce).1)
        (BFloat16.cast (projectionValues (activation:=activation) input row reduce).2)) := by
  rw [output_from_original input actual row rowBound load hardware reduce]
  exact flushing_tail expPrecise expAbs _ _

theorem output_split (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (rowBound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) :
    output input actual row load reduce ops expPrecise expAbs 1=some
      (GateUpSplitTail.tail expAbs
        (BFloat16.narrow (projectionValues (activation:=activation) input row reduce).1)
        (BFloat16.narrow (projectionValues (activation:=activation) input row reduce).2)) := by
  rw [output_from_original input actual row rowBound load hardware reduce]
  exact split_tail ops expPrecise expAbs _ _
end Inference.Kernels.Trellis.GateTailSource
