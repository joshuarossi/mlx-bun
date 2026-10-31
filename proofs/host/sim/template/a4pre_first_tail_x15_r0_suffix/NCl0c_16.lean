import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_suffix.ncl0n0_4 : ((((((PTrie.keysA (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx.nodes).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (Conv.nodeOldB (⟨21966, 19057, 2825025, 8226⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s0.ffi).mlx) = true
end Host.Load.Run.Tpl
