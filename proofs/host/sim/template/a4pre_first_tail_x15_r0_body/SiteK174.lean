import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC174
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl174`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl174 : List Nat := [2665, 2672744, 2673467, 2810993, 2811538, 2811794, 2811819, 2811820, 2811821, 2811822, 2811823, 2811824]
def PRE_first_tail_x15_r0_body.clo174 : List Nat := [21614, 21627, 21633, 21634, 21635, 21636]
def PRE_first_tail_x15_r0_body.cln174 : List Nat := [18722, 18723, 18724, 18725, 18726, 18727, 18728, 18729, 18730, 18731, 18732, 18733, 18734, 18735, 18736, 18737, 18738, 18739, 18740, 18741, 18742, 18743, 18744, 18745, 18746, 18747, 18748]
def PRE_first_tail_x15_r0_body.cli174 : List Nat := [18722, 18723, 18724, 18725, 18726, 18727, 18728, 18729, 18730, 18731, 18732, 18733, 18734, 18735, 18736, 18737, 18738, 18739, 18740, 18741, 18742, 18743, 18744, 18745, 18746, 18747, 18748]
kernel_rfl PRE_first_tail_x15_r0_body.cheap174 : PRE_first_tail_x15_r0_body.s1540.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1538.heap (PRE_first_tail_x15_r0_body.cl174.filterMap fun a => (PRE_first_tail_x15_r0_body.s1540.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe174 : Nat.ble PRE_first_tail_x15_r0_body.s1538.next PRE_first_tail_x15_r0_body.s1540.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP174 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1538 PRE_first_tail_x15_r0_body.s1540 PRE_first_tail_x15_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp174 : Conv.suppListB PRE_first_tail_x15_r0_body.s1540 7541 PRE_first_tail_x15_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound174 : Conv.boundListB PRE_first_tail_x15_r0_body.s1540 PRE_first_tail_x15_r0_body.cl174 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK174 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1538.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK174 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1538.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK174 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1538.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli174.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst174 : Conv.sstListB 7541 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1540.ffi).mlx PRE_first_tail_x15_r0_body.cln174 PRE_first_tail_x15_r0_body.clo174 PRE_first_tail_x15_r0_body.cli174 = true

end Host.Load.Run.Tpl
