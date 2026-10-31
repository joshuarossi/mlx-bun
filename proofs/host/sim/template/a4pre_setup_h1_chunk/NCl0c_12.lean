import host.sim.template.a4pre_setup_h1_chunk.H0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_setup_h1_chunk.ncl0n0_2 : ((((PTrie.keysA (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s0.ffi).mlx.nodes).drop 2000).drop 2000).take 2000).all (Conv.nodeOldB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h1_chunk.s0.ffi).mlx) = true
end Host.Load.Run.Tpl
