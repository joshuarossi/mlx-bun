import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC172
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl172`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl172 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo172 : List Nat := []
def PRE_first_tail_x15_r0_body.cln172 : List Nat := []
def PRE_first_tail_x15_r0_body.cli172 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap172 : PRE_first_tail_x15_r0_body.s1520.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1518.heap (PRE_first_tail_x15_r0_body.cl172.filterMap fun a => (PRE_first_tail_x15_r0_body.s1520.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe172 : Nat.ble PRE_first_tail_x15_r0_body.s1518.next PRE_first_tail_x15_r0_body.s1520.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP172 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1518 PRE_first_tail_x15_r0_body.s1520 PRE_first_tail_x15_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp172 : Conv.suppListB PRE_first_tail_x15_r0_body.s1520 7433 PRE_first_tail_x15_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound172 : Conv.boundListB PRE_first_tail_x15_r0_body.s1520 PRE_first_tail_x15_r0_body.cl172 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK172 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK172 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK172 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1518.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli172.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst172 : Conv.sstListB 7433 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1520.ffi).mlx PRE_first_tail_x15_r0_body.cln172 PRE_first_tail_x15_r0_body.clo172 PRE_first_tail_x15_r0_body.cli172 = true

end Host.Load.Run.Tpl
