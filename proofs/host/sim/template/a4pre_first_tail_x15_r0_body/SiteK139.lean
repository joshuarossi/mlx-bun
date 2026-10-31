import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC139
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl139`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl139 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo139 : List Nat := []
def PRE_first_tail_x15_r0_body.cln139 : List Nat := []
def PRE_first_tail_x15_r0_body.cli139 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap139 : PRE_first_tail_x15_r0_body.s1349.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1347.heap (PRE_first_tail_x15_r0_body.cl139.filterMap fun a => (PRE_first_tail_x15_r0_body.s1349.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe139 : Nat.ble PRE_first_tail_x15_r0_body.s1347.next PRE_first_tail_x15_r0_body.s1349.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP139 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1347 PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.cl139 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp139 : Conv.suppListB PRE_first_tail_x15_r0_body.s1349 6023 PRE_first_tail_x15_r0_body.cl139 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound139 : Conv.boundListB PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.cl139 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst139 : Conv.sstListB 6023 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx PRE_first_tail_x15_r0_body.cln139 PRE_first_tail_x15_r0_body.clo139 PRE_first_tail_x15_r0_body.cli139 = true

end Host.Load.Run.Tpl
