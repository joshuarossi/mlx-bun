import host.sim.compose.a4b.vw15.VWBodyJ23
import host.sim.compose.a4b.vw15.VWBodySite23
import host.sim.compose.a4b.vw15.VWBodyOracles_5
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

theorem bodyCshift23 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S229.tab.length PRE_first_tail_x15_r0_body.s229.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P23.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P23 1036 PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.s231.ffi PRE_first_tail_x15_r0_body.s230.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_23
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_23
  have hcl : SSt (· < 1036) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s231.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S229.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_23] <;> decide) PRE_first_tail_x15_r0_body.cnodesK23 PRE_first_tail_x15_r0_body.cobjsK23
      PRE_first_tail_x15_r0_body.citemsK23 PRE_first_tail_x15_r0_body.cbd23 PRE_first_tail_x15_r0_body.csst23
  exact PRE_first_tail_x15_r0_body.cshift23 bodyNcl23 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_23] at this; exact this)


kernel_rfl bodyFramesEmpty23 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s230 a).isEmpty) = true
kernel_rfl bodyJsRoots23 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s229.next) PRE_first_tail_x15_r0_body.s231.trace PRE_first_tail_x15_r0_body.s231 = true
kernel_rfl bodyJsNative23 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s231.ffi) = true
kernel_rfl bodyLow23 : (PRE_first_tail_x15_r0_body.cws23 ++ PRE_first_tail_x15_r0_body.ws23).all (Nat.ble 9) = true
kernel_rfl bodyCntM23 : countersOkB PRE_first_tail_x15_r0_body.s229 PRE_first_tail_x15_r0_body.s230 = true
kernel_rfl bodyHi23 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s231.ffi).next setupP.E = true
kernel_rfl bodyNhi23 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s231.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge23 : bridgeOf PRE_first_tail_x15_r0_body.s230.ffi = bridgeOf PRE_first_tail_x15_r0_body.s229.ffi
kernel_rfl bodyNN23 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s229.ffi).nnext PRE_first_tail_x15_r0_body.P23.NL = true
kernel_rfl bodyXn23 : Nat.ble (⟨18653, 15733, 2692794, 1036⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s231.ffi).next = true
kernel_rfl bodyLo23 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s231.ffi).next = true
theorem bodyFacts23 : BodySiteFacts PRE_first_tail_x15_r0_body.s229 PRE_first_tail_x15_r0_body.s230 PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S229 PRE_first_tail_x15_r0_body.S230 PRE_first_tail_x15_r0_body.S231
    PRE_first_tail_x15_r0_body.ws23 PRE_first_tail_x15_r0_body.cws23 PRE_first_tail_x15_r0_body.nr23 PRE_first_tail_x15_r0_body.pl23 PRE_first_tail_x15_r0_body.cl23 2692804 1036 PRE_first_tail_x15_r0_body.kd23 PRE_first_tail_x15_r0_body.kappa23 PRE_first_tail_x15_r0_body.P23
    ⟨18653, 15733, 2692793, 1036⟩ ⟨18653, 15733, 2692794, 1036⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap23
  clean := bodyClean23
  cfix := PRE_first_tail_x15_r0_body.cfix23
  zpl := PRE_first_tail_x15_r0_body.zpl23
  zplnd := PRE_first_tail_x15_r0_body.zplnd23
  zn1 := PRE_first_tail_x15_r0_body.zn123
  zfirst := PRE_first_tail_x15_r0_body.zfirst23
  zscn := PRE_first_tail_x15_r0_body.zscn23
  zsmn := PRE_first_tail_x15_r0_body.zsmn23
  zgrow := PRE_first_tail_x15_r0_body.zgrow23
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab23
  zfresh := PRE_first_tail_x15_r0_body.zfresh23
  zcnd := PRE_first_tail_x15_r0_body.zcnd23
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi23
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt23
  zgP := PRE_first_tail_x15_r0_body.zg23_2665
  zkP := PRE_first_tail_x15_r0_body.zk23_2665
  zmP := PRE_first_tail_x15_r0_body.zm23_2665
  zgC := PRE_first_tail_x15_r0_body.zg23_2673467
  zkC := PRE_first_tail_x15_r0_body.zk23_2673467
  zmC := PRE_first_tail_x15_r0_body.zm23_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw23_2673472
  zwV := PRE_first_tail_x15_r0_body.zw23_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap23
  zclbd := PRE_first_tail_x15_r0_body.zclbd23
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap23 PRE_first_tail_x15_r0_body.stFoot23 PRE_first_tail_x15_r0_body.iso23 PRE_first_tail_x15_r0_body.zwr23
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP23
  csupp := PRE_first_tail_x15_r0_body.csupp23
  cbound := PRE_first_tail_x15_r0_body.cbound23
  zimg := PRE_first_tail_x15_r0_body.zimg23
  zctl := PRE_first_tail_x15_r0_body.zctl23
  zstack := PRE_first_tail_x15_r0_body.zstack23
  zjobs := PRE_first_tail_x15_r0_body.zjobs23
  zstores := PRE_first_tail_x15_r0_body.zstores23
  zroots := PRE_first_tail_x15_r0_body.zroots23
  znC := PRE_first_tail_x15_r0_body.znC23
  ctab := PRE_first_tail_x15_r0_body.ctab23
  zbin := PRE_first_tail_x15_r0_body.zbin23
  cbridge := PRE_first_tail_x15_r0_body.cbridge23
  sbridge := bodyBridge23
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj23
  cshiftR := fun h hNL => bodyCshift23 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN23
  raised := PRE_first_tail_x15_r0_body.raised23
  cbigs := PRE_first_tail_x15_r0_body.cbigs23
  cjcl := PRE_first_tail_x15_r0_body.cjcl23
  xnLe := Nat.le_of_ble_eq_true bodyXn23
  loLe := Nat.le_of_ble_eq_true bodyLo23
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB23
  cntM := bodyCntM23
  hiLe := Nat.le_of_ble_eq_true bodyHi23
  nhiLe := Nat.le_of_ble_eq_true bodyNhi23
  jsHeap := bodyJs23
  jsRoots := bodyJsRoots23
  jsNative := bodyJsNative23
  framesEmpty := bodyFramesEmpty23
  trailOld := by decide
  lowVars := bodyLow23

def bodyQs23 : List (Option Q) := []
noncomputable def bodyEs23 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr23.map fun r => nth? PRE_first_tail_x15_r0_body.st23.S2.tab r
kernel_rfl bodyResChk23 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs23 bodyQs23) = true
kernel_rfl bodyLq23 : bodyQs23.length = PRE_first_tail_x15_r0_body.cws23.length
kernel_rfl bodyNrLo23 : PRE_first_tail_x15_r0_body.nr23.all (Nat.ble PRE_first_tail_x15_r0_body.S229.tab.length) = true
kernel_rfl bodySub23 : (Oracles.PRE_first_tail_x15_r0_body.map_site23.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost23 : postSubB bodyM PRE_first_tail_x15_r0_body.ws23 PRE_first_tail_x15_r0_body.cws23 bodyQs23 = true
kernel_rfl bodyDrop23 : Nat.ble (11803 + (PRE_first_tail_x15_r0_body.s230.next - PRE_first_tail_x15_r0_body.s231.next)) 11813 = true
kernel_rfl bodyDropH23 : Nat.ble (175 + ((mlxOf PRE_first_tail_x15_r0_body.s230.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s231.ffi).next)) 175 = true
kernel_rfl bodyDropN23 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s230.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s231.ffi).nnext)) 0 = true
kernel_rfl bodyDv23 : bodyΘ.1.take 126 = bodyΘ.1.take 126 ++ PRE_first_tail_x15_r0_body.cws23
kernel_rfl bodyDe23 : bodyΘ.2.take 126 = bodyΘ.2.take 126 ++ PRE_first_tail_x15_r0_body.nr23.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st23.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 126) (bodyΘ.2.take 126)))
kernel_rfl bodyDl23 : (bodyΘ.1.take 126).length = (bodyΘ.2.take 126).length
kernel_rfl bodyDold23 : (bodyΘ.1.take 126).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws23).isNone && !PRE_first_tail_x15_r0_body.ws23.contains v) = true
kernel_rfl bodyDfree23 : (bodyΘ.2.take 126).all (fun e => (PRE_first_tail_x15_r0_body.cws23 ++ PRE_first_tail_x15_r0_body.ws23).all fun w => e.noVar w) = true

theorem bodyStep23 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11803, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s229 PRE_first_tail_x15_r0_body.S229)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11813, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s231 PRE_first_tail_x15_r0_body.S231) (98 + 1) :=
  bodySite bodyFacts23.cfix bodyFacts23.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st23.S2.tab) (Es := bodyEs23) (qs := bodyQs23)
    (ok := PRE_first_tail_x15_r0_body.st23.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site23 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts23
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site23 r hr) hi (MapOk.sub hm (sub_of_all bodySub23)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk23 r hr) hi hm ho hq)
    bodyLq23 rfl bodyNrLo23 (postSub_sound bodyPost23)
    (Nat.le_of_ble_eq_true bodyDrop23) (by decide) (Nat.le_of_ble_eq_true bodyDropH23) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN23) (by decide)
    bodyDv23 bodyDe23 bodyDl23 bodyDold23 bodyDfree23 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
