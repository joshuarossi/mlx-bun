import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC181
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl181`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl181 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo181 : List Nat := []
def PRE_first_tail_x15_r0_body.cln181 : List Nat := []
def PRE_first_tail_x15_r0_body.cli181 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap181 : PRE_first_tail_x15_r0_body.s1751.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1749.heap (PRE_first_tail_x15_r0_body.cl181.filterMap fun a => (PRE_first_tail_x15_r0_body.s1751.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe181 : Nat.ble PRE_first_tail_x15_r0_body.s1749.next PRE_first_tail_x15_r0_body.s1751.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP181 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1749 PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp181 : Conv.suppListB PRE_first_tail_x15_r0_body.s1751 7817 PRE_first_tail_x15_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound181 : Conv.boundListB PRE_first_tail_x15_r0_body.s1751 PRE_first_tail_x15_r0_body.cl181 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK181 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK181 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK181 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1749.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli181.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst181 : Conv.sstListB 7817 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx PRE_first_tail_x15_r0_body.cln181 PRE_first_tail_x15_r0_body.clo181 PRE_first_tail_x15_r0_body.cli181 = true

end Host.Load.Run.Tpl
