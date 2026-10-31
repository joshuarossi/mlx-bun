import host.sim.template.a4pre_first_tail_x15_r0_body.st27.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st27`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st27.wrR : List (Nat × Nat) := [(2672367, 2672368), (2695717, 2695718), (2696262, 2696263), (2696518, 2696519)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st27.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st27.s3.heap PRE_first_tail_x15_r0_body.st27.wrR ++ freshOf PRE_first_tail_x15_r0_body.st27.s3.heap PRE_first_tail_x15_r0_body.st27.s0.next PRE_first_tail_x15_r0_body.st27.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st27.wr : List Nat := PRE_first_tail_x15_r0_body.st27.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st27.heapFoot : PRE_first_tail_x15_r0_body.st27.s3.heap = setAll PRE_first_tail_x15_r0_body.st27.s0.heap PRE_first_tail_x15_r0_body.st27.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st27.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st27.s0.next PRE_first_tail_x15_r0_body.st27.s3.next = true
theorem PRE_first_tail_x15_r0_body.st27.grows : PRE_first_tail_x15_r0_body.st27.s0.next ≤ PRE_first_tail_x15_r0_body.st27.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st27.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st27.wh : List Nat := [18725, 18738, 18744, 18745, 18746, 18747, 18748, 18749, 18750, 18751, 18752, 18753, 18754, 18755, 18756, 18757, 18758, 18759, 18760, 18761, 18762, 18763, 18764, 18765, 18766, 18767, 18768, 18769, 18770, 18771, 18772]
def PRE_first_tail_x15_r0_body.st27.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st27.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st27.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st27.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st27.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st27.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st27.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st27.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st27.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st27.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
