import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC133
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl133`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl133 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo133 : List Nat := []
def PRE_first_tail_x15_r0_body.cln133 : List Nat := []
def PRE_first_tail_x15_r0_body.cli133 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap133 : PRE_first_tail_x15_r0_body.s1291.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1289.heap (PRE_first_tail_x15_r0_body.cl133.filterMap fun a => (PRE_first_tail_x15_r0_body.s1291.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe133 : Nat.ble PRE_first_tail_x15_r0_body.s1289.next PRE_first_tail_x15_r0_body.s1291.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP133 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp133 : Conv.suppListB PRE_first_tail_x15_r0_body.s1291 5765 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound133 : Conv.boundListB PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln133.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli133.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst133 : Conv.sstListB 5765 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx PRE_first_tail_x15_r0_body.cln133 PRE_first_tail_x15_r0_body.clo133 PRE_first_tail_x15_r0_body.cli133 = true

end Host.Load.Run.Tpl
