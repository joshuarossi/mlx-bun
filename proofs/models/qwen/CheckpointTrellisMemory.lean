import models.qwen.CheckpointTrellis
import contracts.mlx.TensorMemory

namespace Inference.Models.Qwen.CheckpointTrellisMemory
open Contracts.Mlx Kernels.Trellis Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Finite checkpoint payloads and actual byte addresses share the same
-- little-endian interpretation. The payload-to-native-allocation attachment
-- remains an external loader obligation; it is not inferred from a hash.
def gateWords (memory : ByteMemory.Bytes) (base width : Nat) : DownExecution.PackedMatrix :=
  fun row block word => if row<17408 ∧ block<20 ∧ word<8*width then
    ByteMemory.load32 memory (base+4*DownCodebook.rowMajor row block word width) else 0

def downWords (memory : ByteMemory.Bytes) (base width : Nat) : DownExecution.PackedMatrix :=
  fun row block word => if row<17408 ∧ block<20 ∧ word<8*width then
    ByteMemory.load32 memory (base+4*(if width=3 then DownCodebook.interleaved row block word
      else DownCodebook.rowMajor row block word width)) else 0

def scale (memory : ByteMemory.Bytes) (base row : Nat) : Float32 :=
  if row<17408 then Float16.widen (Model.ofBits (HalfMemory.load memory (base+2*row))) else 0

theorem gate_load (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (payload : CheckpointTrellis.Codes width)
    (base : Nat) (before : ByteMemory.Bytes) (row block word : Nat)
    (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    ByteMemory.load32 (TensorMemory.place payload base before) (base+4*DownCodebook.rowMajor row block word width)=
      CheckpointTrellis.gateWords width valid payload row block word := by
  rw [CheckpointTrellis.gate_word width valid payload row block word hr hb hw]
  exact TensorMemory.load32 payload base before
    ⟨DownCodebook.rowMajor row block word width, CheckpointTrellis.row_major_bound width valid row block word hr hb hw⟩

theorem gate_words (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (payload : CheckpointTrellis.Codes width)
    (base : Nat) (before : ByteMemory.Bytes) :
    gateWords (TensorMemory.place payload base before) base width=CheckpointTrellis.gateWords width valid payload := by
  funext row block word
  by_cases inside : row<17408 ∧ block<20 ∧ word<8*width
  · simp only [gateWords, inside]
    exact gate_load width valid payload base before row block word inside.1 inside.2.1 inside.2.2
  · simp only [gateWords, CheckpointTrellis.gateWords, inside, ↓reduceIte, ↓reduceDIte]

theorem down_load (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (payload : CheckpointTrellis.Codes width)
    (base : Nat) (before : ByteMemory.Bytes) (row block word : Nat)
    (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    ByteMemory.load32 (TensorMemory.place payload base before)
      (base+4*(if width=3 then DownCodebook.interleaved row block word else DownCodebook.rowMajor row block word width))=
      CheckpointTrellis.downWords width valid payload row block word := by
  by_cases interleaved : width=3
  · subst width
    rw [ite_eq_left rfl, CheckpointTrellis.down_interleaved valid payload row block word hr hb hw]
    exact TensorMemory.load32 payload base before
      ⟨DownCodebook.interleaved row block word, DownCodebook.interleaved_bounds row block word hr hb hw⟩
  · rw [ite_eq_right interleaved, CheckpointTrellis.down_row_major width valid interleaved payload row block word hr hb hw]
    exact TensorMemory.load32 payload base before
      ⟨DownCodebook.rowMajor row block word width, CheckpointTrellis.row_major_bound width valid row block word hr hb hw⟩

theorem down_words (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (payload : CheckpointTrellis.Codes width)
    (base : Nat) (before : ByteMemory.Bytes) :
    downWords (TensorMemory.place payload base before) base width=CheckpointTrellis.downWords width valid payload := by
  funext row block word
  by_cases inside : row<17408 ∧ block<20 ∧ word<8*width
  · simp only [downWords, inside]
    exact down_load width valid payload base before row block word inside.1 inside.2.1 inside.2.2
  · simp only [downWords, CheckpointTrellis.downWords, inside, ↓reduceIte, ↓reduceDIte]

theorem scale_load (payload : CheckpointTrellis.Scales) (base : Nat) (before : ByteMemory.Bytes) (row : Fin 17408) :
    Float16.widen (Model.ofBits (HalfMemory.load (TensorMemory.place payload base before) (base+2*row.val)))=
      CheckpointTrellis.scale payload row.val := by
  rw [TensorMemory.load16 payload base before row, CheckpointTrellis.scale_exact]
  rfl

theorem scales (payload : CheckpointTrellis.Scales) (base : Nat) (before : ByteMemory.Bytes) :
    scale (TensorMemory.place payload base before) base=CheckpointTrellis.scale payload := by
  funext row
  by_cases inside : row<17408
  · simp only [scale, inside, ↓reduceIte]
    exact scale_load payload base before ⟨row,inside⟩
  · simp only [scale, CheckpointTrellis.scale, inside, ↓reduceIte, ↓reduceDIte]

-- Gate/up's main loads and single wrap load use 32-bit word offsets.
def gateIndex (row run width index : Nat) : Nat :=
  row*(20*(8*width))+run/8*(8*width)+
    (if index<width then GateUpCodebook.firstWord run width+index
     else if run%8=0 then 0 else GateUpCodebook.firstWord run width+width)

theorem gate_index (row run width index : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (hi : index ≤ width) :
    gateIndex row run width index=
      DownCodebook.rowMajor row (run/8) (((7-run%8)*width+index)%(8*width)) width := by
  unfold gateIndex DownCodebook.rowMajor
  by_cases main : index<width
  · rw [ite_eq_left main, (GateUpCodebook.word_loads run width index valid main).2.2.1]
  · have equal : index=width := by omega
    subst index
    rw [ite_eq_right (by omega), (GateUpCodebook.word_loads run width 0 valid (by rcases valid with rfl | rfl | rfl <;> omega)).2.2.2]

theorem gate_run_word (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (payload : CheckpointTrellis.Codes width)
    (base : Nat) (before : ByteMemory.Bytes) (row run index : Nat)
    (hr : row<17408) (hRun : run<160) (hi : index ≤ width) :
    ByteMemory.load32 (TensorMemory.place payload base before) (base+4*gateIndex row run width index)=
      GateUpCodebook.runWords (CheckpointTrellis.gateWords width valid payload row (run/8)) run width index := by
  rw [gate_index row run width index valid hi]
  unfold GateUpCodebook.runWords
  apply gate_load width valid payload base before row (run/8) _ hr (by omega)
  have positive : 0<8*width := by rcases valid with rfl | rfl | rfl <;> omega
  exact Nat.mod_lt _ positive

theorem gate_offset_bounds (row run width index : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (hr : row<17408) (hRun : run<160) (hi : index ≤ width) :
    gateIndex row run width index<17408*20*(8*width) ∧ gateIndex row run width index<2^32 := by
  rw [gate_index row run width index valid hi]
  have positive : 0<8*width := by rcases valid with rfl | rfl | rfl <;> omega
  exact GateUpCodebook.code_address_bounds row run width _ hr hRun valid (Nat.mod_lt _ positive)

-- Down's block pointer plus per-row stride, with the static layout selected
-- by the checkpoint's bit width. This is the address before the uint32 load.
def downIndex (row block word width : Nat) : Nat :=
  (if width=3 then block/2*17408*(2*(8*width))+block%2*(8*width) else block*(8*width))+
    row*(if width=3 then 2*(8*width) else 20*(8*width))+word

theorem down_index (row block word width : Nat) :
    downIndex row block word width=
      if width=3 then DownCodebook.interleaved row block word else DownCodebook.rowMajor row block word width := by
  unfold downIndex DownCodebook.interleaved DownCodebook.rowMajor
  by_cases interleaved : width=3
  · subst width; simp only [↓reduceIte]
  · simp only [interleaved, ↓reduceIte]; omega

theorem down_source_word (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4) (payload : CheckpointTrellis.Codes width)
    (base : Nat) (before : ByteMemory.Bytes) (row block word : Nat)
    (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    ByteMemory.load32 (TensorMemory.place payload base before) (base+4*downIndex row block word width)=
      CheckpointTrellis.downWords width valid payload row block word := by
  rw [down_index]
  exact down_load width valid payload base before row block word hr hb hw

theorem down_offset_bound (row block word width : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    downIndex row block word width<17408*20*(8*width) := by
  rw [down_index]
  by_cases interleaved : width=3
  · subst width
    rw [ite_eq_left rfl]
    exact DownCodebook.interleaved_bounds row block word hr hb hw
  · rw [ite_eq_right interleaved]
    exact CheckpointTrellis.row_major_bound width valid row block word hr hb hw

theorem gate_byte_bounds (base row run width index : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (hr : row<17408) (hRun : run<160) (hi : index ≤ width)
    (aligned : base%4=0) (bounded : base+4*(17408*20*(8*width)) ≤ 2^64) :
    let address := base+4*gateIndex row run width index
    address%4=0 ∧ base ≤ address ∧ address+4 ≤ base+4*(17408*20*(8*width)) ∧ address+4 ≤ 2^64 :=
  TensorMemory.load32_bounds base ⟨gateIndex row run width index,
    (gate_offset_bounds row run width index valid hr hRun hi).1⟩ aligned bounded

theorem gate_uint_index (row run width index : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (hr : row<17408) (hRun : run<160) (hi : index ≤ width) :
    (BitVec.ofNat 32 (gateIndex row run width index)).toNat=gateIndex row run width index := by
  rw [BitVec.toNat_ofNat, Nat.mod_eq_of_lt (gate_offset_bounds row run width index valid hr hRun hi).2]

theorem down_byte_bounds (base row block word width : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (hr : row<17408) (hb : block<20) (hw : word<8*width)
    (aligned : base%4=0) (bounded : base+4*(17408*20*(8*width)) ≤ 2^64) :
    let address := base+4*downIndex row block word width
    address%4=0 ∧ base ≤ address ∧ address+4 ≤ base+4*(17408*20*(8*width)) ∧ address+4 ≤ 2^64 :=
  TensorMemory.load32_bounds base ⟨downIndex row block word width,
    down_offset_bound row block word width valid hr hb hw⟩ aligned bounded

def gateProjection (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (codes : ByteMemory.Bytes) (codeBase : Nat) (scales : ByteMemory.Bytes) (scaleBase : Nat) :
    TrellisCodebookGateUp.Projection := ⟨gateWords codes codeBase width, width, valid, scale scales scaleBase⟩

def downProjection (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (codes : ByteMemory.Bytes) (codeBase : Nat) (scales : ByteMemory.Bytes) (scaleBase : Nat) :
    TrellisCodebookDown.Projection := ⟨downWords codes codeBase width, width, valid, scale scales scaleBase⟩

theorem gate_projection (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (codes : CheckpointTrellis.Codes width) (scales : CheckpointTrellis.Scales)
    (codeBase scaleBase : Nat) (codeBefore scaleBefore : ByteMemory.Bytes) :
    gateProjection width valid (TensorMemory.place codes codeBase codeBefore) codeBase
      (TensorMemory.place scales scaleBase scaleBefore) scaleBase=CheckpointTrellis.gateUp width valid codes scales := by
  unfold gateProjection CheckpointTrellis.gateUp
  rw [gate_words, CheckpointTrellisMemory.scales]

theorem down_projection (width : Nat) (valid : width=2 ∨ width=3 ∨ width=4)
    (codes : CheckpointTrellis.Codes width) (scales : CheckpointTrellis.Scales)
    (codeBase scaleBase : Nat) (codeBefore scaleBefore : ByteMemory.Bytes) :
    downProjection width valid (TensorMemory.place codes codeBase codeBefore) codeBase
      (TensorMemory.place scales scaleBase scaleBefore) scaleBase=CheckpointTrellis.down width valid codes scales := by
  unfold downProjection CheckpointTrellis.down
  rw [down_words, CheckpointTrellisMemory.scales]

end Inference.Models.Qwen.CheckpointTrellisMemory
