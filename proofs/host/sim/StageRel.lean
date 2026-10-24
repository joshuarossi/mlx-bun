import host.sim.Seg
import host.sim.stage.Spec
namespace Host.Ts.Sim.Stage
open Host.Ts Host.Ts.Sim

/-! # Stage contracts from the relation with a target-only stack base

A stage template runs in isolation: its call state has no caller frames. A call made from real
code has the caller's frames below the callee's. `RelB … r` (`Rel.lean`) relates the template to
such a target with the caller frames `r` as a target-only stack base: the target is the
isolated target under `r` (`RelB.ofUnder`, `RelB.strip`). The checked runs simulate under any
base (`Disp.stepSimXLB`, `Disp.runOk_simXVB`) for the steps that read no frame below the
source's own (`Disp.localB`: no return or abrupt completion to an empty source stack, a function
boundary among the frames, a scope frame below a `using` declaration; the generator and
suspension scans `nearestGen`, `splitSusp` then stop within the source's frames).

`StageTpl.holdsU`: a stage template (a checked run of local states and the return step) gives
its contract `StageTpl.contract` in every caller context: `Stage.HoldsU`, from each isolated call
state related to the template's start and each caller frames `r`, a run to the isolated return
state related to the template's end, under `r`. `HoldsU` is what the frame rule and sequential
composition use (`Stage.HoldsU.frame`, `Stage.seqU`); `Stage.Holds` (one return state for all
caller frames) gives it (`Stage.Holds.toU`). The relation gives the per-context form: it fixes
the target's return state up to what it relates, so the run's result is not shown independent of
`r` (that is `RunLocal`'s locality, a property of the concrete run). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64}
  {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- The isolated target under caller frames `r` is related with the base `r`. -/
theorem RelB.ofUnder (h : RelF F FR W M ν K s S t C) (r : List Frame) :
    RelB F FR W r M ν K s S (under t r) C :=
  { h with stack := by show t.stack ++ r = _; rw [h.stack, List.append_nil] }

/-- A target related with the base `r` is the isolated target (its frames the source's images)
under `r`. -/
theorem RelB.strip {r : List Frame} (h : RelB F FR W r M ν K s S t C) :
    t = under { t with stack := s.stack.map M.frame } r ∧
      RelF F FR W M ν K s S { t with stack := s.stack.map M.frame } C := by
  refine ⟨?_, { h with stack := (List.append_nil _).symm }⟩
  have e : t.stack = s.stack.map M.frame ++ r := h.stack
  obtain ⟨hp, nx, c, st, aux⟩ := t
  simp only at e
  simp only [under, e]

/-- At a state whose top frame is not a statement list, `RelXB` is `RelB`. -/
theorem RelXB.rel_frame' {r : List Frame} (h : RelXB F FR W r M ν K s S t C)
    (hs : ∀ rs env fs, s.stack ≠ .s (.block rs env) :: fs) : RelB F FR W r M ν K s S t C := by
  rcases h with h | ⟨_, _, rs, env, fs, _, _, hst, _⟩
  · exact h
  · exact absurd hst (hs rs env fs)

end

/-! ## Contracts that hold in every caller context -/

section
variable {F : Ffi}

/-- **A stage holds in every caller context**: from every isolated call state with `Pre` and every
caller frames `r`, a run reaches an isolated return state with `Post`, under `r`. -/
def Stage.HoldsU (G : Stage F) : Prop :=
  ∀ p t C, G.Pre p t C → ∀ r, ∃ n t' C', G.Post p t C t' C' ∧ runC F n (under t r) C = some (under t' r, C')

theorem Stage.Holds.toU {G : Stage F} (h : G.Holds) : G.HoldsU := fun p t C hp r => by
  obtain ⟨n, t', C', hq, hr⟩ := h p t C hp
  exact ⟨n, t', C', hq, hr r⟩

/-- **Frame rule** (`Stage.frame`) from `HoldsU`. -/
theorem Stage.HoldsU.frame {G : Stage F} (h : G.HoldsU) (I : G.Par → St F.S → CSrv → List Frame → Prop) :
    Seg F (G.AtCall I) (G.AtRet I) := by
  rintro u C ⟨p, t, r, rfl, hp, hi⟩
  obtain ⟨n, t', C', hq, hr⟩ := h p t C hp r
  exact ⟨n, under t' r, C', hr, p, t, C, t', r, rfl, hq, hi⟩

/-- **Sequential composition** (`Stage.seq`) from `HoldsU`. -/
theorem Stage.seqU {G₁ G₂ : Stage F} (h₁ : G₁.HoldsU) (h₂ : G₂.HoldsU)
    {I₁ : G₁.Par → St F.S → CSrv → List Frame → Prop} {I₂ : G₂.Par → St F.S → CSrv → List Frame → Prop}
    (glue : Seg F (G₁.AtRet I₁) (G₂.AtCall I₂)) : Seg F (G₁.AtCall I₁) (G₂.AtRet I₂) :=
  (h₁.frame I₁).trans (glue.trans (h₂.frame I₂))

end

/-! ## Stage templates -/

/-- **A stage template**: from the call state `(s0, S0)` a checked run (acceptance `ok`) to
`(s1, S1)`, and the return step to `(s2, S2)`, whose top frame is no statement list (the isolated
return state has none). -/
structure StageTpl (F : Ffi) (ok : St F.S → SSrv → Bool) where
  s0 : St F.S
  S0 : SSrv
  s1 : St F.S
  S1 : SSrv
  s2 : St F.S
  S2 : SSrv
  n : Nat
  ok0 : ok s0 S0 = true
  run : runOk F ok n s0 S0 = some (s1, S1)
  ok1 : ok s1 S1 = true
  halt : isHalt s1.ctl = false
  last : interpS (step F s1).run S1 = some (s2, S2)
  top : ∀ rs env fs, s2.stack ≠ .s (.block rs env) :: fs

/-- The contract of a stage template under the frames `W`: the isolated call state related to
the template's start (contexts `Kp`, valuations `VBOk`), the isolated return state related to its
end under an extension of the map. -/
def StageTpl.contract {F : Ffi} {ok : St F.S → SSrv → Bool} (T : StageTpl F ok) (FR : Map → Nat → F.S → F.S → Prop)
    (W : Nat → Option WFrame) (Kp : Ctx → Prop) (VBOk : (Nat → F64) → Prop) : Stage F where
  Par := Unit
  Pre _ t C := ∃ M ν K, Kp K ∧ VBOk ν ∧ RelF F FR W M ν K T.s0 T.S0 t C
  Post _ t C t' C' := ∃ M M' ν K, Kp K ∧ RelF F FR W M ν K T.s0 T.S0 t C ∧ Ext M M' T.S0.tab.length ∧
    RelF F FR W M' ν K T.s2 T.S2 t' C'

/-- **A stage template holds in every caller context**: with the one-step simulation under every
stack base (`Disp.stepSimXLB`) and an acceptance of local states only. -/
theorem StageTpl.holdsU {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ok : St F.S → SSrv → Bool}
    {Kp : Ctx → Prop} {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop} (T : StageTpl F ok)
    (hsim : ∀ r, Disp.StepSimXLB F FR ok Kp W r VBOk) (hloc : ∀ s S, ok s S = true → Disp.localB s = true) :
    (T.contract FR W Kp VBOk).HoldsU := by
  rintro ⟨⟩ t C ⟨M, ν, K, hK, hν, h⟩ r
  obtain ⟨M1, t1, C1, hr1, he1, hx1⟩ := Disp.runOk_simXVB F FR ok Kp W r VBOk (hsim r).xv
    (fun s S hs => .inr (hloc s S hs)) ν K hK hν T.n M T.s0 T.S0 (under t r) C T.s1 T.S1 (.inl (RelB.ofUnder h r))
    T.ok0 T.run
  obtain ⟨M2, t2, C2, ht2, he2, hx2⟩ :=
    hsim r M1 ν K T.s1 T.S1 t1 C1 T.s2 T.S2 hK hν hx1 T.halt (.inr (hloc _ _ T.ok1)) T.ok1 T.last
  have h2 := RelXB.rel_frame' hx2 T.top
  obtain ⟨e, h2'⟩ := RelB.strip h2
  have hth : isHalt t1.ctl = false := by rw [hx1.isHalt, T.halt]
  refine ⟨T.n + 1, _, C2, ⟨M, M2, ν, K, hK, h, he1.trans he2 (interpS_runOk_len T.run), h2'⟩, ?_⟩
  rw [← e]
  exact runC_trans hr1 (runC_one hth ht2)

end Host.Ts.Sim.Stage
