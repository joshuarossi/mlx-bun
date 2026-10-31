import host.sim.template.a4pre_first_tail_x15_r0_body.st150.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st150`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st150.wrR : List (Nat × Nat) := [(2672682, 2672683), (2792153, 2792154), (2792698, 2792699), (2792954, 2792955)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st150.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st150.s5.heap PRE_first_tail_x15_r0_body.st150.wrR ++ freshOf PRE_first_tail_x15_r0_body.st150.s5.heap PRE_first_tail_x15_r0_body.st150.s0.next PRE_first_tail_x15_r0_body.st150.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st150.wr : List Nat := PRE_first_tail_x15_r0_body.st150.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st150.heapFoot : PRE_first_tail_x15_r0_body.st150.s5.heap = setAll PRE_first_tail_x15_r0_body.st150.s0.heap PRE_first_tail_x15_r0_body.st150.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st150.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st150.s0.next PRE_first_tail_x15_r0_body.st150.s5.next = true
theorem PRE_first_tail_x15_r0_body.st150.grows : PRE_first_tail_x15_r0_body.st150.s0.next ≤ PRE_first_tail_x15_r0_body.st150.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st150.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st150.wh : List Nat := [21142, 21155, 21161, 21162, 21163, 21164, 21165, 21166, 21167, 21168, 21169, 21170, 21171, 21172, 21173, 21174, 21175, 21176, 21177, 21178, 21179, 21180, 21181, 21182, 21183, 21184, 21185, 21186, 21187, 21188, 21189]
def PRE_first_tail_x15_r0_body.st150.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st150.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st150.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st150.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st150.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st150.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st150.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st150.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st150.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st150.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
