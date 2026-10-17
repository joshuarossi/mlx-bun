import kernels.trellis.PackedArrayDown
import kernels.trellis.CodebookWindowSource
import models.qwen.CheckpointTrellisStorage
namespace Inference.Kernels.Trellis.PackedArrayMaterialization
open Contracts.Mlx Models.Qwen PackedArraySemantics
set_option maxRecDepth 10000

def widthIndex (k : Nat) (valid : k=2 ∨ k=3 ∨ k=4) : Fin 3 := ⟨k-2,by rcases valid with rfl|rfl|rfl <;> omega⟩
theorem width_index (k : Nat) (valid : k=2 ∨ k=3 ∨ k=4) :
    PackedArrayGate.width (widthIndex k valid)=k := by rcases valid with rfl|rfl|rfl <;> rfl

theorem gate_cell (kg ku run : Nat) (validG : kg=2 ∨ kg=3 ∨ kg=4) (validU : ku=2 ∨ ku=3 ∨ ku=4)
    (runBound : run<8) (isUp virtual : Bool) (index : Nat) (bound : index≤(if isUp then ku else kg)) :
    PackedArrayGate.localCell kg ku run isUp virtual index=
      some (.word (if virtual then PackedArrayGate.virtualWord isUp (if isUp then ku else kg) run index
        else PackedArrayGate.sourceWord isUp (if isUp then ku else kg) run index)) := by
  have closed := PackedArrayGate.closed (widthIndex kg validG) (widthIndex ku validU) ⟨run,runBound⟩ isUp virtual
    ⟨index,by simpa only [width_index] using Nat.lt_succ_of_le bound⟩
  simpa only [width_index] using closed

structure GateInput (kg ku : Nat) where
  validG : kg=2 ∨ kg=3 ∨ kg=4
  validU : ku=2 ∨ ku=3 ∨ ku=4
  gateCodes : CheckpointTrellis.Codes kg
  upCodes : CheckpointTrellis.Codes ku
  gateScales : CheckpointTrellis.Scales
  upScales : CheckpointTrellis.Scales
  gate : CheckpointTrellisStorage.Storage gateCodes gateScales
  up : CheckpointTrellisStorage.Storage upCodes upScales
  shared : up.code.bytes=gate.code.bytes

def GateInput.baseIndex (_input : GateInput kg ku) (isUp : Bool) (row run : Nat) : Nat :=
  let k := if isUp then ku else kg
  row*(20*(8*k))+run/8*(8*k)

def GateInput.bases (input : GateInput kg ku) (row run : Nat) : String → BitVec 32 := fun name =>
  if name="gw" then BitVec.ofNat 32 (input.baseIndex false row run)
  else if name="uw" then BitVec.ofNat 32 (input.baseIndex true row run) else 0

def GateInput.globals (input : GateInput kg ku) : String → Nat → BitVec 32 := fun name index =>
  if name="gcodes" then ByteMemory.load32 input.gate.code.bytes (input.gate.code.base+4*index)
  else if name="ucodes" then ByteMemory.load32 input.gate.code.bytes (input.up.code.base+4*index) else 0

def GateInput.matrix (input : GateInput kg ku) (isUp : Bool) : DownExecution.PackedMatrix :=
  if isUp then CheckpointTrellis.gateWords ku input.validU input.upCodes
  else CheckpointTrellis.gateWords kg input.validG input.gateCodes

theorem gate_delta (row run k index : Nat) (valid : k=2 ∨ k=3 ∨ k=4) :
    row*(20*(8*k))+run/8*(8*k)+PackedArrayGate.delta k (run%8) index=
      CheckpointTrellisMemory.gateIndex row run k index := by
  have first := (GateUpCodebook.word_loads run k 0 valid (by rcases valid with rfl|rfl|rfl <;> omega)).1
  simp only [PackedArrayGate.delta,CheckpointTrellisMemory.gateIndex,first]

theorem gate_native_index (row run k index : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤k) :
    (BitVec.ofNat 32 (row*(20*(8*k))+run/8*(8*k))+
      BitVec.ofNat 32 (PackedArrayGate.delta k (run%8) index)).toNat=
      CheckpointTrellisMemory.gateIndex row run k index := by
  have total := (CheckpointTrellisMemory.gate_offset_bounds row run k index valid rowBound runBound bound).2
  have arithmetic := gate_delta row run k index valid
  have baseBound : row*(20*(8*k))+run/8*(8*k)<2^32 := by omega
  have deltaBound : PackedArrayGate.delta k (run%8) index<2^32 := by omega
  rw [BitVec.toNat_add,BitVec.toNat_ofNat,BitVec.toNat_ofNat,Nat.mod_eq_of_lt baseBound,Nat.mod_eq_of_lt deltaBound,
    arithmetic,Nat.mod_eq_of_lt total]

theorem GateInput.source_word (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (index : Nat)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤(if isUp then ku else kg)) :
    (PackedArrayGate.sourceWord isUp (if isUp then ku else kg) (run%8) index).evaluate (input.bases row run) input.globals=
      GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg) index := by
  cases isUp with
  | false =>
    change ByteMemory.load32 input.gate.code.bytes (input.gate.code.base+4*
      ((BitVec.ofNat 32 (row*(20*(8*kg))+run/8*(8*kg)))+
        BitVec.ofNat 32 (PackedArrayGate.delta kg (run%8) index)).toNat)=_
    rw [gate_native_index row run kg index input.validG rowBound runBound bound]
    exact input.gate.gate_run_word input.validG row run index rowBound runBound bound
  | true =>
    change ByteMemory.load32 input.gate.code.bytes (input.up.code.base+4*
      ((BitVec.ofNat 32 (row*(20*(8*ku))+run/8*(8*ku)))+
        BitVec.ofNat 32 (PackedArrayGate.delta ku (run%8) index)).toNat)=_
    rw [gate_native_index row run ku index input.validU rowBound runBound bound]
    rw [←input.shared]
    exact input.up.gate_run_word input.validU row run index rowBound runBound bound

theorem GateInput.virtual_word (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (index : Nat)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤(if isUp then ku else kg)) :
    (PackedArrayGate.virtualWord isUp (if isUp then ku else kg) (run%8) index).evaluate (input.bases row run) input.globals=
      Codebook.CodebookWindow.virtualWord (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg)) index := by
  unfold PackedArrayGate.virtualWord Codebook.CodebookWindow.virtualWord
  split
  · simp only [Word.evaluate]
    rw [input.source_word row run isUp 0 rowBound runBound (by omega)]
  · simp only [Word.evaluate]
    rw [input.source_word row run isUp (index-1) rowBound runBound (by omega),
      input.source_word row run isUp index rowBound runBound bound]

def materialize (bases : String → BitVec 32) (global : String → Nat → BitVec 32) : Value → Option (BitVec 32)
  | .word expression => some (expression.evaluate bases global)
  | .unsigned value => some value
  | _ => none

def GateInput.arrayCell (input : GateInput kg ku) (row run : Nat) (isUp virtual : Bool) (index : Nat) : Option (BitVec 32) :=
  (PackedArrayGate.localCell kg ku (run%8) isUp virtual index).bind (materialize (input.bases row run) input.globals)

theorem GateInput.primary_cell (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (index : Nat)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤(if isUp then ku else kg)) :
    input.arrayCell row run isUp false index=some
      (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg) index) := by
  unfold GateInput.arrayCell
  rw [gate_cell kg ku (run%8) input.validG input.validU (Nat.mod_lt _ (by decide)) isUp false index bound]
  exact congrArg some (input.source_word row run isUp index rowBound runBound bound)

theorem GateInput.virtual_cell (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (index : Nat)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤(if isUp then ku else kg)) :
    input.arrayCell row run isUp true index=some
      (Codebook.CodebookWindow.virtualWord (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg)) index) := by
  unfold GateInput.arrayCell
  rw [gate_cell kg ku (run%8) input.validG input.validU (Nat.mod_lt _ (by decide)) isUp true index bound]
  exact congrArg some (input.virtual_word row run isUp index rowBound runBound bound)

def GateInput.arrays (input : GateInput kg ku) (row run : Nat) (isUp : Bool) : String → Nat → BitVec 32 := fun name index =>
  if name="w" then (input.arrayCell row run isUp false index).getD 0
  else if name="v" then (input.arrayCell row run isUp true index).getD 0 else 0

theorem GateInput.array_primary (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (index : Nat)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤(if isUp then ku else kg)) :
    input.arrays row run isUp "w" index=GateUpCodebook.runWords
      (input.matrix isUp row (run/8)) run (if isUp then ku else kg) index := by
  change (input.arrayCell row run isUp false index).getD 0=_
  rw [input.primary_cell row run isUp index rowBound runBound bound]
  rfl

theorem GateInput.array_virtual (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (index : Nat)
    (rowBound : row<17408) (runBound : run<160) (bound : index≤(if isUp then ku else kg)) :
    input.arrays row run isUp "v" index=Codebook.CodebookWindow.virtualWord
      (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg)) index := by
  change (input.arrayCell row run isUp true index).getD 0=_
  rw [input.virtual_cell row run isUp index rowBound runBound bound]
  rfl

-- Zero extends the finite private array ONLY outside its declared domain. The
-- following proof establishes every actual helper subscript is inside it.
theorem GateInput.window (input : GateInput kg ku) (row run : Nat) (isUp : Bool) (j : Nat)
    (rowBound : row<17408) (runBound : run<160) (column : j<32) :
    CodebookWindowSemantics.executeArrays (input.arrays row run isUp) ((31-j)*(if isUp then ku else kg))=
      some (Codebook.CodebookWindow.byteOffset
        (GateUpCodebook.runWords (input.matrix isUp row (run/8)) run (if isUp then ku else kg)) ((31-j)*(if isUp then ku else kg))) := by
  have valid : (if isUp then ku else kg)=2 ∨ (if isUp then ku else kg)=3 ∨ (if isUp then ku else kg)=4 := by
    cases isUp <;> first | exact input.validG | exact input.validU
  have bounds := GateUpCodebook.window_bounds (if isUp then ku else kg) j valid column
  rw [CodebookWindowSemantics.actual_arrays _ _ bounds.1]
  by_cases test : 2≤(31-j)*(if isUp then ku else kg) ∧ ((31-j)*(if isUp then ku else kg)-2)%32+14≤32
  · rw [CodebookWindowSemantics.expected,ite_eq_left test,Codebook.CodebookWindow.byteOffset,ite_eq_left test]
    change some (((input.arrays row run isUp "w" (((31-j)*(if isUp then ku else kg)-2)/32)) >>>
      (((31-j)*(if isUp then ku else kg)-2)%32)) &&& 16383)=_
    rw [input.array_primary row run isUp (((31-j)*(if isUp then ku else kg)-2)/32) rowBound runBound (by omega)]
    rfl
  · rw [CodebookWindowSemantics.expected,ite_eq_right test,Codebook.CodebookWindow.byteOffset,ite_eq_right test]
    change some (((input.arrays row run isUp "v" (((31-j)*(if isUp then ku else kg)+14)/32)) >>>
      (((31-j)*(if isUp then ku else kg)+14)%32)) &&& 16383)=_
    rw [input.array_virtual row run isUp (((31-j)*(if isUp then ku else kg)+14)/32) rowBound runBound (by omega)]
    rfl
end Inference.Kernels.Trellis.PackedArrayMaterialization
