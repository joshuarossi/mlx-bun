import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC141
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl141`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl141 : List Nat := [2665, 2672663, 2673467, 2786076, 2786077, 2786078, 2786079, 2786080, 2786081, 2786082, 2786083, 2786084, 2786085, 2786086, 2786087, 2786088, 2786089, 2786090]
def PRE_first_tail_x15_r0_body.clo141 : List Nat := [20989, 20990, 20991, 20992]
def PRE_first_tail_x15_r0_body.cln141 : List Nat := [18083, 18084, 18085, 18086, 18087, 18088]
def PRE_first_tail_x15_r0_body.cli141 : List Nat := [18083, 18084, 18085, 18086, 18087, 18088]
kernel_rfl PRE_first_tail_x15_r0_body.cheap141 : PRE_first_tail_x15_r0_body.s1249.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1247.heap (PRE_first_tail_x15_r0_body.cl141.filterMap fun a => (PRE_first_tail_x15_r0_body.s1249.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe141 : Nat.ble PRE_first_tail_x15_r0_body.s1247.next PRE_first_tail_x15_r0_body.s1249.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP141 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1247 PRE_first_tail_x15_r0_body.s1249 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp141 : Conv.suppListB PRE_first_tail_x15_r0_body.s1249 6126 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound141 : Conv.boundListB PRE_first_tail_x15_r0_body.s1249 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1247.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln141.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1247.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1247.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli141.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst141 : Conv.sstListB 6126 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx PRE_first_tail_x15_r0_body.cln141 PRE_first_tail_x15_r0_body.clo141 PRE_first_tail_x15_r0_body.cli141 = true

end Host.Load.Run.Tpl
