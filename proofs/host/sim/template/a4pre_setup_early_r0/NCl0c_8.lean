import host.sim.template.a4pre_setup_early_r0.H0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_setup_early_r0.ncl0o0_0 : ((PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx.objs).take 2000).all (Conv.objOldB (⟨18151, 15235, 2673202, 9⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_early_r0.s0.ffi).mlx) = true
end Host.Load.Run.Tpl
