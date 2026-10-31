import host.sim.template.a4pre_first_tail_x15_r0_body.st132.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st132`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st132.wrR : List (Nat × Nat) := [(2672641, 2672642), (2778209, 2778210), (2778754, 2778755), (2779010, 2779011)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st132.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st132.s5.heap PRE_first_tail_x15_r0_body.st132.wrR ++ freshOf PRE_first_tail_x15_r0_body.st132.s5.heap PRE_first_tail_x15_r0_body.st132.s0.next PRE_first_tail_x15_r0_body.st132.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st132.wr : List Nat := PRE_first_tail_x15_r0_body.st132.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st132.heapFoot : PRE_first_tail_x15_r0_body.st132.s5.heap = setAll PRE_first_tail_x15_r0_body.st132.s0.heap PRE_first_tail_x15_r0_body.st132.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st132.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st132.s0.next PRE_first_tail_x15_r0_body.st132.s5.next = true
theorem PRE_first_tail_x15_r0_body.st132.grows : PRE_first_tail_x15_r0_body.st132.s0.next ≤ PRE_first_tail_x15_r0_body.st132.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st132.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st132.wh : List Nat := [20792, 20805, 20811, 20812, 20813, 20814, 20815, 20816, 20817, 20818, 20819, 20820, 20821, 20822, 20823, 20824, 20825, 20826, 20827, 20828, 20829, 20830, 20831, 20832, 20833, 20834, 20835, 20836, 20837, 20838, 20839]
def PRE_first_tail_x15_r0_body.st132.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st132.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st132.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st132.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st132.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st132.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st132.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st132.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st132.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
