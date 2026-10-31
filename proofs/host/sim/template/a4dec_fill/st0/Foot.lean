import host.sim.template.a4dec_fill.st0.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `DEC_fill.st0`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def DEC_fill.st0.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def DEC_fill.st0.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf DEC_fill.st0.s2.heap DEC_fill.st0.wrR ++ freshOf DEC_fill.st0.s2.heap DEC_fill.st0.s0.next DEC_fill.st0.s2.next
noncomputable def DEC_fill.st0.wr : List Nat := DEC_fill.st0.wrE.map (·.1)

kernel_rfl DEC_fill.st0.heapFoot : DEC_fill.st0.s2.heap = setAll DEC_fill.st0.s0.heap DEC_fill.st0.wrE
kernel_rfl DEC_fill.st0.grows_check : Nat.ble DEC_fill.st0.s0.next DEC_fill.st0.s2.next = true
theorem DEC_fill.st0.grows : DEC_fill.st0.s0.next ≤ DEC_fill.st0.s2.next := Nat.le_of_ble_eq_true DEC_fill.st0.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def DEC_fill.st0.wh : List Nat := []
def DEC_fill.st0.wi : List Nat := [20157]

kernel_rfl DEC_fill.st0.arrsFoot : (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.arrs (DEC_fill.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl DEC_fill.st0.objsFoot : (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.objs (DEC_fill.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl DEC_fill.st0.nodesFoot : (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.nnext)
kernel_rfl DEC_fill.st0.itemsFoot : (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.items ((DEC_fill.st0.wi.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.items (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.nnext)
kernel_rfl DEC_fill.st0.counters : (Nat.ble (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.next (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_fill.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad DEC_fill.st0.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
