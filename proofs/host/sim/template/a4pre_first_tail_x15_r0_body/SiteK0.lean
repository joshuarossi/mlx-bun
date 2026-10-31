import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC0
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl0 : List Nat := [483, 610, 613, 1050, 1051, 1054, 1281, 2665, 4941, 2672300, 2673467, 2674071, 2674616, 2674872, 2674897, 2674898, 2674899, 2674900, 2674901, 2674902, 2674903, 2674904, 2674905, 2674906, 2674907, 2674908, 2674909, 2674910, 2674911, 2674912, 2674913, 2674914, 2674915, 2674916, 2674917, 2674918, 2674919]
def PRE_first_tail_x15_r0_body.clo0 : List Nat := [18169, 18182, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196]
def PRE_first_tail_x15_r0_body.cln0 : List Nat := [15254, 15255, 15256, 15257, 15258, 15259, 15260, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 15268, 15269, 15270, 15271, 15272, 15273, 15274, 15275, 15276, 15277, 15278, 15279, 15280, 15281, 15282, 15283, 15284, 15285, 15286, 15287, 15288, 15289, 15290, 15291, 15292, 15293, 15294, 15295]
def PRE_first_tail_x15_r0_body.cli0 : List Nat := [15254, 15255, 15256, 15257, 15258, 15259, 15260, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 15268, 15269, 15270, 15271, 15272, 15273, 15274, 15275, 15276, 15277, 15278, 15279, 15280, 15281, 15282, 15283, 15284, 15285, 15286, 15287, 15288, 15289, 15290, 15291, 15292, 15293, 15294, 15295]
kernel_rfl PRE_first_tail_x15_r0_body.cheap0 : PRE_first_tail_x15_r0_body.s17.heap = Stage.setAll PRE_first_tail_x15_r0_body.s15.heap (PRE_first_tail_x15_r0_body.cl0.filterMap fun a => (PRE_first_tail_x15_r0_body.s17.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe0 : Nat.ble PRE_first_tail_x15_r0_body.s15.next PRE_first_tail_x15_r0_body.s17.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP0 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s15 PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp0 : Conv.suppListB PRE_first_tail_x15_r0_body.s17 101 PRE_first_tail_x15_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound0 : Conv.boundListB PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s15.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s15.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s15.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst0 : Conv.sstListB 101 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s17.ffi).mlx PRE_first_tail_x15_r0_body.cln0 PRE_first_tail_x15_r0_body.clo0 PRE_first_tail_x15_r0_body.cli0 = true

end Host.Load.Run.Tpl
