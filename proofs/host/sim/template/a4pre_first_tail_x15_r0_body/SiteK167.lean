import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC167
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl167`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl167 : List Nat := [2665, 2673467, 2805801]
def PRE_first_tail_x15_r0_body.clo167 : List Nat := []
def PRE_first_tail_x15_r0_body.cln167 : List Nat := []
def PRE_first_tail_x15_r0_body.cli167 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap167 : PRE_first_tail_x15_r0_body.s1611.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1609.heap (PRE_first_tail_x15_r0_body.cl167.filterMap fun a => (PRE_first_tail_x15_r0_body.s1611.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe167 : Nat.ble PRE_first_tail_x15_r0_body.s1609.next PRE_first_tail_x15_r0_body.s1611.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP167 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1609 PRE_first_tail_x15_r0_body.s1611 PRE_first_tail_x15_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp167 : Conv.suppListB PRE_first_tail_x15_r0_body.s1611 7192 PRE_first_tail_x15_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound167 : Conv.boundListB PRE_first_tail_x15_r0_body.s1611 PRE_first_tail_x15_r0_body.cl167 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK167 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK167 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK167 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1609.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli167.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst167 : Conv.sstListB 7192 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1611.ffi).mlx PRE_first_tail_x15_r0_body.cln167 PRE_first_tail_x15_r0_body.clo167 PRE_first_tail_x15_r0_body.cli167 = true

end Host.Load.Run.Tpl
