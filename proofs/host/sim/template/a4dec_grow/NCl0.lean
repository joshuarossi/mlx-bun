import host.sim.template.a4dec_grow.NCl0c_0
import host.sim.template.a4dec_grow.NCl0c_1
import host.sim.template.a4dec_grow.NCl0c_2
import host.sim.template.a4dec_grow.NCl0c_3
import host.sim.template.a4dec_grow.NCl0c_4
import host.sim.template.a4dec_grow.NCl0c_5
import host.sim.template.a4dec_grow.NCl0c_6
import host.sim.template.a4dec_grow.NCl0c_7
import host.sim.template.a4dec_grow.NCl0c_8
import host.sim.template.a4dec_grow.NCl0c_9
import host.sim.template.a4dec_grow.NCl0c_10
import host.sim.template.a4dec_grow.NCl0c_11
import host.sim.template.a4dec_grow.NCl0c_12
import host.sim.template.a4dec_grow.NCl0c_13
import host.sim.template.a4dec_grow.NCl0c_14
import host.sim.template.a4dec_grow.NCl0c_15
import host.sim.template.a4dec_grow.NCl0c_16
import host.sim.template.a4dec_grow.NCl0c_17
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The native bookkeeping at the start of chain `DEC_grow`: the full check (`Conv.ncleanB`), in chunks. -/

kernel_rfl DEC_grow.ncl0a0_end : ((((((((PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.arrs).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_grow.ncl0a0 : (PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.arrs).all (Conv.arrOldB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) = true :=
  all_take_drop 2000 DEC_grow.ncl0a0_0 (all_take_drop 2000 DEC_grow.ncl0a0_1 (all_take_drop 2000 DEC_grow.ncl0a0_2 (all_take_drop 2000 DEC_grow.ncl0a0_3 (all_take_drop 2000 DEC_grow.ncl0a0_4 (all_take_drop 2000 DEC_grow.ncl0a0_5 (all_take_drop 2000 DEC_grow.ncl0a0_6 (all_take_drop 2000 DEC_grow.ncl0a0_7 (all_of_nil DEC_grow.ncl0a0_end))))))))
kernel_rfl DEC_grow.ncl0o0_end : (PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs).drop 2000 = []
theorem DEC_grow.ncl0o0 : (PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.objs).all (Conv.objOldB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) = true :=
  all_take_drop 2000 DEC_grow.ncl0o0_0 (all_of_nil DEC_grow.ncl0o0_end)
kernel_rfl DEC_grow.ncl0n0_end : ((((((((PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_grow.ncl0n0 : (PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.nodes).all (Conv.nodeOldB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) = true :=
  all_take_drop 2000 DEC_grow.ncl0n0_0 (all_take_drop 2000 DEC_grow.ncl0n0_1 (all_take_drop 2000 DEC_grow.ncl0n0_2 (all_take_drop 2000 DEC_grow.ncl0n0_3 (all_take_drop 2000 DEC_grow.ncl0n0_4 (all_take_drop 2000 DEC_grow.ncl0n0_5 (all_take_drop 2000 DEC_grow.ncl0n0_6 (all_take_drop 2000 DEC_grow.ncl0n0_7 (all_of_nil DEC_grow.ncl0n0_end))))))))
kernel_rfl DEC_grow.ncl0i0_end : (PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.items).drop 2000 = []
theorem DEC_grow.ncl0i0 : (PTrie.keysA (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx.items).all (Conv.itemOldB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx) = true :=
  all_take_drop 2000 DEC_grow.ncl0i0_0 (all_of_nil DEC_grow.ncl0i0_end)
theorem DEC_grow.ncl0B : Conv.ncleanB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx = true := by
  simp only [Conv.ncleanB, DEC_grow.ncl0a0, DEC_grow.ncl0o0, DEC_grow.ncl0n0, DEC_grow.ncl0i0, Bool.and_self]
theorem DEC_grow.ncl0 : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_grow.s0.ffi).mlx := Conv.ncleanB_sound DEC_grow.ncl0B

end Host.Load.Run.Tpl
