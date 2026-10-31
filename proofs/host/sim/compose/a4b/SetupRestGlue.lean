import host.sim.compose.a4b.SetupRestGlueData
import host.sim.compose.a4b.SetupRestCuts

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupRest
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Route Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The simulation uses the original JS acceptance and its exact offset margin. -/
theorem restSim (NB T : Nat) (tk : Nat → Nat) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      PRE_setup_early_r0.okB2 (Disp.KpJ setupJ 4096) wideP [] (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hj rfl rfl rfl rfl rfl [] setupW_ok
  have ha : PRE_setup_early_r0.okB2 = Disp.okJSJ setupJ (okBackFXS setupP) 4096 := by
    funext s S
    rfl
  simpa only [P, backRest, ha] using hs

/-- Transport only proved bookkeeping, on the actual extension chosen by the run. -/
theorem glueFwd {NB T L : Nat} {tk : Nat → Nat} {sa sb : St FF.S} {Sa Sb : SSrv}
    {x : SegInst FF} {M : Map} {t : St FF.S} {C : CSrv}
    (h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      x.M x.ν x.K sa Sa x.t x.C)
    (h1 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      M x.ν x.K sb Sb t C)
    (he : Ext x.M M Sa.tab.length)
    (hi : (bridgeOf sa.ffi).active = false)
    (hb : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hbook : chunkBook L x ∧ fixedCells x) :
    chunkBook L ⟨M, x.ν, x.K, t, C⟩ ∧ fixedCells ⟨M, x.ν, x.K, t, C⟩ := by
  obtain ⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩, hids⟩ := hbook
  have hi' : (bridgeOf sb.ffi).active = false := by rw [hb]; exact hi
  obtain ⟨_, _, hn0⟩ := h0.ffi.1
  obtain ⟨_, _, hn1⟩ := h1.ffi.1
  have sameBridge : bridgeOf t.ffi = bridgeOf x.t.ffi :=
    (hn1.toR hi').bridge.1.trans (hb.trans (hn0.toR hi).bridge.1.symm)
  constructor
  · refine ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, ?_⟩
    intro Cx Pc Kc weights kind NE IP G init
    change Host.Mlx.FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t.ffi) = _
    rw [sameBridge]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  · have ht : Track [2586, 2589] x ⟨M, x.ν, x.K, t, C⟩ := Track.of_ext he
    exact ⟨(ht 2586 (by decide)).trans hids.1, (ht 2589 (by decide)).trans hids.2⟩

/-- An existing checked glue segment and its actual next call step. -/
theorem glueCall {NB T L : Nat} {tk : Nat → Nat} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    {n : Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8)
    (hok : PRE_setup_early_r0.okB2 sa Sa = true)
    (hrun : runOk FF PRE_setup_early_r0.okB2 n sa Sa = some (sb, Sb))
    (hokb : PRE_setup_early_r0.okB2 sb Sb = true) (hh : isHalt sb.ctl = false)
    (hstep : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hor : goodLin setup_early.r0.ps (varsOf setup_early.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hb : bridgeOf sc.ffi = bridgeOf sa.ffi) :
    CutStep (restCut NB T tk L sa Sa) (restCut NB T tk L sc Sc) (n + 1) := by
  apply cut_glueCall (restSim NB T tk) hok hrun hokb hh hstep htop
  · intro c hq hb; exact ⟨hb.1.1, hq.1⟩
  · intro c hq _; exact good_of_row hor (earlyRow h1 h8) hq.2.2
  · intro c M t C hq hbook hr he _ hr'
    exact ⟨⟨hr'.withOracle (fun _ h => nomatch h), hq⟩, glueFwd hr hr' he hi hb hbook⟩

/-- A real framed prompt-length read, with the source's unchanged lenPatch. -/
theorem lengthStep {NB T L : Nat} {tk : Nat → Nat} {sa sb : St FF.S} {Sa Sb : SSrv} {o : Obj}
    (h1 : 1 ≤ L) (h8 : L ≤ 8)
    (hc : sa.ctl = .ret (.obj 2665))
    (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? 2665 = some o)
    (hk : o.kind = .array ([] ++ ([] : List Val)))
    (hp : Bridge.lenPatch sa Sa (.var 9) = (sb, Sb))
    (hor : goodLin setup_early.r0.ps (varsOf setup_early.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hb : bridgeOf sb.ffi = bridgeOf sa.ffi) :
    CutStep (restCut NB T tk L sa Sa) (restCut NB T tk L sb Sb) 1 := by
  rintro t C ⟨c, rfl, rfl, ⟨hr, hq⟩, hbook⟩
  obtain ⟨hctx, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hbook.1
  have h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      c.M c.ν c.K sa Sa c.t c.C := hr.withOracle (good_of_row hor (earlyRow h1 h8) hq.2.2)
  have heval : (.var 9 : SymE).eval c.ν = F64.ofNat ((π.map natV).length + ([] : List Val).length) := by
    simpa only [SymE.eval, MapOk, setupI, Inst.get, List.length_map, hlen,
      List.length_nil, Nat.add_zero] using hq.2.2.1
  obtain ⟨step1, ext1, rel1⟩ := Disp.bridge_len h0.ofJ
    (fullRXD_laws { setupP with rest := machReads T tk } NB) hc hst hframe ho hk (.var 9) heval
  let M := c.M.setNum Sa.tab.length (.lit (F64.ofNat ((π.map natV).length + ([] : List Val).length)))
  let t' : St FF.S := { c.t with stack := sa.stack.tail.map c.M.frame ++ [] }.ret
    (natV ((π.map natV).length + ([] : List Val).length))
  have relp : RelB FF (FullRXD { setupP with rest := machReads T tk } NB) wideP []
      M c.ν c.K sb Sb t' c.C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF
      (FullRXD { setupP with rest := machReads T tk } NB) wideP [] M c.ν c.K p.1 p.2 t' c.C) hp).mp rel1
  have relj := relp.toJ (h0.ffi.2.ext ext1)
  refine ⟨t', c.C, runC_one (by rw [h0.isHalt, hc]; rfl) step1,
    ⟨M, c.ν, c.K, t', c.C⟩, rfl, rfl, ?_, ?_⟩
  · exact ⟨relj.withOracle (fun _ h => nomatch h), hq⟩
  · exact glueFwd h0 relj ext1 hi hb hbook

/-- The last unchanged glue reaches the real nextPrefillStep call. -/
theorem glueEnd {NB T L : Nat} {tk : Nat → Nat} {sa sb : St FF.S} {Sa Sb : SSrv}
    {n : Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8)
    (hok : PRE_setup_early_r0.okB2 sa Sa = true)
    (hrun : runOk FF PRE_setup_early_r0.okB2 n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hor : goodLin setup_early.r0.ps (varsOf setup_early.r0.V [(9, .L)]) Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hb : bridgeOf sb.ffi = bridgeOf sa.ffi) :
    CutStep (restCut NB T tk L sa Sa) (restCut NB T tk L sb Sb) n := by
  apply cut_glue (restSim NB T tk) hok hrun htop
  · intro c hq hb; exact ⟨hb.1.1, hq.1⟩
  · intro c hq _; exact good_of_row hor (earlyRow h1 h8) hq.2.2
  · intro c M t C hq hbook hr he _ hr'
    exact ⟨⟨hr'.withOracle (fun _ h => nomatch h), hq⟩, glueFwd hr hr' he hi hb hbook⟩

/-- Exact composition of the unchanged ks entries, source steps and length patches. -/
theorem chunk_next_core {NB T L : Nat} {tk : Nat → Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (setupChunkCut NB T tk L) (setupNextCut NB T tk L) restFuel := by
  have i8 : (bridgeOf PRE_setup_early_r0.s8.ffi).active = false := by rw [bridge8]; exact inactive6
  have i9 : (bridgeOf PRE_setup_early_r0.s9.ffi).active = false := by rw [bridge9]; exact inactive6
  have i11 : (bridgeOf PRE_setup_early_r0.s11.ffi).active = false := by rw [bridge11]; exact inactive6
  have i12 : (bridgeOf PRE_setup_early_r0.s12.ffi).active = false := by rw [bridge12]; exact inactive6
  have i14 : (bridgeOf PRE_setup_early_r0.s14.ffi).active = false := by rw [bridge14]; exact inactive6
  have i15 : (bridgeOf PRE_setup_early_r0.s15.ffi).active = false := by rw [bridge15]; exact inactive6
  have g2 := glueCall (NB := NB) (T := T) (tk := tk) h1 h8 accepted6 PRE_setup_early_r0.runSeg2
    (runOk_ok_end 1017 PRE_setup_early_r0.runSeg2 unhalted7) unhalted7
    PRE_setup_early_r0.stepA3 top8 oracle6 inactive6 bridge8
  have b3 := lengthStep (NB := NB) (T := T) (tk := tk) h1 h8 PRE_setup_early_r0.ctlA3 stack8
    PRE_setup_early_r0.objA3 (by simpa only [prompt8, List.nil_append] using PRE_setup_early_r0.kindA3)
    (Option.some.inj PRE_setup_early_r0.patchB3) oracle8 i8 (bridge9.trans bridge8.symm)
  have g3 := glueCall (NB := NB) (T := T) (tk := tk) h1 h8 accepted9 PRE_setup_early_r0.runSeg3
    (runOk_ok_end 23 PRE_setup_early_r0.runSeg3 unhalted10) unhalted10
    PRE_setup_early_r0.stepA4 top11 oracle9 i9 (bridge11.trans bridge9.symm)
  have b4 := lengthStep (NB := NB) (T := T) (tk := tk) h1 h8 PRE_setup_early_r0.ctlA4 stack11
    PRE_setup_early_r0.objA4 (by simpa only [prompt11, List.nil_append] using PRE_setup_early_r0.kindA4)
    (Option.some.inj PRE_setup_early_r0.patchB4) oracle11 i11 (bridge12.trans bridge11.symm)
  have g4 := glueCall (NB := NB) (T := T) (tk := tk) h1 h8 accepted12 PRE_setup_early_r0.runSeg4
    (runOk_ok_end 350 PRE_setup_early_r0.runSeg4 unhalted13) unhalted13
    PRE_setup_early_r0.stepA5 top14 oracle12 i12 (bridge14.trans bridge12.symm)
  have b5 := lengthStep (NB := NB) (T := T) (tk := tk) h1 h8 PRE_setup_early_r0.ctlA5 stack14
    PRE_setup_early_r0.objA5 (by simpa only [prompt14, List.nil_append] using PRE_setup_early_r0.kindA5)
    (Option.some.inj PRE_setup_early_r0.patchB5) oracle14 i14 (bridge15.trans bridge14.symm)
  have g5 := glueEnd (NB := NB) (T := T) (tk := tk) h1 h8 accepted15 PRE_setup_early_r0.runSeg5
    top16 oracle15 i15 (bridge16.trans bridge15.symm)
  exact ((((((g2.trans b3).trans g3).trans b4).trans g4).trans b5).trans g5).cast rfl rfl rfl

/-- From the accepted actual chunk cut to the actual nextPrefillStep call. -/
theorem chunk_next {NB T L : Nat} {tk : Nat → Nat} (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (setupChunkCut NB T tk L) (setupNextCut NB T tk L) 1407 :=
  (chunk_next_core h1 h8).cast rfl rfl restFuel_exact.symm

/-- The complete supported initialization prefix, composing the accepted 1001-step cut. -/
theorem ldCut_next {NB T L : Nat} {tk : Nat → Nat}
    (hctx : L + T ≤ 262144) (h1 : 1 ≤ L) (h8 : L ≤ 8) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk L)
      (setupNextCut NB T tk L) 2408 :=
  ((ldCut_chunk hctx h1 h8).trans (chunk_next h1 h8)).cast rfl rfl rfl

theorem setupNext_source (NB T : Nat) (tk : Nat → Nat) (L : Nat) :
    isCallOf (setupNextCut NB T tk L).s0 "nextPrefillStep" none = true := nextCall

theorem setupNext_values {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hR : (setupNextCut NB T tk L).R x PRE_setup_early_r0.s16 ⟨PRE_setup_early_r0.S16.tab, []⟩) :
    x.ν 9 = F64.ofNat L ∧ BigJs x.M := ⟨hR.2.2.2.1, hR.1.ffi.2⟩

theorem setupNext_context {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hb : (setupNextCut NB T tk L).B x) :
    Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧ fixedCells x :=
  ⟨hb.1.1, hb.1.2.1, hb.2⟩

theorem setupNext_prompt {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hb : (setupNextCut NB T tk L).B x) :
    ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
      x.K.fr 2665 = some ([], π.map natV) ∧ x.K.D = 13 ∧ AneFresh x.t := hb.1.2.2

theorem setupNext_offset {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hR : (setupNextCut NB T tk L).R x PRE_setup_early_r0.s16 ⟨PRE_setup_early_r0.S16.tab, []⟩)
    (hb : (setupNextCut NB T tk L).B x) : x.t.next = 2673470 := by
  obtain ⟨π, _, _, _, hd, _⟩ := setupNext_prompt hb
  have h := hR.1.offset
  change x.t.next = PRE_setup_early_r0.s16.next + x.K.D at h
  rw [sourceNext, hd] at h
  exact h

end Host.Ts.Sim.Compose.SetupRest
