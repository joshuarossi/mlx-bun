import host.sim.template.a4pre_post_head.Small
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # POST's acceptance: only the prompt framed

POST reads no chunk, buffer or view (its bridges are array sizes and the prompt's length), and those frames' addresses differ
from one final forward to the next, while a compaction can't move a frame. So POST frames the prompt (and the wide memo) alone,
with `PostHeadSmall`'s row-singleton smallness. `okF` adds the arrays a tail's spread frames. -/

namespace Host.Load.Run.Tpl.PostOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

abbrev J : Disp.JSP FF :=
  { fullJSPPXS setupP [2665] [(4910, .memo [])] with smallB := PostHeadSmall.smallFX2 }

noncomputable def ok : St FF.S → SSrv → Bool :=
  Disp.okJSJ J (okBackFXS setupP) 4096

abbrev JF (extra : List Nat) : Disp.JSP FF := { J with framed := 2665 :: extra }

noncomputable def okF (extra : List Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (JF extra) (okBackFXS setupP) 4096

theorem wp : Disp.Wp J wideP := by
  intro a w hw
  simpa only [wideP, Disp.wideAt, Disp.lookupW] using hw

theorem wpF (extra : List Nat) : Disp.Wp (JF extra) wideP := wp

end Host.Load.Run.Tpl.PostOk
