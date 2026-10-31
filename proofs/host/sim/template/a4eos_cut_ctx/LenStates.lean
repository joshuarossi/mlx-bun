import host.sim.compose.a4b.Entry
import host.sim.template.Chain
import host.sim.template.FullWorld
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose
noncomputable def EOSCutCtxLen.input : SSrv := ⟨DEC.tab0, []⟩
set_option interpreter.prefer_native true in
tpl_chain EOSCutCtxLen from DEC.s0, EOSCutCtxLen.input : "/Users/joshrossi/proofdev/devout-sol-eos-framed/len-plan.json" (world := full)
end Host.Load.Run.Tpl
