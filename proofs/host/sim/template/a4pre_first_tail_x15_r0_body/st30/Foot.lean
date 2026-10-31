import host.sim.template.a4pre_first_tail_x15_r0_body.st30.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st30`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st30.wrR : List (Nat × Nat) := [(2672372, 2672373), (2697973, 2697974), (2698518, 2698519), (2698774, 2698775)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st30.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st30.s5.heap PRE_first_tail_x15_r0_body.st30.wrR ++ freshOf PRE_first_tail_x15_r0_body.st30.s5.heap PRE_first_tail_x15_r0_body.st30.s0.next PRE_first_tail_x15_r0_body.st30.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st30.wr : List Nat := PRE_first_tail_x15_r0_body.st30.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st30.heapFoot : PRE_first_tail_x15_r0_body.st30.s5.heap = setAll PRE_first_tail_x15_r0_body.st30.s0.heap PRE_first_tail_x15_r0_body.st30.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st30.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st30.s0.next PRE_first_tail_x15_r0_body.st30.s5.next = true
theorem PRE_first_tail_x15_r0_body.st30.grows : PRE_first_tail_x15_r0_body.st30.s0.next ≤ PRE_first_tail_x15_r0_body.st30.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st30.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st30.wh : List Nat := [18782, 18795, 18801, 18802, 18803, 18804, 18805, 18806, 18807, 18808, 18809, 18810, 18811, 18812, 18813, 18814, 18815, 18816, 18817, 18818, 18819, 18820, 18821, 18822, 18823, 18824, 18825, 18826, 18827, 18828, 18829]
def PRE_first_tail_x15_r0_body.st30.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st30.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st30.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st30.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st30.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st30.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st30.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st30.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st30.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st30.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
