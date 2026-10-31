import host.sim.template.a4pre_setup_h1_chunk.SiteC0
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_setup_h1_chunk.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_setup_h1_chunk.cl0 : List Nat := [2665]
def PRE_setup_h1_chunk.clo0 : List Nat := []
def PRE_setup_h1_chunk.cln0 : List Nat := []
def PRE_setup_h1_chunk.cli0 : List Nat := []
kernel_rfl PRE_setup_h1_chunk.cheap0 : PRE_setup_h1_chunk.s2.heap = Stage.setAll PRE_setup_h1_chunk.s0.heap (PRE_setup_h1_chunk.cl0.filterMap fun a => (PRE_setup_h1_chunk.s2.heap.get a).map (a, ·))
kernel_rfl PRE_setup_h1_chunk.cnextLe0 : Nat.ble PRE_setup_h1_chunk.s0.next PRE_setup_h1_chunk.s2.next = true
kernel_rfl PRE_setup_h1_chunk.ckeepP0 : Conv.keptPresentB PRE_setup_h1_chunk.s0 PRE_setup_h1_chunk.s2 PRE_setup_h1_chunk.cl0 = true
kernel_rfl PRE_setup_h1_chunk.csupp0 : Conv.suppListB PRE_setup_h1_chunk.s2 10 PRE_setup_h1_chunk.cl0 = true
kernel_rfl PRE_setup_h1_chunk.cbound0 : Conv.boundListB PRE_setup_h1_chunk.s2 PRE_setup_h1_chunk.cl0 = true
kernel_rfl PRE_setup_h1_chunk.cnodesK0 : (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s2.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s0.ffi).mlx.nodes (PRE_setup_h1_chunk.cln0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h1_chunk.s2.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_setup_h1_chunk.cobjsK0 : (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s2.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s0.ffi).mlx.objs (PRE_setup_h1_chunk.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h1_chunk.s2.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_setup_h1_chunk.citemsK0 : (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s2.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s0.ffi).mlx.items (PRE_setup_h1_chunk.cli0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h1_chunk.s2.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_setup_h1_chunk.csst0 : Conv.sstListB 10 (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s2.ffi).mlx PRE_setup_h1_chunk.cln0 PRE_setup_h1_chunk.clo0 PRE_setup_h1_chunk.cli0 = true

end Host.Load.Run.Tpl
