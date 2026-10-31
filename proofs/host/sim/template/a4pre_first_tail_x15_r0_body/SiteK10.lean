import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC10
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl10`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl10 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo10 : List Nat := []
def PRE_first_tail_x15_r0_body.cln10 : List Nat := []
def PRE_first_tail_x15_r0_body.cli10 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap10 : PRE_first_tail_x15_r0_body.s112.heap = Stage.setAll PRE_first_tail_x15_r0_body.s110.heap (PRE_first_tail_x15_r0_body.cl10.filterMap fun a => (PRE_first_tail_x15_r0_body.s112.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe10 : Nat.ble PRE_first_tail_x15_r0_body.s110.next PRE_first_tail_x15_r0_body.s112.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP10 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s110 PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp10 : Conv.suppListB PRE_first_tail_x15_r0_body.s112 506 PRE_first_tail_x15_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound10 : Conv.boundListB PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.cl10 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK10 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK10 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK10 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s110.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli10.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst10 : Conv.sstListB 506 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx PRE_first_tail_x15_r0_body.cln10 PRE_first_tail_x15_r0_body.clo10 PRE_first_tail_x15_r0_body.cli10 = true

end Host.Load.Run.Tpl
