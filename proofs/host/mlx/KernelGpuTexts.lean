import metal.kernels.GateUp
import metal.kernels.DownPartial
import metal.kernels.AffineRow

namespace Host.Mlx.KernelGpu
open Metal

/-! # The texts of the route's parametrized kernels

The texts MLX assembles for affine_row at both widths of every `AffineRoute` shape, for gate-up at each pair of gate
and up widths in {2, 3, 4} and for the down partial at each width, and their elaboration. `Metal.Kernels.AffineRow`
proves the four checkpoint affine texts and `Metal.Kernels.GateUp` seven of the nine gate-up pairs; the rest are
proved here (any loaded pipeline may bind either width at each shape). -/

kernel_rfl affine_compile_4_10_160 :
  (frontend (Metal.Kernels.AffineRow.text 4 10 160)).bind elaborate = some (Metal.Kernels.AffineRow.core4 10)
kernel_rfl affine_compile_4_10_96 :
  (frontend (Metal.Kernels.AffineRow.text 4 10 96)).bind elaborate = some (Metal.Kernels.AffineRow.core4 10)
kernel_rfl affine_compile_4_12_80 :
  (frontend (Metal.Kernels.AffineRow.text 4 12 80)).bind elaborate = some (Metal.Kernels.AffineRow.core4 12)
kernel_rfl affine_compile_3_10_3880 :
  (frontend (Metal.Kernels.AffineRow.text 3 10 3880)).bind elaborate = some (Metal.Kernels.AffineRow.core3 10)

set_option maxHeartbeats 0 in
theorem affine_assembled :
    Metal.Kernels.AffineRow.assembled 4 10 160 = some (Metal.Kernels.AffineRow.text 4 10 160) ∧
    Metal.Kernels.AffineRow.assembled 4 10 96 = some (Metal.Kernels.AffineRow.text 4 10 96) ∧
    Metal.Kernels.AffineRow.assembled 4 12 80 = some (Metal.Kernels.AffineRow.text 4 12 80) ∧
    Metal.Kernels.AffineRow.assembled 3 10 3880 = some (Metal.Kernels.AffineRow.text 3 10 3880) := by
  decide +kernel

kernel_rfl gateUp_compile_2_4 :
  (frontend (Metal.Kernels.GateUp.text 2 4)).bind elaborate = some (Metal.Kernels.GateUp.core 2 4 true)
kernel_rfl gateUp_compile_4_2 :
  (frontend (Metal.Kernels.GateUp.text 4 2)).bind elaborate = some (Metal.Kernels.GateUp.core 4 2 true)

theorem gateUp_compiles {kg ku : Nat} (hg : kg = 2 ∨ kg = 3 ∨ kg = 4) (hu : ku = 2 ∨ ku = 3 ∨ ku = 4) :
    (frontend (Metal.Kernels.GateUp.text kg ku)).bind elaborate =
      some (Metal.Kernels.GateUp.core kg ku (decide (kg ≠ ku))) := by
  rcases hg with rfl | rfl | rfl <;> rcases hu with rfl | rfl | rfl
  exacts [Metal.Kernels.GateUp.compile_2_2, Metal.Kernels.GateUp.compile_2_3, gateUp_compile_2_4,
    Metal.Kernels.GateUp.compile_3_2, Metal.Kernels.GateUp.compile_3_3, Metal.Kernels.GateUp.compile_3_4,
    gateUp_compile_4_2, Metal.Kernels.GateUp.compile_4_3, Metal.Kernels.GateUp.compile_4_4]

set_option maxHeartbeats 0 in
theorem gateUp_launch {kg ku : Nat} (hg : kg = 2 ∨ kg = 3 ∨ kg = 4) (hu : ku = 2 ∨ ku = 3 ∨ ku = 4) :
    Assemble.Tests.launch .gateUp chars!"mlx_bun_trellis_gateup_codebook_row" (Metal.Kernels.GateUp.inputs kg ku) [chars!"mid"]
      (gateUpConfig kg ku) = some (Metal.Kernels.GateUp.text kg ku) := by
  rcases hg with rfl | rfl | rfl <;> rcases hu with rfl | rfl | rfl <;> decide +kernel

set_option maxHeartbeats 0 in
theorem downPartial_launch {k : Nat} (hk : k = 2 ∨ k = 3 ∨ k = 4) :
    Assemble.Tests.launch .downPartial chars!"mlx_bun_trellis_down_codebook_row" (Metal.Kernels.DownPartial.inputs k)
      [chars!"partial"] (downConfig k) = some (Metal.Kernels.DownPartial.text k) := by
  rcases hk with rfl | rfl | rfl <;> decide +kernel

end Host.Mlx.KernelGpu
