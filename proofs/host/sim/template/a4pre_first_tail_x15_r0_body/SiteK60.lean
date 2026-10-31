import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC60
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl60`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl60 : List Nat := [2665, 2672455, 2673467, 2721721, 2722266, 2722522, 2722547, 2722548, 2722549, 2722550, 2722551, 2722552]
def PRE_first_tail_x15_r0_body.clo60 : List Nat := [19376, 19389, 19395, 19396, 19397, 19398]
def PRE_first_tail_x15_r0_body.cln60 : List Nat := [16463, 16464, 16465, 16466, 16467, 16468, 16469, 16470, 16471, 16472, 16473, 16474, 16475, 16476, 16477, 16478, 16479, 16480, 16481, 16482, 16483, 16484, 16485, 16486, 16487, 16488, 16489]
def PRE_first_tail_x15_r0_body.cli60 : List Nat := [16463, 16464, 16465, 16466, 16467, 16468, 16469, 16470, 16471, 16472, 16473, 16474, 16475, 16476, 16477, 16478, 16479, 16480, 16481, 16482, 16483, 16484, 16485, 16486, 16487, 16488, 16489]
kernel_rfl PRE_first_tail_x15_r0_body.cheap60 : PRE_first_tail_x15_r0_body.s541.heap = Stage.setAll PRE_first_tail_x15_r0_body.s539.heap (PRE_first_tail_x15_r0_body.cl60.filterMap fun a => (PRE_first_tail_x15_r0_body.s541.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe60 : Nat.ble PRE_first_tail_x15_r0_body.s539.next PRE_first_tail_x15_r0_body.s541.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP60 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp60 : Conv.suppListB PRE_first_tail_x15_r0_body.s541 2666 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound60 : Conv.boundListB PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.cl60 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s539.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s539.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s539.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli60.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst60 : Conv.sstListB 2666 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s541.ffi).mlx PRE_first_tail_x15_r0_body.cln60 PRE_first_tail_x15_r0_body.clo60 PRE_first_tail_x15_r0_body.cli60 = true

end Host.Load.Run.Tpl
