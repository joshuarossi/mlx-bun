import host.sim.template.a4pre_setup_early_r0.NCl0c_0
import host.sim.template.a4pre_setup_early_r0.NCl0c_1
import host.sim.template.a4pre_setup_early_r0.NCl0c_2
import host.sim.template.a4pre_setup_early_r0.NCl0c_3
import host.sim.template.a4pre_setup_early_r0.NCl0c_4
import host.sim.template.a4pre_setup_early_r0.NCl0c_5
import host.sim.template.a4pre_setup_early_r0.NCl0c_6
import host.sim.template.a4pre_setup_early_r0.NCl0c_7
import host.sim.template.a4pre_setup_early_r0.NCl0c_8
import host.sim.template.a4pre_setup_early_r0.NCl0c_9
import host.sim.template.a4pre_setup_early_r0.NCl0c_10
import host.sim.template.a4pre_setup_early_r0.NCl0c_11
import host.sim.template.a4pre_setup_early_r0.NCl0c_12
import host.sim.template.a4pre_setup_early_r0.NCl0c_13
import host.sim.template.a4pre_setup_early_r0.NCl0c_14
import host.sim.template.a4pre_setup_early_r0.NCl0c_15
import host.sim.template.a4pre_setup_early_r0.NCl0c_16
import host.sim.template.a4pre_setup_early_r0.NCl0c_17
import host.sim.template.a4pre_setup_early_r0.NCl0c_18
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping at the start of chain `PRE_setup_early_r0`: the full check (`Conv.ncleanB`), in chunks. -/

kernel_rfl PRE_setup_early_r0.ncl0a0_end : ((((((((PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.arrs).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PRE_setup_early_r0.ncl0a0 : (PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.arrs).all (Conv.arrOldB (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx) = true :=
  all_take_drop 2000 PRE_setup_early_r0.ncl0a0_0 (all_take_drop 2000 PRE_setup_early_r0.ncl0a0_1 (all_take_drop 2000 PRE_setup_early_r0.ncl0a0_2 (all_take_drop 2000 PRE_setup_early_r0.ncl0a0_3 (all_take_drop 2000 PRE_setup_early_r0.ncl0a0_4 (all_take_drop 2000 PRE_setup_early_r0.ncl0a0_5 (all_take_drop 2000 PRE_setup_early_r0.ncl0a0_6 (all_take_drop 2000 PRE_setup_early_r0.ncl0a0_7 (all_of_nil PRE_setup_early_r0.ncl0a0_end))))))))
kernel_rfl PRE_setup_early_r0.ncl0o0_end : ((PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.objs).drop 2000).drop 2000 = []
theorem PRE_setup_early_r0.ncl0o0 : (PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.objs).all (Conv.objOldB (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx) = true :=
  all_take_drop 2000 PRE_setup_early_r0.ncl0o0_0 (all_take_drop 2000 PRE_setup_early_r0.ncl0o0_1 (all_of_nil PRE_setup_early_r0.ncl0o0_end))
kernel_rfl PRE_setup_early_r0.ncl0n0_end : ((((((((PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PRE_setup_early_r0.ncl0n0 : (PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.nodes).all (Conv.nodeOldB (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx) = true :=
  all_take_drop 2000 PRE_setup_early_r0.ncl0n0_0 (all_take_drop 2000 PRE_setup_early_r0.ncl0n0_1 (all_take_drop 2000 PRE_setup_early_r0.ncl0n0_2 (all_take_drop 2000 PRE_setup_early_r0.ncl0n0_3 (all_take_drop 2000 PRE_setup_early_r0.ncl0n0_4 (all_take_drop 2000 PRE_setup_early_r0.ncl0n0_5 (all_take_drop 2000 PRE_setup_early_r0.ncl0n0_6 (all_take_drop 2000 PRE_setup_early_r0.ncl0n0_7 (all_of_nil PRE_setup_early_r0.ncl0n0_end))))))))
kernel_rfl PRE_setup_early_r0.ncl0i0_end : (PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.items).drop 2000 = []
theorem PRE_setup_early_r0.ncl0i0 : (PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.items).all (Conv.itemOldB (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx) = true :=
  all_take_drop 2000 PRE_setup_early_r0.ncl0i0_0 (all_of_nil PRE_setup_early_r0.ncl0i0_end)
theorem PRE_setup_early_r0.ncl0B : Conv.ncleanB (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx = true := by
  simp only [Conv.ncleanB, PRE_setup_early_r0.ncl0a0, PRE_setup_early_r0.ncl0o0, PRE_setup_early_r0.ncl0n0, PRE_setup_early_r0.ncl0i0, Bool.and_self]
theorem PRE_setup_early_r0.ncl0 : Conv.NClean (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx := Conv.ncleanB_sound PRE_setup_early_r0.ncl0B

end Host.Load.Run.Tpl
