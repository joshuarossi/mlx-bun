import host.sim.template.Chain
import host.sim.template.FullWorld
import host.load.run.prompt.H88
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Scratch (track A4, Phase B): the prompt route from `loadDone` (a 102-token prompt) to the call of the VW forward
closure (h2671722: the 101-row tail), full world. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain VW0 from Host.Load.Run.Prompt.P.a2818, Host.Load.Run.Prompt.P.S2818 : "{\"stop\": \"call:#2671722\", \"frames\": [], \"wide\": [[4910, \".memo []\"]]}" (world := full, arg := ((List.replicate 102 9707).map Host.Ts.natV))

end Host.Load.Run.Tpl
