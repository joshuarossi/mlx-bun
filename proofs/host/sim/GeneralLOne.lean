import host.sim.GeneralL
import host.sim.General
import host.sim.GeneralEos
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Load Host.Load.Run.Full Host.Load.Run.Tail

/-! # The prompt of length 1 as an instance of the general loop

The existing template's cases are the six loop cases at `L = 1` (`loopCases1`; the two new
cases are never selected there: a cleared iteration `i % 256 = 0` has offset residue `2`, so
`CLEAR` fills both slots), `loopSelL loopCases1 1 = loopSel` (`loopSelL_one`), and they satisfy
the loop's requirements at `L = 1` (`loopCases1_okAt`). The existing route theorems follow
from the general ones with the existing boot prefix and base invariant: `loop_source_one`
(`loop_source`'s statement, from `loop_sourceL`) and `loop_source_eos_one`
(`loop_source_eos`'s, from `loop_source_eosL`). -/

/-- The existing loop cases at `L = 1`; `CLEAR` in the two new cases' slots. -/
noncomputable def loopCases1 : LoopCases ok loadP0 Base.s0 Base.S0.tab loopFixC where
  ord := LoopCase.addFix ORDINARY.loopCase cacheCell ORDINARY.fixCache
  clear := LoopCase.addFix CLEAR.loopCase cacheCell CLEAR.fixCache
  grow := LoopCase.addFix GROWTH.loopCase cacheCell GROWTH.fixCache
  fill := LoopCase.addFix FILL.loopCase cacheCell FILL.fixCache
  clearFill := LoopCase.addFix CLEAR.loopCase cacheCell CLEAR.fixCache
  clearGrow := LoopCase.addFix CLEAR.loopCase cacheCell CLEAR.fixCache

/-- **The six-way selection at `L = 1` is the existing one.** -/
theorem loopSelL_one (i : Nat) : loopSelL loopCases1 1 i = loopSel i := by
  unfold loopSelL loopSel
  by_cases h0 : i % 256 = 0
  · rw [ite_eq_left h0, ite_eq_right (show ¬ (1 + i + 1) % 256 = 0 by omega),
      ite_eq_right (show ¬ (1 + i + 1) % 256 = 255 by omega), ite_eq_left h0]
    rfl
  · rw [ite_eq_right h0, ite_eq_right h0]
    by_cases h3 : i % 256 = 253
    · rw [ite_eq_right (show ¬ (1 + i + 1) % 256 = 0 by omega), ite_eq_left (show (1 + i + 1) % 256 = 255 by omega),
        ite_eq_left h3]
      rfl
    · rw [ite_eq_right h3]
      by_cases h4 : i % 256 = 254
      · rw [ite_eq_left (show (1 + i + 1) % 256 = 0 by omega), ite_eq_left h4]
        rfl
      · rw [ite_eq_right (show ¬ (1 + i + 1) % 256 = 0 by omega), ite_eq_right (show ¬ (1 + i + 1) % 256 = 255 by omega),
          ite_eq_right h4]
        rfl

/-- The existing cases meet the loop's requirements at `L = 1`. -/
theorem loopCases1_okAt : loopCases1.OkAt 1 151053 3738 2445 where
  grow i := by
    rw [loopSelL_one, loopSel_grow]
    simp only [decide_eq_decide]
    omega
  good ρ T tk i nx hi1 hT hLT htok ht := by
    rw [loopSelL_one, valL_one]
    exact loopSel_good hi1 hT htok (by omega) ht
  within i := by
    rw [loopSelL_one]
    exact loopSel_d i

/-- The loop's acceptance. -/
noncomputable def loopAcc1 : AccSim loadP0 LoopVBOk ok [2673447, 12502] := AccSim.load _

/-- The three final cases. -/
noncomputable def finalSim1 : FinalSim loadP0 LoopVBOk ok Base.s0 Base.S0.tab 2590 (finalDG false false) where
  okB := FINAL.okB
  aN := 3123641
  fc := FINAL.finalCase
  cover := FINAL.cover
  acc := AccSim.load _
  ne1 := FINAL.aN_ne.1
  ne2 := FINAL.aN_ne.2

noncomputable def finalSimC0 : FinalSim loadP0 LoopVBOk ok Base.s0 Base.S0.tab 2590 (finalDG true false) where
  okB := FINALC0.okB
  aN := 3123642
  fc := FINALC0.finalCase
  cover := FINALC0.cover
  acc := AccSim.load _
  ne1 := FINALC0.aN_ne.1
  ne2 := FINALC0.aN_ne.2

noncomputable def finalSimC1 : FinalSim loadP0 LoopVBOk ok Base.s0 Base.S0.tab 2590 (finalDG false true) where
  okB := FINALC1.okB
  aN := 3123642
  fc := FINALC1.finalCase
  cover := FINALC1.cover
  acc := AccSim.load _
  ne1 := FINALC1.aN_ne.1
  ne2 := FINALC1.aN_ne.2

/-- The value bounds of the loop valuation at `L = 1`. -/
theorem valL_one_vb {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} (hnat : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k)
    (hTb : T ≤ 262144) (htk : ∀ k, k ≤ T → tk k ≤ 2 ^ 20) (i nx : Nat) (hi : i + 2 ≤ T) (hnx : nx ≤ 2 ^ 20) :
    LoopVBOk (valL ρ T tk 1 i nx) :=
  loopVal_vb hnat (by omega) (by omega) (by omega) (by have := capL_le (1 + i + 1); omega) (htk _ (by omega))
    (htk _ (by omega)) hnx

/-- **`loop_source` from the general theorem at `L = 1`.** -/
theorem loop_source_one {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    (T : Nat) (hT : 3 ≤ T) (hTb : T ≤ 262144) (ρ : Nat → F64) (tk : Nat → Nat)
    (h0 : ρ 0 = F64.ofNat T) (hρ : ∀ k, 1 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k))
    (hnat : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k) (htk : ∀ k, k ≤ T → tk k ≤ 2 ^ 20)
    (notEos : ∀ k, 1 ≤ k → k ≤ T → tk k ≠ 248044)
    (hG0 : Gx 1 Base.M (P.ta3272 (tailReads ρ T)) (Base.COf ρ))
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStep Gx (loopSel i) ρ T tk (loopReads ρ T) i)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 →
      FinalGStep Gx loadP0 loopFixC FINAL.finalCase ρ T tk (loopReads ρ T) G)
    (hF0 : (T - 2) % 256 = 0 → FinalGStep Gx loadP0 loopFixC FINALC0.finalCase ρ T tk (loopReads ρ T) G)
    (hF1 : (T - 1) % 256 = 0 → FinalGStep Gx loadP0 loopFixC FINALC1.finalCase ρ T tk (loopReads ρ T) G) :
    ∃ N tF CF, (∀ n, N ≤ n → ((bootL Route.cx (worldTail (tailReads ρ T)) 2000).bind fun start =>
        runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (tF, CF)) ∧
      (∃ v, tF.ctl = .halt (.normal v)) ∧
      emittedNumbers tF (entryEnv P.s0) CF = some ((List.range T).map fun k => ρ (k + 1)) ∧ G tF CF := by
  have hpre := prefix_run (tailReads ρ T) ρ (good_bootAnswers h0 (hρ 1 (by omega) (by omega)) hT (by omega)
    (notEos 1 (by omega) (by omega)) (by have := htk 1 (by omega); omega))
  obtain ⟨nx, hnx, h17⟩ := hnat 17
  have hinv1 := (LoopInvL_one (Gx := Gx) _ _ _ _ _ _ _).2 (base_inv (Gx := Gx) (tk := tk) 151053 3738 2445 hT h0
    (hρ 1 (by omega) (by omega)) (hρ 2 (by omega) (by omega)) h17 hnx (fun k hk hkT => hρ k (by omega) hkT) hG0)
  obtain ⟨N, tF, CF, hrun, hv, hem, hLe, hGoal⟩ := loop_sourceL (L := 1) loopAcc1 Base.loopStart Base.noVar17
    (by decide) (by decide) loopCases1 loopCases1_okAt finalSim1 finalSimC0 finalSimC1 emitted_cell hT (by omega)
    (by rw [loopReads_length]; omega) htk (fun k hk hkT => notEos k (by omega) hkT)
    (fun i nx hi1 hiT hnx => valL_one_vb hnat hTb htk i nx hiT hnx)
    (by show T * 151053 < 2 ^ 61; omega)
    (by show Base.s0.ffi.mlx.next + T * 3738 + (131072 - Base.s0.ffi.mlx.next) < 2 ^ 46
        rw [Base.mnext_val]; omega)
    (by show Base.s0.ffi.mlx.nnext + T * 2445 + (2 ^ 40 - Base.s0.ffi.mlx.nnext) < 2 ^ 62
        rw [Base.mnnext_val]; omega)
    (fun i h1 h2 => by rw [loopSelL_one]; exact (LoopGStepL_one _ i).2 (hG i h1 h2))
    (fun h1 h2 => (FinalGStepL_one _ (by omega)).2 (hF h1 h2))
    (fun h => (FinalGStepL_one _ (by omega)).2 (hF0 h))
    (fun h => (FinalGStepL_one _ (by omega)).2 (hF1 h)) hpre hinv1
  refine ⟨N, tF, CF, fun n hn => ?_, hv, emitted_numbers hT hLe hem, hGoal⟩
  rw [boot_tail]
  exact hrun n hn

/-! ## The EOS stops -/

/-- The existing loop cases at `L = 1`, fixing the `generation` cell too. -/
noncomputable def loopCases1E : LoopCases ok loadP0 Base.s0 Base.S0.tab loopFixE where
  ord := LoopCase.addFix loopCases1.ord genCell ORDINARY.fixGen
  clear := LoopCase.addFix loopCases1.clear genCell CLEAR.fixGen
  grow := LoopCase.addFix loopCases1.grow genCell GROWTH.fixGen
  fill := LoopCase.addFix loopCases1.fill genCell FILL.fixGen
  clearFill := LoopCase.addFix loopCases1.clear genCell CLEAR.fixGen
  clearGrow := LoopCase.addFix loopCases1.clear genCell CLEAR.fixGen

/-- Fixing one more address keeps the selected case's data. -/
theorem loopSelL_oneE (L i : Nat) :
    (loopSelL loopCases1E L i).n = (loopSelL loopCases1 L i).n ∧
      (loopSelL loopCases1E L i).S0 = (loopSelL loopCases1 L i).S0 ∧
      (loopSelL loopCases1E L i).s1 = (loopSelL loopCases1 L i).s1 ∧
      (loopSelL loopCases1E L i).S1 = (loopSelL loopCases1 L i).S1 ∧
      (loopSelL loopCases1E L i).σ = (loopSelL loopCases1 L i).σ ∧
      (loopSelL loopCases1E L i).grow = (loopSelL loopCases1 L i).grow := by
  unfold loopSelL
  split_ifs <;> exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- `LoopGStepV` reads a case only through its run, end and restart map. -/
theorem LoopGStepV_congr {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA fixA' : List Nat} {c : LoopCase ok P s0 tab0 fixA}
    {c' : LoopCase ok P s0 tab0 fixA'} {V : LoopVals} {toks : List NumV} {i : Nat}
    (hn : c.n = c'.n) (hS0 : c.S0 = c'.S0) (hs1 : c.s1 = c'.s1) (hS1 : c.S1 = c'.S1) (hσ : c.σ = c'.σ) :
    LoopGStepV Gx c V toks i ↔ LoopGStepV Gx c' V toks i := by
  unfold LoopGStepV
  rw [hn, hS0, hs1, hS1, hσ]

theorem loopCases1E_okAt : loopCases1E.OkAt 1 151053 3738 2445 where
  grow i := by
    rw [(loopSelL_oneE 1 i).2.2.2.2.2]
    exact loopCases1_okAt.grow i
  good ρ T tk i nx hi1 hT hLT htok ht := by
    rw [(loopSelL_oneE 1 i).2.1]
    exact loopCases1_okAt.good ρ T tk i nx hi1 hT hLT htok ht
  within i := by
    unfold LoopCase.Within
    rw [(loopSelL_oneE 1 i).2.2.1]
    exact loopCases1_okAt.within i

noncomputable def exitSim1 : ExitSim loadP0 LoopVBOk ok Base.s0 Base.S0.tab 2590 where
  okB := EOSX.okB
  aN := 3123589
  ec := EOSX.exitCase
  cover := EOSX.cover
  acc := AccSim.load _
  ne2 := EOSX.aN_ne.2

noncomputable def finalESim1 : FinalESim loadP0 LoopVBOk ok Base.s0 Base.S0.tab 2590 (finalEDG false) where
  okB := FINALE.okB
  aN := 3123626
  ec := FINALE.exitCase
  cover := FINALE.cover
  acc := AccSim.load _
  ne2 := FINALE.aN_ne.2

noncomputable def finalESimC0 : FinalESim loadP0 LoopVBOk ok Base.s0 Base.S0.tab 2590 (finalEDG true) where
  okB := FINALEC0.okB
  aN := 3123627
  ec := FINALEC0.exitCase
  cover := FINALEC0.cover
  acc := AccSim.load _
  ne2 := FINALEC0.aN_ne.2

/-- **`loop_source_eos` from the general theorem at `L = 1`.** -/
theorem loop_source_eos_one {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    (T : Nat) (hT : 3 ≤ T) (hTb : T ≤ 262144) (ρ : Nat → F64) (tk : Nat → Nat)
    (h0 : ρ 0 = F64.ofNat T) (hρ : ∀ k, 1 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k))
    (hnat : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k) (htk : ∀ k, k ≤ T → tk k ≤ 2 ^ 20)
    (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (notEos : ∀ j, 1 ≤ j → j < k → tk j ≠ 248044) (eos : tk k = 248044)
    (hG0 : Gx 1 Base.M (P.ta3272 (tailReads ρ T)) (Base.COf ρ))
    (hG : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → LoopGStep Gx (loopSel i) ρ T tk (loopReads ρ T) i)
    (hX : k < T → ExitGStep Gx loadP0 loopFixE EOSX.exitCase ρ T tk (loopReads ρ T) (k - 1) G)
    (hF : k = T → (T - 2) % 256 ≠ 0 → FinalEGStep Gx loadP0 loopFixE FINALE.exitCase ρ T tk (loopReads ρ T) G)
    (hF0 : k = T → (T - 2) % 256 = 0 → FinalEGStep Gx loadP0 loopFixE FINALEC0.exitCase ρ T tk (loopReads ρ T) G) :
    ∃ N tF CF, (∀ n, N ≤ n → ((bootL Route.cx (worldTail (tailReads ρ T)) 2000).bind fun start =>
        runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (tF, CF)) ∧
      (∃ v, tF.ctl = .halt (.normal v)) ∧
      emittedNumbers tF (entryEnv P.s0) CF = some ((List.range (k - 1)).map fun j => ρ (j + 1)) ∧ G tF CF ∧
      Stop.statsField tF (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop") := by
  have hpre := prefix_run (tailReads ρ T) ρ (good_bootAnswers h0 (hρ 1 (by omega) (by omega)) hT (by omega)
    (notEos 1 le_rfl (by omega)) (by have := htk 1 (by omega); omega))
  obtain ⟨nx, hnx, h17⟩ := hnat 17
  have hinv1 := (LoopInvL_one (Gx := Gx) _ _ _ _ _ _ _).2 (base_invF (Gx := Gx) (tk := tk) loopFixE 151053 3738 2445
    hT h0 (hρ 1 (by omega) (by omega)) (hρ 2 (by omega) (by omega)) h17 hnx (fun k hk hkT => hρ k (by omega) hkT) hG0)
  obtain ⟨N, tF, CF, hrun, hv, hem, hLe, hGoal, i, MF, ν, KF, s, S, hs, hrel, hfixF⟩ :=
    loop_source_eosL (L := 1) loopAcc1 Base.loopStart Base.noVar17 (by decide) (by decide) loopCases1E
      loopCases1E_okAt exitSim1 finalESim1 finalESimC0 emitted_cell hT (by omega) (by rw [loopReads_length]; omega)
      htk k hk2 hkT (fun j hj hjk => notEos j (by omega) hjk) eos
      (fun i nx hi1 hiT hnx => valL_one_vb hnat hTb htk i nx hiT hnx)
      (by show T * 151053 < 2 ^ 61; omega)
      (by show Base.s0.ffi.mlx.next + T * 3738 + (131072 - Base.s0.ffi.mlx.next) < 2 ^ 46
          rw [Base.mnext_val]; omega)
      (by show Base.s0.ffi.mlx.nnext + T * 2445 + (2 ^ 40 - Base.s0.ffi.mlx.nnext) < 2 ^ 62
          rw [Base.mnnext_val]; omega)
      (fun i h1 h2 h3 => by
        have e := loopSelL_oneE 1 i
        refine (LoopGStepV_congr e.1 e.2.1 e.2.2.1 e.2.2.2.1 e.2.2.2.2.1).2 ?_
        rw [loopSelL_one]
        exact (LoopGStepL_one _ i).2 (hG i h1 h2 h3))
      (fun h => (ExitGStepL_one _ _).2 (hX h))
      (fun h1 h2 => (FinalEGStepL_one _ (by omega)).2 (hF h1 h2))
      (fun h1 h2 => (FinalEGStepL_one _ (by omega)).2 (hF0 h1 h2))
      (fun s => Stop.statsField s (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop"))
      EOSX.finish_reason FINALE.finish_reason FINALEC0.finish_reason hpre hinv1
  refine ⟨N, tF, CF, fun n hn => ?_, hv, ?_, hGoal, statsField_stop hrel (hfixF genCell (by decide)) hs⟩
  · rw [boot_tail]
    exact hrun n hn
  · rw [show k - 1 = k - 2 + 1 by omega]
    exact emitted_numbers_take (by omega) hLe hem

end Host.Load.Run.Tpl
