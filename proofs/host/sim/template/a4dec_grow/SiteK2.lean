import host.sim.template.a4dec_grow.SiteC2
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`DEC_grow.cl2`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def DEC_grow.cl2 : List Nat := [2665, 12504, 2673448]
def DEC_grow.clo2 : List Nat := []
def DEC_grow.cln2 : List Nat := []
def DEC_grow.cli2 : List Nat := []
kernel_rfl DEC_grow.cheap2 : DEC_grow.s10.heap = Stage.setAll DEC_grow.s8.heap (DEC_grow.cl2.filterMap fun a => (DEC_grow.s10.heap.get a).map (a, ·))
kernel_rfl DEC_grow.cnextLe2 : Nat.ble DEC_grow.s8.next DEC_grow.s10.next = true
kernel_rfl DEC_grow.ckeepP2 : Conv.keptPresentB DEC_grow.s8 DEC_grow.s10 DEC_grow.cl2 = true
kernel_rfl DEC_grow.csupp2 : Conv.suppListB DEC_grow.s10 386 DEC_grow.cl2 = true
kernel_rfl DEC_grow.cbound2 : Conv.boundListB DEC_grow.s10 DEC_grow.cl2 = true
kernel_rfl DEC_grow.cnodesK2 : (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.nodes (DEC_grow.cln2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_grow.cobjsK2 : (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.objs (DEC_grow.clo2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_grow.citemsK2 : (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_grow.s8.ffi).mlx.items (DEC_grow.cli2.filterMap fun i => ((Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_grow.csst2 : Conv.sstListB 386 (Host.Load.Layers.toLoad DEC_grow.s10.ffi).mlx DEC_grow.cln2 DEC_grow.clo2 DEC_grow.cli2 = true

end Host.Load.Run.Tpl
