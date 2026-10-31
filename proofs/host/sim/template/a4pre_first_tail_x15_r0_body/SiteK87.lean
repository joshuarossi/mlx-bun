import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC87
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl87`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl87 : List Nat := [2665, 2672522, 2673467, 2742801, 2743346, 2743602, 2743627, 2743628, 2743629, 2743630, 2743631, 2743632]
def PRE_first_tail_x15_r0_body.clo87 : List Nat := [19905, 19918, 19924, 19925, 19926, 19927]
def PRE_first_tail_x15_r0_body.cln87 : List Nat := [17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 17009, 17010, 17011, 17012, 17013, 17014, 17015, 17016, 17017, 17018, 17019, 17020, 17021, 17022, 17023, 17024, 17025, 17026]
def PRE_first_tail_x15_r0_body.cli87 : List Nat := [17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 17009, 17010, 17011, 17012, 17013, 17014, 17015, 17016, 17017, 17018, 17019, 17020, 17021, 17022, 17023, 17024, 17025, 17026]
kernel_rfl PRE_first_tail_x15_r0_body.cheap87 : PRE_first_tail_x15_r0_body.s852.heap = Stage.setAll PRE_first_tail_x15_r0_body.s850.heap (PRE_first_tail_x15_r0_body.cl87.filterMap fun a => (PRE_first_tail_x15_r0_body.s852.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe87 : Nat.ble PRE_first_tail_x15_r0_body.s850.next PRE_first_tail_x15_r0_body.s852.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP87 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s850 PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp87 : Conv.suppListB PRE_first_tail_x15_r0_body.s852 3821 PRE_first_tail_x15_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound87 : Conv.boundListB PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.cl87 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK87 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK87 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK87 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s850.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli87.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst87 : Conv.sstListB 3821 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx PRE_first_tail_x15_r0_body.cln87 PRE_first_tail_x15_r0_body.clo87 PRE_first_tail_x15_r0_body.cli87 = true

end Host.Load.Run.Tpl
