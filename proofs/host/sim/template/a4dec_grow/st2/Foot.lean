import host.sim.template.a4dec_grow.st2.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `DEC_grow.st2`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def DEC_grow.st2.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def DEC_grow.st2.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf DEC_grow.st2.s2.heap DEC_grow.st2.wrR ++ freshOf DEC_grow.st2.s2.heap DEC_grow.st2.s0.next DEC_grow.st2.s2.next
noncomputable def DEC_grow.st2.wr : List Nat := DEC_grow.st2.wrE.map (·.1)

kernel_rfl DEC_grow.st2.heapFoot : DEC_grow.st2.s2.heap = setAll DEC_grow.st2.s0.heap DEC_grow.st2.wrE
kernel_rfl DEC_grow.st2.grows_check : Nat.ble DEC_grow.st2.s0.next DEC_grow.st2.s2.next = true
theorem DEC_grow.st2.grows : DEC_grow.st2.s0.next ≤ DEC_grow.st2.s2.next := Nat.le_of_ble_eq_true DEC_grow.st2.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def DEC_grow.st2.wh : List Nat := [29440]
def DEC_grow.st2.wi : List Nat := []

kernel_rfl DEC_grow.st2.arrsFoot : (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.arrs (DEC_grow.st2.wh.filterMap fun h => ((Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl DEC_grow.st2.objsFoot : (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.objs (DEC_grow.st2.wh.filterMap fun h => ((Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl DEC_grow.st2.nodesFoot : (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.nnext)
kernel_rfl DEC_grow.st2.itemsFoot : (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.items ((DEC_grow.st2.wi.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.items (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.nnext)
kernel_rfl DEC_grow.st2.counters : (Nat.ble (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.next (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad DEC_grow.st2.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad DEC_grow.st2.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
