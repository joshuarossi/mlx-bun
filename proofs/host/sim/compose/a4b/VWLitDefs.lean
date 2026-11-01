import host.sim.dispatch.OkLit
import host.sim.template.FastOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The body's acceptance over a literal prompt length

A forward whose row count is a literal reaches `arange`'s checks, `Number.isInteger` of literals and a cache key
printed from literals. `VWFrames.bodyLitOk` is `bodyOk` with those steps (`Disp.okJSLit`), `bodyLitOkN` the same over
the fast table. The one-step theorems are in `host.sim.compose.a4b.VWLit`. -/

namespace Host.Ts.Sim.Compose.VWFrames
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

noncomputable def bodyLitOk (bytes : List Byte) (n : Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSLit (typedJ bytes n) (okBackFXS setupP) bodyD0

/-- `Disp.okJSLit` over `FSrv`. -/
noncomputable def bodyLitOkN (bytes : List Byte) (n : Nat) (s : St FF.S) (c : FSrv) : Bool :=
  bodyOkN bytes n s c || Disp.isIntLitB s || Disp.tmplLitB s

theorem bodyLitOkN_ok (bytes : List Byte) (n : Nat) (s : St FF.S) (c : FSrv) (h : c.Wf) :
    bodyLitOkN bytes n s c = bodyLitOk bytes n s c.toS := by
  unfold bodyLitOkN
  rw [bodyOkN_ok bytes n s c h]
  rfl

/-- Everything `bodyOk` accepts `bodyLitOk` accepts. -/
theorem bodyOk_lit {bytes : List Byte} {n : Nat} {s : St FF.S} {S : SSrv} (h : bodyOk bytes n s S = true) :
    bodyLitOk bytes n s S = true :=
  Disp.okJSJ_lit h

end Host.Ts.Sim.Compose.VWFrames
