import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC35
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl35`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl35 : List Nat := [2665, 2673467, 2702205]
def PRE_first_tail_x15_r0_body.clo35 : List Nat := []
def PRE_first_tail_x15_r0_body.cln35 : List Nat := []
def PRE_first_tail_x15_r0_body.cli35 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap35 : PRE_first_tail_x15_r0_body.s346.heap = Stage.setAll PRE_first_tail_x15_r0_body.s344.heap (PRE_first_tail_x15_r0_body.cl35.filterMap fun a => (PRE_first_tail_x15_r0_body.s346.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe35 : Nat.ble PRE_first_tail_x15_r0_body.s344.next PRE_first_tail_x15_r0_body.s346.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP35 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s344 PRE_first_tail_x15_r0_body.s346 PRE_first_tail_x15_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp35 : Conv.suppListB PRE_first_tail_x15_r0_body.s346 1549 PRE_first_tail_x15_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound35 : Conv.boundListB PRE_first_tail_x15_r0_body.s346 PRE_first_tail_x15_r0_body.cl35 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK35 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s344.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln35.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK35 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s344.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo35.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK35 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s344.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli35.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst35 : Conv.sstListB 1549 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx PRE_first_tail_x15_r0_body.cln35 PRE_first_tail_x15_r0_body.clo35 PRE_first_tail_x15_r0_body.cli35 = true

end Host.Load.Run.Tpl
