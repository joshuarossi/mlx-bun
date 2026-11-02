import host.sim.template.PostOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # POST's acceptance before its shared cut, a final forward's chunk still framed

The frame that holds `const chunk` (`executeMlxPrefillStep`) waits on the forward, so at POST's entry the chunk is live, its template elements empty
and the target's the tokens. POST reads it no more; it frames it until that frame has returned, and the tail's link drops it. -/

namespace Host.Load.Run.Tpl.PostOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

abbrev J0F (extra : List Nat) : Disp.JSP FF := { J0 with framed := 2665 :: 4910 :: (ghostPf ++ extra) }

noncomputable def okF0 (extra : List Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (J0F extra) (okBackFXS setupP) 4096

theorem wpF0 (extra : List Nat) : Disp.Wp (J0F extra) wideGPf := wp0

end Host.Load.Run.Tpl.PostOk
