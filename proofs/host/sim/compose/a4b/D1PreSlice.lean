import host.sim.compose.a4b.D1PreSliceFacts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem sim1 (NB T : Nat) (tk : Nat → Nat) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      D1StageSplit.okB1 (Disp.KpJ setupJ 4096) wideP [] (VBOkF loopVB) := by
  have he : D1StageSplit.okB1 = PRE_g0b.okB0 := rfl
  rw [he]
  exact SetupCommon.sim NB T tk

theorem book_fwd {NB T : Nat} {tk : Nat → Nat} {sa sb : St FF.S} {Sa Sb : SSrv}
    {x : SegInst FF} {M : Map} {t : St FF.S} {C : CSrv}
    (h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      x.M x.ν x.K sa Sa x.t x.C)
    (h1 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      M x.ν x.K sb Sb t C) (he : Ext x.M M Sa.tab.length)
    (hi : (bridgeOf sa.ffi).active = false) (hb : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hbook : Book T tk x) : Book T tk ⟨M, x.ν, x.K, t, C⟩ := by
  obtain ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩, hids⟩, hv, ha⟩ := hbook
  have hi' : (bridgeOf sb.ffi).active = false := by rw [hb]; exact hi
  obtain ⟨_, _, hn0⟩ := h0.ffi.1
  obtain ⟨_, _, hn1⟩ := h1.ffi.1
  have sameBridge : bridgeOf t.ffi = bridgeOf x.t.ffi :=
    (hn1.toR hi').bridge.1.trans (hb.trans (hn0.toR hi).bridge.1.symm)
  refine ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hd, ?_⟩, ?_⟩, hv, ?_⟩
  · intro Cx Pc Kc weights kind NE IP G init
    change Host.Mlx.FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t.ffi) = _
    rw [sameBridge]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  · exact ⟨(congrFun he.a 2586).trans hids.1, (congrFun he.a 2589).trans hids.2⟩
  · exact (congrFun he.a 2590).trans ha

theorem preSlice {NB T : Nat} {tk : Nat → Nat}
    (horacle : ∀ ν, MapOk ν (setupI 1) D1StageSplit.map_g1_FIN_first → Good ν D1StageSplit.S1.oracle) :
    CutStep (g1Cut NB T tk)
      (cut NB T tk D1StageSplit.map_g1_FIN_first D1StageSplit.s3 D1StageSplit.S3) 73 := by
  have hrun : runOk FF D1StageSplit.okB1 72 D1StageSplit.s1 D1StageSplit.S1 =
      some (D1StageSplit.s2, D1StageSplit.S2) := by
    exact D1StageSplit.k1
  apply cut_glueCall (n := 72) (sim1 NB T tk) accepted1 hrun (runOk_ok_end 71 hrun live2) live2
    D1StageSplit.stepA2 top3
  · intro x hq hb; exact ⟨hb.1.1.1, hq.1⟩
  · intro x hq _; exact horacle x.ν hq.2.2
  · intro x M t C hq hb hr he _ hr'
    refine ⟨⟨hr'.withOracle (fun _ h => nomatch h), hq⟩, ?_⟩
    exact book_fwd hr hr' he
      ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bridge1).trans inactive0) bridge3 hb

end Host.Ts.Sim.Compose.D1Split
