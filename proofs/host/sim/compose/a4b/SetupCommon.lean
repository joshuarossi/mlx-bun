import host.sim.compose.a4b.SetupCommonData
import host.sim.template.a4pre_g0b.Run
import host.sim.template.a4pre_g0b.Bridge

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- Setup keeps the prompt and driver cells; different chunk classes may have
different offsets within the acceptance's common bound. -/
def BookBase (T : Nat) (tk : Nat → Nat) (L : Nat) (x : SegInst FF) : Prop :=
  (Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
  ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
    x.K.fr 2665 = some ([], π.map natV) ∧ AneFresh x.t ∧ x.M.num 10 = .lit (F64.ofNat (chunkC L))) ∧
    setupInputs T tk x ∧ baseNums ∧ (L ≤ 8 → x.K.D = 13)

def Book (T : Nat) (tk : Nat → Nat) (L : Nat) (x : SegInst FF) : Prop :=
  (Disp.KpJ setupJ 4096 x.K ∧ x.K.fr 4910 = none ∧
  ∃ π : List Nat, π.length = L ∧ (∀ t ∈ π, t < 248320) ∧
    x.K.fr 2665 = some ([], π.map natV) ∧ AneFresh x.t ∧ x.M.num 10 = .lit (F64.ofNat (chunkC L))) ∧
    setupInputs T tk x ∧ baseNums ∧ (L ≤ 8 → x.K.D = 13) ∧ x.K.D ≤ 3526

theorem Book.base {T L : Nat} {tk : Nat → Nat} {x : SegInst FF} (h : Book T tk L x) : BookBase T tk L x :=
  ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1⟩
theorem Book.offset {T L : Nat} {tk : Nat → Nat} {x : SegInst FF} (h : Book T tk L x) : x.K.D ≤ 3526 := h.2.2.2.2

noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (s : St FF.S) (S : SSrv) (i : Cls.Inst) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) setupJ wideP m s S i with
    B := fun x => Book T tk i.L x ∧ fixedCells x ∧ PromptFr π x ∧ NativeAt 0 0 s x.t }

noncomputable def nextCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (L : Nat) : ICut FF :=
  cut NB T tk π PRE_g0b.s10 PRE_g0b.S10 (setupI L)

theorem sim (NB T : Nat) (tk : Nat → Nat) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      PRE_g0b.okB0 (Disp.KpJ setupJ 4096) wideP [] (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hj rfl rfl rfl rfl rfl [] setupW_ok
  have ha : PRE_g0b.okB0 = Disp.okJSJ setupJ (okBackFXS setupP) 4096 := by
    funext s S
    exact setup_acceptance s S
  simpa only [P, backRest, ha] using hs

theorem simQ (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))
      PRE_g0b.okB0 (Disp.KpJ setupJ 4096) wideP [] (VBOkF loopVB) := by
  have ha : PRE_g0b.okB0 = Disp.okJSJ setupJ (okBackFXS setupP) 4096 := by
    funext s S
    exact setup_acceptance s S
  rw [ha]
  exact SetupChunk.wideGrowSim NB T tk [] y0

theorem book_fwd {NB T : Nat} {tk : Nat → Nat} {ρ : List Nat} {L : Nat} {sa sb : St FF.S} {Sa Sb : SSrv}
    {x : SegInst FF} {M : Map} {t : St FF.S} {C : CSrv}
    (h0 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      x.M x.ν x.K sa Sa x.t x.C)
    (h1 : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      M x.ν x.K sb Sb t C) (he : Ext x.M M Sa.tab.length) (h10 : 10 < Sa.tab.length)
    (hi : (bridgeOf sa.ffi).active = false) (hb : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true)
    (hbook : Book T tk L x ∧ fixedCells x ∧ PromptFr ρ x ∧ NativeAt 0 0 sa x.t) :
    Book T tk L ⟨M, x.ν, x.K, t, C⟩ ∧ fixedCells ⟨M, x.ν, x.K, t, C⟩ ∧ PromptFr ρ ⟨M, x.ν, x.K, t, C⟩ ∧ NativeAt 0 0 sb t := by
  obtain ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh, hnum⟩, ⟨hreserved, hem⟩, hbase, hsmall⟩, hids, hpin, hnat⟩ := hbook
  have hi' : (bridgeOf sb.ffi).active = false := by rw [hb]; exact hi
  obtain ⟨_, _, hn0⟩ := h0.ffi.1
  obtain ⟨_, _, hn1⟩ := h1.ffi.1
  have sameBridge : bridgeOf t.ffi = bridgeOf x.t.ffi :=
    (hn1.toR hi').bridge.1.trans (hb.trans (hn0.toR hi).bridge.1.symm)
  refine ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, ?_, (he.num 10 h10).trans hnum⟩,
    ⟨hreserved, (congrFun he.a 2590).trans hem⟩, hbase, hsmall⟩, ?_, hpin, hnat.step (P := { setupP with rest := machReads T tk }) rfl h0 h1 he.big he.node hcnt⟩
  · intro Cx Pc Kc weights kind NE IP G init
    change Host.Mlx.FfiAneEval.final Pc Kc weights kind NE IP G init (bridgeOf t.ffi) = _
    rw [sameBridge]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  · exact ⟨(congrFun he.a 2586).trans hids.1, (congrFun he.a 2589).trans hids.2⟩

theorem glueCall {NB T n : Nat} {tk : Nat → Nat} {ρ : List Nat} {r : Row} {i : Cls.Inst}
    {sa sb sc : St FF.S} {Sa Sb Sc : SSrv} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hrow : InRow r i)
    (hor : goodLin r.ps (varsOf r.V m) Sa.oracle = true)
    (hok : PRE_g0b.okB0 sa Sa = true)
    (hrun : runOk FF PRE_g0b.okB0 n sa Sa = some (sb, Sb))
    (hokb : PRE_g0b.okB0 sb Sb = true) (hh : isHalt sb.ctl = false)
    (hstep : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (h10 : 10 < Sa.tab.length)
    (hi : (bridgeOf sa.ffi).active = false) (hb : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sc = true) :
    CutStep (withMem Mem (cut NB T tk ρ sa Sa i)) (withMem Mem (cut NB T tk ρ sc Sc i)) (n + 1) := by
  apply cut_glueCall (sim NB T tk) hok hrun hokb hh hstep htop
  · intro c hq hb; exact ⟨hb.1.1.1.1, hq.1⟩
  · intro c hq _; exact good_of_row hor hrow hq.2.2
  · intro c M t C hq hbook hr he hrun' hr'
    have hg := glueCall_ngrow (simQ NB T tk) hok hrun hokb hh hstep hq.1 hbook.1.1.1.1 hr hrun'
    exact ⟨⟨hr'.withOracle (fun _ h => nomatch h), hq⟩, book_fwd hr hr' he h10 hi hb hcnt hbook.1,
      hMem c ⟨M, c.ν, c.K, t, C⟩ ⟨runC_le _ _ _ _ _ hrun', he.node, hg,
        tokens_of_grow hr hr' hg (countersOkB_tokens hcnt)⟩ hbook.2⟩

theorem lengthStep {NB T : Nat} {tk : Nat → Nat} {ρ : List Nat} {r : Row} {i : Cls.Inst}
    {sa sb : St FF.S} {Sa Sb : SSrv} {o : Obj} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hrow : InRow r i)
    (hor : goodLin r.ps (varsOf r.V m) Sa.oracle = true)
    (hc : sa.ctl = .ret (.obj 2665)) (hst : sa.stack = .e (.member kLength false) :: sa.stack.tail)
    (ho : sa.obj? 2665 = some o) (hk : o.kind = .array ([] ++ ([] : List Val)))
    (hp : Bridge.lenPatch sa Sa (.var 9) = (sb, Sb))
    (h10 : 10 < Sa.tab.length)
    (hi : (bridgeOf sa.ffi).active = false) (hb : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) :
    CutStep (withMem Mem (cut NB T tk ρ sa Sa i)) (withMem Mem (cut NB T tk ρ sb Sb i)) 1 := by
  rintro t C ⟨c, rfl, rfl, ⟨hr, hq⟩, hbook, hm⟩
  obtain ⟨⟨hctx, hmemo, π, hlen, hvocab, hframe, hfresh, hnum⟩, ⟨hreserved, hem⟩, hbase, hsmall⟩ := hbook.1
  have h0 := hr.withOracle (good_of_row hor hrow hq.2.2)
  change RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
    c.M c.ν c.K sa ⟨Sa.tab, Sa.oracle⟩ c.t c.C at h0
  have heval : (.var 9 : SymE).eval c.ν = F64.ofNat ((π.map natV).length + ([] : List Val).length) := by
    simpa only [SymE.eval, m, MapOk, Inst.get, List.length_map, hlen, List.length_nil, Nat.add_zero]
      using hq.2.2.1
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
  exact ⟨t', c.C, runC_one (by rw [h0.isHalt, hc]; rfl) step1,
    ⟨M, c.ν, c.K, t', c.C⟩, rfl, rfl,
    ⟨relj.withOracle (fun _ h => nomatch h), hq⟩, book_fwd h0 relj ext1 h10 hi hb hcnt hbook,
    hMem c ⟨M, c.ν, c.K, t', c.C⟩ ⟨CSrv.Le.refl _, ext1.node, Host.Mlx.Ffi.NGrow.refl _, rfl⟩ hm⟩

kernel_rfl cnt0 : countersOkB PRE_g0b.s0 PRE_g0b.s2 = true
kernel_rfl cnt2 : countersOkB PRE_g0b.s2 PRE_g0b.s3 = true
kernel_rfl cnt3 : countersOkB PRE_g0b.s3 PRE_g0b.s5 = true
kernel_rfl cnt5 : countersOkB PRE_g0b.s5 PRE_g0b.s6 = true
kernel_rfl cnt6 : countersOkB PRE_g0b.s6 PRE_g0b.s8 = true
kernel_rfl cnt8 : countersOkB PRE_g0b.s8 PRE_g0b.s9 = true
kernel_rfl cnt9 : countersOkB PRE_g0b.s9 PRE_g0b.s10 = true

theorem run {NB T : Nat} {tk : Nat → Nat} {ρ : List Nat} {r : Row} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hr : r ∈ FillSetupEarly.setupRows) (hi : InRow r i) :
    CutStep (withMem Mem (cut NB T tk ρ PRE_g0b.s0 PRE_g0b.S0 i))
      (withMem Mem (cut NB T tk ρ PRE_g0b.s10 PRE_g0b.S10 i)) 1407 := by
  have i3 : (bridgeOf PRE_g0b.s3.ffi).active = false := by rw [bridge3]; exact inactive0
  have i6 : (bridgeOf PRE_g0b.s6.ffi).active = false := by rw [bridge6]; exact inactive0
  have i9 : (bridgeOf PRE_g0b.s9.ffi).active = false := by rw [bridge9]; exact inactive0
  have i2 : (bridgeOf PRE_g0b.s2.ffi).active = false := by rw [bridge2]; exact inactive0
  have i5 : (bridgeOf PRE_g0b.s5.ffi).active = false := by rw [bridge5]; exact inactive0
  have i8 : (bridgeOf PRE_g0b.s8.ffi).active = false := by rw [bridge8]; exact inactive0
  have g0 := glueCall (NB := NB) (T := T) (tk := tk) hMem hi (List.all_eq_true.mp oracle0 r hr)
    accepted0 PRE_g0b.runSeg0 (runOk_ok_end 1017 PRE_g0b.runSeg0 live1) live1 PRE_g0b.stepA1 top2
    (Nat.blt_eq.mp tableLen0) inactive0 bridge2 cnt0
  have b1 := lengthStep (NB := NB) (T := T) (tk := tk) hMem hi (List.all_eq_true.mp oracle2 r hr)
    PRE_g0b.ctlA1 stack2 PRE_g0b.objA1 (by rw [PRE_g0b.kindA1, empty2]; rfl)
    (Option.some.inj PRE_g0b.patchB1) (Nat.blt_eq.mp tableLen2) i2 (bridge3.trans bridge2.symm) cnt2
  have g1 := glueCall (NB := NB) (T := T) (tk := tk) hMem hi (List.all_eq_true.mp oracle3 r hr)
    accepted3 PRE_g0b.runSeg1 (runOk_ok_end 23 PRE_g0b.runSeg1 live4) live4 PRE_g0b.stepA2 top5
    (Nat.blt_eq.mp tableLen3) i3
    (bridge5.trans bridge3.symm) cnt3
  have b2 := lengthStep (NB := NB) (T := T) (tk := tk) hMem hi (List.all_eq_true.mp oracle5 r hr)
    PRE_g0b.ctlA2 stack5 PRE_g0b.objA2 (by rw [PRE_g0b.kindA2, empty5]; rfl)
    (Option.some.inj PRE_g0b.patchB2) (Nat.blt_eq.mp tableLen5) i5 (bridge6.trans bridge5.symm) cnt5
  have g2 := glueCall (NB := NB) (T := T) (tk := tk) hMem hi (List.all_eq_true.mp oracle6 r hr)
    accepted6 PRE_g0b.runSeg2 (runOk_ok_end 350 PRE_g0b.runSeg2 live7) live7 PRE_g0b.stepA3 top8
    (Nat.blt_eq.mp tableLen6) i6
    (bridge8.trans bridge6.symm) cnt6
  have b3 := lengthStep (NB := NB) (T := T) (tk := tk) hMem hi (List.all_eq_true.mp oracle8 r hr)
    PRE_g0b.ctlA3 stack8 PRE_g0b.objA3 (by rw [PRE_g0b.kindA3, empty8]; rfl)
    (Option.some.inj PRE_g0b.patchB3) (Nat.blt_eq.mp tableLen8) i8 (bridge9.trans bridge8.symm) cnt8
  have g3 : CutStep (withMem Mem (cut NB T tk ρ PRE_g0b.s9 PRE_g0b.S9 i))
      (withMem Mem (cut NB T tk ρ PRE_g0b.s10 PRE_g0b.S10 i)) 8 := by
    apply cut_glue (sim NB T tk) accepted9 PRE_g0b.runSeg3 top10
    · intro c hq hb; exact ⟨hb.1.1.1.1, hq.1⟩
    · intro c hq _; exact good_of_row (List.all_eq_true.mp oracle9 r hr) hi hq.2.2
    · intro c M t C hq hb hrel he hrun' hrel'
      have hg := glue_ngrow (simQ NB T tk) accepted9 PRE_g0b.runSeg3 hq.1 hb.1.1.1.1 hrel hrun'
      exact ⟨⟨hrel'.withOracle (fun _ h => nomatch h), hq⟩,
        book_fwd hrel hrel' he (Nat.blt_eq.mp tableLen9) i9 (bridge10.trans bridge9.symm) cnt9 hb.1,
        hMem c ⟨M, c.ν, c.K, t, C⟩ ⟨runC_le _ _ _ _ _ hrun', he.node, hg,
          tokens_of_grow hrel hrel' hg (countersOkB_tokens cnt9)⟩ hb.2⟩
  exact ((((((g0.trans b1).trans g1).trans b2).trans g2).trans b3).trans g3).cast rfl rfl rfl

theorem toNext {NB T : Nat} {tk : Nat → Nat} {ρ : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hC : i.C = chunkC i.L) :
    CutConv (withMem Mem (cut NB T tk ρ PRE_g0b.s10 PRE_g0b.S10 i)) (withMem Mem (nextCut NB T tk ρ i.L)) := by
  rintro x ⟨hr, hq⟩ hb
  refine ⟨x, rfl, rfl, ⟨hr, hq.1, hq.2.1, ?_⟩, hb⟩
  change x.ν 9 = F64.ofNat i.L ∧ x.ν 10 = F64.ofNat (chunkC i.L) ∧ True
  exact ⟨hq.2.2.1, by rw [← hC]; exact hq.2.2.2.1, trivial⟩

end Host.Ts.Sim.Compose.SetupCommon

namespace Host.Ts.Sim.Compose.FillSetupEarly
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupChunk

/-- All setup classes share the template PRE_g0b, with C abstracted at table/variable 10. -/
noncomputable def g0b (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop)
    (hMem : ∀ L x y, NTrack x y → Mem L x → Mem L y) :
    GluePiece FF setupRows (fun i => withMem (Mem i.L) (SetupCommon.cut NB T tk π PRE_g0b.s0 PRE_g0b.S0 i))
      (fun i => withMem (Mem i.L) (SetupCommon.nextCut NB T tk π i.L)) where
  m := SetupCommon.m
  n := 1407
  O := PRE_g0b.S0.oracle
  chk r hr := List.all_eq_true.mp SetupCommon.oracle0 r hr
  ok r hr i hi _ := (SetupCommon.run (hMem i.L) hr hi).convR (SetupCommon.toNext (setupC hr hi))

end Host.Ts.Sim.Compose.FillSetupEarly
