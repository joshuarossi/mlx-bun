import host.sim.template.a4dec_clearFill.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 3 of chain `DEC_clearFill` (boundaries 10 to 11): the native bookkeeping's step. -/

def DEC_clearFill.gh3 : List Nat := []
def DEC_clearFill.gn3 : List Nat := []
def DEC_clearFill.gi3 : List Nat := []
kernel_rfl DEC_clearFill.gkA3 : (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.arrs (DEC_clearFill.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_clearFill.gkO3 : (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.objs (DEC_clearFill.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearFill.gkN3 : (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.nodes (DEC_clearFill.gn3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearFill.gkI3 : (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx.items (DEC_clearFill.gi3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearFill.gbd3 : (DEC_clearFill.gh3 ++ DEC_clearFill.gn3 ++ DEC_clearFill.gi3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.gle3 : Conv.Cnt.leB (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) = true
kernel_rfl DEC_clearFill.gck3 : Conv.ncleanListB (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx DEC_clearFill.gh3 DEC_clearFill.gn3 DEC_clearFill.gi3 = true
theorem DEC_clearFill.gncl3 (h : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s10.ffi).mlx) : Conv.NClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_clearFill.gle3 DEC_clearFill.gkA3 DEC_clearFill.gkO3 DEC_clearFill.gkN3 DEC_clearFill.gkI3 DEC_clearFill.gbd3 DEC_clearFill.gck3

-- the JS bookkeeping's step
def DEC_clearFill.gjh3 : List Nat := []
kernel_rfl DEC_clearFill.gjk3 : DEC_clearFill.s11.heap = Stage.setAll DEC_clearFill.s10.heap (DEC_clearFill.gjh3.filterMap fun a => (DEC_clearFill.s11.heap.get a).map (a, ·))
kernel_rfl DEC_clearFill.gjbd3 : DEC_clearFill.gjh3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_clearFill.gjc3 : Conv.jcleanListB (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s11 DEC_clearFill.gjh3 = true
theorem DEC_clearFill.gjcl3 (h : Conv.JClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s10) : Conv.JClean (⟨29440, 24888, 3124248, 290⟩ : Conv.Cnt) DEC_clearFill.s11 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_clearFill.gle3)
    (Conv.heap_off_setAll DEC_clearFill.gjk3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_clearFill.gjbd3 a ha)) DEC_clearFill.gjc3

end Host.Load.Run.Tpl
