import host.sim.template.a4dec_grow.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 3 of chain `DEC_grow` (boundaries 10 to 11): the native bookkeeping's step. -/

def DEC_grow.gh3 : List Nat := []
def DEC_grow.gn3 : List Nat := []
def DEC_grow.gi3 : List Nat := []
kernel_rfl DEC_grow.gkA3 : (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.arrs (DEC_grow.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_grow.gkO3 : (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.objs (DEC_grow.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_grow.gkN3 : (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.nodes (DEC_grow.gn3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_grow.gkI3 : (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.items (DEC_grow.gi3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_grow.gbd3 : (DEC_grow.gh3 ++ DEC_grow.gn3 ++ DEC_grow.gi3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.gle3 : Conv.Cnt.leB (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) = true
kernel_rfl DEC_grow.gck3 : Conv.ncleanListB (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx DEC_grow.gh3 DEC_grow.gn3 DEC_grow.gi3 = true
theorem DEC_grow.gncl3 (h : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx) : Conv.NClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s11.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_grow.gle3 DEC_grow.gkA3 DEC_grow.gkO3 DEC_grow.gkN3 DEC_grow.gkI3 DEC_grow.gbd3 DEC_grow.gck3

-- the JS bookkeeping's step
def DEC_grow.gjh3 : List Nat := []
kernel_rfl DEC_grow.gjk3 : DEC_grow.s11.heap = Stage.setAll DEC_grow.s10.heap (DEC_grow.gjh3.filterMap fun a => (DEC_grow.s11.heap.get a).map (a, ·))
kernel_rfl DEC_grow.gjbd3 : DEC_grow.gjh3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_grow.gjc3 : Conv.jcleanListB (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s11 DEC_grow.gjh3 = true
theorem DEC_grow.gjcl3 (h : Conv.JClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s10) : Conv.JClean (⟨29440, 24984, 3124247, 386⟩ : Conv.Cnt) DEC_grow.s11 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_grow.gle3)
    (Conv.heap_off_setAll DEC_grow.gjk3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_grow.gjbd3 a ha)) DEC_grow.gjc3

end Host.Load.Run.Tpl
