import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC84
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl84`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl84 : List Nat := [2665, 2672517, 2673467, 2740545, 2741090, 2741346, 2741371, 2741372, 2741373, 2741374, 2741375, 2741376]
def PRE_first_tail_x15_r0_body.clo84 : List Nat := [19848, 19861, 19867, 19868, 19869, 19870]
def PRE_first_tail_x15_r0_body.cln84 : List Nat := [16937, 16938, 16939, 16940, 16941, 16942, 16943, 16944, 16945, 16946, 16947, 16948, 16949, 16950, 16951, 16952, 16953, 16954, 16955, 16956, 16957, 16958, 16959, 16960, 16961, 16962, 16963]
def PRE_first_tail_x15_r0_body.cli84 : List Nat := [16937, 16938, 16939, 16940, 16941, 16942, 16943, 16944, 16945, 16946, 16947, 16948, 16949, 16950, 16951, 16952, 16953, 16954, 16955, 16956, 16957, 16958, 16959, 16960, 16961, 16962, 16963]
kernel_rfl PRE_first_tail_x15_r0_body.cheap84 : PRE_first_tail_x15_r0_body.s751.heap = Stage.setAll PRE_first_tail_x15_r0_body.s749.heap (PRE_first_tail_x15_r0_body.cl84.filterMap fun a => (PRE_first_tail_x15_r0_body.s751.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe84 : Nat.ble PRE_first_tail_x15_r0_body.s749.next PRE_first_tail_x15_r0_body.s751.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP84 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.s751 PRE_first_tail_x15_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp84 : Conv.suppListB PRE_first_tail_x15_r0_body.s751 3692 PRE_first_tail_x15_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound84 : Conv.boundListB PRE_first_tail_x15_r0_body.s751 PRE_first_tail_x15_r0_body.cl84 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK84 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK84 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK84 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli84.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst84 : Conv.sstListB 3692 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx PRE_first_tail_x15_r0_body.cln84 PRE_first_tail_x15_r0_body.clo84 PRE_first_tail_x15_r0_body.cli84 = true

end Host.Load.Run.Tpl
