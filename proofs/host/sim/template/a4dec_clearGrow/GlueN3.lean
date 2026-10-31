import host.sim.template.a4dec_clearGrow.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 3 of chain `DEC_clearGrow` (boundaries 10 to 11): the native bookkeeping's step. -/

def DEC_clearGrow.gh3 : List Nat := []
def DEC_clearGrow.gn3 : List Nat := []
def DEC_clearGrow.gi3 : List Nat := []
kernel_rfl DEC_clearGrow.gkA3 : (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.arrs (DEC_clearGrow.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.gkO3 : (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.objs (DEC_clearGrow.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.gkN3 : (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.nodes (DEC_clearGrow.gn3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearGrow.gkI3 : (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.items (DEC_clearGrow.gi3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearGrow.gbd3 : (DEC_clearGrow.gh3 ++ DEC_clearGrow.gn3 ++ DEC_clearGrow.gi3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.gle3 : Conv.Cnt.leB (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) = true
kernel_rfl DEC_clearGrow.gck3 : Conv.ncleanListB (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx DEC_clearGrow.gh3 DEC_clearGrow.gn3 DEC_clearGrow.gi3 = true
theorem DEC_clearGrow.gncl3 (h : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx) : Conv.NClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clearGrow.gle3 DEC_clearGrow.gkA3 DEC_clearGrow.gkO3 DEC_clearGrow.gkN3 DEC_clearGrow.gkI3 DEC_clearGrow.gbd3 DEC_clearGrow.gck3

-- the JS bookkeeping's step
def DEC_clearGrow.gjh3 : List Nat := []
kernel_rfl DEC_clearGrow.gjk3 : DEC_clearGrow.s11.heap = Stage.setAll DEC_clearGrow.s10.heap (DEC_clearGrow.gjh3.filterMap fun a => (DEC_clearGrow.s11.heap.get a).map (a, ·))
kernel_rfl DEC_clearGrow.gjbd3 : DEC_clearGrow.gjh3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearGrow.gjc3 : Conv.jcleanListB (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s11 DEC_clearGrow.gjh3 = true
theorem DEC_clearGrow.gjcl3 (h : Conv.JClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s10) : Conv.JClean (⟨29440, 24984, 3124248, 386⟩ : Conv.Cnt) DEC_clearGrow.s11 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clearGrow.gle3)
    (Conv.heap_off_setAll DEC_clearGrow.gjk3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearGrow.gjbd3 a ha)) DEC_clearGrow.gjc3

end Host.Load.Run.Tpl
