import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC63
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl63`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl63 : List Nat := [2665, 2672460, 2673467, 2723977, 2724522, 2724778, 2724803, 2724804, 2724805, 2724806, 2724807, 2724808]
def PRE_first_tail_x15_r0_body.clo63 : List Nat := [19433, 19446, 19452, 19453, 19454, 19455]
def PRE_first_tail_x15_r0_body.cln63 : List Nat := [16526, 16527, 16528, 16529, 16530, 16531, 16532, 16533, 16534, 16535, 16536, 16537, 16538, 16539, 16540, 16541, 16542, 16543, 16544, 16545, 16546, 16547, 16548, 16549, 16550, 16551, 16552]
def PRE_first_tail_x15_r0_body.cli63 : List Nat := [16526, 16527, 16528, 16529, 16530, 16531, 16532, 16533, 16534, 16535, 16536, 16537, 16538, 16539, 16540, 16541, 16542, 16543, 16544, 16545, 16546, 16547, 16548, 16549, 16550, 16551, 16552]
kernel_rfl PRE_first_tail_x15_r0_body.cheap63 : PRE_first_tail_x15_r0_body.s568.heap = Stage.setAll PRE_first_tail_x15_r0_body.s566.heap (PRE_first_tail_x15_r0_body.cl63.filterMap fun a => (PRE_first_tail_x15_r0_body.s568.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe63 : Nat.ble PRE_first_tail_x15_r0_body.s566.next PRE_first_tail_x15_r0_body.s568.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP63 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s566 PRE_first_tail_x15_r0_body.s568 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp63 : Conv.suppListB PRE_first_tail_x15_r0_body.s568 2795 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound63 : Conv.boundListB PRE_first_tail_x15_r0_body.s568 PRE_first_tail_x15_r0_body.cl63 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s566.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s566.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s566.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli63.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst63 : Conv.sstListB 2795 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx PRE_first_tail_x15_r0_body.cln63 PRE_first_tail_x15_r0_body.clo63 PRE_first_tail_x15_r0_body.cli63 = true

end Host.Load.Run.Tpl
