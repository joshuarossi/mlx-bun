import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC183
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl183`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl183 : List Nat := [2665, 2672770, 2673467, 2818161, 2818706, 2818962, 2818987, 2818988, 2818989, 2818990, 2818991, 2818992]
def PRE_first_tail_x15_r0_body.clo183 : List Nat := [21793, 21806, 21812, 21813, 21814, 21815]
def PRE_first_tail_x15_r0_body.cln183 : List Nat := [18896, 18897, 18898, 18899, 18900, 18901, 18902, 18903, 18904, 18905, 18906, 18907, 18908, 18909, 18910, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 18921, 18922]
def PRE_first_tail_x15_r0_body.cli183 : List Nat := [18896, 18897, 18898, 18899, 18900, 18901, 18902, 18903, 18904, 18905, 18906, 18907, 18908, 18909, 18910, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 18921, 18922]
kernel_rfl PRE_first_tail_x15_r0_body.cheap183 : PRE_first_tail_x15_r0_body.s1772.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1770.heap (PRE_first_tail_x15_r0_body.cl183.filterMap fun a => (PRE_first_tail_x15_r0_body.s1772.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe183 : Nat.ble PRE_first_tail_x15_r0_body.s1770.next PRE_first_tail_x15_r0_body.s1772.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP183 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1770 PRE_first_tail_x15_r0_body.s1772 PRE_first_tail_x15_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp183 : Conv.suppListB PRE_first_tail_x15_r0_body.s1772 7925 PRE_first_tail_x15_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound183 : Conv.boundListB PRE_first_tail_x15_r0_body.s1772 PRE_first_tail_x15_r0_body.cl183 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK183 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK183 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK183 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1770.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli183.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst183 : Conv.sstListB 7925 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1772.ffi).mlx PRE_first_tail_x15_r0_body.cln183 PRE_first_tail_x15_r0_body.clo183 PRE_first_tail_x15_r0_body.cli183 = true

end Host.Load.Run.Tpl
