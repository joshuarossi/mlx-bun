import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC54
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl54`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl54 : List Nat := [2665, 2672434, 2673467, 2716817, 2717362, 2717618, 2717643, 2717644, 2717645, 2717646, 2717647, 2717648]
def PRE_first_tail_x15_r0_body.clo54 : List Nat := [19254, 19267, 19273, 19274, 19275, 19276]
def PRE_first_tail_x15_r0_body.cln54 : List Nat := [16352, 16353, 16354, 16355, 16356, 16357, 16358, 16359, 16360, 16361, 16362, 16363, 16364, 16365, 16366, 16367, 16368, 16369, 16370, 16371, 16372, 16373, 16374, 16375, 16376, 16377, 16378]
def PRE_first_tail_x15_r0_body.cli54 : List Nat := [16352, 16353, 16354, 16355, 16356, 16357, 16358, 16359, 16360, 16361, 16362, 16363, 16364, 16365, 16366, 16367, 16368, 16369, 16370, 16371, 16372, 16373, 16374, 16375, 16376, 16377, 16378]
kernel_rfl PRE_first_tail_x15_r0_body.cheap54 : PRE_first_tail_x15_r0_body.s490.heap = Stage.setAll PRE_first_tail_x15_r0_body.s488.heap (PRE_first_tail_x15_r0_body.cl54.filterMap fun a => (PRE_first_tail_x15_r0_body.s490.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe54 : Nat.ble PRE_first_tail_x15_r0_body.s488.next PRE_first_tail_x15_r0_body.s490.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP54 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp54 : Conv.suppListB PRE_first_tail_x15_r0_body.s490 2411 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound54 : Conv.boundListB PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.cl54 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK54 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s488.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli54.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst54 : Conv.sstListB 2411 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx PRE_first_tail_x15_r0_body.cln54 PRE_first_tail_x15_r0_body.clo54 PRE_first_tail_x15_r0_body.cli54 = true

end Host.Load.Run.Tpl
