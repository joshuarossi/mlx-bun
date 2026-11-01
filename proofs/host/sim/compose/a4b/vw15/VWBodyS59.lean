import host.sim.compose.a4b.vw15.VWBodyJ59
import host.sim.compose.a4b.vw15.VWBodySite59
import host.sim.compose.a4b.vw15.VWBodyOracles_14
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

theorem bodyCshift59 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S574.tab.length PRE_first_tail_x15_r0_body.s574.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P59.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P59 2575 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.s576.ffi PRE_first_tail_x15_r0_body.s575.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_59
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_59
  have hcl : SSt (· < 2575) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s576.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S574.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_59] <;> decide) PRE_first_tail_x15_r0_body.cnodesK59 PRE_first_tail_x15_r0_body.cobjsK59
      PRE_first_tail_x15_r0_body.citemsK59 PRE_first_tail_x15_r0_body.cbd59 PRE_first_tail_x15_r0_body.csst59
  exact PRE_first_tail_x15_r0_body.cshift59 bodyNcl59 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_59] at this; exact this)


kernel_rfl bodyFramesEmpty59 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s575 a).isEmpty) = true
kernel_rfl bodyJsRoots59 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s574.next) PRE_first_tail_x15_r0_body.s576.trace PRE_first_tail_x15_r0_body.s576 = true
kernel_rfl bodyJsNative59 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s576.ffi) = true
kernel_rfl bodyLow59 : (PRE_first_tail_x15_r0_body.cws59 ++ PRE_first_tail_x15_r0_body.ws59).all (Nat.ble 9) = true
kernel_rfl bodyCntM59 : countersOkB PRE_first_tail_x15_r0_body.s574 PRE_first_tail_x15_r0_body.s575 = true
kernel_rfl bodyHi59 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s576.ffi).next setupP.E = true
kernel_rfl bodyNhi59 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s576.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge59 : bridgeOf PRE_first_tail_x15_r0_body.s575.ffi = bridgeOf PRE_first_tail_x15_r0_body.s574.ffi
kernel_rfl bodyNN59 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s574.ffi).nnext PRE_first_tail_x15_r0_body.P59.NL = true
kernel_rfl bodyXn59 : Nat.ble (⟨19361, 16444, 2721054, 2575⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s576.ffi).next = true
kernel_rfl bodyLo59 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s576.ffi).next = true
theorem bodyFacts59 : BodySiteFacts PRE_first_tail_x15_r0_body.s574 PRE_first_tail_x15_r0_body.s575 PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S574 PRE_first_tail_x15_r0_body.S575 PRE_first_tail_x15_r0_body.S576
    PRE_first_tail_x15_r0_body.ws59 PRE_first_tail_x15_r0_body.cws59 PRE_first_tail_x15_r0_body.nr59 PRE_first_tail_x15_r0_body.pl59 PRE_first_tail_x15_r0_body.cl59 2721064 2575 PRE_first_tail_x15_r0_body.kd59 PRE_first_tail_x15_r0_body.kappa59 PRE_first_tail_x15_r0_body.P59
    ⟨19361, 16444, 2721053, 2575⟩ ⟨19361, 16444, 2721054, 2575⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap59
  clean := bodyClean59
  cfix := PRE_first_tail_x15_r0_body.cfix59
  zpl := PRE_first_tail_x15_r0_body.zpl59
  zplnd := PRE_first_tail_x15_r0_body.zplnd59
  zn1 := PRE_first_tail_x15_r0_body.zn159
  zfirst := PRE_first_tail_x15_r0_body.zfirst59
  zscn := PRE_first_tail_x15_r0_body.zscn59
  zsmn := PRE_first_tail_x15_r0_body.zsmn59
  zgrow := PRE_first_tail_x15_r0_body.zgrow59
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab59
  zfresh := PRE_first_tail_x15_r0_body.zfresh59
  zcnd := PRE_first_tail_x15_r0_body.zcnd59
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi59
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt59
  zgP := PRE_first_tail_x15_r0_body.zg59_2665
  zkP := PRE_first_tail_x15_r0_body.zk59_2665
  zmP := PRE_first_tail_x15_r0_body.zm59_2665
  zgC := PRE_first_tail_x15_r0_body.zg59_2673467
  zkC := PRE_first_tail_x15_r0_body.zk59_2673467
  zmC := PRE_first_tail_x15_r0_body.zm59_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw59_2673472
  zwV := PRE_first_tail_x15_r0_body.zw59_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap59
  zclbd := PRE_first_tail_x15_r0_body.zclbd59
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap59 PRE_first_tail_x15_r0_body.stFoot59 PRE_first_tail_x15_r0_body.iso59 PRE_first_tail_x15_r0_body.zwr59
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP59
  csupp := PRE_first_tail_x15_r0_body.csupp59
  cbound := PRE_first_tail_x15_r0_body.cbound59
  zimg := PRE_first_tail_x15_r0_body.zimg59
  zctl := PRE_first_tail_x15_r0_body.zctl59
  zstack := PRE_first_tail_x15_r0_body.zstack59
  zjobs := PRE_first_tail_x15_r0_body.zjobs59
  zstores := PRE_first_tail_x15_r0_body.zstores59
  zroots := PRE_first_tail_x15_r0_body.zroots59
  znC := PRE_first_tail_x15_r0_body.znC59
  ctab := PRE_first_tail_x15_r0_body.ctab59
  zbin := PRE_first_tail_x15_r0_body.zbin59
  cbridge := PRE_first_tail_x15_r0_body.cbridge59
  sbridge := bodyBridge59
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj59
  cshiftR := fun h hNL => bodyCshift59 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN59
  raised := PRE_first_tail_x15_r0_body.raised59
  cbigs := PRE_first_tail_x15_r0_body.cbigs59
  cjcl := PRE_first_tail_x15_r0_body.cjcl59
  xnLe := Nat.le_of_ble_eq_true bodyXn59
  loLe := Nat.le_of_ble_eq_true bodyLo59
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB59
  cntM := bodyCntM59
  hiLe := Nat.le_of_ble_eq_true bodyHi59
  nhiLe := Nat.le_of_ble_eq_true bodyNhi59
  jsHeap := bodyJs59
  jsRoots := bodyJsRoots59
  jsNative := bodyJsNative59
  framesEmpty := bodyFramesEmpty59
  trailOld := by decide
  lowVars := bodyLow59

def bodyQs59 : List (Option Q) := []
noncomputable def bodyEs59 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr59.map fun r => nth? PRE_first_tail_x15_r0_body.st59.S2.tab r
kernel_rfl bodyResChk59 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs59 bodyQs59) = true
kernel_rfl bodyLq59 : bodyQs59.length = PRE_first_tail_x15_r0_body.cws59.length
kernel_rfl bodyNrLo59 : PRE_first_tail_x15_r0_body.nr59.all (Nat.ble PRE_first_tail_x15_r0_body.S574.tab.length) = true
kernel_rfl bodySub59 : (Oracles.PRE_first_tail_x15_r0_body.map_site59.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost59 : postSubB bodyM PRE_first_tail_x15_r0_body.ws59 PRE_first_tail_x15_r0_body.cws59 bodyQs59 = true
kernel_rfl bodyDrop59 : Nat.ble (23392 + (PRE_first_tail_x15_r0_body.s575.next - PRE_first_tail_x15_r0_body.s576.next)) 23402 = true
kernel_rfl bodyDropH59 : Nat.ble (406 + ((mlxOf PRE_first_tail_x15_r0_body.s575.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s576.ffi).next)) 406 = true
kernel_rfl bodyDropN59 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s575.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s576.ffi).nnext)) 0 = true
kernel_rfl bodyDv59 : bodyΘ.1.take 315 = bodyΘ.1.take 315 ++ PRE_first_tail_x15_r0_body.cws59
kernel_rfl bodyDe59 : bodyΘ.2.take 315 = bodyΘ.2.take 315 ++ PRE_first_tail_x15_r0_body.nr59.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st59.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 315) (bodyΘ.2.take 315)))
kernel_rfl bodyDl59 : (bodyΘ.1.take 315).length = (bodyΘ.2.take 315).length
kernel_rfl bodyDold59 : (bodyΘ.1.take 315).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws59).isNone && !PRE_first_tail_x15_r0_body.ws59.contains v) = true
kernel_rfl bodyDfree59 : (bodyΘ.2.take 315).all (fun e => (PRE_first_tail_x15_r0_body.cws59 ++ PRE_first_tail_x15_r0_body.ws59).all fun w => e.noVar w) = true

theorem bodyStep59 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23392, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s574 PRE_first_tail_x15_r0_body.S574)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23402, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s576 PRE_first_tail_x15_r0_body.S576) (98 + 1) :=
  bodySite bodyFacts59.cfix bodyFacts59.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st59.S2.tab) (Es := bodyEs59) (qs := bodyQs59)
    (ok := PRE_first_tail_x15_r0_body.st59.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site59 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts59
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site59 r hr) hi (MapOk.sub hm (sub_of_all bodySub59)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk59 r hr) hi hm ho hq)
    bodyLq59 rfl bodyNrLo59 (postSub_sound bodyPost59)
    (Nat.le_of_ble_eq_true bodyDrop59) (by decide) (Nat.le_of_ble_eq_true bodyDropH59) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN59) (by decide)
    bodyDv59 bodyDe59 bodyDl59 bodyDold59 bodyDfree59 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
