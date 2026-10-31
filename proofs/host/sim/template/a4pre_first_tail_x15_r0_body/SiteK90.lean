import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC90
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl90`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl90 : List Nat := [2665, 2672527, 2673467, 2745061, 2745606, 2745862, 2745887, 2745888, 2745889, 2745890, 2745891, 2745892]
def PRE_first_tail_x15_r0_body.clo90 : List Nat := [19962, 19975, 19981, 19982, 19983, 19984]
def PRE_first_tail_x15_r0_body.cln90 : List Nat := [17063, 17064, 17065, 17066, 17067, 17068, 17069, 17070, 17071, 17072, 17073, 17074, 17075, 17076, 17077, 17078, 17079, 17080, 17081, 17082, 17083, 17084, 17085, 17086, 17087, 17088, 17089]
def PRE_first_tail_x15_r0_body.cli90 : List Nat := [17063, 17064, 17065, 17066, 17067, 17068, 17069, 17070, 17071, 17072, 17073, 17074, 17075, 17076, 17077, 17078, 17079, 17080, 17081, 17082, 17083, 17084, 17085, 17086, 17087, 17088, 17089]
kernel_rfl PRE_first_tail_x15_r0_body.cheap90 : PRE_first_tail_x15_r0_body.s881.heap = Stage.setAll PRE_first_tail_x15_r0_body.s879.heap (PRE_first_tail_x15_r0_body.cl90.filterMap fun a => (PRE_first_tail_x15_r0_body.s881.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe90 : Nat.ble PRE_first_tail_x15_r0_body.s879.next PRE_first_tail_x15_r0_body.s881.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP90 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s879 PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp90 : Conv.suppListB PRE_first_tail_x15_r0_body.s881 3950 PRE_first_tail_x15_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound90 : Conv.boundListB PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.cl90 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK90 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s879.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK90 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s879.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK90 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s879.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli90.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst90 : Conv.sstListB 3950 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s881.ffi).mlx PRE_first_tail_x15_r0_body.cln90 PRE_first_tail_x15_r0_body.clo90 PRE_first_tail_x15_r0_body.cli90 = true

end Host.Load.Run.Tpl
