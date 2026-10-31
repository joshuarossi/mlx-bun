import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC191
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl191`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl191 : List Nat := [2665, 2673467, 2824653]
def PRE_first_tail_x15_r0_body.clo191 : List Nat := []
def PRE_first_tail_x15_r0_body.cln191 : List Nat := []
def PRE_first_tail_x15_r0_body.cli191 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap191 : PRE_first_tail_x15_r0_body.s1841.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1839.heap (PRE_first_tail_x15_r0_body.cl191.filterMap fun a => (PRE_first_tail_x15_r0_body.s1841.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe191 : Nat.ble PRE_first_tail_x15_r0_body.s1839.next PRE_first_tail_x15_r0_body.s1841.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP191 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1839 PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp191 : Conv.suppListB PRE_first_tail_x15_r0_body.s1841 8218 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound191 : Conv.boundListB PRE_first_tail_x15_r0_body.s1841 PRE_first_tail_x15_r0_body.cl191 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli191.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst191 : Conv.sstListB 8218 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1841.ffi).mlx PRE_first_tail_x15_r0_body.cln191 PRE_first_tail_x15_r0_body.clo191 PRE_first_tail_x15_r0_body.cli191 = true

end Host.Load.Run.Tpl
