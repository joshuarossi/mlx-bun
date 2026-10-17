import kernels.trellis.GatePointerSemantics
import kernels.trellis.GateWeightSource
namespace Inference.Kernels.Trellis.GatePointerSource
open Contracts.Mlx Contracts.Mlx.M1Max Models.Qwen PackedArrayMaterialization
open GatePointerSemantics
set_option maxRecDepth 10000

attribute [local irreducible] GatePointerSemantics.execute GatePointerSemantics.prepare

theorem prepared_selected (input : GateInput kg ku) (run : Nat) (runBound : run<160) :
    prepare kg ku run=some (expected kg ku run) := by
  rw [prepare_source]
  have selected:=prepared (widthIndex kg input.validG) (widthIndex ku input.validU) ⟨run,runBound⟩
  have kgEq : (widthIndex kg input.validG).val+2=kg:=width_index kg input.validG
  have kuEq : (widthIndex ku input.validU).val+2=ku:=width_index ku input.validU
  simpa only [kgEq,kuEq] using selected

def resolve (state : Environment) (row : Nat) (name : String) : Option (BitVec 32) := do
  pure ((unsigned (←PackedArraySemantics.lookup name state)).realize row)

def base (_input : GateInput kg ku) (row run : Nat) (isUp : Bool) : Option (BitVec 32) := do
  resolve (←prepare kg ku run) row (if isUp then "uw" else "gw")

theorem base_eq (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (runBound : run<160) :
    base input row run isUp=some (BitVec.ofNat 32 (input.baseIndex isUp row run)) := by
  unfold base
  rw [prepared_selected input run runBound]
  cases isUp with
  | false =>
    change some (BitVec.ofNat 32 row*BitVec.ofNat 32 (20*(8*kg))+BitVec.ofNat 32 (run/8*(8*kg)))=_
    rw [←BitVec.ofNat_mul,←BitVec.ofNat_add]
    rfl
  | true =>
    change some (BitVec.ofNat 32 row*BitVec.ofNat 32 (20*(8*ku))+BitVec.ofNat 32 (run/8*(8*ku)))=_
    rw [←BitVec.ofNat_mul,←BitVec.ofNat_add]
    rfl

def bases (input : GateInput kg ku) (row run : Nat) : Option (String → BitVec 32) :=
  (base input row run false).bind (fun gate => (base input row run true).bind
    (fun up => some (fun name => if name="gw" then gate else if name="uw" then up else 0)))

theorem bases_eq (input : GateInput kg ku) (row run : Nat) (runBound : run<160) :
    bases input row run=some (input.bases row run) := by
  unfold bases
  rw [base_eq input row run false runBound]
  rw [Option.bind_some]
  rw [base_eq input row run true runBound]
  rfl

-- This is a word INDEX, not a reinterpreted byte pointer. Its byte address in
-- the original code buffer is base+4*index, as in source_word below.
theorem base_not_wrapped (input : GateInput kg ku) (row run : Nat) (isUp : Bool)
    (rowBound : row<17408) (runBound : run<160) :
    (base input row run isUp).map BitVec.toNat=some (input.baseIndex isUp row run) := by
  have valid : (if isUp then ku else kg)=2 ∨ (if isUp then ku else kg)=3 ∨ (if isUp then ku else kg)=4 := by
    cases isUp <;> first | exact input.validG | exact input.validU
  have last:=(CheckpointTrellisMemory.gate_offset_bounds row run (if isUp then ku else kg) 0 valid rowBound runBound (by omega)).2
  have offset:=gate_delta row run (if isUp then ku else kg) 0 valid
  have bounded : input.baseIndex isUp row run<2^32 := by
    dsimp only [GateInput.baseIndex]
    omega
  rw [base_eq input row run isUp runBound]
  change some (BitVec.ofNat 32 (input.baseIndex isUp row run)).toNat=_
  rw [BitVec.toNat_ofNat,Nat.mod_eq_of_lt bounded]

-- Symbolic anchors are a representation of the two already-computed uint32
-- bases. The scalar private-array inputs come from executed source declarations.
def privateInitial (_input : GateInput kg ku) (run : Nat) : Option PackedArraySemantics.State := do
  let state ←prepare kg ku run
  let gateFirst ←resolve state 0 "gW0"
  let upFirst ←resolve state 0 "uW0"
  let t0 ←resolve state 0 "t0"
  pure ⟨[("KG",.signed kg),("KU",.signed ku),("gw",.address "gw" 0),("uw",.address "uw" 0),
    ("gW0",.unsigned gateFirst),("uW0",.unsigned upFirst),("t0",.unsigned t0)],[],["gcodes","ucodes"]⟩

theorem private_initial_eq (input : GateInput kg ku) (run : Nat) (runBound : run<160) :
    privateInitial input run=some (PackedArrayGate.initial kg ku (run%8)) := by
  unfold privateInitial
  rw [prepared_selected input run runBound]
  rfl

def localCell (input : GateInput kg ku) (run : Nat) (isUp virtual : Bool) (index : Nat) : Option PackedArraySemantics.Value :=
  (privateInitial input run).bind (fun initial =>
    (PackedArrayPrograms.sourceExecute PackedArrayPrograms.gateSources initial).bind (fun state =>
      PackedArraySemantics.cell state (if isUp then if virtual then "uv" else "u" else if virtual then "gv" else "g") [index]))

theorem local_cell_eq (input : GateInput kg ku) (run : Nat) (isUp virtual : Bool) (index : Nat) (runBound : run<160) :
    localCell input run isUp virtual index=PackedArrayGate.localCell kg ku (run%8) isUp virtual index := by
  unfold localCell
  rw [private_initial_eq input run runBound]
  rw [Option.bind_some]
  rw [PackedArrayGate.from_source]
  rfl

def arrayCell (input : GateInput kg ku) (row run : Nat) (isUp virtual : Bool) (index : Nat) : Option (BitVec 32) :=
  (bases input row run).bind (fun bases => (localCell input run isUp virtual index).bind (materialize bases input.globals))

theorem array_cell_eq (input : GateInput kg ku) (row run : Nat) (isUp virtual : Bool) (index : Nat) (runBound : run<160) :
    arrayCell input row run isUp virtual index=input.arrayCell row run isUp virtual index := by
  unfold arrayCell
  rw [bases_eq input row run runBound]
  rw [Option.bind_some]
  rw [local_cell_eq input run isUp virtual index runBound]
  rfl

def arrays (input : GateInput kg ku) (row run : Nat) (isUp : Bool) : String → Nat → BitVec 32 := fun name index =>
  if name="w" then (arrayCell input row run isUp false index).getD 0
  else if name="v" then (arrayCell input row run isUp true index).getD 0 else 0

theorem arrays_eq (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (runBound : run<160) :
    arrays input row run isUp=input.arrays row run isUp := by
  funext name index
  unfold arrays GateInput.arrays
  rw [array_cell_eq input row run isUp false index runBound,array_cell_eq input row run isUp true index runBound]

theorem source_word (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (index : Nat)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤(if isUp then ku else kg)) :
    arrayCell input row run isUp false index=some
      (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg) index) := by
  rw [array_cell_eq input row run isUp false index runBound]
  exact input.primary_cell row run isUp index rowBound runBound bound

-- The original/current global byte heap is unchanged by source context
-- evaluation. Widths, wrap, virtual words and window helper all use that heap.
theorem window (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (rowBound : row<17408) (runBound : run<160) (column : j<32)
    (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base : Nat) (completed : CodebookTableSource.ParsedCompleted base 1024)
    (aligned : base%4=0) (room : base+16384≤2^64) :
    CodebookWindowSource.readActual load (Memory.execute completed.schedule before) base (arrays input row run isUp)
      ((31-j)*(if isUp then ku else kg))=some (GateWeightSource.coefficient input row run j isUp) := by
  rw [arrays_eq input row run isUp runBound]
  exact PackedArrayConsumer.gate_read input row run j isUp rowBound runBound column load hardware before base completed aligned room

-- Same parsed call/scalar semantics as the frozen weight interpreter, now
-- with private arrays constructed from the parsed pointer setup above.
def readWeight (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (code : GateWeightSyntax.Weight) : Option Float32 := do
  if code.target=(if isUp then "uWeight" else "gWeight") ∧ code.function="trellis_codebook_window" ∧
      code.table="table" ∧ code.words=(if isUp then "u" else "g") ∧ code.virtual=(if isUp then "uv" else "gv") ∧
      code.scale=(if isUp then "uScale" else "gScale") then
    let level ←GateWeightSource.integer j kg ku code.level
    if level=12 then
      let coefficient ←CodebookWindowSource.readActual load memory base (arrays input row run isUp)
        (←GateWeightSource.offset j kg ku code)
      let scaling ←GateWeightSource.scale input row isUp
      pure (coefficient*scaling)
    else none
  else none

theorem read_weight_eq (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) (runBound : run<160)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (code : GateWeightSyntax.Weight) :
    readWeight input row run j isUp load memory base code=GateWeightSource.readWeight input row run j isUp load memory base code := by
  unfold readWeight GateWeightSource.readWeight
  rw [arrays_eq input row run isUp runBound]

def weight (input : GateInput kg ku) (row run j : Nat) (isUp : Bool)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) : Option Float32 := do
  readWeight input row run j isUp load memory base
    (←GateWeightSyntax.parseWeight (if isUp then GateWeightSyntax.upWeightSource else GateWeightSyntax.gateWeightSource))

theorem weight_eq (input : GateInput kg ku) (row run j : Nat) (isUp : Bool) (runBound : run<160)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) :
    weight input row run j isUp load memory base=GateWeightSource.weight input row run j isUp load memory base := by
  simp only [weight,GateWeightSource.weight,read_weight_eq input row run j isUp runBound]

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

def memoryStep (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row run q p : Nat) (load : ThreadgroupLoad) (acc : GateAccumulateSource.Dual) : Option GateAccumulateSource.Dual := do
  let gate ←weight input row run (q*8+p) false load (GateWeightSource.tableMemory actual) tableBase
  let up ←weight input row run (q*8+p) true load (GateWeightSource.tableMemory actual) tableBase
  GateAccumulateSource.memoryStep actual.memory inputBase run q p gate up acc

theorem memory_step_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row run q p : Nat) (runBound : run<160) (load : ThreadgroupLoad) (acc : GateAccumulateSource.Dual) :
    memoryStep input actual row run q p load acc=GateWeightSource.memoryStep input actual row run q p load acc := by
  unfold memoryStep GateWeightSource.memoryStep
  rw [weight_eq input row run (q*8+p) false runBound,weight_eq input row run (q*8+p) true runBound]
end Inference.Kernels.Trellis.GatePointerSource
