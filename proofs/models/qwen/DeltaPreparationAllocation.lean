import models.qwen.DeltaEntryAllocation

namespace Inference.Models.Qwen.DeltaPreparationAllocation
open Contracts.Mlx Layers Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

-- Byte offsets: join 0, history 81920, convolution 143360, Q 163840, K 167936,
-- V 172032, decay 184320, beta 184512. The arena ends at 184608.
structure Arena where
  base : Nat
  aligned : base%4=0
  bounded : base+184608 ≤ 2^64

theorem Arena.half (arena : Arena) {offset : Nat} (even : offset%2=0) :
    2*((arena.base+offset)/2)=arena.base+offset := by have := arena.aligned; omega

theorem Arena.separate (arena : Arena) {offset length base size : Nat} (inside : offset+length≤184608)
    (safe : MemoryRegions.Disjoint arena.base 184608 base size) :
    MemoryRegions.Disjoint (arena.base+offset) length base size := by
  unfold MemoryRegions.Disjoint at *
  omega

def Arena.geometry (arena : Arena) : DeltaHeadsMemory.Geometry where
  base i := if i.val=0 then arena.base+163840 else if i.val=1 then arena.base+167936 else arena.base+172032
  aligned := by intro i; fin_cases i <;> dsimp <;> have := arena.aligned <;> omega
  bounded := by intro i; fin_cases i <;> dsimp [DeltaHeadsMemory.size,DeltaHeadsMemory.blocks] <;> have := arena.bounded <;> omega
  separate := by
    intro i j different
    fin_cases i <;> fin_cases j <;> simp_all [DeltaHeadsMemory.size,DeltaHeadsMemory.blocks,MemoryRegions.Disjoint]

theorem Arena.headSeparate (arena : Arena) {base size : Nat} (safe : MemoryRegions.Disjoint arena.base 184608 base size) :
    ∀ i, MemoryRegions.Disjoint (arena.geometry.base i) (DeltaHeadsMemory.size i) base size := by
  intro i
  fin_cases i <;> exact arena.separate (by decide) safe

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}

structure Fresh (source : ResidualDeltaStorageConstruction.Source layer cache input) (arena : Arena) : Prop where
  history : MemoryRegions.Disjoint arena.base 184608 source.cacheStorage.buffers.history.base 61440
  state : MemoryRegions.Disjoint arena.base 184608 source.cacheStorage.buffers.recurrent.base 3145728
  qkv : MemoryRegions.Disjoint arena.base 184608 source.entry.affine.qkvBuffer.base 20480
  a : MemoryRegions.Disjoint arena.base 184608 source.entry.affine.aBuffer.base 96
  b : MemoryRegions.Disjoint arena.base 184608 source.entry.affine.bBuffer.base 96
  z : MemoryRegions.Disjoint arena.base 184608 source.entry.affine.gateBuffer.base 12288
  residual : MemoryRegions.Disjoint arena.base 184608 source.entry.savedResidual.base 10240
  parameters : DeltaParameterMemory.Protected source.parameters (MemoryRegions.Disjoint arena.base 184608)
  suffix : source.suffix.Protected (MemoryRegions.Disjoint arena.base 184608)

theorem parameters_regions (source : ResidualDeltaStorageConstruction.Source layer cache input) (property : Nat → Nat → Prop) :
    DeltaParameterMemory.Protected source.parametersAfterEntry property ↔ DeltaParameterMemory.Protected source.parameters property :=
  DecodeParameterMemory.delta_mixer_regions source.parameters source.entry.affine.memory
    (DeltaParameterMemory.protected_mono source.parameters (fun _ _ h => source.entry.other_region h) source.entryFrames.parameterSafe) property

theorem suffix_regions (source : ResidualDeltaStorageConstruction.Source layer cache input) (property : Nat → Nat → Prop) :
    source.suffixAfterEntry.Protected property ↔ source.suffix.Protected property := Iff.rfl

variable (source : ResidualDeltaStorageConstruction.Source layer cache input) (arena : Arena) (fresh : Fresh source arena)

include fresh in
theorem parameters_safe : DeltaParameterMemory.Protected source.parametersAfterEntry (MemoryRegions.Disjoint arena.base 184608) :=
  (parameters_regions source _).mpr fresh.parameters

def convolution : DeltaPreparationConstruction.ConvolutionAllocation source.entry.affine source.cacheAfterEntry source.parametersAfterEntry where
  joinBase := arena.base/2
  tailBase := (arena.base+81920)/2
  outputBase := arena.base+143360
  joinBounded := by have h := arena.half (offset := 0) (by decide); have := arena.bounded; omega
  tailBounded := by have h := arena.half (offset := 81920) (by decide); have := arena.bounded; omega
  outputAligned := by have := arena.aligned; omega
  outputBounded := by have := arena.bounded; omega
  historySeparate := by
    change MemoryRegions.Disjoint (2*(arena.base/2)) 81920 source.cacheStorage.buffers.history.base 61440
    have h := arena.half (offset := 0) (by decide); simp only [Nat.add_zero] at h
    rw [h]; exact arena.separate (offset := 0) (length := 81920) (by decide) fresh.history
  sourceSeparate := by
    have h := arena.half (offset := 0) (by decide); simp only [Nat.add_zero] at h
    rw [h]; exact arena.separate (offset := 0) (length := 81920) (by decide) fresh.qkv
  tailSeparate := by
    have h := arena.half (offset := 0) (by decide); have t := arena.half (offset := 81920) (by decide)
    simp only [Nat.add_zero] at h
    rw [h,t]; unfold MemoryRegions.Disjoint; omega
  joinWeight := by
    have h := arena.half (offset := 0) (by decide); simp only [Nat.add_zero] at h
    rw [h]; exact arena.separate (offset := 0) (length := 81920) (by decide) (parameters_safe source arena fresh).1
  tailWeight := by
    rw [arena.half (offset := 81920) (by decide)]
    exact arena.separate (offset := 81920) (length := 61440) (by decide) (parameters_safe source arena fresh).1
  outputSource := by
    have h := arena.half (offset := 0) (by decide); simp only [Nat.add_zero] at h
    rw [h]; unfold MemoryRegions.Disjoint; omega
  outputWeight := arena.separate (offset := 143360) (length := 20480) (by decide) (parameters_safe source arena fresh).1
  outputHistory := by rw [arena.half (offset := 81920) (by decide)]; unfold MemoryRegions.Disjoint; omega

def convolved := DeltaPreparationConstruction.convolved source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl (convolution source arena fresh)

theorem convolution_safe {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 184608 base size) :
    ConvolutionMemory.Safe (convolved source arena fresh) base size := by
  change MemoryRegions.Disjoint (2*(arena.base/2)) 81920 base size ∧
    MemoryRegions.Disjoint (2*((arena.base+81920)/2)) 61440 base size ∧
    MemoryRegions.Disjoint (arena.base+143360) 20480 base size
  have h := arena.half (offset := 0) (by decide); simp only [Nat.add_zero] at h
  rw [h,arena.half (offset := 81920) (by decide)]
  exact ⟨arena.separate (offset := 0) (length := 81920) (by decide) separate,arena.separate (offset := 81920) (length := 61440) (by decide) separate,arena.separate (offset := 143360) (length := 20480) (by decide) separate⟩


include fresh in
theorem query_safe : ConvolutionMemory.Safe (convolved source arena fresh) source.parametersAfterEntry.queryScale.base 256 :=
  convolution_safe source arena fresh (parameters_safe source arena fresh).2.1

include fresh in
theorem key_safe : ConvolutionMemory.Safe (convolved source arena fresh) source.parametersAfterEntry.keyScale.base 256 :=
  convolution_safe source arena fresh (parameters_safe source arena fresh).2.2.1

include fresh in
theorem gate_safe : (DeltaParameterMemory.gateInput source.entry.affine source.parametersAfterEntry).Protected
    (fun base => ConvolutionMemory.Safe (convolved source arena fresh) base 96) :=
  ⟨convolution_safe source arena fresh (parameters_safe source arena fresh).2.2.2.1,
    convolution_safe source arena fresh fresh.a,
    convolution_safe source arena fresh (parameters_safe source arena fresh).2.2.2.2.1,
    convolution_safe source arena fresh fresh.b⟩

def scales := DeltaPreparationConstruction.scales source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl
  (convolution source arena fresh) (query_safe source arena fresh) (key_safe source arena fresh)

def gateSource := DeltaPreparationConstruction.gateSource source.entry.affine source.cacheAfterEntry source.parametersAfterEntry rfl
  (convolution source arena fresh) (gate_safe source arena fresh)


def Arena.headAllocationFor (arena : Arena) (source : DeltaHeadsMemory.Input projected qScale kScale)
    (inputBase : source.storage.input.base=arena.base+143360)
    (query : MemoryRegions.Disjoint arena.base 184608 source.storage.qScale.base 256)
    (key : MemoryRegions.Disjoint arena.base 184608 source.storage.kScale.base 256) :
    DeltaPreparationConstruction.HeadAllocation source where
  geometry := arena.geometry
  sourceSeparate := by
    intro i
    rw [inputBase]
    fin_cases i <;> simp [Arena.geometry,DeltaHeadsMemory.size,DeltaHeadsMemory.blocks,MemoryRegions.Disjoint]
  querySeparate := arena.headSeparate query
  keySeparate := arena.headSeparate key


theorem head_input_base : (scales source arena fresh).headInput.storage.input.base=arena.base+143360 := rfl

theorem head_query_base_generic {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
    {weights : Fin 10240 → Fin 4 → ArrayStorage.BF} {i : ConvolutionMemory.Input history next weights}
    {c : Bool} {e : ConvolutionMemory.Execution i c} {q k : Fin 128 → ArrayStorage.BF}
    (s : DeltaConvolutionMemory.Scales e q k) : s.headInput.storage.qScale.base=s.query.base := rfl

theorem head_key_base_generic {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
    {weights : Fin 10240 → Fin 4 → ArrayStorage.BF} {i : ConvolutionMemory.Input history next weights}
    {c : Bool} {e : ConvolutionMemory.Execution i c} {q k : Fin 128 → ArrayStorage.BF}
    (s : DeltaConvolutionMemory.Scales e q k) : s.headInput.storage.kScale.base=s.key.base := rfl

theorem scales_query_base : (scales source arena fresh).query.base=source.parametersAfterEntry.queryScale.base := rfl
theorem scales_key_base : (scales source arena fresh).key.base=source.parametersAfterEntry.keyScale.base := rfl

theorem head_query_safe : MemoryRegions.Disjoint arena.base 184608 (scales source arena fresh).headInput.storage.qScale.base 256 :=
  Eq.mpr (congrArg (fun base => MemoryRegions.Disjoint arena.base 184608 base 256)
    ((head_query_base_generic (scales source arena fresh)).trans (scales_query_base source arena fresh)))
    (parameters_safe source arena fresh).2.1

theorem head_key_safe : MemoryRegions.Disjoint arena.base 184608 (scales source arena fresh).headInput.storage.kScale.base 256 :=
  Eq.mpr (congrArg (fun base => MemoryRegions.Disjoint arena.base 184608 base 256)
    ((head_key_base_generic (scales source arena fresh)).trans (scales_key_base source arena fresh)))
    (parameters_safe source arena fresh).2.2.1

def headAllocation : DeltaPreparationConstruction.HeadAllocation (scales source arena fresh).headInput :=
  @Arena.headAllocationFor (convolved source arena fresh).output layer.mixer.headParams.qScale layer.mixer.headParams.kScale
    arena (scales source arena fresh).headInput (head_input_base source arena fresh)
    (head_query_safe source arena fresh) (head_key_safe source arena fresh)


def heads := DeltaPreparationConstruction.heads (scales source arena fresh).headInput layer.mixer.recurrence.heads
  layer.mixer.headParams.width layer.mixer.headParams.eps (headAllocation source arena fresh)


theorem convolution_gate_regions {history : State.ConvolutionStorage.History} {next : Fin 10240 → ArrayStorage.BF}
    {weights : Fin 10240 → Fin 4 → ArrayStorage.BF} {i : ConvolutionMemory.Input history next weights}
    {c : Bool} (e : ConvolutionMemory.Execution i c) (g : GateMemory.Input aLog a dtBias b)
    (shared : g.storage.logarithm.bytes=i.window.joined.old.bytes)
    (safe : g.Protected (fun base => ConvolutionMemory.Safe e base 96)) (property : Nat → Prop) :
    (DeltaConvolutionMemory.gatesAfterConvolution e g shared safe).Protected property ↔ g.Protected property := Iff.rfl

include fresh in
theorem gate_regions : (gateSource source arena fresh).Protected (fun base => MemoryRegions.Disjoint arena.base 184608 base 96) := by
  apply (convolution_gate_regions (convolved source arena fresh)
    (DeltaParameterMemory.gateInput source.entry.affine source.parametersAfterEntry)
    source.parametersAfterEntry.logarithmShared (gate_safe source arena fresh) _).mpr
  exact ⟨(parameters_safe source arena fresh).2.2.2.1,fresh.a,(parameters_safe source arena fresh).2.2.2.2.1,fresh.b⟩


def gateAllocation : DeltaPreparationConstruction.GateAllocation (heads source arena fresh) (gateSource source arena fresh) where
  headSafe := ⟨arena.headSeparate (gate_regions source arena fresh).1,
    arena.headSeparate (gate_regions source arena fresh).2.1,
    arena.headSeparate (gate_regions source arena fresh).2.2.1,
    arena.headSeparate (gate_regions source arena fresh).2.2.2⟩
  decayBase := arena.base+184320
  betaBase := (arena.base+184512)/2
  decayAligned := by have := arena.aligned; omega
  decayBounded := by have := arena.bounded; omega
  betaBounded := by rw [arena.half (offset := 184512) (by decide)]; have := arena.bounded; omega
  decaySafe := ⟨arena.separate (offset := 184320) (length := 192) (by decide) (gate_regions source arena fresh).1,
    arena.separate (offset := 184320) (length := 192) (by decide) (gate_regions source arena fresh).2.1,
    arena.separate (offset := 184320) (length := 192) (by decide) (gate_regions source arena fresh).2.2.1,
    arena.separate (offset := 184320) (length := 192) (by decide) (gate_regions source arena fresh).2.2.2⟩
  betaSource := Or.inr (by
    rw [arena.half (offset := 184512) (by decide)]
    exact MemoryRegions.disjoint_symm (arena.separate (offset := 184512) (length := 96) (by decide) (gate_regions source arena fresh).2.2.2))
  betaDecay := by rw [arena.half (offset := 184512) (by decide)]; unfold MemoryRegions.Disjoint; omega
  querySafe := by
    change MemoryRegions.Disjoint (arena.base+184320) 192 (arena.base+163840) 4096 ∧
      MemoryRegions.Disjoint (2*((arena.base+184512)/2)) 96 (arena.base+163840) 4096
    rw [arena.half (offset := 184512) (by decide)]; unfold MemoryRegions.Disjoint; omega
  keySafe := by
    change MemoryRegions.Disjoint (arena.base+184320) 192 (arena.base+167936) 4096 ∧
      MemoryRegions.Disjoint (2*((arena.base+184512)/2)) 96 (arena.base+167936) 4096
    rw [arena.half (offset := 184512) (by decide)]; unfold MemoryRegions.Disjoint; omega
  valueSafe := by
    change MemoryRegions.Disjoint (arena.base+184320) 192 (arena.base+172032) 12288 ∧
      MemoryRegions.Disjoint (2*((arena.base+184512)/2)) 96 (arena.base+172032) 12288
    rw [arena.half (offset := 184512) (by decide)]; unfold MemoryRegions.Disjoint; omega


def plan : ResidualDeltaStorageConstruction.PreparationPlan source where
  convolution := convolution source arena fresh
  prepared := ⟨query_safe source arena fresh,key_safe source arena fresh,gate_safe source arena fresh,
    headAllocation source arena fresh,gateAllocation source arena fresh⟩



def execution := ResidualDeltaStorageConstruction.preparation source (plan source arena fresh)

theorem prepared_safe {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 184608 base size) :
    DeltaPreparedMemory.Safe (execution source arena fresh).prepared base size := by
  change (∀ i, MemoryRegions.Disjoint (arena.geometry.base i) (DeltaHeadsMemory.size i) base size) ∧
    MemoryRegions.Disjoint (arena.base+184320) 192 base size ∧
    MemoryRegions.Disjoint (2*((arena.base+184512)/2)) 96 base size
  rw [arena.half (offset := 184512) (by decide)]
  exact ⟨arena.headSeparate separate,
    arena.separate (offset := 184320) (length := 192) (by decide) separate,
    arena.separate (offset := 184512) (length := 96) (by decide) separate⟩

theorem safe {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 184608 base size) :
    DeltaConvolutionMemory.Safe (execution source arena fresh) base size :=
  ⟨convolution_safe source arena fresh separate,prepared_safe source arena fresh separate⟩

include fresh in
theorem history_safe : DeltaPreparedMemory.Safe (execution source arena fresh).prepared
    (2*((plan source arena fresh).convolution.tailBase)) 61440 := by
  change (∀ i, MemoryRegions.Disjoint (arena.geometry.base i) (DeltaHeadsMemory.size i)
      (2*((arena.base+81920)/2)) 61440) ∧
    MemoryRegions.Disjoint (arena.base+184320) 192 (2*((arena.base+81920)/2)) 61440 ∧
    MemoryRegions.Disjoint (2*((arena.base+184512)/2)) 96 (2*((arena.base+81920)/2)) 61440
  rw [arena.half (offset := 81920) (by decide),arena.half (offset := 184512) (by decide)]
  refine ⟨?_,?_,?_⟩
  · intro i; fin_cases i <;> simp [Arena.geometry,DeltaHeadsMemory.size,DeltaHeadsMemory.blocks,MemoryRegions.Disjoint]
  · unfold MemoryRegions.Disjoint; omega
  · unfold MemoryRegions.Disjoint; omega

theorem frames : ResidualDeltaStorageConstruction.PreparationFrames source (plan source arena fresh) where
  historySafe := history_safe source arena fresh
  stateSafe := safe source arena fresh fresh.state
  residualSafe := safe source arena fresh fresh.residual
  gateSafe := safe source arena fresh fresh.z
  normSafe := safe source arena fresh (parameters_safe source arena fresh).2.2.2.2.2.1
  projectionSafe := AffineMemoryFrames.protected_mono _ _ (fun _ _ h => safe source arena fresh h)
    (parameters_safe source arena fresh).2.2.2.2.2.2
  suffixSafe := DecodeParameterMemory.suffix_mono _ (fun _ _ h => safe source arena fresh h)
    ((suffix_regions source _).mpr fresh.suffix)

theorem other_region {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 184608 base size)
    (offset : Nat) (bound : offset<size) :
    (execution source arena fresh).prepared.gates.betaBuffer.bytes (base+offset)=source.entry.affine.memory (base+offset) :=
  (execution source arena fresh).other_region (safe source arena fresh separate) offset bound


include fresh in
theorem layout :
    2*(plan source arena fresh).convolution.joinBase=arena.base ∧
    2*(plan source arena fresh).convolution.tailBase=arena.base+81920 ∧
    (plan source arena fresh).convolution.outputBase=arena.base+143360 ∧
    (execution source arena fresh).heads.queryBuffer.base=arena.base+163840 ∧
    (execution source arena fresh).heads.keyBuffer.base=arena.base+167936 ∧
    (execution source arena fresh).heads.valueBuffer.base=arena.base+172032 ∧
    (execution source arena fresh).prepared.decay.base=arena.base+184320 ∧
    2*(execution source arena fresh).prepared.gates.beta.base=arena.base+184512 := by
  refine ⟨?_,arena.half (offset := 81920) (by decide),rfl,rfl,rfl,rfl,rfl,arena.half (offset := 184512) (by decide)⟩
  change 2*(arena.base/2)=arena.base
  simpa only [Nat.add_zero] using arena.half (offset := 0) (by decide)

end Inference.Models.Qwen.DeltaPreparationAllocation
