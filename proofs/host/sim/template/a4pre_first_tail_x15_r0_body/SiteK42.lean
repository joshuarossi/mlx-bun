import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC42
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl42`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl42 : List Nat := [2665, 2672403, 2673467, 2707393, 2707938, 2708194, 2708219, 2708220, 2708221, 2708222, 2708223, 2708224]
def PRE_first_tail_x15_r0_body.clo42 : List Nat := [19018, 19031, 19037, 19038, 19039, 19040]
def PRE_first_tail_x15_r0_body.cln42 : List Nat := [16115, 16116, 16117, 16118, 16119, 16120, 16121, 16122, 16123, 16124, 16125, 16126, 16127, 16128, 16129, 16130, 16131, 16132, 16133, 16134, 16135, 16136, 16137, 16138, 16139, 16140, 16141]
def PRE_first_tail_x15_r0_body.cli42 : List Nat := [16115, 16116, 16117, 16118, 16119, 16120, 16121, 16122, 16123, 16124, 16125, 16126, 16127, 16128, 16129, 16130, 16131, 16132, 16133, 16134, 16135, 16136, 16137, 16138, 16139, 16140, 16141]
kernel_rfl PRE_first_tail_x15_r0_body.cheap42 : PRE_first_tail_x15_r0_body.s385.heap = Stage.setAll PRE_first_tail_x15_r0_body.s383.heap (PRE_first_tail_x15_r0_body.cl42.filterMap fun a => (PRE_first_tail_x15_r0_body.s385.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe42 : Nat.ble PRE_first_tail_x15_r0_body.s383.next PRE_first_tail_x15_r0_body.s385.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP42 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s383 PRE_first_tail_x15_r0_body.s385 PRE_first_tail_x15_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp42 : Conv.suppListB PRE_first_tail_x15_r0_body.s385 1898 PRE_first_tail_x15_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound42 : Conv.boundListB PRE_first_tail_x15_r0_body.s385 PRE_first_tail_x15_r0_body.cl42 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK42 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK42 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK42 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s383.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli42.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst42 : Conv.sstListB 1898 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s385.ffi).mlx PRE_first_tail_x15_r0_body.cln42 PRE_first_tail_x15_r0_body.clo42 PRE_first_tail_x15_r0_body.cli42 = true

end Host.Load.Run.Tpl
