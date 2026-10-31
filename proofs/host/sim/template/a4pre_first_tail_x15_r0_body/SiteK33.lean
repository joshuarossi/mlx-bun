import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC33
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl33`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl33 : List Nat := [2665, 2672384, 2673467, 2701320, 2701321, 2701322, 2701323, 2701324, 2701325, 2701326, 2701327, 2701328, 2701329, 2701330, 2701331, 2701332, 2701333, 2701334]
def PRE_first_tail_x15_r0_body.clo33 : List Nat := [18865, 18866, 18867, 18868]
def PRE_first_tail_x15_r0_body.cln33 : List Nat := [15950, 15951, 15952, 15953, 15954, 15955]
def PRE_first_tail_x15_r0_body.cli33 : List Nat := [15950, 15951, 15952, 15953, 15954, 15955]
kernel_rfl PRE_first_tail_x15_r0_body.cheap33 : PRE_first_tail_x15_r0_body.s304.heap = Stage.setAll PRE_first_tail_x15_r0_body.s302.heap (PRE_first_tail_x15_r0_body.cl33.filterMap fun a => (PRE_first_tail_x15_r0_body.s304.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe33 : Nat.ble PRE_first_tail_x15_r0_body.s302.next PRE_first_tail_x15_r0_body.s304.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP33 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s302 PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp33 : Conv.suppListB PRE_first_tail_x15_r0_body.s304 1509 PRE_first_tail_x15_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound33 : Conv.boundListB PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.cl33 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK33 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln33.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK33 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo33.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK33 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s302.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli33.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst33 : Conv.sstListB 1509 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx PRE_first_tail_x15_r0_body.cln33 PRE_first_tail_x15_r0_body.clo33 PRE_first_tail_x15_r0_body.cli33 = true

end Host.Load.Run.Tpl
