import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC25
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl25`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl25 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo25 : List Nat := []
def PRE_first_tail_x15_r0_body.cln25 : List Nat := []
def PRE_first_tail_x15_r0_body.cli25 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap25 : PRE_first_tail_x15_r0_body.s233.heap = Stage.setAll PRE_first_tail_x15_r0_body.s231.heap (PRE_first_tail_x15_r0_body.cl25.filterMap fun a => (PRE_first_tail_x15_r0_body.s233.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe25 : Nat.ble PRE_first_tail_x15_r0_body.s231.next PRE_first_tail_x15_r0_body.s233.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP25 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.s233 PRE_first_tail_x15_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp25 : Conv.suppListB PRE_first_tail_x15_r0_body.s233 1148 PRE_first_tail_x15_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound25 : Conv.boundListB PRE_first_tail_x15_r0_body.s233 PRE_first_tail_x15_r0_body.cl25 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK25 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK25 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK25 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli25.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst25 : Conv.sstListB 1148 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s233.ffi).mlx PRE_first_tail_x15_r0_body.cln25 PRE_first_tail_x15_r0_body.clo25 PRE_first_tail_x15_r0_body.cli25 = true

end Host.Load.Run.Tpl
