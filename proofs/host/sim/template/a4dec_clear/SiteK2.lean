import host.sim.template.a4dec_clear.SiteC2
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`DEC_clear.cl2`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def DEC_clear.cl2 : List Nat := [2665, 12504, 2673448]
def DEC_clear.clo2 : List Nat := []
def DEC_clear.cln2 : List Nat := []
def DEC_clear.cli2 : List Nat := []
kernel_rfl DEC_clear.cheap2 : DEC_clear.s10.heap = Stage.setAll DEC_clear.s8.heap (DEC_clear.cl2.filterMap fun a => (DEC_clear.s10.heap.get a).map (a, ·))
kernel_rfl DEC_clear.cnextLe2 : Nat.ble DEC_clear.s8.next DEC_clear.s10.next = true
kernel_rfl DEC_clear.ckeepP2 : Conv.keptPresentB DEC_clear.s8 DEC_clear.s10 DEC_clear.cl2 = true
kernel_rfl DEC_clear.csupp2 : Conv.suppListB DEC_clear.s10 354 DEC_clear.cl2 = true
kernel_rfl DEC_clear.cbound2 : Conv.boundListB DEC_clear.s10 DEC_clear.cl2 = true
kernel_rfl DEC_clear.cnodesK2 : (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.nodes (DEC_clear.cln2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_clear.cobjsK2 : (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.objs (DEC_clear.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_clear.citemsK2 : (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_clear.s8.ffi).mlx.items (DEC_clear.cli2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_clear.csst2 : Conv.sstListB 354 (Host.Load.Layers.toLoad DEC_clear.s10.ffi).mlx DEC_clear.cln2 DEC_clear.clo2 DEC_clear.cli2 = true

end Host.Load.Run.Tpl
