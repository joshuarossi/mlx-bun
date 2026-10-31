import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC114
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl114`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl114 : List Nat := [2665, 2672589, 2673467, 2763897, 2764442, 2764698, 2764723, 2764724, 2764725, 2764726, 2764727, 2764728]
def PRE_first_tail_x15_r0_body.clo114 : List Nat := [20434, 20447, 20453, 20454, 20455, 20456]
def PRE_first_tail_x15_r0_body.cln114 : List Nat := [17537, 17538, 17539, 17540, 17541, 17542, 17543, 17544, 17545, 17546, 17547, 17548, 17549, 17550, 17551, 17552, 17553, 17554, 17555, 17556, 17557, 17558, 17559, 17560, 17561, 17562, 17563]
def PRE_first_tail_x15_r0_body.cli114 : List Nat := [17537, 17538, 17539, 17540, 17541, 17542, 17543, 17544, 17545, 17546, 17547, 17548, 17549, 17550, 17551, 17552, 17553, 17554, 17555, 17556, 17557, 17558, 17559, 17560, 17561, 17562, 17563]
kernel_rfl PRE_first_tail_x15_r0_body.cheap114 : PRE_first_tail_x15_r0_body.s1015.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1013.heap (PRE_first_tail_x15_r0_body.cl114.filterMap fun a => (PRE_first_tail_x15_r0_body.s1015.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe114 : Nat.ble PRE_first_tail_x15_r0_body.s1013.next PRE_first_tail_x15_r0_body.s1015.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP114 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1013 PRE_first_tail_x15_r0_body.s1015 PRE_first_tail_x15_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp114 : Conv.suppListB PRE_first_tail_x15_r0_body.s1015 4976 PRE_first_tail_x15_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound114 : Conv.boundListB PRE_first_tail_x15_r0_body.s1015 PRE_first_tail_x15_r0_body.cl114 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK114 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1013.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK114 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1013.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK114 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1013.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli114.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst114 : Conv.sstListB 4976 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx PRE_first_tail_x15_r0_body.cln114 PRE_first_tail_x15_r0_body.clo114 PRE_first_tail_x15_r0_body.cli114 = true

end Host.Load.Run.Tpl
