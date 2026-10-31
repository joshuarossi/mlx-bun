import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ncl0n0_5 : (((((((PTrie.keysA (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (Conv.nodeOldB (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx) = true
end Host.Load.Run.Tpl
