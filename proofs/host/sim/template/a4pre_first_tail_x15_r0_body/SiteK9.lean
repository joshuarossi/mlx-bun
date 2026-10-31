import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC9
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl9`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl9 : List Nat := [2665, 2672322, 2673467, 2682494, 2682495, 2682496, 2682497, 2682498, 2682499, 2682500, 2682501, 2682502, 2682503, 2682504, 2682505, 2682506, 2682507, 2682508]
def PRE_first_tail_x15_r0_body.clo9 : List Nat := [18393, 18394, 18395, 18396]
def PRE_first_tail_x15_r0_body.cln9 : List Nat := [15476, 15477, 15478, 15479, 15480, 15481]
def PRE_first_tail_x15_r0_body.cli9 : List Nat := [15476, 15477, 15478, 15479, 15480, 15481]
kernel_rfl PRE_first_tail_x15_r0_body.cheap9 : PRE_first_tail_x15_r0_body.s104.heap = Stage.setAll PRE_first_tail_x15_r0_body.s102.heap (PRE_first_tail_x15_r0_body.cl9.filterMap fun a => (PRE_first_tail_x15_r0_body.s104.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe9 : Nat.ble PRE_first_tail_x15_r0_body.s102.next PRE_first_tail_x15_r0_body.s104.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP9 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s102 PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp9 : Conv.suppListB PRE_first_tail_x15_r0_body.s104 483 PRE_first_tail_x15_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound9 : Conv.boundListB PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.cl9 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK9 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK9 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK9 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s102.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli9.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst9 : Conv.sstListB 483 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx PRE_first_tail_x15_r0_body.cln9 PRE_first_tail_x15_r0_body.clo9 PRE_first_tail_x15_r0_body.cli9 = true

end Host.Load.Run.Tpl
