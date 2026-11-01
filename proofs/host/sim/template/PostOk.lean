import host.sim.template.a4pre_post_head.Small
import host.sim.template.Ghosts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # POST's acceptance: only the prompt framed

POST reads no chunk, buffer or view (its bridges are array sizes and the prompt's length), and those frames' addresses differ
from one final forward to the next, while a compaction can't move a frame. So POST frames the prompt, the wide memo and the ghosts alone,
with `PostHeadSmall`'s row-singleton smallness. `okF` adds the arrays a tail's spread frames. -/

namespace Host.Load.Run.Tpl.PostOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

/-- Before POST's shared cut: the head compiles the sampler, which writes the trace registry, so only the pre-final ghosts are framed. -/
abbrev J0 : Disp.JSP FF :=
  { fullJSPPXS setupP (2665 :: ghostPf) wideListPf with smallB := PostHeadSmall.smallFX2 }

noncomputable def ok0 : St FF.S → SSrv → Bool :=
  Disp.okJSJ J0 (okBackFXS setupP) 4096

theorem wp0 : Disp.Wp J0 wideGPf := fun _ _ hw => hw

abbrev J : Disp.JSP FF :=
  { fullJSPPXS setupP (2665 :: ghostAddrs) wideList with smallB := PostHeadSmall.smallFX2 }

noncomputable def ok : St FF.S → SSrv → Bool :=
  Disp.okJSJ J (okBackFXS setupP) 4096

abbrev JF (extra : List Nat) : Disp.JSP FF := { J with framed := 2665 :: (ghostAddrs ++ extra) }

noncomputable def okF (extra : List Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (JF extra) (okBackFXS setupP) 4096

theorem wp : Disp.Wp J wideG := fun _ _ hw => hw

theorem wpF (extra : List Nat) : Disp.Wp (JF extra) wideG := wp

end Host.Load.Run.Tpl.PostOk
