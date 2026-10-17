import kernels.sampling.LogSumExpSourceSyntax
import kernels.sampling.LogSumExpBlockRanges
namespace Inference.Kernels.Sampling.LogSumExpSourceArithmetic
open Contracts.Mlx
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- `maxval < value ? value : maxval` on flushed operands (Maximum.less).
def select (previous value : Float32) : Float32 :=
  if Maximum.less previous value then value else previous

theorem select_model (previous value : Float32) : select previous value=Maximum.value previous value := rfl

theorem retain_tie (previous value : Float32)
    (equal : Model.compare (Numerics.model (FlushToZero.flush previous))
      (Numerics.model (FlushToZero.flush value))=some .eq) :
    select previous value=previous := by
  simp only [select,Maximum.less,equal]
  rfl


private theorem ofFn_four {α : Type} (values : Fin 4→α) :
    List.ofFn values=[values 0,values 1,values 2,values 3] := rfl

attribute [local irreducible] select Maximum.value

def maximum (previous : Float32) (values : Fin 4→Float32) : Float32 :=
  select (select (select (select previous (values 0)) (values 1)) (values 2)) (values 3)

theorem maximum_model (s : LogSumExpBlockRanges.State) (values : Fin 4→Float32) :
    maximum s.maximum values=LogSumExpBlockRanges.nextMaximum s values := by
  simp only [maximum,select_model,LogSumExpBlockRanges.nextMaximum,ofFn_four,Maximum.fold,List.foldl_cons,List.foldl_nil]

-- fast::exp remains the existing scalar primitive. Subtraction is explicitly
-- rounded/flushed before that call, matching the existing source model.
def exponential (p : Attention.SdpaUpdate.Platform) (value shift : Float32) : Float32 :=
  p.exp (Arithmetic.sub value shift)

theorem exponential_model (p : Attention.SdpaUpdate.Platform) (value shift : Float32) :
    exponential p value shift=Attention.SdpaUpdate.exponential p value shift := rfl

-- The boolean is the explicit compiler contract for contraction of '*='
-- with the first following '+='. The remaining three additions stay ordered.
def normalizer (p : Attention.SdpaUpdate.Platform) (previousMaximum nextMaximum acc : Float32)
    (values : Fin 4→Float32) : Float32 :=
  let factor := exponential p previousMaximum nextMaximum
  let term := fun i=>exponential p (values i) nextMaximum
  let first := if p.sumContracted then FlushToZero.fma acc factor (term 0)
    else FlushToZero.add (FlushToZero.mul acc factor) (term 0)
  FlushToZero.add (FlushToZero.add (FlushToZero.add first (term 1)) (term 2)) (term 3)

theorem normalizer_model (p : Attention.SdpaUpdate.Platform) (s : LogSumExpBlockRanges.State)
    (nextMaximum : Float32) (values : Fin 4→Float32) :
    normalizer p s.maximum nextMaximum s.normalizer values=
      LogSumExpAccumulator.update p.sumContracted s.normalizer
        (Attention.SdpaUpdate.exponential p s.maximum nextMaximum)
        (LogSumExpBlockRanges.terms p values nextMaximum) := by
  rw [LogSumExpAccumulator.execution]
  rfl

def block (p : Attention.SdpaUpdate.Platform) (s : LogSumExpBlockRanges.State)
    (values : Fin 4→Float32) : LogSumExpBlockRanges.State :=
  let next := maximum s.maximum values
  ⟨next,normalizer p s.maximum next s.normalizer values⟩

theorem block_model (p : Attention.SdpaUpdate.Platform) (s : LogSumExpBlockRanges.State)
    (values : Fin 4→Float32) : block p s values=LogSumExpBlockRanges.validStep p s values := by
  unfold block
  rw [maximum_model s values]
  dsimp only
  rw [normalizer_model]
  rfl
end Inference.Kernels.Sampling.LogSumExpSourceArithmetic
