import host.sim.template.a4dec_fill.SiteC2
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`DEC_fill.cl2`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def DEC_fill.cl2 : List Nat := [2665, 12504, 2673448]
def DEC_fill.clo2 : List Nat := []
def DEC_fill.cln2 : List Nat := []
def DEC_fill.cli2 : List Nat := []
kernel_rfl DEC_fill.cheap2 : DEC_fill.s10.heap = Stage.setAll DEC_fill.s8.heap (DEC_fill.cl2.filterMap fun a => (DEC_fill.s10.heap.get a).map (a, ·))
kernel_rfl DEC_fill.cnextLe2 : Nat.ble DEC_fill.s8.next DEC_fill.s10.next = true
kernel_rfl DEC_fill.ckeepP2 : Conv.keptPresentB DEC_fill.s8 DEC_fill.s10 DEC_fill.cl2 = true
kernel_rfl DEC_fill.csupp2 : Conv.suppListB DEC_fill.s10 290 DEC_fill.cl2 = true
kernel_rfl DEC_fill.cbound2 : Conv.boundListB DEC_fill.s10 DEC_fill.cl2 = true
kernel_rfl DEC_fill.cnodesK2 : (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.nodes (DEC_fill.cln2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_fill.cobjsK2 : (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.objs (DEC_fill.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_fill.citemsK2 : (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s8.ffi).mlx.items (DEC_fill.cli2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_fill.csst2 : Conv.sstListB 290 (Host.Load.Layers.toLoad DEC_fill.s10.ffi).mlx DEC_fill.cln2 DEC_fill.clo2 DEC_fill.cli2 = true

end Host.Load.Run.Tpl
