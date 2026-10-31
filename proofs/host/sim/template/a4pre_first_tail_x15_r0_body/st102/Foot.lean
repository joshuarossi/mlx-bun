import host.sim.template.a4pre_first_tail_x15_r0_body.st102.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st102`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st102.wrR : List (Nat × Nat) := [(2672558, 2672559), (2754485, 2754486), (2755030, 2755031), (2755286, 2755287)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st102.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st102.s3.heap PRE_first_tail_x15_r0_body.st102.wrR ++ freshOf PRE_first_tail_x15_r0_body.st102.s3.heap PRE_first_tail_x15_r0_body.st102.s0.next PRE_first_tail_x15_r0_body.st102.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st102.wr : List Nat := PRE_first_tail_x15_r0_body.st102.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st102.heapFoot : PRE_first_tail_x15_r0_body.st102.s3.heap = setAll PRE_first_tail_x15_r0_body.st102.s0.heap PRE_first_tail_x15_r0_body.st102.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st102.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st102.s0.next PRE_first_tail_x15_r0_body.st102.s3.next = true
theorem PRE_first_tail_x15_r0_body.st102.grows : PRE_first_tail_x15_r0_body.st102.s0.next ≤ PRE_first_tail_x15_r0_body.st102.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st102.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st102.wh : List Nat := [20198, 20211, 20217, 20218, 20219, 20220, 20221, 20222, 20223, 20224, 20225, 20226, 20227, 20228, 20229, 20230, 20231, 20232, 20233, 20234, 20235, 20236, 20237, 20238, 20239, 20240, 20241, 20242, 20243, 20244, 20245]
def PRE_first_tail_x15_r0_body.st102.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st102.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st102.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st102.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st102.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st102.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st102.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st102.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st102.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st102.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
