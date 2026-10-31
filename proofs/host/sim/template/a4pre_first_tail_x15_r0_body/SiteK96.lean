import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC96
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl96`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl96 : List Nat := [2665, 2672548, 2673467, 2749965, 2750510, 2750766, 2750791, 2750792, 2750793, 2750794, 2750795, 2750796]
def PRE_first_tail_x15_r0_body.clo96 : List Nat := [20084, 20097, 20103, 20104, 20105, 20106]
def PRE_first_tail_x15_r0_body.cln96 : List Nat := [17174, 17175, 17176, 17177, 17178, 17179, 17180, 17181, 17182, 17183, 17184, 17185, 17186, 17187, 17188, 17189, 17190, 17191, 17192, 17193, 17194, 17195, 17196, 17197, 17198, 17199, 17200]
def PRE_first_tail_x15_r0_body.cli96 : List Nat := [17174, 17175, 17176, 17177, 17178, 17179, 17180, 17181, 17182, 17183, 17184, 17185, 17186, 17187, 17188, 17189, 17190, 17191, 17192, 17193, 17194, 17195, 17196, 17197, 17198, 17199, 17200]
kernel_rfl PRE_first_tail_x15_r0_body.cheap96 : PRE_first_tail_x15_r0_body.s856.heap = Stage.setAll PRE_first_tail_x15_r0_body.s854.heap (PRE_first_tail_x15_r0_body.cl96.filterMap fun a => (PRE_first_tail_x15_r0_body.s856.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe96 : Nat.ble PRE_first_tail_x15_r0_body.s854.next PRE_first_tail_x15_r0_body.s856.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP96 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s854 PRE_first_tail_x15_r0_body.s856 PRE_first_tail_x15_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp96 : Conv.suppListB PRE_first_tail_x15_r0_body.s856 4205 PRE_first_tail_x15_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound96 : Conv.boundListB PRE_first_tail_x15_r0_body.s856 PRE_first_tail_x15_r0_body.cl96 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK96 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s854.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK96 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s854.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK96 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s854.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli96.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst96 : Conv.sstListB 4205 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s856.ffi).mlx PRE_first_tail_x15_r0_body.cln96 PRE_first_tail_x15_r0_body.clo96 PRE_first_tail_x15_r0_body.cli96 = true

end Host.Load.Run.Tpl
