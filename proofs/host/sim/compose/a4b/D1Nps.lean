import host.sim.compose.a4b.D1SplitData
import host.sim.compose.a4b.SetupDropLegacy
import host.sim.compose.MergeValue
import host.sim.compose.PreGrow
import host.sim.stage.NextStep

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

def Book (T : Nat) (tk : Nat → Nat) (x : SegInst FF) : Prop :=
  (chunkBook 1 x ∧ fixedCells x) ∧ setupInputs T tk x

noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (m : List (Nat × Q))
    (s : St FF.S) (S : SSrv) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP m s S (setupI 1)
    with B := Book T tk }

noncomputable abbrev npsCut (NB T : Nat) (tk : Nat → Nat) :=
  cut NB T tk D1StageSplit.map_start D1StageSplit.s0 D1StageSplit.S0
noncomputable abbrev g1Cut (NB T : Nat) (tk : Nat → Nat) :=
  cut NB T tk D1StageSplit.map_g1_FIN_first D1StageSplit.s1 D1StageSplit.S1

theorem toNps (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) :
    CutConv (withMem Mem (SetupCommon.nextCut NB T tk π 1)) (withMem Mem (npsCut NB T tk)) := by
  apply (SetupDrop.toSingleton NB T tk π hMem).trans
  rintro x ⟨hr, hq⟩ hb
  refine ⟨x, rfl, rfl, ⟨?_, hq⟩, hb⟩
  change RelB FF _ wideP [] x.M x.ν x.K (D1StageSplit.s0 : St FF.S)
    ⟨D1StageSplit.S0.tab, []⟩ x.t x.C
  rw [startEq, startTab]
  exact hr

theorem stageSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      D1StageSplit.st0.okL (Disp.KpJ setupJ 4096) wideP r (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hj rfl rfl rfl rfl rfl r setupW_ok
  apply hs.mono
  intro s S h
  change (Disp.okJSJ setupJ (okBackFXS setupP) 4096 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  simpa only [P, backRest] using h.1

theorem stageGrowSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      D1StageSplit.st0.okL (Disp.KpJ setupJ 4096) wideP r (VBOkF loopVB) := by
  apply (wideGrowSim NB T tk r y0).mono
  intro s S h
  change (Disp.okJSJ setupJ (okBackFXS setupP) 4096 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  exact h.1

kernel_rfl cnt1 : countersOkB D1StageSplit.s0 D1StageSplit.s1 = true

theorem nps {NB T : Nat} {tk : Nat → Nat} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y)
    (horacle : ∀ ν, MapOk ν (setupI 1) [(9, .L)] → Good ν D1StageSplit.st0.S0.oracle) :
    CutStep (withMem Mem (npsCut NB T tk)) (withMem Mem (g1Cut NB T tk)) (D1StageSplit.st0.tpl.n + 1) := by
  apply (D1StageSplit.site0 (stageSim NB T tk)).step
    (fun x hq hb => ⟨hb.1.1.1.1, hq.1⟩)
    (fun x hq _ => horacle x.ν hq.2.2)
  rintro x M t C hq ⟨hb, hm⟩ hrel hext hrun hmerged
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t.ffi) :=
    (D1StageSplit.site0 (stageSim NB T tk)).ngrow (fun stk y0 => stageGrowSim NB T tk stk y0) hq.1 hb.1.1.1 hrel hrun
  change PQ setupJ D1StageSplit.map_g1_FIN_first (setupI 1)
      (⟨M, Conv.resVal x.ν D1StageSplit.ws0
        (Conv.resF SymE.var D1StageSplit.st0.S2.tab D1StageSplit.S0.tab.length x.ν), x.K, t, C⟩ : SegInst FF) ∧
    Book T tk ⟨M, Conv.resVal x.ν D1StageSplit.ws0
      (Conv.resF SymE.var D1StageSplit.st0.S2.tab D1StageSplit.S0.tab.length x.ν), x.K, t, C⟩ ∧
    Mem ⟨M, Conv.resVal x.ν D1StageSplit.ws0
      (Conv.resF SymE.var D1StageSplit.st0.S2.tab D1StageSplit.S0.tab.length x.ν), x.K, t, C⟩
  have hvals := post_mergeP (ws := D1StageSplit.ws0) (qs := [.L, .L, .L])
    (f := Conv.resF SymE.var D1StageSplit.st0.S2.tab D1StageSplit.S0.tab.length x.ν)
    hq.1 hq.2.2 (by rw [ws0]; decide) (by rw [ws0]; rfl)
    (by intro p hp; have he : p = (9, Q.L) := List.mem_singleton.mp hp; subst p; rw [ws0]; decide)
    (by
      intro j w q hw hqj
      have hqL : q = Q.L := by simpa using nth?_mem_some hqj
      subst q
      have hj : j < 3 := by simpa only [ws0, List.length_cons, List.length_nil] using nth?_lt _ _ _ hw
      exact resultValue hq.2.2.1 hj)
    (by intro j w q hw hqj; have hqL : q = Q.L := by simpa using nth?_mem_some hqj
        subst q; change 1 ≤ 2 ^ 20; decide)
  refine ⟨⟨hvals.1, hq.2.1, ?_⟩, ?_, hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng,
    tokens_of_grow hrel hmerged ng (countersOkB_tokens cnt1)⟩ hm⟩
  · simpa [ws0, D1StageSplit.map_start, D1StageSplit.map_g1_FIN_first] using hvals.2
  · obtain ⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩, hids⟩ := hb.1
    have hi1 : (bridgeOf D1StageSplit.s1.ffi).active = false := by rw [bridge1]; exact inactive0
    obtain ⟨_, _, r0⟩ := hrel.ffi.1
    obtain ⟨_, _, r1⟩ := hmerged.ffi.1
    have sameBridge : bridgeOf t.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi1).bridge.1.trans (bridge1.trans (r0.toR inactive0).bridge.1.symm)
    refine ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hd, ?_⟩, ?_⟩, ?_⟩
    · intro Cx Pc Kc weights kind NE IP G init
      change Host.Mlx.FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t.ffi) = _
      rw [sameBridge]
      exact hfresh Cx Pc Kc weights kind NE IP G init
    · change M.a 2586 = 2586 ∧ M.a 2589 = 2589
      rw [hext.a]
      exact hids
    · constructor
      · intro j hj
        change Conv.resVal x.ν D1StageSplit.ws0
          (Conv.resF SymE.var D1StageSplit.st0.S2.tab D1StageSplit.S0.tab.length x.ν) j = _
        rw [Conv.resVal_off (by simp [ws0] <;> omega)]
        exact hb.2.1 j hj
      · change M.a 2590 = 2590
        rw [hext.a]
        exact hb.2.2

theorem finalRowL {i : Cls.Inst} (hi : InRow final_cold.r0 i) : i.L = 1 := by
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [final_cold.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  omega

noncomputable def nps_FIN_first__start__g1_FIN_first (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    StagePiece FF [final_cold.r0] [⟨[(0, .L), (1, .o), (2, .C)], Stage.NextStep.FIN.O⟩]
      (fun i => withMem (Mem i.L) (SetupCommon.nextCut NB T tk π i.L)) (fun _ => withMem (Mem 1) (g1Cut NB T tk)) where
  m := [(9, .L)]
  n := 180
  O := D1StageSplit.st0.S0.oracle
  chk r hr := by
    obtain rfl := List.mem_singleton.mp hr
    exact List.all_eq_true.mp D1StageSplit.chk_site0 _ (by simp)
  ok r hr i hi _ := by
    obtain rfl := List.mem_singleton.mp hr
    have hL := finalRowL hi
    have horacle : ∀ ν, MapOk ν (setupI 1) [(9, .L)] → Good ν D1StageSplit.st0.S0.oracle := by
      intro ν hm
      apply good_of_row (List.all_eq_true.mp D1StageSplit.chk_site0 _ (by simp)) hi
      refine ⟨?_, trivial⟩
      change ν 9 = F64.ofNat i.L
      rw [hL]
      exact hm.1
    change StageCall (withMem (Mem i.L) (SetupCommon.nextCut NB T tk π i.L)) (withMem (Mem 1) (g1Cut NB T tk)) 180
    rw [hL]
    exact StageCall.intro (toNps NB T tk π (hMem 1)) (nps (hMem 1) horacle) (CutConv.refl _)

end Host.Ts.Sim.Compose.D1Split
