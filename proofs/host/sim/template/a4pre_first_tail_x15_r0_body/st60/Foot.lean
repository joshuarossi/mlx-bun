import host.sim.template.a4pre_first_tail_x15_r0_body.st60.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st60`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st60.wrR : List (Nat × Nat) := [(2672455, 2672456), (2721721, 2721722), (2722266, 2722267), (2722522, 2722523)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st60.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st60.s3.heap PRE_first_tail_x15_r0_body.st60.wrR ++ freshOf PRE_first_tail_x15_r0_body.st60.s3.heap PRE_first_tail_x15_r0_body.st60.s0.next PRE_first_tail_x15_r0_body.st60.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st60.wr : List Nat := PRE_first_tail_x15_r0_body.st60.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st60.heapFoot : PRE_first_tail_x15_r0_body.st60.s3.heap = setAll PRE_first_tail_x15_r0_body.st60.s0.heap PRE_first_tail_x15_r0_body.st60.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st60.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st60.s0.next PRE_first_tail_x15_r0_body.st60.s3.next = true
theorem PRE_first_tail_x15_r0_body.st60.grows : PRE_first_tail_x15_r0_body.st60.s0.next ≤ PRE_first_tail_x15_r0_body.st60.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st60.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st60.wh : List Nat := [19376, 19389, 19395, 19396, 19397, 19398, 19399, 19400, 19401, 19402, 19403, 19404, 19405, 19406, 19407, 19408, 19409, 19410, 19411, 19412, 19413, 19414, 19415, 19416, 19417, 19418, 19419, 19420, 19421, 19422, 19423]
def PRE_first_tail_x15_r0_body.st60.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st60.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st60.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st60.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st60.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st60.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st60.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st60.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st60.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st60.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
