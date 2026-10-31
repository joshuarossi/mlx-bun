import host.sim.compose.a4b.GraphColdNative
import host.sim.template.a4pre_d1_post_one.Support
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph.One
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

noncomputable def native : Ffi.St := Full.mlxOf D1PostOne.s10.ffi

theorem common_nodes (i : Nat) (hi : i < 17777) :
    native.nodes.get i = endLoad.ffi.mlx.nodes.get i :=
  D1PostOne.common_nodes i hi

/- Frozen source data, including the actual Metal source and header fields. -/
kernel_rfl kernel_objects : native.objs = endLoad.ffi.mlx.objs

theorem kernel_names (Ks : KernelSources) (k : Nat) :
    kernelName? Ks native k = kernelName? Ks endLoad.ffi.mlx k := by
  simp only [kernelName?, Ffi.St.obj?, kernel_objects]

theorem table_common : D1PostOne.S10.tab = endSrv.tab ++
    [.var 9, .var 9, .bin .min (.lit (F64.ofNat 0)) (.var 9)] := by
  rw [endSrv_eq]
  exact D1PostOne.table_common

theorem table_prefix (i : Nat) (e : SymE) (he : nth? endSrv.tab i = some e) :
    nth? D1PostOne.S10.tab i = some e := by
  rw [table_common]
  exact nth?_append_keep _ _ _ _ he

end Host.Ts.Sim.Compose.ColdGraph.One
