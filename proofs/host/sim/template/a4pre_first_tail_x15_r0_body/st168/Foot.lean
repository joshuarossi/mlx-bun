import host.sim.template.a4pre_first_tail_x15_r0_body.st168.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st168`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st168.wrR : List (Nat × Nat) := [(2672734, 2672735), (2806473, 2806474), (2807018, 2807019), (2807274, 2807275)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st168.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st168.s3.heap PRE_first_tail_x15_r0_body.st168.wrR ++ freshOf PRE_first_tail_x15_r0_body.st168.s3.heap PRE_first_tail_x15_r0_body.st168.s0.next PRE_first_tail_x15_r0_body.st168.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st168.wr : List Nat := PRE_first_tail_x15_r0_body.st168.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st168.heapFoot : PRE_first_tail_x15_r0_body.st168.s3.heap = setAll PRE_first_tail_x15_r0_body.st168.s0.heap PRE_first_tail_x15_r0_body.st168.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st168.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st168.s0.next PRE_first_tail_x15_r0_body.st168.s3.next = true
theorem PRE_first_tail_x15_r0_body.st168.grows : PRE_first_tail_x15_r0_body.st168.s0.next ≤ PRE_first_tail_x15_r0_body.st168.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st168.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st168.wh : List Nat := [21500, 21513, 21519, 21520, 21521, 21522, 21523, 21524, 21525, 21526, 21527, 21528, 21529, 21530, 21531, 21532, 21533, 21534, 21535, 21536, 21537, 21538, 21539, 21540, 21541, 21542, 21543, 21544, 21545, 21546, 21547]
def PRE_first_tail_x15_r0_body.st168.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st168.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st168.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st168.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st168.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st168.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st168.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st168.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st168.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st168.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
