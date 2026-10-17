import kernels.trellis.GateFmaOperations
namespace Inference.Kernels.Trellis.GateWeightOperations
open Contracts.Mlx Contracts.Mlx.M1Max Models.Qwen PackedArrayMaterialization GateWeightSyntax GateWeightSource
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- The multiplication lowering is explicit, with scale widening and source
-- pointer/private-array reads shared by both standard and FTZ selections.
def readWeight (mul : Float32 → Float32 → Float32) (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (code : Weight) : Option Float32 := do
  if code.target=(if isUp then "uWeight" else "gWeight") ∧ code.function="trellis_codebook_window" ∧
      code.table="table" ∧ code.words=(if isUp then "u" else "g") ∧ code.virtual=(if isUp then "uv" else "gv") ∧
      code.scale=(if isUp then "uScale" else "gScale") then
    let level ←integer j kg ku code.level
    if level=12 then
      let coefficient ←CodebookWindowSource.readActual load memory base (GatePointerSource.arrays input row run isUp) (←offset j kg ku code)
      let scaling ←scale input row isUp
      pure (mul coefficient scaling)
    else none
  else none

def weight (mul : Float32 → Float32 → Float32) (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : Option Float32 := do
  readWeight mul input row run j isUp load memory base
    (←parseWeight (if isUp then upWeightSource else gateWeightSource))

def coefficient (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) : Float32 :=
  CodebookLoad.mathematicalCode (Codebook.PackedState.read (input.matrix isUp row (run/8))
    (if isUp then ku else kg) (run%8*32+j))

def value (mul : Float32 → Float32 → Float32) (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) : Float32 :=
  mul (coefficient input row run j isUp) (scaleValue input isUp row)

attribute [local irreducible] integer offset scale CodebookWindowSource.readActual

theorem weight_initialized (mul : Float32 → Float32 → Float32) (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (rowBound : row<17408) (runBound : run<160) (column : j<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (initialized : CodebookLoad.Initialized memory base)
    (aligned : base%4=0) (room : base+16384≤2^64) :
    weight mul input row run j isUp load memory base=some (value mul input row run j isUp) := by
  have off:=selected_offset (widthIndex kg input.validG) (widthIndex ku input.validU) ⟨j,column⟩ isUp
  have lev:=selected_level (widthIndex kg input.validG) (widthIndex ku input.validU) ⟨j,column⟩ isUp
  have kgEq : (widthIndex kg input.validG).val+2=kg:=width_index kg input.validG
  have kuEq : (widthIndex ku input.validU).val+2=ku:=width_index ku input.validU
  rw [kgEq,kuEq] at off lev
  unfold weight
  rw [parsed_weights]
  change readWeight mul input row run j isUp load memory base (weightAST isUp)=_
  unfold readWeight
  have names : (weightAST isUp).target=(if isUp then "uWeight" else "gWeight") ∧
      (weightAST isUp).function="trellis_codebook_window" ∧ (weightAST isUp).table="table" ∧
      (weightAST isUp).words=(if isUp then "u" else "g") ∧
      (weightAST isUp).virtual=(if isUp then "uv" else "gv") ∧
      (weightAST isUp).scale=(if isUp then "uScale" else "gScale") := by cases isUp <;> decide
  rw [ite_eq_left names]
  rw [lev]
  change (do
    let code ←CodebookWindowSource.readActual load memory base (GatePointerSource.arrays input row run isUp)
      (←offset j kg ku (weightAST isUp))
    let scaling ←scale input row isUp
    pure (mul code scaling))=_
  rw [off]
  change (CodebookWindowSource.readActual load memory base
    (GatePointerSource.arrays input row run isUp) ((31-j)*(if isUp then ku else kg))).bind _=_
  have read : CodebookWindowSource.readActual load memory base (GatePointerSource.arrays input row run isUp)
      ((31-j)*(if isUp then ku else kg))=some (coefficient input row run j isUp) := by
    rw [GatePointerSource.arrays_eq input row run isUp runBound]
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

end Inference.Kernels.Trellis.GateWeightOperations
