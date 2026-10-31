import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC138
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl138`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl138 : List Nat := [2665, 2672651, 2673467, 2782725, 2783270, 2783526, 2783551, 2783552, 2783553, 2783554, 2783555, 2783556]
def PRE_first_tail_x15_r0_body.clo138 : List Nat := [20906, 20919, 20925, 20926, 20927, 20928]
def PRE_first_tail_x15_r0_body.cln138 : List Nat := [18011, 18012, 18013, 18014, 18015, 18016, 18017, 18018, 18019, 18020, 18021, 18022, 18023, 18024, 18025, 18026, 18027, 18028, 18029, 18030, 18031, 18032, 18033, 18034, 18035, 18036, 18037]
def PRE_first_tail_x15_r0_body.cli138 : List Nat := [18011, 18012, 18013, 18014, 18015, 18016, 18017, 18018, 18019, 18020, 18021, 18022, 18023, 18024, 18025, 18026, 18027, 18028, 18029, 18030, 18031, 18032, 18033, 18034, 18035, 18036, 18037]
kernel_rfl PRE_first_tail_x15_r0_body.cheap138 : PRE_first_tail_x15_r0_body.s1341.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1339.heap (PRE_first_tail_x15_r0_body.cl138.filterMap fun a => (PRE_first_tail_x15_r0_body.s1341.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe138 : Nat.ble PRE_first_tail_x15_r0_body.s1339.next PRE_first_tail_x15_r0_body.s1341.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP138 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1339 PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.cl138 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp138 : Conv.suppListB PRE_first_tail_x15_r0_body.s1341 6002 PRE_first_tail_x15_r0_body.cl138 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound138 : Conv.boundListB PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.cl138 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst138 : Conv.sstListB 6002 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx PRE_first_tail_x15_r0_body.cln138 PRE_first_tail_x15_r0_body.clo138 PRE_first_tail_x15_r0_body.cli138 = true

end Host.Load.Run.Tpl
