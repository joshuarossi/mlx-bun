import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 1 of chain `PRE_first_tail_x15_r0_suffix` (boundaries 4 to 8): the native bookkeeping's step. -/

def PRE_first_tail_x15_r0_suffix.gh1 : List Nat := []
def PRE_first_tail_x15_r0_suffix.gn1 : List Nat := []
def PRE_first_tail_x15_r0_suffix.gi1 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_suffix.gkA1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.arrs (PRE_first_tail_x15_r0_suffix.gh1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gkO1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.objs (PRE_first_tail_x15_r0_suffix.gh1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gkN1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.nodes (PRE_first_tail_x15_r0_suffix.gn1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gkI1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.items (PRE_first_tail_x15_r0_suffix.gi1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gbd1 : (PRE_first_tail_x15_r0_suffix.gh1 ++ PRE_first_tail_x15_r0_suffix.gn1 ++ PRE_first_tail_x15_r0_suffix.gi1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.gle1 : Conv.Cnt.leB (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (⟨21966, 19057, 2825043, 8227⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.gck1 : Conv.ncleanListB (⟨21966, 19057, 2825043, 8227⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx PRE_first_tail_x15_r0_suffix.gh1 PRE_first_tail_x15_r0_suffix.gn1 PRE_first_tail_x15_r0_suffix.gi1 = true
theorem PRE_first_tail_x15_r0_suffix.gncl1 (h : Conv.NClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx) : Conv.NClean (⟨21966, 19057, 2825043, 8227⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s8.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_suffix.gle1 PRE_first_tail_x15_r0_suffix.gkA1 PRE_first_tail_x15_r0_suffix.gkO1 PRE_first_tail_x15_r0_suffix.gkN1 PRE_first_tail_x15_r0_suffix.gkI1 PRE_first_tail_x15_r0_suffix.gbd1 PRE_first_tail_x15_r0_suffix.gck1

-- the JS bookkeeping's step
def PRE_first_tail_x15_r0_suffix.gjh1 : List Nat := [2673450, 2673455, 2673463, 2825030, 2825031, 2825032, 2825033, 2825034, 2825035, 2825036, 2825037, 2825038, 2825039, 2825040, 2825041, 2825042]
kernel_rfl PRE_first_tail_x15_r0_suffix.gjk1 : PRE_first_tail_x15_r0_suffix.s8.heap = Stage.setAll PRE_first_tail_x15_r0_suffix.s4.heap (PRE_first_tail_x15_r0_suffix.gjh1.filterMap fun a => (PRE_first_tail_x15_r0_suffix.s8.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.gjbd1 : PRE_first_tail_x15_r0_suffix.gjh1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.gjc1 : Conv.jcleanListB (⟨21966, 19057, 2825043, 8227⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s8 PRE_first_tail_x15_r0_suffix.gjh1 = true
theorem PRE_first_tail_x15_r0_suffix.gjcl1 (h : Conv.JClean (⟨21966, 19057, 2825030, 8226⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s4) : Conv.JClean (⟨21966, 19057, 2825043, 8227⟩ : Conv.Cnt) PRE_first_tail_x15_r0_suffix.s8 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_suffix.gle1)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_suffix.gjk1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_suffix.gjbd1 a ha)) PRE_first_tail_x15_r0_suffix.gjc1

end Host.Load.Run.Tpl
