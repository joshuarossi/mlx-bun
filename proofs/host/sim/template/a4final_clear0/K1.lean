import host.sim.template.a4final_clear0.H0
import host.sim.template.a4final_clear0.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalClear0.stepA2 : interpS (step FinalClear0.F FinalClear0.s4).run FinalClear0.S4 = some (FinalClear0.s5, FinalClear0.S5)
kernel_rfl FinalClear0.patchB2 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalClear0.s5 FinalClear0.S5 (FinalClear0.promptLen)) = some (FinalClear0.s6, FinalClear0.S6)
kernel_rfl FinalClear0.stepA3 : interpS (step FinalClear0.F FinalClear0.s7).run FinalClear0.S7 = some (FinalClear0.s8, FinalClear0.S8)
end Host.Load.Run.Tpl
