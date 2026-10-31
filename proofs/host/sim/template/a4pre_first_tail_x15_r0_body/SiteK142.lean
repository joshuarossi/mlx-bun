import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC142
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl142`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl142 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo142 : List Nat := []
def PRE_first_tail_x15_r0_body.cln142 : List Nat := []
def PRE_first_tail_x15_r0_body.cli142 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap142 : PRE_first_tail_x15_r0_body.s1256.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1254.heap (PRE_first_tail_x15_r0_body.cl142.filterMap fun a => (PRE_first_tail_x15_r0_body.s1256.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe142 : Nat.ble PRE_first_tail_x15_r0_body.s1254.next PRE_first_tail_x15_r0_body.s1256.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP142 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.s1256 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp142 : Conv.suppListB PRE_first_tail_x15_r0_body.s1256 6149 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound142 : Conv.boundListB PRE_first_tail_x15_r0_body.s1256 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst142 : Conv.sstListB 6149 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1256.ffi).mlx PRE_first_tail_x15_r0_body.cln142 PRE_first_tail_x15_r0_body.clo142 PRE_first_tail_x15_r0_body.cli142 = true

end Host.Load.Run.Tpl
