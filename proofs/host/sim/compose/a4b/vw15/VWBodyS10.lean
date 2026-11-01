import host.sim.compose.a4b.vw15.VWBodyJ10
import host.sim.compose.a4b.vw15.VWBodySite10
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

theorem bodyCshift10 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S110.tab.length PRE_first_tail_x15_r0_body.s110.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P10.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P10 506 PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.s112.ffi PRE_first_tail_x15_r0_body.s111.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_10
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_10
  have hcl : SSt (· < 506) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s112.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S110.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_10] <;> decide) PRE_first_tail_x15_r0_body.cnodesK10 PRE_first_tail_x15_r0_body.cobjsK10
      PRE_first_tail_x15_r0_body.citemsK10 PRE_first_tail_x15_r0_body.cbd10 PRE_first_tail_x15_r0_body.csst10
  exact PRE_first_tail_x15_r0_body.cshift10 bodyNcl10 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_10] at this; exact this)


kernel_rfl bodyFramesEmpty10 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s111 a).isEmpty) = true
kernel_rfl bodyJsRoots10 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s110.next) PRE_first_tail_x15_r0_body.s112.trace PRE_first_tail_x15_r0_body.s112 = true
kernel_rfl bodyJsNative10 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s112.ffi) = true
kernel_rfl bodyLow10 : (PRE_first_tail_x15_r0_body.cws10 ++ PRE_first_tail_x15_r0_body.ws10).all (Nat.ble 9) = true
kernel_rfl bodyCntM10 : countersOkB PRE_first_tail_x15_r0_body.s110 PRE_first_tail_x15_r0_body.s111 = true
kernel_rfl bodyHi10 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s112.ffi).next setupP.E = true
kernel_rfl bodyNhi10 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s112.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge10 : bridgeOf PRE_first_tail_x15_r0_body.s111.ffi = bridgeOf PRE_first_tail_x15_r0_body.s110.ffi
kernel_rfl bodyNN10 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s110.ffi).nnext PRE_first_tail_x15_r0_body.P10.NL = true
kernel_rfl bodyXn10 : Nat.ble (⟨18410, 15492, 2683093, 506⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s112.ffi).next = true
kernel_rfl bodyLo10 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s112.ffi).next = true
theorem bodyFacts10 : BodySiteFacts PRE_first_tail_x15_r0_body.s110 PRE_first_tail_x15_r0_body.s111 PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S110 PRE_first_tail_x15_r0_body.S111 PRE_first_tail_x15_r0_body.S112
    PRE_first_tail_x15_r0_body.ws10 PRE_first_tail_x15_r0_body.cws10 PRE_first_tail_x15_r0_body.nr10 PRE_first_tail_x15_r0_body.pl10 PRE_first_tail_x15_r0_body.cl10 2683095 506 PRE_first_tail_x15_r0_body.kd10 PRE_first_tail_x15_r0_body.kappa10 PRE_first_tail_x15_r0_body.P10
    ⟨18410, 15492, 2683093, 506⟩ ⟨18410, 15492, 2683093, 506⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap10
  clean := bodyClean10
  cfix := PRE_first_tail_x15_r0_body.cfix10
  zpl := PRE_first_tail_x15_r0_body.zpl10
  zplnd := PRE_first_tail_x15_r0_body.zplnd10
  zn1 := PRE_first_tail_x15_r0_body.zn110
  zfirst := PRE_first_tail_x15_r0_body.zfirst10
  zscn := PRE_first_tail_x15_r0_body.zscn10
  zsmn := PRE_first_tail_x15_r0_body.zsmn10
  zgrow := PRE_first_tail_x15_r0_body.zgrow10
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab10
  zfresh := PRE_first_tail_x15_r0_body.zfresh10
  zcnd := PRE_first_tail_x15_r0_body.zcnd10
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi10
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt10
  zgP := PRE_first_tail_x15_r0_body.zg10_2665
  zkP := PRE_first_tail_x15_r0_body.zk10_2665
  zmP := PRE_first_tail_x15_r0_body.zm10_2665
  zgC := PRE_first_tail_x15_r0_body.zg10_2673467
  zkC := PRE_first_tail_x15_r0_body.zk10_2673467
  zmC := PRE_first_tail_x15_r0_body.zm10_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw10_2673472
  zwV := PRE_first_tail_x15_r0_body.zw10_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap10
  zclbd := PRE_first_tail_x15_r0_body.zclbd10
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap10 PRE_first_tail_x15_r0_body.stFoot10 PRE_first_tail_x15_r0_body.iso10 PRE_first_tail_x15_r0_body.zwr10
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP10
  csupp := PRE_first_tail_x15_r0_body.csupp10
  cbound := PRE_first_tail_x15_r0_body.cbound10
  zimg := PRE_first_tail_x15_r0_body.zimg10
  zctl := PRE_first_tail_x15_r0_body.zctl10
  zstack := PRE_first_tail_x15_r0_body.zstack10
  zjobs := PRE_first_tail_x15_r0_body.zjobs10
  zstores := PRE_first_tail_x15_r0_body.zstores10
  zroots := PRE_first_tail_x15_r0_body.zroots10
  znC := PRE_first_tail_x15_r0_body.znC10
  ctab := PRE_first_tail_x15_r0_body.ctab10
  zbin := PRE_first_tail_x15_r0_body.zbin10
  cbridge := PRE_first_tail_x15_r0_body.cbridge10
  sbridge := bodyBridge10
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj10
  cshiftR := fun h hNL => bodyCshift10 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN10
  raised := PRE_first_tail_x15_r0_body.raised10
  cbigs := PRE_first_tail_x15_r0_body.cbigs10
  cjcl := PRE_first_tail_x15_r0_body.cjcl10
  xnLe := Nat.le_of_ble_eq_true bodyXn10
  loLe := Nat.le_of_ble_eq_true bodyLo10
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB10
  cntM := bodyCntM10
  hiLe := Nat.le_of_ble_eq_true bodyHi10
  nhiLe := Nat.le_of_ble_eq_true bodyNhi10
  jsHeap := bodyJs10
  jsRoots := bodyJsRoots10
  jsNative := bodyJsNative10
  framesEmpty := bodyFramesEmpty10
  trailOld := by decide
  lowVars := bodyLow10

def bodyQs10 : List (Option Q) := []
noncomputable def bodyEs10 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr10.map fun r => nth? PRE_first_tail_x15_r0_body.st10.S2.tab r
kernel_rfl bodyResChk10 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs10 bodyQs10) = true
kernel_rfl bodyLq10 : bodyQs10.length = PRE_first_tail_x15_r0_body.cws10.length
kernel_rfl bodyNrLo10 : PRE_first_tail_x15_r0_body.nr10.all (Nat.ble PRE_first_tail_x15_r0_body.S110.tab.length) = true
kernel_rfl bodySub10 : (Oracles.PRE_first_tail_x15_r0_body.map_site10.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost10 : postSubB bodyM PRE_first_tail_x15_r0_body.ws10 PRE_first_tail_x15_r0_body.cws10 bodyQs10 = true
kernel_rfl bodyDrop10 : Nat.ble (7956 + (PRE_first_tail_x15_r0_body.s111.next - PRE_first_tail_x15_r0_body.s112.next)) 7958 = true
kernel_rfl bodyDropH10 : Nat.ble (98 + ((mlxOf PRE_first_tail_x15_r0_body.s111.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s112.ffi).next)) 98 = true
kernel_rfl bodyDropN10 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s111.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s112.ffi).nnext)) 0 = true
kernel_rfl bodyDv10 : bodyΘ.1.take 63 = bodyΘ.1.take 63 ++ PRE_first_tail_x15_r0_body.cws10
kernel_rfl bodyDe10 : bodyΘ.2.take 63 = bodyΘ.2.take 63 ++ PRE_first_tail_x15_r0_body.nr10.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st10.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 63) (bodyΘ.2.take 63)))
kernel_rfl bodyDl10 : (bodyΘ.1.take 63).length = (bodyΘ.2.take 63).length
kernel_rfl bodyDold10 : (bodyΘ.1.take 63).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws10).isNone && !PRE_first_tail_x15_r0_body.ws10.contains v) = true
kernel_rfl bodyDfree10 : (bodyΘ.2.take 63).all (fun e => (PRE_first_tail_x15_r0_body.cws10 ++ PRE_first_tail_x15_r0_body.ws10).all fun w => e.noVar w) = true

theorem bodyStep10 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s110 PRE_first_tail_x15_r0_body.S110)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7958, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.S112) (27 + 1) :=
  bodySite bodyFacts10.cfix bodyFacts10.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st10.S2.tab) (Es := bodyEs10) (qs := bodyQs10)
    (ok := PRE_first_tail_x15_r0_body.st10.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site10 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts10
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site10 r hr) hi (MapOk.sub hm (sub_of_all bodySub10)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk10 r hr) hi hm ho hq)
    bodyLq10 rfl bodyNrLo10 (postSub_sound bodyPost10)
    (Nat.le_of_ble_eq_true bodyDrop10) (by decide) (Nat.le_of_ble_eq_true bodyDropH10) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN10) (by decide)
    bodyDv10 bodyDe10 bodyDl10 bodyDold10 bodyDfree10 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
