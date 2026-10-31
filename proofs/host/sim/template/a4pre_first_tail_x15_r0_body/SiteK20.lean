import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC20
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl20`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl20 : List Nat := [2665, 2673467, 2690171]
def PRE_first_tail_x15_r0_body.clo20 : List Nat := []
def PRE_first_tail_x15_r0_body.cln20 : List Nat := []
def PRE_first_tail_x15_r0_body.cli20 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap20 : PRE_first_tail_x15_r0_body.s203.heap = Stage.setAll PRE_first_tail_x15_r0_body.s201.heap (PRE_first_tail_x15_r0_body.cl20.filterMap fun a => (PRE_first_tail_x15_r0_body.s203.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe20 : Nat.ble PRE_first_tail_x15_r0_body.s201.next PRE_first_tail_x15_r0_body.s203.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP20 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s201 PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp20 : Conv.suppListB PRE_first_tail_x15_r0_body.s203 910 PRE_first_tail_x15_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound20 : Conv.boundListB PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.cl20 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK20 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln20.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK20 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo20.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK20 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s201.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli20.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst20 : Conv.sstListB 910 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx PRE_first_tail_x15_r0_body.cln20 PRE_first_tail_x15_r0_body.clo20 PRE_first_tail_x15_r0_body.cli20 = true

end Host.Load.Run.Tpl
