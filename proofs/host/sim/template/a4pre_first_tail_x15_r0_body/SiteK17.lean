import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC17
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl17`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl17 : List Nat := [2665, 2673467, 2687915]
def PRE_first_tail_x15_r0_body.clo17 : List Nat := []
def PRE_first_tail_x15_r0_body.cln17 : List Nat := []
def PRE_first_tail_x15_r0_body.cli17 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap17 : PRE_first_tail_x15_r0_body.s174.heap = Stage.setAll PRE_first_tail_x15_r0_body.s172.heap (PRE_first_tail_x15_r0_body.cl17.filterMap fun a => (PRE_first_tail_x15_r0_body.s174.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe17 : Nat.ble PRE_first_tail_x15_r0_body.s172.next PRE_first_tail_x15_r0_body.s174.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP17 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s172 PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp17 : Conv.suppListB PRE_first_tail_x15_r0_body.s174 781 PRE_first_tail_x15_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound17 : Conv.boundListB PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.cl17 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK17 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s172.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK17 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s172.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK17 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s172.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli17.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst17 : Conv.sstListB 781 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx PRE_first_tail_x15_r0_body.cln17 PRE_first_tail_x15_r0_body.clo17 PRE_first_tail_x15_r0_body.cli17 = true

end Host.Load.Run.Tpl
