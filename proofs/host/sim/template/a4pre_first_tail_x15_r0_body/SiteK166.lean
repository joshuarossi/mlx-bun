import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC166
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl166`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl166 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo166 : List Nat := []
def PRE_first_tail_x15_r0_body.cln166 : List Nat := []
def PRE_first_tail_x15_r0_body.cli166 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap166 : PRE_first_tail_x15_r0_body.s1607.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1605.heap (PRE_first_tail_x15_r0_body.cl166.filterMap fun a => (PRE_first_tail_x15_r0_body.s1607.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe166 : Nat.ble PRE_first_tail_x15_r0_body.s1605.next PRE_first_tail_x15_r0_body.s1607.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP166 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1605 PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp166 : Conv.suppListB PRE_first_tail_x15_r0_body.s1607 7175 PRE_first_tail_x15_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound166 : Conv.boundListB PRE_first_tail_x15_r0_body.s1607 PRE_first_tail_x15_r0_body.cl166 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK166 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1605.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK166 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1605.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK166 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1605.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli166.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst166 : Conv.sstListB 7175 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1607.ffi).mlx PRE_first_tail_x15_r0_body.cln166 PRE_first_tail_x15_r0_body.clo166 PRE_first_tail_x15_r0_body.cli166 = true

end Host.Load.Run.Tpl
