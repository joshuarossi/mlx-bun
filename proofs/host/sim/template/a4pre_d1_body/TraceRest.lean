import host.sim.template.a4pre_d1_body.TraceFull
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full

theorem applyOk_rest (P : LoadP) (rest : List NumV) :
    applyOk {P with rest := rest} = applyOk P := by
  funext x args
  unfold applyOk
  split <;> rfl

theorem additional_rest (P : LoadP) (rest : List NumV) :
    additionalOk {P with rest := rest} = additionalOk P := by
  funext x name args
  unfold additionalOk
  split
  · change (_ && applyOk {P.raise (mlxOf x).nnext with rest := rest} (mlxOf x) args && _) = _
    rw [applyOk_rest]
  · rfl

theorem smallB_rest (P : LoadP) (rest : List NumV) (VB : Nat → Nat) :
    smallB {P with rest := rest} VB = smallB P VB := by
  funext S x name args
  unfold smallB
  rw [additional_rest]

end Host.Load.Run.Tpl.D1BodyTrace

-- rechecked: literal chunk length
