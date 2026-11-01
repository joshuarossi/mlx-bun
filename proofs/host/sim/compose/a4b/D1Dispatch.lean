import host.sim.compose.a4b.D1G1
import host.sim.compose.a4b.D1DispatchGrow
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

noncomputable abbrev g2Cut (NB T : Nat) (tk : Nat → Nat) :=
  typedCut NB T tk D1StageSplit.s21 D1StageSplit.S21

kernel_rfl cnt21 : countersOkB D1StageSplit.s20 D1StageSplit.s21 = true

private theorem bridge21 : bridgeOf D1StageSplit.s21.ffi = bridgeOf D1StageSplit.s20.ffi :=
  typedRun21.src_bridge.trans typedRun19.dst_bridge.symm

theorem dispatch (NB T : Nat) (tk : Nat → Nat) {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y)
    (horacle : ∀ ν, MapOk ν (setupI 1) D1StageSplit.map_g1_FIN_first → Good ν D1StageSplit.st1.S0.oracle) :
    CutStep (withMem Mem (dispatchCut NB T tk)) (withMem Mem (g2Cut NB T tk)) 155 := by
  rintro t C ⟨x, rfl, rfl, ⟨π, K0, hr, hb, hip, hins, hmap⟩, ⟨hfresh, hids⟩, hmem⟩
  let d := dispatchSite NB T tk (D1Typed.bytes π)
  have h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1StageSplit.s20 d.tpl.S0 x.t x.C := by
    have h := hr.withOracle (horacle x.ν hmap)
    change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1StageSplit.s20
      ⟨D1StageSplit.S20.tab, D1StageSplit.st1.S0.oracle⟩ x.t x.C at h
    rw [← d.tab] at h
    exact h
  obtain ⟨M', t', C', hrun, hext, h2⟩ := Conv.site_merge d.tpl d.start rfl d.sim d.localOk
    hb.context hb.valuation d.foot d.nodup d.bound d.trace D1StageSplit.S20.tab.length h0
  rw [d.tab] at hext
  replace h2 := d.merged h2
  have hm := h2.resMerge hr.srv.num hext (runC_le _ _ _ _ _ hrun) (d.tab ▸ d.tpl.len2)
    d.len d.freshNodup d.fresh
  have hm' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] M' x.ν x.K D1StageSplit.s21
      ⟨D1StageSplit.S21.tab, []⟩ t' C' := by
    rw [D1StageSplit.mergeTab1]
    exact hm
  have ng := d.ngrow (dispatchGrowSim NB T tk (D1Typed.bytes π)) hb.valuation hb.context h0 hrun
  have ip : SetupD1Input.InputAt π (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun)
  have book : SetupD1.ForwardBook π K0 (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) := by
    refine ⟨hb.length, hb.vocab, hb.valuation, hb.singleton, hb.context, hb.incoming,
      hb.incomingPrompt, hb.incomingMemo, hb.frames, hb.offset, hb.lo, hb.hi, ?_⟩
    change ∃ asR ret tr, x.K.base' = _
    rw [hext.a]
    exact hb.inputEvent
  have inputs : setupInputs T tk (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) :=
    ⟨hins.1, by change M'.a 2590 = 2590; rw [hext.a]; exact hins.2⟩
  have ids : fixedCells (⟨M', x.ν, x.K, t', C'⟩ : SegInst FF) := by
    change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
    rw [hext.a]
    exact hids
  have hi20 : (bridgeOf D1StageSplit.s20.ffi).active = false := by
    have hbr := typedRun19.dst_bridge.trans D1StageSplit.k1.src_bridge.symm
    rw [hbr, bridge1]
    exact inactive0
  have hi21 : (bridgeOf D1StageSplit.s21.ffi).active = false := by rw [bridge21]; exact hi20
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hm'.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hi21).bridge.1.trans (bridge21.trans (r0.toR hi20).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  exact ⟨t', C', hrun, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨π, K0, hm', book, ip, inputs, hmap⟩, ⟨fresh, ids⟩,
    hMem x _ ⟨runC_le _ _ _ _ _ hrun, hext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens cnt21)⟩ hmem⟩

noncomputable def disp_D1__g1_FIN_first__g2_fin_first (NB T : Nat) (tk : Nat → Nat) (Mem : SegInst FF → Prop)
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) :
    StagePiece FF [final_cold.r0] [] (fun _ => withMem Mem (dispatchCut NB T tk)) (fun _ => withMem Mem (g2Cut NB T tk)) where
  m := D1StageSplit.map_g1_FIN_first
  n := 155
  O := D1StageSplit.st1.S0.oracle
  chk r hr := by
    obtain rfl := List.mem_singleton.mp hr
    exact List.all_eq_true.mp D1StageSplit.chk_site1 _ (by simp)
  ok r hr i hi ho := by
    obtain rfl := List.mem_singleton.mp hr
    have hL := finalRowL hi
    refine StageCall.intro (CutConv.refl _) (dispatch NB T tk hMem ?_) (CutConv.refl _)
    intro ν hm
    apply ho.1 ν
    simpa only [D1StageSplit.map_g1_FIN_first, MapOk, setupI, Cls.Inst.get, hL] using hm

end Host.Ts.Sim.Compose.D1Split
