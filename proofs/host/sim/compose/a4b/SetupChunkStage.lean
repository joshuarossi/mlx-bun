import host.sim.compose.a4b.SetupChunkStageData
import host.sim.compose.a4b.SetupEarlyGlue
import host.sim.compose.FixedGhost
import host.sim.compose.SetupKeep

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupChunk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Route Host.Ts.Sim.Compose.SetupEarly

/-- The two loaded cells needed by subsequent terminal bookkeeping. -/
def fixedCells (x : SegInst FF) : Prop := x.M.a 2586 = 2586 ∧ x.M.a 2589 = 2589

/-- The call boundary retains both terminal cell identities. -/
noncomputable def chunkCallFixedCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { setupChunkCallCut NB T tk L with B := fun x => callBook L x ∧ fixedCells x }

/-- The stage result is kept existentially until the checked compaction drops it. -/
def mergedQ (L : Nat) (x : SegInst FF) : Prop :=
  ∃ ν, x.ν = Conv.resVal ν PRE_setup_early_r0.ws0
    (Conv.resF SymE.var PRE_setup_early_r0.st0.S2.tab PRE_setup_early_r0.S4.tab.length ν) ∧
    VBOkF loopVB ν ∧ Disp.Kp setupJ x.K ∧ MapOk ν (setupI L) [(9, .L)]

/-- Facts of the incoming call used by the checked compaction. -/
def mergeBook (NB L : Nat) (x : SegInst FF) : Prop :=
  callBook L x ∧ fixedCells x ∧
  Conv.CallFacts PRE_setup_early_r0.s4 PRE_setup_early_r0.S4.tab.length ∧
  NB ≤ PRE_setup_early_r0.P0.NL ∧
  Conv.FullShiftQ PRE_setup_early_r0.P0 10 PRE_setup_early_r0.kappa0
    PRE_setup_early_r0.s6.ffi PRE_setup_early_r0.s5.ffi

/-- The actual merged boundary, retaining the caller context and exact result valuation. -/
noncomputable def chunkMergedCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  (Cut.mk PRE_setup_early_r0.s5 PRE_setup_early_r0.S5.tab
    (Conv.relB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP [] (mergedQ L))).with
    (mergeBook NB L)

/-- The local checked acceptance is the caller's acceptance restricted to local states. -/
theorem stageSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      PRE_setup_early_r0.st0.okL (Disp.KpJ setupJ 4096) wideP r (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hj rfl rfl rfl rfl rfl r setupW_ok
  apply hs.mono
  intro s S h
  change (Disp.okJSJ setupJ (okBackFXS setupP) 4096 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  simpa only [P, backRest] using h.1

/-- The acceptance's simulation with the target's growth from `y0`. -/
theorem wideGrowSim (NB T : Nat) (tk : Nat → Nat) (stk : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      (Disp.okJSJ setupJ (okBackFXS setupP) 4096) (Disp.KpJ setupJ 4096) wideP stk (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB setupJ 4096 hj rfl rfl rfl rfl rfl stk setupW_ok y0
  have he : Disp.FRJ (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) =
      FRQ (Disp.FRJ (FullRXD P NB)) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) := by
    funext M m x y
    exact propext ⟨fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩, fun h => ⟨⟨h.1.1, h.2⟩, h.1.2⟩⟩
  rw [he] at hs
  simpa only [P, backRest] using hs

theorem stageGrowSim (NB T : Nat) (tk : Nat → Nat) (r : List Frame) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      PRE_setup_early_r0.st0.okL (Disp.KpJ setupJ 4096) wideP r (VBOkF loopVB) := by
  apply (wideGrowSim NB T tk r y0).mono
  intro s S h
  change (Disp.okJSJ setupJ (okBackFXS setupP) 4096 s S && Disp.localB s) = true at h
  simp only [Bool.and_eq_true] at h
  exact h.1

kernel_rfl keepNN : PRE_setup_early_r0.kd0.nn0 = PRE_setup_early_r0.kd0.nn1
kernel_rfl keepNK : PTrie.keys PRE_setup_early_r0.kd0.node = []
kernel_rfl cntMerged : countersOkB PRE_setup_early_r0.s4 PRE_setup_early_r0.s5 = true

/-- The actual site template runs for 100 steps and its return step, keeping caller entries. -/
theorem chunkCall_merged_keeps {NB T L : Nat} {tk : Nat → Nat}
    (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStepKeeps (chunkCallFixedCut NB T tk L) (chunkMergedCut NB T tk L) 101 := by
  rintro c ⟨hr, hq⟩ ⟨hb, hids⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb
  have h0 := hr.withOracle (good_of_row stageOracle (earlyRow h1 h8) hq.2.2)
  have hS : PRE_setup_early_r0.st0.S0 = ⟨PRE_setup_early_r0.S4.tab, PRE_setup_early_r0.st0.S0.oracle⟩ := by
    rw [← PRE_setup_early_r0.tab0_0]
  change RelB FF _ wideP [] c.M c.ν c.K PRE_setup_early_r0.s4
    ⟨PRE_setup_early_r0.S4.tab, PRE_setup_early_r0.st0.S0.oracle⟩ c.t c.C at h0
  rw [← hS] at h0
  let tpl : Stage.StageTpl FF PRE_setup_early_r0.st0.okL := PRE_setup_early_r0.st0.tpl
  obtain ⟨M', t', C', run, ext, rel⟩ := Conv.site_merge tpl
    PRE_setup_early_r0.iso0 rfl (stageSim NB T tk) PRE_setup_early_r0.st0.loc hk hq.1
    PRE_setup_early_r0.stFoot0 PRE_setup_early_r0.wrNodup0 PRE_setup_early_r0.wrBound0
    PRE_setup_early_r0.trace0 PRE_setup_early_r0.S4.tab.length h0
  have hm := PRE_setup_early_r0.merged0 rel
  have hext : Ext c.M M' PRE_setup_early_r0.S4.tab.length := by
    change Ext c.M M' PRE_setup_early_r0.st0.S0.tab.length at ext
    rw [PRE_setup_early_r0.tab0_0] at ext
    exact ext
  have hlen2 : PRE_setup_early_r0.S4.tab.length ≤ PRE_setup_early_r0.st0.S2.tab.length := by
    have h := PRE_setup_early_r0.st0.tpl.len2
    change PRE_setup_early_r0.st0.S0.tab.length ≤ PRE_setup_early_r0.st0.S2.tab.length at h
    rw [PRE_setup_early_r0.tab0_0] at h
    exact h
  have hm' := hm.resMerge (tab := PRE_setup_early_r0.S4.tab) hr.srv.num hext (runC_le _ _ _ _ _ run) hlen2
    (show PRE_setup_early_r0.ws0.length = _ from PRE_setup_early_r0.mergeLen0.symm)
    (by decide : PRE_setup_early_r0.ws0.Nodup)
    (noVar_of_all (by have h := PRE_setup_early_r0.fresh0; simp only [Bool.and_eq_true] at h; exact h.1))
  let ν' := Conv.resVal c.ν PRE_setup_early_r0.ws0
    (Conv.resF SymE.var PRE_setup_early_r0.st0.S2.tab PRE_setup_early_r0.S4.tab.length c.ν)
  have hg0 : Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi) := by
    obtain ⟨_, t1, C1, run1, -, h2⟩ := Conv.site_merge tpl PRE_setup_early_r0.iso0 rfl
      (fun stk => stageGrowSim NB T tk stk (mlxOf c.t.ffi)) PRE_setup_early_r0.st0.loc hk hq.1
      PRE_setup_early_r0.stFoot0 PRE_setup_early_r0.wrNodup0 PRE_setup_early_r0.wrBound0 PRE_setup_early_r0.trace0 0 (relB_withQ h0 (Host.Mlx.Ffi.NGrow.refl _))
    rw [run] at run1
    cases run1
    exact h2.ffi.2
  have ntrack : NTrack c ⟨M', ν', c.K, t', C'⟩ :=
    ⟨runC_le _ _ _ _ _ run, hext.node, hg0, tokens_of_grow hr hm' hg0 (countersOkB_tokens cntMerged), congrFun hext.a 12504⟩
  refine ⟨⟨M', ν', c.K, t', C'⟩, run, ?_, ?_, ?_, ?_, rfl, fun _ _ h => h.step (P := { setupP with rest := machReads T tk }) rfl hr hm' hext.big hext.node cntMerged, ntrack⟩
  · change RelB FF _ wideP [] M' ν' c.K PRE_setup_early_r0.s5 ⟨PRE_setup_early_r0.S5.tab, []⟩ t' C' ∧ _
    rw [PRE_setup_early_r0.mergeTab0]
    exact ⟨hm', c.ν, rfl, hq⟩
  · have top := hr.ffi.1.top (by rfl)
    have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf PRE_setup_early_r0.s4.ffi).nnext).NL ≤
        PRE_setup_early_r0.P0.NL := by
      change (mlxOf PRE_setup_early_r0.s4.ffi).nnext ≤ 15235
      rw [← PRE_setup_early_r0.fcnn0]
    refine ⟨?_, ?_, ⟨hr.presentBound, hr.heapSupp⟩, Nat.le_trans top.1.load.mlx.nbl hNL,
      PRE_setup_early_r0.cshiftR0 top.1 hNL⟩
    · have inactive4 : (bridgeOf PRE_setup_early_r0.s4.ffi).active = false := by
        rw [SetupEarly.bridge4, PRE_setup_early_r0.start_eq]
        exact Host.Load.Run.Prompt.ldStT_bridge [] []
      have inactive5 : (bridgeOf PRE_setup_early_r0.s5.ffi).active = false := by rw [bridge5]; exact inactive4
      obtain ⟨_, _, hn0⟩ := hr.ffi.1
      obtain ⟨_, _, hn5⟩ := hm'.ffi.1
      have sameBridge : bridgeOf t'.ffi = bridgeOf c.t.ffi :=
        (hn5.toR inactive5).bridge.1.trans (bridge5.trans (hn0.toR inactive4).bridge.1.symm)
      refine ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, ?_⟩
      intro Cx Pc Kc weights kind NE IP G init
      change Host.Mlx.FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t'.ffi) = _
      rw [sameBridge]
      exact hfresh Cx Pc Kc weights kind NE IP G init

    · change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
      rw [hext.a]
      exact hids
  · intro j hj
    apply Conv.resVal_off
    change j ∉ [1000]
    simp only [List.mem_singleton]
    omega
  · exact congrFun hext.a 2590

theorem chunkCall_merged {NB T L : Nat} {tk : Nat → Nat}
    (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (chunkCallFixedCut NB T tk L) (chunkMergedCut NB T tk L) 101 :=
  (chunkCall_merged_keeps h1 h8).step

/-- A local strengthening of the initial cut, derived from the real load map. -/
noncomputable def initialFixedCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { setupInitialJsCut NB T tk L with
    B := fun x => setupInitialBook L x ∧ BigJs x.M ∧ fixedCells x }

theorem ldCut_initialFixed {NB T L : Nat} {tk : Nat → Nat} (hctx : L + T ≤ 262144) :
    CutConv (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (initialFixedCut NB T tk L) := by
  intro x hR hB
  have he := ldCut_setupEntryAt hctx hR hB
  refine ⟨{ x with ν := rowVal x.ν L }, rfl, rfl, he.1,
    ⟨he.2.1, (ldCut_setupContext hB).2, he.2.2⟩, ?_, ?_⟩
  · change BigJs x.M
    rw [hB.1]
    exact BigJs.id
  · change x.M.a 2586 = 2586 ∧ x.M.a 2589 = 2589
    rw [hB.1]
    exact ⟨rfl, rfl⟩

kernel_rfl cntCall : countersOkB PRE_setup_early_r0.s0 PRE_setup_early_r0.s4 = true

theorem initial_chunkCall_fixed_oracle_keeps {NB T L : Nat} {tk : Nat → Nat}
    (horacle : ∀ ν, MapOk ν (setupI L) [(9, .L)] → Good ν PRE_setup_early_r0.S0.oracle) :
    CutStepKeeps (initialFixedCut NB T tk L) (chunkCallFixedCut NB T tk L) (897 + 1 + 1 + 1) := by
  rintro c ⟨hr, hq⟩ ⟨hb, hj, hids⟩
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
    (hr.toJ hj).withOracle (horacle c.ν hq.2.2)
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
  have hsimQ : ∀ y0 : Host.Mlx.Ffi.St, Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD P NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) PRE_setup_early_r0.okB0 (Disp.KpJ setupJ 4096) wideP [] (VBOkF loopVB) := by
    intro y0
    have ha : PRE_setup_early_r0.okB0 = Disp.okJSJ setupJ (okBackFXS setupP) 4096 := by
      funext s S
      exact setup_acceptance s S
    rw [ha]
    exact wideGrowSim NB T tk [] y0
  have ng12 : Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t2.ffi) :=
    glueCall_ngrow hsimQ accepted0 PRE_setup_early_r0.k0 ok1 unhalted1 PRE_setup_early_r0.stepA1 hq.1 hk h0 run2
  have ng34 : Host.Mlx.Ffi.NGrow (mlxOf t3.ffi) (mlxOf t4.ffi) :=
    glueCall_ngrow hsimQ (n := 0) accepted3 rfl accepted3 unhalted3 PRE_setup_early_r0.stepA2 hq.1 hk rel3j
      (runC_one (by rw [rel3j.isHalt]; exact unhalted3) step4)
  have ng : Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t4.ffi) := ng12.trans ng34
  have ntrack : NTrack c ⟨M4, c.ν, c.K, t4, C4⟩ :=
    ⟨runC_le _ _ _ _ _ run4, ext4.node.trans (ext3.node.trans (ext2.node.trans ext1.node)), ng,
      tokens_of_grow h0 (rel4.rel_noRet top4) ng (countersOkB_tokens cntCall),
      (congrFun ext4.a 12504).trans ((congrFun ext3.a 12504).trans ((congrFun ext2.a 12504).trans (congrFun ext1.a 12504)))⟩
  refine ⟨⟨M4, c.ν, c.K, t4, C4⟩, run4, ?_, ?_, ?_, ?_, rfl, fun _ _ h => h.step (P := { setupP with rest := machReads T tk }) rfl h0 (rel4.rel_noRet top4)
    (ext4.big.trans (ext3.big.trans (ext2.big.trans ext1.big)))
    (ext4.node.trans (ext3.node.trans (ext2.node.trans ext1.node))) cntCall, ntrack⟩
  · exact ⟨(rel4.rel_noRet top4).withOracle (fun _ h => nomatch h), hq⟩
  · constructor
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
  
  
    · have ht1 : Track [2586, 2589] c ⟨M1, c.ν, c.K, t1, C1⟩ := Track.of_ext ext1
      have ht2 : Track [2586, 2589] c ⟨M2, c.ν, c.K, t2, C2⟩ := ht1.ext ext2
      have ht3 : Track [2586, 2589] c ⟨M3, c.ν, c.K, t3, C2⟩ := ht2.ext ext3
      have ht4 : Track [2586, 2589] c ⟨M4, c.ν, c.K, t4, C4⟩ := ht3.ext ext4
      exact ⟨(ht4 2586 (by decide)).trans hids.1, (ht4 2589 (by decide)).trans hids.2⟩
  · exact fun _ _ => rfl
  · change M4.a 2590 = c.M.a 2590
    rw [ext4.a, ext3.a, ext2.a, ext1.a]

theorem initial_chunkCall_fixed_oracle {NB T L : Nat} {tk : Nat → Nat}
    (horacle : ∀ ν, MapOk ν (setupI L) [(9, .L)] → Good ν PRE_setup_early_r0.S0.oracle) :
    CutStep (initialFixedCut NB T tk L) (chunkCallFixedCut NB T tk L) (897 + 1 + 1 + 1) :=
  (initial_chunkCall_fixed_oracle_keeps horacle).step

theorem initial_chunkCall_fixed_core {NB T L : Nat} {tk : Nat → Nat}
    (hrow : InRow setup_early.r0 (setupI L)) :
    CutStep (initialFixedCut NB T tk L) (chunkCallFixedCut NB T tk L) (897 + 1 + 1 + 1) :=
  initial_chunkCall_fixed_oracle (fun _ hm => good_of_row oracle0 hrow hm)

theorem ldCut_chunkCall_fixed {NB T L : Nat} {tk : Nat → Nat}
    (hctx : L + T ≤ 262144) (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (chunkCallFixedCut NB T tk L) 900 :=
  ((initial_chunkCall_fixed_core (earlyRow h1 h8)).cast rfl rfl rfl).convL (ldCut_initialFixed hctx)

/-- Inactive wide entries have the same heap relation as ordinary entries. -/
theorem inactiveMemo {FR : Map → Nat → FF.S → FF.S → Prop} {W W' : Nat → Option WFrame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St FF.S} {S : SSrv} {C : CSrv}
    (h : RelB FF FR W [] M ν K s S t C)
    (hw : ∀ a, K.fr a ≠ none → W' a = W a) : RelB FF FR W' [] M ν K s S t C :=
by
  refine { h with heap := ?_ }
  intro a o ho
  have hh := h.heap a o ho
  cases hf : K.fr a with
  | none => exact (SlotW.of_fr_none hf).mpr ((SlotW.of_fr_none hf).mp hh)
  | some p =>
    have he := hw a (by rw [hf]; exact Option.some_ne_none _)
    unfold SlotW at hh ⊢
    rw [he]
    exact hh

theorem wideInactive {K : Ctx} (hmemo : K.fr 4910 = none) :
    ∀ a, K.fr a ≠ none → wideP a = noFrames a := by
  intro a ha
  by_cases h : a = 4910
  · subst h; exact (ha hmemo).elim
  · change (bif Nat.beq a 4910 then some (WFrame.memo []) else none) = none
    rw [Template.beq_false h]
    rfl

/-- Exact bookkeeping after compaction; its counter offset is thirteen. -/
def chunkBook (L : Nat) (x : SegInst FF) : Prop :=
  Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
  ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
    x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 13 ∧ AneFresh x.t

/-- The actual canonical s6/S6 cut, with its JS law and both fixed terminal cells. -/
noncomputable def setupChunkCut (NB T : Nat) (tk : Nat → Nat) (L : Nat) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      setupJ wideP [(9, .L)] PRE_setup_early_r0.s6 PRE_setup_early_r0.S6 (setupI L) with
    B := fun x => chunkBook L x ∧ fixedCells x }

/-- The checked canonical state shift, applying the original footprint and caller closedness. -/
theorem chunkShift {K : Ctx} (hk : Disp.Kp setupJ K) {π : List Nat}
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hcall : Conv.CallFacts PRE_setup_early_r0.s4 PRE_setup_early_r0.S4.tab.length)
    (hnative : Conv.FullShiftQ PRE_setup_early_r0.P0 10 PRE_setup_early_r0.kappa0
      PRE_setup_early_r0.s6.ffi PRE_setup_early_r0.s5.ffi) :
    ShiftD FF (fun σ x y => x = PRE_setup_early_r0.s6.ffi ∧
      Conv.FullShiftQX PRE_setup_early_r0.P0 PRE_setup_early_r0.S6.tab.length σ x y)
      PRE_setup_early_r0.kappa0 PRE_setup_early_r0.cthetaZ0 (kpOf K noFrames) noFrames K
      PRE_setup_early_r0.s6 ⟨PRE_setup_early_r0.S6.tab, []⟩
      PRE_setup_early_r0.s5 ⟨PRE_setup_early_r0.S5.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := (PRE_setup_early_r0.s6 : St FF.S)) PRE_setup_early_r0.zroots0
  have hs := Conv.compact_shift (F := FF) (W := noFrames) (K1 := K)
    PRE_setup_early_r0.zkap0 hcall callClean PRE_setup_early_r0.cfix0
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp PRE_setup_early_r0.zpl0 p hp))
    (nodupT_sound PRE_setup_early_r0.zplnd0).2 (Nat.le_of_ble_eq_true PRE_setup_early_r0.zn10)
    (Nat.le_of_ble_eq_true PRE_setup_early_r0.zfirst0) PRE_setup_early_r0.zscn0 PRE_setup_early_r0.zsmn0
    (Nat.le_of_ble_eq_true PRE_setup_early_r0.zgrow0) PRE_setup_early_r0.mergeTab0
    (noVar_of_all PRE_setup_early_r0.zfresh0) (nodupT_sound PRE_setup_early_r0.zcnd0).2
    (by rfl : PRE_setup_early_r0.cws0.length = PRE_setup_early_r0.nr0.length)
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_early_r0.znrHi0 r hr))
    hk.2.2 (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_early_r0.zfrlt0 a ha))
    (Xs := [2665]) (by intro a; simp [noFrames]) (by intro a w hw; cases hw)
    (by
      intro a pre pre' hka _
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      change a ∈ [2665] at ha
      simp only [List.mem_singleton] at ha
      subst ha
      rw [hframe] at hka
      cases hka
      refine ⟨_, arrOf PRE_setup_early_r0.s5 2665, PRE_setup_early_r0.zg0_2665, ?_, ?_⟩
      · rw [PRE_setup_early_r0.zk0_2665, sourcePromptEmpty]
      · simpa only [sourcePromptEmpty, List.length_nil, List.drop_zero, List.nil_append] using
          PRE_setup_early_r0.zm0_2665)
    (by intro a w hw; cases hw) (by intro a w hw; cases hw)
    (Conv.heap_off_setAll PRE_setup_early_r0.cheap0
      (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_early_r0.zclbd0 a ha)))
    (hoff_of PRE_setup_early_r0.mheap0 PRE_setup_early_r0.stFoot0 PRE_setup_early_r0.iso0 PRE_setup_early_r0.zwr0)
    PRE_setup_early_r0.ckeepP0 PRE_setup_early_r0.csupp0 PRE_setup_early_r0.cbound0 PRE_setup_early_r0.zimg0
    PRE_setup_early_r0.zctl0 PRE_setup_early_r0.zstack0 PRE_setup_early_r0.zjobs0 PRE_setup_early_r0.zstores0
    (by rw [PRE_setup_early_r0.znC0]; exact hroots.1)
    (by rw [PRE_setup_early_r0.znC0]; exact hroots.2.1)
    (by rw [PRE_setup_early_r0.znC0]; exact hroots.2.2.1)
    (by rw [PRE_setup_early_r0.znC0]; exact hroots.2.2.2)
    (Conv.bigFixed_of_mshift hnative.load.mlx hk.1 hk.2.1)
  have hs' : ShiftD FF (fun _ _ _ => True) PRE_setup_early_r0.kappa0 PRE_setup_early_r0.ctheta0
      (kpOf K noFrames) noFrames K PRE_setup_early_r0.s6 ⟨PRE_setup_early_r0.S6.tab, []⟩
      PRE_setup_early_r0.s5 ⟨PRE_setup_early_r0.S5.tab, []⟩ := by
    rw [PRE_setup_early_r0.ctab0]
    exact hs
  have hθ := hs'.retheta (θ' := PRE_setup_early_r0.cthetaZ0) (by
    rw [PRE_setup_early_r0.ctab0]
    exact Conv.compactθZ_tab
      (noVar_of_all (by have h := PRE_setup_early_r0.fresh0; simp only [Bool.and_eq_true] at h; exact h.1))
      (disj_of_all PRE_setup_early_r0.cwsDisj0))
  exact { hθ with ffi := ⟨rfl, by
    rw [PRE_setup_early_r0.ctab0]
    change Conv.FullShiftQX PRE_setup_early_r0.P0 10 PRE_setup_early_r0.kappa0 _ _
    exact hnative.toX PRE_setup_early_r0.zbin0⟩ }

/-- The checked compaction changes no target state and consumes zero target steps. -/
theorem merged_compact_keeps {NB T L : Nat} {tk : Nat → Nat} :
    CutConvKeeps (chunkMergedCut NB T tk L) (setupChunkCut NB T tk L) := by
  rintro x ⟨hr, ν, hν, hvb, hkp, hmap⟩ ⟨hb, hids, hcall, hNB, hnative⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb
  have hr0 := inactiveMemo hr.ofJ (fun a ha => (wideInactive hmemo a ha).symm)
  have hs := chunkShift hkp hframe hcall hnative
  have hnext6 : (mlxOf PRE_setup_early_r0.s6.ffi).next = 18155 :=
    congrArg Prod.fst PRE_setup_early_r0.ccounters0
  have hoff : x.t.next = 2673349 := by
    have h := hr.offset
    change x.t.next = PRE_setup_early_r0.s5.next + x.K.D at h
    rw [PRE_setup_early_r0.zsmn0, hd, Nat.add_zero] at h
    exact h
  have hD : x.t.next - PRE_setup_early_r0.s6.next = 13 := by rw [hoff, PRE_setup_early_r0.cnext0]
  have hfree := Conv.jclean_noBigSt (lo := (mlxOf PRE_setup_early_r0.s6.ffi).next) (E := setupP.E)
    (PRE_setup_early_r0.cjcl0 callClean)
    (by rw [hnext6]) (by decide : setupP.E ≤ RData.bigHi)
    PRE_setup_early_r0.zroots20
  have hband : ∀ i : Int, ((mlxOf PRE_setup_early_r0.s6.ffi).next : Int) ≤ i ∧ i < setupP.E →
      ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
    intro i hi
    rw [hnext6] at hi
    have hlo : x.K.lo = 18151 := hk.1.1
    have hhi : x.K.hi = 131072 := hk.1.2.1
    rw [hlo, hhi]
    change 18155 ≤ i ∧ i < 131072 at hi
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have hroomN : NRoom setupP (Host.Load.Layers.toLoad PRE_setup_early_r0.s6.ffi)
      (Host.Load.Layers.toLoad x.t.ffi) := by
    obtain ⟨P', hP, hf⟩ := hr.ffi.1
    obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
    constructor
    · have h := hf.load.mlx.hroom.2
      rw [hE] at h
      change (mlxOf x.t.ffi).next + (setupP.E - (mlxOf PRE_setup_early_r0.s5.ffi).next) < 2 ^ 46 at h
      rw [sameNativeNext] at h
      exact h
    · have h := hf.load.mlx.nroom.2.2
      rw [hNE] at h
      change (mlxOf x.t.ffi).nnext + (setupP.NE - (mlxOf PRE_setup_early_r0.s5.ffi).nnext) < 2 ^ 62 at h
      rw [sameNativeNnext] at h
      exact h
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := PRE_setup_early_r0.s6) (s1 := PRE_setup_early_r0.s5)
    (S0 := ⟨PRE_setup_early_r0.S6.tab, []⟩) (S1 := ⟨PRE_setup_early_r0.S5.tab, []⟩)
    PRE_setup_early_r0.raised0 hNB hr0 hs PRE_setup_early_r0.cbigs0 hfree hband
    (fun _ h => nomatch h) (by rw [hD]; decide) hroomN
  let N := (x.M.after PRE_setup_early_r0.kappa0).rebig (mlxOf PRE_setup_early_r0.s6.ffi).next
    setupP.E (mlxOf x.t.ffi).next
  let K' : Ctx := ⟨Shift.framedNext x.M x.K PRE_setup_early_r0.s5,
    PRE_setup_early_r0.s6.trace, x.t.trace, x.t.next - PRE_setup_early_r0.s6.next, x.K.lo, x.K.hi⟩
  let ν' := Shift.valuation PRE_setup_early_r0.cthetaZ0 x.ν
  have hcD : RelB FF (FullRD { setupP with rest := machReads T tk } NB) noFrames [] N ν' K'
      PRE_setup_early_r0.s6 ⟨PRE_setup_early_r0.S6.tab, []⟩ x.t x.C := by
    obtain ⟨P', hP, hf⟩ := hc.ffi
    exact hc.mapFR' ⟨P', hP, hf.toR PRE_setup_early_r0.zbin0⟩
  have hcJ := hcD.afterJsFullDBlocks (M := x.M) (σ := PRE_setup_early_r0.kappa0) hr.ffi.2 rfl
    (fun _ hi => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) hi)
    (by change x.K.lo ≤ 2 ^ 56; rw [hk.1.1]; decide)
    canonicalJsHeap canonicalJsRoots canonicalJsNative
  have hctx : Disp.KpJ setupJ 4096 K' := by
    exact ⟨Kp_restart hkp _ _ _, by change x.t.next - PRE_setup_early_r0.s6.next ≤ 4096; rw [hD]; decide⟩
  have hmemo' : K'.fr 4910 = none := by
    change Shift.framedNext x.M x.K PRE_setup_early_r0.s5 4910 = none
    exact (framedNext_none_iff (M := x.M) (s1 := (PRE_setup_early_r0.s5 : St FF.S)) 4910).mpr hmemo
  have hcW := inactiveMemo hcJ (wideInactive hmemo')
  have hcX : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP [] N.withJs ν' K'
      PRE_setup_early_r0.s6 ⟨PRE_setup_early_r0.S6.tab, []⟩ x.t x.C :=
    RelF.mapFR' hcW ⟨hcW.ffi.1.toXD, hcW.ffi.2⟩
  have hval : VBOkF loopVB ν' ∧ MapOk ν' (setupI L) [(9, .L)] := by
    have hout : ∀ v, PRE_setup_early_r0.ws0.contains v = false → x.ν v = ν v := by
      intro v hv
      rw [hν]
      exact Conv.resVal_off (fun hm => by
        have hc := List.contains_iff_mem.mpr hm
        rw [hv] at hc
        cases hc)
    constructor
    · apply Conv.vbOk_post (ws := PRE_setup_early_r0.cws0) (rs := PRE_setup_early_r0.crs0)
        (zs := PRE_setup_early_r0.ws0)
      · intro v hv; rw [hout v hv]; exact hvb v
      · intro j c r hj; cases hj
      · exact Nat.le_refl 0
    · change ν' 9 = F64.ofNat L ∧ True
      refine ⟨?_, trivial⟩
      change Shift.valuation (Conv.compactθZ [] PRE_setup_early_r0.crs0 [1000]) x.ν 9 = _
      rw [Conv.valuation_compactθZ_out (by rfl) (by decide), hout 9 (by decide)]
      exact hmap.1
  have hfrK : K'.fr 2665 = some ([], π.map natV) := by
    obtain ⟨o, ho, hkind⟩ := PRE_setup_early_r0.arr0_2665
    have hknd : o.kind = .array ([] ++ []) := by simpa only [sourcePromptEmpty, PRE_setup_early_r0.arrEl0_2665] using hkind
    have h := framedNext_of (M := x.M) hframe ho hknd
    simpa only [Map.vals, List.map_nil, List.append_nil] using h
  refine ⟨⟨N.withJs, ν', K', x.t, x.C⟩, rfl, rfl, ⟨hcX, hval.1, hctx.1, hval.2⟩, ⟨?_, ?_⟩, ?_, ?_,
    hfrK.trans hframe.symm, fun _ _ h => ⟨sameNativeNext ▸ h.1, sameNativeNnext ▸ h.2⟩,
    funext fun k => congrArg x.M.node (compact_node_id keepNN keepNK k), ?_⟩
  · exact ⟨hctx, hmemo', π, hlen, hvocab, hfrK, hD, hfresh⟩
  · have hκ : ∀ a ∈ [2586, 2589], PRE_setup_early_r0.kappa0.a a = a := by
      intro a ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl
      · exact Conv.Map.compact_lt (by decide : 2586 < 2673336)
      · exact Conv.Map.compact_lt (by decide : 2589 < 2673336)
    have ht := Track.compactPair (sm := PRE_setup_early_r0.s5) (sc := PRE_setup_early_r0.s6)
      (θk := PRE_setup_early_r0.cthetaZ0) (P := setupP) (Track.refl [2586, 2589] x) hκ
    exact ⟨(ht 2586 (by decide)).trans hids.1, (ht 2589 (by decide)).trans hids.2⟩
  · intro j hj
    change Shift.valuation (Conv.compactθZ [] PRE_setup_early_r0.crs0 [1000]) x.ν j = _
    apply Conv.valuation_compactθZ_out (by rfl)
    simp only [List.contains_cons, List.contains_nil, Bool.or_false]
    exact Template.beq_false (by omega)
  · change x.M.a (PRE_setup_early_r0.kappa0.a 2590) = x.M.a 2590
    have hκ : PRE_setup_early_r0.kappa0.a 2590 = 2590 :=
      Conv.Map.compact_lt (by decide : 2590 < 2673336)
    rw [hκ]
  · change x.M.a (PRE_setup_early_r0.kappa0.a 12504) = x.M.a 12504
    have hκ : PRE_setup_early_r0.kappa0.a 12504 = 12504 :=
      Conv.Map.compact_lt (by decide : 12504 < 2673336)
    rw [hκ]

theorem merged_compact {NB T L : Nat} {tk : Nat → Nat} :
    CutConv (chunkMergedCut NB T tk L) (setupChunkCut NB T tk L) :=
  merged_compact_keeps.conv

/-- The actual 101-step chunk call, merged and compacted to s6/S6. -/
theorem chunkCall_chunk {NB T L : Nat} {tk : Nat → Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (chunkCallFixedCut NB T tk L) (setupChunkCut NB T tk L) 101 :=
  (chunkCall_merged h1 h8).convR merged_compact

/-- The actual supported setup interval selects chunk size 2048. -/
theorem chunkC2048 {L : Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8) : chunkC L = 2048 := by
  rw [chunkC_eq L (by omega)]
  (repeat' split) <;> omega

/-- The endpoint exposes both the prompt-length valuation and the usable JS pointer law. -/
theorem setupChunk_values {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (h : (setupChunkCut NB T tk L).R x PRE_setup_early_r0.s6 ⟨PRE_setup_early_r0.S6.tab, []⟩) :
    x.ν 9 = F64.ofNat L ∧ BigJs x.M := ⟨h.2.2.2.1, h.1.ffi.2⟩

/-- Actual initialization through s6 needs only the context bound and the supported natural interval. -/
theorem ldCut_chunk {NB T L : Nat} {tk : Nat → Nat}
    (hctx : L + T ≤ 262144) (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (setupChunkCut NB T tk L) 1001 :=
  ((ldCut_chunkCall_fixed hctx h1 h8).trans (chunkCall_chunk h1 h8)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.SetupChunk
