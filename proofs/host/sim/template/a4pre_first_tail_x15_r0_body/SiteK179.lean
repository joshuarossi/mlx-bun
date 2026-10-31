import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC179
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl179`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl179 : List Nat := [2665, 2673467, 2815229]
def PRE_first_tail_x15_r0_body.clo179 : List Nat := []
def PRE_first_tail_x15_r0_body.cln179 : List Nat := []
def PRE_first_tail_x15_r0_body.cli179 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap179 : PRE_first_tail_x15_r0_body.s1575.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1573.heap (PRE_first_tail_x15_r0_body.cl179.filterMap fun a => (PRE_first_tail_x15_r0_body.s1575.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe179 : Nat.ble PRE_first_tail_x15_r0_body.s1573.next PRE_first_tail_x15_r0_body.s1575.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP179 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1573 PRE_first_tail_x15_r0_body.s1575 PRE_first_tail_x15_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp179 : Conv.suppListB PRE_first_tail_x15_r0_body.s1575 7705 PRE_first_tail_x15_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound179 : Conv.boundListB PRE_first_tail_x15_r0_body.s1575 PRE_first_tail_x15_r0_body.cl179 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK179 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK179 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK179 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1573.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli179.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst179 : Conv.sstListB 7705 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx PRE_first_tail_x15_r0_body.cln179 PRE_first_tail_x15_r0_body.clo179 PRE_first_tail_x15_r0_body.cli179 = true

end Host.Load.Run.Tpl
