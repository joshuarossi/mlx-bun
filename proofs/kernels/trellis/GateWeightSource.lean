import kernels.trellis.GateWeightSyntax
import kernels.trellis.GateAccumulateSource
import kernels.trellis.PackedArrayWeights
namespace Inference.Kernels.Trellis.GateWeightSource
open Contracts.Mlx Contracts.Mlx.M1Max Models.Qwen PackedArrayMaterialization GateWeightSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Source expressions are evaluated as uint32, including subtraction/cast.
def integer (j kg ku : Nat) : PackedArraySyntax.Expr → Option (BitVec 32)
  | .variable name => if name="j" then some (BitVec.ofNat 32 j)
    else if name="KG" then some (BitVec.ofNat 32 kg)
    else if name="KU" then some (BitVec.ofNat 32 ku)
    else if name="L" then some 12 else none
  | .literal .unsigned n => if n<2^32 then some (BitVec.ofNat 32 n) else none
  | .castUInt value => integer j kg ku value
  | .subtract a b => do pure ((←integer j kg ku a)-(←integer j kg ku b))
  | .multiply a b => do pure ((←integer j kg ku a)*(←integer j kg ku b))
  | _ => none

def offset (j kg ku : Nat) (code : Weight) : Option Nat := do
  pure (←integer j kg ku code.offset).toNat

theorem selected_offset : ∀ kg ku : Fin 3, ∀ j : Fin 32, ∀ isUp : Bool,
    offset j.val (kg.val+2) (ku.val+2) (weightAST isUp)=some ((31-j.val)*(if isUp then ku.val+2 else kg.val+2)) := by decide +kernel

theorem selected_level : ∀ kg ku : Fin 3, ∀ j : Fin 32, ∀ isUp : Bool,
    integer j.val (kg.val+2) (ku.val+2) (weightAST isUp).level=some 12 := by decide +kernel

-- The cast float(scales[row]) widens an IEEE half stored at the actual pointer.
-- These checkpoint scales are FP16; activation staging remains BF16.
def readScale (input : GateInput kg ku) (row : Nat) (code : Scale) : Option Float32 := do
  if code.index matches .variable "row" then
    if row<17408 then
      if code.array="gscales" ∧ code.target="gScale" then
        pure (Float16.widen (Model.ofBits (HalfMemory.load input.gate.code.bytes (input.gate.scale.base+2*row))))
      else if code.array="uscales" ∧ code.target="uScale" then
        pure (Float16.widen (Model.ofBits (HalfMemory.load input.up.code.bytes (input.up.scale.base+2*row))))
      else none
    else none
  else none

def scale (input : GateInput kg ku) (row : Nat) (isUp : Bool) : Option Float32 := do
  readScale input row (←parseScale (if isUp then upScaleSource else gateScaleSource))

def scaleValue (input : GateInput kg ku) (isUp : Bool) (row : Nat) : Float32 :=
  if isUp then CheckpointTrellis.scale input.upScales row else CheckpointTrellis.scale input.gateScales row

attribute [local irreducible] parseScale parseWeight

theorem scale_original (input : GateInput kg ku) (row : Nat) (rowBound : row<17408) (isUp : Bool) :
    scale input row isUp=some (scaleValue input isUp row) := by
  unfold scale
  rw [parsed_scales]
  cases isUp with
  | false =>
    change (if row<17408 then some (Float16.widen (Model.ofBits (HalfMemory.load input.gate.code.bytes
      (input.gate.scale.base+2*row)))) else none)=_
    rw [ite_eq_left rowBound,input.gate.scale_load ⟨row,rowBound⟩]
    rfl
  | true =>
    change (if row<17408 then some (Float16.widen (Model.ofBits (HalfMemory.load input.up.code.bytes
      (input.up.scale.base+2*row)))) else none)=_
    rw [ite_eq_left rowBound,input.up.scale_load ⟨row,rowBound⟩]
    rfl

-- Calls resolve their retained array/table/function names, so a renamed operand
-- cannot silently read the other projection. Multiplication rounds BEFORE FMA.
def readWeight (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (code : Weight) : Option Float32 := do
  if code.target=(if isUp then "uWeight" else "gWeight") ∧ code.function="trellis_codebook_window" ∧
      code.table="table" ∧ code.words=(if isUp then "u" else "g") ∧ code.virtual=(if isUp then "uv" else "gv") ∧
      code.scale=(if isUp then "uScale" else "gScale") then
    let level ←integer j kg ku code.level
    if level=12 then
      let coefficient ←CodebookWindowSource.readActual load memory base (input.arrays row run isUp) (←offset j kg ku code)
      let scaling ←scale input row isUp
      pure (coefficient * scaling)
    else none
  else none

def weight (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : Option Float32 := do
  readWeight input row run j isUp load memory base
    (←parseWeight (if isUp then upWeightSource else gateWeightSource))

def coefficient (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) : Float32 :=
  CodebookLoad.mathematicalCode (Codebook.PackedState.read (input.matrix isUp row (run/8))
    (if isUp then ku else kg) (run%8*32+j))

def value (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) : Float32 :=
  coefficient input row run j isUp * scaleValue input isUp row

attribute [local irreducible] integer offset scale CodebookWindowSource.readActual

theorem weight_initialized (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (rowBound : row<17408) (runBound : run<160) (column : j<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (initialized : CodebookLoad.Initialized memory base)
    (aligned : base%4=0) (room : base+16384≤2^64) :
    weight input row run j isUp load memory base=some (value input row run j isUp) := by
  have off:=selected_offset (widthIndex kg input.validG) (widthIndex ku input.validU) ⟨j,column⟩ isUp
  have lev:=selected_level (widthIndex kg input.validG) (widthIndex ku input.validU) ⟨j,column⟩ isUp
  have kgEq : (widthIndex kg input.validG).val+2=kg:=width_index kg input.validG
  have kuEq : (widthIndex ku input.validU).val+2=ku:=width_index ku input.validU
  rw [kgEq,kuEq] at off lev
  unfold weight
  rw [parsed_weights]
  change readWeight input row run j isUp load memory base (weightAST isUp)=_
  unfold readWeight
  have names : (weightAST isUp).target=(if isUp then "uWeight" else "gWeight") ∧
      (weightAST isUp).function="trellis_codebook_window" ∧ (weightAST isUp).table="table" ∧
      (weightAST isUp).words=(if isUp then "u" else "g") ∧
      (weightAST isUp).virtual=(if isUp then "uv" else "gv") ∧
      (weightAST isUp).scale=(if isUp then "uScale" else "gScale") := by cases isUp <;> decide
  rw [ite_eq_left names]
  rw [lev]
  change (do
    let code ←CodebookWindowSource.readActual load memory base (input.arrays row run isUp)
      (←offset j kg ku (weightAST isUp))
    let scaling ←scale input row isUp
    pure (code*scaling))=_
  rw [off]
  change (CodebookWindowSource.readActual load memory base
    (input.arrays row run isUp) ((31-j)*(if isUp then ku else kg))).bind _=_
  have read : CodebookWindowSource.readActual load memory base (input.arrays row run isUp)
      ((31-j)*(if isUp then ku else kg))=some (coefficient input row run j isUp) := by
    unfold CodebookWindowSource.readActual
    rw [input.window row run isUp j rowBound runBound column]
    change some (CodebookLoad.read load memory base
      (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg))
      ((31-j)*(if isUp then ku else kg)))=_
    have valid : (if isUp then ku else kg)=2 ∨ (if isUp then ku else kg)=3 ∨ (if isUp then ku else kg)=4 := by
      cases isUp <;> first | exact input.validG | exact input.validU
    exact congrArg some (GateUpCodebook.load_correct load hardware memory base aligned room initialized
      _ run (if isUp then ku else kg) j valid column)
  rw [read]
  change (scale input row isUp).bind _=_
  rw [scale_original input row rowBound isUp]
  rfl

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

def tableMemory (actual : GateInputSource.Execution source tableBase inputBase) : WordMemory :=
  GateUpBarrier.floatMemory (ByteMemory.view actual.memory)

theorem table_initialized (actual : GateInputSource.Execution source tableBase inputBase) :
    CodebookLoad.Initialized (tableMemory actual) tableBase := actual.existing.ready.codebook

attribute [local irreducible] weight GateAccumulateSource.memoryStep GateInputSource.Execution.memory tableMemory

-- Both weight calls and the input read use the SAME completed threadgroup
-- byte heap. Packed codes and FP16 scales retain their original buffers.
def memoryStep (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row run q p : Nat) (load : ThreadgroupLoad) (acc : GateAccumulateSource.Dual) : Option GateAccumulateSource.Dual := do
  let gate ←weight input row run (q*8+p) false load (tableMemory actual) tableBase
  let up ←weight input row run (q*8+p) true load (tableMemory actual) tableBase
  GateAccumulateSource.memoryStep actual.memory inputBase run q p gate up acc

theorem memory_step (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row run q p : Nat) (rowBound : row<17408) (runBound : run<160) (qBound : q<4) (pBound : p<8)
    (load : ThreadgroupLoad) (hardware : LoadContract load) (acc : GateAccumulateSource.Dual) :
    memoryStep input actual row run q p load acc=some
      (GateUpExecution.accumulate (q*8+p) (value input row run (q*8+p) false)
        (GateUpExecution.widen (ArrayStorage.bfWords activation (run*32+q*8+p))) acc.1,
       GateUpExecution.accumulate (q*8+p) (value input row run (q*8+p) true)
        (GateUpExecution.widen (ArrayStorage.bfWords activation (run*32+q*8+p))) acc.2) := by
  unfold memoryStep
  rw [weight_initialized input row run (q*8+p) false rowBound runBound (by omega) load hardware
    (tableMemory actual) tableBase (table_initialized actual) actual.tableAligned actual.tableBounded]
  change (weight input row run (q*8+p) true load (tableMemory actual) tableBase).bind _=_
  rw [weight_initialized input row run (q*8+p) true rowBound runBound (by omega) load hardware
    (tableMemory actual) tableBase (table_initialized actual) actual.tableAligned actual.tableBounded]
  exact GateAccumulateSource.memory_step actual run q p runBound qBound pBound _ _ acc
end Inference.Kernels.Trellis.GateWeightSource
