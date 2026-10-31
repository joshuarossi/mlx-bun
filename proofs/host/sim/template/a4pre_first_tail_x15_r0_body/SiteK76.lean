import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC76
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl76`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl76 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo76 : List Nat := []
def PRE_first_tail_x15_r0_body.cln76 : List Nat := []
def PRE_first_tail_x15_r0_body.cli76 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap76 : PRE_first_tail_x15_r0_body.s680.heap = Stage.setAll PRE_first_tail_x15_r0_body.s678.heap (PRE_first_tail_x15_r0_body.cl76.filterMap fun a => (PRE_first_tail_x15_r0_body.s680.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe76 : Nat.ble PRE_first_tail_x15_r0_body.s678.next PRE_first_tail_x15_r0_body.s680.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP76 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s678 PRE_first_tail_x15_r0_body.s680 PRE_first_tail_x15_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp76 : Conv.suppListB PRE_first_tail_x15_r0_body.s680 3329 PRE_first_tail_x15_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound76 : Conv.boundListB PRE_first_tail_x15_r0_body.s680 PRE_first_tail_x15_r0_body.cl76 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli76.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst76 : Conv.sstListB 3329 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s680.ffi).mlx PRE_first_tail_x15_r0_body.cln76 PRE_first_tail_x15_r0_body.clo76 PRE_first_tail_x15_r0_body.cli76 = true

end Host.Load.Run.Tpl
