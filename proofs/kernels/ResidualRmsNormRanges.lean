import kernels.ResidualRmsNorm
import contracts.mlx.BFloat16ConversionBounds
import contracts.mlx.Float32Bounds

namespace Inference.Kernels.ResidualRmsNormRanges
open Contracts.Mlx Contracts.Mlx.Numerics ResidualRmsNorm
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Keep both source rounding sites: binary32 addition followed by bf16 store.
theorem addition (x update cap : BF) (hx : Model.isFinite x = true)
    (hu : Model.isFinite update = true) (hc : Model.isFinite cap = true)
    (bound : |Model.toReal x| + |Model.toReal update| ≤ Model.toReal cap) :
    AddFinite x update ∧ |Model.toReal (residual x update)| ≤ Model.toReal cap := by
  have h := Float32Bounds.add_range (BFloat16.widen x) (BFloat16.widen update) (BFloat16.widen cap)
    (BFloat16.widen_finite x hx) (BFloat16.widen_finite update hu) (BFloat16.widen_finite cap hc) (by
      simpa only [BFloat16.widen_real _ hx, BFloat16.widen_real _ hu, BFloat16.widen_real _ hc] using bound)
  have hn := BFloat16ConversionBounds.narrow_range (added x update) cap (FlushToZero.finite_flush _ h.1) hc
    (by simpa only [added, BFloat16.widen_real _ hc] using h.2)
  exact ⟨⟨hx, hu, h.1, hn.1⟩, hn.2⟩

end Inference.Kernels.ResidualRmsNormRanges
