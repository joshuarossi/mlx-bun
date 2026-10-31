import host.sim.compose.a4b.Entry
import host.sim.template.Split
import host.sim.template.Bridges
import host.sim.template.FullWorld
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Compose
noncomputable def FinalEos0Base.s0 := DEC.s0
noncomputable def FinalEos0Base.S0 : SSrv := ⟨DEC.tab0, []⟩
def FinalEos0.promptLen : SymE := .bin .sub (.bin .sub (.var 9) (.var 10)) litOne
set_option interpreter.prefer_native true in
tpl_case_split FinalEos0 from FinalEos0Base : "FINALE"
  bridging (Bridge.routeBridges { kinds := ["len", "spread"], lens := [(2665, FinalEos0.promptLen)] })
(world := full, spec := "/Users/joshrossi/proofdev/devout-sol-final-eos0/spec.json", cap := 2500)
end Host.Load.Run.Tpl
