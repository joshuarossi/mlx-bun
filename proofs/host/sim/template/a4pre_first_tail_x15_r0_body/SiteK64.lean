import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC64
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl64`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl64 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo64 : List Nat := []
def PRE_first_tail_x15_r0_body.cln64 : List Nat := []
def PRE_first_tail_x15_r0_body.cli64 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap64 : PRE_first_tail_x15_r0_body.s630.heap = Stage.setAll PRE_first_tail_x15_r0_body.s628.heap (PRE_first_tail_x15_r0_body.cl64.filterMap fun a => (PRE_first_tail_x15_r0_body.s630.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe64 : Nat.ble PRE_first_tail_x15_r0_body.s628.next PRE_first_tail_x15_r0_body.s630.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP64 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s628 PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.cl64 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp64 : Conv.suppListB PRE_first_tail_x15_r0_body.s630 2816 PRE_first_tail_x15_r0_body.cl64 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound64 : Conv.boundListB PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.cl64 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli64.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst64 : Conv.sstListB 2816 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s630.ffi).mlx PRE_first_tail_x15_r0_body.cln64 PRE_first_tail_x15_r0_body.clo64 PRE_first_tail_x15_r0_body.cli64 = true

end Host.Load.Run.Tpl
