import host.sim.template.a4pre_first_tail_x15_r0_body.st181.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st181`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st181.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st181.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st181.s2.heap PRE_first_tail_x15_r0_body.st181.wrR ++ freshOf PRE_first_tail_x15_r0_body.st181.s2.heap PRE_first_tail_x15_r0_body.st181.s0.next PRE_first_tail_x15_r0_body.st181.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st181.wr : List Nat := PRE_first_tail_x15_r0_body.st181.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st181.heapFoot : PRE_first_tail_x15_r0_body.st181.s2.heap = setAll PRE_first_tail_x15_r0_body.st181.s0.heap PRE_first_tail_x15_r0_body.st181.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st181.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st181.s0.next PRE_first_tail_x15_r0_body.st181.s2.next = true
theorem PRE_first_tail_x15_r0_body.st181.grows : PRE_first_tail_x15_r0_body.st181.s0.next ≤ PRE_first_tail_x15_r0_body.st181.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st181.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st181.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st181.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st181.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st181.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st181.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st181.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st181.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st181.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st181.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st181.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st181.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
