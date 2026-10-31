import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC41
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl41`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl41 : List Nat := [2665, 2673467, 2706743]
def PRE_first_tail_x15_r0_body.clo41 : List Nat := []
def PRE_first_tail_x15_r0_body.cln41 : List Nat := []
def PRE_first_tail_x15_r0_body.cli41 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap41 : PRE_first_tail_x15_r0_body.s404.heap = Stage.setAll PRE_first_tail_x15_r0_body.s402.heap (PRE_first_tail_x15_r0_body.cl41.filterMap fun a => (PRE_first_tail_x15_r0_body.s404.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe41 : Nat.ble PRE_first_tail_x15_r0_body.s402.next PRE_first_tail_x15_r0_body.s404.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP41 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp41 : Conv.suppListB PRE_first_tail_x15_r0_body.s404 1807 PRE_first_tail_x15_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound41 : Conv.boundListB PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.cl41 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK41 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK41 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK41 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s402.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli41.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst41 : Conv.sstListB 1807 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s404.ffi).mlx PRE_first_tail_x15_r0_body.cln41 PRE_first_tail_x15_r0_body.clo41 PRE_first_tail_x15_r0_body.cli41 = true

end Host.Load.Run.Tpl
