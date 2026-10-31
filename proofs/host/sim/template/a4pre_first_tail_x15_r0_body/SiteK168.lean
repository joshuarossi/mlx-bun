import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC168
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl168`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl168 : List Nat := [2665, 2672734, 2673467, 2806473, 2807018, 2807274, 2807299, 2807300, 2807301, 2807302, 2807303, 2807304]
def PRE_first_tail_x15_r0_body.clo168 : List Nat := [21500, 21513, 21519, 21520, 21521, 21522]
def PRE_first_tail_x15_r0_body.cln168 : List Nat := [18596, 18597, 18598, 18599, 18600, 18601, 18602, 18603, 18604, 18605, 18606, 18607, 18608, 18609, 18610, 18611, 18612, 18613, 18614, 18615, 18616, 18617, 18618, 18619, 18620, 18621, 18622]
def PRE_first_tail_x15_r0_body.cli168 : List Nat := [18596, 18597, 18598, 18599, 18600, 18601, 18602, 18603, 18604, 18605, 18606, 18607, 18608, 18609, 18610, 18611, 18612, 18613, 18614, 18615, 18616, 18617, 18618, 18619, 18620, 18621, 18622]
kernel_rfl PRE_first_tail_x15_r0_body.cheap168 : PRE_first_tail_x15_r0_body.s1628.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1626.heap (PRE_first_tail_x15_r0_body.cl168.filterMap fun a => (PRE_first_tail_x15_r0_body.s1628.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe168 : Nat.ble PRE_first_tail_x15_r0_body.s1626.next PRE_first_tail_x15_r0_body.s1628.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP168 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1626 PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.cl168 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp168 : Conv.suppListB PRE_first_tail_x15_r0_body.s1628 7283 PRE_first_tail_x15_r0_body.cl168 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound168 : Conv.boundListB PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.cl168 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK168 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK168 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK168 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1626.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli168.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst168 : Conv.sstListB 7283 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx PRE_first_tail_x15_r0_body.cln168 PRE_first_tail_x15_r0_body.clo168 PRE_first_tail_x15_r0_body.cli168 = true

end Host.Load.Run.Tpl
