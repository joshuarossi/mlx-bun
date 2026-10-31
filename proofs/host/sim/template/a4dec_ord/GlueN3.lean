import host.sim.template.a4dec_ord.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 3 of chain `DEC_ord` (boundaries 10 to 11): the native bookkeeping's step. -/

def DEC_ord.gh3 : List Nat := []
def DEC_ord.gn3 : List Nat := []
def DEC_ord.gi3 : List Nat := []
kernel_rfl DEC_ord.gkA3 : (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.arrs (DEC_ord.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_ord.gkO3 : (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.objs (DEC_ord.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_ord.gkN3 : (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.nodes (DEC_ord.gn3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_ord.gkI3 : (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.items (DEC_ord.gi3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_ord.gbd3 : (DEC_ord.gh3 ++ DEC_ord.gn3 ++ DEC_ord.gi3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.gle3 : Conv.Cnt.leB (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) = true
kernel_rfl DEC_ord.gck3 : Conv.ncleanListB (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx DEC_ord.gh3 DEC_ord.gn3 DEC_ord.gi3 = true
theorem DEC_ord.gncl3 (h : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx) : Conv.NClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s11.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_ord.gle3 DEC_ord.gkA3 DEC_ord.gkO3 DEC_ord.gkN3 DEC_ord.gkI3 DEC_ord.gbd3 DEC_ord.gck3

-- the JS bookkeeping's step
def DEC_ord.gjh3 : List Nat := []
kernel_rfl DEC_ord.gjk3 : DEC_ord.s11.heap = Stage.setAll DEC_ord.s10.heap (DEC_ord.gjh3.filterMap fun a => (DEC_ord.s11.heap.get a).map (a, ·))
kernel_rfl DEC_ord.gjbd3 : DEC_ord.gjh3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_ord.gjc3 : Conv.jcleanListB (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s11 DEC_ord.gjh3 = true
theorem DEC_ord.gjcl3 (h : Conv.JClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s10) : Conv.JClean (⟨29440, 24920, 3124247, 354⟩ : Conv.Cnt) DEC_ord.s11 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_ord.gle3)
    (Conv.heap_off_setAll DEC_ord.gjk3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_ord.gjbd3 a ha)) DEC_ord.gjc3

end Host.Load.Run.Tpl
