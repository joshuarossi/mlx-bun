import host.sim.compose.a4b.vw15.VWBodyJ109
import host.sim.compose.a4b.vw15.VWBodySite109
import host.sim.compose.a4b.vw15.VWBodyOracles_27
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift109 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1059.tab.length PRE_first_tail_x15_r0_body.s1059.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P109.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P109 4739 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.s1061.ffi PRE_first_tail_x15_r0_body.s1060.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_109
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_109
  have hcl : SSt (· < 4739) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1061.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1059.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_109] <;> decide) PRE_first_tail_x15_r0_body.cnodesK109 PRE_first_tail_x15_r0_body.cobjsK109
      PRE_first_tail_x15_r0_body.citemsK109 PRE_first_tail_x15_r0_body.cbd109 PRE_first_tail_x15_r0_body.csst109
  exact PRE_first_tail_x15_r0_body.cshift109 bodyNcl109 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_109] at this; exact this)


kernel_rfl bodyFramesEmpty109 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1060 a).isEmpty) = true
kernel_rfl bodyJsRoots109 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1059.next) PRE_first_tail_x15_r0_body.s1061.trace PRE_first_tail_x15_r0_body.s1061 = true
kernel_rfl bodyJsNative109 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1061.ffi) = true
kernel_rfl bodyLow109 : (PRE_first_tail_x15_r0_body.cws109 ++ PRE_first_tail_x15_r0_body.ws109).all (Nat.ble 9) = true
kernel_rfl bodyCntM109 : countersOkB PRE_first_tail_x15_r0_body.s1059 PRE_first_tail_x15_r0_body.s1060 = true
kernel_rfl bodyHi109 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1061.ffi).next setupP.E = true
kernel_rfl bodyNhi109 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1061.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge109 : bridgeOf PRE_first_tail_x15_r0_body.s1060.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1059.ffi
kernel_rfl bodyNN109 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1059.ffi).nnext PRE_first_tail_x15_r0_body.P109.NL = true
kernel_rfl bodyXn109 : Nat.ble (⟨20356, 17451, 2760707, 4739⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1061.ffi).next = true
kernel_rfl bodyLo109 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1061.ffi).next = true
theorem bodyFacts109 : BodySiteFacts PRE_first_tail_x15_r0_body.s1059 PRE_first_tail_x15_r0_body.s1060 PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1059 PRE_first_tail_x15_r0_body.S1060 PRE_first_tail_x15_r0_body.S1061
    PRE_first_tail_x15_r0_body.ws109 PRE_first_tail_x15_r0_body.cws109 PRE_first_tail_x15_r0_body.nr109 PRE_first_tail_x15_r0_body.pl109 PRE_first_tail_x15_r0_body.cl109 2760709 4739 PRE_first_tail_x15_r0_body.kd109 PRE_first_tail_x15_r0_body.kappa109 PRE_first_tail_x15_r0_body.P109
    ⟨20356, 17451, 2760707, 4739⟩ ⟨20356, 17451, 2760707, 4739⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap109
  clean := bodyClean109
  cfix := PRE_first_tail_x15_r0_body.cfix109
  zpl := PRE_first_tail_x15_r0_body.zpl109
  zplnd := PRE_first_tail_x15_r0_body.zplnd109
  zn1 := PRE_first_tail_x15_r0_body.zn1109
  zfirst := PRE_first_tail_x15_r0_body.zfirst109
  zscn := PRE_first_tail_x15_r0_body.zscn109
  zsmn := PRE_first_tail_x15_r0_body.zsmn109
  zgrow := PRE_first_tail_x15_r0_body.zgrow109
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab109
  zfresh := PRE_first_tail_x15_r0_body.zfresh109
  zcnd := PRE_first_tail_x15_r0_body.zcnd109
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi109
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt109
  zgP := PRE_first_tail_x15_r0_body.zg109_2665
  zkP := PRE_first_tail_x15_r0_body.zk109_2665
  zmP := PRE_first_tail_x15_r0_body.zm109_2665
  zgC := PRE_first_tail_x15_r0_body.zg109_2673467
  zkC := PRE_first_tail_x15_r0_body.zk109_2673467
  zmC := PRE_first_tail_x15_r0_body.zm109_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw109_2673472
  zwV := PRE_first_tail_x15_r0_body.zw109_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap109
  zclbd := PRE_first_tail_x15_r0_body.zclbd109
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap109 PRE_first_tail_x15_r0_body.stFoot109 PRE_first_tail_x15_r0_body.iso109 PRE_first_tail_x15_r0_body.zwr109
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP109
  csupp := PRE_first_tail_x15_r0_body.csupp109
  cbound := PRE_first_tail_x15_r0_body.cbound109
  zimg := PRE_first_tail_x15_r0_body.zimg109
  zctl := PRE_first_tail_x15_r0_body.zctl109
  zstack := PRE_first_tail_x15_r0_body.zstack109
  zjobs := PRE_first_tail_x15_r0_body.zjobs109
  zstores := PRE_first_tail_x15_r0_body.zstores109
  zroots := PRE_first_tail_x15_r0_body.zroots109
  znC := PRE_first_tail_x15_r0_body.znC109
  ctab := PRE_first_tail_x15_r0_body.ctab109
  zbin := PRE_first_tail_x15_r0_body.zbin109
  cbridge := PRE_first_tail_x15_r0_body.cbridge109
  sbridge := bodyBridge109
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj109
  cshiftR := fun h hNL => bodyCshift109 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN109
  raised := PRE_first_tail_x15_r0_body.raised109
  cbigs := PRE_first_tail_x15_r0_body.cbigs109
  cjcl := PRE_first_tail_x15_r0_body.cjcl109
  xnLe := Nat.le_of_ble_eq_true bodyXn109
  loLe := Nat.le_of_ble_eq_true bodyLo109
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB109
  cntM := bodyCntM109
  hiLe := Nat.le_of_ble_eq_true bodyHi109
  nhiLe := Nat.le_of_ble_eq_true bodyNhi109
  jsHeap := bodyJs109
  jsRoots := bodyJsRoots109
  jsNative := bodyJsNative109
  framesEmpty := bodyFramesEmpty109
  trailOld := by decide
  lowVars := bodyLow109

def bodyQs109 : List (Option Q) := []
noncomputable def bodyEs109 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr109.map fun r => nth? PRE_first_tail_x15_r0_body.st109.S2.tab r
kernel_rfl bodyResChk109 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs109 bodyQs109) = true
kernel_rfl bodyLq109 : bodyQs109.length = PRE_first_tail_x15_r0_body.cws109.length
kernel_rfl bodyNrLo109 : PRE_first_tail_x15_r0_body.nr109.all (Nat.ble PRE_first_tail_x15_r0_body.S1059.tab.length) = true
kernel_rfl bodySub109 : (Oracles.PRE_first_tail_x15_r0_body.map_site109.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost109 : postSubB bodyM PRE_first_tail_x15_r0_body.ws109 PRE_first_tail_x15_r0_body.cws109 bodyQs109 = true
kernel_rfl bodyDrop109 : Nat.ble (39967 + (PRE_first_tail_x15_r0_body.s1060.next - PRE_first_tail_x15_r0_body.s1061.next)) 39969 = true
kernel_rfl bodyDropH109 : Nat.ble (739 + ((mlxOf PRE_first_tail_x15_r0_body.s1060.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1061.ffi).next)) 739 = true
kernel_rfl bodyDropN109 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1060.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1061.ffi).nnext)) 0 = true
kernel_rfl bodyDv109 : bodyΘ.1.take 585 = bodyΘ.1.take 585 ++ PRE_first_tail_x15_r0_body.cws109
kernel_rfl bodyDe109 : bodyΘ.2.take 585 = bodyΘ.2.take 585 ++ PRE_first_tail_x15_r0_body.nr109.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st109.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 585) (bodyΘ.2.take 585)))
kernel_rfl bodyDl109 : (bodyΘ.1.take 585).length = (bodyΘ.2.take 585).length
kernel_rfl bodyDold109 : (bodyΘ.1.take 585).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws109).isNone && !PRE_first_tail_x15_r0_body.ws109.contains v) = true
kernel_rfl bodyDfree109 : (bodyΘ.2.take 585).all (fun e => (PRE_first_tail_x15_r0_body.cws109 ++ PRE_first_tail_x15_r0_body.ws109).all fun w => e.noVar w) = true

theorem bodyStep109 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39967, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1059 PRE_first_tail_x15_r0_body.S1059)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39969, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.S1061) (27 + 1) :=
  bodySite bodyFacts109.cfix bodyFacts109.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st109.S2.tab) (Es := bodyEs109) (qs := bodyQs109)
    (ok := PRE_first_tail_x15_r0_body.st109.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site109 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts109
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site109 r hr) hi (MapOk.sub hm (sub_of_all bodySub109)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk109 r hr) hi hm ho hq)
    bodyLq109 rfl bodyNrLo109 (postSub_sound bodyPost109)
    (Nat.le_of_ble_eq_true bodyDrop109) (by decide) (Nat.le_of_ble_eq_true bodyDropH109) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN109) (by decide)
    bodyDv109 bodyDe109 bodyDl109 bodyDold109 bodyDfree109 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
