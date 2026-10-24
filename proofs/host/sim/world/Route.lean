import host.sim.world.Top
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The route of a prompt over a world, at every budget and first EOS position

The driver's loop (`generation/autoregressive.ts:567-760`) reads token 1 once before its own
forward when the budget is at least 2 (the early yield, skipped when it is EOS), dispatches the
next decode step whenever the budget allows (`stepIndex + 1 < maxTokens`), reads the token again
and stops at an EOS (`finishReason = "stop"`) or when no step was dispatched. So:

* `T ≥ 3`: an EOS as token 1 halts after one dispatched decode step without yielding: the route
  leaves the prefill's exit cut `ps` through the stage calls before the EOS test to a cut and halts
  along its own chain from there, POST (which assumes token 1 is not EOS) never run. Token 2 is
  read at the decode cut `i = 1`, so an EOS there halts from the decode cut (`decodeHalt_cutW` at
  `J = 1`), and tokens `3 … T` as before;
* `T = 2`: token 1 as for `T ≥ 3`; token 2 is read without a dispatch, and the loop stops;
* `T = 1`: no early read and no decode step; token 1 is read once, and the loop stops.

The emitted tokens are stated by their values on the halted target's server (`emittedValsW`:
tokens `1 … m` of `tk`, `tokVals`), the same for every path.

* `CutHaltW I n Goal`: the halting contract of any cut; `CutStep.haltW`, `CutConv.haltW`,
  `source_haltW`.
* `halt_fromW`: a halting chain (`HaltSegW`) from a cut whose `emitted` array is unframed: the
  target holds the map's image of the template's array at the chain's end, whose numbers are the
  template's table entries at the valuation; `PathW`, `PathW.halt`: cut steps to such a cut and
  the chain (the short budgets' paths and the EOS at token 1).
* `RouteGoalW`: the route's goal (`NoEos`: tokens `1 … T`; `FirstEos … k`: tokens `1 … k - 1` and
  `"stop"`); `RouteGoalW.ofNo`, `RouteGoalW.ofFirst`.
* `source_tokens_prompt_routeW`: `T ≥ 3`, exhaustive over the first EOS position (no EOS: the final
  chains; `k = 1`: a path from `ps`; `2 ≤ k < T`: the exit chain at the cut of iteration `k - 1`,
  `k = 2` the decode cut itself; `k = T`: the EOS final chains). The decode iterations are taken as
  `DecodeItersW` (the six cases of pieces: `LoopCasesW.iterW`; cut-step chains with stage calls:
  `decodeIter_piecesW`; through compactions: `decodeIter_piecesCW`), every halting chain's oracle
  decided over its class's boxes (`FinalOk`, `ExitOk`, `FinalEOk`).
* `source_tokens_prompt_allW`: **every budget `1 ≤ T`**: `T = 1` and `T = 2` by their paths from
  `ps` (with and without EOS), `T ≥ 3` by `source_tokens_prompt_routeW`. Every halting chain
  supplies its end state's finish reason (`HaltStopSrc`). -/


/-! ## Halts from cuts -/

section
variable {F : Ffi}

/-- **The halting contract of a cut**: from its invariant, `n` target steps halt the target with
`Goal`. -/
def CutHaltW (I : ICut F) (n : Nat) (Goal : St F.S → CSrv → Prop) : Prop :=
  ∀ t C, I.Inv t C → ∃ tF CF v, runC F n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧ CSrv.Le C CF ∧
    Goal tF CF

theorem CutStep.haltW {I J : ICut F} {n m : Nat} {Goal : St F.S → CSrv → Prop} (h : CutStep I J n)
    (hh : CutHaltW J m Goal) : CutHaltW I (n + m) Goal := by
  intro t C hI
  obtain ⟨t1, C1, hr1, hJ⟩ := h t C hI
  obtain ⟨tF, CF, v, hr2, hv, hle, hG⟩ := hh t1 C1 hJ
  exact ⟨tF, CF, v, runC_trans hr1 hr2, hv, (runC_le _ _ _ _ _ hr1).trans hle, hG⟩

theorem CutHaltW.cast {I : ICut F} {n n' : Nat} {Goal : St F.S → CSrv → Prop} (h : CutHaltW I n Goal)
    (e : n = n') : CutHaltW I n' Goal := e ▸ h

theorem CutConv.haltW {I J : ICut F} {m : Nat} {Goal : St F.S → CSrv → Prop} (h : CutConv I J)
    (hh : CutHaltW J m Goal) : CutHaltW I m Goal :=
  (h.step.haltW hh).cast (Nat.zero_add m)

/-- A halt from the route's start: the boot run, cut steps to a cut, a halt there. -/
theorem source_haltW {I J : ICut F} {n m N0 : Nat} {Goal : St F.S → CSrv → Prop} {t0 tL : St F.S} {C0 CL : CSrv}
    (hboot : runC F N0 t0 C0 = some (tL, CL)) (hI : I.Inv tL CL) (h : CutStep I J n) (hh : CutHaltW J m Goal) :
    ∃ N tF CF, (∀ k, N ≤ k → runC F k t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C0 CF ∧ Goal tF CF := by
  obtain ⟨tF, CF, v, hr, hv, hle, hG⟩ := h.haltW hh tL CL hI
  have hrun := runC_trans hboot hr
  exact ⟨_, tF, CF, fun k hk => runC_halted_le hrun (by rw [hv]; rfl) hk, ⟨v, hv⟩,
    (runC_le _ _ _ _ _ hboot).trans hle, hG⟩

end

/-! ## The emitted tokens' values -/

/-- A number's value on the concrete server. -/
def numValW (C : CSrv) : Val → Option F64
  | .num x => C.val x
  | _ => none

/-- **The values of the emitted tokens** at the target `tF` with its server `CF`: the `emitted`
binding's elements, each a number the server evaluates. -/
def emittedValsW {S : Type} (tF : St S) (env : Env) (nm : Name) (CF : CSrv) : Option (List F64) :=
  ((bindingOf tF env nm).bind (elementsW tF)).bind fun es => es.mapM (numValW CF)

/-- A template value's number at the valuation `ν` (a table reference's entry, a literal). -/
def symValW (S : SSrv) (ν : Nat → F64) : Val → Option F64
  | .num (.ref j) => (nth? S.tab j).map fun e => e.eval ν
  | .num (.lit f) => some f
  | _ => none

/-- Tokens `1 … m` of `tk`. -/
def tokVals (tk : Nat → Nat) (m : Nat) : List F64 := (List.range m).map fun j => F64.ofNat (tk (j + 1))

theorem mapM_some {α β : Type} {f : α → Option β} : ∀ (l : List α) (r : List β), l.length = r.length →
    (∀ i (h : i < l.length) (h' : i < r.length), f l[i] = some r[i]) → l.mapM f = some r
  | [], [], _, _ => rfl
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl
  | a :: l, b :: r, hl, h => by
    have ha : f a = some b := h 0 (by simp) (by simp)
    have hr := mapM_some l r (by simpa using hl) fun i h1 h2 => h (i + 1) (by simp; omega) (by simp; omega)
    simp [List.mapM_cons, ha, hr]

/-- A template value's number at `ν` is the target value's under a relation's numbers. -/
theorem numVal_of_sym {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} (h : NumOK M ν S C) :
    ∀ v y, symValW S ν v = some y → numValW C (M.val v) = some y
  | .num (.ref j), y, hv => by
    simp only [symValW] at hv
    cases he : nth? S.tab j with
    | none => rw [he] at hv; cases hv
    | some e => rw [he] at hv; cases hv; exact h j e he
  | .num (.lit f), y, hv => by cases hv; rfl
  | .undef, _, hv => by cases hv
  | .null, _, hv => by cases hv
  | .bool _, _, hv => by cases hv
  | .big _, _, hv => by cases hv
  | .str _, _, hv => by cases hv
  | .sym _, _, hv => by cases hv
  | .obj _, _, hv => by cases hv
  | .ptr _ _, _, hv => by cases hv

theorem mapM_vals {M : Map} {f g : Val → Option F64} (hfg : ∀ v y, g v = some y → f (M.val v) = some y) :
    ∀ (es : List Val) (r : List F64), es.mapM g = some r → (M.vals es).mapM f = some r
  | [], r, h => by simp at h; subst h; rfl
  | v :: es, r, h => by
    simp only [List.mapM_cons] at h
    cases hv : g v with
    | none => simp [hv] at h
    | some y =>
      cases hes : es.mapM g with
      | none => simp [hv, hes] at h
      | some ys =>
        simp [hv, hes] at h
        subst h
        show (M.val v :: M.vals es).mapM f = some (y :: ys)
        simp [List.mapM_cons, hfg v y hv, mapM_vals hfg es ys hes]

/-- **A halting chain from a cut whose `emitted` array is unframed** (over `Wd`): entering the
chain from the cut's relation and bookkeeping (the start relation under `W`, the oracle, the entry
predicate, `emitted` unframed, the fixed addresses), the target halts with the `emitted` binding
the map's image of the template's array at the chain's end (`arrOf I.s0 A.emit ++ xs`), whose
numbers are `vs` (the template's table entries at the valuation), the goal `Gf` and the chain's
end fact `Fin`. -/
theorem halt_fromW {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {r : List NumV} {I : ICut Wd.F}
    {fixA : List Nat} {Fin : St Wd.F.S → Prop} {Gf : St Wd.F.S → CSrv → Prop} {env : Env} {nm : Name}
    {xs : List Val} {vs : List F64} (hs : HaltSegW Wd A W P r I.s0 I.s0 I.tab0 xs)
    (hent : ∀ x, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x →
      RelF Wd.F (Wd.R P r) W x.M x.ν x.K I.s0 ⟨I.tab0, []⟩ x.t x.C ∧ Good x.ν hs.S0.oracle ∧ hs.QA x.ν x.K ∧
        x.K.fr A.emit = none ∧ ∀ a ∈ fixA, x.M.a a = a)
    (hvs : ∀ x, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x → (arrOf I.s0 A.emit ++ xs).mapM (symValW hs.case.SF x.ν) = some vs)
    (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA) (hwc : W A.cE = none) (henv : lookupEnv nm env = some A.cE)
    (hfin : HaltFinW hs fixA Fin)
    (hG : ∀ x xF, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x → runC Wd.F hs.case.n x.t x.C = some (xF.t, xF.C) →
      Wd.Grows x.t xF.t → Ext x.M xF.M I.tab0.length → xF.ν = x.ν → hs.case.Rend xF hs.case.sF hs.case.SF →
      Gf xF.t xF.C) :
    CutHaltW I hs.case.n (fun tF CF => emittedValsW tF env nm CF = some vs ∧ Gf tF CF ∧ Fin tF) := by
  rintro t C ⟨x, rfl, rfl, hR, hB⟩
  obtain ⟨h0, hgood, hQA, hfe, hfix⟩ := hent x hR hB
  have h1 : RelF Wd.F (Wd.R P r) W x.M x.ν x.K I.s0 hs.S0 x.t x.C :=
    h0.srvSwap hs.tab ⟨fun j e he => h0.srv.num j e (by rw [hs.tab] at he; exact he), hgood⟩
  obtain ⟨x1, hst, hend, ⟨v, hv⟩⟩ := hs.halt (x := x) ⟨h1, hQA⟩
  have hF := (hs.rend x1 _ _ hend).1
  have hext : Ext x.M x1.M I.tab0.length := by rw [← hs.tab]; exact hst.ext
  have hMa : x1.M.a = x.M.a := hext.a
  obtain ⟨-, -, hke⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, hst.le, ?_, hG x x1 hR hB hst.run hst.tr hext hst.val hend,
    hfin x1 hend fun a ha => by rw [hMa]; exact hfix a ha⟩
  -- the emitted array: the template's array at the chain's end, unframed, at its fixed address
  have hfa : x1.M.a A.cE = A.cE := by rw [hMa]; exact hfix _ hcE
  have hfb : x1.M.a A.emit = A.emit := by rw [hMa]; exact hfix _ hb
  have hc' : x1.t.cell? A.cE = some (some (.obj A.emit)) := by
    have := hF.cell? hs.cell (.inl hwc)
    rw [hfa] at this
    exact this.trans (by show some (some (Val.obj (x1.M.a A.emit))) = _; rw [hfb])
  obtain ⟨o, hg, hkind⟩ := hs.emitG
  have hfr : x1.K.fr A.emit = none := by rw [hke]; exact hfe
  have ho := hF.obj? (obj?_iff.2 hg) hfr
  rw [hfb] at ho
  have hel : (bindingOf x1.t env nm).bind (elementsW x1.t) = some (x1.M.vals (arrOf I.s0 A.emit ++ xs)) := by
    unfold bindingOf
    rw [henv, Option.bind_some, hc']
    show elementsW x1.t (.obj A.emit) = _
    simp only [elementsW, objectW, ho]
    show (match x1.M.kind o.kind with | .array es => some es | _ => none) = _
    rw [hkind]
    rfl
  unfold emittedValsW
  rw [hel, Option.bind_some]
  have hν : x1.ν = x.ν := hst.val
  exact mapM_vals (numVal_of_sym hF.srv.num) _ vs (by rw [hν]; exact hvs x hR hB)

/-- **A halting path from a cut `I0`**: cut steps to a cut `I` and a halting chain from `I` whose
`emitted` array is unframed, with its entry and the values `vs` of its emitted numbers
(`halt_fromW`). The short budgets' paths and the EOS at token 1 leave the prefill's exit `ps` so. -/
structure PathW (Wd : World) (A : Addr) (W : Nat → Option WFrame) (P : Wd.Par) (fixA : List Nat) (I0 : ICut Wd.F)
    (vs : List F64) where
  I : ICut Wd.F
  n : Nat
  pre : CutStep I0 I n
  r : List NumV
  xs : List Val
  hs : HaltSegW Wd A W P r I.s0 I.s0 I.tab0 xs
  entry : ∀ x, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x →
    RelF Wd.F (Wd.R P r) W x.M x.ν x.K I.s0 ⟨I.tab0, []⟩ x.t x.C ∧ Good x.ν hs.S0.oracle ∧ hs.QA x.ν x.K ∧
      x.K.fr A.emit = none ∧ ∀ a ∈ fixA, x.M.a a = a
  vals : ∀ x, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x → (arrOf I.s0 A.emit ++ xs).mapM (symValW hs.case.SF x.ν) = some vs

section Path
variable {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {fixA : List Nat} {I0 : ICut Wd.F}
  {vs : List F64}

/-- A path's graph obligation: the goal at the halted target from the chain's start and end. -/
def PathW.Goal (p : PathW Wd A W P fixA I0 vs) (Gf : St Wd.F.S → CSrv → Prop) : Prop :=
  ∀ x xF, p.I.R x p.I.s0 ⟨p.I.tab0, []⟩ → p.I.B x → runC Wd.F p.hs.case.n x.t x.C = some (xF.t, xF.C) →
    Wd.Grows x.t xF.t → Ext x.M xF.M p.I.tab0.length → xF.ν = x.ν → p.hs.case.Rend xF p.hs.case.sF p.hs.case.SF →
    Gf xF.t xF.C

/-- **A path's halt** from `I0`: the emitted numbers `vs`, the goal, the chain's end fact. -/
theorem PathW.halt (p : PathW Wd A W P fixA I0 vs) {env : Env} {nm : Name} {Fin : St Wd.F.S → Prop}
    {Gf : St Wd.F.S → CSrv → Prop} (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA) (hwc : W A.cE = none)
    (henv : lookupEnv nm env = some A.cE) (hfin : HaltFinW p.hs fixA Fin) (hG : p.Goal Gf) :
    CutHaltW I0 (p.n + p.hs.case.n) (fun tF CF => emittedValsW tF env nm CF = some vs ∧ Gf tF CF ∧ Fin tF) :=
  p.pre.haltW (halt_fromW p.hs p.entry p.vals hcE hb hwc henv hfin hG)

end Path

/-! ## The route's goal -/

/-- The first EOS among tokens `1 … T` is token `k`. -/
def FirstEos (tk : Nat → Nat) (T k : Nat) : Prop :=
  1 ≤ k ∧ k ≤ T ∧ tk k = 248044 ∧ ∀ j, 1 ≤ j → j < k → tk j ≠ 248044

/-- No token among `1 … T` is EOS. -/
def NoEos (tk : Nat → Nat) (T : Nat) : Prop := ∀ j, 1 ≤ j → j ≤ T → tk j ≠ 248044

theorem FirstEos.unique {tk : Nat → Nat} {T k k' : Nat} (h : FirstEos tk T k) (h' : FirstEos tk T k') : k' = k := by
  obtain ⟨h1, _, h3, h4⟩ := h
  obtain ⟨h1', _, h3', h4'⟩ := h'
  rcases Nat.lt_trichotomy k' k with hl | he | hl
  · exact absurd h3' (h4 k' h1' hl)
  · exact he
  · exact absurd h3 (h4' k h1 hl)

/-- **The route's goal**: from `(t0, C0)` the target halts; with no EOS among tokens `1 … T` it
emits tokens `1 … T` and `G` holds; with the first EOS at `k` it emits tokens `1 … k - 1`, `GE k`
holds and `generation.stats.finishReason` is `"stop"`. -/
def RouteGoalW {F : Ffi} (t0 : St F.S) (C0 : CSrv) (env : Env) (nm : Name) (T : Nat) (tk : Nat → Nat)
    (G : St F.S → CSrv → Prop) (GE : Nat → St F.S → CSrv → Prop) : Prop :=
  ∃ N tF CF, (∀ n, N ≤ n → runC F n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
    CSrv.Le C0 CF ∧
    (NoEos tk T → emittedValsW tF env nm CF = some (tokVals tk T) ∧ G tF CF) ∧
    (∀ k, FirstEos tk T k → emittedValsW tF env nm CF = some (tokVals tk (k - 1)) ∧ GE k tF CF ∧ stopFin env tF)

section Goal
variable {F : Ffi} {t0 : St F.S} {C0 : CSrv} {env : Env} {nm : Name} {T : Nat} {tk : Nat → Nat}
  {G : St F.S → CSrv → Prop} {GE : Nat → St F.S → CSrv → Prop}

/-- The route's goal on the path without EOS. -/
theorem RouteGoalW.ofNo (hno : NoEos tk T)
    (h : ∃ N tF CF, (∀ n, N ≤ n → runC F n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C0 CF ∧ emittedValsW tF env nm CF = some (tokVals tk T) ∧ G tF CF) :
    RouteGoalW t0 C0 env nm T tk G GE := by
  obtain ⟨N, tF, CF, hr, hv, hle, hem, hg⟩ := h
  exact ⟨N, tF, CF, hr, hv, hle, fun _ => ⟨hem, hg⟩, fun k ⟨h1, h2, h3, _⟩ => absurd h3 (hno k h1 h2)⟩

/-- The route's goal on the path of the first EOS `k`. -/
theorem RouteGoalW.ofFirst {k : Nat} (hk : FirstEos tk T k)
    (h : ∃ N tF CF, (∀ n, N ≤ n → runC F n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C0 CF ∧ emittedValsW tF env nm CF = some (tokVals tk (k - 1)) ∧ GE k tF CF ∧ stopFin env tF) :
    RouteGoalW t0 C0 env nm T tk G GE := by
  obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := h
  refine ⟨N, tF, CF, hr, hv, hle, fun hno => absurd hk.2.2.1 (hno k hk.1 hk.2.1), fun k' hk' => ?_⟩
  obtain rfl := hk.unique hk'
  exact ⟨hem, hg, hs⟩

/-- The route's goal with weaker goals at the halted target. -/
theorem RouteGoalW.mono {G' : St F.S → CSrv → Prop} {GE' : Nat → St F.S → CSrv → Prop}
    (h : RouteGoalW t0 C0 env nm T tk G GE) (hG : ∀ tF CF, G tF CF → G' tF CF)
    (hE : ∀ k tF CF, FirstEos tk T k → GE k tF CF → GE' k tF CF) : RouteGoalW t0 C0 env nm T tk G' GE' := by
  obtain ⟨N, tF, CF, hr, hv, hle, hno, hfst⟩ := h
  exact ⟨N, tF, CF, hr, hv, hle, fun h => ⟨(hno h).1, hG _ _ (hno h).2⟩,
    fun k hk => ⟨(hfst k hk).1, hE k _ _ hk (hfst k hk).2.1, (hfst k hk).2.2⟩⟩

end Goal

/-- The emitted numbers of the decode route: the cut's one-token prefix `[e1]` and the first `m`
readbacks are tokens `1 … m + 1`. -/
theorem emitted_toks {C : CSrv} {e1 : NumV} {toks : List NumV} {tk : Nat → Nat} {m : Nat}
    (he1 : C.val e1 = some (F64.ofNat (tk 1)))
    (hv : ∀ j (hj : j < toks.length), C.val toks[j] = some (F64.ofNat (tk (j + 2)))) (hm : m ≤ toks.length) :
    ([Val.num e1] ++ (toks.take m).map Val.num).mapM (numValW C) = some (tokVals tk (m + 1)) := by
  refine mapM_some _ _ (by simp [tokVals]; omega) fun i h1 h2 => ?_
  match i, h1, h2 with
  | 0, _, _ => simpa [tokVals, numValW] using he1
  | j + 1, h1, _ =>
    have hj : j < toks.length := by simp at h1; omega
    simpa [tokVals, numValW, List.getElem_append_right, List.getElem_map, List.getElem_take] using hv j hj

/-- The emitted numbers' values from the `emitted` binding's elements. -/
theorem emittedValsW_of {S : Type} {tF : St S} {env : Env} {nm : Name} {CF : CSrv} {es : List Val} {vs : List F64}
    (he : (bindingOf tF env nm).bind (elementsW tF) = some es) (hv : es.mapM (numValW CF) = some vs) :
    emittedValsW tF env nm CF = some vs := by
  unfold emittedValsW; rw [he, Option.bind_some, hv]


/-! ## The route at every first EOS position, `T ≥ 3` -/

section Route
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {G : St Wd.F.S → CSrv → Prop}
  {GE : Nat → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A}
  {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop}

/-- **The route of a prompt `π` over the world `Wd` with a budget `T ≥ 3`, every path**
(`RouteGoalW`), exhaustively over the first EOS position among tokens `1 … T`: none (the final
chains), `k = 1` (a path from the prefill's exit, `PathW`), `2 ≤ k < T` (the exit chain at the cut of
iteration `k - 1`; `k = 2` is the decode cut itself), `k = T` (the EOS final chains). Each path's
graph obligations are needed only on that path; the halting chains supply their end states'
finish reason (`HaltStopSrc`); the decode cut's prefix is token 1 (`he1`). -/
theorem source_tokens_prompt_routeW (π : List Nat) {T : Nat} (hπ : 1 ≤ π.length) (hT : 3 ≤ T)
    (hctx : π.length + T ≤ 262144)
    -- the prefill to its exit, POST when token 1 is not EOS
    {I : PrefInvsW Wd.F} (SP : PrefStepsPW I) {nP : Nat}
    {ρ : Nat → F64} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    (hpost : tk 1 ≠ 248044 → CutStep (I.ps π.length) (I.dec π.length) nP)
    -- the boot to loadDone and the loadDone cut
    {N0 : Nat} {t0 tL : St Wd.F.S} {C0 CL : CSrv} (hboot : runC Wd.F N0 t0 C0 = some (tL, CL))
    (hld : (I.ld π.length).Inv tL CL)
    -- the decode cut at the regenerated template's constants `A`, its prefix token 1
    (hdec : I.dec π.length = loopCutW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk π.length) tk toks E0 B)
    {e1 : NumV} (hE0 : E0 = [.num e1])
    (he1 : ∀ t C, (I.dec π.length).Inv t C → C.val e1 = some (F64.ofNat (tk 1)))
    (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA) (hgen : A.gen ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    {env : Env} {nm : Name} (henv : lookupEnv nm env = some A.cE)
    (hgenv : lookupEnv chars!"generation" env = some A.gen)
    -- the decode iterations (with their graph obligations), however each is proven
    (hit : DecodeItersW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk π.length) tk toks E0 B ΔJ ΔH ΔN) T tk)
    -- no EOS: the three final chains
    (F0 F1 F2 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : FinalOk false false F0.S0.oracle) (c1 : FinalOk true false F1.S0.oracle)
    (c2 : FinalOk false true F2.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      F0.QA (valL ρ T tk π.length (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk π.length (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk π.length (T - 2) (tk T)) K)
    -- the first EOS at `2 ≤ k < T`: the exit chain at the cut of iteration `k - 1`
    (X : ∀ k, HaltSegW Wd A W P (toks.drop (k - 1)) s0 s0 tab0 []) (cX : ∀ k, ExitOk (X k).S0.oracle)
    (hQX : ∀ k, 2 ≤ k → k < T → ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) →
      K.lo = Wd.lo P → K.hi = Wd.E P → (X k).QA (valL ρ T tk π.length (k - 1) nx) K)
    (sX : ∀ k, 2 ≤ k → k < T → HaltStopSrc (X k))
    -- the first EOS at `T`: the two EOS final chains
    (FE0 FE1 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (c0E : FinalEOk false FE0.S0.oracle) (c1E : FinalEOk true FE1.S0.oracle)
    (hQE : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      FE0.QA (valL ρ T tk π.length (T - 2) (tk T)) K ∧ FE1.QA (valL ρ T tk π.length (T - 2) (tk T)) K)
    (s0E : HaltStopSrc FE0) (s1E : HaltStopSrc FE1)
    -- the first EOS at token 1: a path from the prefill's exit (the stage calls before the EOS test,
    -- one dispatched decode step, the halting chain), emitting nothing
    (P1 : tk 1 = 248044 → PathW Wd A W P fixA (I.ps π.length) [])
    (s1H : ∀ h, HaltStopSrc (P1 h).hs)
    -- the readbacks and the bounds
    (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    -- the graph side of the halts, along each path
    (hF : NoEos tk T → (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 →
      LastGStepW A Gx P W Fr fixA F0 (valL ρ T tk π.length) tk G)
    (hF0 : NoEos tk T → (T - 2) % 256 = 0 → LastGStepW A Gx P W Fr fixA F1 (valL ρ T tk π.length) tk G)
    (hF1 : NoEos tk T → (T - 1) % 256 = 0 → LastGStepW A Gx P W Fr fixA F2 (valL ρ T tk π.length) tk G)
    (hX : ∀ k, 2 ≤ k → k < T → FirstEos tk T k → CutGStepW A Gx P W Fr fixA (X k) (valL ρ T tk π.length) (GE k))
    (hFE : FirstEos tk T T → (T - 2) % 256 ≠ 0 → LastGStepW A Gx P W Fr fixA FE0 (valL ρ T tk π.length) tk (GE T))
    (hFE0 : FirstEos tk T T → (T - 2) % 256 = 0 → LastGStepW A Gx P W Fr fixA FE1 (valL ρ T tk π.length) tk (GE T))
    (hG1 : ∀ h, (P1 h).Goal (GE 1)) :
    RouteGoalW t0 C0 env nm T tk G GE := by
  classical
  have hL2 : π.length ≤ 262143 := by omega
  have hLT : π.length + T < 2 ^ 29 := by omega
  have hps := prefill_reach_psW SP hπ hL2
  -- the decode cut after POST, with the prefix's and the readbacks' values
  have post : tk 1 ≠ 248044 → ∃ N1 t1 C1, runC Wd.F N1 t0 C0 = some (t1, C1) ∧
      DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk π.length) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1 ∧
      C1.val e1 = some (F64.ofNat (tk 1)) ∧ ∀ j (hj : j < toks.length), C1.val toks[j] = some (F64.ofNat (tk (j + 2))) := by
    intro h1
    obtain ⟨t1, C1, hr1, hinv⟩ := (hps.trans (hpost h1)) tL CL hld
    have hv1 := he1 t1 C1 hinv
    rw [hdec] at hinv
    have hinv' := (loopCutW_inv ΔJ ΔH ΔN t1 C1).1 hinv
    have hc := hinv'
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hvals, -⟩ := hc
    exact ⟨_, t1, C1, runC_trans hboot hr1, hinv', hv1, hvals⟩
  by_cases hex : ∃ k, 1 ≤ k ∧ k ≤ T ∧ tk k = 248044
  · -- the first EOS
    obtain ⟨k, hk⟩ : ∃ k, FirstEos tk T k := by
      refine ⟨Nat.find hex, (Nat.find_spec hex).1, (Nat.find_spec hex).2.1, (Nat.find_spec hex).2.2,
        fun j h1 h2 he => Nat.find_min hex h2 ⟨h1, ?_, he⟩⟩
      have := (Nat.find_spec hex).2.1; omega
    obtain ⟨hk1, hkT, heos, hmin⟩ := hk
    refine RouteGoalW.ofFirst ⟨hk1, hkT, heos, hmin⟩ ?_
    by_cases hk1' : k = 1
    · -- token 1: a path from the prefill's exit
      subst hk1'
      obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := source_haltW hboot hld hps
        ((P1 heos).halt (Fin := stopFin env) hcE hb hwc henv ((s1H heos).toW hgen hgenv) (hG1 heos))
      exact ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩
    · -- tokens `2 … T`: POST, then the decode route's EOS stop
      have hk2 : 2 ≤ k := by omega
      obtain ⟨N1, t1, C1, hpre, hinv, hv1, hvals⟩ := post (hmin 1 le_rfl (by omega))
      obtain ⟨N, tF, CF, hrun, hv, hle, ⟨hem, hg⟩, hfin⟩ := decode_source_eosLW (Fin := stopFin env) (G := GE k)
        hA st hfrN hcE hb hwc hwe k hk2 hkT
        (fun i h1 h2 h3 => hit i h1 h3 fun j hj1 hj2 => hmin j hj1 (by omega)) (X k) (cX k) FE0 FE1 c0E c1E
        (fun h => hQX k hk2 h) hQE
        (fun h => (sX k hk2 h).toW hgen hgenv) (fun _ => s0E.toW hgen hgenv) (fun _ => s1E.toW hgen hgenv) henv hT
        hLT hlen htk (fun j h2 h3 => hmin j (by omega) h3) heos
        (fun h => hX k hk2 h ⟨hk1, hkT, heos, hmin⟩)
        (fun h hc => by subst h; exact hFE ⟨hk1, hkT, heos, hmin⟩ hc)
        (fun h hc => by subst h; exact hFE0 ⟨hk1, hkT, heos, hmin⟩ hc) hpre hinv
      rw [hE0] at hem
      have hvs := emitted_toks (m := k - 2) (hle.val hv1) (fun j hj => hle.val (hvals j hj)) (by omega)
      rw [show k - 2 + 1 = k - 1 by omega] at hvs
      exact ⟨N, tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, emittedValsW_of hem hvs, hg, hfin⟩
  · -- no EOS among tokens `1 … T`: POST, the decode route, the final chains
    have hno : NoEos tk T := fun j h1 h2 he => hex ⟨j, h1, h2, he⟩
    refine RouteGoalW.ofNo hno ?_
    obtain ⟨N1, t1, C1, hpre, hinv, hv1, hvals⟩ := post (hno 1 le_rfl (by omega))
    obtain ⟨N, tF, CF, hrun, hv, hle, hem, hg⟩ := decode_sourceLW hA st hfrN hcE hb hwc hwe
      (fun i h1 h2 => hit i h1 h2 fun j hj1 hj2 => hno j hj1 (by omega))
      F0 F1 F2 c0 c1 c2 hQA henv hT hLT hlen htk (fun j h2 h3 => hno j (by omega) h3) (hF hno) (hF0 hno) (hF1 hno)
      hpre hinv
    rw [hE0] at hem
    have hvs := emitted_toks (m := T - 1) (hle.val hv1) (fun j hj => hle.val (hvals j hj)) hlen
    rw [show T - 1 + 1 = T by omega] at hvs
    exact ⟨N, tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, emittedValsW_of hem hvs, hg⟩

/-! ## The route at every budget -/

/-- **The route of a prompt `π` over the world `Wd`, every budget `1 ≤ T`** (`RouteGoalW`). The
driver's loop (`autoregressive.ts:567-760`) at the short budgets:

* `T = 1`: no early read of token 1 and no decode step (`maxTokens > 1` and
  `stepIndex + 1 < maxTokens` fail); token 1 is read once, then the loop stops: emitted `[]` and
  `"stop"` at an EOS, token 1 otherwise (`P11`, `P10`);
* `T = 2`: token 1 is read early (yielded unless EOS) and decode step 1 is dispatched; at an EOS
  the route stops with nothing emitted (`P21`); otherwise token 2 is read without a dispatch, the
  loop stops: token 1 and `"stop"` at an EOS (`P22`), tokens 1 and 2 otherwise (`P20`);
* `T ≥ 3`: `source_tokens_prompt_routeW` (`h3`).

Each short path is a `PathW` from the prefill's exit `ps` (its stage calls as cut steps, a halting
chain from an unframed `emitted` array), with its end state's finish reason at the stops and its
graph obligation. -/
theorem source_tokens_prompt_allW (π : List Nat) {T : Nat} (hπ : 1 ≤ π.length) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144)
    {I : PrefInvsW Wd.F} (SP : PrefStepsPW I) {tk : Nat → Nat}
    {N0 : Nat} {t0 tL : St Wd.F.S} {C0 CL : CSrv} (hboot : runC Wd.F N0 t0 C0 = some (tL, CL))
    (hld : (I.ld π.length).Inv tL CL)
    (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA) (hgen : A.gen ∈ fixA) (hwc : W A.cE = none)
    {env : Env} {nm : Name} (henv : lookupEnv nm env = some A.cE)
    (hgenv : lookupEnv chars!"generation" env = some A.gen)
    -- `T ≥ 3`: the route through the decode loop
    (h3 : 3 ≤ T → RouteGoalW t0 C0 env nm T tk G GE)
    -- `T = 2`
    (P21 : T = 2 → tk 1 = 248044 → PathW Wd A W P fixA (I.ps π.length) [])
    (P22 : T = 2 → tk 1 ≠ 248044 → tk 2 = 248044 → PathW Wd A W P fixA (I.ps π.length) (tokVals tk 1))
    (P20 : T = 2 → tk 1 ≠ 248044 → tk 2 ≠ 248044 → PathW Wd A W P fixA (I.ps π.length) (tokVals tk 2))
    -- `T = 1`
    (P11 : T = 1 → tk 1 = 248044 → PathW Wd A W P fixA (I.ps π.length) [])
    (P10 : T = 1 → tk 1 ≠ 248044 → PathW Wd A W P fixA (I.ps π.length) (tokVals tk 1))
    -- the stops' finish reason
    (s21 : ∀ h h', HaltStopSrc (P21 h h').hs) (s22 : ∀ h h' h'', HaltStopSrc (P22 h h' h'').hs)
    (s11 : ∀ h h', HaltStopSrc (P11 h h').hs)
    -- the graph side
    (g21 : ∀ h h', (P21 h h').Goal (GE 1)) (g22 : ∀ h h' h'', (P22 h h' h'').Goal (GE 2))
    (g20 : ∀ h h' h'', (P20 h h' h'').Goal G) (g11 : ∀ h h', (P11 h h').Goal (GE 1))
    (g10 : ∀ h h', (P10 h h').Goal G) :
    RouteGoalW t0 C0 env nm T tk G GE := by
  have hps := prefill_reach_psW SP hπ (by omega)
  have triv : ∀ {vs : List F64} (p : PathW Wd A W P fixA (I.ps π.length) vs), HaltFinW p.hs fixA (fun _ => True) :=
    fun _ _ _ _ => trivial
  rcases (by omega : T = 1 ∨ T = 2 ∨ 3 ≤ T) with h1 | h2 | h3'
  · subst h1
    by_cases he : tk 1 = 248044
    · refine RouteGoalW.ofFirst (k := 1) ⟨le_rfl, le_rfl, he, fun j h1 h2 => absurd h2 (by omega)⟩ ?_
      obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := source_haltW hboot hld hps
        ((P11 rfl he).halt (Fin := stopFin env) hcE hb hwc henv ((s11 rfl he).toW hgen hgenv) (g11 rfl he))
      exact ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩
    · refine RouteGoalW.ofNo (fun j h1 h2 => by obtain rfl : j = 1 := by omega
                                                exact he) ?_
      obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, -⟩ := source_haltW hboot hld hps
        ((P10 rfl he).halt hcE hb hwc henv (triv _) (g10 rfl he))
      exact ⟨N, tF, CF, hr, hv, hle, hem, hg⟩
  · subst h2
    by_cases he1 : tk 1 = 248044
    · refine RouteGoalW.ofFirst (k := 1) ⟨le_rfl, by omega, he1, fun j h1 h2 => absurd h2 (by omega)⟩ ?_
      obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := source_haltW hboot hld hps
        ((P21 rfl he1).halt (Fin := stopFin env) hcE hb hwc henv ((s21 rfl he1).toW hgen hgenv) (g21 rfl he1))
      exact ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩
    · by_cases he2 : tk 2 = 248044
      · refine RouteGoalW.ofFirst (k := 2) ⟨by omega, le_rfl, he2, fun j h1 h2 => by
          obtain rfl : j = 1 := by omega
          exact he1⟩ ?_
        obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := source_haltW hboot hld hps
          ((P22 rfl he1 he2).halt (Fin := stopFin env) hcE hb hwc henv ((s22 rfl he1 he2).toW hgen hgenv)
            (g22 rfl he1 he2))
        exact ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩
      · refine RouteGoalW.ofNo (fun j h1 h2 => by
          rcases (by omega : j = 1 ∨ j = 2) with rfl | rfl
          · exact he1
          · exact he2) ?_
        obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, -⟩ := source_haltW hboot hld hps
          ((P20 rfl he1 he2).halt hcE hb hwc henv (triv _) (g20 rfl he1 he2))
        exact ⟨N, tF, CF, hr, hv, hle, hem, hg⟩
  · exact h3 h3'

end Route

end Host.Ts.Sim.Prefill
