import host.sim.LoopFinal
namespace Host.Ts.Sim
open Host.Ts

/-! # Segment cases

A template case of the prefill chain (design `host-L-design.md` §3.3) is a list of checked
segments separated by bridge steps, ending in a restart (into the case's own start or into
another template's start) or a halt. `LoopCase`, `FinalCase` and `ExitCase` are its instances
with one or two segments and the epilogue's spread as the only bridge.

The statements here are generic in the relation: a boundary of the chain carries a relation
family `SRel F` (`relQ`: `Rel` under a native relation with a predicate of the valuation and
the context; `relXQ` for `RelX`; any other family, e.g. a relation with further frames). The
target side of a related pair is a `SegInst` (map, valuation, context, target state and
server).

* `PieceSim L R R' n s S s' S'`: from `R` at `(s, S)`, `n` target steps reach `R'` at
  `(s', S')`, at the same valuation, under a map extending the start's, with the context and the
  target evolving by the chain's laws `L` (`SegLaws`: preorders `KR` on contexts and `TR` on
  targets, e.g. the growth of the native state).
* `SegChain`: pieces composed; `SegChain.sim`.
* Pieces: a checked run (`PieceSim.ofRunOk`, `ofRunOkRel`), the last step into a state the
  acceptance rejects (`ofLast`), `Rel`/`RelX` conversions, and the bridge steps: any target step
  related to a patched template state (`ofStep`), an `MSim` lemma (`ofMSim`), the framed
  spread (`spread`, `Disp.step_spread_framed`).
* `SegCase L R0 s0 S0 E`: a chain from the start and its ending `E` (`SegTarget`): restart
  into `(s0', S0')` under `R'` with the restart's facts `Post`, or halt. `seg_step` runs it.
* `load_restart`: the load world's restart (`load_step` without its run) after any run whose
  end context is the start's, so a chain of context-keeping pieces restarts with `ShiftJS` and
  `NShift` as a loop case does. -/

/-- The target side of a related pair: the map, the valuation, the context, the target and its
server. -/
structure SegInst (F : Ffi) where
  M : Map
  ν : Nat → F64
  K : Ctx
  t : St F.S
  C : CSrv

/-- A relation family at a template boundary: the target side, the source state and server. -/
abbrev SRel (F : Ffi) := SegInst F → St F.S → SSrv → Prop

/-- How the context and the target may change along a chain. -/
structure SegLaws (F : Ffi) where
  KR : Ctx → Ctx → Prop
  TR : St F.S → St F.S → Prop
  krefl : ∀ K, KR K K
  ktrans : ∀ {K1 K2 K3 : Ctx}, KR K1 K2 → KR K2 K3 → KR K1 K3
  trefl : ∀ t, TR t t
  ttrans : ∀ {t1 t2 t3 : St F.S}, TR t1 t2 → TR t2 t3 → TR t1 t3

section
variable {F : Ffi} {L : SegLaws F}

/-- `x'` is `n` target steps after `x`, at the same valuation, under a map extending `x`'s on the
first `ℓ` references, with the context and the target evolving by `L`. -/
structure SegInst.Step (L : SegLaws F) (n ℓ : Nat) (x x' : SegInst F) : Prop where
  run : runC F n x.t x.C = some (x'.t, x'.C)
  val : x'.ν = x.ν
  ext : Ext x.M x'.M ℓ
  kr : L.KR x.K x'.K
  tr : L.TR x.t x'.t

theorem SegInst.Step.refl (L : SegLaws F) (ℓ : Nat) (x : SegInst F) : x.Step L 0 ℓ x :=
  ⟨rfl, rfl, Ext.refl _ _, L.krefl _, L.trefl _⟩

theorem SegInst.Step.trans {n m ℓ ℓ' : Nat} {x x1 x2 : SegInst F} (h1 : x.Step L n ℓ x1)
    (h2 : x1.Step L m ℓ' x2) (hl : ℓ ≤ ℓ') : x.Step L (n + m) ℓ x2 :=
  ⟨runC_trans h1.run h2.run, h2.val.trans h1.val, h1.ext.trans h2.ext hl, L.ktrans h1.kr h2.kr,
    L.ttrans h1.tr h2.tr⟩

theorem SegInst.Step.le {n ℓ : Nat} {x x' : SegInst F} (h : x.Step L n ℓ x') : CSrv.Le x.C x'.C :=
  runC_le n x.t x.C x'.t x'.C h.run

/-- **A piece of a chain**: from `R` at `(s, S)`, `n` target steps reach `R'` at `(s', S')`. -/
def PieceSim (L : SegLaws F) (R R' : SRel F) (n : Nat) (s : St F.S) (S : SSrv) (s' : St F.S) (S' : SSrv) :
    Prop :=
  ∀ x, R x s S → ∃ x', x.Step L n S.tab.length x' ∧ R' x' s' S'

theorem PieceSim.trans {R R' R'' : SRel F} {n m : Nat} {s s' s'' : St F.S} {S S' S'' : SSrv}
    (h1 : PieceSim L R R' n s S s' S') (h2 : PieceSim L R' R'' m s' S' s'' S'')
    (hl : S.tab.length ≤ S'.tab.length) : PieceSim L R R'' (n + m) s S s'' S'' := by
  intro x hx
  obtain ⟨x1, h1x, hr1⟩ := h1 x hx
  obtain ⟨x2, h2x, hr2⟩ := h2 x1 hr1
  exact ⟨x2, h1x.trans h2x hl, hr2⟩

/-- **A chain of pieces** from `R` at `(s, S)` to `R'` at `(s', S')`; the table only grows. -/
inductive SegChain (L : SegLaws F) : SRel F → St F.S → SSrv → SRel F → St F.S → SSrv → Type where
  | nil (R : SRel F) (s : St F.S) (S : SSrv) : SegChain L R s S R s S
  | cons {R R' R'' : SRel F} {s s' s'' : St F.S} {S S' S'' : SSrv} (n : Nat)
      (sim : PieceSim L R R' n s S s' S') (len : S.tab.length ≤ S'.tab.length)
      (rest : SegChain L R' s' S' R'' s'' S'') : SegChain L R s S R'' s'' S''

/-- The target steps of a chain. -/
def SegChain.n {R R' : SRel F} {s s' : St F.S} {S S' : SSrv} : SegChain L R s S R' s' S' → Nat
  | .nil .. => 0
  | .cons n _ _ rest => n + rest.n

theorem SegChain.len {R R' : SRel F} {s s' : St F.S} {S S' : SSrv} :
    SegChain L R s S R' s' S' → S.tab.length ≤ S'.tab.length
  | .nil .. => Nat.le_refl _
  | .cons _ _ hl rest => Nat.le_trans hl rest.len

/-- **A chain's run.** -/
theorem SegChain.sim {R R' : SRel F} {s s' : St F.S} {S S' : SSrv} :
    (c : SegChain L R s S R' s' S') → PieceSim L R R' c.n s S s' S'
  | .nil .. => fun x hx => ⟨x, SegInst.Step.refl L _ x, hx⟩
  | .cons _ p hl rest => p.trans rest.sim hl

/-! ## Endings and segment cases -/

/-- How a segment case ends: a restart into the start `(s0', S0')` of a template (the case's own
for a self-restart) under `R'`, with facts `Post x x1 x'` of the case's start `x`, end `x1` and
restarted pair `x'`; or a halt. -/
inductive SegTarget (F : Ffi) where
  | restart (R' : SRel F) (s0' : St F.S) (S0' : SSrv) (Post : SegInst F → SegInst F → SegInst F → Prop)
  | halt

/-- The ending's obligation at the chain's end `(sF, SF)` under `Rend`. A restart is a relation
transformation of the end (no target step), knowing the case's start and run. -/
def SegTarget.Ok (L : SegLaws F) (R0 : SRel F) (s0 : St F.S) (S0 : SSrv) (Rend : SRel F) (sF : St F.S)
    (SF : SSrv) : SegTarget F → Prop
  | .restart R' s0' S0' Post => ∀ n x x1, R0 x s0 S0 → x.Step L n S0.tab.length x1 → Rend x1 sF SF →
      ∃ x', x'.t = x1.t ∧ x'.C = x1.C ∧ R' x' s0' S0' ∧ Post x x1 x'
  | .halt => ∀ x, Rend x sF SF → ∃ v, x.t.ctl = .halt (.normal v)

/-- What the ending gives at the target's end `x1` after the start `x`. -/
def SegTarget.Holds : SegTarget F → SegInst F → SegInst F → Prop
  | .restart R' s0' S0' Post, x, x1 => ∃ x', x'.t = x1.t ∧ x'.C = x1.C ∧ R' x' s0' S0' ∧ Post x x1 x'
  | .halt, _, x1 => ∃ v, x1.t.ctl = .halt (.normal v)

/-- **A segment case**: a chain of checked segments and bridges from the template start `(s0, S0)`
under `R0`, and its ending `E`. -/
structure SegCase (L : SegLaws F) (R0 : SRel F) (s0 : St F.S) (S0 : SSrv) (E : SegTarget F) where
  Rend : SRel F
  sF : St F.S
  SF : SSrv
  chain : SegChain L R0 s0 S0 Rend sF SF
  fin : E.Ok L R0 s0 S0 Rend sF SF

/-- The target steps of a case. -/
abbrev SegCase.n {R0 : SRel F} {s0 : St F.S} {S0 : SSrv} {E : SegTarget F} (c : SegCase L R0 s0 S0 E) : Nat :=
  c.chain.n

/-- **A segment case's step.** From `R0` at the start, the target runs the case's steps to a
state related to the chain's end, where the ending holds: the restarted relation at the next
template's start, or a halt. -/
theorem seg_step {R0 : SRel F} {s0 : St F.S} {S0 : SSrv} {E : SegTarget F} (c : SegCase L R0 s0 S0 E)
    {x : SegInst F} (h : R0 x s0 S0) :
    ∃ x1, x.Step L c.n S0.tab.length x1 ∧ c.Rend x1 c.sF c.SF ∧ E.Holds x x1 := by
  obtain ⟨x1, hst, hr⟩ := c.chain.sim x h
  refine ⟨x1, hst, hr, ?_⟩
  have hf := c.fin
  cases E with
  | restart R' s0' S0' Post => exact hf c.n x x1 h hst hr
  | halt => exact hf x1 hr

/-- A restarting case's step. -/
theorem seg_restart {R0 R' : SRel F} {s0 s0' : St F.S} {S0 S0' : SSrv}
    {Post : SegInst F → SegInst F → SegInst F → Prop} (c : SegCase L R0 s0 S0 (.restart R' s0' S0' Post))
    {x : SegInst F} (h : R0 x s0 S0) :
    ∃ x1 x', x.Step L c.n S0.tab.length x1 ∧ c.Rend x1 c.sF c.SF ∧ x'.t = x1.t ∧ x'.C = x1.C ∧
      R' x' s0' S0' ∧ Post x x1 x' := by
  obtain ⟨x1, hst, hr, x', ht, hC, hR, hP⟩ := seg_step c h
  exact ⟨x1, x', hst, hr, ht, hC, hR, hP⟩

/-- A halting case's step: the target halts after the case's steps, and stays there. -/
theorem seg_halt {R0 : SRel F} {s0 : St F.S} {S0 : SSrv} (c : SegCase L R0 s0 S0 .halt) {x : SegInst F}
    (h : R0 x s0 S0) :
    ∃ x1, x.Step L c.n S0.tab.length x1 ∧ c.Rend x1 c.sF c.SF ∧ (∃ v, x1.t.ctl = .halt (.normal v)) ∧
      ∀ m, c.n ≤ m → runC F m x.t x.C = some (x1.t, x1.C) := by
  obtain ⟨x1, hst, hr, v, hv⟩ := seg_step c h
  exact ⟨x1, hst, hr, ⟨v, hv⟩, fun m hm => runC_halted_le hst.run (by rw [hv]; rfl) hm⟩

end

/-! ## The relations of checked boundaries -/

section
variable {F : Ffi}

/-- `Rel` under the native relation `FR`, with a predicate `Q` of the valuation and the context. -/
def relQ (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (Q : (Nat → F64) → Ctx → Prop) : SRel F :=
  fun x s S => Rel F FR x.M x.ν x.K s S x.t x.C ∧ Q x.ν x.K

/-- `RelX` under the native relation `FR`, with `Q`. -/
def relXQ (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (Q : (Nat → F64) → Ctx → Prop) : SRel F :=
  fun x s S => RelX F FR x.M x.ν x.K s S x.t x.C ∧ Q x.ν x.K

/-- Growth of the target along the checked runs of `ok` from a `Q`-related start. -/
def RunTR (L : SegLaws F) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Q : (Nat → F64) → Ctx → Prop) : Prop :=
  ∀ (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St F.S) (S S1 : SSrv) (C C1 : CSrv), Q ν K →
    Rel F FR M ν K s S t C → ok s S = true → runOk F ok n s S = some (s1, S1) → runC F n t C = some (t1, C1) →
    L.TR t t1

/-- Growth of the target along one accepted step from a `Q`-related state, whatever the reached state. -/
def StepTR (L : SegLaws F) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Q : (Nat → F64) → Ctx → Prop) : Prop :=
  ∀ (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St F.S) (S S1 : SSrv) (C C1 : CSrv), Q ν K →
    RelX F FR M ν K s S t C → isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) →
    interpC (step F t).run C = some (t1, C1) → L.TR t t1

/-- One target step of a non-halted state. -/
theorem runC_one {t t1 : St F.S} {C C1 : CSrv} (hh : isHalt t.ctl = false)
    (hs : interpC (step F t).run C = some (t1, C1)) : runC F 1 t C = some (t1, C1) := by
  simp only [runC, runWith_succ, hh, Bool.cond_false, hs, St.rebuild_eq]
  rfl

end

section Pieces
variable {F : Ffi} {L : SegLaws F} {FR : Map → Nat → F.S → F.S → Prop} {Q Q' : (Nat → F64) → Ctx → Prop}
  {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VB : (Nat → F64) → Prop}
  {R R' : SRel F} {n : Nat} {s s' : St F.S} {S S' : SSrv}

/-- **A checked segment** (`runOk`), from `Rel` to `RelX`. -/
theorem PieceSim.ofRunOk (hsim : Disp.StepSimXV F FR ok Kp VB) (hQ : ∀ ν K, Q ν K → Kp K ∧ VB ν)
    (htr : RunTR L FR ok Q) (hok : ok s S = true) (hrun : runOk F ok n s S = some (s', S')) :
    PieceSim L (relQ F FR Q) (relXQ F FR Q) n s S s' S' := by
  rintro ⟨M, ν, K, t, C⟩ ⟨h, hq⟩
  obtain ⟨hK, hν⟩ := hQ ν K hq
  obtain ⟨M', t', C', hr, he, hx⟩ := Disp.runOk_simXV F FR ok Kp VB hsim ν K hK hν n M s S t C s' S' (Or.inl h) hok hrun
  exact ⟨⟨M', ν, K, t', C'⟩, ⟨hr, rfl, he, L.krefl K, htr M ν K n s t s' t' S S' C C' hq h hok hrun hr⟩, hx, hq⟩

/-- **A checked segment** ending at a state that does not return a value, `Rel` to `Rel`. -/
theorem PieceSim.ofRunOkRel (hsim : Disp.StepSimXV F FR ok Kp VB) (hQ : ∀ ν K, Q ν K → Kp K ∧ VB ν)
    (htr : RunTR L FR ok Q) (hok : ok s S = true) (hrun : runOk F ok n s S = some (s', S'))
    (hctl : ∀ v, s'.ctl ≠ .ret v) : PieceSim L (relQ F FR Q) (relQ F FR Q) n s S s' S' := by
  intro x hx
  obtain ⟨x', hst, hx', hq⟩ := PieceSim.ofRunOk hsim hQ htr hok hrun x hx
  exact ⟨x', hst, hx'.rel hctl, hq⟩

/-- **The last step of a segment** into a state its acceptance may reject (`StepSimXL`). -/
theorem PieceSim.ofLast (hsim : Disp.StepSimXL F FR ok Kp VB) (hQ : ∀ ν K, Q ν K → Kp K ∧ VB ν)
    (htr : StepTR L FR ok Q) (hok : ok s S = true) (hh : isHalt s.ctl = false)
    (hs : interpS (step F s).run S = some (s', S')) : PieceSim L (relXQ F FR Q) (relXQ F FR Q) 1 s S s' S' := by
  rintro ⟨M, ν, K, t, C⟩ ⟨h, hq⟩
  obtain ⟨hK, hν⟩ := hQ ν K hq
  obtain ⟨M', t1, C1, ht, he, hx⟩ := hsim M ν K s S t C s' S' hK hν h hh hok hs
  have hth : isHalt t.ctl = false := by rw [h.isHalt, hh]
  exact ⟨⟨M', ν, K, t1, C1⟩, ⟨runC_one hth ht, rfl, he, L.krefl K, htr M ν K s t s' t1 S S' C C1 hq h hh hok hs ht⟩,
    hx, hq⟩

/-- A boundary relation implying another at the same state: a piece of no step. -/
theorem PieceSim.imp (h : ∀ x, R x s S → R' x s S) : PieceSim L R R' 0 s S s S :=
  fun x hx => ⟨x, SegInst.Step.refl L _ x, h x hx⟩

/-- `Rel` is `RelX`. -/
theorem PieceSim.xOfRel : PieceSim L (relQ F FR Q) (relXQ F FR Q) 0 s S s S :=
  PieceSim.imp fun _ hx => ⟨Or.inl hx.1, hx.2⟩

/-- At a state whose top frame is not a statement list, `RelX` is `Rel`. -/
theorem PieceSim.relOfX (hs : ∀ r env fs, s.stack ≠ .s (.block r env) :: fs) :
    PieceSim L (relXQ F FR Q) (relQ F FR Q) 0 s S s S :=
  PieceSim.imp fun _ hx => ⟨hx.1.rel_frame hs, hx.2⟩

/-- **A bridge step**: the target's step from any `R`-related state is related by `R'` to the
patched template state `(s', S')` (the template is only a proof device: `(s', S')` need not be
the template's own step). -/
theorem PieceSim.ofStep
    (h : ∀ x, R x s S → isHalt x.t.ctl = false ∧ ∃ M' K' t1 C1, interpC (step F x.t).run x.C = some (t1, C1) ∧
      Ext x.M M' S.tab.length ∧ L.KR x.K K' ∧ L.TR x.t t1 ∧ R' ⟨M', x.ν, K', t1, C1⟩ s' S') :
    PieceSim L R R' 1 s S s' S' := by
  intro x hx
  obtain ⟨hh, M', K', t1, C1, hs, he, hk, ht, hr⟩ := h x hx
  exact ⟨⟨M', x.ν, K', t1, C1⟩, ⟨runC_one hh hs, rfl, he, hk, ht⟩, hr⟩

/-- **A bridge step from an `MSim` lemma** on the template's own step. -/
theorem PieceSim.ofMSim (hs : interpS (step F s).run S = some (s', S'))
    (h : ∀ x, R x s S → isHalt x.t.ctl = false ∧ MSim (fun M' S1 C1 s1 t1 => Grow x.M x.ν S x.C M' S1 C1 ∧
      ∃ K', L.KR x.K K' ∧ L.TR x.t t1 ∧ R' ⟨M', x.ν, K', t1, C1⟩ s1 S1) S x.C (step F s) (step F x.t)) :
    PieceSim L R R' 1 s S s' S' := by
  refine PieceSim.ofStep fun x hx => ?_
  obtain ⟨hh, hm⟩ := h x hx
  obtain ⟨M', t1, C1, ht, hg, K', hk, htr, hr⟩ := MSim.run hm s' S' hs
  exact ⟨hh, M', K', t1, C1, ht, hg.ext, hk, htr, hr⟩

/-- **The framed spread** (`Disp.step_spread_framed`): the last-element spread of a framed array
`b` into an array literal frames the new array at `s.next`. -/
theorem PieceSim.spread {b : Nat} {acc : List Val} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret (.obj b)) (hst : s.stack = .l (.spread acc [] env) :: fs)
    (hn : s.next + margin < Sim.bound) (hp : Present s aArrayProto)
    (hs : interpS (step F s).run S = some (s', S'))
    (hfr : ∀ ν K, Q ν K → ∃ p, K.fr b = some p)
    (hQ : ∀ (M : Map) ν K pre pre', Q ν K → K.fr b = some (pre, pre') →
      Q' ν (Disp.Ctx.frameAt K s.next (acc.reverse ++ pre, M.vals acc.reverse ++ pre')) ∧
        L.KR K (Disp.Ctx.frameAt K s.next (acc.reverse ++ pre, M.vals acc.reverse ++ pre')))
    (hTR : ∀ t t' : St F.S, t'.ffi = t.ffi → L.TR t t') :
    PieceSim L (relQ F FR Q) (relQ F FR Q') 1 s S s' S' := by
  refine PieceSim.ofMSim hs fun x hx => ?_
  obtain ⟨h, hq⟩ := hx
  obtain ⟨⟨pre, pre'⟩, hb⟩ := hfr _ _ hq
  have hth : isHalt x.t.ctl = false := by rw [h.ctl, hc]; rfl
  refine ⟨hth, ?_⟩
  have hm := Disp.step_spread_framed h hc hst hb hn hp
  refine hm.mono fun M' S1 C1 s1 t1 ⟨hg, hr, hffi⟩ => ⟨hg, Disp.Ctx.frameAt x.K s.next (acc.reverse ++ pre,
    x.M.vals acc.reverse ++ pre'), (hQ x.M _ _ _ _ hq hb).2, hTR _ _ hffi, hr, (hQ x.M _ _ _ _ hq hb).1⟩

end Pieces

/-! ## The load world's restart after a run keeping the context -/

/-- **The load world's restart.** After any `n`-step target run from a related template start to a
related end under the same context (`load_step`'s premises without its checked run: e.g. a chain of
context-keeping pieces), the target is related to the template start again: under the restart map
with the fresh handles reassigned, at the substituted valuation with the next readback `v` bound to
`v17`, for the remaining readbacks `r`; the target's counters advance by the template's. -/
theorem load_restart {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K : Ctx}
    {s0 s1 t t1 : St LF.S} {S0 S1 : SSrv} {C C1 : CSrv} {n : Nat}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (h : Rel LF (LR P r0) M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC LF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length) (h1 : Rel LF (LR P r0) M1 ν K s1 S1 t1 C1)
    (htab : ∀ e ∈ S1.tab, e.noVar 17 = true) (hor : ∀ q ∈ S1.oracle, q.noVar 17 = true)
    (hshift : Shift LF (FSn { P with rest := r0 } S0.tab.length s0.ffi) σ θ K s0 S0 s1
      ⟨S1.tab ++ [.var 17], S1.oracle⟩)
    (hσ : σ.num 79 = .ref S1.tab.length) (htok : s0.ffi.mlx.tokens = [.ref 79]) (h79 : 79 < S0.tab.length)
    (hbig : bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true)
    (hfree : NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : s1.ffi.mlx.next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hroomN : t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62) :
    t1.next = t.next + (s1.next - s0.next) ∧
      t1.ffi.mlx.next = t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) ∧
      t1.ffi.mlx.nnext = t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) ∧
      Rel LF (LR P r)
        ((((M1.setNum S1.tab.length v).after σ)).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next)
        (Shift.valuation θ (upd ν 17 x))
        ⟨Shift.framedNext (M1.setNum S1.tab.length v) K s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 := by
  subst hr0
  have hns : NShift { P with rest := v :: r } S0.tab.length σ s0.ffi s1.ffi := hshift.ffi.2
  have hl := lockstep h.ffi h1.ffi hext rfl hns.mlx.hnext.2 hE hns.mlx.nle
  have hoff : t1.next = t.next + (s1.next - s0.next) := by
    have := h1.offset; have := h.offset; have := hshift.grows; omega
  have htk : t1.ffi.mlx.tokens = v :: r := by
    have := h1.ffi.mlx.tokensX
    rw [hns.mlx.tokens] at this
    simpa using this
  have hvx : C1.val v = some x := (runC_le n t C t1 C1 hrc).val hx
  have hw : LoadRw { P with rest := v :: r } (M1.setNum S1.tab.length v) (S1.tab.length + 1)
      (clearTokens s1.ffi) t1.ffi := by
    rw [clearTokens_nil hns.mlx.tokens]
    exact (((loadR_laws _).stable _ _ _ _ _ h1.ffi (Map.setNum_ext M1 S1.tab.length v)).mono
      (Nat.le_succ _)).weak
  have hroom : t1.next - s0.next < Sim.bound := by
    rw [hoff]; have := h.offset; have := hshift.grows; omega
  have hf : FRr { P with rest := v :: r } s0.ffi (M1.setNum S1.tab.length v) (S1.tab.length + 1) s1.ffi t1.ffi := by
    refine ⟨hw, ?_, ?_⟩
    · show t1.ffi.mlx.next + (P.E - s0.ffi.mlx.next) < 2 ^ 46
      rw [hl.1]; omega
    · show t1.ffi.mlx.nnext + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62
      rw [hl.2]; omega
  have h2 := (h1.extendVar (loadR_laws _) htab hor hvx).mapFR (FR' := FRr { P with rest := v :: r } s0.ffi)
    (by simpa using hf)
  have hrel := restart (F := LF) (FR := FRr { P with rest := v :: r } s0.ffi)
    (FS := FSn { P with rest := v :: r } S0.tab.length s0.ffi) _ σ _ θ K s0 s1 t1 ⟨S0.tab, []⟩ _ C1
    (fun x y z hxy hyz => by simpa using fsn_compose _ x y z hxy (by simpa using hyz)) h2
    (hshift.withOracle []) (fun _ hq => by cases hq) hroom
  refine ⟨hoff, hl.1, hl.2, ?_⟩
  -- reassign the fresh handle images
  have hw0 := hrel.ffi.1
  have hz : t1.ffi.mlx.tokens = s0.ffi.mlx.tokens.map ((M1.setNum S1.tab.length v).after σ).nv ++ r := by
    rw [htk, htok]
    simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, Map.nv]
    show v :: r = (M1.setNum S1.tab.length v).nv (σ.num 79) :: r
    rw [hσ]
    simp [Map.nv, Map.setNum_self]
  have hffi := LoadRw.rebig hw0 hbig (fun t ht => by rw [htok] at ht; simp at ht; subst ht; exact h79) hz
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

end Host.Ts.Sim
