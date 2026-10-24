import host.sim.stage.Under
namespace Host.Ts.Sim.Stage
open Host.Ts

/-! # Stage contracts

The route's TypeScript is proven as stages (design `seams.md` §6): one call of one of our
functions, from its call state to the state that returns its result to the caller, proven
against a contract and composed by the caller's proof through the contract only.

* `Seg F P Q`: from every state and server satisfying `P`, a run reaches `Q` (a Hoare triple
  over `runC`; `CutStep` of `host.sim.Prefill` and `PieceSim` of `host.sim.Seg` are its
  invariant and relational forms). `Seg.trans` composes, `Seg.mono` weakens.
* `Stage F`: ghost parameters `Par`, a precondition `Pre` on the **isolated** call state (the
  callee's frames only: no caller frames) and its server, a postcondition `Post` relating the
  isolated return state and its server to them. What the call reads is what `Pre` constrains;
  what it writes, allocates and frees is what `Post` states, with the rest framed by `Framed`
  (heap below the call's counter outside the written addresses, jobs, stores, trace, the native
  state up to a relation; `LiveDelta` is the live-set change against a liveness layer).
* `Stage.Holds`: from every isolated call state with `Pre`, a run of some length reaches one
  return state with `Post` **under every caller stack** (`under t r`). The obligation of a
  stage is a stage template from the call to the return (`tpl_sim`: a symbolic run checked
  with the FFI, its native state and the caller frames free, `host.sim.stage.Under`); for a
  stage proven by a non-parametric run of the isolated state, `Stage.ofIso` asks that the run
  is local (`RunLocal`: no step reads below the callee's frames) and `runC_under` adds the
  caller frames.
* **Frame rule** `Stage.frame`: a stage that holds runs inside every context that satisfies
  its precondition on the isolated part, the caller frames and any caller fact `I` unchanged.
* **Sequential composition** `Stage.seq`: two stages at a call boundary, through the caller's
  segment from the first return to the second call. -/

section
variable {F : Ffi}

theorem runC_add {m n : Nat} {t t1 t2 : St F.S} {C C1 C2 : CSrv} (h1 : runC F m t C = some (t1, C1))
    (h2 : runC F n t1 C1 = some (t2, C2)) : runC F (m + n) t C = some (t2, C2) := by
  unfold runC at *; rw [runWith_add F interpC, h1]; exact h2

/-! ## Segments -/

/-- **A segment**: from every state and server satisfying `P`, a run of some length reaches a
state and server satisfying `Q`. -/
def Seg (F : Ffi) (P Q : St F.S → CSrv → Prop) : Prop :=
  ∀ t C, P t C → ∃ n t' C', runC F n t C = some (t', C') ∧ Q t' C'

theorem Seg.refl (P : St F.S → CSrv → Prop) : Seg F P P := fun t C h => ⟨0, t, C, rfl, h⟩

theorem Seg.trans {P Q R : St F.S → CSrv → Prop} (h1 : Seg F P Q) (h2 : Seg F Q R) : Seg F P R := by
  intro t C h
  obtain ⟨n, t1, C1, hr1, hq⟩ := h1 t C h
  obtain ⟨m, t2, C2, hr2, hr⟩ := h2 t1 C1 hq
  exact ⟨n + m, t2, C2, runC_add hr1 hr2, hr⟩

theorem Seg.mono {P P' Q Q' : St F.S → CSrv → Prop} (h : Seg F P Q) (hP : ∀ t C, P' t C → P t C)
    (hQ : ∀ t C, Q t C → Q' t C) : Seg F P' Q' := by
  intro t C hp
  obtain ⟨n, t', C', hr, hq⟩ := h t C (hP t C hp)
  exact ⟨n, t', C', hr, hQ t' C' hq⟩

/-! ## Frames -/

/-- **What a call leaves alone**, from its isolated call state `t` to its isolated return state
`t'`: the heap below `t.next` outside the written addresses `W` (allocations are fresh, at or
above `t.next`), the jobs, the stores, the trace (new events only in front), and the native
state up to `N` (`Eq` for a call that makes no native call). -/
structure Framed (W : Nat → Prop) (N : F.S → F.S → Prop) (t t' : St F.S) : Prop where
  next : t.next ≤ t'.next
  heap : ∀ a, a < t.next → ¬ W a → t'.heap.get a = t.heap.get a
  jobs : t'.jobs = t.jobs
  stores : t'.stores = t.stores
  trace : ∃ evs, t'.trace = evs ++ t.trace
  ffi : N t.ffi t'.ffi

theorem Framed.trans {W1 W2 : Nat → Prop} {N1 N2 : F.S → F.S → Prop} {t t1 t2 : St F.S}
    (h1 : Framed W1 N1 t t1) (h2 : Framed W2 N2 t1 t2) :
    Framed (fun a => W1 a ∨ W2 a) (fun x z => ∃ y, N1 x y ∧ N2 y z) t t2 where
  next := Nat.le_trans h1.next h2.next
  heap a ha hw := by
    rw [h2.heap a (Nat.lt_of_lt_of_le ha h1.next) (fun h => hw (.inr h)), h1.heap a ha (fun h => hw (.inl h))]
  jobs := h2.jobs.trans h1.jobs
  stores := h2.stores.trans h1.stores
  trace := by
    obtain ⟨e1, he1⟩ := h1.trace
    obtain ⟨e2, he2⟩ := h2.trace
    exact ⟨e2 ++ e1, by rw [he2, he1, List.append_assoc]⟩
  ffi := ⟨t1.ffi, h1.ffi, h2.ffi⟩

/-- **A live-set change**: against a liveness layer (`live x h`: native handle `h` is live in
native state `x`), the call allocates `A` and frees `D`; every other handle keeps its liveness.
A stage that frees every temporary it allocates has `A` = the handles it returns or leaves
in the caches, and `D` = the handles it consumes. -/
def LiveDelta (live : F.S → Nat → Prop) (A D : Nat → Prop) (x x' : F.S) : Prop :=
  ∀ h, live x' h ↔ (live x h ∧ ¬ D h) ∨ A h

/-- An unchanged native state allocates and frees nothing. -/
theorem LiveDelta.refl (live : F.S → Nat → Prop) (x : F.S) :
    LiveDelta live (fun _ => False) (fun _ => False) x x := by
  intro h; simp

theorem LiveDelta.trans {live : F.S → Nat → Prop} {A1 D1 A2 D2 : Nat → Prop} {x x1 x2 : F.S}
    (h1 : LiveDelta live A1 D1 x x1) (h2 : LiveDelta live A2 D2 x1 x2) :
    LiveDelta live (fun h => (A1 h ∧ ¬ D2 h) ∨ A2 h) (fun h => D1 h ∨ D2 h) x x2 := by
  intro h
  rw [h2 h, h1 h]
  by_cases hl : live x h <;> by_cases hd1 : D1 h <;> by_cases hd2 : D2 h <;> by_cases ha1 : A1 h <;>
    by_cases ha2 : A2 h <;> simp [hl, hd1, hd2, ha1, ha2]

/-! ## Stage contracts -/

/-- **A stage contract** of one call: ghost parameters, the precondition on the isolated call
state and its server, the postcondition relating the isolated return state and its server to
them. -/
structure Stage (F : Ffi) where
  Par : Type
  Pre : Par → St F.S → CSrv → Prop
  Post : Par → St F.S → CSrv → St F.S → CSrv → Prop

/-- **The stage holds**: from every isolated call state with `Pre`, a run of some length
reaches one return state with `Post`, the same under every caller stack. -/
def Stage.Holds (G : Stage F) : Prop :=
  ∀ p t C, G.Pre p t C → ∃ n t' C', G.Post p t C t' C' ∧ ∀ r, runC F n (under t r) C = some (under t' r, C')

/-- A call of `G` in a context: the isolated call state under caller frames `r`, with the
caller fact `I` of the parameters, the isolated state, its server and the frames. -/
def Stage.AtCall (G : Stage F) (I : G.Par → St F.S → CSrv → List Frame → Prop) (u : St F.S) (C : CSrv) : Prop :=
  ∃ p t r, u = under t r ∧ G.Pre p t C ∧ I p t C r

/-- The return of a call of `G` in a context, the caller frames and fact those of the call. -/
def Stage.AtRet (G : Stage F) (I : G.Par → St F.S → CSrv → List Frame → Prop) (u : St F.S) (C' : CSrv) : Prop :=
  ∃ p t C t' r, u = under t' r ∧ G.Post p t C t' C' ∧ I p t C r

/-- **Frame rule.** A stage proven in isolation runs inside every context that satisfies its
precondition on the isolated part: the caller's frames and every caller fact `I` carry over. -/
theorem Stage.frame {G : Stage F} (h : G.Holds) (I : G.Par → St F.S → CSrv → List Frame → Prop) :
    Seg F (G.AtCall I) (G.AtRet I) := by
  rintro u C ⟨p, t, r, rfl, hp, hi⟩
  obtain ⟨n, t', C', hq, hr⟩ := h p t C hp
  exact ⟨n, under t' r, C', hr r, p, t, C, t', r, rfl, hq, hi⟩

/-- **Sequential composition at a call boundary**: the first stage in its context, the caller's
segment from its return to the second call, the second stage in its context. -/
theorem Stage.seq {G₁ G₂ : Stage F} (h₁ : G₁.Holds) (h₂ : G₂.Holds)
    {I₁ : G₁.Par → St F.S → CSrv → List Frame → Prop} {I₂ : G₂.Par → St F.S → CSrv → List Frame → Prop}
    (glue : Seg F (G₁.AtRet I₁) (G₂.AtCall I₂)) : Seg F (G₁.AtCall I₁) (G₂.AtRet I₂) :=
  (Stage.frame h₁ I₁).trans (glue.trans (Stage.frame h₂ I₂))

/-- Two calls back to back: the second call is the first return (no caller step between). -/
theorem Stage.seq_now {G₁ G₂ : Stage F} (h₁ : G₁.Holds) (h₂ : G₂.Holds)
    {I₁ : G₁.Par → St F.S → CSrv → List Frame → Prop} {I₂ : G₂.Par → St F.S → CSrv → List Frame → Prop}
    (hb : ∀ u C, G₁.AtRet I₁ u C → G₂.AtCall I₂ u C) : Seg F (G₁.AtCall I₁) (G₂.AtRet I₂) :=
  Stage.seq h₁ h₂ ((Seg.refl _).mono (fun _ _ h => h) hb)

theorem Stage.Holds.weaken {G G' : Stage F} (h : G.Holds) (hPar : G'.Par = G.Par)
    (hPre : ∀ p t C, G'.Pre p t C → G.Pre (cast hPar p) t C)
    (hPost : ∀ p t C t' C', G.Post (cast hPar p) t C t' C' → G'.Post p t C t' C') : G'.Holds := by
  intro p t C hp
  obtain ⟨n, t', C', hq, hr⟩ := h _ t C (hPre p t C hp)
  exact ⟨n, t', C', hPost p t C t' C' hq, hr⟩

/-! ## Isolated runs that do not read below the callee's frames -/

/-- **A local state**: its step does not read below its frames, so under any caller frames it
steps to its own step's result under the same frames. -/
def StepLocal (F : Ffi) (t : St F.S) : Prop :=
  ∀ r C t1 C1, interpC (step F t).run C = some (t1, C1) → interpC (step F (under t r)).run C = some (under t1 r, C1)

/-- Every state a run of `n` steps steps from is local. -/
def RunLocal (F : Ffi) : Nat → St F.S → CSrv → Prop
  | 0, _, _ => True
  | n + 1, t, C => isHalt t.ctl = true ∨
      (StepLocal F t ∧ ∀ t1 C1, interpC (step F t).run C = some (t1, C1) → RunLocal F n t1 C1)

/-- **The caller frames of a local run**: a run of local states is the same run under every
caller frames. -/
theorem runC_under : ∀ (n : Nat) (t t' : St F.S) (C C' : CSrv), RunLocal F n t C →
    runC F n t C = some (t', C') → ∀ r, runC F n (under t r) C = some (under t' r, C')
  | 0, t, t', C, C', _, h, r => by
    simp only [runC, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    rfl
  | n + 1, t, t', C, C', hl, h, r => by
    cases hh : isHalt t.ctl
    · rcases hl with hl | ⟨hs, hrest⟩
      · rw [hh] at hl; cases hl
      · unfold runC at h ⊢
        rw [runWith_succ, hh] at h
        rw [runWith_succ, under_ctl, hh]
        simp only [Bool.cond_false] at h ⊢
        cases hst : interpC (step F t).run C with
        | none => rw [hst] at h; cases h
        | some p =>
          obtain ⟨t1, C1⟩ := p
          simp only [hst, St.rebuild_eq] at h
          simp only [hs r C t1 C1 hst, St.rebuild_eq]
          exact runC_under n t1 t' C1 C' (hrest t1 C1 hst) h r
    · have e := runWith_halted F interpC t C hh (n + 1)
      unfold runC at h ⊢
      rw [e] at h
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact runWith_halted F interpC (under t r) C (by rw [under_ctl]; exact hh) (n + 1)

/-- **An isolated stage holds in every context** when its isolated runs are local. -/
theorem Stage.ofIso {G : Stage F}
    (h : ∀ p t C, G.Pre p t C → ∃ n t' C', G.Post p t C t' C' ∧ runC F n t C = some (t', C') ∧ RunLocal F n t C) :
    G.Holds := by
  intro p t C hp
  obtain ⟨n, t', C', hq, hr, hl⟩ := h p t C hp
  exact ⟨n, t', C', hq, runC_under n t t' C C' hl hr⟩

/-! ## Stage templates -/

/-- **A stage template's concrete runs** (`run_sim`): a symbolic run from the call state to the
return state checked for every FFI, native state and caller frames gives, at every valuation
whose oracle answers are correct, one concrete run under every caller frames, to the
instantiated server. -/
theorem tpl_sim {s0 s1 : St Unit} {m0 m1 n : Nat} {S0 S1 : SSrv}
    (h : ∀ (F : Ffi) (x : F.S) (r : List Frame), runS F n (tpl s0 m0 x r) S0 = some (tpl s1 m1 x r, S1))
    (F : Ffi) (x : F.S) {ρ : Nat → F64} {C : CSrv} (hi : Inst ρ S0 C) :
    Inst ρ S1 ⟨S1.tab.map (SymE.eval ρ)⟩ ∧
      ∀ r, runC F n (under (tpl s0 m0 x []) r) C = some (under (tpl s1 m1 x []) r, ⟨S1.tab.map (SymE.eval ρ)⟩) := by
  have key : ∀ r, runC F n (tpl s0 m0 x r) C = some (tpl s1 m1 x r, ⟨S1.tab.map (SymE.eval ρ)⟩) ∧
      Inst ρ S1 ⟨S1.tab.map (SymE.eval ρ)⟩ := by
    intro r
    obtain ⟨C', hr, hi'⟩ := run_sim F ρ n _ _ S0 S1 C hi (h F x r)
    obtain ⟨tab'⟩ := C'
    have e : tab' = S1.tab.map (SymE.eval ρ) := hi'.1
    subst e
    exact ⟨hr, hi'⟩
  refine ⟨(key []).2, fun r => ?_⟩
  rw [← tpl_under, ← tpl_under]
  exact (key r).1

/-- `tpl_sim` for a template over a fixed native state (`tplN`): a stage that calls the FFI. -/
theorem tplN_sim {F : Ffi} {s0 s1 : St F.S} {m0 m1 n : Nat} {S0 S1 : SSrv}
    (h : ∀ r : List Frame, runS F n (tplN s0 m0 r) S0 = some (tplN s1 m1 r, S1))
    {ρ : Nat → F64} {C : CSrv} (hi : Inst ρ S0 C) :
    Inst ρ S1 ⟨S1.tab.map (SymE.eval ρ)⟩ ∧
      ∀ r, runC F n (under (tplN s0 m0 []) r) C = some (under (tplN s1 m1 []) r, ⟨S1.tab.map (SymE.eval ρ)⟩) := by
  have key : ∀ r, runC F n (tplN s0 m0 r) C = some (tplN s1 m1 r, ⟨S1.tab.map (SymE.eval ρ)⟩) ∧
      Inst ρ S1 ⟨S1.tab.map (SymE.eval ρ)⟩ := by
    intro r
    obtain ⟨C', hr, hi'⟩ := run_sim F ρ n _ _ S0 S1 C hi (h r)
    obtain ⟨tab'⟩ := C'
    have e : tab' = S1.tab.map (SymE.eval ρ) := hi'.1
    subst e
    exact ⟨hr, hi'⟩
  refine ⟨(key []).2, fun r => ?_⟩
  rw [← tplN_under, ← tplN_under]
  exact (key r).1

end

end Host.Ts.Sim.Stage
