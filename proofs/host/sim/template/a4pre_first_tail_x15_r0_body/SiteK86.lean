import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC86
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl86`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl86 : List Nat := [2665, 2673467, 2742155]
def PRE_first_tail_x15_r0_body.clo86 : List Nat := []
def PRE_first_tail_x15_r0_body.cln86 : List Nat := []
def PRE_first_tail_x15_r0_body.cli86 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap86 : PRE_first_tail_x15_r0_body.s762.heap = Stage.setAll PRE_first_tail_x15_r0_body.s760.heap (PRE_first_tail_x15_r0_body.cl86.filterMap fun a => (PRE_first_tail_x15_r0_body.s762.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe86 : Nat.ble PRE_first_tail_x15_r0_body.s760.next PRE_first_tail_x15_r0_body.s762.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP86 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s760 PRE_first_tail_x15_r0_body.s762 PRE_first_tail_x15_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp86 : Conv.suppListB PRE_first_tail_x15_r0_body.s762 3730 PRE_first_tail_x15_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound86 : Conv.boundListB PRE_first_tail_x15_r0_body.s762 PRE_first_tail_x15_r0_body.cl86 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK86 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK86 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK86 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s760.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli86.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst86 : Conv.sstListB 3730 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s762.ffi).mlx PRE_first_tail_x15_r0_body.cln86 PRE_first_tail_x15_r0_body.clo86 PRE_first_tail_x15_r0_body.cli86 = true

end Host.Load.Run.Tpl
