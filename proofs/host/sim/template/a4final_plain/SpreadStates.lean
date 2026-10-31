import host.sim.template.a4final_plain.H0
import host.sim.template.Chain
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option interpreter.prefer_native true in
tpl_chain FinalPlainSp from FinalPlain.s6, FinalPlain.S6 : "/Users/joshrossi/proofdev/devout-sol-final-plain/spread-plan.json" (world := full)
end Host.Load.Run.Tpl
