import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.template.a4pre_first_tail_x15_r0.H1
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 2 of chain `PRE_first_tail_x15_r0` (boundaries 19 to 38): the native bookkeeping's step. -/

def PRE_first_tail_x15_r0.gh2 : List Nat := [18155]
def PRE_first_tail_x15_r0.gn2 : List Nat := [15235]
def PRE_first_tail_x15_r0.gi2 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0.gkA2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.arrs (PRE_first_tail_x15_r0.gh2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkO2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.objs (PRE_first_tail_x15_r0.gh2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkN2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.nodes (PRE_first_tail_x15_r0.gn2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gkI2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.items (PRE_first_tail_x15_r0.gi2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.gbd2 : (PRE_first_tail_x15_r0.gh2 ++ PRE_first_tail_x15_r0.gn2 ++ PRE_first_tail_x15_r0.gi2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.gle2 : Conv.Cnt.leB (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0.gck2 : Conv.ncleanListB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx PRE_first_tail_x15_r0.gh2 PRE_first_tail_x15_r0.gn2 PRE_first_tail_x15_r0.gi2 = true
theorem PRE_first_tail_x15_r0.gncl2 (h : Conv.NClean (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx) : Conv.NClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s38.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0.gle2 PRE_first_tail_x15_r0.gkA2 PRE_first_tail_x15_r0.gkO2 PRE_first_tail_x15_r0.gkN2 PRE_first_tail_x15_r0.gkI2 PRE_first_tail_x15_r0.gbd2 PRE_first_tail_x15_r0.gck2

-- the JS bookkeeping's step
def PRE_first_tail_x15_r0.gjh2 : List Nat := [2673453, 2673454, 2673455, 2673458, 2673459, 2673460, 2673461, 2673462, 2673463, 2673464, 2673465, 2673466, 2673467, 2673468, 2673469, 2673470, 2673471, 2673472, 2673473, 2673474, 2673475, 2673476, 2673477, 2673478, 2673479, 2673480, 2673481, 2673482, 2673483, 2673484, 2673485, 2673486, 2673487]
kernel_rfl PRE_first_tail_x15_r0.gjk2 : PRE_first_tail_x15_r0.s38.heap = Stage.setAll PRE_first_tail_x15_r0.s19.heap (PRE_first_tail_x15_r0.gjh2.filterMap fun a => (PRE_first_tail_x15_r0.s38.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0.gjbd2 : PRE_first_tail_x15_r0.gjh2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0.gjc2 : Conv.jcleanListB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s38 PRE_first_tail_x15_r0.gjh2 = true
theorem PRE_first_tail_x15_r0.gjcl2 (h : Conv.JClean (⟨18155, 15235, 2673458, 15⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s19) : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0.s38 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0.gle2)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0.gjk2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0.gjbd2 a ha)) PRE_first_tail_x15_r0.gjc2

end Host.Load.Run.Tpl
