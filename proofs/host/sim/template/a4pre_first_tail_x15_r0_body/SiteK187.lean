import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC187
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl187`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl187 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo187 : List Nat := []
def PRE_first_tail_x15_r0_body.cln187 : List Nat := []
def PRE_first_tail_x15_r0_body.cli187 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap187 : PRE_first_tail_x15_r0_body.s1809.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1807.heap (PRE_first_tail_x15_r0_body.cl187.filterMap fun a => (PRE_first_tail_x15_r0_body.s1809.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe187 : Nat.ble PRE_first_tail_x15_r0_body.s1807.next PRE_first_tail_x15_r0_body.s1809.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP187 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1807 PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp187 : Conv.suppListB PRE_first_tail_x15_r0_body.s1809 8075 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound187 : Conv.boundListB PRE_first_tail_x15_r0_body.s1809 PRE_first_tail_x15_r0_body.cl187 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1807.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli187.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst187 : Conv.sstListB 8075 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx PRE_first_tail_x15_r0_body.cln187 PRE_first_tail_x15_r0_body.clo187 PRE_first_tail_x15_r0_body.cli187 = true

end Host.Load.Run.Tpl
