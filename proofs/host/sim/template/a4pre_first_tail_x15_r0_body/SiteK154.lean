import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC154
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl154`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl154 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo154 : List Nat := []
def PRE_first_tail_x15_r0_body.cln154 : List Nat := []
def PRE_first_tail_x15_r0_body.cli154 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap154 : PRE_first_tail_x15_r0_body.s1361.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1359.heap (PRE_first_tail_x15_r0_body.cl154.filterMap fun a => (PRE_first_tail_x15_r0_body.s1361.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe154 : Nat.ble PRE_first_tail_x15_r0_body.s1359.next PRE_first_tail_x15_r0_body.s1361.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP154 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1359 PRE_first_tail_x15_r0_body.s1361 PRE_first_tail_x15_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp154 : Conv.suppListB PRE_first_tail_x15_r0_body.s1361 6662 PRE_first_tail_x15_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound154 : Conv.boundListB PRE_first_tail_x15_r0_body.s1361 PRE_first_tail_x15_r0_body.cl154 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK154 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1359.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK154 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1359.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK154 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1359.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli154.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst154 : Conv.sstListB 6662 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1361.ffi).mlx PRE_first_tail_x15_r0_body.cln154 PRE_first_tail_x15_r0_body.clo154 PRE_first_tail_x15_r0_body.cli154 = true

end Host.Load.Run.Tpl
