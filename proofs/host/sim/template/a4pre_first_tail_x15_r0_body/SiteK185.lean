import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC185
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl185`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl185 : List Nat := [2665, 2673467, 2819771]
def PRE_first_tail_x15_r0_body.clo185 : List Nat := []
def PRE_first_tail_x15_r0_body.cln185 : List Nat := []
def PRE_first_tail_x15_r0_body.cli185 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap185 : PRE_first_tail_x15_r0_body.s1784.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1782.heap (PRE_first_tail_x15_r0_body.cl185.filterMap fun a => (PRE_first_tail_x15_r0_body.s1784.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe185 : Nat.ble PRE_first_tail_x15_r0_body.s1782.next PRE_first_tail_x15_r0_body.s1784.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP185 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1782 PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp185 : Conv.suppListB PRE_first_tail_x15_r0_body.s1784 7963 PRE_first_tail_x15_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound185 : Conv.boundListB PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.cl185 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK185 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1782.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln185.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK185 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1782.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo185.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK185 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1782.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli185.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst185 : Conv.sstListB 7963 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1784.ffi).mlx PRE_first_tail_x15_r0_body.cln185 PRE_first_tail_x15_r0_body.clo185 PRE_first_tail_x15_r0_body.cli185 = true

end Host.Load.Run.Tpl
