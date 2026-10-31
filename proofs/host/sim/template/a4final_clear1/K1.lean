import host.sim.template.a4final_clear1.H0
import host.sim.template.a4final_clear1.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalClear1.stepA2 : interpS (step FinalClear1.F FinalClear1.s4).run FinalClear1.S4 = some (FinalClear1.s5, FinalClear1.S5)
kernel_rfl FinalClear1.patchB2 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalClear1.s5 FinalClear1.S5 (FinalClear1.promptLen)) = some (FinalClear1.s6, FinalClear1.S6)
kernel_rfl FinalClear1.stepA3 : interpS (step FinalClear1.F FinalClear1.s7).run FinalClear1.S7 = some (FinalClear1.s8, FinalClear1.S8)
end Host.Load.Run.Tpl
