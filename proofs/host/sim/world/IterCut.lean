import host.sim.world.Route
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # A decode iteration across cuts: its last piece restarts into the decode cut

A regenerated decode iteration runs through cuts: glue pieces between them (`XCase`), and the stage
calls (readback, D1 forward, sample, asyncEval) as 0-step conversions around the stage's cut step
(`host.sim.conv.Call`: `cut_isolate`, `cut_stage`, `cut_merge`). Only its last cut restarts into
the decode cut, and the restart needs the iteration's start: the template start's relation and the
decode cut's bookkeeping there. This is the decode loop's counterpart of `LoadPostW`/`book_stepW`.

* `IterGhostW … x0 x`: the pair `x` is reached within one iteration from its start pair `x0`: the
  map extends `x0`'s on the loop table, the context is `x0`'s, the valuation gives the loop table
  `x0`'s values, before and after the restart's substitution `θ` (only what the restart reads), the
  mlx state grew. `IterGhostW.refl`, `IterGhostW.step` (a chain piece under `loopLawsW`),
  `IterGhostW.conv` (a conversion), `IterGhostW.merge` (a stage's merge: the caller's context, its
  map extended on the loop table, only fresh variables bound, which the loop table and its
  substitution by `θ` do not read, the mlx growth), `IterGhostW.mergeQ` (the same in the shape of
  `cut_merge`'s `hQ`, the growth from an `NK` that implies it).
* `iterStartW … i x0`: the decode cut at `i` at the start pair `x0` only; `iterEndW … c i x0`: the
  iteration's end template `c.s1` under the world's relation with iteration `i`'s remaining
  readbacks, at its server `c.S1`, with the ghost. `iterEnd_ok`: a chain ending at `(c.s1, c.S1)`
  restarts into `iterEndW` with no change (the last glue piece's `fin`).
* `LoopGStepCW`: the graph obligation across cuts (the end pair at its own valuation, with the ghost).
* `decodeIter_piecesW`: **for every start pair, cut steps from `iterStartW` to `iterEndW` (any
  composition of pieces and conversions carrying the ghost) discharge the per-iteration
  contract**: the world's restart at the end (`LoopCaseW.restartW`) and the bookkeeping of
  `loop_stepW`.

**Through compactions.** A compaction after a stage merge (`host.sim.conv.Compact`) moves the map's
fresh part, resets the context's offset and absorbs the framed arrays' appended elements into the
frames, so the end's map no longer extends the start's. The iteration then restarts from its end
relation alone (`World.EndLaws.restartE`), and the ghost carries what the end reads instead:

* `GhostP`: the virtual start's counters and the growth and `emitted` elements absorbed before it
  (`GhostP.init`, `GhostP.compact`); `IterGhostCW … g x0 x`: the frames (`forwarded` extended, the
  absorbed `emitted` elements appended), the band, the offset from the virtual start, the loop
  table's numbers, the addresses `fixA`, the start's nodes, the target's mlx counters at the
  virtual start's fresh handles and nodes, the loop table's values before and after `θ`, the
  growth. `IterGhostCW.start` (from the start relation), `.conv`, `.step`, `.merge`, `.mergeQ`,
  `.site` (the shapes of `IterGhostW`'s and of `site_ghost`), `.compact` (across a compaction, at
  `full_compact`'s data); `IterGhostW.toC`: the no-compaction ghost is one.
* `IterEndW`: the end template (`LoopCaseW` without start server and steps, its `emitted` array
  extended by what no compaction absorbed; `LoopCaseW.toEnd`), `IterEndW.ShiftFW`, `.Within` (the
  deltas from the ghost's data), `KeepsAtW`, `framedNext_frAt`; `iterEndCW`, `LoopGStepGW`.
* `decodeIter_piecesCW`: **cut steps from `iterStartW` to `iterEndCW` (pieces, stage calls and
  compactions carrying `IterGhostCW`) discharge the per-iteration contract**. -/

/-- **The iteration's ghost**: `x` is reached within one decode iteration from its start pair `x0`
(see the module doc). -/
structure IterGhostW (Wd : World) (A : Addr) (θ : Nat → SymE) (tab0 : List SymE) (x0 x : SegInst Wd.F) : Prop where
  ext : Ext x0.M x.M tab0.length
  ctx : x.K = x0.K
  tab : ∀ j e, nth? tab0 j = some e → e.eval x.ν = e.eval x0.ν
  val : ∀ v j e, nth? tab0 j = some e →
    e.eval (Shift.valuation θ (upd x.ν A.nxt v)) = e.eval (Shift.valuation θ (upd x0.ν A.nxt v))
  grows : Wd.Grows x0.t x.t

section Ghost
variable {Wd : World} {A : Addr} {θ : Nat → SymE} {tab0 : List SymE} {x0 x x1 : SegInst Wd.F}

theorem IterGhostW.refl (x : SegInst Wd.F) : IterGhostW Wd A θ tab0 x x :=
  ⟨Ext.refl _ _, rfl, fun _ _ _ => rfl, fun _ _ _ _ => rfl, World.Grows.refl Wd _⟩

/-- A chain piece keeps the ghost. -/
theorem IterGhostW.step (h : IterGhostW Wd A θ tab0 x0 x) {n ℓ : Nat} (hs : x.Step (loopLawsW Wd) n ℓ x1)
    (hl : tab0.length ≤ ℓ) : IterGhostW Wd A θ tab0 x0 x1 where
  ext := h.ext.trans hs.ext hl
  ctx := hs.kr.trans h.ctx
  tab j e he := by rw [hs.val]; exact h.tab j e he
  val v j e he := by rw [hs.val]; exact h.val v j e he
  grows := World.Grows.trans Wd h.grows hs.tr

/-- **A conversion keeps the ghost** when it keeps the context, extends the map on the loop table,
agrees with the valuation on the loop table and on what `θ` reads, and grows the mlx state (a
stage's merge, `cut_merge`). -/
theorem IterGhostW.conv (h : IterGhostW Wd A θ tab0 x0 x) {x' : SegInst Wd.F} (he : Ext x.M x'.M tab0.length)
    (hk : x'.K = x.K) (htab : ∀ j e, nth? tab0 j = some e → e.eval x'.ν = e.eval x.ν)
    (hval : ∀ v j e, nth? tab0 j = some e →
      e.eval (Shift.valuation θ (upd x'.ν A.nxt v)) = e.eval (Shift.valuation θ (upd x.ν A.nxt v)))
    (hg : Wd.Grows x.t x'.t) : IterGhostW Wd A θ tab0 x0 x' where
  ext := h.ext.trans he (Nat.le_refl _)
  ctx := hk.trans h.ctx
  tab j e hj := (htab j e hj).trans (h.tab j e hj)
  val v j e he := (hval v j e he).trans (h.val v j e he)
  grows := World.Grows.trans Wd h.grows hg

/-- Valuations agreeing off `V` give the same value to an expression mentioning no variable of `V`. -/
theorem SymE.eval_congrW {ν ν' : Nat → F64} {V : Nat → Prop} (hν : ∀ v, ¬ V v → ν' v = ν v) :
    ∀ e : SymE, (∀ w, V w → e.noVar w = true) → e.eval ν' = e.eval ν
  | .lit _, _ => rfl
  | .var i, h => by
    show ν' i = ν i
    refine hν i fun hv => ?_
    have := h i hv
    simp [SymE.noVar] at this
  | .bin op a b, h => by
    show F64.bin op (a.eval ν') (b.eval ν') = F64.bin op (a.eval ν) (b.eval ν)
    rw [SymE.eval_congrW hν a fun w hw => by
        have := h w hw; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.1,
      SymE.eval_congrW hν b fun w hw => by
        have := h w hw; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.2]
  | .un op a, h => by
    show F64.un op (a.eval ν') = F64.un op (a.eval ν)
    rw [SymE.eval_congrW hν a fun w hw => by have := h w hw; simpa [SymE.noVar] using this]

/-- **A stage call's merge keeps the ghost** (for `cut_merge`'s `hQ`): the merged pair has the
caller's context, a map extending the caller's on the loop table, and a valuation changing only
variables `V` (the merge's fresh result variables, `resVal`) that the loop table does not mention
and that the restart's substituted loop table `e.subst θ` reads only at the look-ahead variable;
the stage grew the mlx state (an `NK` implying `Wd.Grows`). The substitution condition is a
syntactic fact of the templates: for `thetaOf l`, an unlisted variable of the loop table maps to
itself, which `V` avoids, so `l` need not list the fresh variables. -/
theorem IterGhostW.merge (h : IterGhostW Wd A θ tab0 x0 x) {M' : Map} {ν' : Nat → F64} {t' : St Wd.F.S} {C' : CSrv}
    {V : Nat → Prop} (he : Ext x.M M' tab0.length) (hoff : ∀ v, ¬ V v → ν' v = x.ν v)
    (htab : ∀ j e, nth? tab0 j = some e → ∀ w, V w → e.noVar w = true)
    (hθ : ∀ j e, nth? tab0 j = some e → ∀ w, V w → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (hg : Wd.Grows x.t t') : IterGhostW Wd A θ tab0 x0 ⟨M', ν', x.K, t', C'⟩ :=
  h.conv (x' := ⟨M', ν', x.K, t', C'⟩) he rfl (fun j e hj => SymE.eval_congrW hoff e (htab j e hj))
    (fun v j e hj => by
      show e.eval (fun i => (θ i).eval (upd ν' A.nxt v)) = e.eval (fun i => (θ i).eval (upd x.ν A.nxt v))
      rw [← SymE.eval_subst, ← SymE.eval_subst]
      refine SymE.eval_congrW (V := fun w => V w ∧ w ≠ A.nxt) (fun u hu => ?_) _ fun w hw => hθ j e hj w hw.1 hw.2
      by_cases hua : u = A.nxt
      · subst hua; rw [upd_self, upd_self]
      · rw [upd_other _ _ hua, upd_other _ _ hua]
        exact hoff u fun hv => hu ⟨hv, hua⟩)
    hg

/-- **The ghost part of `cut_merge`'s `hQ`** in its shape: from the caller pair `c` with the ghost,
the stage's end pair `y`, its server's growth and the native frame `NK` (any `NK` implying the mlx
growth: it reads only the native states), the merged pair `⟨glue c y, νr c.ν, c.K, y.t, y.C⟩` has the
ghost, when the glued map extends the caller's on the loop table and the merge's valuation `νr`
binds only variables `V` the loop table and its substitution by `θ` do not read (`resVal`'s fresh
variables: `resVal_off`). -/
theorem IterGhostW.mergeQ {NK : Map → Wd.F.S → Wd.F.S → Wd.F.S → Prop}
    (hNK : ∀ M a b c, NK M a b c → Host.Mlx.Ffi.NGrow (Wd.toMlx b) (Wd.toMlx c))
    {glue : SegInst Wd.F → SegInst Wd.F → Map} {νr : (Nat → F64) → Nat → F64} {V : Nat → Prop}
    (hext : ∀ c y, Ext c.M (glue c y) tab0.length) (hoff : ∀ ν v, ¬ V v → νr ν v = ν v)
    (htab : ∀ j e, nth? tab0 j = some e → ∀ w, V w → e.noVar w = true)
    (hθ : ∀ j e, nth? tab0 j = some e → ∀ w, V w → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (c y : SegInst Wd.F) (M : Map) (a : Wd.F.S) (h : IterGhostW Wd A θ tab0 x0 c) (_hle : CSrv.Le c.C y.C)
    (hnk : NK M a c.t.ffi y.t.ffi) : IterGhostW Wd A θ tab0 x0 ⟨glue c y, νr c.ν, c.K, y.t, y.C⟩ :=
  h.merge (hext c y) (hoff c.ν) htab hθ (hNK _ _ _ _ hnk)

end Ghost

section Cuts
variable (Wd : World) (A : Addr) (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (W : Nat → Option WFrame) (P : Wd.Par)
  (Fr : LoopFramesA A) (s0 : St Wd.F.S) (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat)
  (toks : List NumV) (E0 : List Val) (B : LoopBase) (ΔJ ΔH ΔN : Nat)

/-- The iteration's start cut: the decode cut at `i`, at the start pair `x0` only. -/
def iterStartW (i : Nat) (x0 : SegInst Wd.F) : ICut Wd.F :=
  { (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).toCut with B := fun x => x = x0 }

/-- **The iteration's end cut**: the case's end template under the world's relation with iteration
`i`'s remaining readbacks at the case's end server, the pair reached from `x0`. -/
def iterEndW (c : LoopCaseW Wd A P s0 tab0 fixA) (i : Nat) (x0 : SegInst Wd.F) : ICut Wd.F where
  s0 := c.s1
  tab0 := c.S1.tab
  R := fun x _ _ => RelF Wd.F (Wd.R P (toks.drop i)) W x.M x.ν x.K c.s1 c.S1 x.t x.C
  B := IterGhostW Wd A c.θ tab0 x0

end Cuts

section Steps
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par}
  {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat}
  {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- **The last glue piece's restart into the end cut is no change**: a chain ending at the case's
end `(c.s1, c.S1)` under the world's relation restarts into `iterEndW` at its end pair. -/
theorem iterEnd_ok {L : SegLaws Wd.F} {R0 : SRel Wd.F} {sA : St Wd.F.S} {SA : SSrv} {Q : (Nat → F64) → Ctx → Prop}
    (c : LoopCaseW Wd A P s0 tab0 fixA) (i : Nat) (x0 : SegInst Wd.F) :
    SegTarget.Ok L R0 sA SA (relQW Wd.F (Wd.R P (toks.drop i)) W Q) c.s1 c.S1
      (.restart (iterEndW Wd A W P s0 tab0 fixA toks c i x0).R c.s1 ⟨c.S1.tab, []⟩ fun _ x1 x' => x' = x1) :=
  fun _ _ x1 _ _ h => ⟨x1, rfl, rfl, h.1, rfl⟩

/-- **A loop case's graph obligation across cuts**: as `LoopGStepW`, with the end pair at its own
valuation (the iteration's stage merges bind new variables), reached with the ghost `IterGhostW`. -/
def LoopGStepCW (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (W : Nat → Option WFrame) (Fr : LoopFramesA A)
    (c : LoopCaseW Wd A P s0 tab0 fixA) (V : LoopVals) (toks : List NumV) (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (n : Nat) (x1 : SegInst Wd.F),
    Gx i M t C → RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
    runC Wd.F n t C = some (x1.t, x1.C) → IterGhostW Wd A c.θ tab0 ⟨M, V i nx, K, t, C⟩ x1 →
    RelF Wd.F (Wd.R P (toks.drop i)) W x1.M x1.ν x1.K c.s1 c.S1 x1.t x1.C →
    Gx (i + 1) (c.rmap x1.M toks[i] x1.t) x1.t x1.C

/-- **A decode iteration across cuts discharges the per-iteration contract.** For every start pair at
the decode cut `i`, cut steps of `n` target steps from `iterStartW` to `iterEndW` (the pieces and
the stage conversions, carrying `IterGhostW`), and the iteration's template facts at its end (`c`:
the case's end state, server and restart data, its start server the loop table without oracle,
its shift under the frames, its kept frames, its counter deltas), the world's restart at the end
takes the decode cut's invariant at `i` to the one at `i + 1`. -/
theorem decodeIter_piecesW (st : LoopStartW Wd A P s0 tab0) (c : LoopCaseW Wd A P s0 tab0 fixA)
    (hS0 : c.S0 = ⟨tab0, []⟩) (hsh : c.ShiftFWW Fr W) (hkeep : c.KeepsW Fr) {i n : Nat} (hi1 : 1 ≤ i)
    (hlen : i < toks.length)
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) A.nxt (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20) (hw : c.Within ΔJ ΔH ΔN) (hJ : i * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + i * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + i * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepCW Gx W Fr c V toks i)
    (hp : ∀ x0, (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).R x0 s0 ⟨tab0, []⟩ →
      (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).B x0 →
      CutStep (iterStartW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i x0)
        (iterEndW Wd A W P s0 tab0 fixA toks c i x0) n) :
    DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n := by
  intro t C hinv
  obtain ⟨x0, ht0, hC0, hR0, hB0⟩ := (decCutW_inv i t C).2 hinv
  obtain ⟨t', C', hrun, x1, ht1, hC1, hR1, hgh⟩ := hp x0 hR0 hB0 t C ⟨x0, ht0, hC0, hR0, rfl⟩
  obtain ⟨M, ν0, K, t0, C0⟩ := x0
  obtain ⟨M1, ν1, K1, t1, C1⟩ := x1
  change t0 = t at ht0
  change C0 = C at hC0
  change t1 = t' at ht1
  change C1 = C' at hC1
  subst ht0 hC0 ht1 hC1
  obtain ⟨nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hB0
  change ν0 = V i nx at hν
  subst hν
  have hgh0 := hgh
  obtain ⟨hext, hctx, htab, hval, hgr⟩ := hgh
  change K1 = K at hctx
  subst hctx
  dsimp only at hD hHi hNi hfr hlo hhi hbase h79 hvals hfix hGx hext htab hval hgr
  change RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K1 s0 ⟨tab0, []⟩ t0 C0 at hR0
  change RelF Wd.F (Wd.R P (toks.drop i)) W M1 ν1 K1 c.s1 c.S1 t1 C1 at hR1
  have hdrop : toks.drop i = toks[i] :: toks.drop (i + 1) := List.drop_eq_getElem_cons hlen
  -- the start relation at the end's valuation, at the case's start server
  have h0 : RelF Wd.F (Wd.R P (toks.drop i)) W M ν1 K1 s0 c.S0 t0 C0 :=
    hR0.srvSwap (by rw [hS0]) ⟨fun j e he => by
      rw [hS0] at he; rw [htab j e he]; exact hR0.srv.num j e he, by rw [hS0]; exact fun q hq => nomatch hq⟩
  rw [hdrop] at h0 hR1
  have eJ : (i - 1) * ΔJ + ΔJ = i * ΔJ := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eH : (i - 1) * ΔH + ΔH = i * ΔH := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eN : (i - 1) * ΔN + ΔN = i * ΔN := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have hoff0 := hR0.offset
  have hw' := hw
  obtain ⟨hdJ, hdH, hdN⟩ := hw'
  -- the world's restart at the end
  have hDb : c.s1.next - s0.next + K1.D < Sim.bound := by omega
  have hHb : (Wd.toMlx t0.ffi).next + ((Wd.toMlx c.s1.ffi).next - (Wd.toMlx s0.ffi).next) +
      (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46 := by omega
  have hNb : (Wd.toMlx t0.ffi).nnext + ((Wd.toMlx c.s1.ffi).nnext - (Wd.toMlx s0.ffi).nnext) +
      (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62 := by omega
  obtain ⟨hoff, hH1, hN1, hrel⟩ := LoopCaseW.restartW st { c with n := n } hsh hfr hlo hhi h0 hrun
    (by rw [hS0]; exact hext) hR1 (hvals i hlen) hDb hHb hNb
  dsimp only at hoff hH1 hN1
  have hrel' : RelF Wd.F (Wd.R P (toks.drop (i + 1))) W (c.rmap M1 toks[i] t1) (V (i + 1) (tk (i + 2)))
      ⟨Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K1 c.s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo,
        K1.hi⟩ s0 ⟨tab0, []⟩ t1 C1 :=
    hrel.srvSwap rfl ⟨fun j e he => by
      rw [← hnext nx, ← hval (F64.ofNat (tk (i + 2))) j e he]; exact hrel.srv.num j e he, fun q hq => nomatch hq⟩
  have hlen1 : A.tok < c.S1.tab.length := by
    have := c.tlen; rw [c.tab] at this; have := st.htok; omega
  have hM79 : (M1.setNum c.S1.tab.length toks[i]).num A.tok = M.num A.tok := by
    rw [(Map.setNum_ext M1 c.S1.tab.length toks[i]).num A.tok hlen1]
    exact hext.num A.tok st.htok
  refine ⟨t1, C1, hrun, c.rmap M1 toks[i] t1,
    ⟨Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K1 c.s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩,
    tk (i + 2), p1 ++ (M1.setNum c.S1.tab.length toks[i]).vals c.xs, hrel', ?_, hlo, hhi, rfl, ?_, htk, ?_, ?_, ?_, ?_,
    ?_, ?_⟩
  · show Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K1 c.s1 = _
    rw [framedNext_frW c hfr hkeep]
    congr 1
    have hnv : (M1.setNum c.S1.tab.length toks[i]).nv (.ref A.tok) = toks[i - 1] := by
      show (M1.setNum c.S1.tab.length toks[i]).num A.tok = _
      rw [hM79]
      have := h79; rw [List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    rw [hnv, show i + 1 - 1 = (i - 1) + 1 by omega, ← take_map_succ toks (i - 1) (by omega), List.append_assoc]
  · show toks[i + 1 - 1]? = some ((c.rmap M1 toks[i] t1).num A.tok)
    show _ = some ((M1.setNum c.S1.tab.length toks[i]).nv (c.σ.num A.tok))
    rw [c.num]
    show _ = some ((M1.setNum c.S1.tab.length toks[i]).num c.S1.tab.length)
    rw [Map.setNum_self, show i + 1 - 1 = i by omega, List.getElem?_eq_getElem hlen]
  · intro j hj
    exact (runC_le n t0 C0 t1 C1 hrun).val (hvals j hj)
  · show t1.next - s0.next ≤ (i + 1 - 1) * ΔJ + B.D
    rw [hoff, show i + 1 - 1 = i by omega]
    omega
  · rw [hH1, show i + 1 - 1 = i by omega]
    omega
  · rw [hN1, show i + 1 - 1 = i by omega]
    omega
  · intro a ha
    show M1.a (c.σ.a a) = a
    rw [c.fix a ha, hext.a, hfix a ha]
  · exact hG hlen nx M K1 t0 C0 n ⟨M1, ν1, K1, t1, C1⟩ hGx hR0
      (fun a => by rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a) hlo hhi hrun hgh0
      (by rw [hdrop]; exact hR1)

end Steps

/-! ## Through compactions -/

/-- **The ghost's template data across compactions**: the virtual start's counters `vJ`, `vH`, `vN`
(the last compaction's canonical state's, the template start's before any), the growth `dJ`, `dH`,
`dN` absorbed before them, and the `emitted` elements `eA` absorbed into its frame. -/
structure GhostP where
  vJ : Nat
  dJ : Nat
  vH : Nat
  dH : Nat
  vN : Nat
  dN : Nat
  eA : List Val

/-- The ghost's data at the template start: no compaction yet. -/
def GhostP.init (Wd : World) (s0 : St Wd.F.S) : GhostP :=
  ⟨s0.next, 0, (Wd.toMlx s0.ffi).next, 0, (Wd.toMlx s0.ffi).nnext, 0, []⟩

/-- The ghost's data after compacting the merged state `sm` to the canonical state `sc`, the
`emitted` array's appended elements `eN` absorbed. -/
def GhostP.compact (Wd : World) (g : GhostP) (sm sc : St Wd.F.S) (eN : List Val) : GhostP :=
  ⟨sc.next, g.dJ + (sm.next - g.vJ), (Wd.toMlx sc.ffi).next, g.dH + ((Wd.toMlx sm.ffi).next - g.vH),
    (Wd.toMlx sc.ffi).nnext, g.dN + ((Wd.toMlx sm.ffi).nnext - g.vN), g.eA ++ eN⟩

/-- The further frames' arrays hold just their prefixes at `s` (`LoopCaseW.KeepsW` at any state). -/
def KeepsAtW {S : Type} {A : Addr} (Fr : LoopFramesA A) (s : St S) : Prop :=
  ∀ a pre pre', Fr.X a = some (pre, pre') → ∀ o es, s.heap.get a = some (.obj o) → o.kind = .array es →
    es.drop pre.length = []

/-- Numbers of the first `n` table entries. -/
def NumRefs (n : Nat) (vs : List Val) : Prop := ∀ v ∈ vs, ∃ j, j < n ∧ v = .num (.ref j)

theorem NumRefs.vals {n : Nat} {vs : List Val} (h : NumRefs n vs) {M M' : Map}
    (hm : ∀ j, j < n → M'.num j = M.num j) : M'.vals vs = M.vals vs := by
  unfold Map.vals
  refine List.map_congr_left fun v hv => ?_
  obtain ⟨j, hj, rfl⟩ := h v hv
  show Val.num (M'.num j) = Val.num (M.num j)
  rw [hm j hj]

/-- **The frames after a restart or a compaction at `s`** (`framedNext_frW` at any state):
`forwarded` and `emitted` extended by the images of their appended elements, the further frames
kept. -/
theorem framedNext_frAt {Wd : World} {A : Addr} {s0 s : St Wd.F.S} {Fr : LoopFramesA A} {M : Map} {K : Ctx}
    {p1 p2 f e : List Val} (hfr : K.fr = frA A s0 Fr.X p1 p2)
    (hf : ∃ o, s.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ f))
    (he : ∃ o, s.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ e)) (hk : KeepsAtW Fr s) :
    Shift.framedNext M K s = frA A s0 Fr.X (p1 ++ M.vals f) (p2 ++ M.vals e) := by
  funext a
  obtain ⟨of, hgf, hkf⟩ := hf
  obtain ⟨oe, hge, hke⟩ := he
  by_cases ha1 : a = A.fwd
  · subst ha1
    rw [framedNext_of (by rw [hfr, frA_fwd]) hgf hkf, frA_fwd]
  · by_cases ha2 : a = A.emit
    · subst ha2
      rw [framedNext_of (by rw [hfr, frA_emit]) hge hke, frA_emit]
    · have hX : K.fr a = Fr.X a := by rw [hfr, frA_other A s0 Fr.X p1 p2 ha1 ha2]
      rw [frA_other A s0 Fr.X _ _ ha1 ha2]
      cases hxa : Fr.X a with
      | none => exact (framedNext_none_iff a).2 (hX.trans hxa)
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        unfold Shift.framedNext
        rw [hX, hxa]
        cases hg : s.heap.get a with
        | none => rfl
        | some h =>
          cases h with
          | cell _ => rfl
          | obj o =>
            cases hok : o.kind with
            | array es =>
              simp only [hok, hk a pre pre' hxa o es hg hok, Map.vals, List.map_nil, List.append_nil]
            | _ => simp only [hok]

/-- Valuations agreeing off `V` give the same value to an expression whose substitution by `θ`
mentions no variable of `V` but `w0`, at the restart's valuation with `w0` bound. -/
theorem SymE.subst_eval_congrW {θ : Nat → SymE} {ν ν' : Nat → F64} {V : Nat → Prop} {w0 : Nat}
    (hoff : ∀ v, ¬ V v → ν' v = ν v) (e : SymE) (hθ : ∀ w, V w → w ≠ w0 → (e.subst θ).noVar w = true) (v : F64) :
    e.eval (Shift.valuation θ (upd ν' w0 v)) = e.eval (Shift.valuation θ (upd ν w0 v)) := by
  show e.eval (fun i => (θ i).eval (upd ν' w0 v)) = e.eval (fun i => (θ i).eval (upd ν w0 v))
  rw [← SymE.eval_subst, ← SymE.eval_subst]
  refine SymE.eval_congrW (V := fun w => V w ∧ w ≠ w0) (fun u hu => ?_) _ fun w hw => hθ w hw.1 hw.2
  by_cases hua : u = w0
  · subst hua; rw [upd_self, upd_self]
  · rw [upd_other _ _ hua, upd_other _ _ hua]
    exact hoff u fun hv => hu ⟨hv, hua⟩

/-- **The iteration's ghost across compactions**: `x` is reached within one decode iteration from
its start pair `x0` through glue pieces, stage calls and compactions (`g`: the virtual start and the
absorbed growth). Instead of extending `x0`'s map and keeping its context (`IterGhostW`), the pair
keeps what the iteration's end reads: the frames are `x0`'s with `forwarded` extended and the
absorbed `emitted` elements `eA` (under `x0`'s map) appended, the context's band, the offset from
the virtual start, the loop table's numbers, the addresses `fixA` and the template start's native
nodes (what the graph side reads of the map), the target's mlx counters at
the virtual start's fresh handles and nodes (bounded by `x0`'s and the absorbed growth), the loop
table's values before and after the restart's substitution `θ`, the mlx growth. -/
structure IterGhostCW (Wd : World) (A : Addr) (P : Wd.Par) (Fr : LoopFramesA A) (s0 : St Wd.F.S)
    (tab0 : List SymE) (fixA : List Nat) (θ : Nat → SymE) (g : GhostP) (x0 x : SegInst Wd.F) : Prop where
  fr : ∃ p1 p2 q1, x0.K.fr = frA A s0 Fr.X p1 p2 ∧ x.K.fr = frA A s0 Fr.X (p1 ++ q1) (p2 ++ x0.M.vals g.eA)
  lo : x.K.lo = x0.K.lo
  hi : x.K.hi = x0.K.hi
  D : x.K.D + g.vJ = x0.K.D + s0.next + g.dJ
  num : ∀ j, j < tab0.length → x.M.num j = x0.M.num j
  fix : ∀ a ∈ fixA, x.M.a a = x0.M.a a
  node : ∀ j, j < (Wd.toMlx s0.ffi).nnext → x.M.node j = x0.M.node j
  H : ∃ tH, tH ≤ (Wd.toMlx x0.t.ffi).next + g.dH ∧
    ∀ k, g.vH + k < Wd.E P → x.M.big (Int.ofNat (g.vH + k)) = Int.ofNat (tH + k)
  N : ∃ tN, tN ≤ (Wd.toMlx x0.t.ffi).nnext + g.dN ∧ ∀ k, x.M.node (g.vN + k) = tN + k
  tab : ∀ j e, nth? tab0 j = some e → e.eval x.ν = e.eval x0.ν
  val : ∀ v j e, nth? tab0 j = some e →
    e.eval (Shift.valuation θ (upd x.ν A.nxt v)) = e.eval (Shift.valuation θ (upd x0.ν A.nxt v))
  grows : Wd.Grows x0.t x.t

section GhostC
variable {Wd : World} {A : Addr} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE}
  {fixA : List Nat} {θ : Nat → SymE} {g : GhostP} {x0 x x1 : SegInst Wd.F}

/-- **The ghost at the iteration's start** from the start relation (its fresh counters) and its
frames. -/
theorem IterGhostCW.start (hE : Wd.EndLaws) {W : Nat → Option WFrame} {r : List NumV} {S : SSrv}
    (h : RelF Wd.F (Wd.R P r) W x0.M x0.ν x0.K s0 S x0.t x0.C) {p1 p2 : List Val}
    (hfr : x0.K.fr = frA A s0 Fr.X p1 p2) : IterGhostCW Wd A P Fr s0 tab0 fixA θ (GhostP.init Wd s0) x0 x0 where
  fr := ⟨p1, p2, [], hfr, by rw [hfr]; simp [GhostP.init, Map.vals]⟩
  lo := rfl
  hi := rfl
  D := rfl
  num _ _ := rfl
  fix _ _ := rfl
  node _ _ := rfl
  H := ⟨(Wd.toMlx x0.t.ffi).next, Nat.le_refl _, fun k hk => hE.bigFresh h.ffi k hk⟩
  N := ⟨(Wd.toMlx x0.t.ffi).nnext, Nat.le_refl _, fun k => hE.nodeFresh h.ffi k⟩
  tab _ _ _ := rfl
  val _ _ _ _ := rfl
  grows := World.Grows.refl Wd _

/-- **A conversion keeps the ghost** when it keeps the context, extends the map on the loop table,
agrees with the valuation on the loop table and on what `θ` reads, and grows the mlx state. -/
theorem IterGhostCW.conv (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x) {x' : SegInst Wd.F}
    (he : Ext x.M x'.M tab0.length) (hk : x'.K = x.K)
    (htab : ∀ j e, nth? tab0 j = some e → e.eval x'.ν = e.eval x.ν)
    (hval : ∀ v j e, nth? tab0 j = some e →
      e.eval (Shift.valuation θ (upd x'.ν A.nxt v)) = e.eval (Shift.valuation θ (upd x.ν A.nxt v)))
    (hg : Wd.Grows x.t x'.t) : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x' where
  fr := by rw [hk]; exact h.fr
  lo := by rw [hk]; exact h.lo
  hi := by rw [hk]; exact h.hi
  D := by rw [hk]; exact h.D
  num j hj := (he.num j hj).trans (h.num j hj)
  fix a ha := by rw [he.a]; exact h.fix a ha
  node j hj := by rw [he.node]; exact h.node j hj
  H := by
    obtain ⟨tH, h1, h2⟩ := h.H
    exact ⟨tH, h1, fun k hk => by rw [he.big]; exact h2 k hk⟩
  N := by
    obtain ⟨tN, h1, h2⟩ := h.N
    exact ⟨tN, h1, fun k => by rw [he.node]; exact h2 k⟩
  tab j e hj := (htab j e hj).trans (h.tab j e hj)
  val v j e hj := (hval v j e hj).trans (h.val v j e hj)
  grows := World.Grows.trans Wd h.grows hg

/-- A chain piece keeps the ghost. -/
theorem IterGhostCW.step (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x) {n ℓ : Nat}
    (hs : x.Step (loopLawsW Wd) n ℓ x1) (hl : tab0.length ≤ ℓ) : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x1 :=
  h.conv (hs.ext.mono hl) hs.kr (fun _ _ _ => by rw [hs.val]) (fun _ _ _ _ => by rw [hs.val]) hs.tr

/-- **A stage call's merge keeps the ghost** (`IterGhostW.merge`'s shape). -/
theorem IterGhostCW.merge (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x) {M' : Map} {ν' : Nat → F64}
    {t' : St Wd.F.S} {C' : CSrv} {V : Nat → Prop} (he : Ext x.M M' tab0.length) (hoff : ∀ v, ¬ V v → ν' v = x.ν v)
    (htab : ∀ j e, nth? tab0 j = some e → ∀ w, V w → e.noVar w = true)
    (hθ : ∀ j e, nth? tab0 j = some e → ∀ w, V w → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (hg : Wd.Grows x.t t') : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 ⟨M', ν', x.K, t', C'⟩ :=
  h.conv (x' := ⟨M', ν', x.K, t', C'⟩) he rfl (fun j e hj => SymE.eval_congrW hoff e (htab j e hj))
    (fun v j e hj => SymE.subst_eval_congrW hoff e (hθ j e hj) v) hg

/-- **The ghost part of `cut_merge`'s `hQ`** (`IterGhostW.mergeQ`'s shape). -/
theorem IterGhostCW.mergeQ {NK : Map → Wd.F.S → Wd.F.S → Wd.F.S → Prop}
    (hNK : ∀ M a b c, NK M a b c → Host.Mlx.Ffi.NGrow (Wd.toMlx b) (Wd.toMlx c))
    {glue : SegInst Wd.F → SegInst Wd.F → Map} {νr : (Nat → F64) → Nat → F64} {V : Nat → Prop}
    (hext : ∀ c y, Ext c.M (glue c y) tab0.length) (hoff : ∀ ν v, ¬ V v → νr ν v = ν v)
    (htab : ∀ j e, nth? tab0 j = some e → ∀ w, V w → e.noVar w = true)
    (hθ : ∀ j e, nth? tab0 j = some e → ∀ w, V w → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (c y : SegInst Wd.F) (M : Map) (a : Wd.F.S) (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 c)
    (_hle : CSrv.Le c.C y.C) (hnk : NK M a c.t.ffi y.t.ffi) :
    IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 ⟨glue c y, νr c.ν, c.K, y.t, y.C⟩ :=
  h.merge (hext c y) (hoff c.ν) htab hθ (hNK _ _ _ _ hnk)

/-- **A site instance keeps the ghost** (`site_ghost`'s shape, for `cut_site`'s `hQ`). -/
theorem IterGhostCW.site (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x) {M' : Map} {t' : St Wd.F.S} {C' : CSrv}
    {n : Nat} (he : Ext x.M M' n) (hn : tab0.length ≤ n) (hg : Wd.Grows x.t t') :
    IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 ⟨M', x.ν, x.K, t', C'⟩ :=
  h.merge (V := fun _ => False) (he.mono hn) (fun _ _ => rfl) (fun _ _ _ _ hv => hv.elim)
    (fun _ _ _ _ hv => hv.elim) hg

/-- **A compaction keeps the ghost, at the compacted data** (`compact`, `full_compact`): the merged
pair `x` at the merged state `sm` (its native relation and offset), the compacted pair at the
canonical state `sc` under a map `M'` keeping the loop table's numbers, the addresses `fixA` and the
template start's nodes (`Map.compact` fixes the call's table entries and addresses; the nodes are
its native part's), with its native relation, a valuation changing only variables `V` the loop
table and its substitution by `θ` do not read (the result variables, `compactθ`), and `compact`'s
context; the merged state's `forwarded` and
`emitted` arrays extend the template start's (by `f`, and by numbers `eN` of the loop table), its
further frames hold their prefixes; the counters only grow from the virtual start to `sm`, and the
canonical state's do not exceed `sm`'s. -/
theorem IterGhostCW.compact (hE : Wd.EndLaws) (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x)
    {sm sc : St Wd.F.S} {r : List NumV} {n n' : Nat} {M' : Map} {ν' : Nat → F64} {V : Nat → Prop}
    {f eN : List Val} (hm : Wd.R P r x.M n sm.ffi x.t.ffi) (hoffm : x.t.next = sm.next + x.K.D)
    (hc : Wd.R P r M' n' sc.ffi x.t.ffi)
    (hnum : ∀ j, j < tab0.length → M'.num j = x.M.num j) (hfix : ∀ a ∈ fixA, M'.a a = x.M.a a)
    (hnode : ∀ j, j < (Wd.toMlx s0.ffi).nnext → M'.node j = x.M.node j)
    (hoff : ∀ v, ¬ V v → ν' v = x.ν v)
    (htab : ∀ j e, nth? tab0 j = some e → ∀ w, V w → e.noVar w = true)
    (hθ : ∀ j e, nth? tab0 j = some e → ∀ w, V w → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (hfwd : ∃ o, sm.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ f))
    (hemit : ∃ o, sm.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ eN))
    (hkeep : KeepsAtW Fr sm) (heN : NumRefs tab0.length eN)
    (hJ : g.vJ ≤ sm.next) (hJc : sc.next ≤ sm.next) (hH : g.vH ≤ (Wd.toMlx sm.ffi).next)
    (hHE : (Wd.toMlx sm.ffi).next < Wd.E P) (hN : g.vN ≤ (Wd.toMlx sm.ffi).nnext) :
    IterGhostCW Wd A P Fr s0 tab0 fixA θ (GhostP.compact Wd g sm sc eN) x0
      ⟨M', ν', ⟨Shift.framedNext x.M x.K sm, sc.trace, x.t.trace, x.t.next - sc.next, x.K.lo, x.K.hi⟩, x.t, x.C⟩ where
  fr := by
    obtain ⟨p1, p2, q1, h0, h1⟩ := h.fr
    refine ⟨p1, p2, q1 ++ x.M.vals f, h0, ?_⟩
    show Shift.framedNext x.M x.K sm = _
    rw [framedNext_frAt h1 hfwd hemit hkeep, heN.vals (fun j hj => h.num j hj)]
    simp only [GhostP.compact, Map.vals, List.map_append, List.append_assoc]
  lo := h.lo
  hi := h.hi
  D := by
    have := h.D
    show x.t.next - sc.next + sc.next = x0.K.D + s0.next + (g.dJ + (sm.next - g.vJ))
    omega
  num j hj := (hnum j hj).trans (h.num j hj)
  fix a ha := (hfix a ha).trans (h.fix a ha)
  node j hj := (hnode j hj).trans (h.node j hj)
  H := by
    obtain ⟨tH, hle, hb⟩ := h.H
    refine ⟨(Wd.toMlx x.t.ffi).next, ?_, fun k hk => hE.bigFresh hc k hk⟩
    have e1 := hE.bigFresh hm 0 (by omega)
    have e2 := hb ((Wd.toMlx sm.ffi).next - g.vH) (by omega)
    rw [show g.vH + ((Wd.toMlx sm.ffi).next - g.vH) = (Wd.toMlx sm.ffi).next + 0 by omega, e1] at e2
    have e3 := Int.ofNat.inj e2
    show (Wd.toMlx x.t.ffi).next ≤ (Wd.toMlx x0.t.ffi).next + (g.dH + ((Wd.toMlx sm.ffi).next - g.vH))
    omega
  N := by
    obtain ⟨tN, hle, hb⟩ := h.N
    refine ⟨(Wd.toMlx x.t.ffi).nnext, ?_, fun k => hE.nodeFresh hc k⟩
    have e1 := hE.nodeFresh hm 0
    have e2 := hb ((Wd.toMlx sm.ffi).nnext - g.vN)
    rw [show g.vN + ((Wd.toMlx sm.ffi).nnext - g.vN) = (Wd.toMlx sm.ffi).nnext + 0 by omega, e1] at e2
    show (Wd.toMlx x.t.ffi).nnext ≤ (Wd.toMlx x0.t.ffi).nnext + (g.dN + ((Wd.toMlx sm.ffi).nnext - g.vN))
    omega
  tab j e hj := (SymE.eval_congrW hoff e (htab j e hj)).trans (h.tab j e hj)
  val v j e hj := (SymE.subst_eval_congrW hoff e (hθ j e hj) v).trans (h.val v j e hj)
  grows := h.grows

/-- **The no-compaction ghost is the ghost at the template start's data**, given the start's
relation and frames. -/
theorem IterGhostW.toC (hE : Wd.EndLaws) (h : IterGhostW Wd A θ tab0 x0 x) {W : Nat → Option WFrame}
    {r : List NumV} {S : SSrv} (h0 : RelF Wd.F (Wd.R P r) W x0.M x0.ν x0.K s0 S x0.t x0.C) {p1 p2 : List Val}
    (hfr : x0.K.fr = frA A s0 Fr.X p1 p2) : IterGhostCW Wd A P Fr s0 tab0 fixA θ (GhostP.init Wd s0) x0 x :=
  (IterGhostCW.start hE h0 hfr).conv h.ext h.ctx h.tab h.val h.grows

end GhostC

/-- **A decode iteration's end template across cuts**: `LoopCaseW` without its start server and
steps (the iteration's start server is the loop table without oracle), with the `emitted` array
extended by `eR`, what no compaction absorbed. -/
structure IterEndW (Wd : World) (A : Addr) (P : Wd.Par) (s0 : St Wd.F.S) (tab0 : List SymE) (fixA : List Nat) where
  s1 : St Wd.F.S
  S1 : SSrv
  σ : Map
  θ : Nat → SymE
  grow : Bool
  xs : List Val
  eR : List Val
  tlen : tab0.length ≤ S1.tab.length
  noVarTab : ∀ e ∈ S1.tab, e.noVar A.nxt = true
  noVarOr : ∀ q ∈ S1.oracle, q.noVar A.nxt = true
  nshift : Wd.NSh P tab0.length σ s0.ffi s1.ffi
  num : σ.num A.tok = .ref S1.tab.length
  hE : (Wd.toMlx s1.ffi).next < Wd.E P
  theta : ∀ j, θ j = loopTheta grow A.nxt j
  fwd : ∃ o, s1.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ xs)
  emit : ∃ o, s1.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ eR)
  fix : ∀ a ∈ fixA, σ.a a = a

section End
variable {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}

/-- A loop case's end as an iteration end (no compaction: the token appended to `emitted`). -/
def LoopCaseW.toEnd (c : LoopCaseW Wd A P s0 tab0 fixA) : IterEndW Wd A P s0 tab0 fixA where
  s1 := c.s1
  S1 := c.S1
  σ := c.σ
  θ := c.θ
  grow := c.grow
  xs := c.xs
  eR := [.num (.ref A.tok)]
  tlen := by have := c.tlen; rw [c.tab] at this; exact this
  noVarTab := c.noVarTab
  noVarOr := c.noVarOr
  nshift := c.nshift
  num := c.num
  hE := c.hE
  theta := c.theta
  fwd := c.fwd
  emit := c.emit
  fix := c.fix

/-- The restart map of an iteration end `M1` with the next readback `v`. -/
abbrev IterEndW.rmap (e : IterEndW Wd A P s0 tab0 fixA) (M1 : Map) (v : NumV) (t1 : St Wd.F.S) : Map :=
  ((M1.setNum e.S1.tab.length v).after e.σ).rebig (Wd.toMlx s0.ffi).next (Wd.E P) (Wd.toMlx t1.ffi).next

/-- **The end's shift under the frames** (`LoopCaseW.ShiftFWW` from the loop table). -/
def IterEndW.ShiftFW (e : IterEndW Wd A P s0 tab0 fixA) (Fr : LoopFramesA A) (W : Nat → Option WFrame) : Prop :=
  (∀ (p1 p2 : List Val) (K : Ctx), K.fr = frA A s0 Fr.X p1 p2 → K.lo = Wd.lo P → K.hi = Wd.E P →
    ShiftJS Wd.F e.σ e.θ (K.unW W) s0 ⟨tab0, []⟩ e.s1 ⟨e.S1.tab ++ [.var A.nxt], e.S1.oracle⟩) ∧
  ∀ a w, W a = some w → a ∈ Fr.xs ∧ e.σ.a a = a ∧ Present s0 a ∧ WFix e.σ (Present s0) w

/-- **The iteration's counter deltas from the ghost's data**: the end's counters past the virtual
start, the growth absorbed before it added, within `ΔJ`, `ΔH`, `ΔN` (`LoopCaseW.Within` at
`GhostP.init`). -/
def IterEndW.Within (e : IterEndW Wd A P s0 tab0 fixA) (g : GhostP) (ΔJ ΔH ΔN : Nat) : Prop :=
  g.vJ ≤ e.s1.next ∧ g.dJ + (e.s1.next - g.vJ) ≤ ΔJ ∧
    g.vH ≤ (Wd.toMlx e.s1.ffi).next ∧ g.dH + ((Wd.toMlx e.s1.ffi).next - g.vH) ≤ ΔH ∧
    g.vN ≤ (Wd.toMlx e.s1.ffi).nnext ∧ g.dN + ((Wd.toMlx e.s1.ffi).nnext - g.vN) ≤ ΔN

end End

section CutsC
variable (Wd : World) (A : Addr) (W : Nat → Option WFrame) (P : Wd.Par) (Fr : LoopFramesA A) (s0 : St Wd.F.S)
  (tab0 : List SymE) (fixA : List Nat) (toks : List NumV)

/-- **The iteration's end cut across compactions**: the end template under the world's relation
with iteration `i`'s remaining readbacks, the pair reached from `x0` (`IterGhostCW` at `g`). -/
def iterEndCW (e : IterEndW Wd A P s0 tab0 fixA) (g : GhostP) (i : Nat) (x0 : SegInst Wd.F) : ICut Wd.F where
  s0 := e.s1
  tab0 := e.S1.tab
  R := fun x _ _ => RelF Wd.F (Wd.R P (toks.drop i)) W x.M x.ν x.K e.s1 e.S1 x.t x.C
  B := IterGhostCW Wd A P Fr s0 tab0 fixA e.θ g x0

end CutsC

section StepsC
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par}
  {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat}
  {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- **The graph obligation across compactions**: as `LoopGStepCW`, the end pair reached with the
ghost `IterGhostCW` instead of a map extension and the start's context. -/
def LoopGStepGW (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (W : Nat → Option WFrame) (Fr : LoopFramesA A)
    (e : IterEndW Wd A P s0 tab0 fixA) (g : GhostP) (V : LoopVals) (toks : List NumV) (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (n : Nat) (x1 : SegInst Wd.F),
    Gx i M t C → RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
    runC Wd.F n t C = some (x1.t, x1.C) → IterGhostCW Wd A P Fr s0 tab0 fixA e.θ g ⟨M, V i nx, K, t, C⟩ x1 →
    RelF Wd.F (Wd.R P (toks.drop i)) W x1.M x1.ν x1.K e.s1 e.S1 x1.t x1.C →
    Gx (i + 1) (e.rmap x1.M toks[i] x1.t) x1.t x1.C

/-- **A decode iteration through stage calls and compactions discharges the per-iteration
contract.** For every start pair at the decode cut `i`, cut steps of `n` target steps from
`iterStartW` to `iterEndCW` (pieces, stage conversions and compactions carrying `IterGhostCW`; the
first conversion from `IterGhostCW.start` or `IterGhostW.toC`), the iteration's end template `e`
(its shift under the frames, its kept frames, its `emitted` elements with the absorbed ones the
token, its counter deltas from the ghost's data), the world's restart from the end relation
(`World.EndLaws.restartE`) takes the decode cut's invariant at `i` to the one at `i + 1`. -/
theorem decodeIter_piecesCW (hE : Wd.EndLaws) (st : LoopStartW Wd A P s0 tab0) (e : IterEndW Wd A P s0 tab0 fixA)
    (g : GhostP) (hsh : e.ShiftFW Fr W) (hkeep : KeepsAtW Fr e.s1) (hemit : g.eA ++ e.eR = [.num (.ref A.tok)])
    {i n : Nat} (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hnext : ∀ nx, Shift.valuation e.θ (upd (V i nx) A.nxt (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20) (hw : e.Within g ΔJ ΔH ΔN) (hJ : i * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + i * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + i * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepGW Gx W Fr e g V toks i)
    (hp : ∀ x0, (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).R x0 s0 ⟨tab0, []⟩ →
      (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).B x0 →
      CutStep (iterStartW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i x0)
        (iterEndCW Wd A W P Fr s0 tab0 fixA toks e g i x0) n) :
    DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n := by
  intro t C hinv
  obtain ⟨x0, ht0, hC0, hR0, hB0⟩ := (decCutW_inv i t C).2 hinv
  obtain ⟨t', C', hrun, x1, ht1, hC1, hR1, hgh⟩ := hp x0 hR0 hB0 t C ⟨x0, ht0, hC0, hR0, rfl⟩
  obtain ⟨M, ν0, K, t0, C0⟩ := x0
  obtain ⟨M1, ν1, K1, t1, C1⟩ := x1
  change t0 = t at ht0
  change C0 = C at hC0
  change t1 = t' at ht1
  change C1 = C' at hC1
  subst ht0 hC0 ht1 hC1
  obtain ⟨nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hB0
  change ν0 = V i nx at hν
  subst hν
  have hgh' := hgh
  obtain ⟨⟨q1, q2, q3, hf0, hf1⟩, hlo1, hhi1, hD1, hnum1, hfix1, -, ⟨tH, htH, hbig⟩, ⟨tN, htN, hnode⟩, -, hval1, -⟩ :=
    hgh'
  dsimp only at hD hHi hNi hfr hlo hhi hbase h79 hvals hfix hGx
  dsimp only at hf0 hf1 hlo1 hhi1 hD1 hnum1 hfix1 htH hbig htN hnode hval1
  change RelF Wd.F (Wd.R P (toks.drop i)) W M (V i nx) K s0 ⟨tab0, []⟩ t0 C0 at hR0
  change RelF Wd.F (Wd.R P (toks.drop i)) W M1 ν1 K1 e.s1 e.S1 t1 C1 at hR1
  have hq2 : q2 = E0 ++ (toks.take (i - 1)).map Val.num := by
    have := congrFun (hf0.symm.trans hfr) A.emit
    rw [frA_emit, frA_emit] at this
    exact (Prod.mk.inj (Option.some.inj this)).2
  subst hq2
  have hdrop : toks.drop i = toks[i] :: toks.drop (i + 1) := List.drop_eq_getElem_cons hlen
  rw [hdrop] at hR1
  obtain ⟨hvJ, hdJ, hvH, hdH, hvN, hdN⟩ := hw
  have hoff0 := hR0.offset
  have hoff1 := hR1.offset
  have heE := e.hE
  -- the end's mlx counters from the virtual start
  have hb2 := hbig ((Wd.toMlx e.s1.ffi).next - g.vH) (by omega)
  rw [show g.vH + ((Wd.toMlx e.s1.ffi).next - g.vH) = (Wd.toMlx e.s1.ffi).next + 0 by omega,
    hE.bigFresh hR1.ffi 0 (by omega)] at hb2
  have hH1 := Int.ofNat.inj hb2
  have hn2 := hnode ((Wd.toMlx e.s1.ffi).nnext - g.vN)
  rw [show g.vN + ((Wd.toMlx e.s1.ffi).nnext - g.vN) = (Wd.toMlx e.s1.ffi).nnext + 0 by omega,
    hE.nodeFresh hR1.ffi 0] at hn2
  have eJ : (i - 1) * ΔJ + ΔJ = i * ΔJ := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eH : (i - 1) * ΔH + ΔH = i * ΔH := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eN : (i - 1) * ΔN + ΔN = i * ΔN := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have hroom : t1.next - s0.next < Sim.bound := by omega
  have hHb : (Wd.toMlx t1.ffi).next + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46 := by omega
  have hNb : (Wd.toMlx t1.ffi).nnext + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62 := by omega
  -- the restart from the end relation
  have hlo' : K1.lo = Wd.lo P := hlo1.trans hlo
  have hhi' : K1.hi = Wd.E P := hhi1.trans hhi
  have hshift := ShiftD.ofJS (K1 := K1)
    (FS := fun σ x y => x = s0.ffi ∧ Wd.NSh P (⟨tab0, []⟩ : SSrv).tab.length σ x y)
    (hsh.1 _ _ K1 hf1 hlo' hhi') ⟨rfl, e.nshift⟩
    (fun a w hw => by
      obtain ⟨hxs, hfx, hpr, hwf⟩ := hsh.2 a w hw
      refine ⟨?_, hfx, hpr, hwf⟩
      rw [hf1]
      exact (frA_ne_none A s0 Fr _ _ a).2 (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hxs)))
    (fun _ _ => rfl) (fun _ ha hn => absurd hn ha) rfl rfl
  have hrel := hE.restartE A.tok A.nxt st.start rfl hR1 e.noVarTab e.noVarOr hshift (fun _ _ hw => hw) e.num
    st.htok (st.band hlo' hhi') ((runC_le n t0 C0 t1 C1 hrun).val (hvals i hlen)) hroom hHb hNb
  rw [dropNext_keep hR1] at hrel
  have hrel' : RelF Wd.F (Wd.R P (toks.drop (i + 1))) W (e.rmap M1 toks[i] t1) (V (i + 1) (tk (i + 2)))
      ⟨Shift.framedNext (M1.setNum e.S1.tab.length toks[i]) K1 e.s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo,
        K1.hi⟩ s0 ⟨tab0, []⟩ t1 C1 :=
    hrel.srvSwap rfl ⟨fun j e' he' => by
      rw [← hnext nx, ← hval1 (F64.ofNat (tk (i + 2))) j e' he']; exact hrel.srv.num j e' he',
      fun q hq => nomatch hq⟩
  have hlen1 : A.tok < e.S1.tab.length := by have := e.tlen; have := st.htok; omega
  have hM79 : (M1.setNum e.S1.tab.length toks[i]).num A.tok = M.num A.tok := by
    rw [(Map.setNum_ext M1 e.S1.tab.length toks[i]).num A.tok hlen1]
    exact hnum1 A.tok st.htok
  have htok79 : M.num A.tok = toks[i - 1] := by
    have := h79; rw [List.getElem?_eq_getElem (by omega)] at this
    exact (Option.some.inj this).symm
  -- the absorbed and the appended `emitted` elements are the token
  have hem : M.vals g.eA ++ (M1.setNum e.S1.tab.length toks[i]).vals e.eR = [Val.num toks[i - 1]] := by
    have hR : NumRefs tab0.length e.eR := fun v hv => ⟨A.tok, st.htok, by
      have : v ∈ g.eA ++ e.eR := List.mem_append_right _ hv
      rw [hemit] at this
      simpa using this⟩
    have htl := e.tlen
    rw [hR.vals (M := M) (M' := M1.setNum e.S1.tab.length toks[i]) (fun j hj => by
      rw [(Map.setNum_ext M1 e.S1.tab.length toks[i]).num j (by omega)]; exact hnum1 j hj),
      Map.vals, Map.vals, ← List.map_append, hemit]
    show [Val.num (M.num A.tok)] = _
    rw [htok79]
  refine ⟨t1, C1, hrun, e.rmap M1 toks[i] t1,
    ⟨Shift.framedNext (M1.setNum e.S1.tab.length toks[i]) K1 e.s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩,
    tk (i + 2), q1 ++ q3 ++ (M1.setNum e.S1.tab.length toks[i]).vals e.xs, hrel', ?_, hlo', hhi', rfl, ?_, htk, ?_, ?_,
    ?_, ?_, ?_, ?_⟩
  · show Shift.framedNext (M1.setNum e.S1.tab.length toks[i]) K1 e.s1 = _
    rw [framedNext_frAt hf1 e.fwd e.emit hkeep]
    congr 1
    rw [List.append_assoc, hem, show i + 1 - 1 = (i - 1) + 1 by omega, ← take_map_succ toks (i - 1) (by omega),
      List.append_assoc]
  · show toks[i + 1 - 1]? = some ((e.rmap M1 toks[i] t1).num A.tok)
    show _ = some ((M1.setNum e.S1.tab.length toks[i]).nv (e.σ.num A.tok))
    rw [e.num]
    show _ = some ((M1.setNum e.S1.tab.length toks[i]).num e.S1.tab.length)
    rw [Map.setNum_self, show i + 1 - 1 = i by omega, List.getElem?_eq_getElem hlen]
  · intro j hj
    exact (runC_le n t0 C0 t1 C1 hrun).val (hvals j hj)
  · show t1.next - s0.next ≤ (i + 1 - 1) * ΔJ + B.D
    rw [show i + 1 - 1 = i by omega]
    omega
  · show (Wd.toMlx t1.ffi).next ≤ (Wd.toMlx s0.ffi).next + (i + 1 - 1) * ΔH + B.H
    rw [show i + 1 - 1 = i by omega]
    omega
  · show (Wd.toMlx t1.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + (i + 1 - 1) * ΔN + B.N
    rw [show i + 1 - 1 = i by omega]
    omega
  · intro a ha
    show M1.a (e.σ.a a) = a
    rw [e.fix a ha, hfix1 a ha, hfix a ha]
  · exact hG hlen nx M K t0 C0 n ⟨M1, ν1, K1, t1, C1⟩ hGx hR0
      (fun a => by rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a) hlo hhi hrun hgh (by rw [hdrop]; exact hR1)

end StepsC

end Host.Ts.Sim.Prefill
