import host.sim.GeneralLoop
import host.sim.LoopExit
import host.sim.EosFacts
import host.sim.template.OraclesEos
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Load Host.Load.Run.Full Host.Load.Run.Tail

/-! # The decode route's EOS stop for every token budget

Token `k` of the valuation is EOS (`2 ≤ k ≤ T`, `T ≥ 3`) and tokens `1 … k - 1` are not:
the boot prefix and the loop up to the cut that reads token `k` (`loop_reach_to`), then the
exit case `EOSX` (`k < T`) or one of the two EOS final cases (`k = T`, by the residue of the
yielded token's cache-clear test). The route halts, emits tokens `1 … k - 1`, and its
`generation.stats.finishReason` is `"stop"`. The loop keeps the `generation` cell fixed
(`loopFixE`), so the halt's finish reason transfers through the end relation. -/

/-- The loop's fixed addresses with the `generation` cell. -/
abbrev loopFixE : List Nat := loopFixC ++ [genCell]

theorem loopSel_fixGen (i : Nat) : (loopSel i).σ.a genCell = genCell := by
  rcases loopSel_cases i with ⟨_, e⟩ | ⟨_, e⟩ | ⟨_, e⟩ | ⟨_, _, _, e⟩ <;> rw [e]
  · exact CLEAR.fixGen
  · exact FILL.fixGen
  · exact GROWTH.fixGen
  · exact ORDINARY.fixGen

/-- The loop case of iteration `i`, fixing the `generation` cell too. -/
noncomputable def loopSelE (i : Nat) : LoopCase ok loadP0 Base.s0 Base.S0.tab loopFixE :=
  LoopCase.addFix (loopSel i) genCell (loopSel_fixGen i)

/-- The loop invariant at the cut (iteration 1), for any fixed-address list (`base_inv`). -/
theorem base_invF {Gx : Nat → Map → St LF.S → CSrv → Prop} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {nx : Nat}
    (fixA : List Nat) (ΔJ ΔH ΔN : Nat) (hT : 3 ≤ T) (h0 : ρ 0 = F64.ofNat T) (h1 : ρ 1 = F64.ofNat (tk 1))
    (h2 : ρ 2 = F64.ofNat (tk 2)) (h17 : ρ 17 = F64.ofNat nx) (hnx : nx ≤ 2 ^ 20)
    (hρ : ∀ k, 3 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k))
    (hG : Gx 1 Base.M (P.ta3272 (tailReads ρ T)) (Base.COf ρ)) :
    LoopInv Gx loadP0 Base.s0 Base.S0.tab fixA ρ T tk (loopReads ρ T) (arrOf P.s3272 12502) ΔJ ΔH ΔN 1
      (P.ta3272 (tailReads ρ T)) (Base.COf ρ) := by
  have hjs := (Base.relJS ρ ⟨Base.S0.tab, []⟩ rfl (fun q hq => by cases hq)).setFfi (Base.Y (tailReads ρ T))
  have hr := hjs.toRel (FR := LR loadP0 (tailReads ρ T)) (Base.loadR _)
  rw [base_val h0 h1 h2 h17] at hr
  refine ⟨Base.M, Base.K, nx, arrOf P.s3272 2673447, ?_, ?_, rfl, rfl, rfl, ?_, hnx, ?_, ?_, ?_, ?_,
    fun _ _ => rfl, hG⟩
  · rw [ta3272_eq]; exact hr
  · show frOf Base.s0 (arrOf P.s3272 2673447) (arrOf P.s3272 12502) = _
    rfl
  · show some (NumV.ref 2) = some (Base.M.nv (.ref 79))
    rw [Base.num79]
  · intro j hj
    match j, hj with
    | 0, _ =>
      show (Base.COf ρ).val (.ref 2) = _
      rw [cut_val ρ ⟨[], by simp⟩ 2 (.inr rfl), h2]
    | j + 1, hj =>
      have hj' : j < T - 2 := by rw [loopReads_length] at hj; omega
      have hj'' : j < (tailReads ρ T).length := by simp [tailReads]; omega
      show (Base.COf ρ).val (tailReads ρ T)[j] = _
      simp only [tailReads, List.getElem_map, List.getElem_range, CSrv.val]
      rw [hρ (j + 3) (by omega) (by omega)]
  · show 0 ≤ _; exact Nat.zero_le _
  · rw [ta3272_eq]
    show Base.Y0.next ≤ Base.X0.next + (1 - 1) * ΔH
    rw [Base.next_same]; exact Nat.le_add_right _ _
  · rw [ta3272_eq]
    show Base.Y0.nnext ≤ Base.X0.nnext + (1 - 1) * ΔN
    rw [Base.nnext_same]; exact Nat.le_add_right _ _

/-- **The loop up to the cut of iteration `J`** (`1 ≤ J ≤ T - 2`): from decode boundary 0,
the boot prefix and the `J - 1` loop iterations reach the loop invariant (with the `generation`
cell fixed) at iteration `J`; only tokens `1 … J` need to be other than EOS. -/
theorem loop_reach_to {Gx : Nat → Map → St LF.S → CSrv → Prop}
    (T : Nat) (hT : 3 ≤ T) (hTb : T ≤ 262144) (ρ : Nat → F64) (tk : Nat → Nat)
    (h0 : ρ 0 = F64.ofNat T) (hρ : ∀ k, 1 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k))
    (hnat : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k) (htk : ∀ k, k ≤ T → tk k ≤ 2 ^ 20)
    (J : Nat) (hJ1 : 1 ≤ J) (hJT : J + 2 ≤ T)
    (notEos : ∀ k, 1 ≤ k → k ≤ J → tk k ≠ 248044)
    (hG0 : Gx 1 Base.M (P.ta3272 (tailReads ρ T)) (Base.COf ρ))
    (hG : ∀ i, 1 ≤ i → i < J → LoopGStep Gx (loopSel i) ρ T tk (loopReads ρ T) i) :
    ∃ t C, runC Host.Load.ffi (32711604 + iterSteps (fun i => (loopSel i).n) 1 (J - 1)) (P.ta0 (tailReads ρ T))
        ⟨P.S0.tab.map (SymE.eval ρ)⟩ = some (t, C) ∧ CSrv.Le (Base.COf ρ) C ∧
      LoopInv Gx loadP0 Base.s0 Base.S0.tab loopFixE ρ T tk (loopReads ρ T) (arrOf P.s3272 12502) 151053 3738 2445
        J t C := by
  have htk' : ∀ k, k ≤ T → tk k < 2 ^ 32 := fun k hk => by have := htk k hk; omega
  have hpre := prefix_run (tailReads ρ T) ρ (good_bootAnswers h0 (hρ 1 (by omega) (by omega)) hT (by omega)
    (notEos 1 le_rfl hJ1) (by have := htk 1 (by omega); omega))
  obtain ⟨nx, hnx, h17⟩ := hnat 17
  have hinv1 := base_invF (Gx := Gx) (tk := tk) loopFixE 151053 3738 2445 hT h0 (hρ 1 (by omega) (by omega))
    (hρ 2 (by omega) (by omega)) h17 hnx (fun k hk hkT => hρ k (by omega) hkT) hG0
  obtain ⟨t, C, hrL, hinv⟩ := loop_all_to (fun r => loadStepSim [2673447, 12502] r) rfl rfl rfl Base.loopStart
    loopSelE J hJT (by rw [loopReads_length]; omega)
    (fun i hi1 hiJ _ => loopSel_good hi1 (by omega) (notEos (i + 1) (by omega) (by omega)) (by omega) (htk' _ (by omega)))
    (fun i hi1 hiJ nx hnx => loopVal_vb hnat (by omega) (by omega) (by omega) (by have := cap_le i; omega)
      (htk _ (by omega)) (htk _ (by omega)) hnx)
    (fun i => loopSel_grow i) (by omega) (fun i _ => by have := cap_le i; omega) htk
    (fun i => (loopSel_d i).1) (fun i => (loopSel_d i).2.1) (fun i => (loopSel_d i).2.2)
    (by show T * 151053 < 2 ^ 61; omega)
    (by show Base.s0.ffi.mlx.next + T * 3738 + (131072 - Base.s0.ffi.mlx.next) < 2 ^ 46
        rw [Base.mnext_val]; omega)
    (by show Base.s0.ffi.mlx.nnext + T * 2445 + (2 ^ 40 - Base.s0.ffi.mlx.nnext) < 2 ^ 62
        rw [Base.mnnext_val]; omega)
    (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht => runOk_ngrow [2673447, 12502] r hK hν hr hok hrun ht)
    (fun i hi1 hiJ => hG i hi1 hiJ) hinv1 hJ1
  exact ⟨t, C, runC_trans hpre hrL, runC_le _ _ _ _ _ hrL, hinv⟩

/-- The emitted numbers of a stop after `m + 1` tokens: tokens `1 … m + 1` of `ρ`. -/
theorem emitted_numbers_take {ρ : Nat → F64} {T m : Nat} {C : CSrv} {s : St LSt} (hm : m ≤ T - 1)
    (hC : CSrv.Le (Base.COf ρ) C)
    (he : (bindingOf s (entryEnv P.s0) chars!"emitted").bind (Extract.elements s) =
      some (arrOf P.s3272 12502 ++ ((loopReads ρ T).take m).map Val.num)) :
    emittedNumbers s (entryEnv P.s0) C = some ((List.range (m + 1)).map fun k => ρ (k + 1)) := by
  unfold emittedNumbers emittedValues
  rw [he, cut_emitted, Option.bind_some, show [Val.num (.ref 1)] ++ ((loopReads ρ T).take m).map Val.num =
    (NumV.ref 1 :: (loopReads ρ T).take m).map Val.num from rfl]
  apply mapM_num
  · simp [loopReads_length]; omega
  · intro i h1 h2
    simp only [List.getElem_map, List.getElem_range]
    match i, h1 with
    | 0, _ => exact cut_val ρ hC 1 (.inl rfl)
    | j + 1, h1 =>
      rw [List.getElem_cons_succ, List.getElem_take]
      match j, h1 with
      | 0, _ => exact cut_val ρ hC 2 (.inr rfl)
      | j + 1, h1 =>
        have hj : j < (tailReads ρ T).length := by simp [loopReads, tailReads] at h1 ⊢; omega
        show C.val (tailReads ρ T)[j] = _
        simp only [tailReads, List.getElem_map, List.getElem_range, CSrv.val]

/-- An EOS final case of the template, from the loop invariant at `T - 2` (as `loop_source`'s
final cases). -/
theorem finalE_source {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okB : St LF.S → SSrv → Bool} {aN : Nat}
    (ec : ExitCase ok okB Base.s0 (finalStart Base.s0 Base.S0.tab.length) (Base.S0.tab ++ [.var 17]) 2590 aN
      [.num (.ref 79)])
    (hok : okB = Disp.okJS (loadJSP [2673447, 12502, aN])) (ha2 : aN ≠ 12502)
    {T : Nat} (hT : 3 ≤ T) {ρ : Nat → F64} {tk : Nat → Nat} (hnat : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k)
    (htk : ∀ k, k ≤ T → tk k ≤ 2 ^ 20) (hTb : T ≤ 262144) {t : St LF.S} {C : CSrv}
    (hinv : LoopInv Gx loadP0 Base.s0 Base.S0.tab loopFixE ρ T tk (loopReads ρ T) (arrOf P.s3272 12502) 151053 3738
      2445 (T - 2) t C)
    (hgood : Good (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) ec.S0.oracle)
    (hfin : Stop.statsField ec.sF (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop"))
    (hGF : FinalEGStep Gx loadP0 loopFixE ec ρ T tk (loopReads ρ T) G) :
    ∃ tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF (entryEnv P.s0) chars!"emitted").bind (Extract.elements tF) =
        some (arrOf P.s3272 12502 ++ ((loopReads ρ T).take (T - 2)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      Stop.statsField tF (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop") := by
  subst hok
  obtain ⟨tF, CF, v, hrF, hv, hem, hLe, hGoal, MF, ν, KF, hrel, hfixF⟩ := finalE_step (G := G)
    (fun r => loadStepSim [2673447, 12502] r) (fun r => loadStepSim [2673447, 12502, aN] r)
    (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht => runOk_ngrow [2673447, 12502] r hK hν hr hok hrun ht)
    (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht => runOk_ngrow [2673447, 12502, aN] r hK hν hr hok hrun ht)
    (fun r => loadStepSimL [2673447, 12502] r)
    (fun r _ _ _ _ _ _ _ _ _ _ _ hK hν hr hh hok hs ht => step_ngrow [2673447, 12502] r hK hν hr hh hok hs ht)
    ⟨rfl, rfl, rfl⟩ ⟨rfl, rfl, rfl⟩ Base.loopStart ec Base.noVar17 (by decide) (by decide) ha2 hinv hT
    (by rw [loopReads_length]; omega) hgood
    (loopVal_vb hnat (by omega) (by omega) (by omega) (by have := cap_le (T - 2); omega) (htk _ (by omega))
      (htk _ (by omega)) (htk _ le_rfl)) emitted_cell hGF
  exact ⟨tF, CF, v, hrF, hv, hem, hLe, hGoal, statsField_stop hrel (hfixF genCell (by decide)) hfin⟩

/-- **The decode route's EOS stop for every token budget `T ≥ 3`**, for a valuation `ρ` of
the run's variables (budget `ρ 0 = T`, tokens `ρ j = tk j`) whose token `k` (`2 ≤ k ≤ T`) is EOS
and tokens `1 … k - 1` are not, and the graph side as a further loop invariant `Gx` with its
obligations at the cut, at the loop cases before the stop and at the stop's case (goal `G`):
booting the world whose readbacks after the first two tokens are tokens `3 … T` of `ρ`, the
route halts, emits tokens `1 … k - 1` of `ρ` (EOS is not yielded), `G` holds at its end, and
`generation.stats.finishReason` is `"stop"` there. -/
theorem loop_source_eos {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
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
  have htk' : ∀ j, j ≤ T → tk j < 2 ^ 32 := fun j hj => by have := htk j hj; omega
  by_cases hk : k < T
  · -- EOS at the cut of iteration `k - 1`
    obtain ⟨t, C, hrL, hLe0, hinv⟩ := loop_reach_to (Gx := Gx) T hT hTb ρ tk h0 hρ hnat htk (k - 1) (by omega)
      (by omega) (fun j h1 hj => notEos j h1 (by omega)) hG0 (fun i hi1 hiJ => hG i hi1 (by omega) (by omega))
    obtain ⟨tF, CF, v, hrF, hv, hem, hLe, hGoal, MF, ν, KF, hrel, hfixF⟩ := exit_step (G := G)
      (fun r => loadStepSim [2673447, 12502] r) (fun r => loadStepSim [2673447, 12502, 3123589] r)
      (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht => runOk_ngrow [2673447, 12502] r hK hν hr hok hrun ht)
      (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht =>
        runOk_ngrow [2673447, 12502, 3123589] r hK hν hr hok hrun ht)
      (fun r => loadStepSimL [2673447, 12502] r)
      (fun r _ _ _ _ _ _ _ _ _ _ _ hK hν hr hh hok hs ht => step_ngrow [2673447, 12502] r hK hν hr hh hok hs ht)
      ⟨rfl, rfl, rfl⟩ ⟨rfl, rfl, rfl⟩ EOSX.exitCase (by decide) (by decide) EOSX.aN_ne.2 hinv
      (fun nx => EOSX.good (by omega) (by rw [show k - 1 + 1 = k by omega]; exact eos) (by omega))
      (fun nx hnx => loopVal_vb hnat (by omega) (by omega) (by omega) (by have := cap_le (k - 1); omega)
        (htk _ (by omega)) (htk _ (by omega)) hnx) emitted_cell (hX hk)
    have hrun := runC_trans hrL hrF
    have hh : isHalt tF.ctl = true := by rw [hv]; rfl
    refine ⟨32711604 + iterSteps (fun i => (loopSel i).n) 1 (k - 1 - 1) + EOSX.exitCase.n, tF, CF,
      fun n hn => ?_, ⟨v, hv⟩, ?_, hGoal, statsField_stop hrel (hfixF genCell (by decide)) EOSX.finish_reason⟩
    · rw [boot_tail]
      exact runC_halted_le hrun hh hn
    · rw [show k - 1 = k - 1 - 1 + 1 by omega]
      exact emitted_numbers_take (by omega) (hLe0.trans hLe) hem
  · -- EOS at the last token
    have hkT' : k = T := by omega
    subst hkT'
    obtain ⟨t, C, hrL, hLe0, hinv⟩ := loop_reach_to (Gx := Gx) k hT hTb ρ tk h0 hρ hnat htk (k - 2) (by omega)
      (by omega) (fun j h1 hj => notEos j h1 (by omega)) hG0 (fun i hi1 hiJ => hG i hi1 (by omega) (by omega))
    have fin : ∀ {okB : St LF.S → SSrv → Bool} {aN : Nat}
        (ec : ExitCase ok okB Base.s0 (finalStart Base.s0 Base.S0.tab.length) (Base.S0.tab ++ [.var 17]) 2590 aN
          [.num (.ref 79)]),
        okB = Disp.okJS (loadJSP [2673447, 12502, aN]) → aN ≠ 12502 →
        Good (loopVal ρ k k (k - 2) (cap (k - 2)) (tk (k - 1)) (tk (k - 2)) (tk k)) ec.S0.oracle →
        Stop.statsField ec.sF (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop") →
        FinalEGStep Gx loadP0 loopFixE ec ρ k tk (loopReads ρ k) G →
        ∃ N tF CF, (∀ n, N ≤ n → ((bootL Route.cx (worldTail (tailReads ρ k)) 2000).bind fun start =>
            runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (tF, CF)) ∧
          (∃ v, tF.ctl = .halt (.normal v)) ∧
          emittedNumbers tF (entryEnv P.s0) CF = some ((List.range (k - 1)).map fun j => ρ (j + 1)) ∧ G tF CF ∧
          Stop.statsField tF (entryEnv P.s0) chars!"finishReason" = some (.str chars!"stop") := by
      intro okB aN ec hok ha2 hgood hfin hGF
      obtain ⟨tF, CF, v, hrF, hv, hem, hLe, hGoal, hstop⟩ :=
        finalE_source ec hok ha2 hT hnat htk hTb hinv hgood hfin hGF
      have hrun := runC_trans hrL hrF
      have hh : isHalt tF.ctl = true := by rw [hv]; rfl
      refine ⟨32711604 + iterSteps (fun i => (loopSel i).n) 1 (k - 2 - 1) + ec.n, tF, CF,
        fun n hn => ?_, ⟨v, hv⟩, ?_, hGoal, hstop⟩
      · rw [boot_tail]
        exact runC_halted_le hrun hh hn
      · rw [show k - 1 = k - 2 + 1 by omega]
        exact emitted_numbers_take (by omega) (hLe0.trans hLe) hem
    by_cases hc0 : (k - 2) % 256 = 0
    · have hg := FINALEC0.good (rest := ρ) (T := k) (tok := tk (k - 1)) (ptok := tk (k - 2)) (next := tk k) (i := k - 2)
        (by omega) (by omega) hc0 (notEos (k - 1) (by omega) (by omega)) eos (by omega) (htk' (k - 1) (by omega))
      rw [show k - 2 + 2 = k by omega] at hg
      exact fin FINALEC0.exitCase rfl FINALEC0.aN_ne.2 hg FINALEC0.finish_reason (hF0 rfl hc0)
    · have hg := FINALE.good (rest := ρ) (T := k) (tok := tk (k - 1)) (ptok := tk (k - 2)) (next := tk k) (i := k - 2)
        (by omega) (by omega) hc0 (notEos (k - 1) (by omega) (by omega)) eos (by omega) (htk' (k - 1) (by omega))
      rw [show k - 2 + 2 = k by omega] at hg
      exact fin FINALE.exitCase rfl FINALE.aN_ne.2 hg FINALE.finish_reason (hF rfl hc0)

end Host.Load.Run.Tpl
