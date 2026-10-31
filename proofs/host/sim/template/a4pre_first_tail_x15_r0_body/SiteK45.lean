import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC45
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl45`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl45 : List Nat := [2665, 2672415, 2673467, 2710740, 2710741, 2710742, 2710743, 2710744, 2710745, 2710746, 2710747, 2710748, 2710749, 2710750, 2710751, 2710752, 2710753, 2710754]
def PRE_first_tail_x15_r0_body.clo45 : List Nat := [19101, 19102, 19103, 19104]
def PRE_first_tail_x15_r0_body.cln45 : List Nat := [16187, 16188, 16189, 16190, 16191, 16192]
def PRE_first_tail_x15_r0_body.cli45 : List Nat := [16187, 16188, 16189, 16190, 16191, 16192]
kernel_rfl PRE_first_tail_x15_r0_body.cheap45 : PRE_first_tail_x15_r0_body.s409.heap = Stage.setAll PRE_first_tail_x15_r0_body.s407.heap (PRE_first_tail_x15_r0_body.cl45.filterMap fun a => (PRE_first_tail_x15_r0_body.s409.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe45 : Nat.ble PRE_first_tail_x15_r0_body.s407.next PRE_first_tail_x15_r0_body.s409.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP45 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s407 PRE_first_tail_x15_r0_body.s409 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp45 : Conv.suppListB PRE_first_tail_x15_r0_body.s409 2022 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound45 : Conv.boundListB PRE_first_tail_x15_r0_body.s409 PRE_first_tail_x15_r0_body.cl45 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK45 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s407.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli45.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst45 : Conv.sstListB 2022 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s409.ffi).mlx PRE_first_tail_x15_r0_body.cln45 PRE_first_tail_x15_r0_body.clo45 PRE_first_tail_x15_r0_body.cli45 = true

end Host.Load.Run.Tpl
