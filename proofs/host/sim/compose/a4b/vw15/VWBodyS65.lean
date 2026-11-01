import host.sim.compose.a4b.vw15.VWBodyJ65
import host.sim.compose.a4b.vw15.VWBodySite65
import host.sim.compose.a4b.vw15.VWBodyOracles_16
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift65 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S632.tab.length PRE_first_tail_x15_r0_body.s632.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P65.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P65 2833 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.s634.ffi PRE_first_tail_x15_r0_body.s633.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_65
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_65
  have hcl : SSt (· < 2833) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s634.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S632.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_65] <;> decide) PRE_first_tail_x15_r0_body.cnodesK65 PRE_first_tail_x15_r0_body.cobjsK65
      PRE_first_tail_x15_r0_body.citemsK65 PRE_first_tail_x15_r0_body.cbd65 PRE_first_tail_x15_r0_body.csst65
  exact PRE_first_tail_x15_r0_body.cshift65 bodyNcl65 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_65] at this; exact this)


kernel_rfl bodyFramesEmpty65 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s633 a).isEmpty) = true
kernel_rfl bodyJsRoots65 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s632.next) PRE_first_tail_x15_r0_body.s634.trace PRE_first_tail_x15_r0_body.s634 = true
kernel_rfl bodyJsNative65 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s634.ffi) = true
kernel_rfl bodyLow65 : (PRE_first_tail_x15_r0_body.cws65 ++ PRE_first_tail_x15_r0_body.ws65).all (Nat.ble 9) = true
kernel_rfl bodyCntM65 : countersOkB PRE_first_tail_x15_r0_body.s632 PRE_first_tail_x15_r0_body.s633 = true
kernel_rfl bodyHi65 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s634.ffi).next setupP.E = true
kernel_rfl bodyNhi65 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s634.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge65 : bridgeOf PRE_first_tail_x15_r0_body.s633.ffi = bridgeOf PRE_first_tail_x15_r0_body.s632.ffi
kernel_rfl bodyNN65 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s632.ffi).nnext PRE_first_tail_x15_r0_body.P65.NL = true
kernel_rfl bodyXn65 : Nat.ble (⟨19476, 16570, 2725588, 2833⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s634.ffi).next = true
kernel_rfl bodyLo65 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s634.ffi).next = true
theorem bodyFacts65 : BodySiteFacts PRE_first_tail_x15_r0_body.s632 PRE_first_tail_x15_r0_body.s633 PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S632 PRE_first_tail_x15_r0_body.S633 PRE_first_tail_x15_r0_body.S634
    PRE_first_tail_x15_r0_body.ws65 PRE_first_tail_x15_r0_body.cws65 PRE_first_tail_x15_r0_body.nr65 PRE_first_tail_x15_r0_body.pl65 PRE_first_tail_x15_r0_body.cl65 2725598 2833 PRE_first_tail_x15_r0_body.kd65 PRE_first_tail_x15_r0_body.kappa65 PRE_first_tail_x15_r0_body.P65
    ⟨19476, 16570, 2725587, 2833⟩ ⟨19476, 16570, 2725588, 2833⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap65
  clean := bodyClean65
  cfix := PRE_first_tail_x15_r0_body.cfix65
  zpl := PRE_first_tail_x15_r0_body.zpl65
  zplnd := PRE_first_tail_x15_r0_body.zplnd65
  zn1 := PRE_first_tail_x15_r0_body.zn165
  zfirst := PRE_first_tail_x15_r0_body.zfirst65
  zscn := PRE_first_tail_x15_r0_body.zscn65
  zsmn := PRE_first_tail_x15_r0_body.zsmn65
  zgrow := PRE_first_tail_x15_r0_body.zgrow65
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab65
  zfresh := PRE_first_tail_x15_r0_body.zfresh65
  zcnd := PRE_first_tail_x15_r0_body.zcnd65
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi65
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt65
  zgP := PRE_first_tail_x15_r0_body.zg65_2665
  zkP := PRE_first_tail_x15_r0_body.zk65_2665
  zmP := PRE_first_tail_x15_r0_body.zm65_2665
  zgC := PRE_first_tail_x15_r0_body.zg65_2673467
  zkC := PRE_first_tail_x15_r0_body.zk65_2673467
  zmC := PRE_first_tail_x15_r0_body.zm65_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw65_2673472
  zwV := PRE_first_tail_x15_r0_body.zw65_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap65
  zclbd := PRE_first_tail_x15_r0_body.zclbd65
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap65 PRE_first_tail_x15_r0_body.stFoot65 PRE_first_tail_x15_r0_body.iso65 PRE_first_tail_x15_r0_body.zwr65
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP65
  csupp := PRE_first_tail_x15_r0_body.csupp65
  cbound := PRE_first_tail_x15_r0_body.cbound65
  zimg := PRE_first_tail_x15_r0_body.zimg65
  zctl := PRE_first_tail_x15_r0_body.zctl65
  zstack := PRE_first_tail_x15_r0_body.zstack65
  zjobs := PRE_first_tail_x15_r0_body.zjobs65
  zstores := PRE_first_tail_x15_r0_body.zstores65
  zroots := PRE_first_tail_x15_r0_body.zroots65
  znC := PRE_first_tail_x15_r0_body.znC65
  ctab := PRE_first_tail_x15_r0_body.ctab65
  zbin := PRE_first_tail_x15_r0_body.zbin65
  cbridge := PRE_first_tail_x15_r0_body.cbridge65
  sbridge := bodyBridge65
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj65
  cshiftR := fun h hNL => bodyCshift65 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN65
  raised := PRE_first_tail_x15_r0_body.raised65
  cbigs := PRE_first_tail_x15_r0_body.cbigs65
  cjcl := PRE_first_tail_x15_r0_body.cjcl65
  xnLe := Nat.le_of_ble_eq_true bodyXn65
  loLe := Nat.le_of_ble_eq_true bodyLo65
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB65
  cntM := bodyCntM65
  hiLe := Nat.le_of_ble_eq_true bodyHi65
  nhiLe := Nat.le_of_ble_eq_true bodyNhi65
  jsHeap := bodyJs65
  jsRoots := bodyJsRoots65
  jsNative := bodyJsNative65
  framesEmpty := bodyFramesEmpty65
  trailOld := by decide
  lowVars := bodyLow65

def bodyQs65 : List (Option Q) := []
noncomputable def bodyEs65 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr65.map fun r => nth? PRE_first_tail_x15_r0_body.st65.S2.tab r
kernel_rfl bodyResChk65 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs65 bodyQs65) = true
kernel_rfl bodyLq65 : bodyQs65.length = PRE_first_tail_x15_r0_body.cws65.length
kernel_rfl bodyNrLo65 : PRE_first_tail_x15_r0_body.nr65.all (Nat.ble PRE_first_tail_x15_r0_body.S632.tab.length) = true
kernel_rfl bodySub65 : (Oracles.PRE_first_tail_x15_r0_body.map_site65.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost65 : postSubB bodyM PRE_first_tail_x15_r0_body.ws65 PRE_first_tail_x15_r0_body.cws65 bodyQs65 = true
kernel_rfl bodyDrop65 : Nat.ble (25714 + (PRE_first_tail_x15_r0_body.s633.next - PRE_first_tail_x15_r0_body.s634.next)) 25724 = true
kernel_rfl bodyDropH65 : Nat.ble (456 + ((mlxOf PRE_first_tail_x15_r0_body.s633.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s634.ffi).next)) 456 = true
kernel_rfl bodyDropN65 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s633.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s634.ffi).nnext)) 0 = true
kernel_rfl bodyDv65 : bodyΘ.1.take 351 = bodyΘ.1.take 351 ++ PRE_first_tail_x15_r0_body.cws65
kernel_rfl bodyDe65 : bodyΘ.2.take 351 = bodyΘ.2.take 351 ++ PRE_first_tail_x15_r0_body.nr65.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st65.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 351) (bodyΘ.2.take 351)))
kernel_rfl bodyDl65 : (bodyΘ.1.take 351).length = (bodyΘ.2.take 351).length
kernel_rfl bodyDold65 : (bodyΘ.1.take 351).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws65).isNone && !PRE_first_tail_x15_r0_body.ws65.contains v) = true
kernel_rfl bodyDfree65 : (bodyΘ.2.take 351).all (fun e => (PRE_first_tail_x15_r0_body.cws65 ++ PRE_first_tail_x15_r0_body.ws65).all fun w => e.noVar w) = true

theorem bodyStep65 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨25714, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s632 PRE_first_tail_x15_r0_body.S632)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25724, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s634 PRE_first_tail_x15_r0_body.S634) (98 + 1) :=
  bodySite bodyFacts65.cfix bodyFacts65.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st65.S2.tab) (Es := bodyEs65) (qs := bodyQs65)
    (ok := PRE_first_tail_x15_r0_body.st65.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site65 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts65
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site65 r hr) hi (MapOk.sub hm (sub_of_all bodySub65)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk65 r hr) hi hm ho hq)
    bodyLq65 rfl bodyNrLo65 (postSub_sound bodyPost65)
    (Nat.le_of_ble_eq_true bodyDrop65) (by decide) (Nat.le_of_ble_eq_true bodyDropH65) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN65) (by decide)
    bodyDv65 bodyDe65 bodyDl65 bodyDold65 bodyDfree65 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
