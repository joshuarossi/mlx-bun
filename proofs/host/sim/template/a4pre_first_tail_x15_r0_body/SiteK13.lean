import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC13
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl13`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl13 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo13 : List Nat := []
def PRE_first_tail_x15_r0_body.cln13 : List Nat := []
def PRE_first_tail_x15_r0_body.cli13 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap13 : PRE_first_tail_x15_r0_body.s141.heap = Stage.setAll PRE_first_tail_x15_r0_body.s139.heap (PRE_first_tail_x15_r0_body.cl13.filterMap fun a => (PRE_first_tail_x15_r0_body.s141.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe13 : Nat.ble PRE_first_tail_x15_r0_body.s139.next PRE_first_tail_x15_r0_body.s141.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP13 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s139 PRE_first_tail_x15_r0_body.s141 PRE_first_tail_x15_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp13 : Conv.suppListB PRE_first_tail_x15_r0_body.s141 635 PRE_first_tail_x15_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound13 : Conv.boundListB PRE_first_tail_x15_r0_body.s141 PRE_first_tail_x15_r0_body.cl13 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK13 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s139.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK13 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s139.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK13 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s139.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli13.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst13 : Conv.sstListB 635 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx PRE_first_tail_x15_r0_body.cln13 PRE_first_tail_x15_r0_body.clo13 PRE_first_tail_x15_r0_body.cli13 = true

end Host.Load.Run.Tpl
