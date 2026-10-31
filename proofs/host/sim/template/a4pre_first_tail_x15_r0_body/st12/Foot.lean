import host.sim.template.a4pre_first_tail_x15_r0_body.st12.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st12`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st12.wrR : List (Nat × Nat) := [(2672331, 2672332), (2684049, 2684050), (2684594, 2684595), (2684850, 2684851)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st12.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st12.s5.heap PRE_first_tail_x15_r0_body.st12.wrR ++ freshOf PRE_first_tail_x15_r0_body.st12.s5.heap PRE_first_tail_x15_r0_body.st12.s0.next PRE_first_tail_x15_r0_body.st12.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st12.wr : List Nat := PRE_first_tail_x15_r0_body.st12.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st12.heapFoot : PRE_first_tail_x15_r0_body.st12.s5.heap = setAll PRE_first_tail_x15_r0_body.st12.s0.heap PRE_first_tail_x15_r0_body.st12.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st12.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st12.s0.next PRE_first_tail_x15_r0_body.st12.s5.next = true
theorem PRE_first_tail_x15_r0_body.st12.grows : PRE_first_tail_x15_r0_body.st12.s0.next ≤ PRE_first_tail_x15_r0_body.st12.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st12.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st12.wh : List Nat := [18432, 18445, 18451, 18452, 18453, 18454, 18455, 18456, 18457, 18458, 18459, 18460, 18461, 18462, 18463, 18464, 18465, 18466, 18467, 18468, 18469, 18470, 18471, 18472, 18473, 18474, 18475, 18476, 18477, 18478, 18479]
def PRE_first_tail_x15_r0_body.st12.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st12.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st12.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st12.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st12.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st12.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st12.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st12.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st12.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st12.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
