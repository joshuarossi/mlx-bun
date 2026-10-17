import kernels.attention.MlxSdpaMergeSource

namespace Inference.Kernels.Attention.MlxSdpaOutputSource
open Contracts.Mlx State MlxSdpaMergeSyntax
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF}
  {cache : Kv.Cache Kv.BF steps} {input : SdpaMemory.Input query cache}
  {p : SdpaVector.Platform} {architecture : Char}

abbrev HeadKernels (p : SdpaVector.Platform) (query : Fin 24 → Fin 256 → ArrayStorage.BF) (cache : Kv.Cache Kv.BF steps) := SdpaOnePassDonation.HeadExecutions p query cache

def entry (summary : Summary) (transpose : Transpose) (base : Nat) (kernels : HeadKernels p query cache)
    (label : SdpaOutput.Label) (offset : Fin 8) : HalfMemory.Store :=
  ⟨base/2+MlxSdpaVectorMemory.outputAddress label.1 label.2.1 offset,
   MlxSdpaMergeSource.outputBits summary transpose (kernels label.1) offset label.2.1⟩

def thread (_ : Gate) (summary : Summary) (transpose : Transpose) (base : Nat) (kernels : HeadKernels p query cache)
    (label : SdpaOutput.Label) : List HalfMemory.Store :=
  if label.2.2.val=0 then List.ofFn (entry summary transpose base kernels label) else []

def programs (gate : Gate) (summary : Summary) (transpose : Transpose) (base : Nat) (kernels : HeadKernels p query cache) : List (List HalfMemory.Store) :=
  (SdpaTwoPassWrites.labels 32).map (thread gate summary transpose base kernels)

def source (base : Nat) (kernels : HeadKernels p query cache) : Option (List (List HalfMemory.Store)) := do
  let summary ←parseSummary sourceSummary
  let transpose ←parseTranspose sourceTranspose
  let gate ←parseGate sourceGate
  let cell ←MlxSdpaVectorSyntax.parseOutput MlxSdpaVectorSyntax.sourceOutput
  if cell=.output "i" then some (programs gate summary transpose base kernels) else none

theorem entry_bounds (kernels : HeadKernels p query cache) (base : Nat) (aligned : base%2=0)
    (bounded : base+12288≤2^64) (label : SdpaOutput.Label) (offset : Fin 8) :
    base≤2*(entry .shared .shared base kernels label offset).word ∧
    2*(entry .shared .shared base kernels label offset).word+2≤base+12288 ∧
    2*(entry .shared .shared base kernels label offset).word+2≤2^64 := by
  have inside := SdpaAddresses.output_in_bounds label.1 label.2.1 offset
  rw [←MlxSdpaVectorMemory.output_address] at inside
  dsimp only [entry]
  omega

theorem entry_eq (kernels : HeadKernels p query cache)
    (finite : ∀ head, SdpaVector.Finite p (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)))
    (base : Nat) (label : SdpaOutput.Label) (offset : Fin 8) :
    entry .shared .shared base kernels label offset=
      SdpaOutput.entry base (SdpaOnePassDonation.produced kernels) label offset := by
  unfold entry SdpaOutput.entry SdpaOutput.address
  rw [MlxSdpaVectorMemory.output_address,SdpaAddresses.output_address,
    MlxSdpaMergeSource.output_bits (kernels label.1) (finite label.1)]
  rfl

theorem source_programs (kernels : HeadKernels p query cache)
    (finite : ∀ head, SdpaVector.Finite p (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head)))
    (base : Nat) : source base kernels=some (SdpaOutput.programs base (SdpaOnePassDonation.produced kernels)) := by
  unfold source
  rw [parsed_summary,parsed_transpose,parsed_gate,MlxSdpaVectorSyntax.parsed_output]
  change some (programs .laneZero .shared .shared base kernels)=_
  apply congrArg some
  unfold programs SdpaOutput.programs
  apply congrArg (List.map · (SdpaTwoPassWrites.labels 32))
  funext label
  unfold thread SdpaOutput.thread
  split
  · apply congrArg List.ofFn
    funext offset
    exact entry_eq kernels finite base label offset
  · rfl

-- Every existing output store is now an instruction of the parsed BF16
-- source program, using the actual summary bytes and transposed registers.
theorem checked (execution : SdpaOnePassDonation.Execution input p architecture)
    (finite : ∀ head, SdpaVector.Finite p (query head) (cache.keys (SdpaScore.kvHead head)) (cache.values (SdpaScore.kvHead head))) :
    ∃ nativePrograms, source execution.stores.base execution.kernels=some nativePrograms ∧
      ThreadgroupWrites.Executes nativePrograms execution.stores.schedule execution.stores.remaining ∧
      ThreadgroupWrites.AtBarrier execution.stores.remaining ∧
      HalfMemory.execute execution.stores.schedule input.cache.memory=execution.stores.memory ∧
      execution.queries.after.memory=execution.stores.memory := by
  refine ⟨_,source_programs execution.kernels finite execution.stores.base,execution.stores.execution,execution.stores.completed,?_⟩
  constructor
  · rw [←execution.initial,←execution.outputInitial]
    rfl
  · rw [execution.queries.memory,execution.storeSchedule,←execution.outputInitial]
    rfl

-- The summaries/scratch values consumed above have actual parsed source
-- executions. These existence witnesses carry no expected intermediate values.
theorem partials_constructed (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (group lane : Fin 32) (offset : Fin 8) :
    ∃ finish, MlxSdpaPartialSource.Executes execution head group lane offset
      (List.finRange (SdpaLayout.count steps group)) (MlxSdpaPartialSource.initial .empty) finish ∧
      finish=SdpaVector.partials p (query head) (cache.keys (SdpaScore.kvHead head))
        (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane offset) group :=
  MlxSdpaPartialSource.complete_exists execution head group lane offset

theorem summary_provenance (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (group : Fin 32) :
    ∃ finish, MlxSdpaPartialSource.Executes execution head group 0 0
      (List.finRange (SdpaLayout.count steps group)) (MlxSdpaPartialSource.initial .empty) finish ∧
      (execution.kernels head).summaries.read true group=finish.shift ∧
      (execution.kernels head).summaries.read false group=finish.denominator := by
  obtain ⟨finish,run,same⟩ := MlxSdpaPartialSource.complete_exists execution head group 0 0
  refine ⟨finish,run,?_⟩
  rw [same]
  constructor <;> rw [SdpaSummaryBytes.Trace.read_correct] <;> rfl

theorem transpose_provenance (execution : SdpaOnePassDonation.Execution input p architecture)
    (head : Fin 24) (readerGroup readerLane : Fin 32) (offset : Fin 8) :
    ∃ finish, MlxSdpaPartialSource.Executes execution head readerLane readerGroup offset
      (List.finRange (SdpaLayout.count steps readerLane)) (MlxSdpaPartialSource.initial .empty) finish ∧
      ((execution.kernels head).scratch offset).register readerGroup readerLane=finish.numerator := by
  obtain ⟨finish,run,same⟩ := MlxSdpaPartialSource.complete_exists execution head readerLane readerGroup offset
  refine ⟨finish,run,?_⟩
  rw [same,SdpaTransposeBytes.Trace.register_correct]
  unfold SdpaOnePassScratch.numeratorLanes
  rfl

end Inference.Kernels.Attention.MlxSdpaOutputSource
