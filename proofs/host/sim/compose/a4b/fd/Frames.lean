import host.route.SetupEntry
import host.sim.compose.a4b.fd.FramesDefs
import host.sim.dispatch.BridgeTyped
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDFrames
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

theorem kp_frame {J J' : Disp.JSP FF} {K : Host.Ts.Sim.Ctx} {a : Nat}
    (hlo : J'.lo = J.lo) (hhi : J'.hi = J.hi) (hfs : J'.framed = J.framed ++ [a])
    (h : Disp.KpJ J 4096 K) (p : List Val × List Val) :
    Disp.KpJ J' 4096 (Disp.Ctx.frameAt K a p) := by
  refine ⟨⟨h.1.1.trans hlo.symm, h.1.2.1.trans hhi.symm, fun b => ?_⟩, h.2⟩
  rw [hfs]
  change (bif Nat.beq b a then some p else K.fr b) ≠ none ↔ _
  by_cases hb : b = a
  · subst hb; simp
  · rw [Template.beq_false hb, Bool.cond_false, h.1.2.2]
    simp [hb]

theorem chunk_wp : Disp.Wp chunkJ wideP := by
  intro a w hw
  simpa only [wideP, Disp.wideAt, Disp.lookupW] using hw

theorem typed_wp (bytes : List Byte) (n : Nat) : Disp.Wp (typedJ bytes n) (typedW bytes n) := by
  intro a w hw
  change Disp.lookupW a [(buffer, .buf bytes), (view, .typed .i32 buffer 0 n), (4910, .memo [])] = some w
  have e1 : Nat.beq view buffer = false := by decide
  have e2 : Nat.beq buffer view = false := by decide
  by_cases hv : a = view
  · subst hv
    simpa only [typedW, Disp.wAt, Disp.lookupW, e1, Nat.beq_refl, Bool.cond_true, Bool.cond_false] using hw
  · have ev := Template.beq_false hv
    by_cases hb : a = buffer
    · subst hb
      simpa only [typedW, Disp.wAt, Disp.lookupW, e2, Nat.beq_refl, Bool.cond_true, Bool.cond_false] using hw
    · have eb := Template.beq_false hb
      simpa only [typedW, Disp.wAt, ev, eb, Bool.cond_false, wideP, Disp.lookupW] using hw

end Host.Ts.Sim.Compose.FDFrames
