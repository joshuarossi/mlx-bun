import host.sim.template.a4pre_first_tail_x15_r0_body.st24.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st24`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st24.wrR : List (Nat × Nat) := [(2672362, 2672363), (2693461, 2693462), (2694006, 2694007), (2694262, 2694263)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st24.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st24.s3.heap PRE_first_tail_x15_r0_body.st24.wrR ++ freshOf PRE_first_tail_x15_r0_body.st24.s3.heap PRE_first_tail_x15_r0_body.st24.s0.next PRE_first_tail_x15_r0_body.st24.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st24.wr : List Nat := PRE_first_tail_x15_r0_body.st24.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st24.heapFoot : PRE_first_tail_x15_r0_body.st24.s3.heap = setAll PRE_first_tail_x15_r0_body.st24.s0.heap PRE_first_tail_x15_r0_body.st24.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st24.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st24.s0.next PRE_first_tail_x15_r0_body.st24.s3.next = true
theorem PRE_first_tail_x15_r0_body.st24.grows : PRE_first_tail_x15_r0_body.st24.s0.next ≤ PRE_first_tail_x15_r0_body.st24.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st24.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st24.wh : List Nat := [18668, 18681, 18687, 18688, 18689, 18690, 18691, 18692, 18693, 18694, 18695, 18696, 18697, 18698, 18699, 18700, 18701, 18702, 18703, 18704, 18705, 18706, 18707, 18708, 18709, 18710, 18711, 18712, 18713, 18714, 18715]
def PRE_first_tail_x15_r0_body.st24.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st24.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st24.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st24.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st24.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st24.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st24.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st24.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st24.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st24.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
