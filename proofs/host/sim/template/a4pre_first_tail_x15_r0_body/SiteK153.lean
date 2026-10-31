import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC153
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl153`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl153 : List Nat := [2665, 2672694, 2673467, 2795500, 2795501, 2795502, 2795503, 2795504, 2795505, 2795506, 2795507, 2795508, 2795509, 2795510, 2795511, 2795512, 2795513, 2795514]
def PRE_first_tail_x15_r0_body.clo153 : List Nat := [21225, 21226, 21227, 21228]
def PRE_first_tail_x15_r0_body.cln153 : List Nat := [18320, 18321, 18322, 18323, 18324, 18325]
def PRE_first_tail_x15_r0_body.cli153 : List Nat := [18320, 18321, 18322, 18323, 18324, 18325]
kernel_rfl PRE_first_tail_x15_r0_body.cheap153 : PRE_first_tail_x15_r0_body.s1484.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1482.heap (PRE_first_tail_x15_r0_body.cl153.filterMap fun a => (PRE_first_tail_x15_r0_body.s1484.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe153 : Nat.ble PRE_first_tail_x15_r0_body.s1482.next PRE_first_tail_x15_r0_body.s1484.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP153 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1482 PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp153 : Conv.suppListB PRE_first_tail_x15_r0_body.s1484 6639 PRE_first_tail_x15_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound153 : Conv.boundListB PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.cl153 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK153 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK153 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK153 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli153.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst153 : Conv.sstListB 6639 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx PRE_first_tail_x15_r0_body.cln153 PRE_first_tail_x15_r0_body.clo153 PRE_first_tail_x15_r0_body.cli153 = true

end Host.Load.Run.Tpl
