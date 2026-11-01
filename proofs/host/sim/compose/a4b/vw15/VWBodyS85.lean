import host.sim.compose.a4b.vw15.VWBodyJ85
import host.sim.compose.a4b.vw15.VWBodySite85
import host.sim.compose.a4b.vw15.VWBodyOracles_21
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

theorem bodyCshift85 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S829.tab.length PRE_first_tail_x15_r0_body.s829.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P85.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P85 3713 PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.s831.ffi PRE_first_tail_x15_r0_body.s830.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_85
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_85
  have hcl : SSt (· < 3713) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S829.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_85] <;> decide) PRE_first_tail_x15_r0_body.cnodesK85 PRE_first_tail_x15_r0_body.cobjsK85
      PRE_first_tail_x15_r0_body.citemsK85 PRE_first_tail_x15_r0_body.cbd85 PRE_first_tail_x15_r0_body.csst85
  exact PRE_first_tail_x15_r0_body.cshift85 bodyNcl85 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_85] at this; exact this)


kernel_rfl bodyFramesEmpty85 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s830 a).isEmpty) = true
kernel_rfl bodyJsRoots85 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s829.next) PRE_first_tail_x15_r0_body.s831.trace PRE_first_tail_x15_r0_body.s831 = true
kernel_rfl bodyJsNative85 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s831.ffi) = true
kernel_rfl bodyLow85 : (PRE_first_tail_x15_r0_body.cws85 ++ PRE_first_tail_x15_r0_body.ws85).all (Nat.ble 9) = true
kernel_rfl bodyCntM85 : countersOkB PRE_first_tail_x15_r0_body.s829 PRE_first_tail_x15_r0_body.s830 = true
kernel_rfl bodyHi85 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s831.ffi).next setupP.E = true
kernel_rfl bodyNhi85 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s831.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge85 : bridgeOf PRE_first_tail_x15_r0_body.s830.ffi = bridgeOf PRE_first_tail_x15_r0_body.s829.ffi
kernel_rfl bodyNN85 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s829.ffi).nnext PRE_first_tail_x15_r0_body.P85.NL = true
kernel_rfl bodyXn85 : Nat.ble (⟨19884, 16977, 2741867, 3713⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s831.ffi).next = true
kernel_rfl bodyLo85 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s831.ffi).next = true
theorem bodyFacts85 : BodySiteFacts PRE_first_tail_x15_r0_body.s829 PRE_first_tail_x15_r0_body.s830 PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S829 PRE_first_tail_x15_r0_body.S830 PRE_first_tail_x15_r0_body.S831
    PRE_first_tail_x15_r0_body.ws85 PRE_first_tail_x15_r0_body.cws85 PRE_first_tail_x15_r0_body.nr85 PRE_first_tail_x15_r0_body.pl85 PRE_first_tail_x15_r0_body.cl85 2741869 3713 PRE_first_tail_x15_r0_body.kd85 PRE_first_tail_x15_r0_body.kappa85 PRE_first_tail_x15_r0_body.P85
    ⟨19884, 16977, 2741867, 3713⟩ ⟨19884, 16977, 2741867, 3713⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap85
  clean := bodyClean85
  cfix := PRE_first_tail_x15_r0_body.cfix85
  zpl := PRE_first_tail_x15_r0_body.zpl85
  zplnd := PRE_first_tail_x15_r0_body.zplnd85
  zn1 := PRE_first_tail_x15_r0_body.zn185
  zfirst := PRE_first_tail_x15_r0_body.zfirst85
  zscn := PRE_first_tail_x15_r0_body.zscn85
  zsmn := PRE_first_tail_x15_r0_body.zsmn85
  zgrow := PRE_first_tail_x15_r0_body.zgrow85
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab85
  zfresh := PRE_first_tail_x15_r0_body.zfresh85
  zcnd := PRE_first_tail_x15_r0_body.zcnd85
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi85
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt85
  zgP := PRE_first_tail_x15_r0_body.zg85_2665
  zkP := PRE_first_tail_x15_r0_body.zk85_2665
  zmP := PRE_first_tail_x15_r0_body.zm85_2665
  zgC := PRE_first_tail_x15_r0_body.zg85_2673467
  zkC := PRE_first_tail_x15_r0_body.zk85_2673467
  zmC := PRE_first_tail_x15_r0_body.zm85_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw85_2673472
  zwV := PRE_first_tail_x15_r0_body.zw85_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap85
  zclbd := PRE_first_tail_x15_r0_body.zclbd85
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap85 PRE_first_tail_x15_r0_body.stFoot85 PRE_first_tail_x15_r0_body.iso85 PRE_first_tail_x15_r0_body.zwr85
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP85
  csupp := PRE_first_tail_x15_r0_body.csupp85
  cbound := PRE_first_tail_x15_r0_body.cbound85
  zimg := PRE_first_tail_x15_r0_body.zimg85
  zctl := PRE_first_tail_x15_r0_body.zctl85
  zstack := PRE_first_tail_x15_r0_body.zstack85
  zjobs := PRE_first_tail_x15_r0_body.zjobs85
  zstores := PRE_first_tail_x15_r0_body.zstores85
  zroots := PRE_first_tail_x15_r0_body.zroots85
  znC := PRE_first_tail_x15_r0_body.znC85
  ctab := PRE_first_tail_x15_r0_body.ctab85
  zbin := PRE_first_tail_x15_r0_body.zbin85
  cbridge := PRE_first_tail_x15_r0_body.cbridge85
  sbridge := bodyBridge85
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj85
  cshiftR := fun h hNL => bodyCshift85 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN85
  raised := PRE_first_tail_x15_r0_body.raised85
  cbigs := PRE_first_tail_x15_r0_body.cbigs85
  cjcl := PRE_first_tail_x15_r0_body.cjcl85
  xnLe := Nat.le_of_ble_eq_true bodyXn85
  loLe := Nat.le_of_ble_eq_true bodyLo85
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB85
  cntM := bodyCntM85
  hiLe := Nat.le_of_ble_eq_true bodyHi85
  nhiLe := Nat.le_of_ble_eq_true bodyNhi85
  jsHeap := bodyJs85
  jsRoots := bodyJsRoots85
  jsNative := bodyJsNative85
  framesEmpty := bodyFramesEmpty85
  trailOld := by decide
  lowVars := bodyLow85

def bodyQs85 : List (Option Q) := []
noncomputable def bodyEs85 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr85.map fun r => nth? PRE_first_tail_x15_r0_body.st85.S2.tab r
kernel_rfl bodyResChk85 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs85 bodyQs85) = true
kernel_rfl bodyLq85 : bodyQs85.length = PRE_first_tail_x15_r0_body.cws85.length
kernel_rfl bodyNrLo85 : PRE_first_tail_x15_r0_body.nr85.all (Nat.ble PRE_first_tail_x15_r0_body.S829.tab.length) = true
kernel_rfl bodySub85 : (Oracles.PRE_first_tail_x15_r0_body.map_site85.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost85 : postSubB bodyM PRE_first_tail_x15_r0_body.ws85 PRE_first_tail_x15_r0_body.cws85 bodyQs85 = true
kernel_rfl bodyDrop85 : Nat.ble (32241 + (PRE_first_tail_x15_r0_body.s830.next - PRE_first_tail_x15_r0_body.s831.next)) 32243 = true
kernel_rfl bodyDropH85 : Nat.ble (585 + ((mlxOf PRE_first_tail_x15_r0_body.s830.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s831.ffi).next)) 585 = true
kernel_rfl bodyDropN85 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s830.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s831.ffi).nnext)) 0 = true
kernel_rfl bodyDv85 : bodyΘ.1.take 459 = bodyΘ.1.take 459 ++ PRE_first_tail_x15_r0_body.cws85
kernel_rfl bodyDe85 : bodyΘ.2.take 459 = bodyΘ.2.take 459 ++ PRE_first_tail_x15_r0_body.nr85.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st85.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 459) (bodyΘ.2.take 459)))
kernel_rfl bodyDl85 : (bodyΘ.1.take 459).length = (bodyΘ.2.take 459).length
kernel_rfl bodyDold85 : (bodyΘ.1.take 459).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws85).isNone && !PRE_first_tail_x15_r0_body.ws85.contains v) = true
kernel_rfl bodyDfree85 : (bodyΘ.2.take 459).all (fun e => (PRE_first_tail_x15_r0_body.cws85 ++ PRE_first_tail_x15_r0_body.ws85).all fun w => e.noVar w) = true

theorem bodyStep85 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32241, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s829 PRE_first_tail_x15_r0_body.S829)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32243, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.S831) (27 + 1) :=
  bodySite bodyFacts85.cfix bodyFacts85.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st85.S2.tab) (Es := bodyEs85) (qs := bodyQs85)
    (ok := PRE_first_tail_x15_r0_body.st85.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site85 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts85
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site85 r hr) hi (MapOk.sub hm (sub_of_all bodySub85)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk85 r hr) hi hm ho hq)
    bodyLq85 rfl bodyNrLo85 (postSub_sound bodyPost85)
    (Nat.le_of_ble_eq_true bodyDrop85) (by decide) (Nat.le_of_ble_eq_true bodyDropH85) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN85) (by decide)
    bodyDv85 bodyDe85 bodyDl85 bodyDold85 bodyDfree85 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
