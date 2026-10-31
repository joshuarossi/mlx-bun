import host.sim.compose.a4b.Entry
import host.sim.template.Split
import host.sim.template.Bridges
import host.sim.template.FullWorld
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose
noncomputable def FinalPlainBase.s0 := DEC.s0
noncomputable def FinalPlainBase.S0 : SSrv := ⟨DEC.tab0, []⟩
def FinalPlain.promptLen : SymE := .bin .sub (.bin .sub (.var 9) (.var 10)) litOne
set_option interpreter.prefer_native true in
tpl_case_split FinalPlain from FinalPlainBase : "FINAL"
  bridging (Bridge.routeBridges { kinds := ["len", "spread"], lens := [(2665, FinalPlain.promptLen)] })
(world := full, spec := "/Users/joshrossi/proofdev/devout-sol-final-plain/spec.json", cap := 2500)
end Host.Load.Run.Tpl
