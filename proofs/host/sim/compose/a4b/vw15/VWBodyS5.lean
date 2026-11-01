import host.sim.compose.a4b.vw15.VWBodyJ5
import host.sim.compose.a4b.vw15.VWBodySite5
import host.sim.compose.a4b.vw15.VWBodyOracles_1
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

theorem bodyCshift5 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S57.tab.length PRE_first_tail_x15_r0_body.s57.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P5.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P5 268 PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.s59.ffi PRE_first_tail_x15_r0_body.s58.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_5
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_5
  have hcl : SSt (· < 268) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S57.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_5] <;> decide) PRE_first_tail_x15_r0_body.cnodesK5 PRE_first_tail_x15_r0_body.cobjsK5
      PRE_first_tail_x15_r0_body.citemsK5 PRE_first_tail_x15_r0_body.cbd5 PRE_first_tail_x15_r0_body.csst5
  exact PRE_first_tail_x15_r0_body.cshift5 bodyNcl5 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_5] at this; exact this)


kernel_rfl bodyFramesEmpty5 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s58 a).isEmpty) = true
kernel_rfl bodyJsRoots5 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s57.next) PRE_first_tail_x15_r0_body.s59.trace PRE_first_tail_x15_r0_body.s59 = true
kernel_rfl bodyJsNative5 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s59.ffi) = true
kernel_rfl bodyLow5 : (PRE_first_tail_x15_r0_body.cws5 ++ PRE_first_tail_x15_r0_body.ws5).all (Nat.ble 9) = true
kernel_rfl bodyCntM5 : countersOkB PRE_first_tail_x15_r0_body.s57 PRE_first_tail_x15_r0_body.s58 = true
kernel_rfl bodyHi5 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s59.ffi).next setupP.E = true
kernel_rfl bodyNhi5 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s59.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge5 : bridgeOf PRE_first_tail_x15_r0_body.s58.ffi = bridgeOf PRE_first_tail_x15_r0_body.s57.ffi
kernel_rfl bodyNN5 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s57.ffi).nnext PRE_first_tail_x15_r0_body.P5.NL = true
kernel_rfl bodyXn5 : Nat.ble (⟨18293, 15385, 2678408, 268⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s59.ffi).next = true
kernel_rfl bodyLo5 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s59.ffi).next = true
theorem bodyFacts5 : BodySiteFacts PRE_first_tail_x15_r0_body.s57 PRE_first_tail_x15_r0_body.s58 PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S57 PRE_first_tail_x15_r0_body.S58 PRE_first_tail_x15_r0_body.S59
    PRE_first_tail_x15_r0_body.ws5 PRE_first_tail_x15_r0_body.cws5 PRE_first_tail_x15_r0_body.nr5 PRE_first_tail_x15_r0_body.pl5 PRE_first_tail_x15_r0_body.cl5 2678418 268 PRE_first_tail_x15_r0_body.kd5 PRE_first_tail_x15_r0_body.kappa5 PRE_first_tail_x15_r0_body.P5
    ⟨18293, 15385, 2678407, 268⟩ ⟨18293, 15385, 2678408, 268⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap5
  clean := bodyClean5
  cfix := PRE_first_tail_x15_r0_body.cfix5
  zpl := PRE_first_tail_x15_r0_body.zpl5
  zplnd := PRE_first_tail_x15_r0_body.zplnd5
  zn1 := PRE_first_tail_x15_r0_body.zn15
  zfirst := PRE_first_tail_x15_r0_body.zfirst5
  zscn := PRE_first_tail_x15_r0_body.zscn5
  zsmn := PRE_first_tail_x15_r0_body.zsmn5
  zgrow := PRE_first_tail_x15_r0_body.zgrow5
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab5
  zfresh := PRE_first_tail_x15_r0_body.zfresh5
  zcnd := PRE_first_tail_x15_r0_body.zcnd5
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi5
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt5
  zgP := PRE_first_tail_x15_r0_body.zg5_2665
  zkP := PRE_first_tail_x15_r0_body.zk5_2665
  zmP := PRE_first_tail_x15_r0_body.zm5_2665
  zgC := PRE_first_tail_x15_r0_body.zg5_2673467
  zkC := PRE_first_tail_x15_r0_body.zk5_2673467
  zmC := PRE_first_tail_x15_r0_body.zm5_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw5_2673472
  zwV := PRE_first_tail_x15_r0_body.zw5_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap5
  zclbd := PRE_first_tail_x15_r0_body.zclbd5
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap5 PRE_first_tail_x15_r0_body.stFoot5 PRE_first_tail_x15_r0_body.iso5 PRE_first_tail_x15_r0_body.zwr5
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP5
  csupp := PRE_first_tail_x15_r0_body.csupp5
  cbound := PRE_first_tail_x15_r0_body.cbound5
  zimg := PRE_first_tail_x15_r0_body.zimg5
  zctl := PRE_first_tail_x15_r0_body.zctl5
  zstack := PRE_first_tail_x15_r0_body.zstack5
  zjobs := PRE_first_tail_x15_r0_body.zjobs5
  zstores := PRE_first_tail_x15_r0_body.zstores5
  zroots := PRE_first_tail_x15_r0_body.zroots5
  znC := PRE_first_tail_x15_r0_body.znC5
  ctab := PRE_first_tail_x15_r0_body.ctab5
  zbin := PRE_first_tail_x15_r0_body.zbin5
  cbridge := PRE_first_tail_x15_r0_body.cbridge5
  sbridge := bodyBridge5
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj5
  cshiftR := fun h hNL => bodyCshift5 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN5
  raised := PRE_first_tail_x15_r0_body.raised5
  cbigs := PRE_first_tail_x15_r0_body.cbigs5
  cjcl := PRE_first_tail_x15_r0_body.cjcl5
  xnLe := Nat.le_of_ble_eq_true bodyXn5
  loLe := Nat.le_of_ble_eq_true bodyLo5
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB5
  cntM := bodyCntM5
  hiLe := Nat.le_of_ble_eq_true bodyHi5
  nhiLe := Nat.le_of_ble_eq_true bodyNhi5
  jsHeap := bodyJs5
  jsRoots := bodyJsRoots5
  jsNative := bodyJsNative5
  framesEmpty := bodyFramesEmpty5
  trailOld := by decide
  lowVars := bodyLow5

def bodyQs5 : List (Option Q) := []
noncomputable def bodyEs5 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr5.map fun r => nth? PRE_first_tail_x15_r0_body.st5.S2.tab r
kernel_rfl bodyResChk5 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs5 bodyQs5) = true
kernel_rfl bodyLq5 : bodyQs5.length = PRE_first_tail_x15_r0_body.cws5.length
kernel_rfl bodyNrLo5 : PRE_first_tail_x15_r0_body.nr5.all (Nat.ble PRE_first_tail_x15_r0_body.S57.tab.length) = true
kernel_rfl bodySub5 : (Oracles.PRE_first_tail_x15_r0_body.map_site5.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost5 : postSubB bodyM PRE_first_tail_x15_r0_body.ws5 PRE_first_tail_x15_r0_body.cws5 bodyQs5 = true
kernel_rfl bodyDrop5 : Nat.ble (6435 + (PRE_first_tail_x15_r0_body.s58.next - PRE_first_tail_x15_r0_body.s59.next)) 6445 = true
kernel_rfl bodyDropH5 : Nat.ble (71 + ((mlxOf PRE_first_tail_x15_r0_body.s58.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s59.ffi).next)) 71 = true
kernel_rfl bodyDropN5 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s58.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s59.ffi).nnext)) 0 = true
kernel_rfl bodyDv5 : bodyΘ.1.take 36 = bodyΘ.1.take 36 ++ PRE_first_tail_x15_r0_body.cws5
kernel_rfl bodyDe5 : bodyΘ.2.take 36 = bodyΘ.2.take 36 ++ PRE_first_tail_x15_r0_body.nr5.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st5.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 36) (bodyΘ.2.take 36)))
kernel_rfl bodyDl5 : (bodyΘ.1.take 36).length = (bodyΘ.2.take 36).length
kernel_rfl bodyDold5 : (bodyΘ.1.take 36).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws5).isNone && !PRE_first_tail_x15_r0_body.ws5.contains v) = true
kernel_rfl bodyDfree5 : (bodyΘ.2.take 36).all (fun e => (PRE_first_tail_x15_r0_body.cws5 ++ PRE_first_tail_x15_r0_body.ws5).all fun w => e.noVar w) = true

theorem bodyStep5 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s57 PRE_first_tail_x15_r0_body.S57)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6445, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.S59) (98 + 1) :=
  bodySite bodyFacts5.cfix bodyFacts5.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st5.S2.tab) (Es := bodyEs5) (qs := bodyQs5)
    (ok := PRE_first_tail_x15_r0_body.st5.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site5 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts5
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site5 r hr) hi (MapOk.sub hm (sub_of_all bodySub5)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk5 r hr) hi hm ho hq)
    bodyLq5 rfl bodyNrLo5 (postSub_sound bodyPost5)
    (Nat.le_of_ble_eq_true bodyDrop5) (by decide) (Nat.le_of_ble_eq_true bodyDropH5) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN5) (by decide)
    bodyDv5 bodyDe5 bodyDl5 bodyDold5 bodyDfree5 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
