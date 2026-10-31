import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC102
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl102`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl102 : List Nat := [2665, 2672558, 2673467, 2754485, 2755030, 2755286, 2755311, 2755312, 2755313, 2755314, 2755315, 2755316]
def PRE_first_tail_x15_r0_body.clo102 : List Nat := [20198, 20211, 20217, 20218, 20219, 20220]
def PRE_first_tail_x15_r0_body.cln102 : List Nat := [17300, 17301, 17302, 17303, 17304, 17305, 17306, 17307, 17308, 17309, 17310, 17311, 17312, 17313, 17314, 17315, 17316, 17317, 17318, 17319, 17320, 17321, 17322, 17323, 17324, 17325, 17326]
def PRE_first_tail_x15_r0_body.cli102 : List Nat := [17300, 17301, 17302, 17303, 17304, 17305, 17306, 17307, 17308, 17309, 17310, 17311, 17312, 17313, 17314, 17315, 17316, 17317, 17318, 17319, 17320, 17321, 17322, 17323, 17324, 17325, 17326]
kernel_rfl PRE_first_tail_x15_r0_body.cheap102 : PRE_first_tail_x15_r0_body.s910.heap = Stage.setAll PRE_first_tail_x15_r0_body.s908.heap (PRE_first_tail_x15_r0_body.cl102.filterMap fun a => (PRE_first_tail_x15_r0_body.s910.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe102 : Nat.ble PRE_first_tail_x15_r0_body.s908.next PRE_first_tail_x15_r0_body.s910.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP102 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s908 PRE_first_tail_x15_r0_body.s910 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp102 : Conv.suppListB PRE_first_tail_x15_r0_body.s910 4463 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound102 : Conv.boundListB PRE_first_tail_x15_r0_body.s910 PRE_first_tail_x15_r0_body.cl102 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s908.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli102.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst102 : Conv.sstListB 4463 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s910.ffi).mlx PRE_first_tail_x15_r0_body.cln102 PRE_first_tail_x15_r0_body.clo102 PRE_first_tail_x15_r0_body.cli102 = true

end Host.Load.Run.Tpl
