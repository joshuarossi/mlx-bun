import host.sim.compose.PostCut
import host.sim.compose.a4b.D1BodyFill
set_option Elab.async false
namespace Host.Ts.Sim.Compose.D1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl

def postSingletonPair (x : SegInst FF) : SegInst FF :=
  { x with ν := upd x.ν 10 (F64.ofNat 1) }

theorem postSingletonBook {T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Ctx} {x : SegInst FF}
    (hb : SetupD1.BodyBook π K0 x) (hv : ∀ j, j < 9 → x.ν j = machVal T tk j)
    (hem : x.M.a 2590 = 2590)
    (hi : SetupD1Input.InputAt π (x.M.node 15235) x.t x.C) :
    Post.Book T tk 4096 π π (postSingletonPair x) := by
  obtain ⟨origin, hb, hp⟩ := hb
  refine ⟨by rw [hb.length], hb.vocab, ?_, hb.length, hb.vocab, ?_, ?_, ?_, hb.context, ?_, ?_, ?_, hem, hi⟩
  · rw [hb.length]
    simp
  · intro j
    change ∃ k ≤ loopVB j, upd x.ν 10 (F64.ofNat 1) j = F64.ofNat k
    by_cases hj : j = 10
    · subst j
      exact ⟨1, by decide, rfl⟩
    · rw [upd_other _ _ hj]
      exact hb.valuation j
  · change upd x.ν 10 (F64.ofNat 1) 9 = _
    rw [upd_other _ _ (by decide), hb.singleton, hb.length]
  · rfl
  · change x.K.fr 2665 = _
    rw [hb.frames]
    simpa [D1Continue.framed, Disp.typedK, Disp.Ctx.frameAt, D1Frames.chunk, D1Frames.buffer] using hb.incomingPrompt
  · change x.K.fr D1Frames.chunk = _
    rw [hb.frames]
    simp [D1Continue.framed, Disp.typedK, Disp.Ctx.frameAt, D1Frames.chunk, D1Frames.buffer]
  · intro j hj
    change upd x.ν 10 (F64.ofNat 1) j = _
    rw [upd_other _ _ (by omega)]
    exact hv j hj

end Host.Ts.Sim.Compose.D1First
