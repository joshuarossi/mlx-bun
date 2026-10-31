import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC83
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl83`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl83 : List Nat := [2665, 2673467, 2739877]
def PRE_first_tail_x15_r0_body.clo83 : List Nat := []
def PRE_first_tail_x15_r0_body.cln83 : List Nat := []
def PRE_first_tail_x15_r0_body.cli83 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap83 : PRE_first_tail_x15_r0_body.s735.heap = Stage.setAll PRE_first_tail_x15_r0_body.s733.heap (PRE_first_tail_x15_r0_body.cl83.filterMap fun a => (PRE_first_tail_x15_r0_body.s735.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe83 : Nat.ble PRE_first_tail_x15_r0_body.s733.next PRE_first_tail_x15_r0_body.s735.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP83 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s733 PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp83 : Conv.suppListB PRE_first_tail_x15_r0_body.s735 3601 PRE_first_tail_x15_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound83 : Conv.boundListB PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.cl83 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK83 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK83 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK83 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s733.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli83.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst83 : Conv.sstListB 3601 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s735.ffi).mlx PRE_first_tail_x15_r0_body.cln83 PRE_first_tail_x15_r0_body.clo83 PRE_first_tail_x15_r0_body.cli83 = true

end Host.Load.Run.Tpl
