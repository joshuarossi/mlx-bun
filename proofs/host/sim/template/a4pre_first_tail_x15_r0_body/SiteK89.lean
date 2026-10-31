import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC89
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl89`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl89 : List Nat := [2665, 2673467, 2744411]
def PRE_first_tail_x15_r0_body.clo89 : List Nat := []
def PRE_first_tail_x15_r0_body.cln89 : List Nat := []
def PRE_first_tail_x15_r0_body.cli89 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap89 : PRE_first_tail_x15_r0_body.s864.heap = Stage.setAll PRE_first_tail_x15_r0_body.s862.heap (PRE_first_tail_x15_r0_body.cl89.filterMap fun a => (PRE_first_tail_x15_r0_body.s864.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe89 : Nat.ble PRE_first_tail_x15_r0_body.s862.next PRE_first_tail_x15_r0_body.s864.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP89 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s862 PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp89 : Conv.suppListB PRE_first_tail_x15_r0_body.s864 3859 PRE_first_tail_x15_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound89 : Conv.boundListB PRE_first_tail_x15_r0_body.s864 PRE_first_tail_x15_r0_body.cl89 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK89 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln89.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK89 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo89.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK89 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s862.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli89.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst89 : Conv.sstListB 3859 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s864.ffi).mlx PRE_first_tail_x15_r0_body.cln89 PRE_first_tail_x15_r0_body.clo89 PRE_first_tail_x15_r0_body.cli89 = true

end Host.Load.Run.Tpl
