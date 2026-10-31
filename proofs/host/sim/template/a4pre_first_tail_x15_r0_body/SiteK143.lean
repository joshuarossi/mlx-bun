import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC143
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl143`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl143 : List Nat := [2665, 2673467, 2786961]
def PRE_first_tail_x15_r0_body.clo143 : List Nat := []
def PRE_first_tail_x15_r0_body.cln143 : List Nat := []
def PRE_first_tail_x15_r0_body.cli143 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap143 : PRE_first_tail_x15_r0_body.s1260.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1258.heap (PRE_first_tail_x15_r0_body.cl143.filterMap fun a => (PRE_first_tail_x15_r0_body.s1260.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe143 : Nat.ble PRE_first_tail_x15_r0_body.s1258.next PRE_first_tail_x15_r0_body.s1260.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP143 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1258 PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp143 : Conv.suppListB PRE_first_tail_x15_r0_body.s1260 6166 PRE_first_tail_x15_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound143 : Conv.boundListB PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.cl143 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK143 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln143.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK143 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo143.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK143 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1258.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli143.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst143 : Conv.sstListB 6166 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1260.ffi).mlx PRE_first_tail_x15_r0_body.cln143 PRE_first_tail_x15_r0_body.clo143 PRE_first_tail_x15_r0_body.cli143 = true

end Host.Load.Run.Tpl
