import host.route.SingletonStart
import host.sim.compose.a4b.D1BodyFill
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Compose

/-- The loaded singleton completes its checked forward, retaining the saved input and driver facts. -/
theorem singleton_forward (NB T : Nat) (tk : Nat → Nat) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk 1)
      (D1First.returnedSavedCut NB T tk) 1544195 :=
  ((singleton_start NB T tk).trans (D1First.saved_forward_returned NB T tk)).cast rfl rfl rfl

end Host.Route
