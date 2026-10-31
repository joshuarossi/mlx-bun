import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC190
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl190`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl190 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo190 : List Nat := []
def PRE_first_tail_x15_r0_body.cln190 : List Nat := []
def PRE_first_tail_x15_r0_body.cli190 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap190 : PRE_first_tail_x15_r0_body.s1676.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1674.heap (PRE_first_tail_x15_r0_body.cl190.filterMap fun a => (PRE_first_tail_x15_r0_body.s1676.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe190 : Nat.ble PRE_first_tail_x15_r0_body.s1674.next PRE_first_tail_x15_r0_body.s1676.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP190 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1674 PRE_first_tail_x15_r0_body.s1676 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp190 : Conv.suppListB PRE_first_tail_x15_r0_body.s1676 8201 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound190 : Conv.boundListB PRE_first_tail_x15_r0_body.s1676 PRE_first_tail_x15_r0_body.cl190 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1676.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1674.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1676.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1676.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1674.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1676.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK190 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1676.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1674.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli190.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1676.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst190 : Conv.sstListB 8201 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1676.ffi).mlx PRE_first_tail_x15_r0_body.cln190 PRE_first_tail_x15_r0_body.clo190 PRE_first_tail_x15_r0_body.cli190 = true

end Host.Load.Run.Tpl
