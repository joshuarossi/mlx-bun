import host.sim.template.a4dec_clearGrow.SiteC2
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`DEC_clearGrow.cl2`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def DEC_clearGrow.cl2 : List Nat := [2665, 12504, 2673448]
def DEC_clearGrow.clo2 : List Nat := []
def DEC_clearGrow.cln2 : List Nat := []
def DEC_clearGrow.cli2 : List Nat := []
kernel_rfl DEC_clearGrow.cheap2 : DEC_clearGrow.s10.heap = Stage.setAll DEC_clearGrow.s8.heap (DEC_clearGrow.cl2.filterMap fun a => (DEC_clearGrow.s10.heap.get a).map (a, ·))
kernel_rfl DEC_clearGrow.cnextLe2 : Nat.ble DEC_clearGrow.s8.next DEC_clearGrow.s10.next = true
kernel_rfl DEC_clearGrow.ckeepP2 : Conv.keptPresentB DEC_clearGrow.s8 DEC_clearGrow.s10 DEC_clearGrow.cl2 = true
kernel_rfl DEC_clearGrow.csupp2 : Conv.suppListB DEC_clearGrow.s10 386 DEC_clearGrow.cl2 = true
kernel_rfl DEC_clearGrow.cbound2 : Conv.boundListB DEC_clearGrow.s10 DEC_clearGrow.cl2 = true
kernel_rfl DEC_clearGrow.cnodesK2 : (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.nodes (DEC_clearGrow.cln2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clearGrow.cobjsK2 : (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.objs (DEC_clearGrow.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clearGrow.citemsK2 : (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clearGrow.s8.ffi).mlx.items (DEC_clearGrow.cli2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_clearGrow.csst2 : Conv.sstListB 386 (Host.Load.Layers.toLoad DEC_clearGrow.s10.ffi).mlx DEC_clearGrow.cln2 DEC_clearGrow.clo2 DEC_clearGrow.cli2 = true

end Host.Load.Run.Tpl
