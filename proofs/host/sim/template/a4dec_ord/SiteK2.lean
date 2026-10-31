import host.sim.template.a4dec_ord.SiteC2
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`DEC_ord.cl2`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def DEC_ord.cl2 : List Nat := [2665, 12504, 2673448]
def DEC_ord.clo2 : List Nat := []
def DEC_ord.cln2 : List Nat := []
def DEC_ord.cli2 : List Nat := []
kernel_rfl DEC_ord.cheap2 : DEC_ord.s10.heap = Stage.setAll DEC_ord.s8.heap (DEC_ord.cl2.filterMap fun a => (DEC_ord.s10.heap.get a).map (a, ·))
kernel_rfl DEC_ord.cnextLe2 : Nat.ble DEC_ord.s8.next DEC_ord.s10.next = true
kernel_rfl DEC_ord.ckeepP2 : Conv.keptPresentB DEC_ord.s8 DEC_ord.s10 DEC_ord.cl2 = true
kernel_rfl DEC_ord.csupp2 : Conv.suppListB DEC_ord.s10 354 DEC_ord.cl2 = true
kernel_rfl DEC_ord.cbound2 : Conv.boundListB DEC_ord.s10 DEC_ord.cl2 = true
kernel_rfl DEC_ord.cnodesK2 : (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.nodes (DEC_ord.cln2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_ord.cobjsK2 : (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.objs (DEC_ord.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_ord.citemsK2 : (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_ord.s8.ffi).mlx.items (DEC_ord.cli2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_ord.csst2 : Conv.sstListB 354 (Host.Load.Layers.toLoad DEC_ord.s10.ffi).mlx DEC_ord.cln2 DEC_ord.clo2 DEC_ord.cli2 = true

end Host.Load.Run.Tpl
