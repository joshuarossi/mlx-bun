import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC178
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl178`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl178 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo178 : List Nat := []
def PRE_first_tail_x15_r0_body.cln178 : List Nat := []
def PRE_first_tail_x15_r0_body.cli178 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap178 : PRE_first_tail_x15_r0_body.s1571.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1569.heap (PRE_first_tail_x15_r0_body.cl178.filterMap fun a => (PRE_first_tail_x15_r0_body.s1571.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe178 : Nat.ble PRE_first_tail_x15_r0_body.s1569.next PRE_first_tail_x15_r0_body.s1571.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP178 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1569 PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp178 : Conv.suppListB PRE_first_tail_x15_r0_body.s1571 7688 PRE_first_tail_x15_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound178 : Conv.boundListB PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.cl178 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK178 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK178 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK178 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst178 : Conv.sstListB 7688 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx PRE_first_tail_x15_r0_body.cln178 PRE_first_tail_x15_r0_body.clo178 PRE_first_tail_x15_r0_body.cli178 = true

end Host.Load.Run.Tpl
