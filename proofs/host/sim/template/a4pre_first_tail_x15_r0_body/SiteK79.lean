import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC79
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl79`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl79 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo79 : List Nat := []
def PRE_first_tail_x15_r0_body.cln79 : List Nat := []
def PRE_first_tail_x15_r0_body.cli79 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap79 : PRE_first_tail_x15_r0_body.s707.heap = Stage.setAll PRE_first_tail_x15_r0_body.s705.heap (PRE_first_tail_x15_r0_body.cl79.filterMap fun a => (PRE_first_tail_x15_r0_body.s707.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe79 : Nat.ble PRE_first_tail_x15_r0_body.s705.next PRE_first_tail_x15_r0_body.s707.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP79 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s705 PRE_first_tail_x15_r0_body.s707 PRE_first_tail_x15_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp79 : Conv.suppListB PRE_first_tail_x15_r0_body.s707 3458 PRE_first_tail_x15_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound79 : Conv.boundListB PRE_first_tail_x15_r0_body.s707 PRE_first_tail_x15_r0_body.cl79 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK79 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s705.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK79 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s705.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK79 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s705.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli79.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst79 : Conv.sstListB 3458 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s707.ffi).mlx PRE_first_tail_x15_r0_body.cln79 PRE_first_tail_x15_r0_body.clo79 PRE_first_tail_x15_r0_body.cli79 = true

end Host.Load.Run.Tpl
