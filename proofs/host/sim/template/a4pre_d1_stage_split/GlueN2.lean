import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 2 of chain `D1StageSplit` (boundaries 21 to 22): the native bookkeeping's step. -/

def D1StageSplit.gh2 : List Nat := []
def D1StageSplit.gn2 : List Nat := []
def D1StageSplit.gi2 : List Nat := []
kernel_rfl D1StageSplit.gkA2 : (Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s21.ffi).mlx.arrs (D1StageSplit.gh2.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl D1StageSplit.gkO2 : (Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s21.ffi).mlx.objs (D1StageSplit.gh2.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl D1StageSplit.gkN2 : (Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s21.ffi).mlx.nodes (D1StageSplit.gn2.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl D1StageSplit.gkI2 : (Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s21.ffi).mlx.items (D1StageSplit.gi2.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx.items.get i).map (i, ·))
kernel_rfl D1StageSplit.gbd2 : (D1StageSplit.gh2 ++ D1StageSplit.gn2 ++ D1StageSplit.gi2).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl D1StageSplit.gle2 : Conv.Cnt.leB (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) = true
kernel_rfl D1StageSplit.gck2 : Conv.ncleanListB (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) (Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx D1StageSplit.gh2 D1StageSplit.gn2 D1StageSplit.gi2 = true
theorem D1StageSplit.gncl2 (h : Conv.NClean (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) (Host.Load.Layers.toLoad D1StageSplit.s21.ffi).mlx) : Conv.NClean (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) (Host.Load.Layers.toLoad D1StageSplit.s22.ffi).mlx :=
  Conv.NClean.stepKeep h D1StageSplit.gle2 D1StageSplit.gkA2 D1StageSplit.gkO2 D1StageSplit.gkN2 D1StageSplit.gkI2 D1StageSplit.gbd2 D1StageSplit.gck2

-- the JS bookkeeping's step
def D1StageSplit.gjh2 : List Nat := []
kernel_rfl D1StageSplit.gjk2 : D1StageSplit.s22.heap = Stage.setAll D1StageSplit.s21.heap (D1StageSplit.gjh2.filterMap fun a => (D1StageSplit.s22.heap.get a).map (a, ·))
kernel_rfl D1StageSplit.gjbd2 : D1StageSplit.gjh2.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl D1StageSplit.gjc2 : Conv.jcleanListB (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) D1StageSplit.s22 D1StageSplit.gjh2 = true
theorem D1StageSplit.gjcl2 (h : Conv.JClean (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) D1StageSplit.s21) : Conv.JClean (⟨18156, 15236, 2673518, 17⟩ : Conv.Cnt) D1StageSplit.s22 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB D1StageSplit.gle2)
    (Conv.heap_off_setAll D1StageSplit.gjk2 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp D1StageSplit.gjbd2 a ha)) D1StageSplit.gjc2

end Host.Load.Run.Tpl
