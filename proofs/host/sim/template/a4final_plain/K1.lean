import host.sim.template.a4final_plain.H0
import host.sim.template.a4final_plain.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl FinalPlain.stepA2 : interpS (step FinalPlain.F FinalPlain.s4).run FinalPlain.S4 = some (FinalPlain.s5, FinalPlain.S5)
kernel_rfl FinalPlain.patchB2 : some (Host.Ts.Sim.Template.Bridge.lenPatch FinalPlain.s5 FinalPlain.S5 (FinalPlain.promptLen)) = some (FinalPlain.s6, FinalPlain.S6)
kernel_rfl FinalPlain.stepA3 : interpS (step FinalPlain.F FinalPlain.s7).run FinalPlain.S7 = some (FinalPlain.s8, FinalPlain.S8)
end Host.Load.Run.Tpl
