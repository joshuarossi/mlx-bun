import host.sim.template.a4final_eos0.H0
import host.sim.template.a4final_eos0.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalEos0.stepA2 : interpS (step FinalEos0.F FinalEos0.s4).run FinalEos0.S4 = some (FinalEos0.s5, FinalEos0.S5)
kernel_rfl FinalEos0.patchB2 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalEos0.s5 FinalEos0.S5 (FinalEos0.promptLen)) = some (FinalEos0.s6, FinalEos0.S6)
kernel_rfl FinalEos0.stepA3 : interpS (step FinalEos0.F FinalEos0.s7).run FinalEos0.S7 = some (FinalEos0.s8, FinalEos0.S8)
end Host.Load.Run.Tpl
