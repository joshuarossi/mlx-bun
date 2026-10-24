import host.sim.LoopL
import host.sim.LoadSim
import host.sim.dispatch.OkLast
import host.sim.extract.GrowRun
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode loop after a prompt of length `L`

After a prompt of `L` tokens the loop runs one of six checked cases per iteration
(`loopSelL`): the cache clear by `i % 256 = 0`, the KV branch by the residue of the offset
`L + i + 1` (`0`: growth, `255`: fill). `LoopCases.Facts` are the template facts of the six
cases (each oracle among its distinct answers, the growth flags, the counter deltas); they give
what the loop needs at every prompt length (`LoopCases.okAt`: the selected case's growth flag
and its oracle at every iteration of the class, by LinGood). The acceptance functions'
simulation facts are `AccSim` (the load world's: `AccSim.load`), a final case with its second
segment's acceptance `FinalSim`, the EOS cases `ExitSim`, `FinalESim`.

* `loop_reachL`: from the invariant at iteration 1 (`LoopInvL … 1`, supplied by the prefill),
  the `T - 3` loop iterations reach the invariant at the final iteration `T - 2`.
* `loop_sourceL`: and one of the three final cases halts with the emitted array, from any
  run reaching the iteration-1 state.
* `loop_source_eosL`: the EOS stops (exit at a loop cut, or the last token).

`host.sim.GeneralLOne` instantiates these at `L = 1` with the existing cases and re-derives
`loop_source`. -/

/-! ## The six loop cases -/

/-- The loop cases of the decode template after a prompt of any length. -/
structure LoopCases (ok : St LF.S → SSrv → Bool) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE)
    (fixA : List Nat) where
  ord : LoopCase ok P s0 tab0 fixA
  clear : LoopCase ok P s0 tab0 fixA
  grow : LoopCase ok P s0 tab0 fixA
  fill : LoopCase ok P s0 tab0 fixA
  clearFill : LoopCase ok P s0 tab0 fixA
  clearGrow : LoopCase ok P s0 tab0 fixA

section Sel
variable {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}

/-- **The loop case of iteration `i` after a prompt of length `L`**: `CLEAR` iff
`i % 256 = 0`; `GROWTH` iff `(L + i + 1) % 256 = 0`, `FILL` iff `(L + i + 1) % 256 = 255`;
`CLEARGROWTH`/`CLEARFILL` when both. -/
def loopSelL (cs : LoopCases ok P s0 tab0 fixA) (L i : Nat) : LoopCase ok P s0 tab0 fixA :=
  if i % 256 = 0 then
    (if (L + i + 1) % 256 = 0 then cs.clearGrow else if (L + i + 1) % 256 = 255 then cs.clearFill else cs.clear)
  else if (L + i + 1) % 256 = 0 then cs.grow else if (L + i + 1) % 256 = 255 then cs.fill else cs.ord

theorem loopSelL_cases (cs : LoopCases ok P s0 tab0 fixA) (L i : Nat) :
    (i % 256 = 0 ∧ (L + i + 1) % 256 = 0 ∧ loopSelL cs L i = cs.clearGrow) ∨
    (i % 256 = 0 ∧ (L + i + 1) % 256 = 255 ∧ loopSelL cs L i = cs.clearFill) ∨
    (i % 256 = 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255 ∧ loopSelL cs L i = cs.clear) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 0 ∧ loopSelL cs L i = cs.grow) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 255 ∧ loopSelL cs L i = cs.fill) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255 ∧ loopSelL cs L i = cs.ord) := by
  unfold loopSelL
  by_cases hc : i % 256 = 0
  · by_cases h0 : (L + i + 1) % 256 = 0
    · exact .inl ⟨hc, h0, by simp [hc, h0]⟩
    · by_cases h1 : (L + i + 1) % 256 = 255
      · exact .inr (.inl ⟨hc, h1, by simp [hc, h1]⟩)
      · exact .inr (.inr (.inl ⟨hc, h0, h1, by simp [hc, h0, h1]⟩))
  · by_cases h0 : (L + i + 1) % 256 = 0
    · exact .inr (.inr (.inr (.inl ⟨hc, h0, by simp [hc, h0]⟩)))
    · by_cases h1 : (L + i + 1) % 256 = 255
      · exact .inr (.inr (.inr (.inr (.inl ⟨hc, h1, by simp [hc, h1]⟩))))
      · exact .inr (.inr (.inr (.inr (.inr ⟨hc, h0, h1, by simp [hc, h0, h1]⟩))))

/-- A loop case's counter deltas are within `ΔJ`, `ΔH`, `ΔN`. -/
def LoopCase.Within (c : LoopCase ok P s0 tab0 fixA) (ΔJ ΔH ΔN : Nat) : Prop :=
  c.s1.next - s0.next ≤ ΔJ ∧ c.s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH ∧ c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN

/-- **The six cases' template facts**: each oracle consists of its case's distinct answers,
exactly the two growth cases grow the capacity, and the counter deltas are bounded. -/
structure LoopCases.Facts (cs : LoopCases ok P s0 tab0 fixA) (ΔJ ΔH ΔN : Nat) : Prop where
  cOrd : cs.ord.S0.oracle.all (fun q => ordD.contains q) = true
  cClear : cs.clear.S0.oracle.all (fun q => clearD.contains q) = true
  cGrow : cs.grow.S0.oracle.all (fun q => growD.contains q) = true
  cFill : cs.fill.S0.oracle.all (fun q => fillD.contains q) = true
  cClearFill : cs.clearFill.S0.oracle.all (fun q => clearFillD.contains q) = true
  cClearGrow : cs.clearGrow.S0.oracle.all (fun q => clearGrowD.contains q) = true
  gOrd : cs.ord.grow = false
  gClear : cs.clear.grow = false
  gGrow : cs.grow.grow = true
  gFill : cs.fill.grow = false
  gClearFill : cs.clearFill.grow = false
  gClearGrow : cs.clearGrow.grow = true
  dOrd : cs.ord.Within ΔJ ΔH ΔN
  dClear : cs.clear.Within ΔJ ΔH ΔN
  dGrow : cs.grow.Within ΔJ ΔH ΔN
  dFill : cs.fill.Within ΔJ ΔH ΔN
  dClearFill : cs.clearFill.Within ΔJ ΔH ΔN
  dClearGrow : cs.clearGrow.Within ΔJ ΔH ΔN

/-- **What the loop needs of the cases at prompt length `L`**: the selected case's growth
flag, its oracle at every iteration of the loop, and its counter deltas. -/
structure LoopCases.OkAt (cs : LoopCases ok P s0 tab0 fixA) (L ΔJ ΔH ΔN : Nat) : Prop where
  grow : ∀ i, (loopSelL cs L i).grow = decide ((L + i + 1) % 256 = 0)
  good : ∀ (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (i nx : Nat), 1 ≤ i → i + 2 < T → L + T < 2 ^ 29 →
    tk (i + 1) ≠ 248044 → tk (i + 1) < 2 ^ 32 → Good (valL ρ T tk L i nx) (loopSelL cs L i).S0.oracle
  within : ∀ i, (loopSelL cs L i).Within ΔJ ΔH ΔN

/-- **The six cases at every prompt length**, from their template facts (LinGood, per class). -/
theorem LoopCases.okAt {cs : LoopCases ok P s0 tab0 fixA} {ΔJ ΔH ΔN : Nat} (hf : cs.Facts ΔJ ΔH ΔN) (L : Nat) :
    cs.OkAt L ΔJ ΔH ΔN where
  grow i := by
    rcases loopSelL_cases cs L i with ⟨_, h, e⟩ | ⟨_, h, e⟩ | ⟨_, h, _, e⟩ | ⟨_, h, e⟩ | ⟨_, h, e⟩ | ⟨_, h, _, e⟩ <;>
      rw [e]
    · rw [hf.gClearGrow]; simp [h]
    · rw [hf.gClearFill]; simp [h]
    · rw [hf.gClear]; simp [h]
    · rw [hf.gGrow]; simp [h]
    · rw [hf.gFill]; simp [h]
    · rw [hf.gOrd]; simp [h]
  good ρ T tk i nx hi1 hT hLT htok ht := by
    rcases loopSelL_cases cs L i with ⟨h1, h2, e⟩ | ⟨h1, h2, e⟩ | ⟨h1, h2, h3, e⟩ | ⟨h1, h2, e⟩ | ⟨h1, h2, e⟩ |
      ⟨h1, h2, h3, e⟩ <;> rw [e]
    · exact good_of_mem (good_clearGrowL hi1 h1 h2 hT (by omega) (by omega) htok ht) hf.cClearGrow
    · exact good_of_mem (good_clearFillL hi1 h1 h2 hT (by omega) (by omega) htok ht) hf.cClearFill
    · exact good_of_mem (good_clearL hi1 h1 h2 h3 hT (by omega) (by omega) htok ht) hf.cClear
    · exact good_of_mem (good_growL h1 h2 hT (by omega) (by omega) htok ht) hf.cGrow
    · exact good_of_mem (good_fillL h1 h2 hT (by omega) (by omega) htok ht) hf.cFill
    · exact good_of_mem (good_ordL h1 h2 h3 hT (by omega) (by omega) htok ht) hf.cOrd
  within i := by
    rcases loopSelL_cases cs L i with ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, _, e⟩ <;>
      rw [e]
    · exact hf.dClearGrow
    · exact hf.dClearFill
    · exact hf.dClear
    · exact hf.dGrow
    · exact hf.dFill
    · exact hf.dOrd

end Sel

/-! ## The acceptance functions' simulation facts -/

/-- The simulation facts of an acceptance function `ok` framing the arrays `framed`: the
one-step theorems (checked and at any reached state) and the growth of the target's mlx state
along its checked runs and steps. -/
structure AccSim (P : LoadP) (VBOk : (Nat → F64) → Prop) (ok : St LF.S → SSrv → Bool) (framed : List Nat) where
  jsP : Disp.JSP LF
  hj : jsP.lo = P.lo ∧ jsP.hi = P.E ∧ jsP.framed = framed
  sim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk
  simL : ∀ r, Disp.StepSimXL LF (LR P r) ok (Disp.Kp jsP) VBOk
  ng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
    (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
    runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx
  ngL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
    Disp.Kp jsP K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → ok s S = true →
    interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx

/-- The load world's acceptance with framed arrays `framed`, at the template's native
parameters `loadP0`. -/
noncomputable def AccSim.load (framed : List Nat) : AccSim loadP0 LoopVBOk (Disp.okJS (loadJSP framed)) framed where
  jsP := loadJSP framed
  hj := ⟨rfl, rfl, rfl⟩
  sim r := loadStepSim framed r
  simL r := loadStepSimL framed r
  ng r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht := runOk_ngrow framed r hK hν hr hok hrun ht
  ngL r _ _ _ _ _ _ _ _ _ _ _ hK hν hr hh hok hs ht := step_ngrow framed r hK hν hr hh hok hs ht

/-- A final case with its answers `D` and the simulation facts of its second segment's
acceptance (framing the spread's new array `aN` as well). -/
structure FinalSim (P : LoadP) (VBOk : (Nat → F64) → Prop) (okA : St LF.S → SSrv → Bool) (s0 : St LF.S)
    (tab0 : List SymE) (cE : Nat) (D : List Ans) where
  okB : St LF.S → SSrv → Bool
  aN : Nat
  fc : FinalCase okA okB s0 tab0 cE aN
  cover : fc.S0.oracle.all (fun q => D.contains q) = true
  acc : AccSim P VBOk okB [2673447, 12502, aN]
  ne1 : aN ≠ 2673447
  ne2 : aN ≠ 12502

/-- The EOS exit case at a loop cut with its acceptances' facts. -/
structure ExitSim (P : LoadP) (VBOk : (Nat → F64) → Prop) (okA : St LF.S → SSrv → Bool) (s0 : St LF.S)
    (tab0 : List SymE) (cE : Nat) where
  okB : St LF.S → SSrv → Bool
  aN : Nat
  ec : ExitCase okA okB s0 s0 tab0 cE aN []
  cover : ec.S0.oracle.all (fun q => eosD.contains q) = true
  acc : AccSim P VBOk okB [2673447, 12502, aN]
  ne2 : aN ≠ 12502

/-- An EOS final case with its answers `D` and its acceptances' facts. -/
structure FinalESim (P : LoadP) (VBOk : (Nat → F64) → Prop) (okA : St LF.S → SSrv → Bool) (s0 : St LF.S)
    (tab0 : List SymE) (cE : Nat) (D : List Ans) where
  okB : St LF.S → SSrv → Bool
  aN : Nat
  ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)]
  cover : ec.S0.oracle.all (fun q => D.contains q) = true
  acc : AccSim P VBOk okB [2673447, 12502, aN]
  ne2 : aN ≠ 12502

/-! ## The loop -/

/-- **The loop after a prompt of length `L`, up to iteration `J`** (`1 ≤ J ≤ T - 2`): from the
invariant at iteration 1, the `J - 1` iterations reach the invariant at iteration `J`; only
tokens `2 … J` need to be other than EOS. -/
theorem loop_reach_toL {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop}
    (S : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (cs : LoopCases ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val}
    (J : Nat) (hJ1 : 1 ≤ J) (hJT : J + 2 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k ≤ J → tk k ≠ 248044)
    (hVB : ∀ i nx, 1 ≤ i → i < J → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i < J → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    {t1 : St LF.S} {C1 : CSrv} (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t1 C1) :
    ∃ t C, runC LF (iterSteps (fun i => (loopSelL cs L i).n) 1 (J - 1)) t1 C1 = some (t, C) ∧ CSrv.Le C1 C ∧
      LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN J t C := by
  obtain ⟨t, C, hr, hinv⟩ := loop_all_toL S.sim S.hj.1 S.hj.2.1 S.hj.2.2 st (loopSelL cs L) J hJT hlen
    (fun i hi1 hiJ nx => hcs.good ρ T tk i nx hi1 (by omega) hLT (notEos (i + 1) (by omega) (by omega))
      (by have := htk (i + 1) (by omega); omega))
    (fun i hi1 hiJ nx hnx => hVB i nx hi1 hiJ hnx) hcs.grow (by omega) htk
    (fun i => (hcs.within i).1) (fun i => (hcs.within i).2.1) (fun i => (hcs.within i).2.2) hJ hH hN S.ng hG h1 hJ1
  exact ⟨t, C, hr, runC_le _ _ _ _ _ hr, hinv⟩

/-- **The loop after a prompt of length `L`**: from the invariant at iteration 1 (supplied by
the prefill), the `T - 3` iterations, each its selected case, reach the invariant at the final
iteration `T - 2`. -/
theorem loop_reachL {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop}
    (S : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (cs : LoopCases ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val}
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k + 2 ≤ T → tk k ≠ 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 < T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    {t1 : St LF.S} {C1 : CSrv} (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t1 C1) :
    ∃ t C, runC LF (iterSteps (fun i => (loopSelL cs L i).n) 1 (T - 3)) t1 C1 = some (t, C) ∧ CSrv.Le C1 C ∧
      LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN (T - 2) t C := by
  have := loop_reach_toL S st cs hcs (T - 2) (by omega) (by omega) hLT hlen htk
    (fun k hk hkJ => notEos k hk (by omega)) (fun i nx h1 h2 hnx => hVB i nx h1 (by omega) hnx) hJ hH hN
    (fun i h1 h2 => hG i h1 (by omega)) h1
  rw [show T - 2 - 1 = T - 3 by omega] at this
  exact this

/-- **The decode route after a prompt of length `L`**, from any run reaching the
iteration-1 state where the invariant holds (the prefill's conclusion): the loop and the final
case (one of three, by the cache-clear tests of the last two tokens) halt, the `emitted`
binding is the cut's prefix followed by the first `T - 1` readbacks, and `G` holds at the end. -/
theorem loop_sourceL {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} {cE : Nat}
    (S : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (cs : LoopCases ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    (F0 : FinalSim P VBOk ok s0 tab0 cE (finalDG false false))
    (F1 : FinalSim P VBOk ok s0 tab0 cE (finalDG true false))
    (F2 : FinalSim P VBOk ok s0 tab0 cE (finalDG false true))
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {env : Env} {nm : Name}
    (henv : lookupEnv nm env = some cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → FinalGStepL Gx P fixA F0.fc L ρ T tk toks G)
    (hF0 : (T - 2) % 256 = 0 → FinalGStepL Gx P fixA F1.fc L ρ T tk toks G)
    (hF1 : (T - 1) % 256 = 0 → FinalGStepL Gx P fixA F2.fc L ρ T tk toks G)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF := by
  obtain ⟨t, C, hrL, hLe, hinv⟩ := loop_reachL S st cs hcs hT hLT (by omega) htk
    (fun k hk hkT => notEos k hk (by omega)) (fun i nx h1 h2 hnx => hVB i nx h1 (by omega) hnx) hJ hH hN hG h1
  have key : ∀ {D : List Ans} (F : FinalSim P VBOk ok s0 tab0 cE D), Good (valL ρ T tk L (T - 2) (tk T)) D →
      FinalGStepL Gx P fixA F.fc L ρ T tk toks G →
      ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
        (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
        CSrv.Le C1 CF ∧ G tF CF := by
    intro D F hD hGF
    obtain ⟨tF, CF, v, hrF, hv, hem, hLeF, hGoal⟩ := final_stepL S.sim F.acc.sim S.ng F.acc.ng S.simL S.ngL S.hj
      F.acc.hj st F.fc hfr17 hcE hb F.ne1 F.ne2 hinv hT hlen (good_of_mem hD F.cover)
      (hVB (T - 2) (tk T) (by omega) (by omega) (htk T le_rfl)) henv hGF
    have hrun := runC_trans hpre (runC_trans hrL hrF)
    exact ⟨_, tF, CF, fun n hn => runC_halted_le hrun (by rw [hv]; rfl) hn, ⟨v, hv⟩, hem, hLe.trans hLeF, hGoal⟩
  have hg := good_finalGL (ρ := ρ) (T := T) (tk := tk) (L := L) (i := T - 2) (nx := tk T) (by omega) (by omega)
    (notEos (T - 2 + 1) (by omega) (by omega)) (notEos T (by omega) le_rfl) (by omega)
    (by have := htk (T - 2 + 1) (by omega); omega) (by have := htk T le_rfl; omega)
  by_cases hc0 : (T - 2) % 256 = 0
  · have e0 : decide ((T - 2) % 256 = 0) = true := decide_eq_true hc0
    have e1 : decide ((T - 2 + 1) % 256 = 0) = false := decide_eq_false (by omega)
    rw [e0, e1] at hg
    exact key F1 hg (hF0 hc0)
  · by_cases hc1 : (T - 1) % 256 = 0
    · have e0 : decide ((T - 2) % 256 = 0) = false := decide_eq_false hc0
      have e1 : decide ((T - 2 + 1) % 256 = 0) = true := decide_eq_true (by omega)
      rw [e0, e1] at hg
      exact key F2 hg (hF1 hc1)
    · have e0 : decide ((T - 2) % 256 = 0) = false := decide_eq_false hc0
      have e1 : decide ((T - 2 + 1) % 256 = 0) = false := decide_eq_false (by omega)
      rw [e0, e1] at hg
      exact key F0 hg (hF hc0 hc1)

/-- **The decode route's EOS stop after a prompt of length `L`**: token `k` (`2 ≤ k ≤ T`) is
EOS and tokens `2 … k - 1` are not. From any run reaching the iteration-1 state where the
invariant holds, the loop up to the cut that reads token `k` and the EOS exit case (`k < T`) or
an EOS final case (`k = T`, by the cache-clear test of the yielded token) halt; the `emitted`
binding is the cut's prefix followed by the first `k - 2` readbacks, `G` holds at the end, and
the end is related, with the loop's fixed addresses kept, to a case halt satisfying `Q` (e.g. its
finish reason). -/
theorem loop_source_eosL {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} {cE : Nat}
    (S : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (cs : LoopCases ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    (X : ExitSim P VBOk ok s0 tab0 cE)
    (FE0 : FinalESim P VBOk ok s0 tab0 cE (finalEDG false))
    (FE1 : FinalESim P VBOk ok s0 tab0 cE (finalEDG true))
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {env : Env} {nm : Name}
    (henv : lookupEnv nm env = some cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T) (notEos : ∀ j, 2 ≤ j → j < k → tk j ≠ 248044) (eos : tk k = 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    (hX : k < T → ExitGStepL Gx P fixA X.ec L ρ T tk toks (k - 1) G)
    (hF : k = T → (T - 2) % 256 ≠ 0 → FinalEGStepL Gx P fixA FE0.ec L ρ T tk toks G)
    (hF0 : k = T → (T - 2) % 256 = 0 → FinalEGStepL Gx P fixA FE1.ec L ρ T tk toks G)
    (Q : St LF.S → Prop) (hQX : Q X.ec.sF) (hQ0 : Q FE0.ec.sF) (hQ1 : Q FE1.ec.sF)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (k - 2)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF ∧
      ∃ i MF ν KF s S, Q s ∧ Rel LF (LR P (toks.drop i)) MF ν KF s S tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
  by_cases hk : k < T
  · -- EOS at the cut of iteration `k - 1`
    obtain ⟨t, C, hrL, hLe, hinv⟩ := loop_reach_toL S st cs hcs (k - 1) (by omega) (by omega) hLT (by omega) htk
      (fun j h1 hj => notEos j h1 (by omega)) (fun i nx h1 h2 hnx => hVB i nx h1 (by omega) hnx) hJ hH hN
      (fun i h1 h2 => hG i h1 (by omega) (by omega)) h1
    obtain ⟨tF, CF, v, hrF, hv, hem, hLeF, hGoal, MF, ν, KF, hrel, hfixF⟩ := exit_stepL S.sim X.acc.sim S.ng X.acc.ng
      S.simL S.ngL S.hj X.acc.hj X.ec hcE hb X.ne2 hinv
      (fun nx => good_of_mem (good_eosL (by omega) (by rw [show k - 1 + 1 = k by omega]; exact eos) (by omega))
        X.cover)
      (fun nx hnx => hVB (k - 1) nx (by omega) (by omega) hnx) henv (hX hk)
    have hrun := runC_trans hpre (runC_trans hrL hrF)
    refine ⟨_, tF, CF, fun n hn => runC_halted_le hrun (by rw [hv]; rfl) hn, ⟨v, hv⟩, ?_, hLe.trans hLeF, hGoal,
      _, MF, ν, KF, _, _, hQX, hrel, hfixF⟩
    rw [show k - 2 = k - 1 - 1 by omega]
    exact hem
  · -- EOS at the last token
    have hkT' : k = T := by omega
    subst hkT'
    obtain ⟨t, C, hrL, hLe, hinv⟩ := loop_reachL S st cs hcs hT hLT (by omega) htk
      (fun j h1 hj => notEos j h1 (by omega)) (fun i nx h1 h2 hnx => hVB i nx h1 (by omega) hnx) hJ hH hN
      (fun i h1 h2 => hG i h1 (by omega) h2) h1
    have fin : ∀ {D : List Ans} (F : FinalESim P VBOk ok s0 tab0 cE D), Q F.ec.sF →
        Good (valL ρ k tk L (k - 2) (tk k)) D →
        FinalEGStepL Gx P fixA F.ec L ρ k tk toks G →
        ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
          (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (k - 2)).map Val.num) ∧
          CSrv.Le C1 CF ∧ G tF CF ∧
          ∃ i MF ν KF s S, Q s ∧ Rel LF (LR P (toks.drop i)) MF ν KF s S tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
      intro D F hQ hD hGF
      obtain ⟨tF, CF, v, hrF, hv, hem, hLeF, hGoal, MF, ν, KF, hrel, hfixF⟩ := finalE_stepL S.sim F.acc.sim S.ng
        F.acc.ng S.simL S.ngL S.hj F.acc.hj st F.ec hfr17 hcE hb F.ne2 hinv hT hlen (good_of_mem hD F.cover)
        (hVB (k - 2) (tk k) (by omega) (by omega) (htk k le_rfl)) henv hGF
      have hrun := runC_trans hpre (runC_trans hrL hrF)
      exact ⟨_, tF, CF, fun n hn => runC_halted_le hrun (by rw [hv]; rfl) hn, ⟨v, hv⟩, hem, hLe.trans hLeF, hGoal,
        _, MF, ν, KF, _, _, hQ, hrel, hfixF⟩
    have hg := good_finalEGL (ρ := ρ) (T := k) (tk := tk) (L := L) (i := k - 2) (nx := tk k) (by omega) (by omega)
      (notEos (k - 2 + 1) (by omega) (by omega)) eos (by omega) (by have := htk (k - 2 + 1) (by omega); omega)
    by_cases hc0 : (k - 2) % 256 = 0
    · have e0 : decide ((k - 2) % 256 = 0) = true := decide_eq_true hc0
      rw [e0] at hg
      exact fin FE1 hQ1 hg (hF0 rfl hc0)
    · have e0 : decide ((k - 2) % 256 = 0) = false := decide_eq_false hc0
      rw [e0] at hg
      exact fin FE0 hQ0 hg (hF rfl hc0)

end Host.Ts.Sim
