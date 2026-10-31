import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC93
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl93`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl93 : List Nat := [2665, 2672539, 2673467, 2748408, 2748409, 2748410, 2748411, 2748412, 2748413, 2748414, 2748415, 2748416, 2748417, 2748418, 2748419, 2748420, 2748421, 2748422]
def PRE_first_tail_x15_r0_body.clo93 : List Nat := [20045, 20046, 20047, 20048]
def PRE_first_tail_x15_r0_body.cln93 : List Nat := [17135, 17136, 17137, 17138, 17139, 17140]
def PRE_first_tail_x15_r0_body.cli93 : List Nat := [17135, 17136, 17137, 17138, 17139, 17140]
kernel_rfl PRE_first_tail_x15_r0_body.cheap93 : PRE_first_tail_x15_r0_body.s909.heap = Stage.setAll PRE_first_tail_x15_r0_body.s907.heap (PRE_first_tail_x15_r0_body.cl93.filterMap fun a => (PRE_first_tail_x15_r0_body.s909.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe93 : Nat.ble PRE_first_tail_x15_r0_body.s907.next PRE_first_tail_x15_r0_body.s909.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP93 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s907 PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp93 : Conv.suppListB PRE_first_tail_x15_r0_body.s909 4074 PRE_first_tail_x15_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound93 : Conv.boundListB PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.cl93 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK93 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK93 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK93 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s907.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli93.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst93 : Conv.sstListB 4074 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx PRE_first_tail_x15_r0_body.cln93 PRE_first_tail_x15_r0_body.clo93 PRE_first_tail_x15_r0_body.cli93 = true

end Host.Load.Run.Tpl
