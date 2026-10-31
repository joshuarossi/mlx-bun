import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 0 of chain `PRE_first_tail_x15_r0_suffix` (boundaries 0 to 2): the native bookkeeping's step. -/

def PRE_first_tail_x15_r0_suffix.gh0 : List Nat := [18155, 21965]
def PRE_first_tail_x15_r0_suffix.gn0 : List Nat := []
def PRE_first_tail_x15_r0_suffix.gi0 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_suffix.gkA0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_suffix.gh0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gkO0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_suffix.gh0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gkN0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx.nodes (PRE_first_tail_x15_r0_suffix.gn0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gkI0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx.items (PRE_first_tail_x15_r0_suffix.gi0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gbd0 : (PRE_first_tail_x15_r0_suffix.gh0 ++ PRE_first_tail_x15_r0_suffix.gn0 ++ PRE_first_tail_x15_r0_suffix.gi0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.gle0 : Conv.Cnt.leB (⟨21966, 19057, 2825025, 8226⟩ : Conv.Cnt) (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.gck0 : Conv.ncleanListB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx PRE_first_tail_x15_r0_suffix.gh0 PRE_first_tail_x15_r0_suffix.gn0 PRE_first_tail_x15_r0_suffix.gi0 = true
theorem PRE_first_tail_x15_r0_suffix.gncl0 (h : Conv.NClean (⟨21966, 19057, 2825025, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx) : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_suffix.gle0 PRE_first_tail_x15_r0_suffix.gkA0 PRE_first_tail_x15_r0_suffix.gkO0 PRE_first_tail_x15_r0_suffix.gkN0 PRE_first_tail_x15_r0_suffix.gkI0 PRE_first_tail_x15_r0_suffix.gbd0 PRE_first_tail_x15_r0_suffix.gck0

-- the JS bookkeeping's step
def PRE_first_tail_x15_r0_suffix.gjh0 : List Nat := [2673259, 2673264, 2673291, 2673463, 2673466, 2673483, 2825012, 2825025, 2825026, 2825027, 2825028, 2825029]
kernel_rfl PRE_first_tail_x15_r0_suffix.gjk0 : PRE_first_tail_x15_r0_suffix.s2.heap = Stage.setAll PRE_first_tail_x15_r0_suffix.s0.heap (PRE_first_tail_x15_r0_suffix.gjh0.filterMap fun a => (PRE_first_tail_x15_r0_suffix.s2.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gjbd0 : PRE_first_tail_x15_r0_suffix.gjh0.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.gjc0 : Conv.jcleanListB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s2 PRE_first_tail_x15_r0_suffix.gjh0 = true
theorem PRE_first_tail_x15_r0_suffix.gjcl0 (h : Conv.JClean (⟨21966, 19057, 2825025, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s0) : Conv.JClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s2 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_suffix.gle0)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_suffix.gjk0 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_suffix.gjbd0 a ha)) PRE_first_tail_x15_r0_suffix.gjc0

end Host.Load.Run.Tpl
