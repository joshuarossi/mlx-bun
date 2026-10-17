import kernels.attention.MlxSdpaMergeSyntax
import contracts.mlx.DivisionBounds

namespace Inference.Kernels.Attention.MlxSdpaMergeSource
open Contracts.Mlx Contracts.Mlx.Numerics MlxSdpaMergeSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

-- Parsed lane-zero publishers and transpose writers produce Float32 stores,
-- preserving the existing two distinct summary regions and scratch strides.
def summaryThread (_ : Summary) (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32)
    (label : SdpaSummaryBytes.Label) : List Memory.Store :=
  if label.2.val=0 then [⟨maxBase/4+label.1.val,maxima label.1⟩,⟨sumBase/4+label.1.val,sums label.1⟩] else []

def summaryPrograms (ast : Summary) (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) : List (List Memory.Store) :=
  SdpaSummaryBytes.labels.map (summaryThread ast maxBase sumBase maxima sums)

theorem summary_programs (maxBase sumBase : Nat) (maxima sums : Fin 32 → Float32) :
    summaryPrograms .shared maxBase sumBase maxima sums=SdpaSummaryBytes.programs maxBase sumBase maxima sums := rfl

theorem summary_execution (trace : SdpaSummaryBytes.Trace maxima sums) :
    ThreadgroupWrites.Executes (summaryPrograms .shared trace.maxBase trace.sumBase maxima sums) trace.schedule trace.remaining ∧
    ThreadgroupWrites.AtBarrier trace.remaining := ⟨trace.execution,trace.barrier⟩

def transposeStore (_ : Transpose) (base : Nat) (values : SdpaTransposeBytes.Lanes)
    (label : SdpaTransposeBytes.Label) : Memory.Store :=
  ⟨base/4+label.2.val*32+label.1.val,values label.1 label.2⟩

theorem transpose_store (base : Nat) (values : SdpaTransposeBytes.Lanes) (label : SdpaTransposeBytes.Label) :
    transposeStore .shared base values label=SdpaTransposeBytes.entry base values label := rfl

def transposePrograms (ast : Transpose) (base : Nat) (values : SdpaTransposeBytes.Lanes) : List (List Memory.Store) :=
  SdpaTransposeBytes.labels.map (fun label => [transposeStore ast base values label])

theorem transpose_execution (trace : SdpaTransposeBytes.Trace values) :
    ThreadgroupWrites.Executes (transposePrograms .shared trace.base values) trace.schedule trace.remaining ∧
    ThreadgroupWrites.AtBarrier trace.remaining ∧ ReadOnlyThreads.AtBarrier 1024 trace.readAfter :=
  ⟨trace.execution,trace.writeBarrier,trace.readBarrier⟩

theorem transpose_register_bytes (trace : SdpaTransposeBytes.Trace values) (group lane : Fin 32) :
    trace.register group lane=FloatMemory.load trace.memory (trace.base+4*(group.val*32+lane.val)) := by
  unfold SdpaTransposeBytes.Trace.register
  rw [ReadOnlyThreads.completed trace.reads trace.readBarrier (group.val*32+lane.val)
    (by have := group.isLt; have := lane.isLt; omega)]
  rfl

variable {steps : Nat} {p : SdpaVector.Platform} {query : Fin 256 → ArrayStorage.BF}
  {keys values : Fin steps → Fin 256 → ArrayStorage.BF}

-- All quantities below are actual Float32 summary bytes or saved registers
-- after the scratch read barrier. No reduction result is supplied as input.
def common (_ : Summary) (execution : SdpaOnePassScratch.Execution p query keys values) : Float32 :=
  p.simdMaximum (fun lane => FloatMemory.load execution.summaries.memory (execution.summaries.maxBase+4*lane.val))

def factor (ast : Summary) (execution : SdpaOnePassScratch.Execution p query keys values) (lane : Fin 32) : Float32 :=
  p.merge.scalar.exp (Arithmetic.sub (FloatMemory.load execution.summaries.memory
    (execution.summaries.maxBase+4*lane.val)) (common ast execution))

def denominator (ast : Summary) (execution : SdpaOnePassScratch.Execution p query keys values) : Float32 :=
  p.merge.reduce (fun lane => FlushToZero.mul (FloatMemory.load execution.summaries.memory
    (execution.summaries.sumBase+4*lane.val)) (factor ast execution lane))

def numerator (_ : Transpose) (ast : Summary) (execution : SdpaOnePassScratch.Execution p query keys values)
    (offset : Fin 8) (group : Fin 32) : Float32 :=
  p.merge.reduce (fun lane => FlushToZero.mul
    (((execution.scratch offset).readAfter (group.val*32+lane.val)).getD 0) (factor ast execution lane))

theorem common_eq (execution : SdpaOnePassScratch.Execution p query keys values) : common .shared execution=SdpaOnePassScratch.common execution := rfl
theorem denominator_eq (execution : SdpaOnePassScratch.Execution p query keys values) : denominator .shared execution=SdpaOnePassScratch.denominator execution := rfl
theorem numerator_eq (execution : SdpaOnePassScratch.Execution p query keys values) (offset : Fin 8) (group : Fin 32) :
    numerator .shared .shared execution offset group=SdpaOnePassScratch.numerator execution offset group := rfl

theorem scratch_reuse (execution : SdpaOnePassScratch.Execution p query keys values) (offset : Fin 7) :
    (execution.scratch ⟨offset.val+1,by omega⟩).base=(execution.scratch ⟨offset.val,by omega⟩).base ∧
    (execution.scratch ⟨offset.val+1,by omega⟩).before=(execution.scratch ⟨offset.val,by omega⟩).memory :=
  ⟨(execution.sameBase _).trans (execution.sameBase _).symm,execution.reuse offset⟩

-- Zero is an explicit source branch. Its exclusion on the selected supported
-- path follows from the already proved positive-denominator numerical range.
def quotient (_ : Transpose) (p : SdpaNormalize.Platform) (numerator denominator : Float32) : Float32 :=
  if Model.isZero (model denominator) then numerator else p.divide numerator denominator

theorem zero_branch (p : SdpaNormalize.Platform) (numerator : Float32) : quotient .shared p numerator 0=numerator := by
  have zero : Model.isZero (model (0 : Float32))=true := by decide +kernel
  simp only [quotient,zero,ite_true]

theorem signed_zero_branch (p : SdpaNormalize.Platform) (numerator : Float32)
    (sign : Float.Model.UnpackedFloat.Sign) :
    quotient .shared p numerator (Float32.ofModel (Float32.Model.pack (.zero sign)))=numerator := by
  have zero : Model.isZero (model (Float32.ofModel (Float32.Model.pack (.zero sign))))=true := by
    cases sign <;> decide +kernel
  simp only [quotient,zero,ite_true]

theorem nonzero_denominator (execution : SdpaOnePassScratch.Execution p query keys values)
    (finite : SdpaVector.Finite p query keys values) : Model.isZero (model (denominator .shared execution))=false := by
  have domain : Division.DivisorDomain (denominator .shared execution) := by
    rw [denominator_eq,SdpaOnePassScratch.denominator_correct execution 0]
    exact (finite.normalization 0).domain
  have hf : (denominator .shared execution).isFinite=true := by
    rw [denominator_eq,SdpaOnePassScratch.denominator_correct execution 0]
    exact (finite.normalization 0).denominator
  exact DivisionBounds.divisor_not_zero _ hf domain

def outputBits (summary : Summary) (transpose : Transpose) (execution : SdpaOnePassScratch.Execution p query keys values)
    (offset : Fin 8) (group : Fin 32) : BitVec 16 :=
  ArrayStorage.bits (BFloat16.narrow (quotient transpose p.normalization
    (numerator transpose summary execution offset group) (denominator summary execution)))

theorem output_bits (execution : SdpaOnePassScratch.Execution p query keys values)
    (finite : SdpaVector.Finite p query keys values) (offset : Fin 8) (group : Fin 32) :
    outputBits .shared .shared execution offset group=
      ArrayStorage.bits (SdpaOnePassScratch.forward execution (SdpaLayout.coordinate group offset)) := by
  unfold outputBits quotient
  rw [nonzero_denominator execution finite]
  simp only [Bool.false_eq_true,ite_false]
  rw [numerator_eq,denominator_eq]
  unfold SdpaOnePassScratch.forward SdpaNormalize.value SdpaNormalize.raw
  have g := group.isLt
  have o := offset.isLt
  have first : (SdpaLayout.coordinate group offset).val%8=offset.val := by dsimp [SdpaLayout.coordinate]; omega
  have second : (SdpaLayout.coordinate group offset).val/8=group.val := by dsimp [SdpaLayout.coordinate]; omega
  simp only [first,second]

end Inference.Kernels.Attention.MlxSdpaMergeSource
