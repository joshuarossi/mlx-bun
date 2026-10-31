import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC169
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl169`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl169 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo169 : List Nat := []
def PRE_first_tail_x15_r0_body.cln169 : List Nat := []
def PRE_first_tail_x15_r0_body.cli169 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap169 : PRE_first_tail_x15_r0_body.s1493.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1491.heap (PRE_first_tail_x15_r0_body.cl169.filterMap fun a => (PRE_first_tail_x15_r0_body.s1493.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe169 : Nat.ble PRE_first_tail_x15_r0_body.s1491.next PRE_first_tail_x15_r0_body.s1493.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP169 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1491 PRE_first_tail_x15_r0_body.s1493 PRE_first_tail_x15_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp169 : Conv.suppListB PRE_first_tail_x15_r0_body.s1493 7304 PRE_first_tail_x15_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound169 : Conv.boundListB PRE_first_tail_x15_r0_body.s1493 PRE_first_tail_x15_r0_body.cl169 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK169 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK169 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK169 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1491.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli169.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst169 : Conv.sstListB 7304 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1493.ffi).mlx PRE_first_tail_x15_r0_body.cln169 PRE_first_tail_x15_r0_body.clo169 PRE_first_tail_x15_r0_body.cli169 = true

end Host.Load.Run.Tpl
