import host.sim.template.a4pre_first_tail_x15_r0_body.st99.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st99`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st99.wrR : List (Nat × Nat) := [(2672553, 2672554), (2752225, 2752226), (2752770, 2752771), (2753026, 2753027)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st99.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st99.s3.heap PRE_first_tail_x15_r0_body.st99.wrR ++ freshOf PRE_first_tail_x15_r0_body.st99.s3.heap PRE_first_tail_x15_r0_body.st99.s0.next PRE_first_tail_x15_r0_body.st99.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st99.wr : List Nat := PRE_first_tail_x15_r0_body.st99.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st99.heapFoot : PRE_first_tail_x15_r0_body.st99.s3.heap = setAll PRE_first_tail_x15_r0_body.st99.s0.heap PRE_first_tail_x15_r0_body.st99.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st99.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st99.s0.next PRE_first_tail_x15_r0_body.st99.s3.next = true
theorem PRE_first_tail_x15_r0_body.st99.grows : PRE_first_tail_x15_r0_body.st99.s0.next ≤ PRE_first_tail_x15_r0_body.st99.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st99.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st99.wh : List Nat := [20141, 20154, 20160, 20161, 20162, 20163, 20164, 20165, 20166, 20167, 20168, 20169, 20170, 20171, 20172, 20173, 20174, 20175, 20176, 20177, 20178, 20179, 20180, 20181, 20182, 20183, 20184, 20185, 20186, 20187, 20188]
def PRE_first_tail_x15_r0_body.st99.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st99.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st99.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st99.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st99.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st99.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st99.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st99.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st99.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st99.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
