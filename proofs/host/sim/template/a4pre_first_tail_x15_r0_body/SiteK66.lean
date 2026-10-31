import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC66
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl66`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl66 : List Nat := [2665, 2672465, 2673467, 2726233, 2726778, 2727034, 2727059, 2727060, 2727061, 2727062, 2727063, 2727064]
def PRE_first_tail_x15_r0_body.clo66 : List Nat := [19490, 19503, 19509, 19510, 19511, 19512]
def PRE_first_tail_x15_r0_body.cln66 : List Nat := [16589, 16590, 16591, 16592, 16593, 16594, 16595, 16596, 16597, 16598, 16599, 16600, 16601, 16602, 16603, 16604, 16605, 16606, 16607, 16608, 16609, 16610, 16611, 16612, 16613, 16614, 16615]
def PRE_first_tail_x15_r0_body.cli66 : List Nat := [16589, 16590, 16591, 16592, 16593, 16594, 16595, 16596, 16597, 16598, 16599, 16600, 16601, 16602, 16603, 16604, 16605, 16606, 16607, 16608, 16609, 16610, 16611, 16612, 16613, 16614, 16615]
kernel_rfl PRE_first_tail_x15_r0_body.cheap66 : PRE_first_tail_x15_r0_body.s595.heap = Stage.setAll PRE_first_tail_x15_r0_body.s593.heap (PRE_first_tail_x15_r0_body.cl66.filterMap fun a => (PRE_first_tail_x15_r0_body.s595.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe66 : Nat.ble PRE_first_tail_x15_r0_body.s593.next PRE_first_tail_x15_r0_body.s595.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP66 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.s595 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp66 : Conv.suppListB PRE_first_tail_x15_r0_body.s595 2924 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound66 : Conv.boundListB PRE_first_tail_x15_r0_body.s595 PRE_first_tail_x15_r0_body.cl66 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln66.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo66.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli66.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst66 : Conv.sstListB 2924 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx PRE_first_tail_x15_r0_body.cln66 PRE_first_tail_x15_r0_body.clo66 PRE_first_tail_x15_r0_body.cli66 = true

end Host.Load.Run.Tpl
