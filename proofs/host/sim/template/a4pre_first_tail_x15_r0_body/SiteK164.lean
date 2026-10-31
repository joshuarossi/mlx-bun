import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC164
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl164`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl164 : List Nat := [2665, 2673467, 2803175]
def PRE_first_tail_x15_r0_body.clo164 : List Nat := []
def PRE_first_tail_x15_r0_body.cln164 : List Nat := []
def PRE_first_tail_x15_r0_body.cli164 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap164 : PRE_first_tail_x15_r0_body.s1583.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1581.heap (PRE_first_tail_x15_r0_body.cl164.filterMap fun a => (PRE_first_tail_x15_r0_body.s1583.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe164 : Nat.ble PRE_first_tail_x15_r0_body.s1581.next PRE_first_tail_x15_r0_body.s1583.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP164 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1581 PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp164 : Conv.suppListB PRE_first_tail_x15_r0_body.s1583 7066 PRE_first_tail_x15_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound164 : Conv.boundListB PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.cl164 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK164 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1581.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK164 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1581.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK164 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1581.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli164.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst164 : Conv.sstListB 7066 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx PRE_first_tail_x15_r0_body.cln164 PRE_first_tail_x15_r0_body.clo164 PRE_first_tail_x15_r0_body.cli164 = true

end Host.Load.Run.Tpl
