import metal.tests.Prefill

namespace Metal.Prefill.Tests
open Metal Core Host.Mlx Host.Mlx.PrefillSources

/-! # The prefill kernels' floating-operation inventories

As Prefill.lean describes them, against proofs/metal/AirInventory.ts. -/

theorem affine3Rows_inventory :
    ((frontend affine3RowsText).bind elaborateO0).map inventory = some
      [("fadd.f32", 4), ("fsub.f32", 1), ("air.fma.f32", 3), ("air.simd_sum.f32", 1), ("fpext bf16→f32", 2),
       ("fptrunc f32→bf16", 1), ("bitcast i32→f32", 1), ("air.convert.f.v4f32.f.v4bf16", 1)] := by
  decide +kernel

theorem affine3Rows_inventoryDefault :
    ((frontend affine3RowsText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 5), ("air.fma.f32", 3), ("air.simd_sum.f32", 1), ("fpext bf16→f32", 2), ("fptrunc f32→bf16", 1),
       ("bitcast i32→f32", 1), ("air.convert.f.v4f32.f.v4bf16", 1)] := by
  decide +kernel

theorem affine4Rows_inventory :
    ((frontend affine4RowsText).bind elaborateO0).map inventory = some
      [("fadd.f32", 4), ("fsub.f32", 1), ("air.fma.f32", 3), ("air.simd_sum.f32", 1), ("fpext bf16→f32", 2),
       ("fptrunc f32→bf16", 1), ("bitcast i32→f32", 1), ("air.convert.f.v4f32.f.v4bf16", 1)] := by
  decide +kernel

theorem affine4Rows_inventoryDefault :
    ((frontend affine4RowsText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 5), ("air.fma.f32", 3), ("air.simd_sum.f32", 1), ("fpext bf16→f32", 2), ("fptrunc f32→bf16", 1),
       ("bitcast i32→f32", 1), ("air.convert.f.v4f32.f.v4bf16", 1)] := by
  decide +kernel

theorem affineSplitMma_inventory :
    ((frontend affineSplitMmaText).bind elaborateO0).map inventory = some
      [("fadd.f32", 1), ("fsub.f32", 1), ("fmul.f32", 1), ("air.fma.f32", 2), ("air.wg.barrier", 1),
       ("air.min.u.i32", 4), ("fpext bf16→f32", 2), ("fptrunc f32→bf16", 1), ("bitcast i32→f32", 2),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f32.v64f32", 1),
       ("air.convert.f.v4f32.f.v4bf16", 2)] := by
  decide +kernel

theorem affineSplitMma_inventoryDefault :
    ((frontend affineSplitMmaText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 1), ("fsub.f32", 1), ("fmul.f32", 1), ("air.fma.f32", 2), ("air.wg.barrier", 1),
       ("air.min.u.i32", 4), ("fpext bf16→f32", 2), ("fptrunc f32→bf16", 1), ("bitcast i32→f32", 2),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f32.v64f32", 1),
       ("air.convert.f.v4f32.f.v4bf16", 2)] := by
  decide +kernel

theorem gateUpCodebookMma_inventory :
    ((frontend gateUpCodebookMmaText).bind elaborateO0).map inventory = some
      [("fadd.f32", 1), ("fsub.f32", 1), ("fmul.f32", 6), ("fdiv.f32", 1), ("fneg.f32", 1), ("air.exp.f32", 1),
       ("air.wg.barrier", 1), ("air.min.u.i32", 2), ("fpext f16→f32", 2), ("fpext bf16→f32", 7),
       ("fptrunc f32→f16", 1), ("fptrunc f32→bf16", 5), ("bitcast i16→bf16", 2), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f16.v64f32.v64f32", 2)] := by
  decide +kernel

theorem gateUpCodebookMma_inventoryDefault :
    ((frontend gateUpCodebookMmaText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 2), ("fmul.bf16", 2), ("fmul.f32", 4), ("fdiv.f32", 1), ("fneg.f32", 1), ("air.exp.f32", 1),
       ("air.wg.barrier", 1), ("air.min.u.i32", 2), ("fpext f16→f32", 2), ("fpext bf16→f32", 3),
       ("fptrunc f32→f16", 1), ("fptrunc f32→bf16", 3), ("bitcast i16→bf16", 2), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f16.v64f32.v64f32", 2)] := by
  decide +kernel

theorem gateUpMmaWide_inventory :
    ((frontend gateUpMmaWideText).bind elaborateO0).map inventory = some
      [("fadd.f32", 1), ("fsub.f32", 1), ("fmul.f32", 6), ("fdiv.f32", 1), ("fneg.f32", 1), ("air.exp.f32", 1),
       ("air.wg.barrier", 2), ("air.min.u.i32", 1), ("fpext f16→f32", 6), ("fpext bf16→f32", 7),
       ("fptrunc f32→f16", 1), ("fptrunc f32→bf16", 5), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f32.v64f32", 2)] := by
  decide +kernel

theorem gateUpMmaWide_inventoryDefault :
    ((frontend gateUpMmaWideText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 2), ("fmul.bf16", 2), ("fmul.f32", 4), ("fdiv.f32", 1), ("fneg.f32", 1), ("air.exp.f32", 1),
       ("air.wg.barrier", 2), ("air.min.u.i32", 1), ("fpext f16→f32", 6), ("fpext bf16→f32", 3),
       ("fptrunc f32→f16", 1), ("fptrunc f32→bf16", 3), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f32.v64f32", 2)] := by
  decide +kernel

theorem downMmaWide_inventory :
    ((frontend downMmaWideText).bind elaborateO0).map inventory = some
      [("fsub.f32", 1), ("fmul.f32", 4), ("air.wg.barrier", 1), ("air.min.u.i32", 2), ("fpext f16→f32", 2),
       ("fpext bf16→f32", 2), ("fptrunc f32→f16", 1), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f16.v64f32", 1)] := by
  decide +kernel

theorem downMmaWide_inventoryDefault :
    ((frontend downMmaWideText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 1), ("fmul.f32", 4), ("air.wg.barrier", 1), ("air.min.u.i32", 2), ("fpext f16→f32", 2),
       ("fpext bf16→f32", 2), ("fptrunc f32→f16", 1), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f16.v64f32", 1)] := by
  decide +kernel

theorem downK3iMmaWide_inventory :
    ((frontend downK3iMmaWideText).bind elaborateO0).map inventory = some
      [("fsub.f32", 1), ("fmul.f32", 4), ("air.wg.barrier", 1), ("air.min.u.i32", 2), ("fpext f16→f32", 2),
       ("fpext bf16→f32", 2), ("fptrunc f32→f16", 1), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f16.v64f32", 1)] := by
  decide +kernel

theorem downK3iMmaWide_inventoryDefault :
    ((frontend downK3iMmaWideText).bind elaborate).map inventoryDefault = some
      [("fadd.f32", 1), ("fmul.f32", 4), ("air.wg.barrier", 1), ("air.min.u.i32", 2), ("fpext f16→f32", 2),
       ("fpext bf16→f32", 2), ("fptrunc f32→f16", 1), ("bitcast i32→f32", 1),
       ("air.simdgroup_matrix_8x8_multiply_accumulate.v64f32.v64f32.v64f16.v64f32", 1)] := by
  decide +kernel

/-! The fills, write_half and vector_expand: the same inventory at both levels. -/

theorem aneTrellisFill_inventory :
    ((frontend aneTrellisFillText).bind elaborateO0).map inventory = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→f16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

theorem aneTrellisFill_inventoryDefault :
    ((frontend aneTrellisFillText).bind elaborate).map inventoryDefault = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→f16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

theorem aneTrellisFillK3i_inventory :
    ((frontend aneTrellisFillK3iText).bind elaborateO0).map inventory = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→f16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

theorem aneTrellisFillK3i_inventoryDefault :
    ((frontend aneTrellisFillK3iText).bind elaborate).map inventoryDefault = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→f16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

theorem aneWriteHalf_inventory :
    ((frontend aneWriteHalfText).bind elaborateO0).map inventory = some
      [("fpext bf16→f32", 1), ("fptrunc f32→f16", 1)] := by
  decide +kernel

theorem aneWriteHalf_inventoryDefault :
    ((frontend aneWriteHalfText).bind elaborate).map inventoryDefault = some
      [("fpext bf16→f32", 1), ("fptrunc f32→f16", 1)] := by
  decide +kernel

theorem vectorExpand_inventory :
    ((frontend vectorExpandText).bind elaborateO0).map inventory = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→bf16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

theorem vectorExpand_inventoryDefault :
    ((frontend vectorExpandText).bind elaborate).map inventoryDefault = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→bf16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

theorem vectorExpandK3i_inventory :
    ((frontend vectorExpandK3iText).bind elaborateO0).map inventory = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→bf16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

theorem vectorExpandK3i_inventoryDefault :
    ((frontend vectorExpandK3iText).bind elaborate).map inventoryDefault = some
      [("fmul.f32", 2), ("fneg.f32", 1), ("air.fma.f32", 2), ("fpext f16→f32", 1), ("fptrunc f32→bf16", 1),
       ("air.convert.f.f32.s.i32", 1)] := by
  decide +kernel

end Metal.Prefill.Tests
