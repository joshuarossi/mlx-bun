import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC48
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl48`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl48 : List Nat := [2665, 2672424, 2673467, 2712297, 2712842, 2713098, 2713123, 2713124, 2713125, 2713126, 2713127, 2713128]
def PRE_first_tail_x15_r0_body.clo48 : List Nat := [19140, 19153, 19159, 19160, 19161, 19162]
def PRE_first_tail_x15_r0_body.cln48 : List Nat := [16226, 16227, 16228, 16229, 16230, 16231, 16232, 16233, 16234, 16235, 16236, 16237, 16238, 16239, 16240, 16241, 16242, 16243, 16244, 16245, 16246, 16247, 16248, 16249, 16250, 16251, 16252]
def PRE_first_tail_x15_r0_body.cli48 : List Nat := [16226, 16227, 16228, 16229, 16230, 16231, 16232, 16233, 16234, 16235, 16236, 16237, 16238, 16239, 16240, 16241, 16242, 16243, 16244, 16245, 16246, 16247, 16248, 16249, 16250, 16251, 16252]
kernel_rfl PRE_first_tail_x15_r0_body.cheap48 : PRE_first_tail_x15_r0_body.s436.heap = Stage.setAll PRE_first_tail_x15_r0_body.s434.heap (PRE_first_tail_x15_r0_body.cl48.filterMap fun a => (PRE_first_tail_x15_r0_body.s436.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe48 : Nat.ble PRE_first_tail_x15_r0_body.s434.next PRE_first_tail_x15_r0_body.s436.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP48 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s434 PRE_first_tail_x15_r0_body.s436 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp48 : Conv.suppListB PRE_first_tail_x15_r0_body.s436 2153 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound48 : Conv.boundListB PRE_first_tail_x15_r0_body.s436 PRE_first_tail_x15_r0_body.cl48 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s434.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s434.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK48 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s434.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli48.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst48 : Conv.sstListB 2153 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s436.ffi).mlx PRE_first_tail_x15_r0_body.cln48 PRE_first_tail_x15_r0_body.clo48 PRE_first_tail_x15_r0_body.cli48 = true

end Host.Load.Run.Tpl
