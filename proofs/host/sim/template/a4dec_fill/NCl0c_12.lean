import host.sim.template.a4dec_fill.H0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_fill.ncl0n0_3 : (((((PTrie.keysA (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx.nodes).drop 2000).drop 2000).drop 2000).take 2000).all (Conv.nodeOldB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s0.ffi).mlx) = true
end Host.Load.Run.Tpl
