import models.qwen.DeltaPreparationAllocation

namespace Inference.Models.Qwen.DeltaTailAllocation
open Contracts.Mlx Layers Kernels Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

-- State 0, recurrent output 3145728, gated normalization 3158016,
-- output affine 3170304. All sizes are bytes.
structure Arena where
  base : Nat
  aligned : base%4=0
  bounded : base+3180544 ≤ 2^64

theorem Arena.separate (arena : Arena) {offset length base size : Nat} (inside : offset+length≤3180544)
    (safe : MemoryRegions.Disjoint arena.base 3180544 base size) :
    MemoryRegions.Disjoint (arena.base+offset) length base size := by
  unfold MemoryRegions.Disjoint at *
  omega

theorem Arena.recurrenceSeparate (arena : Arena) {base size : Nat}
    (safe : MemoryRegions.Disjoint arena.base 3180544 base size) :
    MemoryRegions.Disjoint arena.base 3145728 base size ∧
      MemoryRegions.Disjoint (arena.base+3145728) 12288 base size :=
  ⟨arena.separate (offset := 0) (length := 3145728) (by decide) safe,
    arena.separate (offset := 3145728) (length := 12288) (by decide) safe⟩

theorem input_mono (input : GatedShared.Input initial values) {first second : Nat → Nat → Prop}
    (implies : ∀ base size, first base size → second base size) (safe : input.Protected first) : input.Protected second :=
  ⟨implies _ _ safe.1,implies _ _ safe.2.1,implies _ _ safe.2.2.1,
    implies _ _ safe.2.2.2.1,implies _ _ safe.2.2.2.2.1,implies _ _ safe.2.2.2.2.2⟩

def Arena.recurrenceAllocation (arena : Arena) (input : GatedShared.Input initial values)
    (safe : input.Protected (MemoryRegions.Disjoint arena.base 3180544)) :
    DeltaTailConstruction.RecurrenceAllocation input where
  stateBase := arena.base
  outputBase := arena.base+3145728
  stateAligned := arena.aligned
  outputAligned := by have := arena.aligned; omega
  stateBounded := by have := arena.bounded; omega
  outputBounded := by have := arena.bounded; omega
  separate := by unfold MemoryRegions.Disjoint; omega
  safe := input_mono input (fun _ _ h => arena.recurrenceSeparate h) safe

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}

structure Fresh (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (preparation : ResidualDeltaStorageConstruction.PreparationPlan source)
    (frames : ResidualDeltaStorageConstruction.PreparationFrames source preparation) (arena : Arena) : Prop where
  inputSafe : (ResidualDeltaStorageConstruction.recurrenceInput source preparation frames).Protected
    (MemoryRegions.Disjoint arena.base 3180544)
  gate : MemoryRegions.Disjoint arena.base 3180544 source.entry.affine.gateBuffer.base 12288
  parameters : DeltaParameterMemory.Protected source.parameters (MemoryRegions.Disjoint arena.base 3180544)
  suffix : source.suffix.Protected (MemoryRegions.Disjoint arena.base 3180544)
  residual : MemoryRegions.Disjoint arena.base 3180544 source.entry.savedResidual.base 10240
  history : MemoryRegions.Disjoint arena.base 3180544 (ResidualDeltaStorageConstruction.historyBefore source preparation frames).base 61440

variable (source : ResidualDeltaStorageConstruction.Source layer cache input)
  (preparation : ResidualDeltaStorageConstruction.PreparationPlan source)
  (frames : ResidualDeltaStorageConstruction.PreparationFrames source preparation)
  (arena : Arena) (fresh : Fresh source preparation frames arena)

include fresh in
theorem parameters_safe : DeltaParameterMemory.Protected source.parametersAfterEntry (MemoryRegions.Disjoint arena.base 3180544) :=
  (DeltaPreparationAllocation.parameters_regions source _).mpr fresh.parameters

def recurrencePlan : ResidualDeltaStorageConstruction.RecurrencePlan source preparation frames where
  allocation := arena.recurrenceAllocation (ResidualDeltaStorageConstruction.recurrenceInput source preparation frames) fresh.inputSafe
  stateGate := (arena.recurrenceSeparate fresh.gate).1
  outputGate := (arena.recurrenceSeparate fresh.gate).2
  stateNorm := (arena.recurrenceSeparate (parameters_safe source preparation frames arena fresh).2.2.2.2.2.1).1
  outputNorm := (arena.recurrenceSeparate (parameters_safe source preparation frames arena fresh).2.2.2.2.2.1).2

include fresh in
theorem projection_safe : AffineMemoryFrames.Protected layer.mixer.out
    (ResidualDeltaStorageConstruction.projectionWeights source preparation frames) (MemoryRegions.Disjoint arena.base 3180544) :=
  (ResidualDeltaStorageConstruction.projection_original_regions source preparation frames _).mpr fresh.parameters.2.2.2.2.2.2

def allocation : DeltaTailConstruction.Allocation
    (ResidualDeltaStorageConstruction.tailInput source preparation frames (recurrencePlan source preparation frames arena fresh))
    (ResidualDeltaStorageConstruction.projectionWeights source preparation frames) where
  normalizationBase := arena.base+3158016
  projectionBase := arena.base+3170304
  normalizationAligned := by have := arena.aligned; omega
  projectionAligned := by have := arena.aligned; omega
  normalizationBounded := by have := arena.bounded; omega
  projectionBounded := by have := arena.bounded; omega
  normalizationInput := by change MemoryRegions.Disjoint (arena.base+3158016) 12288 (arena.base+3145728) 12288; unfold MemoryRegions.Disjoint; omega
  normalizationGate := by
    rw [(ResidualDeltaStorageConstruction.tailInput_bases source preparation frames (recurrencePlan source preparation frames arena fresh)).1]
    exact arena.separate (offset := 3158016) (length := 12288) (by decide) fresh.gate
  normalizationWeight := by
    rw [(ResidualDeltaStorageConstruction.tailInput_bases source preparation frames (recurrencePlan source preparation frames arena fresh)).2]
    exact arena.separate (offset := 3158016) (length := 12288) (by decide) (parameters_safe source preparation frames arena fresh).2.2.2.2.2.1
  normalizationState := by change MemoryRegions.Disjoint (arena.base+3158016) 12288 arena.base 3145728; unfold MemoryRegions.Disjoint; omega
  projectionInput := by unfold MemoryRegions.Disjoint; omega
  projectionState := by change MemoryRegions.Disjoint (arena.base+3170304) 10240 arena.base 3145728; unfold MemoryRegions.Disjoint; omega
  weightsProtected := AffineMemoryFrames.protected_mono _ _ (fun _ _ h =>
    ⟨(arena.recurrenceSeparate h).1,(arena.recurrenceSeparate h).2,
      arena.separate (offset := 3158016) (length := 12288) (by decide) h,
      arena.separate (offset := 3170304) (length := 10240) (by decide) h⟩)
    (projection_safe source preparation frames arena fresh)


theorem fromRecurrence_bases {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
    {initial : GatedDevice.State} {values : GatedInputs.Values} {recurrence : GatedShared.Execution reduce flags initial values}
    {gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → ArrayStorage.BF}
    {projection : AffineVerifyLinear.Projection 12 5120}
    (input : DeltaTailMemory.Input recurrence gate weights) (p : GatedRmsNorm.Platform) (width eps : Float32)
    (w : AffineDevice.Storage projection) (shared : AffineMemory.Shared projection w recurrence.input.state.bytes)
    (a : DeltaTailConstruction.Allocation input w) :
    (DeltaTailConstruction.fromRecurrence input p width eps w shared a).normalization.base=a.normalizationBase ∧
      (DeltaTailConstruction.fromRecurrence input p width eps w shared a).affine.base=a.projectionBase := by
  cases projection <;> exact ⟨rfl,rfl⟩

def execution := ResidualDeltaStorageConstruction.tailExecution source preparation frames
  (recurrencePlan source preparation frames arena fresh) (allocation source preparation frames arena fresh)

include fresh in
theorem bases : (execution source preparation frames arena fresh).normalization.base=arena.base+3158016 ∧
    (execution source preparation frames arena fresh).affine.base=arena.base+3170304 :=
  fromRecurrence_bases _ _ _ _ _
    (ResidualDeltaStorageConstruction.projectionSharedAtRecurrence source preparation frames (recurrencePlan source preparation frames arena fresh)) _

theorem safe {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 3180544 base size) :
    DeltaTailMemory.Safe (execution source preparation frames arena fresh) base size := by
  change MemoryRegions.Disjoint arena.base 3145728 base size ∧
    MemoryRegions.Disjoint (arena.base+3145728) 12288 base size ∧
    MemoryRegions.Disjoint (execution source preparation frames arena fresh).normalization.base 12288 base size ∧
    MemoryRegions.Disjoint (execution source preparation frames arena fresh).affine.base 10240 base size
  rw [(bases source preparation frames arena fresh).1,(bases source preparation frames arena fresh).2]
  exact ⟨(arena.recurrenceSeparate separate).1,(arena.recurrenceSeparate separate).2,
    arena.separate (offset := 3158016) (length := 12288) (by decide) separate,
    arena.separate (offset := 3170304) (length := 10240) (by decide) separate⟩

def tailPlan : ResidualDeltaStorageConstruction.TailPlan source preparation frames (recurrencePlan source preparation frames arena fresh) where
  allocation := allocation source preparation frames arena fresh
  residualSafe := safe source preparation frames arena fresh fresh.residual
  historySafe := safe source preparation frames arena fresh fresh.history
  historyState := MemoryRegions.disjoint_symm (arena.recurrenceSeparate fresh.history).1
  suffixSafe := DecodeParameterMemory.suffix_mono _ (fun _ _ h => safe source preparation frames arena fresh h)
    ((ResidualDeltaStorageConstruction.suffix_original_regions source preparation frames _).mpr fresh.suffix)

theorem other_region {base size : Nat} (separate : MemoryRegions.Disjoint arena.base 3180544 base size)
    (offset : Nat) (bound : offset<size) :
    (execution source preparation frames arena fresh).buffer.bytes (base+offset)=
      (ResidualDeltaStorageConstruction.preparation source preparation).prepared.gates.betaBuffer.bytes (base+offset) :=
  ((execution source preparation frames arena fresh).other_region (safe source preparation frames arena fresh separate) offset bound).trans
    (congrFun (ResidualDeltaStorageConstruction.recurrent_memory source preparation frames (recurrencePlan source preparation frames arena fresh)) _)



attribute [local irreducible] ResidualDeltaConstruction.preparation ResidualDeltaStorageConstruction.preparation

theorem history_shared_generic (recurrent : ResidualDeltaStorageConstruction.RecurrencePlan source preparation frames) :
    (ResidualDeltaStorageConstruction.historyBefore source preparation frames).bytes=
    (ResidualDeltaStorageConstruction.recurrent source preparation frames recurrent).input.state.bytes :=
  (show (ResidualDeltaStorageConstruction.historyBefore source preparation frames).bytes=
    (ResidualDeltaStorageConstruction.preparation source preparation).prepared.gates.betaBuffer.bytes from rfl).trans
    (ResidualDeltaStorageConstruction.recurrent_memory source preparation frames recurrent).symm


def cacheFromTail (recurrent : ResidualDeltaStorageConstruction.RecurrencePlan source preparation frames)
    (tail : ResidualDeltaStorageConstruction.TailPlan source preparation frames recurrent) :=
  (ResidualDeltaStorageConstruction.tailExecution source preparation frames recurrent tail.allocation).afterCache
    (ResidualDeltaStorageConstruction.historyBefore source preparation frames)
    (history_shared_generic source preparation frames recurrent) tail.historySafe tail.historyState


def afterCache := cacheFromTail source preparation frames
  (recurrencePlan source preparation frames arena fresh) (tailPlan source preparation frames arena fresh)


include fresh in
theorem afterCache_shared : (afterCache source preparation frames arena fresh).memory=
    (execution source preparation frames arena fresh).buffer.bytes := rfl

include fresh in
theorem layout :
    (ResidualDeltaStorageConstruction.recurrent source preparation frames (recurrencePlan source preparation frames arena fresh)).stores.trace.stateBase=arena.base ∧
    (ResidualDeltaStorageConstruction.recurrent source preparation frames (recurrencePlan source preparation frames arena fresh)).stores.trace.outputBase=arena.base+3145728 ∧
    (execution source preparation frames arena fresh).normalization.base=arena.base+3158016 ∧
    (execution source preparation frames arena fresh).affine.base=arena.base+3170304 :=
  ⟨rfl,rfl,(bases source preparation frames arena fresh).1,(bases source preparation frames arena fresh).2⟩



theorem recurrenceInput_regions (property : Nat → Nat → Prop) :
    (ResidualDeltaStorageConstruction.recurrenceInput source preparation frames).Protected property ↔
    property source.cacheStorage.buffers.recurrent.base 3145728 ∧
    property (ResidualDeltaStorageConstruction.preparation source preparation).heads.keyBuffer.base 4096 ∧
    property (ResidualDeltaStorageConstruction.preparation source preparation).heads.queryBuffer.base 4096 ∧
    property (ResidualDeltaStorageConstruction.preparation source preparation).heads.valueBuffer.base 12288 ∧
    property (ResidualDeltaStorageConstruction.preparation source preparation).prepared.decay.base 192 ∧
    property (2*(ResidualDeltaStorageConstruction.preparation source preparation).prepared.gates.beta.base) 96 := Iff.rfl



-- A disjoint preparation arena supplies all five recurrent operands at once.
theorem prepared_input_fresh (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (previous : DeltaPreparationAllocation.Arena) (previousFresh : DeltaPreparationAllocation.Fresh source previous)
    (arena : Arena) (separate : MemoryRegions.Disjoint arena.base 3180544 previous.base 184608)
    (state : MemoryRegions.Disjoint arena.base 3180544 source.cacheStorage.buffers.recurrent.base 3145728) :
    (ResidualDeltaStorageConstruction.recurrenceInput source (DeltaPreparationAllocation.plan source previous previousFresh)
      (DeltaPreparationAllocation.frames source previous previousFresh)).Protected (MemoryRegions.Disjoint arena.base 3180544) := by
  apply (recurrenceInput_regions source (DeltaPreparationAllocation.plan source previous previousFresh)
    (DeltaPreparationAllocation.frames source previous previousFresh) _).mpr
  have layout := DeltaPreparationAllocation.layout source previous previousFresh
  unfold DeltaPreparationAllocation.execution at layout
  rw [layout.2.2.2.2.1,layout.2.2.2.1,layout.2.2.2.2.2.1,layout.2.2.2.2.2.2.1,layout.2.2.2.2.2.2.2]
  exact ⟨state,
    MemoryRegions.disjoint_symm (previous.separate (offset := 167936) (length := 4096) (by decide) (MemoryRegions.disjoint_symm separate)),
    MemoryRegions.disjoint_symm (previous.separate (offset := 163840) (length := 4096) (by decide) (MemoryRegions.disjoint_symm separate)),
    MemoryRegions.disjoint_symm (previous.separate (offset := 172032) (length := 12288) (by decide) (MemoryRegions.disjoint_symm separate)),
    MemoryRegions.disjoint_symm (previous.separate (offset := 184320) (length := 192) (by decide) (MemoryRegions.disjoint_symm separate)),
    MemoryRegions.disjoint_symm (previous.separate (offset := 184512) (length := 96) (by decide) (MemoryRegions.disjoint_symm separate))⟩

theorem fromPreparationArena (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (previous : DeltaPreparationAllocation.Arena) (previousFresh : DeltaPreparationAllocation.Fresh source previous)
    (arena : Arena) (separate : MemoryRegions.Disjoint arena.base 3180544 previous.base 184608)
    (state : MemoryRegions.Disjoint arena.base 3180544 source.cacheStorage.buffers.recurrent.base 3145728)
    (gate : MemoryRegions.Disjoint arena.base 3180544 source.entry.affine.gateBuffer.base 12288)
    (parameters : DeltaParameterMemory.Protected source.parameters (MemoryRegions.Disjoint arena.base 3180544))
    (suffix : source.suffix.Protected (MemoryRegions.Disjoint arena.base 3180544))
    (residual : MemoryRegions.Disjoint arena.base 3180544 source.entry.savedResidual.base 10240) :
    Fresh source (DeltaPreparationAllocation.plan source previous previousFresh)
      (DeltaPreparationAllocation.frames source previous previousFresh) arena where
  inputSafe := prepared_input_fresh source previous previousFresh arena separate state
  gate := gate
  parameters := parameters
  suffix := suffix
  residual := residual
  history := by
    change MemoryRegions.Disjoint arena.base 3180544 (2*((previous.base+81920)/2)) 61440
    rw [previous.half (offset := 81920) (by decide)]
    exact MemoryRegions.disjoint_symm (previous.separate (offset := 81920) (length := 61440) (by decide) (MemoryRegions.disjoint_symm separate))

end Inference.Models.Qwen.DeltaTailAllocation
