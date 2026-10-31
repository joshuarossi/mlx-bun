import host.sim.template.a4dec_clearFill.SiteC0
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`DEC_clearFill.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def DEC_clearFill.cl0 : List Nat := [2665, 12504, 2673448]
def DEC_clearFill.clo0 : List Nat := []
def DEC_clearFill.cln0 : List Nat := []
def DEC_clearFill.cli0 : List Nat := [20157]
kernel_rfl DEC_clearFill.cheap0 : DEC_clearFill.s2.heap = Stage.setAll DEC_clearFill.s0.heap (DEC_clearFill.cl0.filterMap fun a => (DEC_clearFill.s2.heap.get a).map (a, ·))
kernel_rfl DEC_clearFill.cnextLe0 : Nat.ble DEC_clearFill.s0.next DEC_clearFill.s2.next = true
kernel_rfl DEC_clearFill.ckeepP0 : Conv.keptPresentB DEC_clearFill.s0 DEC_clearFill.s2 DEC_clearFill.cl0 = true
kernel_rfl DEC_clearFill.csupp0 : Conv.suppListB DEC_clearFill.s2 123 DEC_clearFill.cl0 = true
kernel_rfl DEC_clearFill.cbound0 : Conv.boundListB DEC_clearFill.s2 DEC_clearFill.cl0 = true
kernel_rfl DEC_clearFill.cnodesK0 : (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.nodes (DEC_clearFill.cln0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearFill.cobjsK0 : (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.objs (DEC_clearFill.clo0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearFill.citemsK0 : (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.items (DEC_clearFill.cli0.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearFill.csst0 : Conv.sstListB 123 (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx DEC_clearFill.cln0 DEC_clearFill.clo0 DEC_clearFill.cli0 = true

end Host.Load.Run.Tpl
