import host.sim.template.Chain
import host.sim.template.FullWorld
import host.load.run.prompt.H88
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! Scratch (track A4 measurement): the prefill of a 100-token prompt from the prompt boot's `loadDone`, in
the full stack, cut at its SSM window calls (`SSMCache.recurWindow`), to the first decode recurrence. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_chain FSSM from Host.Load.Run.Prompt.P.a2818, Host.Load.Run.Prompt.P.S2818 : "{\"stages\": [{\"fn\": \"recurWindow\", \"piece\": \"ssmW\"}], \"stop\": \"call:recurDecode\", \"frames\": [], \"wide\": [[4910, \".memo []\"]]}" (world := full, arg := ((List.replicate 100 9707).map Host.Ts.natV))

end Host.Load.Run.Tpl
