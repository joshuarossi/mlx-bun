import host.sim.compose.a4b.vw15.VWBodyJ61
import host.sim.compose.a4b.vw15.VWBodySite61
import host.sim.compose.a4b.vw15.VWBodyOracles_15
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

theorem bodyCshift61 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S599.tab.length PRE_first_tail_x15_r0_body.s599.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P61.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P61 2687 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.s601.ffi PRE_first_tail_x15_r0_body.s600.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_61
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_61
  have hcl : SSt (· < 2687) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s601.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S599.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_61] <;> decide) PRE_first_tail_x15_r0_body.cnodesK61 PRE_first_tail_x15_r0_body.cobjsK61
      PRE_first_tail_x15_r0_body.citemsK61 PRE_first_tail_x15_r0_body.cbd61 PRE_first_tail_x15_r0_body.csst61
  exact PRE_first_tail_x15_r0_body.cshift61 bodyNcl61 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_61] at this; exact this)


kernel_rfl bodyFramesEmpty61 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s600 a).isEmpty) = true
kernel_rfl bodyJsRoots61 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s599.next) PRE_first_tail_x15_r0_body.s601.trace PRE_first_tail_x15_r0_body.s601 = true
kernel_rfl bodyJsNative61 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s601.ffi) = true
kernel_rfl bodyLow61 : (PRE_first_tail_x15_r0_body.cws61 ++ PRE_first_tail_x15_r0_body.ws61).all (Nat.ble 9) = true
kernel_rfl bodyCntM61 : countersOkB PRE_first_tail_x15_r0_body.s599 PRE_first_tail_x15_r0_body.s600 = true
kernel_rfl bodyHi61 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s601.ffi).next setupP.E = true
kernel_rfl bodyNhi61 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s601.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge61 : bridgeOf PRE_first_tail_x15_r0_body.s600.ffi = bridgeOf PRE_first_tail_x15_r0_body.s599.ffi
kernel_rfl bodyNN61 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s599.ffi).nnext PRE_first_tail_x15_r0_body.P61.NL = true
kernel_rfl bodyXn61 : Nat.ble (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s601.ffi).next = true
kernel_rfl bodyLo61 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s601.ffi).next = true
theorem bodyFacts61 : BodySiteFacts PRE_first_tail_x15_r0_body.s599 PRE_first_tail_x15_r0_body.s600 PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S599 PRE_first_tail_x15_r0_body.S600 PRE_first_tail_x15_r0_body.S601
    PRE_first_tail_x15_r0_body.ws61 PRE_first_tail_x15_r0_body.cws61 PRE_first_tail_x15_r0_body.nr61 PRE_first_tail_x15_r0_body.pl61 PRE_first_tail_x15_r0_body.cl61 2723045 2687 PRE_first_tail_x15_r0_body.kd61 PRE_first_tail_x15_r0_body.kappa61 PRE_first_tail_x15_r0_body.P61
    ⟨19412, 16503, 2723043, 2687⟩ ⟨19412, 16503, 2723043, 2687⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap61
  clean := bodyClean61
  cfix := PRE_first_tail_x15_r0_body.cfix61
  zpl := PRE_first_tail_x15_r0_body.zpl61
  zplnd := PRE_first_tail_x15_r0_body.zplnd61
  zn1 := PRE_first_tail_x15_r0_body.zn161
  zfirst := PRE_first_tail_x15_r0_body.zfirst61
  zscn := PRE_first_tail_x15_r0_body.zscn61
  zsmn := PRE_first_tail_x15_r0_body.zsmn61
  zgrow := PRE_first_tail_x15_r0_body.zgrow61
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab61
  zfresh := PRE_first_tail_x15_r0_body.zfresh61
  zcnd := PRE_first_tail_x15_r0_body.zcnd61
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi61
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt61
  zgP := PRE_first_tail_x15_r0_body.zg61_2665
  zkP := PRE_first_tail_x15_r0_body.zk61_2665
  zmP := PRE_first_tail_x15_r0_body.zm61_2665
  zgC := PRE_first_tail_x15_r0_body.zg61_2673467
  zkC := PRE_first_tail_x15_r0_body.zk61_2673467
  zmC := PRE_first_tail_x15_r0_body.zm61_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw61_2673472
  zwV := PRE_first_tail_x15_r0_body.zw61_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap61
  zclbd := PRE_first_tail_x15_r0_body.zclbd61
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap61 PRE_first_tail_x15_r0_body.stFoot61 PRE_first_tail_x15_r0_body.iso61 PRE_first_tail_x15_r0_body.zwr61
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP61
  csupp := PRE_first_tail_x15_r0_body.csupp61
  cbound := PRE_first_tail_x15_r0_body.cbound61
  zimg := PRE_first_tail_x15_r0_body.zimg61
  zctl := PRE_first_tail_x15_r0_body.zctl61
  zstack := PRE_first_tail_x15_r0_body.zstack61
  zjobs := PRE_first_tail_x15_r0_body.zjobs61
  zstores := PRE_first_tail_x15_r0_body.zstores61
  zroots := PRE_first_tail_x15_r0_body.zroots61
  znC := PRE_first_tail_x15_r0_body.znC61
  ctab := PRE_first_tail_x15_r0_body.ctab61
  zbin := PRE_first_tail_x15_r0_body.zbin61
  cbridge := PRE_first_tail_x15_r0_body.cbridge61
  sbridge := bodyBridge61
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj61
  cshiftR := fun h hNL => bodyCshift61 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN61
  raised := PRE_first_tail_x15_r0_body.raised61
  cbigs := PRE_first_tail_x15_r0_body.cbigs61
  cjcl := PRE_first_tail_x15_r0_body.cjcl61
  xnLe := Nat.le_of_ble_eq_true bodyXn61
  loLe := Nat.le_of_ble_eq_true bodyLo61
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB61
  cntM := bodyCntM61
  hiLe := Nat.le_of_ble_eq_true bodyHi61
  nhiLe := Nat.le_of_ble_eq_true bodyNhi61
  jsHeap := bodyJs61
  jsRoots := bodyJsRoots61
  jsNative := bodyJsNative61
  framesEmpty := bodyFramesEmpty61
  trailOld := by decide
  lowVars := bodyLow61

def bodyQs61 : List (Option Q) := []
noncomputable def bodyEs61 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr61.map fun r => nth? PRE_first_tail_x15_r0_body.st61.S2.tab r
kernel_rfl bodyResChk61 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs61 bodyQs61) = true
kernel_rfl bodyLq61 : bodyQs61.length = PRE_first_tail_x15_r0_body.cws61.length
kernel_rfl bodyNrLo61 : PRE_first_tail_x15_r0_body.nr61.all (Nat.ble PRE_first_tail_x15_r0_body.S599.tab.length) = true
kernel_rfl bodySub61 : (Oracles.PRE_first_tail_x15_r0_body.map_site61.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost61 : postSubB bodyM PRE_first_tail_x15_r0_body.ws61 PRE_first_tail_x15_r0_body.cws61 bodyQs61 = true
kernel_rfl bodyDrop61 : Nat.ble (24551 + (PRE_first_tail_x15_r0_body.s600.next - PRE_first_tail_x15_r0_body.s601.next)) 24553 = true
kernel_rfl bodyDropH61 : Nat.ble (431 + ((mlxOf PRE_first_tail_x15_r0_body.s600.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s601.ffi).next)) 431 = true
kernel_rfl bodyDropN61 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s600.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s601.ffi).nnext)) 0 = true
kernel_rfl bodyDv61 : bodyΘ.1.take 333 = bodyΘ.1.take 333 ++ PRE_first_tail_x15_r0_body.cws61
kernel_rfl bodyDe61 : bodyΘ.2.take 333 = bodyΘ.2.take 333 ++ PRE_first_tail_x15_r0_body.nr61.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st61.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 333) (bodyΘ.2.take 333)))
kernel_rfl bodyDl61 : (bodyΘ.1.take 333).length = (bodyΘ.2.take 333).length
kernel_rfl bodyDold61 : (bodyΘ.1.take 333).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws61).isNone && !PRE_first_tail_x15_r0_body.ws61.contains v) = true
kernel_rfl bodyDfree61 : (bodyΘ.2.take 333).all (fun e => (PRE_first_tail_x15_r0_body.cws61 ++ PRE_first_tail_x15_r0_body.ws61).all fun w => e.noVar w) = true

theorem bodyStep61 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24551, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s599 PRE_first_tail_x15_r0_body.S599)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24553, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.S601) (27 + 1) :=
  bodySite bodyFacts61.cfix bodyFacts61.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st61.S2.tab) (Es := bodyEs61) (qs := bodyQs61)
    (ok := PRE_first_tail_x15_r0_body.st61.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site61 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts61
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site61 r hr) hi (MapOk.sub hm (sub_of_all bodySub61)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk61 r hr) hi hm ho hq)
    bodyLq61 rfl bodyNrLo61 (postSub_sound bodyPost61)
    (Nat.le_of_ble_eq_true bodyDrop61) (by decide) (Nat.le_of_ble_eq_true bodyDropH61) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN61) (by decide)
    bodyDv61 bodyDe61 bodyDl61 bodyDold61 bodyDfree61 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
