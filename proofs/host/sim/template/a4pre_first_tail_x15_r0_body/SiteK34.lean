import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC34
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl34`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl34 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo34 : List Nat := []
def PRE_first_tail_x15_r0_body.cln34 : List Nat := []
def PRE_first_tail_x15_r0_body.cli34 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap34 : PRE_first_tail_x15_r0_body.s342.heap = Stage.setAll PRE_first_tail_x15_r0_body.s340.heap (PRE_first_tail_x15_r0_body.cl34.filterMap fun a => (PRE_first_tail_x15_r0_body.s342.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe34 : Nat.ble PRE_first_tail_x15_r0_body.s340.next PRE_first_tail_x15_r0_body.s342.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP34 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s340 PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp34 : Conv.suppListB PRE_first_tail_x15_r0_body.s342 1532 PRE_first_tail_x15_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound34 : Conv.boundListB PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.cl34 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK34 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK34 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK34 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli34.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst34 : Conv.sstListB 1532 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx PRE_first_tail_x15_r0_body.cln34 PRE_first_tail_x15_r0_body.clo34 PRE_first_tail_x15_r0_body.cli34 = true

end Host.Load.Run.Tpl
