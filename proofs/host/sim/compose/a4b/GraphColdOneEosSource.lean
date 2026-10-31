import host.sim.compose.a4b.GraphColdOne
import host.sim.template.a4pre_d1_post_one_eos.Support
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph.OneEos
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

noncomputable def native : Ffi.St := Full.mlxOf D1PostOneEos.s10.ffi

/- Equality is confined to the native source; the JavaScript heaps differ. -/
kernel_rfl native_same : native = One.native

theorem nodes_same : native.nodes = One.native.nodes :=
  D1PostOneEos.nodes_same

theorem common_nodes (i : Nat) (hi : i < 17777) :
    native.nodes.get i = endLoad.ffi.mlx.nodes.get i := by
  rw [nodes_same]
  exact One.common_nodes i hi

/- Whole object equality includes the actual Metal source and header fields. -/
theorem kernel_objects : native.objs = endLoad.ffi.mlx.objs :=
  (congrArg Ffi.St.objs native_same).trans One.kernel_objects

theorem kernel_names (Ks : KernelSources) (k : Nat) :
    kernelName? Ks native k = kernelName? Ks endLoad.ffi.mlx k := by
  simp only [kernelName?, Ffi.St.obj?, kernel_objects]

theorem table_same : D1PostOneEos.S10.tab = D1PostOne.S10.tab :=
  D1PostOneEos.table_same

theorem table_prefix (i : Nat) (e : SymE) (he : nth? endSrv.tab i = some e) :
    nth? D1PostOneEos.S10.tab i = some e := by
  rw [table_same]
  exact One.table_prefix i e he

theorem native_relation (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) : G.MR P NB Mp n One.native y :=
  native_same ▸ hR

end Host.Ts.Sim.Compose.ColdGraph.OneEos
