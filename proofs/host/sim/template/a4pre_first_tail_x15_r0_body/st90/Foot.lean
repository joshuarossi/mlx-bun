import host.sim.template.a4pre_first_tail_x15_r0_body.st90.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st90`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st90.wrR : List (Nat × Nat) := [(2672527, 2672528), (2745061, 2745062), (2745606, 2745607), (2745862, 2745863)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st90.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st90.s3.heap PRE_first_tail_x15_r0_body.st90.wrR ++ freshOf PRE_first_tail_x15_r0_body.st90.s3.heap PRE_first_tail_x15_r0_body.st90.s0.next PRE_first_tail_x15_r0_body.st90.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st90.wr : List Nat := PRE_first_tail_x15_r0_body.st90.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st90.heapFoot : PRE_first_tail_x15_r0_body.st90.s3.heap = setAll PRE_first_tail_x15_r0_body.st90.s0.heap PRE_first_tail_x15_r0_body.st90.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st90.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st90.s0.next PRE_first_tail_x15_r0_body.st90.s3.next = true
theorem PRE_first_tail_x15_r0_body.st90.grows : PRE_first_tail_x15_r0_body.st90.s0.next ≤ PRE_first_tail_x15_r0_body.st90.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st90.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st90.wh : List Nat := [19962, 19975, 19981, 19982, 19983, 19984, 19985, 19986, 19987, 19988, 19989, 19990, 19991, 19992, 19993, 19994, 19995, 19996, 19997, 19998, 19999, 20000, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009]
def PRE_first_tail_x15_r0_body.st90.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st90.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st90.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st90.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st90.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st90.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st90.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st90.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st90.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st90.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
