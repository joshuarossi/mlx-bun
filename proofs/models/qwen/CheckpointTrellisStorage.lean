import models.qwen.CheckpointTrellisMemory
import contracts.mlx.TensorStorage

namespace Inference.Models.Qwen.CheckpointTrellisStorage
open Contracts.Mlx Kernels.Trellis Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {width : Nat} {codes : CheckpointTrellis.Codes width} {scales : CheckpointTrellis.Scales}

theorem gate_words (buffer : TensorStorage.Buffer codes) (valid : width=2 ∨ width=3 ∨ width=4) :
    CheckpointTrellisMemory.gateWords buffer.bytes buffer.base width=CheckpointTrellis.gateWords width valid codes := by
  funext row block word
  by_cases inside : row<17408 ∧ block<20 ∧ word<8*width
  · simp only [CheckpointTrellisMemory.gateWords, inside]
    rw [CheckpointTrellis.gate_word width valid codes row block word inside.1 inside.2.1 inside.2.2]
    exact buffer.load32 ⟨_, CheckpointTrellis.row_major_bound width valid row block word inside.1 inside.2.1 inside.2.2⟩
  · simp only [CheckpointTrellisMemory.gateWords, CheckpointTrellis.gateWords, inside, ↓reduceIte, ↓reduceDIte]

theorem down_words (buffer : TensorStorage.Buffer codes) (valid : width=2 ∨ width=3 ∨ width=4) :
    CheckpointTrellisMemory.downWords buffer.bytes buffer.base width=CheckpointTrellis.downWords width valid codes := by
  funext row block word
  by_cases inside : row<17408 ∧ block<20 ∧ word<8*width
  · simp only [CheckpointTrellisMemory.downWords, inside]
    by_cases interleaved : width=3
    · subst width
      rw [ite_eq_left rfl, CheckpointTrellis.down_interleaved valid codes row block word inside.1 inside.2.1 inside.2.2]
      exact buffer.load32 ⟨_, DownCodebook.interleaved_bounds row block word inside.1 inside.2.1 inside.2.2⟩
    · rw [ite_eq_right interleaved, CheckpointTrellis.down_row_major width valid interleaved codes row block word inside.1 inside.2.1 inside.2.2]
      exact buffer.load32 ⟨_, CheckpointTrellis.row_major_bound width valid row block word inside.1 inside.2.1 inside.2.2⟩
  · simp only [CheckpointTrellisMemory.downWords, CheckpointTrellis.downWords, inside, ↓reduceIte, ↓reduceDIte]

theorem scale_values (buffer : TensorStorage.Buffer scales) :
    CheckpointTrellisMemory.scale buffer.bytes buffer.base=CheckpointTrellis.scale scales := by
  funext row
  by_cases inside : row<17408
  · simp only [CheckpointTrellisMemory.scale, inside, ↓reduceIte]
    rw [buffer.load16 ⟨row,inside⟩, CheckpointTrellis.scale_exact scales ⟨row,inside⟩]
    rfl
  · simp only [CheckpointTrellisMemory.scale, CheckpointTrellis.scale, inside, ↓reduceIte, ↓reduceDIte]

structure Storage (codes : CheckpointTrellis.Codes width) (scales : CheckpointTrellis.Scales) where
  code : TensorStorage.Buffer codes
  scale : TensorStorage.Buffer scales
  shared : scale.bytes=code.bytes
  codeAligned : code.base%4=0
  scaleAligned : scale.base%2=0

def fromPayloads (codes : CheckpointTrellis.Codes width) (scales : CheckpointTrellis.Scales)
    (before : ByteMemory.Bytes) (codeBase scaleBase : Nat)
    (codeAligned : codeBase%4=0) (scaleAligned : scaleBase%2=0)
    (codeBound : codeBase+4*(17408*20*(8*width)) ≤ 2^64) (scaleBound : scaleBase+34816 ≤ 2^64)
    (separate : MemoryRegions.Disjoint scaleBase 34816 codeBase (4*(17408*20*(8*width)))) : Storage codes scales :=
  let code := TensorStorage.placed codes codeBase before codeBound
  ⟨code.afterPlace scales scaleBase separate, TensorStorage.placed scales scaleBase code.bytes scaleBound,
    rfl, codeAligned, scaleAligned⟩

def Storage.gateProjection (storage : Storage codes scales) (valid : width=2 ∨ width=3 ∨ width=4) :
    TrellisCodebookGateUp.Projection :=
  CheckpointTrellisMemory.gateProjection width valid storage.code.bytes storage.code.base storage.scale.bytes storage.scale.base

def Storage.downProjection (storage : Storage codes scales) (valid : width=2 ∨ width=3 ∨ width=4) :
    TrellisCodebookDown.Projection :=
  CheckpointTrellisMemory.downProjection width valid storage.code.bytes storage.code.base storage.scale.bytes storage.scale.base

theorem Storage.gate_eq (storage : Storage codes scales) (valid : width=2 ∨ width=3 ∨ width=4) :
    storage.gateProjection valid=CheckpointTrellis.gateUp width valid codes scales := by
  unfold Storage.gateProjection CheckpointTrellisMemory.gateProjection CheckpointTrellis.gateUp
  rw [gate_words storage.code valid, scale_values]

theorem Storage.down_eq (storage : Storage codes scales) (valid : width=2 ∨ width=3 ∨ width=4) :
    storage.downProjection valid=CheckpointTrellis.down width valid codes scales := by
  unfold Storage.downProjection CheckpointTrellisMemory.downProjection CheckpointTrellis.down
  rw [down_words storage.code valid, scale_values]

def Storage.reframe (storage : Storage codes scales) (after : ByteMemory.Bytes)
    (codeSame : ∀ offset < 4*(17408*20*(8*width)), after (storage.code.base+offset)=storage.code.bytes (storage.code.base+offset))
    (scaleSame : ∀ offset < 34816, after (storage.scale.base+offset)=storage.code.bytes (storage.scale.base+offset)) : Storage codes scales where
  code := storage.code.reframe after codeSame
  scale := storage.scale.reframe after (by
    intro offset bound
    exact (scaleSame offset bound).trans (congrFun storage.shared _).symm)
  shared := rfl
  codeAligned := storage.codeAligned
  scaleAligned := storage.scaleAligned

def Storage.after16 (storage : Storage codes scales) {base size : Nat} (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores)
    (codeSeparate : MemoryRegions.Disjoint base size storage.code.base (4*(17408*20*(8*width))))
    (scaleSeparate : MemoryRegions.Disjoint base size storage.scale.base 34816) : Storage codes scales :=
  storage.reframe (HalfMemory.execute stores storage.code.bytes)
    (MemoryRegions.execute16_other stores _ inside codeSeparate) (MemoryRegions.execute16_other stores _ inside scaleSeparate)

def Storage.after32 (storage : Storage codes scales) {base size : Nat} (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores)
    (codeSeparate : MemoryRegions.Disjoint base size storage.code.base (4*(17408*20*(8*width))))
    (scaleSeparate : MemoryRegions.Disjoint base size storage.scale.base 34816) : Storage codes scales :=
  storage.reframe (ByteMemory.execute stores storage.code.bytes)
    (MemoryRegions.execute32_other stores _ inside codeSeparate) (MemoryRegions.execute32_other stores _ inside scaleSeparate)

theorem Storage.gate_run_word (storage : Storage codes scales) (valid : width=2 ∨ width=3 ∨ width=4)
    (row run index : Nat) (hr : row<17408) (hRun : run<160) (hi : index ≤ width) :
    ByteMemory.load32 storage.code.bytes (storage.code.base+4*CheckpointTrellisMemory.gateIndex row run width index)=
      GateUpCodebook.runWords (CheckpointTrellis.gateWords width valid codes row (run/8)) run width index := by
  rw [ArrayFrame.word_congr (TensorMemory.place codes storage.code.base storage.code.bytes) storage.code.bytes
    storage.code.base (4*(17408*20*(8*width))) _ storage.code.placed_region
    (by have := (CheckpointTrellisMemory.gate_offset_bounds row run width index valid hr hRun hi).1; omega)]
  exact CheckpointTrellisMemory.gate_run_word width valid codes storage.code.base storage.code.bytes row run index hr hRun hi

theorem Storage.down_source_word (storage : Storage codes scales) (valid : width=2 ∨ width=3 ∨ width=4)
    (row block word : Nat) (hr : row<17408) (hb : block<20) (hw : word<8*width) :
    ByteMemory.load32 storage.code.bytes (storage.code.base+4*CheckpointTrellisMemory.downIndex row block word width)=
      CheckpointTrellis.downWords width valid codes row block word := by
  rw [ArrayFrame.word_congr (TensorMemory.place codes storage.code.base storage.code.bytes) storage.code.bytes
    storage.code.base (4*(17408*20*(8*width))) _ storage.code.placed_region
    (by have := CheckpointTrellisMemory.down_offset_bound row block word width valid hr hb hw; omega)]
  exact CheckpointTrellisMemory.down_source_word width valid codes storage.code.base storage.code.bytes row block word hr hb hw

theorem Storage.scale_load (storage : Storage codes scales) (row : Fin 17408) :
    Float16.widen (Model.ofBits (HalfMemory.load storage.code.bytes (storage.scale.base+2*row.val)))=
      CheckpointTrellis.scale scales row.val := by
  rw [← storage.shared, storage.scale.load16 row, CheckpointTrellis.scale_exact]
  rfl

end Inference.Models.Qwen.CheckpointTrellisStorage
