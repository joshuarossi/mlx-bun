import host.sim.template.a4pre_first_tail_x15_r0_body.st3.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st3`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st3.wrR : List (Nat × Nat) := [(2672305, 2672306), (2676797, 2676798), (2677342, 2677343), (2677598, 2677599)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st3.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st3.s3.heap PRE_first_tail_x15_r0_body.st3.wrR ++ freshOf PRE_first_tail_x15_r0_body.st3.s3.heap PRE_first_tail_x15_r0_body.st3.s0.next PRE_first_tail_x15_r0_body.st3.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st3.wr : List Nat := PRE_first_tail_x15_r0_body.st3.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st3.heapFoot : PRE_first_tail_x15_r0_body.st3.s3.heap = setAll PRE_first_tail_x15_r0_body.st3.s0.heap PRE_first_tail_x15_r0_body.st3.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st3.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st3.s0.next PRE_first_tail_x15_r0_body.st3.s3.next = true
theorem PRE_first_tail_x15_r0_body.st3.grows : PRE_first_tail_x15_r0_body.st3.s0.next ≤ PRE_first_tail_x15_r0_body.st3.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st3.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st3.wh : List Nat := [18250, 18263, 18269, 18270, 18271, 18272, 18273, 18274, 18275, 18276, 18277, 18278, 18279, 18280, 18281, 18282, 18283, 18284, 18285, 18286, 18287, 18288, 18289, 18290, 18291, 18292, 18293, 18294, 18295, 18296, 18297]
def PRE_first_tail_x15_r0_body.st3.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st3.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st3.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st3.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st3.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st3.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st3.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st3.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st3.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st3.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
