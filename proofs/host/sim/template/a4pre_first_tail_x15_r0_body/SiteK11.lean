import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC11
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl11`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl11 : List Nat := [2665, 2673467, 2683381]
def PRE_first_tail_x15_r0_body.clo11 : List Nat := []
def PRE_first_tail_x15_r0_body.cln11 : List Nat := []
def PRE_first_tail_x15_r0_body.cli11 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap11 : PRE_first_tail_x15_r0_body.s116.heap = Stage.setAll PRE_first_tail_x15_r0_body.s114.heap (PRE_first_tail_x15_r0_body.cl11.filterMap fun a => (PRE_first_tail_x15_r0_body.s116.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe11 : Nat.ble PRE_first_tail_x15_r0_body.s114.next PRE_first_tail_x15_r0_body.s116.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP11 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s114 PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp11 : Conv.suppListB PRE_first_tail_x15_r0_body.s116 523 PRE_first_tail_x15_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound11 : Conv.boundListB PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.cl11 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK11 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK11 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK11 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s114.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli11.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst11 : Conv.sstListB 523 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx PRE_first_tail_x15_r0_body.cln11 PRE_first_tail_x15_r0_body.clo11 PRE_first_tail_x15_r0_body.cli11 = true

end Host.Load.Run.Tpl
