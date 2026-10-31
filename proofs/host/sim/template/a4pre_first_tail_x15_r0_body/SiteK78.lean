import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC78
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl78`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl78 : List Nat := [2665, 2672496, 2673467, 2735645, 2736190, 2736446, 2736471, 2736472, 2736473, 2736474, 2736475, 2736476]
def PRE_first_tail_x15_r0_body.clo78 : List Nat := [19726, 19739, 19745, 19746, 19747, 19748]
def PRE_first_tail_x15_r0_body.cln78 : List Nat := [16826, 16827, 16828, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836, 16837, 16838, 16839, 16840, 16841, 16842, 16843, 16844, 16845, 16846, 16847, 16848, 16849, 16850, 16851, 16852]
def PRE_first_tail_x15_r0_body.cli78 : List Nat := [16826, 16827, 16828, 16829, 16830, 16831, 16832, 16833, 16834, 16835, 16836, 16837, 16838, 16839, 16840, 16841, 16842, 16843, 16844, 16845, 16846, 16847, 16848, 16849, 16850, 16851, 16852]
kernel_rfl PRE_first_tail_x15_r0_body.cheap78 : PRE_first_tail_x15_r0_body.s700.heap = Stage.setAll PRE_first_tail_x15_r0_body.s698.heap (PRE_first_tail_x15_r0_body.cl78.filterMap fun a => (PRE_first_tail_x15_r0_body.s700.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe78 : Nat.ble PRE_first_tail_x15_r0_body.s698.next PRE_first_tail_x15_r0_body.s700.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP78 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s698 PRE_first_tail_x15_r0_body.s700 PRE_first_tail_x15_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp78 : Conv.suppListB PRE_first_tail_x15_r0_body.s700 3437 PRE_first_tail_x15_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound78 : Conv.boundListB PRE_first_tail_x15_r0_body.s700 PRE_first_tail_x15_r0_body.cl78 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK78 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK78 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK78 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s698.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli78.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst78 : Conv.sstListB 3437 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx PRE_first_tail_x15_r0_body.cln78 PRE_first_tail_x15_r0_body.clo78 PRE_first_tail_x15_r0_body.cli78 = true

end Host.Load.Run.Tpl
