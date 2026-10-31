import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC12
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl12`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl12 : List Nat := [2665, 2672331, 2673467, 2684049, 2684594, 2684850, 2684875, 2684876, 2684877, 2684878, 2684879, 2684880]
def PRE_first_tail_x15_r0_body.clo12 : List Nat := [18432, 18445, 18451, 18452, 18453, 18454]
def PRE_first_tail_x15_r0_body.cln12 : List Nat := [15515, 15516, 15517, 15518, 15519, 15520, 15521, 15522, 15523, 15524, 15525, 15526, 15527, 15528, 15529, 15530, 15531, 15532, 15533, 15534, 15535, 15536, 15537, 15538, 15539, 15540, 15541]
def PRE_first_tail_x15_r0_body.cli12 : List Nat := [15515, 15516, 15517, 15518, 15519, 15520, 15521, 15522, 15523, 15524, 15525, 15526, 15527, 15528, 15529, 15530, 15531, 15532, 15533, 15534, 15535, 15536, 15537, 15538, 15539, 15540, 15541]
kernel_rfl PRE_first_tail_x15_r0_body.cheap12 : PRE_first_tail_x15_r0_body.s121.heap = Stage.setAll PRE_first_tail_x15_r0_body.s119.heap (PRE_first_tail_x15_r0_body.cl12.filterMap fun a => (PRE_first_tail_x15_r0_body.s121.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe12 : Nat.ble PRE_first_tail_x15_r0_body.s119.next PRE_first_tail_x15_r0_body.s121.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP12 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s119 PRE_first_tail_x15_r0_body.s121 PRE_first_tail_x15_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp12 : Conv.suppListB PRE_first_tail_x15_r0_body.s121 614 PRE_first_tail_x15_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound12 : Conv.boundListB PRE_first_tail_x15_r0_body.s121 PRE_first_tail_x15_r0_body.cl12 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK12 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK12 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK12 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s119.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli12.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst12 : Conv.sstListB 614 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx PRE_first_tail_x15_r0_body.cln12 PRE_first_tail_x15_r0_body.clo12 PRE_first_tail_x15_r0_body.cli12 = true

end Host.Load.Run.Tpl
