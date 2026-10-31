import host.sim.template.a4pre_first_tail_x15_r0_body.st108.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st108`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st108.wrR : List (Nat × Nat) := [(2672579, 2672580), (2759385, 2759386), (2759930, 2759931), (2760186, 2760187)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st108.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st108.s3.heap PRE_first_tail_x15_r0_body.st108.wrR ++ freshOf PRE_first_tail_x15_r0_body.st108.s3.heap PRE_first_tail_x15_r0_body.st108.s0.next PRE_first_tail_x15_r0_body.st108.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st108.wr : List Nat := PRE_first_tail_x15_r0_body.st108.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st108.heapFoot : PRE_first_tail_x15_r0_body.st108.s3.heap = setAll PRE_first_tail_x15_r0_body.st108.s0.heap PRE_first_tail_x15_r0_body.st108.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st108.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st108.s0.next PRE_first_tail_x15_r0_body.st108.s3.next = true
theorem PRE_first_tail_x15_r0_body.st108.grows : PRE_first_tail_x15_r0_body.st108.s0.next ≤ PRE_first_tail_x15_r0_body.st108.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st108.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st108.wh : List Nat := [20320, 20333, 20339, 20340, 20341, 20342, 20343, 20344, 20345, 20346, 20347, 20348, 20349, 20350, 20351, 20352, 20353, 20354, 20355, 20356, 20357, 20358, 20359, 20360, 20361, 20362, 20363, 20364, 20365, 20366, 20367]
def PRE_first_tail_x15_r0_body.st108.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st108.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st108.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st108.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st108.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st108.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st108.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st108.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st108.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st108.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
