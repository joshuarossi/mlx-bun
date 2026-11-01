import host.sim.compose.a4b.vw15.VWBodyJ11
import host.sim.compose.a4b.vw15.VWBodySite11
import host.sim.compose.a4b.vw15.VWBodyOracles_2
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift11 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S114.tab.length PRE_first_tail_x15_r0_body.s114.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P11.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P11 523 PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.s116.ffi PRE_first_tail_x15_r0_body.s115.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_11
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_11
  have hcl : SSt (· < 523) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S114.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_11] <;> decide) PRE_first_tail_x15_r0_body.cnodesK11 PRE_first_tail_x15_r0_body.cobjsK11
      PRE_first_tail_x15_r0_body.citemsK11 PRE_first_tail_x15_r0_body.cbd11 PRE_first_tail_x15_r0_body.csst11
  exact PRE_first_tail_x15_r0_body.cshift11 bodyNcl11 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_11] at this; exact this)


kernel_rfl bodyFramesEmpty11 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s115 a).isEmpty) = true
kernel_rfl bodyJsRoots11 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s114.next) PRE_first_tail_x15_r0_body.s116.trace PRE_first_tail_x15_r0_body.s116 = true
kernel_rfl bodyJsNative11 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s116.ffi) = true
kernel_rfl bodyLow11 : (PRE_first_tail_x15_r0_body.cws11 ++ PRE_first_tail_x15_r0_body.ws11).all (Nat.ble 9) = true
kernel_rfl bodyCntM11 : countersOkB PRE_first_tail_x15_r0_body.s114 PRE_first_tail_x15_r0_body.s115 = true
kernel_rfl bodyHi11 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s116.ffi).next setupP.E = true
kernel_rfl bodyNhi11 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s116.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge11 : bridgeOf PRE_first_tail_x15_r0_body.s115.ffi = bridgeOf PRE_first_tail_x15_r0_body.s114.ffi
kernel_rfl bodyNN11 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s114.ffi).nnext PRE_first_tail_x15_r0_body.P11.NL = true
kernel_rfl bodyXn11 : Nat.ble (⟨18417, 15496, 2683382, 523⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s116.ffi).next = true
kernel_rfl bodyLo11 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s116.ffi).next = true
theorem bodyFacts11 : BodySiteFacts PRE_first_tail_x15_r0_body.s114 PRE_first_tail_x15_r0_body.s115 PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S114 PRE_first_tail_x15_r0_body.S115 PRE_first_tail_x15_r0_body.S116
    PRE_first_tail_x15_r0_body.ws11 PRE_first_tail_x15_r0_body.cws11 PRE_first_tail_x15_r0_body.nr11 PRE_first_tail_x15_r0_body.pl11 PRE_first_tail_x15_r0_body.cl11 2683392 523 PRE_first_tail_x15_r0_body.kd11 PRE_first_tail_x15_r0_body.kappa11 PRE_first_tail_x15_r0_body.P11
    ⟨18417, 15496, 2683381, 523⟩ ⟨18417, 15496, 2683382, 523⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap11
  clean := bodyClean11
  cfix := PRE_first_tail_x15_r0_body.cfix11
  zpl := PRE_first_tail_x15_r0_body.zpl11
  zplnd := PRE_first_tail_x15_r0_body.zplnd11
  zn1 := PRE_first_tail_x15_r0_body.zn111
  zfirst := PRE_first_tail_x15_r0_body.zfirst11
  zscn := PRE_first_tail_x15_r0_body.zscn11
  zsmn := PRE_first_tail_x15_r0_body.zsmn11
  zgrow := PRE_first_tail_x15_r0_body.zgrow11
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab11
  zfresh := PRE_first_tail_x15_r0_body.zfresh11
  zcnd := PRE_first_tail_x15_r0_body.zcnd11
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi11
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt11
  zgP := PRE_first_tail_x15_r0_body.zg11_2665
  zkP := PRE_first_tail_x15_r0_body.zk11_2665
  zmP := PRE_first_tail_x15_r0_body.zm11_2665
  zgC := PRE_first_tail_x15_r0_body.zg11_2673467
  zkC := PRE_first_tail_x15_r0_body.zk11_2673467
  zmC := PRE_first_tail_x15_r0_body.zm11_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw11_2673472
  zwV := PRE_first_tail_x15_r0_body.zw11_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap11
  zclbd := PRE_first_tail_x15_r0_body.zclbd11
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap11 PRE_first_tail_x15_r0_body.stFoot11 PRE_first_tail_x15_r0_body.iso11 PRE_first_tail_x15_r0_body.zwr11
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP11
  csupp := PRE_first_tail_x15_r0_body.csupp11
  cbound := PRE_first_tail_x15_r0_body.cbound11
  zimg := PRE_first_tail_x15_r0_body.zimg11
  zctl := PRE_first_tail_x15_r0_body.zctl11
  zstack := PRE_first_tail_x15_r0_body.zstack11
  zjobs := PRE_first_tail_x15_r0_body.zjobs11
  zstores := PRE_first_tail_x15_r0_body.zstores11
  zroots := PRE_first_tail_x15_r0_body.zroots11
  znC := PRE_first_tail_x15_r0_body.znC11
  ctab := PRE_first_tail_x15_r0_body.ctab11
  zbin := PRE_first_tail_x15_r0_body.zbin11
  cbridge := PRE_first_tail_x15_r0_body.cbridge11
  sbridge := bodyBridge11
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj11
  cshiftR := fun h hNL => bodyCshift11 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN11
  raised := PRE_first_tail_x15_r0_body.raised11
  cbigs := PRE_first_tail_x15_r0_body.cbigs11
  cjcl := PRE_first_tail_x15_r0_body.cjcl11
  xnLe := Nat.le_of_ble_eq_true bodyXn11
  loLe := Nat.le_of_ble_eq_true bodyLo11
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB11
  cntM := bodyCntM11
  hiLe := Nat.le_of_ble_eq_true bodyHi11
  nhiLe := Nat.le_of_ble_eq_true bodyNhi11
  jsHeap := bodyJs11
  jsRoots := bodyJsRoots11
  jsNative := bodyJsNative11
  framesEmpty := bodyFramesEmpty11
  trailOld := by decide
  lowVars := bodyLow11

def bodyQs11 : List (Option Q) := []
noncomputable def bodyEs11 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr11.map fun r => nth? PRE_first_tail_x15_r0_body.st11.S2.tab r
kernel_rfl bodyResChk11 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs11 bodyQs11) = true
kernel_rfl bodyLq11 : bodyQs11.length = PRE_first_tail_x15_r0_body.cws11.length
kernel_rfl bodyNrLo11 : PRE_first_tail_x15_r0_body.nr11.all (Nat.ble PRE_first_tail_x15_r0_body.S114.tab.length) = true
kernel_rfl bodySub11 : (Oracles.PRE_first_tail_x15_r0_body.map_site11.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost11 : postSubB bodyM PRE_first_tail_x15_r0_body.ws11 PRE_first_tail_x15_r0_body.cws11 bodyQs11 = true
kernel_rfl bodyDrop11 : Nat.ble (7958 + (PRE_first_tail_x15_r0_body.s115.next - PRE_first_tail_x15_r0_body.s116.next)) 7968 = true
kernel_rfl bodyDropH11 : Nat.ble (98 + ((mlxOf PRE_first_tail_x15_r0_body.s115.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s116.ffi).next)) 98 = true
kernel_rfl bodyDropN11 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s115.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s116.ffi).nnext)) 0 = true
kernel_rfl bodyDv11 : bodyΘ.1.take 63 = bodyΘ.1.take 63 ++ PRE_first_tail_x15_r0_body.cws11
kernel_rfl bodyDe11 : bodyΘ.2.take 63 = bodyΘ.2.take 63 ++ PRE_first_tail_x15_r0_body.nr11.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st11.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 63) (bodyΘ.2.take 63)))
kernel_rfl bodyDl11 : (bodyΘ.1.take 63).length = (bodyΘ.2.take 63).length
kernel_rfl bodyDold11 : (bodyΘ.1.take 63).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws11).isNone && !PRE_first_tail_x15_r0_body.ws11.contains v) = true
kernel_rfl bodyDfree11 : (bodyΘ.2.take 63).all (fun e => (PRE_first_tail_x15_r0_body.cws11 ++ PRE_first_tail_x15_r0_body.ws11).all fun w => e.noVar w) = true

theorem bodyStep11 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s114 PRE_first_tail_x15_r0_body.S114)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s116 PRE_first_tail_x15_r0_body.S116) (98 + 1) :=
  bodySite bodyFacts11.cfix bodyFacts11.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st11.S2.tab) (Es := bodyEs11) (qs := bodyQs11)
    (ok := PRE_first_tail_x15_r0_body.st11.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site11 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts11
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site11 r hr) hi (MapOk.sub hm (sub_of_all bodySub11)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk11 r hr) hi hm ho hq)
    bodyLq11 rfl bodyNrLo11 (postSub_sound bodyPost11)
    (Nat.le_of_ble_eq_true bodyDrop11) (by decide) (Nat.le_of_ble_eq_true bodyDropH11) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN11) (by decide)
    bodyDv11 bodyDe11 bodyDl11 bodyDold11 bodyDfree11 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
