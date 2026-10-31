import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC116
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl116`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl116 : List Nat := [2665, 2673467, 2765507]
def PRE_first_tail_x15_r0_body.clo116 : List Nat := []
def PRE_first_tail_x15_r0_body.cln116 : List Nat := []
def PRE_first_tail_x15_r0_body.cli116 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap116 : PRE_first_tail_x15_r0_body.s1026.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1024.heap (PRE_first_tail_x15_r0_body.cl116.filterMap fun a => (PRE_first_tail_x15_r0_body.s1026.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe116 : Nat.ble PRE_first_tail_x15_r0_body.s1024.next PRE_first_tail_x15_r0_body.s1026.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP116 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.s1026 PRE_first_tail_x15_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp116 : Conv.suppListB PRE_first_tail_x15_r0_body.s1026 5014 PRE_first_tail_x15_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound116 : Conv.boundListB PRE_first_tail_x15_r0_body.s1026 PRE_first_tail_x15_r0_body.cl116 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK116 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1026.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1026.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK116 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1026.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1026.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK116 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1026.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli116.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1026.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst116 : Conv.sstListB 5014 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1026.ffi).mlx PRE_first_tail_x15_r0_body.cln116 PRE_first_tail_x15_r0_body.clo116 PRE_first_tail_x15_r0_body.cli116 = true

end Host.Load.Run.Tpl
