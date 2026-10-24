import metal.tests.Elab

namespace Metal.Elab.Tests
open Metal Core Elab Assemble.Tests Host.Mlx

/-! # The route kernels' floating-operation inventories

AirInventory.ts (`xcrun metal -std=metal4.1 -fmetal-math-mode=safe`) gives
the same counts in both columns, except that the default level's
`fcmp.olt.bf16` in gatedRmsNorm is `fcmp.olt.f32` here: the optimizer
narrows `g < 0.0f` for `g = float(gate[index])` through the local; the
semantics compares `bfloat`s through widening, so the core keeps it. -/

theorem affineRow_inventory :
    ((frontend affineRowText).bind elaborateO0).map inventory = some
      [("fadd.bf16", 7), ("fadd.f32", 2), ("fsub.f32", 10), ("fmul.f32", 3), ("fdiv.f32", 7),
       ("llvm.fmuladd.f32", 11), ("air.simd_sum.f32", 1), ("air.wg.barrier", 1), ("fpext bf16→f32", 11),
       ("fptrunc f32→bf16", 1), ("bitcast i32→f32", 10)] := by
  decide +kernel

theorem affineRow_inventoryDefault :
    ((frontend affineRowText).bind elaborate).map inventoryDefault = some
      [("fadd.bf16", 7), ("fadd.f32", 12), ("fmul.f32", 10), ("llvm.fmuladd.f32", 11),
       ("air.simd_sum.f32", 1), ("air.wg.barrier", 1), ("fpext bf16→f32", 11), ("fptrunc f32→bf16", 1),
       ("bitcast i32→f32", 10)] := by
  decide +kernel

theorem siluRmsHeads_inventory :
    ((frontend siluRmsHeadsText).bind elaborateO0).map inventory = some
      [("fadd.bf16", 1), ("fadd.f32", 1), ("fsub.bf16", 1), ("fmul.bf16", 3), ("fmul.f32", 1),
       ("fdiv.bf16", 1), ("fdiv.f32", 1), ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1),
       ("air.fast_fabs.f32", 1), ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 1), ("fcmp.olt.bf16", 1),
       ("fpext bf16→f32", 4), ("fptrunc f32→bf16", 3)] := by
  decide +kernel

theorem siluRmsHeads_inventoryDefault :
    ((frontend siluRmsHeadsText).bind elaborate).map inventoryDefault = some
      [("fadd.bf16", 1), ("fadd.f32", 1), ("fsub.bf16", 1), ("fmul.bf16", 3), ("fmul.f32", 2),
       ("fdiv.bf16", 1), ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1), ("air.fast_fabs.f32", 1),
       ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 1), ("fcmp.olt.bf16", 1), ("fpext bf16→f32", 4),
       ("fptrunc f32→bf16", 3)] := by
  decide +kernel

theorem gatedDeltaStep_inventory :
    ((frontend gatedDeltaStepText).bind elaborateO0).map inventory = some
      [("fsub.f32", 1), ("fmul.f32", 2), ("llvm.fmuladd.f32", 3), ("air.simd_sum.f32", 2),
       ("fpext bf16→f32", 5), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem gatedDeltaStep_inventoryDefault :
    ((frontend gatedDeltaStepText).bind elaborate).map inventoryDefault = some
      [("fsub.f32", 1), ("fmul.f32", 2), ("llvm.fmuladd.f32", 3), ("air.simd_sum.f32", 2),
       ("fpext bf16→f32", 5), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem gatedRmsNorm_inventory :
    ((frontend gatedRmsNormText).bind elaborateO0).map inventory = some
      [("fadd.f32", 2), ("fsub.f32", 1), ("fmul.bf16", 1), ("fmul.f32", 3), ("fdiv.f32", 2),
       ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1), ("air.fast_fabs.f32", 1), ("air.rsqrt.f32", 1),
       ("air.simd_sum.f32", 1), ("fcmp.olt.f32", 1), ("fpext bf16→f32", 4), ("fptrunc f32→bf16", 2)] := by
  decide +kernel

theorem gatedRmsNorm_inventoryDefault :
    ((frontend gatedRmsNormText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 2), ("fsub.f32", 1), ("fmul.bf16", 1), ("fmul.f32", 4), ("fdiv.f32", 1),
       ("llvm.fmuladd.f32", 1), ("air.fast_exp.f32", 1), ("air.fast_fabs.f32", 1), ("air.rsqrt.f32", 1),
       ("air.simd_sum.f32", 1), ("fcmp.olt.f32", 1), ("fpext bf16→f32", 4), ("fptrunc f32→bf16", 2)] := by
  decide +kernel

theorem residualRmsNorm_inventory :
    ((frontend residualRmsNormText).bind elaborateO0).map inventory = some
      [("fadd.f32", 2), ("fmul.bf16", 1), ("fmul.f32", 1), ("fdiv.f32", 1), ("llvm.fmuladd.f32", 1),
       ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 3), ("fpext bf16→f32", 4),
       ("fptrunc f32→bf16", 2)] := by
  decide +kernel

theorem residualRmsNorm_inventoryDefault :
    ((frontend residualRmsNormText).bind elaborate).map inventoryDefault = some
      [("fadd.bf16", 1), ("fadd.f32", 1), ("fmul.bf16", 1), ("fmul.f32", 1), ("fdiv.f32", 1),
       ("llvm.fmuladd.f32", 1), ("air.rsqrt.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 3),
       ("fpext bf16→f32", 2), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem gateUp_inventory :
    ((frontend gateUpText).bind elaborateO0).map inventory = some
      [("fadd.f32", 3), ("fsub.f32", 1), ("fmul.f32", 5), ("fdiv.f32", 1), ("fneg.f32", 1),
       ("air.fma.f32", 4), ("air.exp.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 1),
       ("fpext f16→f32", 2), ("fpext bf16→f32", 5), ("fptrunc f32→bf16", 5), ("bitcast i32→f32", 2)] := by
  decide +kernel

theorem gateUp_inventoryDefault :
    ((frontend gateUpText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 4), ("fmul.bf16", 2), ("fmul.f32", 3), ("fdiv.f32", 1), ("fneg.f32", 1),
       ("air.fma.f32", 4), ("air.exp.f32", 1), ("air.simd_sum.f32", 2), ("air.wg.barrier", 1),
       ("fpext f16→f32", 2), ("fpext bf16→f32", 1), ("fptrunc f32→bf16", 3), ("bitcast i32→f32", 2)] := by
  decide +kernel

theorem downPartial_inventory :
    ((frontend downPartialText).bind elaborateO0).map inventory = some
      [("fadd.f32", 1), ("fsub.f32", 1), ("fmul.f32", 3), ("air.fma.f32", 2), ("air.wg.barrier", 3),
       ("fpext f16→f32", 2), ("fpext bf16→f32", 2), ("bitcast i32→f32", 1)] := by
  decide +kernel

theorem downPartial_inventoryDefault :
    ((frontend downPartialText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 2), ("fmul.f32", 3), ("air.fma.f32", 2), ("air.wg.barrier", 3), ("fpext f16→f32", 2),
       ("fpext bf16→f32", 2), ("bitcast i32→f32", 1)] := by
  decide +kernel

theorem downFold_inventory :
    ((frontend downFoldText).bind elaborateO0).map inventory = some
      [("air.simd_sum.f32", 1), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem downFold_inventoryDefault :
    ((frontend downFoldText).bind elaborate).map inventoryDefault = some
      [("air.simd_sum.f32", 1), ("fptrunc f32→bf16", 1)] := by
  decide +kernel

theorem argmaxPartial_inventory :
    ((frontend argmaxPartialText).bind elaborateO0).map inventory = some
      [("fsub.bf16", 1), ("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2),
       ("air.wg.barrier", 1), ("air.min.u.i32", 1), ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3),
       ("fpext bf16→f32", 1), ("bitcast f32→i32", 1)] := by
  decide +kernel

theorem argmaxPartial_inventoryDefault :
    ((frontend argmaxPartialText).bind elaborate).map inventoryDefault = some
      [("fsub.bf16", 1), ("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2),
       ("air.wg.barrier", 1), ("air.min.u.i32", 1), ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3),
       ("fpext bf16→f32", 1), ("bitcast f32→i32", 1)] := by
  decide +kernel

theorem argmaxFinish_inventory :
    ((frontend argmaxFinishText).bind elaborateO0).map inventory = some
      [("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2), ("air.wg.barrier", 1),
       ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3)] := by
  decide +kernel

theorem argmaxFinish_inventoryDefault :
    ((frontend argmaxFinishText).bind elaborate).map inventoryDefault = some
      [("air.simd_shuffle_down.u.i32", 2), ("air.simd_shuffle_down.f32", 2), ("air.wg.barrier", 1),
       ("fcmp.ogt.f32", 3), ("fcmp.oeq.f32", 3)] := by
  decide +kernel

end Metal.Elab.Tests
