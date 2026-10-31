import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC23
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl23`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl23 : List Nat := [2665, 2673467, 2692793]
def PRE_first_tail_x15_r0_body.clo23 : List Nat := []
def PRE_first_tail_x15_r0_body.cln23 : List Nat := []
def PRE_first_tail_x15_r0_body.cli23 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap23 : PRE_first_tail_x15_r0_body.s210.heap = Stage.setAll PRE_first_tail_x15_r0_body.s208.heap (PRE_first_tail_x15_r0_body.cl23.filterMap fun a => (PRE_first_tail_x15_r0_body.s210.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe23 : Nat.ble PRE_first_tail_x15_r0_body.s208.next PRE_first_tail_x15_r0_body.s210.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP23 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s208 PRE_first_tail_x15_r0_body.s210 PRE_first_tail_x15_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp23 : Conv.suppListB PRE_first_tail_x15_r0_body.s210 1036 PRE_first_tail_x15_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound23 : Conv.boundListB PRE_first_tail_x15_r0_body.s210 PRE_first_tail_x15_r0_body.cl23 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK23 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln23.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK23 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo23.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK23 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s208.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli23.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst23 : Conv.sstListB 1036 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx PRE_first_tail_x15_r0_body.cln23 PRE_first_tail_x15_r0_body.clo23 PRE_first_tail_x15_r0_body.cli23 = true

end Host.Load.Run.Tpl
