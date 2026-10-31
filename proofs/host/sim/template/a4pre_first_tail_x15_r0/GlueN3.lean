import host.sim.template.a4pre_first_tail_x15_r0.H1
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 3 of chain `PRE_first_tail_x15_r0` (boundaries 40 to 41): the native bookkeeping's step. -/

def PRE_first_tail_x15_r0.gh3 : List Nat := []
def PRE_first_tail_x15_r0.gn3 : List Nat := []
def PRE_first_tail_x15_r0.gi3 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0.gkA3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.arrs (PRE_first_tail_x15_r0.gh3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkO3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.objs (PRE_first_tail_x15_r0.gh3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkN3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.nodes (PRE_first_tail_x15_r0.gn3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkI3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx.items (PRE_first_tail_x15_r0.gi3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gbd3 : (PRE_first_tail_x15_r0.gh3 ++ PRE_first_tail_x15_r0.gn3 ++ PRE_first_tail_x15_r0.gi3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.gle3 : Conv.Cnt.leB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0.gck3 : Conv.ncleanListB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx PRE_first_tail_x15_r0.gh3 PRE_first_tail_x15_r0.gn3 PRE_first_tail_x15_r0.gi3 = true
theorem PRE_first_tail_x15_r0.gncl3 (h : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s40.ffi).mlx) : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s41.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0.gle3 PRE_first_tail_x15_r0.gkA3 PRE_first_tail_x15_r0.gkO3 PRE_first_tail_x15_r0.gkN3 PRE_first_tail_x15_r0.gkI3 PRE_first_tail_x15_r0.gbd3 PRE_first_tail_x15_r0.gck3

-- the JS bookkeeping's step
def PRE_first_tail_x15_r0.gjh3 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0.gjk3 : PRE_first_tail_x15_r0.s41.heap = Stage.setAll PRE_first_tail_x15_r0.s40.heap (PRE_first_tail_x15_r0.gjh3.filterMap fun a => (PRE_first_tail_x15_r0.s41.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0.gjbd3 : PRE_first_tail_x15_r0.gjh3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.gjc3 : Conv.jcleanListB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s41 PRE_first_tail_x15_r0.gjh3 = true
theorem PRE_first_tail_x15_r0.gjcl3 (h : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s40) : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s41 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0.gle3)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0.gjk3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0.gjbd3 a ha)) PRE_first_tail_x15_r0.gjc3

end Host.Load.Run.Tpl
