import host.sim.template.a4pre_first_tail_x15_r0_body.st36.H0
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st36`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st36.wrR : List (Nat × Nat) := [(2672393, 2672394), (2702877, 2702878), (2703422, 2703423), (2703678, 2703679)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st36.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st36.s3.heap PRE_first_tail_x15_r0_body.st36.wrR ++ freshOf PRE_first_tail_x15_r0_body.st36.s3.heap PRE_first_tail_x15_r0_body.st36.s0.next PRE_first_tail_x15_r0_body.st36.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st36.wr : List Nat := PRE_first_tail_x15_r0_body.st36.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st36.heapFoot : PRE_first_tail_x15_r0_body.st36.s3.heap = setAll PRE_first_tail_x15_r0_body.st36.s0.heap PRE_first_tail_x15_r0_body.st36.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st36.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st36.s0.next PRE_first_tail_x15_r0_body.st36.s3.next = true
theorem PRE_first_tail_x15_r0_body.st36.grows : PRE_first_tail_x15_r0_body.st36.s0.next ≤ PRE_first_tail_x15_r0_body.st36.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st36.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st36.wh : List Nat := [18904, 18917, 18923, 18924, 18925, 18926, 18927, 18928, 18929, 18930, 18931, 18932, 18933, 18934, 18935, 18936, 18937, 18938, 18939, 18940, 18941, 18942, 18943, 18944, 18945, 18946, 18947, 18948, 18949, 18950, 18951]
def PRE_first_tail_x15_r0_body.st36.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st36.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st36.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st36.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st36.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st36.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st36.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st36.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st36.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st36.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
