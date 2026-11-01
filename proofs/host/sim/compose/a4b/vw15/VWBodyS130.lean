import host.sim.compose.a4b.vw15.VWBodyJ130
import host.sim.compose.a4b.vw15.VWBodySite130
import host.sim.compose.a4b.vw15.VWBodyOracles_32
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift130 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1260.tab.length PRE_first_tail_x15_r0_body.s1260.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P130.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P130 5636 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.s1262.ffi PRE_first_tail_x15_r0_body.s1261.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_130
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_130
  have hcl : SSt (· < 5636) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1260.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_130] <;> decide) PRE_first_tail_x15_r0_body.cnodesK130 PRE_first_tail_x15_r0_body.cobjsK130
      PRE_first_tail_x15_r0_body.citemsK130 PRE_first_tail_x15_r0_body.cbd130 PRE_first_tail_x15_r0_body.csst130
  exact PRE_first_tail_x15_r0_body.cshift130 bodyNcl130 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_130] at this; exact this)


kernel_rfl bodyFramesEmpty130 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1261 a).isEmpty) = true
kernel_rfl bodyJsRoots130 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1260.next) PRE_first_tail_x15_r0_body.s1262.trace PRE_first_tail_x15_r0_body.s1262 = true
kernel_rfl bodyJsNative130 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1262.ffi) = true
kernel_rfl bodyLow130 : (PRE_first_tail_x15_r0_body.cws130 ++ PRE_first_tail_x15_r0_body.ws130).all (Nat.ble 9) = true
kernel_rfl bodyCntM130 : countersOkB PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.s1261 = true
kernel_rfl bodyHi130 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1262.ffi).next setupP.E = true
kernel_rfl bodyNhi130 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1262.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge130 : bridgeOf PRE_first_tail_x15_r0_body.s1261.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1260.ffi
kernel_rfl bodyNN130 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1260.ffi).nnext PRE_first_tail_x15_r0_body.P130.NL = true
kernel_rfl bodyXn130 : Nat.ble (⟨20770, 17862, 2777253, 5636⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1262.ffi).next = true
kernel_rfl bodyLo130 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1262.ffi).next = true
theorem bodyFacts130 : BodySiteFacts PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.s1261 PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1260 PRE_first_tail_x15_r0_body.S1261 PRE_first_tail_x15_r0_body.S1262
    PRE_first_tail_x15_r0_body.ws130 PRE_first_tail_x15_r0_body.cws130 PRE_first_tail_x15_r0_body.nr130 PRE_first_tail_x15_r0_body.pl130 PRE_first_tail_x15_r0_body.cl130 2777255 5636 PRE_first_tail_x15_r0_body.kd130 PRE_first_tail_x15_r0_body.kappa130 PRE_first_tail_x15_r0_body.P130
    ⟨20770, 17862, 2777253, 5636⟩ ⟨20770, 17862, 2777253, 5636⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap130
  clean := bodyClean130
  cfix := PRE_first_tail_x15_r0_body.cfix130
  zpl := PRE_first_tail_x15_r0_body.zpl130
  zplnd := PRE_first_tail_x15_r0_body.zplnd130
  zn1 := PRE_first_tail_x15_r0_body.zn1130
  zfirst := PRE_first_tail_x15_r0_body.zfirst130
  zscn := PRE_first_tail_x15_r0_body.zscn130
  zsmn := PRE_first_tail_x15_r0_body.zsmn130
  zgrow := PRE_first_tail_x15_r0_body.zgrow130
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab130
  zfresh := PRE_first_tail_x15_r0_body.zfresh130
  zcnd := PRE_first_tail_x15_r0_body.zcnd130
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi130
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt130
  zgP := PRE_first_tail_x15_r0_body.zg130_2665
  zkP := PRE_first_tail_x15_r0_body.zk130_2665
  zmP := PRE_first_tail_x15_r0_body.zm130_2665
  zgC := PRE_first_tail_x15_r0_body.zg130_2673467
  zkC := PRE_first_tail_x15_r0_body.zk130_2673467
  zmC := PRE_first_tail_x15_r0_body.zm130_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw130_2673472
  zwV := PRE_first_tail_x15_r0_body.zw130_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap130
  zclbd := PRE_first_tail_x15_r0_body.zclbd130
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap130 PRE_first_tail_x15_r0_body.stFoot130 PRE_first_tail_x15_r0_body.iso130 PRE_first_tail_x15_r0_body.zwr130
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP130
  csupp := PRE_first_tail_x15_r0_body.csupp130
  cbound := PRE_first_tail_x15_r0_body.cbound130
  zimg := PRE_first_tail_x15_r0_body.zimg130
  zctl := PRE_first_tail_x15_r0_body.zctl130
  zstack := PRE_first_tail_x15_r0_body.zstack130
  zjobs := PRE_first_tail_x15_r0_body.zjobs130
  zstores := PRE_first_tail_x15_r0_body.zstores130
  zroots := PRE_first_tail_x15_r0_body.zroots130
  znC := PRE_first_tail_x15_r0_body.znC130
  ctab := PRE_first_tail_x15_r0_body.ctab130
  zbin := PRE_first_tail_x15_r0_body.zbin130
  cbridge := PRE_first_tail_x15_r0_body.cbridge130
  sbridge := bodyBridge130
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj130
  cshiftR := fun h hNL => bodyCshift130 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN130
  raised := PRE_first_tail_x15_r0_body.raised130
  cbigs := PRE_first_tail_x15_r0_body.cbigs130
  cjcl := PRE_first_tail_x15_r0_body.cjcl130
  xnLe := Nat.le_of_ble_eq_true bodyXn130
  loLe := Nat.le_of_ble_eq_true bodyLo130
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB130
  cntM := bodyCntM130
  hiLe := Nat.le_of_ble_eq_true bodyHi130
  nhiLe := Nat.le_of_ble_eq_true bodyNhi130
  jsHeap := bodyJs130
  jsRoots := bodyJsRoots130
  jsNative := bodyJsNative130
  framesEmpty := bodyFramesEmpty130
  trailOld := by decide
  lowVars := bodyLow130

def bodyQs130 : List (Option Q) := []
noncomputable def bodyEs130 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr130.map fun r => nth? PRE_first_tail_x15_r0_body.st130.S2.tab r
kernel_rfl bodyResChk130 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs130 bodyQs130) = true
kernel_rfl bodyLq130 : bodyQs130.length = PRE_first_tail_x15_r0_body.cws130.length
kernel_rfl bodyNrLo130 : PRE_first_tail_x15_r0_body.nr130.all (Nat.ble PRE_first_tail_x15_r0_body.S1260.tab.length) = true
kernel_rfl bodySub130 : (Oracles.PRE_first_tail_x15_r0_body.map_site130.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost130 : postSubB bodyM PRE_first_tail_x15_r0_body.ws130 PRE_first_tail_x15_r0_body.cws130 bodyQs130 = true
kernel_rfl bodyDrop130 : Nat.ble (46496 + (PRE_first_tail_x15_r0_body.s1261.next - PRE_first_tail_x15_r0_body.s1262.next)) 46498 = true
kernel_rfl bodyDropH130 : Nat.ble (868 + ((mlxOf PRE_first_tail_x15_r0_body.s1261.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1262.ffi).next)) 868 = true
kernel_rfl bodyDropN130 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1261.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1262.ffi).nnext)) 0 = true
kernel_rfl bodyDv130 : bodyΘ.1.take 693 = bodyΘ.1.take 693 ++ PRE_first_tail_x15_r0_body.cws130
kernel_rfl bodyDe130 : bodyΘ.2.take 693 = bodyΘ.2.take 693 ++ PRE_first_tail_x15_r0_body.nr130.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st130.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 693) (bodyΘ.2.take 693)))
kernel_rfl bodyDl130 : (bodyΘ.1.take 693).length = (bodyΘ.2.take 693).length
kernel_rfl bodyDold130 : (bodyΘ.1.take 693).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws130).isNone && !PRE_first_tail_x15_r0_body.ws130.contains v) = true
kernel_rfl bodyDfree130 : (bodyΘ.2.take 693).all (fun e => (PRE_first_tail_x15_r0_body.cws130 ++ PRE_first_tail_x15_r0_body.ws130).all fun w => e.noVar w) = true

theorem bodyStep130 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46496, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1260 PRE_first_tail_x15_r0_body.S1260)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46498, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.S1262) (27 + 1) :=
  bodySite bodyFacts130.cfix bodyFacts130.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st130.S2.tab) (Es := bodyEs130) (qs := bodyQs130)
    (ok := PRE_first_tail_x15_r0_body.st130.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site130 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts130
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site130 r hr) hi (MapOk.sub hm (sub_of_all bodySub130)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk130 r hr) hi hm ho hq)
    bodyLq130 rfl bodyNrLo130 (postSub_sound bodyPost130)
    (Nat.le_of_ble_eq_true bodyDrop130) (by decide) (Nat.le_of_ble_eq_true bodyDropH130) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN130) (by decide)
    bodyDv130 bodyDe130 bodyDl130 bodyDold130 bodyDfree130 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
