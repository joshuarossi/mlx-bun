import host.sim.template.a4pre_d1_stage_split.st0.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `D1StageSplit.st0`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def D1StageSplit.st0.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def D1StageSplit.st0.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf D1StageSplit.st0.s2.heap D1StageSplit.st0.wrR ++ freshOf D1StageSplit.st0.s2.heap D1StageSplit.st0.s0.next D1StageSplit.st0.s2.next
noncomputable def D1StageSplit.st0.wr : List Nat := D1StageSplit.st0.wrE.map (·.1)

kernel_rfl D1StageSplit.st0.heapFoot : D1StageSplit.st0.s2.heap = setAll D1StageSplit.st0.s0.heap D1StageSplit.st0.wrE
kernel_rfl D1StageSplit.st0.grows_check : Nat.ble D1StageSplit.st0.s0.next D1StageSplit.st0.s2.next = true
theorem D1StageSplit.st0.grows : D1StageSplit.st0.s0.next ≤ D1StageSplit.st0.s2.next := Nat.le_of_ble_eq_true D1StageSplit.st0.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def D1StageSplit.st0.wh : List Nat := []
def D1StageSplit.st0.wi : List Nat := []

kernel_rfl D1StageSplit.st0.arrsFoot : (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.arrs (D1StageSplit.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl D1StageSplit.st0.objsFoot : (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.objs (D1StageSplit.st0.wh.filterMap fun h => ((Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl D1StageSplit.st0.nodesFoot : (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.nnext)
kernel_rfl D1StageSplit.st0.itemsFoot : (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.items ((D1StageSplit.st0.wi.filterMap fun i => ((Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.items (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.nnext)
kernel_rfl D1StageSplit.st0.counters : (Nat.ble (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.next (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad D1StageSplit.st0.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad D1StageSplit.st0.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
