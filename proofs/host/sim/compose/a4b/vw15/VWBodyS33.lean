import host.sim.compose.a4b.vw15.VWBodyJ33
import host.sim.compose.a4b.vw15.VWBodySite33
import host.sim.compose.a4b.vw15.VWBodyOracles_8
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift33 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S332.tab.length PRE_first_tail_x15_r0_body.s332.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P33.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P33 1509 PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.s334.ffi PRE_first_tail_x15_r0_body.s333.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_33
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_33
  have hcl : SSt (· < 1509) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s334.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S332.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_33] <;> decide) PRE_first_tail_x15_r0_body.cnodesK33 PRE_first_tail_x15_r0_body.cobjsK33
      PRE_first_tail_x15_r0_body.citemsK33 PRE_first_tail_x15_r0_body.cbd33 PRE_first_tail_x15_r0_body.csst33
  exact PRE_first_tail_x15_r0_body.cshift33 bodyNcl33 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_33] at this; exact this)


kernel_rfl bodyFramesEmpty33 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s333 a).isEmpty) = true
kernel_rfl bodyJsRoots33 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s332.next) PRE_first_tail_x15_r0_body.s334.trace PRE_first_tail_x15_r0_body.s334 = true
kernel_rfl bodyJsNative33 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s334.ffi) = true
kernel_rfl bodyLow33 : (PRE_first_tail_x15_r0_body.cws33 ++ PRE_first_tail_x15_r0_body.ws33).all (Nat.ble 9) = true
kernel_rfl bodyCntM33 : countersOkB PRE_first_tail_x15_r0_body.s332 PRE_first_tail_x15_r0_body.s333 = true
kernel_rfl bodyHi33 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s334.ffi).next setupP.E = true
kernel_rfl bodyNhi33 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s334.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge33 : bridgeOf PRE_first_tail_x15_r0_body.s333.ffi = bridgeOf PRE_first_tail_x15_r0_body.s332.ffi
kernel_rfl bodyNN33 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s332.ffi).nnext PRE_first_tail_x15_r0_body.P33.NL = true
kernel_rfl bodyXn33 : Nat.ble (⟨18869, 15956, 2701335, 1509⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s334.ffi).next = true
kernel_rfl bodyLo33 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s334.ffi).next = true
theorem bodyFacts33 : BodySiteFacts PRE_first_tail_x15_r0_body.s332 PRE_first_tail_x15_r0_body.s333 PRE_first_tail_x15_r0_body.s334 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S332 PRE_first_tail_x15_r0_body.S333 PRE_first_tail_x15_r0_body.S334
    PRE_first_tail_x15_r0_body.ws33 PRE_first_tail_x15_r0_body.cws33 PRE_first_tail_x15_r0_body.nr33 PRE_first_tail_x15_r0_body.pl33 PRE_first_tail_x15_r0_body.cl33 2701685 1509 PRE_first_tail_x15_r0_body.kd33 PRE_first_tail_x15_r0_body.kappa33 PRE_first_tail_x15_r0_body.P33
    ⟨18865, 15950, 2701320, 1500⟩ ⟨18869, 15956, 2701335, 1509⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap33
  clean := bodyClean33
  cfix := PRE_first_tail_x15_r0_body.cfix33
  zpl := PRE_first_tail_x15_r0_body.zpl33
  zplnd := PRE_first_tail_x15_r0_body.zplnd33
  zn1 := PRE_first_tail_x15_r0_body.zn133
  zfirst := PRE_first_tail_x15_r0_body.zfirst33
  zscn := PRE_first_tail_x15_r0_body.zscn33
  zsmn := PRE_first_tail_x15_r0_body.zsmn33
  zgrow := PRE_first_tail_x15_r0_body.zgrow33
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab33
  zfresh := PRE_first_tail_x15_r0_body.zfresh33
  zcnd := PRE_first_tail_x15_r0_body.zcnd33
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi33
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt33
  zgP := PRE_first_tail_x15_r0_body.zg33_2665
  zkP := PRE_first_tail_x15_r0_body.zk33_2665
  zmP := PRE_first_tail_x15_r0_body.zm33_2665
  zgC := PRE_first_tail_x15_r0_body.zg33_2673467
  zkC := PRE_first_tail_x15_r0_body.zk33_2673467
  zmC := PRE_first_tail_x15_r0_body.zm33_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw33_2673472
  zwV := PRE_first_tail_x15_r0_body.zw33_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap33
  zclbd := PRE_first_tail_x15_r0_body.zclbd33
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap33 PRE_first_tail_x15_r0_body.stFoot33 PRE_first_tail_x15_r0_body.iso33 PRE_first_tail_x15_r0_body.zwr33
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP33
  csupp := PRE_first_tail_x15_r0_body.csupp33
  cbound := PRE_first_tail_x15_r0_body.cbound33
  zimg := PRE_first_tail_x15_r0_body.zimg33
  zctl := PRE_first_tail_x15_r0_body.zctl33
  zstack := PRE_first_tail_x15_r0_body.zstack33
  zjobs := PRE_first_tail_x15_r0_body.zjobs33
  zstores := PRE_first_tail_x15_r0_body.zstores33
  zroots := PRE_first_tail_x15_r0_body.zroots33
  znC := PRE_first_tail_x15_r0_body.znC33
  ctab := PRE_first_tail_x15_r0_body.ctab33
  zbin := PRE_first_tail_x15_r0_body.zbin33
  cbridge := PRE_first_tail_x15_r0_body.cbridge33
  sbridge := bodyBridge33
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj33
  cshiftR := fun h hNL => bodyCshift33 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN33
  raised := PRE_first_tail_x15_r0_body.raised33
  cbigs := PRE_first_tail_x15_r0_body.cbigs33
  cjcl := PRE_first_tail_x15_r0_body.cjcl33
  xnLe := Nat.le_of_ble_eq_true bodyXn33
  loLe := Nat.le_of_ble_eq_true bodyLo33
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB33
  cntM := bodyCntM33
  hiLe := Nat.le_of_ble_eq_true bodyHi33
  nhiLe := Nat.le_of_ble_eq_true bodyNhi33
  jsHeap := bodyJs33
  jsRoots := bodyJsRoots33
  jsNative := bodyJsNative33
  framesEmpty := bodyFramesEmpty33
  trailOld := by decide
  lowVars := bodyLow33

def bodyQs33 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs33 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr33.map fun r => nth? PRE_first_tail_x15_r0_body.st33.S3.tab r
kernel_rfl bodyResChk33 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs33 bodyQs33) = true
kernel_rfl bodyLq33 : bodyQs33.length = PRE_first_tail_x15_r0_body.cws33.length
kernel_rfl bodyNrLo33 : PRE_first_tail_x15_r0_body.nr33.all (Nat.ble PRE_first_tail_x15_r0_body.S332.tab.length) = true
kernel_rfl bodySub33 : (Oracles.PRE_first_tail_x15_r0_body.map_site33.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost33 : postSubB bodyM PRE_first_tail_x15_r0_body.ws33 PRE_first_tail_x15_r0_body.cws33 bodyQs33 = true
kernel_rfl bodyDrop33 : Nat.ble (15296 + (PRE_first_tail_x15_r0_body.s333.next - PRE_first_tail_x15_r0_body.s334.next)) 15646 = true
kernel_rfl bodyDropH33 : Nat.ble (250 + ((mlxOf PRE_first_tail_x15_r0_body.s333.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s334.ffi).next)) 252 = true
kernel_rfl bodyDropN33 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s333.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s334.ffi).nnext)) 0 = true
kernel_rfl bodyDv33 : bodyΘ.1.take 189 = bodyΘ.1.take 180 ++ PRE_first_tail_x15_r0_body.cws33
kernel_rfl bodyDe33 : bodyΘ.2.take 189 = bodyΘ.2.take 180 ++ PRE_first_tail_x15_r0_body.nr33.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st33.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 180) (bodyΘ.2.take 180)))
kernel_rfl bodyDl33 : (bodyΘ.1.take 180).length = (bodyΘ.2.take 180).length
kernel_rfl bodyDold33 : (bodyΘ.1.take 180).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws33).isNone && !PRE_first_tail_x15_r0_body.ws33.contains v) = true
kernel_rfl bodyDfree33 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x15_r0_body.cws33 ++ PRE_first_tail_x15_r0_body.ws33).all fun w => e.noVar w) = true

theorem bodyStep33 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15296, 250, 0, 180⟩ bodyM PRE_first_tail_x15_r0_body.s332 PRE_first_tail_x15_r0_body.S332)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15646, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s334 PRE_first_tail_x15_r0_body.S334) (3452 + 1) :=
  bodySite bodyFacts33.cfix bodyFacts33.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st33.S3.tab) (Es := bodyEs33) (qs := bodyQs33)
    (ok := PRE_first_tail_x15_r0_body.st33.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site33 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts33
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site33 r hr) hi (MapOk.sub hm (sub_of_all bodySub33)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk33 r hr) hi hm ho hq)
    bodyLq33 rfl bodyNrLo33 (postSub_sound bodyPost33)
    (Nat.le_of_ble_eq_true bodyDrop33) (by decide) (Nat.le_of_ble_eq_true bodyDropH33) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN33) (by decide)
    bodyDv33 bodyDe33 bodyDl33 bodyDold33 bodyDfree33 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
