import metal.tests.Elab

namespace Metal.Elab.Tests
open Metal Core Elab Assemble.Tests Host.Mlx

/-! # The route kernels elaborate

Each of the ten route kernels' texts (Elab.lean) elaborates, and every contraction site, barrier and
collective of its core has its own site. Kernel-checked (`decide +kernel`). -/

theorem affineRow_elaborates : ((frontend affineRowText).bind elaborate).isSome = true := by decide +kernel
theorem siluRmsHeads_elaborates : ((frontend siluRmsHeadsText).bind elaborate).isSome = true := by
  decide +kernel
theorem gatedDeltaStep_elaborates : ((frontend gatedDeltaStepText).bind elaborate).isSome = true := by
  decide +kernel
theorem gatedRmsNorm_elaborates : ((frontend gatedRmsNormText).bind elaborate).isSome = true := by
  decide +kernel
theorem residualRmsNorm_elaborates : ((frontend residualRmsNormText).bind elaborate).isSome = true := by
  decide +kernel
theorem gateUp_elaborates : ((frontend gateUpText).bind elaborate).isSome = true := by decide +kernel
theorem downPartial_elaborates : ((frontend downPartialText).bind elaborate).isSome = true := by
  decide +kernel
theorem downFold_elaborates : ((frontend downFoldText).bind elaborate).isSome = true := by decide +kernel
theorem argmaxPartial_elaborates : ((frontend argmaxPartialText).bind elaborate).isSome = true := by
  decide +kernel
theorem argmaxFinish_elaborates : ((frontend argmaxFinishText).bind elaborate).isSome = true := by
  decide +kernel

/-- Every contraction site, barrier and collective has its own site. -/
theorem route_sites :
    [affineRowText, siluRmsHeadsText, gatedDeltaStepText, gatedRmsNormText, residualRmsNormText,
      gateUpText, downPartialText, downFoldText, argmaxPartialText, argmaxFinishText].all sitesDistinct = true := by
  decide +kernel

end Metal.Elab.Tests
