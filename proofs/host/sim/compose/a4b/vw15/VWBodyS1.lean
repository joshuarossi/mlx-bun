import host.sim.compose.a4b.vw15.VWBodyJ1
import host.sim.compose.a4b.vw15.VWBodySite1
import host.sim.compose.a4b.vw15.VWBodyOracles_0
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift1 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S24.tab.length PRE_first_tail_x15_r0_body.s24.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P1.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P1 122 PRE_first_tail_x15_r0_body.kappa1 PRE_first_tail_x15_r0_body.s26.ffi PRE_first_tail_x15_r0_body.s25.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_1
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_1
  have hcl : SSt (· < 122) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S24.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_1] <;> decide) PRE_first_tail_x15_r0_body.cnodesK1 PRE_first_tail_x15_r0_body.cobjsK1
      PRE_first_tail_x15_r0_body.citemsK1 PRE_first_tail_x15_r0_body.cbd1 PRE_first_tail_x15_r0_body.csst1
  exact PRE_first_tail_x15_r0_body.cshift1 bodyNcl1 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_1] at this; exact this)


kernel_rfl bodyFramesEmpty1 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s25 a).isEmpty) = true
kernel_rfl bodyJsRoots1 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s24.next) PRE_first_tail_x15_r0_body.s26.trace PRE_first_tail_x15_r0_body.s26 = true
kernel_rfl bodyJsNative1 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s26.ffi) = true
kernel_rfl bodyLow1 : (PRE_first_tail_x15_r0_body.cws1 ++ PRE_first_tail_x15_r0_body.ws1).all (Nat.ble 9) = true
kernel_rfl bodyCntM1 : countersOkB PRE_first_tail_x15_r0_body.s24 PRE_first_tail_x15_r0_body.s25 = true
kernel_rfl bodyHi1 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s26.ffi).next setupP.E = true
kernel_rfl bodyNhi1 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s26.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge1 : bridgeOf PRE_first_tail_x15_r0_body.s25.ffi = bridgeOf PRE_first_tail_x15_r0_body.s24.ffi
kernel_rfl bodyNN1 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s24.ffi).nnext PRE_first_tail_x15_r0_body.P1.NL = true
kernel_rfl bodyXn1 : Nat.ble (⟨18226, 15318, 2675765, 122⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s26.ffi).next = true
kernel_rfl bodyLo1 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s26.ffi).next = true
theorem bodyFacts1 : BodySiteFacts PRE_first_tail_x15_r0_body.s24 PRE_first_tail_x15_r0_body.s25 PRE_first_tail_x15_r0_body.s26 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S24 PRE_first_tail_x15_r0_body.S25 PRE_first_tail_x15_r0_body.S26
    PRE_first_tail_x15_r0_body.ws1 PRE_first_tail_x15_r0_body.cws1 PRE_first_tail_x15_r0_body.nr1 PRE_first_tail_x15_r0_body.pl1 PRE_first_tail_x15_r0_body.cl1 2675767 122 PRE_first_tail_x15_r0_body.kd1 PRE_first_tail_x15_r0_body.kappa1 PRE_first_tail_x15_r0_body.P1
    ⟨18226, 15318, 2675765, 122⟩ ⟨18226, 15318, 2675765, 122⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap1
  clean := bodyClean1
  cfix := PRE_first_tail_x15_r0_body.cfix1
  zpl := PRE_first_tail_x15_r0_body.zpl1
  zplnd := PRE_first_tail_x15_r0_body.zplnd1
  zn1 := PRE_first_tail_x15_r0_body.zn11
  zfirst := PRE_first_tail_x15_r0_body.zfirst1
  zscn := PRE_first_tail_x15_r0_body.zscn1
  zsmn := PRE_first_tail_x15_r0_body.zsmn1
  zgrow := PRE_first_tail_x15_r0_body.zgrow1
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab1
  zfresh := PRE_first_tail_x15_r0_body.zfresh1
  zcnd := PRE_first_tail_x15_r0_body.zcnd1
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi1
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt1
  zgP := PRE_first_tail_x15_r0_body.zg1_2665
  zkP := PRE_first_tail_x15_r0_body.zk1_2665
  zmP := PRE_first_tail_x15_r0_body.zm1_2665
  zgC := PRE_first_tail_x15_r0_body.zg1_2673467
  zkC := PRE_first_tail_x15_r0_body.zk1_2673467
  zmC := PRE_first_tail_x15_r0_body.zm1_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw1_2673472
  zwV := PRE_first_tail_x15_r0_body.zw1_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap1
  zclbd := PRE_first_tail_x15_r0_body.zclbd1
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap1 PRE_first_tail_x15_r0_body.stFoot1 PRE_first_tail_x15_r0_body.iso1 PRE_first_tail_x15_r0_body.zwr1
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP1
  csupp := PRE_first_tail_x15_r0_body.csupp1
  cbound := PRE_first_tail_x15_r0_body.cbound1
  zimg := PRE_first_tail_x15_r0_body.zimg1
  zctl := PRE_first_tail_x15_r0_body.zctl1
  zstack := PRE_first_tail_x15_r0_body.zstack1
  zjobs := PRE_first_tail_x15_r0_body.zjobs1
  zstores := PRE_first_tail_x15_r0_body.zstores1
  zroots := PRE_first_tail_x15_r0_body.zroots1
  znC := PRE_first_tail_x15_r0_body.znC1
  ctab := PRE_first_tail_x15_r0_body.ctab1
  zbin := PRE_first_tail_x15_r0_body.zbin1
  cbridge := PRE_first_tail_x15_r0_body.cbridge1
  sbridge := bodyBridge1
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj1
  cshiftR := fun h hNL => bodyCshift1 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN1
  raised := PRE_first_tail_x15_r0_body.raised1
  cbigs := PRE_first_tail_x15_r0_body.cbigs1
  cjcl := PRE_first_tail_x15_r0_body.cjcl1
  xnLe := Nat.le_of_ble_eq_true bodyXn1
  loLe := Nat.le_of_ble_eq_true bodyLo1
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB1
  cntM := bodyCntM1
  hiLe := Nat.le_of_ble_eq_true bodyHi1
  nhiLe := Nat.le_of_ble_eq_true bodyNhi1
  jsHeap := bodyJs1
  jsRoots := bodyJsRoots1
  jsNative := bodyJsNative1
  framesEmpty := bodyFramesEmpty1
  trailOld := by decide
  lowVars := bodyLow1

def bodyQs1 : List (Option Q) := []
noncomputable def bodyEs1 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr1.map fun r => nth? PRE_first_tail_x15_r0_body.st1.S2.tab r
kernel_rfl bodyResChk1 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs1 bodyQs1) = true
kernel_rfl bodyLq1 : bodyQs1.length = PRE_first_tail_x15_r0_body.cws1.length
kernel_rfl bodyNrLo1 : PRE_first_tail_x15_r0_body.nr1.all (Nat.ble PRE_first_tail_x15_r0_body.S24.tab.length) = true
kernel_rfl bodySub1 : (Oracles.PRE_first_tail_x15_r0_body.map_site1.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost1 : postSubB bodyM PRE_first_tail_x15_r0_body.ws1 PRE_first_tail_x15_r0_body.cws1 bodyQs1 = true
kernel_rfl bodyDrop1 : Nat.ble (5263 + (PRE_first_tail_x15_r0_body.s25.next - PRE_first_tail_x15_r0_body.s26.next)) 5265 = true
kernel_rfl bodyDropH1 : Nat.ble (46 + ((mlxOf PRE_first_tail_x15_r0_body.s25.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s26.ffi).next)) 46 = true
kernel_rfl bodyDropN1 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s25.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s26.ffi).nnext)) 0 = true
kernel_rfl bodyDv1 : bodyΘ.1.take 18 = bodyΘ.1.take 18 ++ PRE_first_tail_x15_r0_body.cws1
kernel_rfl bodyDe1 : bodyΘ.2.take 18 = bodyΘ.2.take 18 ++ PRE_first_tail_x15_r0_body.nr1.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st1.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 18) (bodyΘ.2.take 18)))
kernel_rfl bodyDl1 : (bodyΘ.1.take 18).length = (bodyΘ.2.take 18).length
kernel_rfl bodyDold1 : (bodyΘ.1.take 18).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws1).isNone && !PRE_first_tail_x15_r0_body.ws1.contains v) = true
kernel_rfl bodyDfree1 : (bodyΘ.2.take 18).all (fun e => (PRE_first_tail_x15_r0_body.cws1 ++ PRE_first_tail_x15_r0_body.ws1).all fun w => e.noVar w) = true

theorem bodyStep1 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5263, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s24 PRE_first_tail_x15_r0_body.S24)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5265, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s26 PRE_first_tail_x15_r0_body.S26) (27 + 1) :=
  bodySite bodyFacts1.cfix bodyFacts1.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st1.S2.tab) (Es := bodyEs1) (qs := bodyQs1)
    (ok := PRE_first_tail_x15_r0_body.st1.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site1 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts1
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site1 r hr) hi (MapOk.sub hm (sub_of_all bodySub1)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk1 r hr) hi hm ho hq)
    bodyLq1 rfl bodyNrLo1 (postSub_sound bodyPost1)
    (Nat.le_of_ble_eq_true bodyDrop1) (by decide) (Nat.le_of_ble_eq_true bodyDropH1) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN1) (by decide)
    bodyDv1 bodyDe1 bodyDl1 bodyDold1 bodyDfree1 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
