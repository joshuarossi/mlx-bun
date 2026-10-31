import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC106
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl106`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl106 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo106 : List Nat := []
def PRE_first_tail_x15_r0_body.cln106 : List Nat := []
def PRE_first_tail_x15_r0_body.cli106 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap106 : PRE_first_tail_x15_r0_body.s1032.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1030.heap (PRE_first_tail_x15_r0_body.cl106.filterMap fun a => (PRE_first_tail_x15_r0_body.s1032.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe106 : Nat.ble PRE_first_tail_x15_r0_body.s1030.next PRE_first_tail_x15_r0_body.s1032.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP106 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1030 PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp106 : Conv.suppListB PRE_first_tail_x15_r0_body.s1032 4610 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound106 : Conv.boundListB PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.cl106 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK106 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1030.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli106.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst106 : Conv.sstListB 4610 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx PRE_first_tail_x15_r0_body.cln106 PRE_first_tail_x15_r0_body.clo106 PRE_first_tail_x15_r0_body.cli106 = true

end Host.Load.Run.Tpl
