import host.sim.compose.a4b.VWNpsCompactRel
import host.sim.compose.a4b.VWNpsValues
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

def npsMap : List (Nat × Q) := [(9, .L), (1087, .n)]
def afterNpsBook (T L : Nat) (tk : Nat → Nat) (x : SegInst FF) : Prop :=
  Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
  (∃ π : List Nat, π.length = L ∧ (∀ k ∈ π, k < 248320) ∧ x.K.fr 2665 = some ([], π.map natV)) ∧
  AneFresh x.t ∧ setupInputs T tk x ∧ fixedCells x ∧ x.K.D ≤ 3540
noncomputable def afterNpsCut (NB T : Nat) (tk : Nat → Nat) (i : Cls.Inst) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP npsMap
      PRE_first_tail_x15_r0.s19 PRE_first_tail_x15_r0.S19 i with B := afterNpsBook T i.L tk }

theorem reservedCwsOff {j : Nat} (hj : j < 9) : Conv.idx? j PRE_first_tail_x15_r0.cws1 = none := by
  simp [PRE_first_tail_x15_r0.cws1, Conv.idx?, show 1087 ≠ j by omega]
theorem reservedWsOff {j : Nat} (hj : j < 9) : PRE_first_tail_x15_r0.ws1.contains j = false := by
  apply Bool.eq_false_iff.mpr
  intro hc
  have h := Nat.le_of_ble_eq_true (List.all_eq_true.mp npsWsLow j (List.contains_iff_mem.mp hc))
  omega

theorem nps_compact {NB T : Nat} {tk : Nat → Nat} {i : Cls.Inst}
    (h1 : 1 ≤ i.L) (hL : i.L ≤ 2 ^ 20) (hn : i.n = i.L - 1) :
    CutConv (mergedCut NB T tk i.L) (afterNpsCut NB T tk i) := by
  rintro x hR hB
  have hcdata := nps_compact_rel hR hB
  obtain ⟨hr, ν, hν, hvb, hkp, hmap⟩ := hR
  obtain ⟨⟨hframeBook, hsmall, hoffset⟩, hins, hids, hbase, hcall, hNB, hnative⟩ := hB
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩ := hframeBook
  obtain ⟨hc, hctx, hmemo', hp, hD⟩ := hcdata
  have hvals := post_callP (m := [(9, .L)]) (m' := npsMap) (qs := [.n])
    (S2 := PRE_first_tail_x15_r0.st1.S2.tab) (Sm := PRE_first_tail_x15_r0.S18.tab)
    (ws := PRE_first_tail_x15_r0.ws1) (cws := PRE_first_tail_x15_r0.cws1)
    (nr := PRE_first_tail_x15_r0.nr1) (Es := [some npsResult]) hvb
    (show MapOk ν i [(9, .L)] from ⟨hmap.1, trivial⟩)
    (by intro p hp; obtain rfl := List.mem_singleton.mp hp; decide)
    PRE_first_tail_x15_r0.mergeTab1 rfl
    (by rw [← PRE_first_tail_x15_r0.tab0_1]; exact PRE_first_tail_x15_r0.mergeLen1.symm)
    (by decide) (by decide) rfl rfl (by decide) npsResults
    (by
      intro j o he
      cases j with
      | zero =>
        cases he
        refine ⟨npsResult, .n, rfl, rfl, ?_⟩
        change npsResult.eval ν = F64.ofNat i.n
        rw [hn]
        exact npsResultEval hmap.1 h1 (by omega)
      | succ j => cases he)
    (by intro j c q hc hq; have hq' : q = Q.n := by simpa using nth?_mem_some hq
        subst q; change i.n ≤ loopVB c; have hc' : c = 1087 := by simpa [PRE_first_tail_x15_r0.cws1] using nth?_mem_some hc
        subst c; change i.n ≤ 2 ^ 20; rw [hn]; omega)
    (by intro p hp; simpa [npsMap, PRE_first_tail_x15_r0.cws1] using hp)
  have hpq : VBOkF loopVB (npsPair x).ν ∧ MapOk (npsPair x).ν i npsMap := by
    change VBOkF loopVB (Shift.valuation θZ1 x.ν) ∧ MapOk (Shift.valuation θZ1 x.ν) i npsMap
    rw [hν]
    exact hvals
  refine ⟨npsPair x, rfl, rfl, ⟨hc, hpq.1, hctx.1, hpq.2⟩,
    hctx, hmemo', hp, hfresh, ⟨?_, ?_⟩, ?_, ?_⟩
  · intro j hj
    change Shift.valuation θZ1 x.ν j = _
    unfold θZ1
    rw [Conv.valuation_compactθZ_out (reservedCwsOff hj) (reservedWsOff hj)]
    exact hins.1 j hj
  · change x.M.a (PRE_first_tail_x15_r0.kappa1.a 2590) = 2590
    have he : PRE_first_tail_x15_r0.kappa1.a 2590 = 2590 := by rw [PRE_first_tail_x15_r0.zkap1]; exact Conv.Map.compact_lt (by decide)
    rw [he]; exact hins.2
  · change x.M.a (PRE_first_tail_x15_r0.kappa1.a 2586) = 2586 ∧ x.M.a (PRE_first_tail_x15_r0.kappa1.a 2589) = 2589
    have h6 : PRE_first_tail_x15_r0.kappa1.a 2586 = 2586 := by rw [PRE_first_tail_x15_r0.zkap1]; exact Conv.Map.compact_lt (by decide)
    have h9 : PRE_first_tail_x15_r0.kappa1.a 2589 = 2589 := by rw [PRE_first_tail_x15_r0.zkap1]; exact Conv.Map.compact_lt (by decide)
    rw [h6, h9]; exact hids
  · rw [hD]; omega
end Host.Ts.Sim.Compose.VWFirst
