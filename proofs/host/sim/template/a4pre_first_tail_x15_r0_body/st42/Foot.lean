import host.sim.template.a4pre_first_tail_x15_r0_body.st42.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st42`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st42.wrR : List (Nat × Nat) := [(2672403, 2672404), (2707393, 2707394), (2707938, 2707939), (2708194, 2708195)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st42.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st42.s3.heap PRE_first_tail_x15_r0_body.st42.wrR ++ freshOf PRE_first_tail_x15_r0_body.st42.s3.heap PRE_first_tail_x15_r0_body.st42.s0.next PRE_first_tail_x15_r0_body.st42.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st42.wr : List Nat := PRE_first_tail_x15_r0_body.st42.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st42.heapFoot : PRE_first_tail_x15_r0_body.st42.s3.heap = setAll PRE_first_tail_x15_r0_body.st42.s0.heap PRE_first_tail_x15_r0_body.st42.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st42.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st42.s0.next PRE_first_tail_x15_r0_body.st42.s3.next = true
theorem PRE_first_tail_x15_r0_body.st42.grows : PRE_first_tail_x15_r0_body.st42.s0.next ≤ PRE_first_tail_x15_r0_body.st42.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st42.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st42.wh : List Nat := [19018, 19031, 19037, 19038, 19039, 19040, 19041, 19042, 19043, 19044, 19045, 19046, 19047, 19048, 19049, 19050, 19051, 19052, 19053, 19054, 19055, 19056, 19057, 19058, 19059, 19060, 19061, 19062, 19063, 19064, 19065]
def PRE_first_tail_x15_r0_body.st42.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st42.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st42.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st42.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st42.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st42.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st42.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st42.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st42.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st42.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
