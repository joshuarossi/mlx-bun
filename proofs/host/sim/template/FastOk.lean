import host.sim.full.RunFast
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.Stage

/-! # The parameterized acceptances over the fast table

`bodyOk` and `typedOk`, and a stage's `okLocal`, over `FSrv`: what the generated chunks are checked at. -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

/-- `okLocal` over `FSrv`. -/
def okLocalN {S : Type} (ok : St S → FSrv → Bool) (s : St S) (c : FSrv) : Bool := ok s c && Disp.localB s

theorem okLocalN_ok {S : Type} {ok : St S → SSrv → Bool} {okN : St S → FSrv → Bool}
    (h : ∀ s c, FSrv.Wf c → okN s c = ok s c.toS) (s : St S) (c : FSrv) (hw : c.Wf) :
    okLocalN okN s c = okLocal ok s c.toS := by
  unfold okLocalN okLocal
  rw [h s c hw]

end Host.Ts.Sim.Template

namespace Host.Ts.Sim.Compose.VWFrames
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

noncomputable def bodyOkN (bytes : List Byte) (n : Nat) : St FF.S → FSrv → Bool :=
  Disp.okJSJN (typedJ bytes n) (okBackFXS setupP) bodyD0 (smallFX2F loopVB)

theorem bodyOkN_ok (bytes : List Byte) (n : Nat) (s : St FF.S) (c : FSrv) (h : c.Wf) :
    bodyOkN bytes n s c = bodyOk bytes n s c.toS :=
  Disp.okJSJN_eq (typedJ bytes n) (okBackFXS setupP) bodyD0 (fun _ x name args hw => smallFX2F_eq loopVB hw x name args) s h

noncomputable def typedOkN (bytes : List Byte) (n : Nat) : St FF.S → FSrv → Bool :=
  Disp.okJSJN (typedJ bytes n) (okBackFXS setupP) 4096 (smallFX2F loopVB)

theorem typedOkN_ok (bytes : List Byte) (n : Nat) (s : St FF.S) (c : FSrv) (h : c.Wf) :
    typedOkN bytes n s c = typedOk bytes n s c.toS :=
  Disp.okJSJN_eq (typedJ bytes n) (okBackFXS setupP) 4096 (fun _ x name args hw => smallFX2F_eq loopVB hw x name args) s h

end Host.Ts.Sim.Compose.VWFrames
