import host.sim.template.a4dec_fill.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 3 of chain `DEC_fill` (boundaries 10 to 11): the native bookkeeping's step. -/

def DEC_fill.gh3 : List Nat := []
def DEC_fill.gn3 : List Nat := []
def DEC_fill.gi3 : List Nat := []
kernel_rfl DEC_fill.gkA3 : (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.arrs (DEC_fill.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_fill.gkO3 : (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.objs (DEC_fill.gh3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_fill.gkN3 : (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.nodes (DEC_fill.gn3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_fill.gkI3 : (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.items (DEC_fill.gi3.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_fill.gbd3 : (DEC_fill.gh3 ++ DEC_fill.gn3 ++ DEC_fill.gi3).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.gle3 : Conv.Cnt.leB (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) = true
kernel_rfl DEC_fill.gck3 : Conv.ncleanListB (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx DEC_fill.gh3 DEC_fill.gn3 DEC_fill.gi3 = true
theorem DEC_fill.gncl3 (h : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx) : Conv.NClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s11.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_fill.gle3 DEC_fill.gkA3 DEC_fill.gkO3 DEC_fill.gkN3 DEC_fill.gkI3 DEC_fill.gbd3 DEC_fill.gck3

-- the JS bookkeeping's step
def DEC_fill.gjh3 : List Nat := []
kernel_rfl DEC_fill.gjk3 : DEC_fill.s11.heap = Stage.setAll DEC_fill.s10.heap (DEC_fill.gjh3.filterMap fun a => (DEC_fill.s11.heap.get a).map (a, ·))
kernel_rfl DEC_fill.gjbd3 : DEC_fill.gjh3.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.gjc3 : Conv.jcleanListB (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s11 DEC_fill.gjh3 = true
theorem DEC_fill.gjcl3 (h : Conv.JClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s10) : Conv.JClean (⟨29440, 24888, 3124247, 290⟩ : Conv.Cnt) DEC_fill.s11 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_fill.gle3)
    (Conv.heap_off_setAll DEC_fill.gjk3 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_fill.gjbd3 a ha)) DEC_fill.gjc3

end Host.Load.Run.Tpl
