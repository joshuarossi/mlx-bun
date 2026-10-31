import host.sim.template.a4dec_clearFill.H0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearFill.ncl0a0_2 : ((((PTrie.keysA (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx.arrs).drop 2000).drop 2000).take 2000).all (Conv.arrOldB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi).mlx) = true
end Host.Load.Run.Tpl
