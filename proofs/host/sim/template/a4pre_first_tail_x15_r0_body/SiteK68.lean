import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC68
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl68`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl68 : List Nat := [2665, 2673467, 2727843]
def PRE_first_tail_x15_r0_body.clo68 : List Nat := []
def PRE_first_tail_x15_r0_body.cln68 : List Nat := []
def PRE_first_tail_x15_r0_body.cli68 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap68 : PRE_first_tail_x15_r0_body.s606.heap = Stage.setAll PRE_first_tail_x15_r0_body.s604.heap (PRE_first_tail_x15_r0_body.cl68.filterMap fun a => (PRE_first_tail_x15_r0_body.s606.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe68 : Nat.ble PRE_first_tail_x15_r0_body.s604.next PRE_first_tail_x15_r0_body.s606.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP68 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s604 PRE_first_tail_x15_r0_body.s606 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp68 : Conv.suppListB PRE_first_tail_x15_r0_body.s606 2962 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound68 : Conv.boundListB PRE_first_tail_x15_r0_body.s606 PRE_first_tail_x15_r0_body.cl68 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s604.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli68.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst68 : Conv.sstListB 2962 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx PRE_first_tail_x15_r0_body.cln68 PRE_first_tail_x15_r0_body.clo68 PRE_first_tail_x15_r0_body.cli68 = true

end Host.Load.Run.Tpl
