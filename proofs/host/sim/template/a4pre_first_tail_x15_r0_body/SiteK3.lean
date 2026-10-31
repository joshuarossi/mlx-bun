import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC3
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl3`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl3 : List Nat := [2665, 2672305, 2673467, 2676797, 2677342, 2677598, 2677623, 2677624, 2677625, 2677626, 2677627, 2677628]
def PRE_first_tail_x15_r0_body.clo3 : List Nat := [18250, 18263, 18269, 18270, 18271, 18272]
def PRE_first_tail_x15_r0_body.cln3 : List Nat := [15341, 15342, 15343, 15344, 15345, 15346, 15347, 15348, 15349, 15350, 15351, 15352, 15353, 15354, 15355, 15356, 15357, 15358, 15359, 15360, 15361, 15362, 15363, 15364, 15365, 15366, 15367]
def PRE_first_tail_x15_r0_body.cli3 : List Nat := [15341, 15342, 15343, 15344, 15345, 15346, 15347, 15348, 15349, 15350, 15351, 15352, 15353, 15354, 15355, 15356, 15357, 15358, 15359, 15360, 15361, 15362, 15363, 15364, 15365, 15366, 15367]
kernel_rfl PRE_first_tail_x15_r0_body.cheap3 : PRE_first_tail_x15_r0_body.s47.heap = Stage.setAll PRE_first_tail_x15_r0_body.s45.heap (PRE_first_tail_x15_r0_body.cl3.filterMap fun a => (PRE_first_tail_x15_r0_body.s47.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe3 : Nat.ble PRE_first_tail_x15_r0_body.s45.next PRE_first_tail_x15_r0_body.s47.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP3 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s45 PRE_first_tail_x15_r0_body.s47 PRE_first_tail_x15_r0_body.cl3 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp3 : Conv.suppListB PRE_first_tail_x15_r0_body.s47 230 PRE_first_tail_x15_r0_body.cl3 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound3 : Conv.boundListB PRE_first_tail_x15_r0_body.s47 PRE_first_tail_x15_r0_body.cl3 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s45.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s45.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s45.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli3.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst3 : Conv.sstListB 230 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s47.ffi).mlx PRE_first_tail_x15_r0_body.cln3 PRE_first_tail_x15_r0_body.clo3 PRE_first_tail_x15_r0_body.cli3 = true

end Host.Load.Run.Tpl
