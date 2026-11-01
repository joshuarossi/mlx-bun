import host.sim.template.a4pre_d1_stage_split.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 1 of chain `D1StageSplit` (boundaries 1 to 20): the native bookkeeping's step. -/

def D1StageSplit.gh1 : List Nat := [18155]
def D1StageSplit.gn1 : List Nat := [15235]
def D1StageSplit.gi1 : List Nat := []
kernel_rfl D1StageSplit.gkA1 : (Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s1.ffi).mlx.arrs (D1StageSplit.gh1.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl D1StageSplit.gkO1 : (Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s1.ffi).mlx.objs (D1StageSplit.gh1.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl D1StageSplit.gkN1 : (Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s1.ffi).mlx.nodes (D1StageSplit.gn1.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl D1StageSplit.gkI1 : (Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad D1StageSplit.s1.ffi).mlx.items (D1StageSplit.gi1.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx.items.get i).map (i, ·))
kernel_rfl D1StageSplit.gbd1 : (D1StageSplit.gh1 ++ D1StageSplit.gn1 ++ D1StageSplit.gi1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl D1StageSplit.gle1 : Conv.Cnt.leB (⟨18155, 15235, 2673470, 17⟩ : Conv.Cnt) (⟨18156, 15236, 2673500, 17⟩ : Conv.Cnt) = true
kernel_rfl D1StageSplit.gck1 : Conv.ncleanListB (⟨18156, 15236, 2673500, 17⟩ : Conv.Cnt) (Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx D1StageSplit.gh1 D1StageSplit.gn1 D1StageSplit.gi1 = true
theorem D1StageSplit.gncl1 (h : Conv.NClean (⟨18155, 15235, 2673470, 17⟩ : Conv.Cnt) (Host.Load.Layers.toLoad D1StageSplit.s1.ffi).mlx) : Conv.NClean (⟨18156, 15236, 2673500, 17⟩ : Conv.Cnt) (Host.Load.Layers.toLoad D1StageSplit.s20.ffi).mlx :=
  Conv.NClean.stepKeep h D1StageSplit.gle1 D1StageSplit.gkA1 D1StageSplit.gkO1 D1StageSplit.gkN1 D1StageSplit.gkI1 D1StageSplit.gbd1 D1StageSplit.gck1

-- the JS bookkeeping's step
def D1StageSplit.gjh1 : List Nat := [2673453, 2673454, 2673455, 2673470, 2673471, 2673472, 2673473, 2673474, 2673475, 2673476, 2673477, 2673478, 2673479, 2673480, 2673481, 2673482, 2673483, 2673484, 2673485, 2673486, 2673487, 2673488, 2673489, 2673490, 2673491, 2673492, 2673493, 2673494, 2673495, 2673496, 2673497, 2673498, 2673499]
kernel_rfl D1StageSplit.gjk1 : D1StageSplit.s20.heap = Stage.setAll D1StageSplit.s1.heap (D1StageSplit.gjh1.filterMap fun a => (D1StageSplit.s20.heap.get a).map (a, ·))
kernel_rfl D1StageSplit.gjbd1 : D1StageSplit.gjh1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl D1StageSplit.gjc1 : Conv.jcleanListB (⟨18156, 15236, 2673500, 17⟩ : Conv.Cnt) D1StageSplit.s20 D1StageSplit.gjh1 = true
theorem D1StageSplit.gjcl1 (h : Conv.JClean (⟨18155, 15235, 2673470, 17⟩ : Conv.Cnt) D1StageSplit.s1) : Conv.JClean (⟨18156, 15236, 2673500, 17⟩ : Conv.Cnt) D1StageSplit.s20 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB D1StageSplit.gle1)
    (Conv.heap_off_setAll D1StageSplit.gjk1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp D1StageSplit.gjbd1 a ha)) D1StageSplit.gjc1

end Host.Load.Run.Tpl
