import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC52
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl52`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl52 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo52 : List Nat := []
def PRE_first_tail_x15_r0_body.cln52 : List Nat := []
def PRE_first_tail_x15_r0_body.cli52 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap52 : PRE_first_tail_x15_r0_body.s515.heap = Stage.setAll PRE_first_tail_x15_r0_body.s513.heap (PRE_first_tail_x15_r0_body.cl52.filterMap fun a => (PRE_first_tail_x15_r0_body.s515.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe52 : Nat.ble PRE_first_tail_x15_r0_body.s513.next PRE_first_tail_x15_r0_body.s515.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP52 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s513 PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp52 : Conv.suppListB PRE_first_tail_x15_r0_body.s515 2303 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound52 : Conv.boundListB PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.cl52 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK52 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s513.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli52.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst52 : Conv.sstListB 2303 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s515.ffi).mlx PRE_first_tail_x15_r0_body.cln52 PRE_first_tail_x15_r0_body.clo52 PRE_first_tail_x15_r0_body.cli52 = true

end Host.Load.Run.Tpl
