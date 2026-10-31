import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC59
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl59`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl59 : List Nat := [2665, 2673467, 2721053]
def PRE_first_tail_x15_r0_body.clo59 : List Nat := []
def PRE_first_tail_x15_r0_body.cln59 : List Nat := []
def PRE_first_tail_x15_r0_body.cli59 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap59 : PRE_first_tail_x15_r0_body.s576.heap = Stage.setAll PRE_first_tail_x15_r0_body.s574.heap (PRE_first_tail_x15_r0_body.cl59.filterMap fun a => (PRE_first_tail_x15_r0_body.s576.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe59 : Nat.ble PRE_first_tail_x15_r0_body.s574.next PRE_first_tail_x15_r0_body.s576.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP59 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s574 PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.cl59 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp59 : Conv.suppListB PRE_first_tail_x15_r0_body.s576 2575 PRE_first_tail_x15_r0_body.cl59 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound59 : Conv.boundListB PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.cl59 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli59.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst59 : Conv.sstListB 2575 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx PRE_first_tail_x15_r0_body.cln59 PRE_first_tail_x15_r0_body.clo59 PRE_first_tail_x15_r0_body.cli59 = true

end Host.Load.Run.Tpl
