import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC36
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl36`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl36 : List Nat := [2665, 2672393, 2673467, 2702877, 2703422, 2703678, 2703703, 2703704, 2703705, 2703706, 2703707, 2703708]
def PRE_first_tail_x15_r0_body.clo36 : List Nat := [18904, 18917, 18923, 18924, 18925, 18926]
def PRE_first_tail_x15_r0_body.cln36 : List Nat := [15989, 15990, 15991, 15992, 15993, 15994, 15995, 15996, 15997, 15998, 15999, 16000, 16001, 16002, 16003, 16004, 16005, 16006, 16007, 16008, 16009, 16010, 16011, 16012, 16013, 16014, 16015]
def PRE_first_tail_x15_r0_body.cli36 : List Nat := [15989, 15990, 15991, 15992, 15993, 15994, 15995, 15996, 15997, 15998, 15999, 16000, 16001, 16002, 16003, 16004, 16005, 16006, 16007, 16008, 16009, 16010, 16011, 16012, 16013, 16014, 16015]
kernel_rfl PRE_first_tail_x15_r0_body.cheap36 : PRE_first_tail_x15_r0_body.s331.heap = Stage.setAll PRE_first_tail_x15_r0_body.s329.heap (PRE_first_tail_x15_r0_body.cl36.filterMap fun a => (PRE_first_tail_x15_r0_body.s331.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe36 : Nat.ble PRE_first_tail_x15_r0_body.s329.next PRE_first_tail_x15_r0_body.s331.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP36 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s329 PRE_first_tail_x15_r0_body.s331 PRE_first_tail_x15_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp36 : Conv.suppListB PRE_first_tail_x15_r0_body.s331 1640 PRE_first_tail_x15_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound36 : Conv.boundListB PRE_first_tail_x15_r0_body.s331 PRE_first_tail_x15_r0_body.cl36 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK36 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s331.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s329.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s331.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK36 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s331.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s329.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s331.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK36 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s331.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s329.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli36.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s331.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst36 : Conv.sstListB 1640 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s331.ffi).mlx PRE_first_tail_x15_r0_body.cln36 PRE_first_tail_x15_r0_body.clo36 PRE_first_tail_x15_r0_body.cli36 = true

end Host.Load.Run.Tpl
