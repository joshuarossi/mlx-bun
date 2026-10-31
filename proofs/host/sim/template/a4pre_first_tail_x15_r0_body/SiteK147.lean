import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC147
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl147`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl147 : List Nat := [2665, 2672677, 2673467, 2789893, 2790438, 2790694, 2790719, 2790720, 2790721, 2790722, 2790723, 2790724]
def PRE_first_tail_x15_r0_body.clo147 : List Nat := [21085, 21098, 21104, 21105, 21106, 21107]
def PRE_first_tail_x15_r0_body.cln147 : List Nat := [18185, 18186, 18187, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196, 18197, 18198, 18199, 18200, 18201, 18202, 18203, 18204, 18205, 18206, 18207, 18208, 18209, 18210, 18211]
def PRE_first_tail_x15_r0_body.cli147 : List Nat := [18185, 18186, 18187, 18188, 18189, 18190, 18191, 18192, 18193, 18194, 18195, 18196, 18197, 18198, 18199, 18200, 18201, 18202, 18203, 18204, 18205, 18206, 18207, 18208, 18209, 18210, 18211]
kernel_rfl PRE_first_tail_x15_r0_body.cheap147 : PRE_first_tail_x15_r0_body.s1427.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1425.heap (PRE_first_tail_x15_r0_body.cl147.filterMap fun a => (PRE_first_tail_x15_r0_body.s1427.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe147 : Nat.ble PRE_first_tail_x15_r0_body.s1425.next PRE_first_tail_x15_r0_body.s1427.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP147 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1425 PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp147 : Conv.suppListB PRE_first_tail_x15_r0_body.s1427 6386 PRE_first_tail_x15_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound147 : Conv.boundListB PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.cl147 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK147 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK147 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK147 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1425.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli147.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst147 : Conv.sstListB 6386 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx PRE_first_tail_x15_r0_body.cln147 PRE_first_tail_x15_r0_body.clo147 PRE_first_tail_x15_r0_body.cli147 = true

end Host.Load.Run.Tpl
