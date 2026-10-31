import host.sim.template.a4pre_first_tail_x15_r0_body.st186.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st186`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st186.wrR : List (Nat × Nat) := [(2672775, 2672776), (2820421, 2820422), (2820966, 2820967), (2821222, 2821223)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st186.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st186.s5.heap PRE_first_tail_x15_r0_body.st186.wrR ++ freshOf PRE_first_tail_x15_r0_body.st186.s5.heap PRE_first_tail_x15_r0_body.st186.s0.next PRE_first_tail_x15_r0_body.st186.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st186.wr : List Nat := PRE_first_tail_x15_r0_body.st186.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st186.heapFoot : PRE_first_tail_x15_r0_body.st186.s5.heap = setAll PRE_first_tail_x15_r0_body.st186.s0.heap PRE_first_tail_x15_r0_body.st186.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st186.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st186.s0.next PRE_first_tail_x15_r0_body.st186.s5.next = true
theorem PRE_first_tail_x15_r0_body.st186.grows : PRE_first_tail_x15_r0_body.st186.s0.next ≤ PRE_first_tail_x15_r0_body.st186.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st186.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st186.wh : List Nat := [21850, 21863, 21869, 21870, 21871, 21872, 21873, 21874, 21875, 21876, 21877, 21878, 21879, 21880, 21881, 21882, 21883, 21884, 21885, 21886, 21887, 21888, 21889, 21890, 21891, 21892, 21893, 21894, 21895, 21896, 21897]
def PRE_first_tail_x15_r0_body.st186.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st186.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st186.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st186.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st186.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st186.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st186.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st186.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st186.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st186.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
