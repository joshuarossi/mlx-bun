import host.sim.compose.a4b.SetupEarlyGlueData
import host.sim.compose.PrefillLen
import host.route.SetupEntry
import host.sim.template.a4pre_setup_early_r0.K0

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupEarly
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Route

/-- Bookkeeping retained at the first actual chunkSize call. -/
def callBook (L : Nat) (x : SegInst FF) : Prop :=
  Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
  ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
    x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 0 ∧ AneFresh x.t

/-- The actual s4/S4 call, with the loaded prompt and the JS pointer law. -/
noncomputable def setupChunkCallCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      setupJ wideP [(9, .L)] PRE_setup_early_r0.s4 PRE_setup_early_r0.S4 (setupI L) with
    B := callBook L }

/-- The endpoint is the actual initial chunkSize call. -/
theorem chunkCall_source (NB T : Nat) (tk : Nat → Nat) (L : Nat) :
    isCallOf (setupChunkCallCut NB T tk L).s0 "chunkSize" none = true :=
  PRE_setup_early_r0.callA2

/-- The actual load cut has the JS law, via its identity map. The parent may retain
this fact in setupInitialBook; it is stated separately here to leave that interface unchanged. -/
noncomputable def setupInitialJsCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { setupInitialCut NB T tk L with B := fun x => setupInitialBook L x ∧ BigJs x.M }

theorem ldCut_setupInitialJs {NB T L : Nat} {tk : Nat → Nat} (hctx : L + T ≤ 262144) :
    CutConv (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (setupInitialJsCut NB T tk L) := by
  intro x hR hB
  have he := ldCut_setupEntryAt hctx hR hB
  refine ⟨{ x with ν := rowVal x.ν L }, rfl, rfl, he.1,
    ⟨he.2.1, (ldCut_setupContext hB).2, he.2.2⟩, ?_⟩
  change BigJs x.M
  rw [hB.1]
  exact BigJs.id

theorem setupInitialJs_forget (NB T : Nat) (tk : Nat → Nat) (L : Nat) :
    CutConv (setupInitialJsCut NB T tk L) (setupInitialCut NB T tk L) := by
  intro x hR hB
  exact ⟨x, rfl, rfl, hR, hB.1⟩

theorem wrapRest (P : LoadP) (r : List NumV) : wrapOk { P with rest := r } = wrapOk P := by
  funext x args
  unfold wrapOk
  split <;> rfl

theorem bridgeOpRest (P : LoadP) (r : List NumV) : bridgeOpOk { P with rest := r } = bridgeOpOk P := by
  funext name args
  unfold bridgeOpOk
  split <;> rfl

theorem callRest (P : LoadP) (r : List NumV) : okCallFX2 { P with rest := r } = okCallFX2 P := by
  funext x name args
  unfold okCallFX2 okCallFW okCallFA
  rw [wrapRest, G.okCallSX_rest, cloOk_rest, bridgeOpRest, okCallFS_rest]

theorem callRaiseRest (P : LoadP) (r : List NumV) : okCallFXD { P with rest := r } = okCallFXD P := by
  funext x name args
  unfold okCallFXD
  change (bif decide (P.NL = P.N0) then okCallFX2 { P.raise (mlxOf x).nnext with rest := r } x name args
    else okCallFX2 { P with rest := r } x name args) = _
  rw [callRest (P.raise (mlxOf x).nnext) r, callRest P r]

theorem backRest (P : LoadP) (r : List NumV) : okBackFXS { P with rest := r } = okBackFXS P := by
  funext x a
  unfold okBackFXS G.backOkG G.backOkV G.backOkR
  rfl

/-- The accepted row's first glue ends at the real chunkSize call after exactly 900 steps. -/
theorem setupInitial_chunkCall_core {NB T L : Nat} {tk : Nat → Nat}
    (hrow : InRow setup_early.r0 (setupI L)) :
    CutStep (setupInitialJsCut NB T tk L) (setupChunkCallCut NB T tk L) (897 + 1 + 1 + 1) := by
  rintro t C ⟨c, rfl, rfl, ⟨hr, hq⟩, hb, hj⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb
  let P : LoadP := { setupP with rest := machReads T tk }
  have hsim : Disp.StepSimXLB FF (Disp.FRJ (FullRXD P NB)) PRE_setup_early_r0.okB0
      (Disp.KpJ setupJ 4096) wideP [] (VBOkF loopVB) :=
    by
      have hjc : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
      have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hjc rfl rfl rfl rfl rfl [] setupW_ok
      have ha : PRE_setup_early_r0.okB0 = Disp.okJSJ setupJ (okBackFXS setupP) 4096 := by
        funext s S
        exact setup_acceptance s S
      simpa only [P, backRest, ha] using hs
  have h0 : RelB FF (Disp.FRJ (FullRXD P NB)) wideP [] c.M c.ν c.K
      PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 c.t c.C :=
    (hr.toJ hj).withOracle (good_of_row oracle0 hrow hq.2.2)
  obtain ⟨M1, t1, C1, run1, ext1, rel1⟩ := Disp.runOk_simXVB FF _ _ _ _ [] _ hsim.xv
    (fun _ _ _ => .inl rfl) c.ν c.K hk hq.1 897 c.M
    PRE_setup_early_r0.s0 PRE_setup_early_r0.S0 c.t c.C
    PRE_setup_early_r0.s1 PRE_setup_early_r0.S1 (.inl h0) accepted0 PRE_setup_early_r0.k0
  have ok1 := runOk_ok_end 896 PRE_setup_early_r0.k0 unhalted1
  obtain ⟨M2, t2, C2, step2, ext2, rel2⟩ := hsim M1 c.ν c.K
    PRE_setup_early_r0.s1 PRE_setup_early_r0.S1 t1 C1
    PRE_setup_early_r0.s2 PRE_setup_early_r0.S2 hk hq.1 rel1 unhalted1 (.inl rfl)
    ok1 PRE_setup_early_r0.stepA1
  have run2 := runC_trans run1 (runC_one (by rw [rel1.isHalt]; exact unhalted1) step2)
  have h2 := rel2.rel_noRet top2
  have heval : (.var 9 : SymE).eval c.ν = F64.ofNat ((π.map natV).length + ([] : List Val).length) := by
    simpa only [SymE.eval, MapOk, setupI, Inst.get, List.length_map, hlen,
      List.length_nil, Nat.add_zero] using hq.2.2.1
  have hkind : (Host.Ts.Sim.Template.objOf PRE_setup_early_r0.s2 2665).kind = .array ([] ++ ([] : List Val)) := by
    rw [PRE_setup_early_r0.kindA1, promptEmpty]
    rfl
  obtain ⟨step3, ext3, rel3⟩ := Disp.bridge_len h2.ofJ (fullRXD_laws P NB)
    PRE_setup_early_r0.ctlA1 lengthStack hframe PRE_setup_early_r0.objA1 hkind (.var 9) heval
  have patch := Option.some.inj PRE_setup_early_r0.patchB1
  let M3 := M2.setNum PRE_setup_early_r0.S2.tab.length
    (.lit (F64.ofNat ((π.map natV).length + ([] : List Val).length)))
  let t3 : St FF.S := { t2 with stack := PRE_setup_early_r0.s2.stack.tail.map M2.frame ++ [] }.ret
    (natV ((π.map natV).length + ([] : List Val).length))
  have rel3p : RelB FF (FullRXD P NB) wideP [] M3 c.ν c.K
      PRE_setup_early_r0.s3 PRE_setup_early_r0.S3 t3 C2 :=
    (congrArg (fun p : St FF.S × SSrv =>
      RelB FF (FullRXD P NB) wideP [] M3 c.ν c.K p.1 p.2 t3 C2) patch).mp rel3
  have rel3j := rel3p.toJ (h2.ffi.2.ext ext3)
  obtain ⟨M4, t4, C4, step4, ext4, rel4⟩ := hsim _ c.ν c.K
    PRE_setup_early_r0.s3 PRE_setup_early_r0.S3 _ C2
    PRE_setup_early_r0.s4 PRE_setup_early_r0.S4 hk hq.1 (.inl rel3j) unhalted3 (.inl rfl)
    accepted3 PRE_setup_early_r0.stepA2
  have run3 := runC_trans run2 (runC_one (by rw [h2.isHalt, PRE_setup_early_r0.ctlA1]; rfl) step3)
  have run4 := runC_trans run3 (runC_one (by rw [rel3j.isHalt]; exact unhalted3) step4)
  refine ⟨t4, C4, run4, ⟨M4, c.ν, c.K, t4, C4⟩, rfl, rfl, ?_, ?_⟩
  · exact ⟨(rel4.rel_noRet top4).withOracle (fun _ h => nomatch h), hq⟩
  · have inactive0 : (bridgeOf PRE_setup_early_r0.s0.ffi).active = false := by
      rw [PRE_setup_early_r0.start_eq]
      exact Host.Load.Run.Prompt.ldStT_bridge [] []
    have inactive4 : (bridgeOf PRE_setup_early_r0.s4.ffi).active = false := by
      rw [bridge4]; exact inactive0
    obtain ⟨_, _, hn0⟩ := hr.ffi
    obtain ⟨_, _, hn4⟩ := (rel4.rel_noRet top4).ffi.1
    have sameBridge : bridgeOf t4.ffi = bridgeOf c.t.ffi :=
      (hn4.toR inactive4).bridge.1.trans (bridge4.trans (hn0.toR inactive0).bridge.1.symm)
    refine ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, ?_⟩
    intro Cx Pc Kc weights kind NE IP G init
    change Host.Mlx.FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t4.ffi) = _
    rw [sameBridge]
    exact hfresh Cx Pc Kc weights kind NE IP G init

/-- Construct the actual early row from its supported natural interval. -/
theorem earlyRow {L : Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    InRow setup_early.r0 (setupI L) := by
  have hC : chunkC L = 2048 := by
    rw [chunkC_eq L (by omega)]
    (repeat' split) <;> omega
  exact ⟨by row_close [setup_early.r0, setupI, hC], vx [(L : Int)],
    by row_close [setup_early.r0], by row_close [setup_early.r0, setupI, hC]⟩

/-- The exact checked step sum, presented as 900. -/
theorem setupInitial_chunkCall {NB T L : Nat} {tk : Nat → Nat}
    (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (setupInitialJsCut NB T tk L) (setupChunkCallCut NB T tk L) 900 :=
  (setupInitial_chunkCall_core (earlyRow h1 h8)).cast rfl rfl rfl

/-- From the real checked load boundary to the first chunkSize call. -/
theorem ldCut_chunkCall {NB T L : Nat} {tk : Nat → Nat}
    (hctx : L + T ≤ 262144) (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (setupChunkCallCut NB T tk L) 900 :=
  (setupInitial_chunkCall h1 h8).convL (ldCut_setupInitialJs hctx)

end Host.Ts.Sim.Compose.SetupEarly
