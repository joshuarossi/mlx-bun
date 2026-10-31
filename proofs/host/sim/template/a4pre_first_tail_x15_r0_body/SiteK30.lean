import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC30
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl30`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl30 : List Nat := [2665, 2672372, 2673467, 2697973, 2698518, 2698774, 2698799, 2698800, 2698801, 2698802, 2698803, 2698804]
def PRE_first_tail_x15_r0_body.clo30 : List Nat := [18782, 18795, 18801, 18802, 18803, 18804]
def PRE_first_tail_x15_r0_body.cln30 : List Nat := [15878, 15879, 15880, 15881, 15882, 15883, 15884, 15885, 15886, 15887, 15888, 15889, 15890, 15891, 15892, 15893, 15894, 15895, 15896, 15897, 15898, 15899, 15900, 15901, 15902, 15903, 15904]
def PRE_first_tail_x15_r0_body.cli30 : List Nat := [15878, 15879, 15880, 15881, 15882, 15883, 15884, 15885, 15886, 15887, 15888, 15889, 15890, 15891, 15892, 15893, 15894, 15895, 15896, 15897, 15898, 15899, 15900, 15901, 15902, 15903, 15904]
kernel_rfl PRE_first_tail_x15_r0_body.cheap30 : PRE_first_tail_x15_r0_body.s306.heap = Stage.setAll PRE_first_tail_x15_r0_body.s304.heap (PRE_first_tail_x15_r0_body.cl30.filterMap fun a => (PRE_first_tail_x15_r0_body.s306.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe30 : Nat.ble PRE_first_tail_x15_r0_body.s304.next PRE_first_tail_x15_r0_body.s306.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP30 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.cl30 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp30 : Conv.suppListB PRE_first_tail_x15_r0_body.s306 1385 PRE_first_tail_x15_r0_body.cl30 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound30 : Conv.boundListB PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.cl30 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK30 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK30 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK30 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s304.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli30.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst30 : Conv.sstListB 1385 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s306.ffi).mlx PRE_first_tail_x15_r0_body.cln30 PRE_first_tail_x15_r0_body.clo30 PRE_first_tail_x15_r0_body.cli30 = true

end Host.Load.Run.Tpl
