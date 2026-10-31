import host.sim.template.a4dec_ord.SiteC0
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`DEC_ord.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def DEC_ord.cl0 : List Nat := [2665, 12504, 2673448]
def DEC_ord.clo0 : List Nat := []
def DEC_ord.cln0 : List Nat := []
def DEC_ord.cli0 : List Nat := [20157]
kernel_rfl DEC_ord.cheap0 : DEC_ord.s2.heap = Stage.setAll DEC_ord.s0.heap (DEC_ord.cl0.filterMap fun a => (DEC_ord.s2.heap.get a).map (a, ·))
kernel_rfl DEC_ord.cnextLe0 : Nat.ble DEC_ord.s0.next DEC_ord.s2.next = true
kernel_rfl DEC_ord.ckeepP0 : Conv.keptPresentB DEC_ord.s0 DEC_ord.s2 DEC_ord.cl0 = true
kernel_rfl DEC_ord.csupp0 : Conv.suppListB DEC_ord.s2 123 DEC_ord.cl0 = true
kernel_rfl DEC_ord.cbound0 : Conv.boundListB DEC_ord.s2 DEC_ord.cl0 = true
kernel_rfl DEC_ord.cnodesK0 : (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.nodes (DEC_ord.cln0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_ord.cobjsK0 : (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.objs (DEC_ord.clo0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_ord.citemsK0 : (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s0.ffi).mlx.items (DEC_ord.cli0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_ord.csst0 : Conv.sstListB 123 (Host.Load.Layers.toLoad DEC_ord.s2.ffi).mlx DEC_ord.cln0 DEC_ord.clo0 DEC_ord.cli0 = true

end Host.Load.Run.Tpl
