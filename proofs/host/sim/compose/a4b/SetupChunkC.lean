import host.sim.compose.a4b.FillSetupCall
import host.sim.compose.Literal

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupChunk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

kernel_rfl chunkLiteral6 : PRE_setup_early_r0.s6.ctl = .ret (.num (.lit (F64.ofNat 2048)))
kernel_rfl chunkFresh10 : (PRE_setup_early_r0.S6.tab.all fun e => e.noVar 10) = true

/-- The canonical heap's numeric references precede the C entry. -/
def baseNums : Prop := ∀ a o, PRE_setup_early_r0.s6.heap.get a = some o →
  Supp.hobj (fun _ => True) 10 o

end Host.Ts.Sim.Compose.SetupChunk
