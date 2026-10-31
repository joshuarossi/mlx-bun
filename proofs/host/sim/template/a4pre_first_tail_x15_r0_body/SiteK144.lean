import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC144
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl144`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl144 : List Nat := [2665, 2672672, 2673467, 2787633, 2788178, 2788434, 2788459, 2788460, 2788461, 2788462, 2788463, 2788464]
def PRE_first_tail_x15_r0_body.clo144 : List Nat := [21028, 21041, 21047, 21048, 21049, 21050]
def PRE_first_tail_x15_r0_body.cln144 : List Nat := [18122, 18123, 18124, 18125, 18126, 18127, 18128, 18129, 18130, 18131, 18132, 18133, 18134, 18135, 18136, 18137, 18138, 18139, 18140, 18141, 18142, 18143, 18144, 18145, 18146, 18147, 18148]
def PRE_first_tail_x15_r0_body.cli144 : List Nat := [18122, 18123, 18124, 18125, 18126, 18127, 18128, 18129, 18130, 18131, 18132, 18133, 18134, 18135, 18136, 18137, 18138, 18139, 18140, 18141, 18142, 18143, 18144, 18145, 18146, 18147, 18148]
kernel_rfl PRE_first_tail_x15_r0_body.cheap144 : PRE_first_tail_x15_r0_body.s1398.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1396.heap (PRE_first_tail_x15_r0_body.cl144.filterMap fun a => (PRE_first_tail_x15_r0_body.s1398.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe144 : Nat.ble PRE_first_tail_x15_r0_body.s1396.next PRE_first_tail_x15_r0_body.s1398.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP144 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1396 PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp144 : Conv.suppListB PRE_first_tail_x15_r0_body.s1398 6257 PRE_first_tail_x15_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound144 : Conv.boundListB PRE_first_tail_x15_r0_body.s1398 PRE_first_tail_x15_r0_body.cl144 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK144 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK144 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK144 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1396.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli144.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst144 : Conv.sstListB 6257 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx PRE_first_tail_x15_r0_body.cln144 PRE_first_tail_x15_r0_body.clo144 PRE_first_tail_x15_r0_body.cli144 = true

end Host.Load.Run.Tpl
