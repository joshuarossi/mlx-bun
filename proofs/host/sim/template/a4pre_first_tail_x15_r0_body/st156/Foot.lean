import host.sim.template.a4pre_first_tail_x15_r0_body.st156.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st156`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st156.wrR : List (Nat × Nat) := [(2672703, 2672704), (2797053, 2797054), (2797598, 2797599), (2797854, 2797855)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st156.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st156.s5.heap PRE_first_tail_x15_r0_body.st156.wrR ++ freshOf PRE_first_tail_x15_r0_body.st156.s5.heap PRE_first_tail_x15_r0_body.st156.s0.next PRE_first_tail_x15_r0_body.st156.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st156.wr : List Nat := PRE_first_tail_x15_r0_body.st156.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st156.heapFoot : PRE_first_tail_x15_r0_body.st156.s5.heap = setAll PRE_first_tail_x15_r0_body.st156.s0.heap PRE_first_tail_x15_r0_body.st156.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st156.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st156.s0.next PRE_first_tail_x15_r0_body.st156.s5.next = true
theorem PRE_first_tail_x15_r0_body.st156.grows : PRE_first_tail_x15_r0_body.st156.s0.next ≤ PRE_first_tail_x15_r0_body.st156.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st156.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st156.wh : List Nat := [21264, 21277, 21283, 21284, 21285, 21286, 21287, 21288, 21289, 21290, 21291, 21292, 21293, 21294, 21295, 21296, 21297, 21298, 21299, 21300, 21301, 21302, 21303, 21304, 21305, 21306, 21307, 21308, 21309, 21310, 21311]
def PRE_first_tail_x15_r0_body.st156.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st156.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st156.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st156.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st156.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st156.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st156.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st156.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st156.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st156.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
