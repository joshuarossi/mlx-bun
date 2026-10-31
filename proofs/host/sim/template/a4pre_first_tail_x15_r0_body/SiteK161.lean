import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC161
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl161`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl161 : List Nat := [2665, 2673467, 2800919]
def PRE_first_tail_x15_r0_body.clo161 : List Nat := []
def PRE_first_tail_x15_r0_body.cln161 : List Nat := []
def PRE_first_tail_x15_r0_body.cli161 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap161 : PRE_first_tail_x15_r0_body.s1554.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1552.heap (PRE_first_tail_x15_r0_body.cl161.filterMap fun a => (PRE_first_tail_x15_r0_body.s1554.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe161 : Nat.ble PRE_first_tail_x15_r0_body.s1552.next PRE_first_tail_x15_r0_body.s1554.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP161 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1552 PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp161 : Conv.suppListB PRE_first_tail_x15_r0_body.s1554 6937 PRE_first_tail_x15_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound161 : Conv.boundListB PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.cl161 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK161 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1552.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK161 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1552.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK161 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1552.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli161.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst161 : Conv.sstListB 6937 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1554.ffi).mlx PRE_first_tail_x15_r0_body.cln161 PRE_first_tail_x15_r0_body.clo161 PRE_first_tail_x15_r0_body.cli161 = true

end Host.Load.Run.Tpl
