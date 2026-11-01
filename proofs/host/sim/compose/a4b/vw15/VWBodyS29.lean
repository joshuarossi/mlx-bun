import host.sim.compose.a4b.vw15.VWBodyJ29
import host.sim.compose.a4b.vw15.VWBodySite29
import host.sim.compose.a4b.vw15.VWBodyOracles_7
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift29 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S287.tab.length PRE_first_tail_x15_r0_body.s287.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P29.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P29 1294 PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.s289.ffi PRE_first_tail_x15_r0_body.s288.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_29
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_29
  have hcl : SSt (· < 1294) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s289.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S287.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_29] <;> decide) PRE_first_tail_x15_r0_body.cnodesK29 PRE_first_tail_x15_r0_body.cobjsK29
      PRE_first_tail_x15_r0_body.citemsK29 PRE_first_tail_x15_r0_body.cbd29 PRE_first_tail_x15_r0_body.csst29
  exact PRE_first_tail_x15_r0_body.cshift29 bodyNcl29 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_29] at this; exact this)


kernel_rfl bodyFramesEmpty29 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s288 a).isEmpty) = true
kernel_rfl bodyJsRoots29 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s287.next) PRE_first_tail_x15_r0_body.s289.trace PRE_first_tail_x15_r0_body.s289 = true
kernel_rfl bodyJsNative29 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s289.ffi) = true
kernel_rfl bodyLow29 : (PRE_first_tail_x15_r0_body.cws29 ++ PRE_first_tail_x15_r0_body.ws29).all (Nat.ble 9) = true
kernel_rfl bodyCntM29 : countersOkB PRE_first_tail_x15_r0_body.s287 PRE_first_tail_x15_r0_body.s288 = true
kernel_rfl bodyHi29 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s289.ffi).next setupP.E = true
kernel_rfl bodyNhi29 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s289.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge29 : bridgeOf PRE_first_tail_x15_r0_body.s288.ffi = bridgeOf PRE_first_tail_x15_r0_body.s287.ffi
kernel_rfl bodyNN29 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s287.ffi).nnext PRE_first_tail_x15_r0_body.P29.NL = true
kernel_rfl bodyXn29 : Nat.ble (⟨18768, 15859, 2697328, 1294⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s289.ffi).next = true
kernel_rfl bodyLo29 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s289.ffi).next = true
theorem bodyFacts29 : BodySiteFacts PRE_first_tail_x15_r0_body.s287 PRE_first_tail_x15_r0_body.s288 PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S287 PRE_first_tail_x15_r0_body.S288 PRE_first_tail_x15_r0_body.S289
    PRE_first_tail_x15_r0_body.ws29 PRE_first_tail_x15_r0_body.cws29 PRE_first_tail_x15_r0_body.nr29 PRE_first_tail_x15_r0_body.pl29 PRE_first_tail_x15_r0_body.cl29 2697338 1294 PRE_first_tail_x15_r0_body.kd29 PRE_first_tail_x15_r0_body.kappa29 PRE_first_tail_x15_r0_body.P29
    ⟨18768, 15859, 2697327, 1294⟩ ⟨18768, 15859, 2697328, 1294⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap29
  clean := bodyClean29
  cfix := PRE_first_tail_x15_r0_body.cfix29
  zpl := PRE_first_tail_x15_r0_body.zpl29
  zplnd := PRE_first_tail_x15_r0_body.zplnd29
  zn1 := PRE_first_tail_x15_r0_body.zn129
  zfirst := PRE_first_tail_x15_r0_body.zfirst29
  zscn := PRE_first_tail_x15_r0_body.zscn29
  zsmn := PRE_first_tail_x15_r0_body.zsmn29
  zgrow := PRE_first_tail_x15_r0_body.zgrow29
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab29
  zfresh := PRE_first_tail_x15_r0_body.zfresh29
  zcnd := PRE_first_tail_x15_r0_body.zcnd29
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi29
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt29
  zgP := PRE_first_tail_x15_r0_body.zg29_2665
  zkP := PRE_first_tail_x15_r0_body.zk29_2665
  zmP := PRE_first_tail_x15_r0_body.zm29_2665
  zgC := PRE_first_tail_x15_r0_body.zg29_2673467
  zkC := PRE_first_tail_x15_r0_body.zk29_2673467
  zmC := PRE_first_tail_x15_r0_body.zm29_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw29_2673472
  zwV := PRE_first_tail_x15_r0_body.zw29_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap29
  zclbd := PRE_first_tail_x15_r0_body.zclbd29
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap29 PRE_first_tail_x15_r0_body.stFoot29 PRE_first_tail_x15_r0_body.iso29 PRE_first_tail_x15_r0_body.zwr29
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP29
  csupp := PRE_first_tail_x15_r0_body.csupp29
  cbound := PRE_first_tail_x15_r0_body.cbound29
  zimg := PRE_first_tail_x15_r0_body.zimg29
  zctl := PRE_first_tail_x15_r0_body.zctl29
  zstack := PRE_first_tail_x15_r0_body.zstack29
  zjobs := PRE_first_tail_x15_r0_body.zjobs29
  zstores := PRE_first_tail_x15_r0_body.zstores29
  zroots := PRE_first_tail_x15_r0_body.zroots29
  znC := PRE_first_tail_x15_r0_body.znC29
  ctab := PRE_first_tail_x15_r0_body.ctab29
  zbin := PRE_first_tail_x15_r0_body.zbin29
  cbridge := PRE_first_tail_x15_r0_body.cbridge29
  sbridge := bodyBridge29
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj29
  cshiftR := fun h hNL => bodyCshift29 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN29
  raised := PRE_first_tail_x15_r0_body.raised29
  cbigs := PRE_first_tail_x15_r0_body.cbigs29
  cjcl := PRE_first_tail_x15_r0_body.cjcl29
  xnLe := Nat.le_of_ble_eq_true bodyXn29
  loLe := Nat.le_of_ble_eq_true bodyLo29
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB29
  cntM := bodyCntM29
  hiLe := Nat.le_of_ble_eq_true bodyHi29
  nhiLe := Nat.le_of_ble_eq_true bodyNhi29
  jsHeap := bodyJs29
  jsRoots := bodyJsRoots29
  jsNative := bodyJsNative29
  framesEmpty := bodyFramesEmpty29
  trailOld := by decide
  lowVars := bodyLow29

def bodyQs29 : List (Option Q) := []
noncomputable def bodyEs29 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr29.map fun r => nth? PRE_first_tail_x15_r0_body.st29.S2.tab r
kernel_rfl bodyResChk29 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs29 bodyQs29) = true
kernel_rfl bodyLq29 : bodyQs29.length = PRE_first_tail_x15_r0_body.cws29.length
kernel_rfl bodyNrLo29 : PRE_first_tail_x15_r0_body.nr29.all (Nat.ble PRE_first_tail_x15_r0_body.S287.tab.length) = true
kernel_rfl bodySub29 : (Oracles.PRE_first_tail_x15_r0_body.map_site29.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost29 : postSubB bodyM PRE_first_tail_x15_r0_body.ws29 PRE_first_tail_x15_r0_body.cws29 bodyQs29 = true
kernel_rfl bodyDrop29 : Nat.ble (14125 + (PRE_first_tail_x15_r0_body.s288.next - PRE_first_tail_x15_r0_body.s289.next)) 14135 = true
kernel_rfl bodyDropH29 : Nat.ble (225 + ((mlxOf PRE_first_tail_x15_r0_body.s288.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s289.ffi).next)) 225 = true
kernel_rfl bodyDropN29 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s288.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s289.ffi).nnext)) 0 = true
kernel_rfl bodyDv29 : bodyΘ.1.take 162 = bodyΘ.1.take 162 ++ PRE_first_tail_x15_r0_body.cws29
kernel_rfl bodyDe29 : bodyΘ.2.take 162 = bodyΘ.2.take 162 ++ PRE_first_tail_x15_r0_body.nr29.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st29.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl29 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold29 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws29).isNone && !PRE_first_tail_x15_r0_body.ws29.contains v) = true
kernel_rfl bodyDfree29 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x15_r0_body.cws29 ++ PRE_first_tail_x15_r0_body.ws29).all fun w => e.noVar w) = true

theorem bodyStep29 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s287 PRE_first_tail_x15_r0_body.S287)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14135, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s289 PRE_first_tail_x15_r0_body.S289) (98 + 1) :=
  bodySite bodyFacts29.cfix bodyFacts29.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st29.S2.tab) (Es := bodyEs29) (qs := bodyQs29)
    (ok := PRE_first_tail_x15_r0_body.st29.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site29 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts29
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site29 r hr) hi (MapOk.sub hm (sub_of_all bodySub29)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk29 r hr) hi hm ho hq)
    bodyLq29 rfl bodyNrLo29 (postSub_sound bodyPost29)
    (Nat.le_of_ble_eq_true bodyDrop29) (by decide) (Nat.le_of_ble_eq_true bodyDropH29) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN29) (by decide)
    bodyDv29 bodyDe29 bodyDl29 bodyDold29 bodyDfree29 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
