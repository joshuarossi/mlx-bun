import host.sim.template.a4pre_setup_h4_chunk.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 1 of chain `PRE_setup_h4_chunk` (boundaries 2 to 3): the native bookkeeping's step. -/

def PRE_setup_h4_chunk.gh1 : List Nat := []
def PRE_setup_h4_chunk.gn1 : List Nat := []
def PRE_setup_h4_chunk.gi1 : List Nat := []
kernel_rfl PRE_setup_h4_chunk.gkA1 : (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s2.ffi).mlx.arrs (PRE_setup_h4_chunk.gh1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_setup_h4_chunk.gkO1 : (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s2.ffi).mlx.objs (PRE_setup_h4_chunk.gh1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_setup_h4_chunk.gkN1 : (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s2.ffi).mlx.nodes (PRE_setup_h4_chunk.gn1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_setup_h4_chunk.gkI1 : (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s2.ffi).mlx.items (PRE_setup_h4_chunk.gi1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_setup_h4_chunk.gbd1 : (PRE_setup_h4_chunk.gh1 ++ PRE_setup_h4_chunk.gn1 ++ PRE_setup_h4_chunk.gi1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_h4_chunk.gle1 : Conv.Cnt.leB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) = true
kernel_rfl PRE_setup_h4_chunk.gck1 : Conv.ncleanListB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx PRE_setup_h4_chunk.gh1 PRE_setup_h4_chunk.gn1 PRE_setup_h4_chunk.gi1 = true
theorem PRE_setup_h4_chunk.gncl1 (h : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s2.ffi).mlx) : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h4_chunk.s3.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_setup_h4_chunk.gle1 PRE_setup_h4_chunk.gkA1 PRE_setup_h4_chunk.gkO1 PRE_setup_h4_chunk.gkN1 PRE_setup_h4_chunk.gkI1 PRE_setup_h4_chunk.gbd1 PRE_setup_h4_chunk.gck1

-- the JS bookkeeping's step
def PRE_setup_h4_chunk.gjh1 : List Nat := []
kernel_rfl PRE_setup_h4_chunk.gjk1 : PRE_setup_h4_chunk.s3.heap = Stage.setAll PRE_setup_h4_chunk.s2.heap (PRE_setup_h4_chunk.gjh1.filterMap fun a => (PRE_setup_h4_chunk.s3.heap.get a).map (a, ·))
kernel_rfl PRE_setup_h4_chunk.gjbd1 : PRE_setup_h4_chunk.gjh1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_h4_chunk.gjc1 : Conv.jcleanListB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h4_chunk.s3 PRE_setup_h4_chunk.gjh1 = true
theorem PRE_setup_h4_chunk.gjcl1 (h : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h4_chunk.s2) : Conv.JClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) PRE_setup_h4_chunk.s3 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_setup_h4_chunk.gle1)
    (Conv.heap_off_setAll PRE_setup_h4_chunk.gjk1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_h4_chunk.gjbd1 a ha)) PRE_setup_h4_chunk.gjc1

end Host.Load.Run.Tpl
