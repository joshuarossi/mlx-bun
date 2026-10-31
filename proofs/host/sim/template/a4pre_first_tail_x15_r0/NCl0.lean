import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.template.a4pre_setup_early_r0.NCl0
import host.sim.conv.NClean
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

kernel_rfl PRE_first_tail_x15_r0.ncl_arrs_eq : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s0.ffi).mlx.arrs = (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.arrs
kernel_rfl PRE_first_tail_x15_r0.ncl_objs_eq : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s0.ffi).mlx.objs = (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.objs
kernel_rfl PRE_first_tail_x15_r0.ncl_nodes_eq : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s0.ffi).mlx.nodes = (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.nodes
kernel_rfl PRE_first_tail_x15_r0.ncl_items_eq : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s0.ffi).mlx.items = (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.items

theorem PRE_first_tail_x15_r0.ncl0 : Conv.NClean (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s0.ffi).mlx := by
  refine PRE_setup_early_r0.ncl0.stepB (lh := []) (ln := []) (li := []) ⟨Nat.le_refl _, Nat.le_refl _, Nat.le_refl _, Nat.le_refl _⟩ ?_ ?_ ?_ ?_ rfl
  · intro k _; rw [PRE_first_tail_x15_r0.ncl_arrs_eq]
  · intro k _; rw [PRE_first_tail_x15_r0.ncl_objs_eq]
  · intro k _; rw [PRE_first_tail_x15_r0.ncl_nodes_eq]
  · intro k _; rw [PRE_first_tail_x15_r0.ncl_items_eq]

end Host.Load.Run.Tpl
