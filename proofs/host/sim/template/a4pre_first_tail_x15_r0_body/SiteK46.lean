import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC46
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl46`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl46 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo46 : List Nat := []
def PRE_first_tail_x15_r0_body.cln46 : List Nat := []
def PRE_first_tail_x15_r0_body.cli46 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap46 : PRE_first_tail_x15_r0_body.s457.heap = Stage.setAll PRE_first_tail_x15_r0_body.s455.heap (PRE_first_tail_x15_r0_body.cl46.filterMap fun a => (PRE_first_tail_x15_r0_body.s457.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe46 : Nat.ble PRE_first_tail_x15_r0_body.s455.next PRE_first_tail_x15_r0_body.s457.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP46 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp46 : Conv.suppListB PRE_first_tail_x15_r0_body.s457 2045 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound46 : Conv.boundListB PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.cl46 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln46.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo46.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli46.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst46 : Conv.sstListB 2045 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx PRE_first_tail_x15_r0_body.cln46 PRE_first_tail_x15_r0_body.clo46 PRE_first_tail_x15_r0_body.cli46 = true

end Host.Load.Run.Tpl
