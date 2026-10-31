import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC18
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl18`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl18 : List Nat := [2665, 2672341, 2673467, 2688561, 2689106, 2689362, 2689387, 2689388, 2689389, 2689390, 2689391, 2689392]
def PRE_first_tail_x15_r0_body.clo18 : List Nat := [18546, 18559, 18565, 18566, 18567, 18568]
def PRE_first_tail_x15_r0_body.cln18 : List Nat := [15641, 15642, 15643, 15644, 15645, 15646, 15647, 15648, 15649, 15650, 15651, 15652, 15653, 15654, 15655, 15656, 15657, 15658, 15659, 15660, 15661, 15662, 15663, 15664, 15665, 15666, 15667]
def PRE_first_tail_x15_r0_body.cli18 : List Nat := [15641, 15642, 15643, 15644, 15645, 15646, 15647, 15648, 15649, 15650, 15651, 15652, 15653, 15654, 15655, 15656, 15657, 15658, 15659, 15660, 15661, 15662, 15663, 15664, 15665, 15666, 15667]
kernel_rfl PRE_first_tail_x15_r0_body.cheap18 : PRE_first_tail_x15_r0_body.s191.heap = Stage.setAll PRE_first_tail_x15_r0_body.s189.heap (PRE_first_tail_x15_r0_body.cl18.filterMap fun a => (PRE_first_tail_x15_r0_body.s191.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe18 : Nat.ble PRE_first_tail_x15_r0_body.s189.next PRE_first_tail_x15_r0_body.s191.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP18 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s189 PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp18 : Conv.suppListB PRE_first_tail_x15_r0_body.s191 872 PRE_first_tail_x15_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound18 : Conv.boundListB PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.cl18 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK18 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s189.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK18 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s189.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK18 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s189.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli18.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst18 : Conv.sstListB 872 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx PRE_first_tail_x15_r0_body.cln18 PRE_first_tail_x15_r0_body.clo18 PRE_first_tail_x15_r0_body.cli18 = true

end Host.Load.Run.Tpl
