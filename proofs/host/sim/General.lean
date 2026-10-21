import host.sim.GeneralLoop
import host.sim.LoopFinal
import host.sim.template.final.Case
import host.sim.template.finalc0.Case
import host.sim.template.finalc1.Case
import host.sim.template.OraclesFinal
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Load Host.Load.Run.Full Host.Load.Run.Tail

/-! # The decode route for every token budget

The actual source route booted with budget `T ≥ 3`: the boot prefix and the loop
(`loop_reach`), then the final case (one of three, by the budget's residue). The world's
readbacks after the first two tokens are the remaining tokens of the valuation, as
literals. The graph side is a further invariant `Gx` with its obligations; the composed
run halts and emits the `T` tokens of the valuation. -/

/-- **The decode route for every token budget `T ≥ 3`**, for a valuation `ρ` of the run's
variables (budget `ρ 0 = T`, tokens `ρ k = tk k`, no EOS) and the graph side as a further loop
invariant `Gx` with its obligations at the cut, at every loop case and at the final case (goal
`G`): booting the world whose readbacks after the first two tokens are tokens `3 … T` of `ρ`,
the route halts, emits tokens `1 … T` of `ρ`, and `G` holds at its end. -/
theorem loop_source {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    (T : Nat) (hT : 3 ≤ T) (hTb : T ≤ 262144) (ρ : Nat → F64) (tk : Nat → Nat)
    (h0 : ρ 0 = F64.ofNat T) (hρ : ∀ k, 1 ≤ k → k ≤ T → ρ k = F64.ofNat (tk k))
    (hnat : ∀ j, ∃ k ≤ 2 ^ 20, ρ j = F64.ofNat k) (htk : ∀ k, k ≤ T → tk k ≤ 2 ^ 20)
    (notEos : ∀ k, 1 ≤ k → k ≤ T → tk k ≠ 248044)
    (hG0 : Gx 1 Base.M (P.ta3272 (tailReads ρ T)) (Base.COf ρ))
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStep Gx (loopSel i) ρ T tk (loopReads ρ T) i)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → FinalGStep Gx loadP0 loopFixC FINAL.finalCase ρ T tk (loopReads ρ T) G)
    (hF0 : (T - 2) % 256 = 0 → FinalGStep Gx loadP0 loopFixC FINALC0.finalCase ρ T tk (loopReads ρ T) G)
    (hF1 : (T - 1) % 256 = 0 → FinalGStep Gx loadP0 loopFixC FINALC1.finalCase ρ T tk (loopReads ρ T) G) :
    ∃ N tF CF, (∀ n, N ≤ n → ((bootL Route.cx (worldTail (tailReads ρ T)) 2000).bind fun start =>
        runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (tF, CF)) ∧
      (∃ v, tF.ctl = .halt (.normal v)) ∧
      emittedNumbers tF (entryEnv P.s0) CF = some ((List.range T).map fun k => ρ (k + 1)) ∧ G tF CF := by
  have htk' : ∀ k, k ≤ T → tk k < 2 ^ 32 := fun k hk => by have := htk k hk; omega
  obtain ⟨t', C', hrL, hLe0, hinv⟩ := loop_reach T hT hTb ρ tk h0 hρ hnat htk notEos hG0 hG
  -- the final case, for any of the three
  have key : ∀ {okB : St LF.S → SSrv → Bool} {aN : Nat} (fc : FinalCase ok okB Base.s0 Base.S0.tab 2590 aN),
      okB = Disp.okJS (loadJSP [2673447, 12502, aN]) → aN ≠ 2673447 → aN ≠ 12502 →
      Good (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) fc.S0.oracle →
      FinalGStep Gx loadP0 loopFixC fc ρ T tk (loopReads ρ T) G →
      ∃ N tF CF, (∀ n, N ≤ n → ((bootL Route.cx (worldTail (tailReads ρ T)) 2000).bind fun start =>
          runC Host.Load.ffi n start ⟨P.S0.tab.map (SymE.eval ρ)⟩) = some (tF, CF)) ∧
        (∃ v, tF.ctl = .halt (.normal v)) ∧
        emittedNumbers tF (entryEnv P.s0) CF = some ((List.range T).map fun k => ρ (k + 1)) ∧ G tF CF := by
    intro okB aN fc hok ha1 ha2 hgood hGF
    subst hok
    obtain ⟨tF, CF, v, hrF, hv, hem, hLe, hGoal⟩ := final_step (G := G) (fun r => loadStepSim [2673447, 12502] r)
      (fun r => loadStepSim [2673447, 12502, aN] r)
      (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht => runOk_ngrow [2673447, 12502] r hK hν hr hok hrun ht)
      (fun r _ _ _ _ _ _ _ _ _ _ _ _ hK hν hr hok hrun ht => runOk_ngrow [2673447, 12502, aN] r hK hν hr hok hrun ht)
      (fun r => loadStepSimL [2673447, 12502] r)
      (fun r _ _ _ _ _ _ _ _ _ _ _ hK hν hr hh hok hs ht => step_ngrow [2673447, 12502] r hK hν hr hh hok hs ht)
      ⟨rfl, rfl, rfl⟩ ⟨rfl, rfl, rfl⟩ Base.loopStart fc
      Base.noVar17 (by decide) (by decide) ha1 ha2 hinv hT (by rw [loopReads_length]; omega) hgood
      (loopVal_vb hnat (by omega) (by omega) (by omega) (by have := cap_le (T - 2); omega) (htk _ (by omega))
        (htk _ (by omega)) (htk _ le_rfl)) emitted_cell hGF
    have hrun := runC_trans hrL hrF
    have hh : isHalt tF.ctl = true := by rw [hv]; rfl
    refine ⟨32711604 + iterSteps (fun i => (loopSel i).n) 1 (T - 3) + (fc.nA + 1 + 1 + fc.nB), tF, CF,
      fun n hn => ?_, ⟨v, hv⟩, emitted_numbers hT (hLe0.trans hLe) hem, hGoal⟩
    rw [boot_tail]
    exact runC_halted_le hrun hh hn
  by_cases hc0 : (T - 2) % 256 = 0
  · have hg := FINALC0.good (rest := ρ) (T := T) (ptok := tk (T - 2)) (i := T - 2) (by omega) (by omega) hc0
      (notEos (T - 1) (by omega) (by omega)) (notEos T (by omega) le_rfl) (by omega) (htk' (T - 1) (by omega))
      (htk' T le_rfl)
    rw [show T - 2 + 2 = T by omega] at hg
    exact key FINALC0.finalCase rfl FINALC0.aN_ne.1 FINALC0.aN_ne.2 hg (hF0 hc0)
  · by_cases hc1 : (T - 1) % 256 = 0
    · have hg := FINALC1.good (rest := ρ) (T := T) (ptok := tk (T - 2)) (i := T - 2) (by omega) (by omega)
        (by rw [show T - 2 + 1 = T - 1 by omega]; exact hc1)
        (notEos (T - 1) (by omega) (by omega)) (notEos T (by omega) le_rfl) (by omega) (htk' (T - 1) (by omega))
        (htk' T le_rfl)
      rw [show T - 2 + 2 = T by omega] at hg
      exact key FINALC1.finalCase rfl FINALC1.aN_ne.1 FINALC1.aN_ne.2 hg (hF1 hc1)
    · have hg := FINAL.good (rest := ρ) (T := T) (ptok := tk (T - 2)) (i := T - 2) (by omega) (by omega) hc0
        (by rw [show T - 2 + 1 = T - 1 by omega]; exact hc1)
        (notEos (T - 1) (by omega) (by omega)) (notEos T (by omega) le_rfl) (by omega) (htk' (T - 1) (by omega))
        (htk' T le_rfl)
      rw [show T - 2 + 2 = T by omega] at hg
      exact key FINAL.finalCase rfl FINAL.aN_ne.1 FINAL.aN_ne.2 hg (hF hc0 hc1)

end Host.Load.Run.Tpl
