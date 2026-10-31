import host.sim.template.a4dec_clear.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 3 of chain `DEC_clear` (boundaries 10 to 11): the native bookkeeping's step. -/

def DEC_clear.gh3 : List Nat := []
def DEC_clear.gn3 : List Nat := []
def DEC_clear.gi3 : List Nat := []
kernel_rfl DEC_clear.gkA3 : (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.arrs (DEC_clear.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clear.gkO3 : (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.objs (DEC_clear.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clear.gkN3 : (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.nodes (DEC_clear.gn3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clear.gkI3 : (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.items (DEC_clear.gi3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_clear.gbd3 : (DEC_clear.gh3 ++ DEC_clear.gn3 ++ DEC_clear.gi3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.gle3 : Conv.Cnt.leB (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) = true
kernel_rfl DEC_clear.gck3 : Conv.ncleanListB (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx DEC_clear.gh3 DEC_clear.gn3 DEC_clear.gi3 = true
theorem DEC_clear.gncl3 (h : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx) : Conv.NClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s11.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clear.gle3 DEC_clear.gkA3 DEC_clear.gkO3 DEC_clear.gkN3 DEC_clear.gkI3 DEC_clear.gbd3 DEC_clear.gck3

-- the JS bookkeeping's step
def DEC_clear.gjh3 : List Nat := []
kernel_rfl DEC_clear.gjk3 : DEC_clear.s11.heap = Stage.setAll DEC_clear.s10.heap (DEC_clear.gjh3.filterMap fun a => (DEC_clear.s11.heap.get a).map (a, ·))
kernel_rfl DEC_clear.gjbd3 : DEC_clear.gjh3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clear.gjc3 : Conv.jcleanListB (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s11 DEC_clear.gjh3 = true
theorem DEC_clear.gjcl3 (h : Conv.JClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s10) : Conv.JClean (⟨29440, 24920, 3124248, 354⟩ : Conv.Cnt) DEC_clear.s11 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clear.gle3)
    (Conv.heap_off_setAll DEC_clear.gjk3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clear.gjbd3 a ha)) DEC_clear.gjc3

end Host.Load.Run.Tpl
