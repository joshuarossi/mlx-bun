import host.sim.compose.a4b.vw15.VWBodyJ148
import host.sim.compose.a4b.vw15.VWBodySite148
import host.sim.compose.a4b.vw15.VWBodyOracles_37
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift148 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1433.tab.length PRE_first_tail_x15_r0_body.s1433.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P148.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P148 6407 PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.s1435.ffi PRE_first_tail_x15_r0_body.s1434.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_148
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_148
  have hcl : SSt (· < 6407) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1433.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_148] <;> decide) PRE_first_tail_x15_r0_body.cnodesK148 PRE_first_tail_x15_r0_body.cobjsK148
      PRE_first_tail_x15_r0_body.citemsK148 PRE_first_tail_x15_r0_body.cbd148 PRE_first_tail_x15_r0_body.csst148
  exact PRE_first_tail_x15_r0_body.cshift148 bodyNcl148 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_148] at this; exact this)


kernel_rfl bodyFramesEmpty148 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1434 a).isEmpty) = true
kernel_rfl bodyJsRoots148 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1433.next) PRE_first_tail_x15_r0_body.s1435.trace PRE_first_tail_x15_r0_body.s1435 = true
kernel_rfl bodyJsNative148 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1435.ffi) = true
kernel_rfl bodyLow148 : (PRE_first_tail_x15_r0_body.cws148 ++ PRE_first_tail_x15_r0_body.ws148).all (Nat.ble 9) = true
kernel_rfl bodyCntM148 : countersOkB PRE_first_tail_x15_r0_body.s1433 PRE_first_tail_x15_r0_body.s1434 = true
kernel_rfl bodyHi148 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1435.ffi).next setupP.E = true
kernel_rfl bodyNhi148 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1435.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge148 : bridgeOf PRE_first_tail_x15_r0_body.s1434.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1433.ffi
kernel_rfl bodyNN148 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1433.ffi).nnext PRE_first_tail_x15_r0_body.P148.NL = true
kernel_rfl bodyXn148 : Nat.ble (⟨21121, 18225, 2791215, 6407⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1435.ffi).next = true
kernel_rfl bodyLo148 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1435.ffi).next = true
theorem bodyFacts148 : BodySiteFacts PRE_first_tail_x15_r0_body.s1433 PRE_first_tail_x15_r0_body.s1434 PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1433 PRE_first_tail_x15_r0_body.S1434 PRE_first_tail_x15_r0_body.S1435
    PRE_first_tail_x15_r0_body.ws148 PRE_first_tail_x15_r0_body.cws148 PRE_first_tail_x15_r0_body.nr148 PRE_first_tail_x15_r0_body.pl148 PRE_first_tail_x15_r0_body.cl148 2791217 6407 PRE_first_tail_x15_r0_body.kd148 PRE_first_tail_x15_r0_body.kappa148 PRE_first_tail_x15_r0_body.P148
    ⟨21121, 18225, 2791215, 6407⟩ ⟨21121, 18225, 2791215, 6407⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap148
  clean := bodyClean148
  cfix := PRE_first_tail_x15_r0_body.cfix148
  zpl := PRE_first_tail_x15_r0_body.zpl148
  zplnd := PRE_first_tail_x15_r0_body.zplnd148
  zn1 := PRE_first_tail_x15_r0_body.zn1148
  zfirst := PRE_first_tail_x15_r0_body.zfirst148
  zscn := PRE_first_tail_x15_r0_body.zscn148
  zsmn := PRE_first_tail_x15_r0_body.zsmn148
  zgrow := PRE_first_tail_x15_r0_body.zgrow148
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab148
  zfresh := PRE_first_tail_x15_r0_body.zfresh148
  zcnd := PRE_first_tail_x15_r0_body.zcnd148
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi148
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt148
  zgP := PRE_first_tail_x15_r0_body.zg148_2665
  zkP := PRE_first_tail_x15_r0_body.zk148_2665
  zmP := PRE_first_tail_x15_r0_body.zm148_2665
  zgC := PRE_first_tail_x15_r0_body.zg148_2673467
  zkC := PRE_first_tail_x15_r0_body.zk148_2673467
  zmC := PRE_first_tail_x15_r0_body.zm148_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw148_2673472
  zwV := PRE_first_tail_x15_r0_body.zw148_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap148
  zclbd := PRE_first_tail_x15_r0_body.zclbd148
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap148 PRE_first_tail_x15_r0_body.stFoot148 PRE_first_tail_x15_r0_body.iso148 PRE_first_tail_x15_r0_body.zwr148
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP148
  csupp := PRE_first_tail_x15_r0_body.csupp148
  cbound := PRE_first_tail_x15_r0_body.cbound148
  zimg := PRE_first_tail_x15_r0_body.zimg148
  zctl := PRE_first_tail_x15_r0_body.zctl148
  zstack := PRE_first_tail_x15_r0_body.zstack148
  zjobs := PRE_first_tail_x15_r0_body.zjobs148
  zstores := PRE_first_tail_x15_r0_body.zstores148
  zroots := PRE_first_tail_x15_r0_body.zroots148
  znC := PRE_first_tail_x15_r0_body.znC148
  ctab := PRE_first_tail_x15_r0_body.ctab148
  zbin := PRE_first_tail_x15_r0_body.zbin148
  cbridge := PRE_first_tail_x15_r0_body.cbridge148
  sbridge := bodyBridge148
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj148
  cshiftR := fun h hNL => bodyCshift148 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN148
  raised := PRE_first_tail_x15_r0_body.raised148
  cbigs := PRE_first_tail_x15_r0_body.cbigs148
  cjcl := PRE_first_tail_x15_r0_body.cjcl148
  xnLe := Nat.le_of_ble_eq_true bodyXn148
  loLe := Nat.le_of_ble_eq_true bodyLo148
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB148
  cntM := bodyCntM148
  hiLe := Nat.le_of_ble_eq_true bodyHi148
  nhiLe := Nat.le_of_ble_eq_true bodyNhi148
  jsHeap := bodyJs148
  jsRoots := bodyJsRoots148
  jsNative := bodyJsNative148
  framesEmpty := bodyFramesEmpty148
  trailOld := by decide
  lowVars := bodyLow148

def bodyQs148 : List (Option Q) := []
noncomputable def bodyEs148 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr148.map fun r => nth? PRE_first_tail_x15_r0_body.st148.S2.tab r
kernel_rfl bodyResChk148 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs148 bodyQs148) = true
kernel_rfl bodyLq148 : bodyQs148.length = PRE_first_tail_x15_r0_body.cws148.length
kernel_rfl bodyNrLo148 : PRE_first_tail_x15_r0_body.nr148.all (Nat.ble PRE_first_tail_x15_r0_body.S1433.tab.length) = true
kernel_rfl bodySub148 : (Oracles.PRE_first_tail_x15_r0_body.map_site148.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost148 : postSubB bodyM PRE_first_tail_x15_r0_body.ws148 PRE_first_tail_x15_r0_body.cws148 bodyQs148 = true
kernel_rfl bodyDrop148 : Nat.ble (52699 + (PRE_first_tail_x15_r0_body.s1434.next - PRE_first_tail_x15_r0_body.s1435.next)) 52701 = true
kernel_rfl bodyDropH148 : Nat.ble (995 + ((mlxOf PRE_first_tail_x15_r0_body.s1434.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1435.ffi).next)) 995 = true
kernel_rfl bodyDropN148 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1434.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1435.ffi).nnext)) 0 = true
kernel_rfl bodyDv148 : bodyΘ.1.take 792 = bodyΘ.1.take 792 ++ PRE_first_tail_x15_r0_body.cws148
kernel_rfl bodyDe148 : bodyΘ.2.take 792 = bodyΘ.2.take 792 ++ PRE_first_tail_x15_r0_body.nr148.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st148.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 792) (bodyΘ.2.take 792)))
kernel_rfl bodyDl148 : (bodyΘ.1.take 792).length = (bodyΘ.2.take 792).length
kernel_rfl bodyDold148 : (bodyΘ.1.take 792).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws148).isNone && !PRE_first_tail_x15_r0_body.ws148.contains v) = true
kernel_rfl bodyDfree148 : (bodyΘ.2.take 792).all (fun e => (PRE_first_tail_x15_r0_body.cws148 ++ PRE_first_tail_x15_r0_body.ws148).all fun w => e.noVar w) = true

theorem bodyStep148 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨52699, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1433 PRE_first_tail_x15_r0_body.S1433)
      (bodyCut NB T tk π i x0 bodyΘ ⟨52701, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.S1435) (27 + 1) :=
  bodySite bodyFacts148.cfix bodyFacts148.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st148.S2.tab) (Es := bodyEs148) (qs := bodyQs148)
    (ok := PRE_first_tail_x15_r0_body.st148.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site148 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts148
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site148 r hr) hi (MapOk.sub hm (sub_of_all bodySub148)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk148 r hr) hi hm ho hq)
    bodyLq148 rfl bodyNrLo148 (postSub_sound bodyPost148)
    (Nat.le_of_ble_eq_true bodyDrop148) (by decide) (Nat.le_of_ble_eq_true bodyDropH148) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN148) (by decide)
    bodyDv148 bodyDe148 bodyDl148 bodyDold148 bodyDfree148 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
