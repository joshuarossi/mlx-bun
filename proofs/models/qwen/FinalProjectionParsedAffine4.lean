import models.qwen.FinalProjectionConstruction
import layers.AffineParsedSource4

namespace Inference.Models.Qwen.FinalProjectionParsedAffine4
open Contracts.Mlx Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection4 10 248320}
  {input : Fin 5120 → ArrayStorage.BF}
  (storage : FinalProjectionConstruction.Storage norm (.bits4 projection) input)
  (allocation : FinalProjectionConstruction.Allocation storage)

-- The 248320-row head uses the same normalized activation and parameter
-- storage as final-projection construction, after normalization's stores.
theorem source (before : Nat → Float32) (finite : projection.Finite (norm.forward input)) :
    AffineParsedSource4.Certificate (blocks:=3880)
      (FinalProjectionConstruction.output storage allocation) before :=
  AffineParsedSource4.checked (steps:=10) (blocks:=3880) (FinalProjectionConstruction.output storage allocation)
    before (by decide) (by decide) finite

theorem current_input :
    (FinalProjectionConstruction.output storage allocation).source=
      FinalProjectionConstruction.normalized storage allocation :=
  FinalProjectionConstruction.output_source storage allocation

theorem readback (finite : projection.Finite (norm.forward input)) (row : Fin 248320) :
    AffineParsedSource4.value (steps:=10) (blocks:=3880) (FinalProjectionConstruction.output storage allocation) row=
      projection.forward (norm.forward input) row :=
  (source storage allocation (fun _ => 0) finite).readback row

theorem readback_error (before : Nat → Float32) (finite : projection.Finite (norm.forward input))
    (target error : Fin 5120 → ℝ)
    (inputBound : ∀ i, |Model.toReal (norm.forward input i)-target i|≤error i)
    (row : Fin 248320) :
    |Model.toReal (AffineParsedSource4.value (steps:=10) (blocks:=3880) (FinalProjectionConstruction.output storage allocation) row)-
      projection.target target row|≤projection.budget (norm.forward input) target error row :=
  AffineParsedSource4.readback_error (steps:=10) (blocks:=3880) (FinalProjectionConstruction.output storage allocation)
    before (source storage allocation before finite) target error inputBound finite row

end Inference.Models.Qwen.FinalProjectionParsedAffine4
