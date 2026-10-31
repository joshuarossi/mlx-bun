import host.sim.template.a4final_eos1.H0
import host.sim.template.a4final_eos1.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalEos1.stepA2 : interpS (step FinalEos1.F FinalEos1.s4).run FinalEos1.S4 = some (FinalEos1.s5, FinalEos1.S5)
kernel_rfl FinalEos1.patchB2 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalEos1.s5 FinalEos1.S5 (FinalEos1.promptLen)) = some (FinalEos1.s6, FinalEos1.S6)
kernel_rfl FinalEos1.stepA3 : interpS (step FinalEos1.F FinalEos1.s7).run FinalEos1.S7 = some (FinalEos1.s8, FinalEos1.S8)
end Host.Load.Run.Tpl
