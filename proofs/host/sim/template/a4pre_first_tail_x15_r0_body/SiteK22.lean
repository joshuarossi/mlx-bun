import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC22
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl22`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl22 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo22 : List Nat := []
def PRE_first_tail_x15_r0_body.cln22 : List Nat := []
def PRE_first_tail_x15_r0_body.cli22 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap22 : PRE_first_tail_x15_r0_body.s206.heap = Stage.setAll PRE_first_tail_x15_r0_body.s204.heap (PRE_first_tail_x15_r0_body.cl22.filterMap fun a => (PRE_first_tail_x15_r0_body.s206.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe22 : Nat.ble PRE_first_tail_x15_r0_body.s204.next PRE_first_tail_x15_r0_body.s206.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP22 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s204 PRE_first_tail_x15_r0_body.s206 PRE_first_tail_x15_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp22 : Conv.suppListB PRE_first_tail_x15_r0_body.s206 1019 PRE_first_tail_x15_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound22 : Conv.boundListB PRE_first_tail_x15_r0_body.s206 PRE_first_tail_x15_r0_body.cl22 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK22 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK22 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK22 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s204.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli22.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst22 : Conv.sstListB 1019 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s206.ffi).mlx PRE_first_tail_x15_r0_body.cln22 PRE_first_tail_x15_r0_body.clo22 PRE_first_tail_x15_r0_body.cli22 = true

end Host.Load.Run.Tpl
