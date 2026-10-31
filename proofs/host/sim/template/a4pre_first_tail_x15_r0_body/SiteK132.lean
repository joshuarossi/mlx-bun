import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC132
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl132`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl132 : List Nat := [2665, 2672641, 2673467, 2778209, 2778754, 2779010, 2779035, 2779036, 2779037, 2779038, 2779039, 2779040]
def PRE_first_tail_x15_r0_body.clo132 : List Nat := [20792, 20805, 20811, 20812, 20813, 20814]
def PRE_first_tail_x15_r0_body.cln132 : List Nat := [17885, 17886, 17887, 17888, 17889, 17890, 17891, 17892, 17893, 17894, 17895, 17896, 17897, 17898, 17899, 17900, 17901, 17902, 17903, 17904, 17905, 17906, 17907, 17908, 17909, 17910, 17911]
def PRE_first_tail_x15_r0_body.cli132 : List Nat := [17885, 17886, 17887, 17888, 17889, 17890, 17891, 17892, 17893, 17894, 17895, 17896, 17897, 17898, 17899, 17900, 17901, 17902, 17903, 17904, 17905, 17906, 17907, 17908, 17909, 17910, 17911]
kernel_rfl PRE_first_tail_x15_r0_body.cheap132 : PRE_first_tail_x15_r0_body.s1283.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1281.heap (PRE_first_tail_x15_r0_body.cl132.filterMap fun a => (PRE_first_tail_x15_r0_body.s1283.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe132 : Nat.ble PRE_first_tail_x15_r0_body.s1281.next PRE_first_tail_x15_r0_body.s1283.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP132 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1281 PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp132 : Conv.suppListB PRE_first_tail_x15_r0_body.s1283 5744 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound132 : Conv.boundListB PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst132 : Conv.sstListB 5744 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx PRE_first_tail_x15_r0_body.cln132 PRE_first_tail_x15_r0_body.clo132 PRE_first_tail_x15_r0_body.cli132 = true

end Host.Load.Run.Tpl
