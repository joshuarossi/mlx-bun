import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC186
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl186`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl186 : List Nat := [2665, 2672775, 2673467, 2820421, 2820966, 2821222, 2821247, 2821248, 2821249, 2821250, 2821251, 2821252]
def PRE_first_tail_x15_r0_body.clo186 : List Nat := [21850, 21863, 21869, 21870, 21871, 21872]
def PRE_first_tail_x15_r0_body.cln186 : List Nat := [18959, 18960, 18961, 18962, 18963, 18964, 18965, 18966, 18967, 18968, 18969, 18970, 18971, 18972, 18973, 18974, 18975, 18976, 18977, 18978, 18979, 18980, 18981, 18982, 18983, 18984, 18985]
def PRE_first_tail_x15_r0_body.cli186 : List Nat := [18959, 18960, 18961, 18962, 18963, 18964, 18965, 18966, 18967, 18968, 18969, 18970, 18971, 18972, 18973, 18974, 18975, 18976, 18977, 18978, 18979, 18980, 18981, 18982, 18983, 18984, 18985]
kernel_rfl PRE_first_tail_x15_r0_body.cheap186 : PRE_first_tail_x15_r0_body.s1801.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1799.heap (PRE_first_tail_x15_r0_body.cl186.filterMap fun a => (PRE_first_tail_x15_r0_body.s1801.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe186 : Nat.ble PRE_first_tail_x15_r0_body.s1799.next PRE_first_tail_x15_r0_body.s1801.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP186 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1799 PRE_first_tail_x15_r0_body.s1801 PRE_first_tail_x15_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp186 : Conv.suppListB PRE_first_tail_x15_r0_body.s1801 8054 PRE_first_tail_x15_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound186 : Conv.boundListB PRE_first_tail_x15_r0_body.s1801 PRE_first_tail_x15_r0_body.cl186 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK186 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK186 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK186 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst186 : Conv.sstListB 8054 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx PRE_first_tail_x15_r0_body.cln186 PRE_first_tail_x15_r0_body.clo186 PRE_first_tail_x15_r0_body.cli186 = true

end Host.Load.Run.Tpl
