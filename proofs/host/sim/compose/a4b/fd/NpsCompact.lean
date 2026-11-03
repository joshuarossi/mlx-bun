import host.sim.compose.a4b.fd.NpsCompactRel
import host.sim.compose.a4b.fd.NpsValues
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

def npsMap : List (Nat × Q) := [(9, .L), (12, .n)]
def afterNpsBook (T L : Nat) (tk : Nat → Nat) (x : SegInst FF) : Prop :=
  Disp.KpJ FDFrames.startJ 131072 x.K ∧ x.K.fr 4910 = none ∧
  (∃ π : List Nat, π.length = L ∧ (∀ k ∈ π, k < 248320) ∧ x.K.fr 2665 = some ([], π.map natV)) ∧
  AneFresh x.t ∧ setupInputs T tk x ∧ fixedCells x ∧ x.K.D ≤ 3540
noncomputable def afterNpsCut (NB T : Nat) (tk : Nat → Nat) (ρ : List Nat) (i : Cls.Inst) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) FDFrames.startJ wideGPf npsMap
      PRE_fd_vw_r0.s2 PRE_fd_vw_r0.S2 i with
    B := fun x => afterNpsBook T i.L tk x ∧ PromptFr ρ x ∧ NativeAt 0 0 PRE_fd_vw_r0.s2 x.t }

kernel_rfl keepNN1 : PRE_fd_vw_r0.kd0.nn0 = PRE_fd_vw_r0.kd0.nn1
kernel_rfl keepNK1 : PTrie.keys PRE_fd_vw_r0.kd0.node = []
kernel_rfl sameNext1 : (mlxOf PRE_fd_vw_r0.s1.ffi).next = (mlxOf PRE_fd_vw_r0.s2.ffi).next
kernel_rfl sameNnext1 : (mlxOf PRE_fd_vw_r0.s1.ffi).nnext = (mlxOf PRE_fd_vw_r0.s2.ffi).nnext

theorem reservedCwsOff {j : Nat} (hj : j < 9) : Conv.idx? j PRE_fd_vw_r0.cws0 = none := by
  simp [PRE_fd_vw_r0.cws0, Conv.idx?, show 12 ≠ j by omega]
theorem reservedWsOff {j : Nat} (hj : j < 9) : PRE_fd_vw_r0.ws0.contains j = false := by
  apply Bool.eq_false_iff.mpr
  intro hc
  have h := Nat.le_of_ble_eq_true (List.all_eq_true.mp npsWsLow j (List.contains_iff_mem.mp hc))
  omega

theorem nps_compact {NB T : Nat} {tk : Nat → Nat} {ρ : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (h1 : 1 ≤ i.L) (hL : i.L ≤ 2 ^ 20) (hn : i.n = i.L - 1) :
    CutConv (withMem Mem (mergedPinCut NB T tk ρ i.L)) (withMem Mem (afterNpsCut NB T tk ρ i)) := by
  rintro x hR ⟨⟨hB, hpin, hnat⟩, hm⟩
  have hcdata := nps_compact_rel hR hB
  obtain ⟨hr, ν, hν, hvb, hkp, hmap⟩ := hR
  obtain ⟨⟨hframeBook, hsmall, hoffset⟩, hins, hids, hbase, hcall, hNB, hnative⟩ := hB
  obtain ⟨hk, hmemo, π', hlen, hvocab, hframe, hfresh⟩ := hframeBook
  obtain ⟨hc, hctx, hmemo', hp, hD, hfrP⟩ := hcdata
  have hvals := post_callP (m := [(9, .L)]) (m' := npsMap) (qs := [.n])
    (S2 := PRE_fd_vw_r0.st0.S2.tab) (Sm := PRE_fd_vw_r0.S1.tab)
    (ws := PRE_fd_vw_r0.ws0) (cws := PRE_fd_vw_r0.cws0)
    (nr := PRE_fd_vw_r0.nr0) (Es := [some npsResult]) hvb
    (show MapOk ν i [(9, .L)] from ⟨hmap.1, trivial⟩)
    (by intro p hp; obtain rfl := List.mem_singleton.mp hp; decide)
    PRE_fd_vw_r0.mergeTab0 rfl
    (by rw [← PRE_fd_vw_r0.tab0_0]; exact PRE_fd_vw_r0.mergeLen0.symm)
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
        subst q; change i.n ≤ loopVB c; have hc' : c = 12 := by simpa [PRE_fd_vw_r0.cws0] using nth?_mem_some hc
        subst c; change i.n ≤ 2 ^ 20; rw [hn]; omega)
    (by intro p hp; simpa [npsMap, PRE_fd_vw_r0.cws0] using hp)
  have hpq : VBOkF loopVB (npsPair x).ν ∧ MapOk (npsPair x).ν i npsMap := by
    change VBOkF loopVB (Shift.valuation θZ1 x.ν) ∧ MapOk (Shift.valuation θZ1 x.ν) i npsMap
    rw [hν]
    exact hvals
  refine ⟨npsPair x, rfl, rfl, ⟨hc, hpq.1, hctx.1, hpq.2⟩,
    ⟨⟨hctx, hmemo', hp, hfresh, ⟨?_, ?_⟩, ?_, ?_⟩, hfrP.trans hpin,
      ⟨sameNext1 ▸ hnat.1, sameNnext1 ▸ hnat.2⟩⟩,
    hMem x _ (NTrack.conv rfl rfl (funext fun k => congrArg x.M.node (compact_node_id keepNN1 keepNK1 k))
      (by change x.M.a (PRE_fd_vw_r0.kappa0.a 12504) = _; rw [PRE_fd_vw_r0.zkap0, Conv.Map.compact_lt (by decide)])) hm⟩
  · intro j hj
    change Shift.valuation θZ1 x.ν j = _
    unfold θZ1
    rw [Conv.valuation_compactθZ_out (reservedCwsOff hj) (reservedWsOff hj)]
    exact hins.1 j hj
  · change x.M.a (PRE_fd_vw_r0.kappa0.a 2590) = 2590
    have he : PRE_fd_vw_r0.kappa0.a 2590 = 2590 := by rw [PRE_fd_vw_r0.zkap0]; exact Conv.Map.compact_lt (by decide)
    rw [he]; exact hins.2
  · change x.M.a (PRE_fd_vw_r0.kappa0.a 2586) = 2586 ∧ x.M.a (PRE_fd_vw_r0.kappa0.a 2589) = 2589
    have h6 : PRE_fd_vw_r0.kappa0.a 2586 = 2586 := by rw [PRE_fd_vw_r0.zkap0]; exact Conv.Map.compact_lt (by decide)
    have h9 : PRE_fd_vw_r0.kappa0.a 2589 = 2589 := by rw [PRE_fd_vw_r0.zkap0]; exact Conv.Map.compact_lt (by decide)
    rw [h6, h9]; exact hids
  · rw [hD]; omega
end Host.Ts.Sim.Compose.FDVW
