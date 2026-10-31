import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC40
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl40`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl40 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo40 : List Nat := []
def PRE_first_tail_x15_r0_body.cln40 : List Nat := []
def PRE_first_tail_x15_r0_body.cli40 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap40 : PRE_first_tail_x15_r0_body.s365.heap = Stage.setAll PRE_first_tail_x15_r0_body.s363.heap (PRE_first_tail_x15_r0_body.cl40.filterMap fun a => (PRE_first_tail_x15_r0_body.s365.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe40 : Nat.ble PRE_first_tail_x15_r0_body.s363.next PRE_first_tail_x15_r0_body.s365.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP40 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.s365 PRE_first_tail_x15_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp40 : Conv.suppListB PRE_first_tail_x15_r0_body.s365 1790 PRE_first_tail_x15_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound40 : Conv.boundListB PRE_first_tail_x15_r0_body.s365 PRE_first_tail_x15_r0_body.cl40 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK40 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK40 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK40 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli40.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst40 : Conv.sstListB 1790 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx PRE_first_tail_x15_r0_body.cln40 PRE_first_tail_x15_r0_body.clo40 PRE_first_tail_x15_r0_body.cli40 = true

end Host.Load.Run.Tpl
