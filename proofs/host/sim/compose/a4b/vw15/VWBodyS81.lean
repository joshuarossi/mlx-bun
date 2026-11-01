import host.sim.compose.a4b.vw15.VWBodyJ81
import host.sim.compose.a4b.vw15.VWBodySite81
import host.sim.compose.a4b.vw15.VWBodyOracles_20
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift81 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S792.tab.length PRE_first_tail_x15_r0_body.s792.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P81.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P81 3561 PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.s794.ffi PRE_first_tail_x15_r0_body.s793.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_81
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_81
  have hcl : SSt (· < 3561) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s794.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S792.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_81] <;> decide) PRE_first_tail_x15_r0_body.cnodesK81 PRE_first_tail_x15_r0_body.cobjsK81
      PRE_first_tail_x15_r0_body.citemsK81 PRE_first_tail_x15_r0_body.cbd81 PRE_first_tail_x15_r0_body.csst81
  exact PRE_first_tail_x15_r0_body.cshift81 bodyNcl81 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_81] at this; exact this)


kernel_rfl bodyFramesEmpty81 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s793 a).isEmpty) = true
kernel_rfl bodyJsRoots81 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s792.next) PRE_first_tail_x15_r0_body.s794.trace PRE_first_tail_x15_r0_body.s794 = true
kernel_rfl bodyJsNative81 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s794.ffi) = true
kernel_rfl bodyLow81 : (PRE_first_tail_x15_r0_body.cws81 ++ PRE_first_tail_x15_r0_body.ws81).all (Nat.ble 9) = true
kernel_rfl bodyCntM81 : countersOkB PRE_first_tail_x15_r0_body.s792 PRE_first_tail_x15_r0_body.s793 = true
kernel_rfl bodyHi81 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s794.ffi).next setupP.E = true
kernel_rfl bodyNhi81 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s794.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge81 : bridgeOf PRE_first_tail_x15_r0_body.s793.ffi = bridgeOf PRE_first_tail_x15_r0_body.s792.ffi
kernel_rfl bodyNN81 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s792.ffi).nnext PRE_first_tail_x15_r0_body.P81.NL = true
kernel_rfl bodyXn81 : Nat.ble (⟨19813, 16904, 2739007, 3561⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s794.ffi).next = true
kernel_rfl bodyLo81 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s794.ffi).next = true
theorem bodyFacts81 : BodySiteFacts PRE_first_tail_x15_r0_body.s792 PRE_first_tail_x15_r0_body.s793 PRE_first_tail_x15_r0_body.s794 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S792 PRE_first_tail_x15_r0_body.S793 PRE_first_tail_x15_r0_body.S794
    PRE_first_tail_x15_r0_body.ws81 PRE_first_tail_x15_r0_body.cws81 PRE_first_tail_x15_r0_body.nr81 PRE_first_tail_x15_r0_body.pl81 PRE_first_tail_x15_r0_body.cl81 2739357 3561 PRE_first_tail_x15_r0_body.kd81 PRE_first_tail_x15_r0_body.kappa81 PRE_first_tail_x15_r0_body.P81
    ⟨19809, 16898, 2738992, 3552⟩ ⟨19813, 16904, 2739007, 3561⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap81
  clean := bodyClean81
  cfix := PRE_first_tail_x15_r0_body.cfix81
  zpl := PRE_first_tail_x15_r0_body.zpl81
  zplnd := PRE_first_tail_x15_r0_body.zplnd81
  zn1 := PRE_first_tail_x15_r0_body.zn181
  zfirst := PRE_first_tail_x15_r0_body.zfirst81
  zscn := PRE_first_tail_x15_r0_body.zscn81
  zsmn := PRE_first_tail_x15_r0_body.zsmn81
  zgrow := PRE_first_tail_x15_r0_body.zgrow81
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab81
  zfresh := PRE_first_tail_x15_r0_body.zfresh81
  zcnd := PRE_first_tail_x15_r0_body.zcnd81
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi81
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt81
  zgP := PRE_first_tail_x15_r0_body.zg81_2665
  zkP := PRE_first_tail_x15_r0_body.zk81_2665
  zmP := PRE_first_tail_x15_r0_body.zm81_2665
  zgC := PRE_first_tail_x15_r0_body.zg81_2673467
  zkC := PRE_first_tail_x15_r0_body.zk81_2673467
  zmC := PRE_first_tail_x15_r0_body.zm81_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw81_2673472
  zwV := PRE_first_tail_x15_r0_body.zw81_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap81
  zclbd := PRE_first_tail_x15_r0_body.zclbd81
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap81 PRE_first_tail_x15_r0_body.stFoot81 PRE_first_tail_x15_r0_body.iso81 PRE_first_tail_x15_r0_body.zwr81
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP81
  csupp := PRE_first_tail_x15_r0_body.csupp81
  cbound := PRE_first_tail_x15_r0_body.cbound81
  zimg := PRE_first_tail_x15_r0_body.zimg81
  zctl := PRE_first_tail_x15_r0_body.zctl81
  zstack := PRE_first_tail_x15_r0_body.zstack81
  zjobs := PRE_first_tail_x15_r0_body.zjobs81
  zstores := PRE_first_tail_x15_r0_body.zstores81
  zroots := PRE_first_tail_x15_r0_body.zroots81
  znC := PRE_first_tail_x15_r0_body.znC81
  ctab := PRE_first_tail_x15_r0_body.ctab81
  zbin := PRE_first_tail_x15_r0_body.zbin81
  cbridge := PRE_first_tail_x15_r0_body.cbridge81
  sbridge := bodyBridge81
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj81
  cshiftR := fun h hNL => bodyCshift81 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN81
  raised := PRE_first_tail_x15_r0_body.raised81
  cbigs := PRE_first_tail_x15_r0_body.cbigs81
  cjcl := PRE_first_tail_x15_r0_body.cjcl81
  xnLe := Nat.le_of_ble_eq_true bodyXn81
  loLe := Nat.le_of_ble_eq_true bodyLo81
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB81
  cntM := bodyCntM81
  hiLe := Nat.le_of_ble_eq_true bodyHi81
  nhiLe := Nat.le_of_ble_eq_true bodyNhi81
  jsHeap := bodyJs81
  jsRoots := bodyJsRoots81
  jsNative := bodyJsNative81
  framesEmpty := bodyFramesEmpty81
  trailOld := by decide
  lowVars := bodyLow81

def bodyQs81 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs81 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr81.map fun r => nth? PRE_first_tail_x15_r0_body.st81.S3.tab r
kernel_rfl bodyResChk81 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs81 bodyQs81) = true
kernel_rfl bodyLq81 : bodyQs81.length = PRE_first_tail_x15_r0_body.cws81.length
kernel_rfl bodyNrLo81 : PRE_first_tail_x15_r0_body.nr81.all (Nat.ble PRE_first_tail_x15_r0_body.S792.tab.length) = true
kernel_rfl bodySub81 : (Oracles.PRE_first_tail_x15_r0_body.map_site81.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost81 : postSubB bodyM PRE_first_tail_x15_r0_body.ws81 PRE_first_tail_x15_r0_body.cws81 bodyQs81 = true
kernel_rfl bodyDrop81 : Nat.ble (30730 + (PRE_first_tail_x15_r0_body.s793.next - PRE_first_tail_x15_r0_body.s794.next)) 31080 = true
kernel_rfl bodyDropH81 : Nat.ble (558 + ((mlxOf PRE_first_tail_x15_r0_body.s793.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s794.ffi).next)) 560 = true
kernel_rfl bodyDropN81 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s793.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s794.ffi).nnext)) 0 = true
kernel_rfl bodyDv81 : bodyΘ.1.take 441 = bodyΘ.1.take 432 ++ PRE_first_tail_x15_r0_body.cws81
kernel_rfl bodyDe81 : bodyΘ.2.take 441 = bodyΘ.2.take 432 ++ PRE_first_tail_x15_r0_body.nr81.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st81.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 432) (bodyΘ.2.take 432)))
kernel_rfl bodyDl81 : (bodyΘ.1.take 432).length = (bodyΘ.2.take 432).length
kernel_rfl bodyDold81 : (bodyΘ.1.take 432).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws81).isNone && !PRE_first_tail_x15_r0_body.ws81.contains v) = true
kernel_rfl bodyDfree81 : (bodyΘ.2.take 441).all (fun e => (PRE_first_tail_x15_r0_body.cws81 ++ PRE_first_tail_x15_r0_body.ws81).all fun w => e.noVar w) = true

theorem bodyStep81 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30730, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s792 PRE_first_tail_x15_r0_body.S792)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31080, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s794 PRE_first_tail_x15_r0_body.S794) (3452 + 1) :=
  bodySite bodyFacts81.cfix bodyFacts81.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st81.S3.tab) (Es := bodyEs81) (qs := bodyQs81)
    (ok := PRE_first_tail_x15_r0_body.st81.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site81 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts81
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site81 r hr) hi (MapOk.sub hm (sub_of_all bodySub81)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk81 r hr) hi hm ho hq)
    bodyLq81 rfl bodyNrLo81 (postSub_sound bodyPost81)
    (Nat.le_of_ble_eq_true bodyDrop81) (by decide) (Nat.le_of_ble_eq_true bodyDropH81) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN81) (by decide)
    bodyDv81 bodyDe81 bodyDl81 bodyDold81 bodyDfree81 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
