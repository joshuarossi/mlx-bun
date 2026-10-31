import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC104
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl104`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl104 : List Nat := [2665, 2673467, 2756095]
def PRE_first_tail_x15_r0_body.clo104 : List Nat := []
def PRE_first_tail_x15_r0_body.cln104 : List Nat := []
def PRE_first_tail_x15_r0_body.cli104 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap104 : PRE_first_tail_x15_r0_body.s921.heap = Stage.setAll PRE_first_tail_x15_r0_body.s919.heap (PRE_first_tail_x15_r0_body.cl104.filterMap fun a => (PRE_first_tail_x15_r0_body.s921.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe104 : Nat.ble PRE_first_tail_x15_r0_body.s919.next PRE_first_tail_x15_r0_body.s921.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP104 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s919 PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp104 : Conv.suppListB PRE_first_tail_x15_r0_body.s921 4501 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound104 : Conv.boundListB PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.cl104 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK104 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s919.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli104.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst104 : Conv.sstListB 4501 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s921.ffi).mlx PRE_first_tail_x15_r0_body.cln104 PRE_first_tail_x15_r0_body.clo104 PRE_first_tail_x15_r0_body.cli104 = true

end Host.Load.Run.Tpl
