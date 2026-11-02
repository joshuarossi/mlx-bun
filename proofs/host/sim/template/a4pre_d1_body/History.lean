import host.sim.compose.a4b.SetupD1Dispatch
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Run.Tpl

/-- The exact initialization book, with its input-data base retained as a suffix
of the current trace base after actual size bridges restart the context. -/
def BodyBook (π : List Nat) (K0 : Host.Ts.Sim.Ctx) (x : SegInst FF) : Prop :=
  ∃ origin : List Event,
    ForwardBook π K0 ⟨x.M, x.ν, { x.K with base' := origin }, x.t, x.C⟩ ∧
    ∃ pre, x.K.base' = pre ++ origin

theorem BodyBook.initial {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {x : SegInst FF}
    (h : ForwardBook π K0 x) : BodyBook π K0 x := by
  exact ⟨x.K.base', h, [], rfl⟩

private theorem rebase {π : List Nat} {K0 K K' : Host.Ts.Sim.Ctx} {M M' : Map}
    {ν : Nat → F64} {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : ForwardBook π K0 ⟨M, ν, K, t, C⟩) (he : Ext M M' n)
    (hfr : K'.fr = K.fr) (hd : K'.D = K.D) (hlo : K'.lo = K.lo) (hhi : K'.hi = K.hi)
    (hb : K'.base' = K.base') : ForwardBook π K0 ⟨M', ν, K', t', C'⟩ := by
  refine ⟨h.length, h.vocab, h.valuation, h.singleton, ?_, h.incoming,
    h.incomingPrompt, h.incomingMemo, hfr.trans h.frames, hd.trans h.offset,
    hlo.trans h.lo, hhi.trans h.hi, ?_⟩
  · change Disp.Kp (D1Frames.typedJ (D1Typed.bytes π)) K' ∧ K'.D ≤ 4096
    simpa only [Disp.Kp, hfr, hd, hlo, hhi] using
      (show Disp.Kp (D1Frames.typedJ (D1Typed.bytes π)) K ∧ K.D ≤ 4096 from h.context)
  · simpa only [hb, he.a] using h.inputEvent

theorem BodyBook.ext {π : List Nat} {K0 K : Host.Ts.Sim.Ctx} {M M' : Map}
    {ν : Nat → F64} {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : BodyBook π K0 ⟨M, ν, K, t, C⟩) (he : Ext M M' n) :
    BodyBook π K0 ⟨M', ν, K, t', C'⟩ := by
  obtain ⟨origin, hb, hp⟩ := h
  exact ⟨origin, rebase hb he rfl rfl rfl rfl rfl, hp⟩

theorem BodyBook.restart {π : List Nat} {K0 K : Host.Ts.Sim.Ctx} {M M' : Map}
    {ν : Nat → F64} {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame} {s : St FF.S} {S : SSrv}
    {e : Event} {base : List Event}
    (h : BodyBook π K0 ⟨M, ν, K, t, C⟩) (he : Ext M M' n)
    (hr : RelB FF FR W [] M ν K s S t C) (ht : t'.trace = e :: t.trace) :
    BodyBook π K0 ⟨M', ν, ⟨K.fr, base, t'.trace, K.D, K.lo, K.hi⟩, t', C'⟩ := by
  obtain ⟨origin, hb, pre, hp⟩ := h
  refine ⟨origin, rebase hb he rfl rfl rfl rfl rfl, ?_⟩
  obtain ⟨fresh, _, hf⟩ := hr.trace
  refine ⟨e :: (fresh.map M.event ++ pre), ?_⟩
  change t'.trace = _
  rw [ht, hf, hp]
  simp only [List.cons_append, List.append_assoc]

theorem BodyBook.inputHistory {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {x : SegInst FF}
    (h : BodyBook π K0 x) :
    ∃ pre asR ret tr, x.K.base' = pre ++
      ⟨chars!"mlx_array_new_data", .jsPtr (x.M.a D1Frames.buffer) 0 (D1Typed.bytes π) :: asR, ret⟩ :: tr := by
  obtain ⟨origin, hb, pre, hp⟩ := h
  obtain ⟨asR, ret, tr, he⟩ := hb.inputEvent
  exact ⟨pre, asR, ret, tr, hp.trans (congrArg (pre ++ ·) he)⟩

end Host.Ts.Sim.Compose.SetupD1

-- rechecked: literal chunk length
