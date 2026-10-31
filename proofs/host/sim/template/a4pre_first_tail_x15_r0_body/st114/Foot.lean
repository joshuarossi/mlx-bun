import host.sim.template.a4pre_first_tail_x15_r0_body.st114.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st114`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st114.wrR : List (Nat × Nat) := [(2672589, 2672590), (2763897, 2763898), (2764442, 2764443), (2764698, 2764699)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st114.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st114.s3.heap PRE_first_tail_x15_r0_body.st114.wrR ++ freshOf PRE_first_tail_x15_r0_body.st114.s3.heap PRE_first_tail_x15_r0_body.st114.s0.next PRE_first_tail_x15_r0_body.st114.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st114.wr : List Nat := PRE_first_tail_x15_r0_body.st114.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st114.heapFoot : PRE_first_tail_x15_r0_body.st114.s3.heap = setAll PRE_first_tail_x15_r0_body.st114.s0.heap PRE_first_tail_x15_r0_body.st114.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st114.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st114.s0.next PRE_first_tail_x15_r0_body.st114.s3.next = true
theorem PRE_first_tail_x15_r0_body.st114.grows : PRE_first_tail_x15_r0_body.st114.s0.next ≤ PRE_first_tail_x15_r0_body.st114.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st114.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st114.wh : List Nat := [20434, 20447, 20453, 20454, 20455, 20456, 20457, 20458, 20459, 20460, 20461, 20462, 20463, 20464, 20465, 20466, 20467, 20468, 20469, 20470, 20471, 20472, 20473, 20474, 20475, 20476, 20477, 20478, 20479, 20480, 20481]
def PRE_first_tail_x15_r0_body.st114.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st114.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st114.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st114.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st114.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st114.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st114.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st114.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st114.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st114.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
