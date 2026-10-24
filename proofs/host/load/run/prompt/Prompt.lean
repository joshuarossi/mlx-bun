import host.load.run.prompt.Run
import host.load.run.prompt.Boot
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load

set_option maxRecDepth 1000000 in
/-- **The boot of the route for every prompt**: booting `RoutePrompt.cx π` and running the
28172201 load steps reaches `loadDone` with the prompt array holding `π`. -/
theorem boot_prompt (π : List Nat) :
    (bootL (RoutePrompt.cx π) Decode.world 2000).bind (fun s => runS P.F 28172201 s P.S0) =
      some (P.a2818 (π.map natV), P.S2818) := by
  rw [show RoutePrompt.cx π = RoutePrompt.cxV (π.map natV) from rfl, boot]
  exact (Option.bind_some _ _).trans (P.absRun (π.map natV))

end Host.Load.Run.Prompt
