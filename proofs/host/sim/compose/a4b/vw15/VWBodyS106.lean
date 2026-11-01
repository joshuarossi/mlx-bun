import host.sim.compose.a4b.vw15.VWBodyJ106
import host.sim.compose.a4b.vw15.VWBodySite106
import host.sim.compose.a4b.vw15.VWBodyOracles_26
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift106 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1030.tab.length PRE_first_tail_x15_r0_body.s1030.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P106.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P106 4610 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.s1032.ffi PRE_first_tail_x15_r0_body.s1031.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_106
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_106
  have hcl : SSt (· < 4610) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1032.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1030.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_106] <;> decide) PRE_first_tail_x15_r0_body.cnodesK106 PRE_first_tail_x15_r0_body.cobjsK106
      PRE_first_tail_x15_r0_body.citemsK106 PRE_first_tail_x15_r0_body.cbd106 PRE_first_tail_x15_r0_body.csst106
  exact PRE_first_tail_x15_r0_body.cshift106 bodyNcl106 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_106] at this; exact this)


kernel_rfl bodyFramesEmpty106 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1031 a).isEmpty) = true
kernel_rfl bodyJsRoots106 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1030.next) PRE_first_tail_x15_r0_body.s1032.trace PRE_first_tail_x15_r0_body.s1032 = true
kernel_rfl bodyJsNative106 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1032.ffi) = true
kernel_rfl bodyLow106 : (PRE_first_tail_x15_r0_body.cws106 ++ PRE_first_tail_x15_r0_body.ws106).all (Nat.ble 9) = true
kernel_rfl bodyCntM106 : countersOkB PRE_first_tail_x15_r0_body.s1030 PRE_first_tail_x15_r0_body.s1031 = true
kernel_rfl bodyHi106 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1032.ffi).next setupP.E = true
kernel_rfl bodyNhi106 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1032.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge106 : bridgeOf PRE_first_tail_x15_r0_body.s1031.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1030.ffi
kernel_rfl bodyNN106 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1030.ffi).nnext PRE_first_tail_x15_r0_body.P106.NL = true
kernel_rfl bodyXn106 : Nat.ble (⟨20298, 17388, 2758429, 4610⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1032.ffi).next = true
kernel_rfl bodyLo106 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1032.ffi).next = true
theorem bodyFacts106 : BodySiteFacts PRE_first_tail_x15_r0_body.s1030 PRE_first_tail_x15_r0_body.s1031 PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1030 PRE_first_tail_x15_r0_body.S1031 PRE_first_tail_x15_r0_body.S1032
    PRE_first_tail_x15_r0_body.ws106 PRE_first_tail_x15_r0_body.cws106 PRE_first_tail_x15_r0_body.nr106 PRE_first_tail_x15_r0_body.pl106 PRE_first_tail_x15_r0_body.cl106 2758431 4610 PRE_first_tail_x15_r0_body.kd106 PRE_first_tail_x15_r0_body.kappa106 PRE_first_tail_x15_r0_body.P106
    ⟨20298, 17388, 2758429, 4610⟩ ⟨20298, 17388, 2758429, 4610⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap106
  clean := bodyClean106
  cfix := PRE_first_tail_x15_r0_body.cfix106
  zpl := PRE_first_tail_x15_r0_body.zpl106
  zplnd := PRE_first_tail_x15_r0_body.zplnd106
  zn1 := PRE_first_tail_x15_r0_body.zn1106
  zfirst := PRE_first_tail_x15_r0_body.zfirst106
  zscn := PRE_first_tail_x15_r0_body.zscn106
  zsmn := PRE_first_tail_x15_r0_body.zsmn106
  zgrow := PRE_first_tail_x15_r0_body.zgrow106
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab106
  zfresh := PRE_first_tail_x15_r0_body.zfresh106
  zcnd := PRE_first_tail_x15_r0_body.zcnd106
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi106
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt106
  zgP := PRE_first_tail_x15_r0_body.zg106_2665
  zkP := PRE_first_tail_x15_r0_body.zk106_2665
  zmP := PRE_first_tail_x15_r0_body.zm106_2665
  zgC := PRE_first_tail_x15_r0_body.zg106_2673467
  zkC := PRE_first_tail_x15_r0_body.zk106_2673467
  zmC := PRE_first_tail_x15_r0_body.zm106_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw106_2673472
  zwV := PRE_first_tail_x15_r0_body.zw106_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap106
  zclbd := PRE_first_tail_x15_r0_body.zclbd106
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap106 PRE_first_tail_x15_r0_body.stFoot106 PRE_first_tail_x15_r0_body.iso106 PRE_first_tail_x15_r0_body.zwr106
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP106
  csupp := PRE_first_tail_x15_r0_body.csupp106
  cbound := PRE_first_tail_x15_r0_body.cbound106
  zimg := PRE_first_tail_x15_r0_body.zimg106
  zctl := PRE_first_tail_x15_r0_body.zctl106
  zstack := PRE_first_tail_x15_r0_body.zstack106
  zjobs := PRE_first_tail_x15_r0_body.zjobs106
  zstores := PRE_first_tail_x15_r0_body.zstores106
  zroots := PRE_first_tail_x15_r0_body.zroots106
  znC := PRE_first_tail_x15_r0_body.znC106
  ctab := PRE_first_tail_x15_r0_body.ctab106
  zbin := PRE_first_tail_x15_r0_body.zbin106
  cbridge := PRE_first_tail_x15_r0_body.cbridge106
  sbridge := bodyBridge106
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj106
  cshiftR := fun h hNL => bodyCshift106 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN106
  raised := PRE_first_tail_x15_r0_body.raised106
  cbigs := PRE_first_tail_x15_r0_body.cbigs106
  cjcl := PRE_first_tail_x15_r0_body.cjcl106
  xnLe := Nat.le_of_ble_eq_true bodyXn106
  loLe := Nat.le_of_ble_eq_true bodyLo106
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB106
  cntM := bodyCntM106
  hiLe := Nat.le_of_ble_eq_true bodyHi106
  nhiLe := Nat.le_of_ble_eq_true bodyNhi106
  jsHeap := bodyJs106
  jsRoots := bodyJsRoots106
  jsNative := bodyJsNative106
  framesEmpty := bodyFramesEmpty106
  trailOld := by decide
  lowVars := bodyLow106

def bodyQs106 : List (Option Q) := []
noncomputable def bodyEs106 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr106.map fun r => nth? PRE_first_tail_x15_r0_body.st106.S2.tab r
kernel_rfl bodyResChk106 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs106 bodyQs106) = true
kernel_rfl bodyLq106 : bodyQs106.length = PRE_first_tail_x15_r0_body.cws106.length
kernel_rfl bodyNrLo106 : PRE_first_tail_x15_r0_body.nr106.all (Nat.ble PRE_first_tail_x15_r0_body.S1030.tab.length) = true
kernel_rfl bodySub106 : (Oracles.PRE_first_tail_x15_r0_body.map_site106.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost106 : postSubB bodyM PRE_first_tail_x15_r0_body.ws106 PRE_first_tail_x15_r0_body.cws106 bodyQs106 = true
kernel_rfl bodyDrop106 : Nat.ble (38806 + (PRE_first_tail_x15_r0_body.s1031.next - PRE_first_tail_x15_r0_body.s1032.next)) 38808 = true
kernel_rfl bodyDropH106 : Nat.ble (714 + ((mlxOf PRE_first_tail_x15_r0_body.s1031.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1032.ffi).next)) 714 = true
kernel_rfl bodyDropN106 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1031.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1032.ffi).nnext)) 0 = true
kernel_rfl bodyDv106 : bodyΘ.1.take 567 = bodyΘ.1.take 567 ++ PRE_first_tail_x15_r0_body.cws106
kernel_rfl bodyDe106 : bodyΘ.2.take 567 = bodyΘ.2.take 567 ++ PRE_first_tail_x15_r0_body.nr106.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st106.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 567) (bodyΘ.2.take 567)))
kernel_rfl bodyDl106 : (bodyΘ.1.take 567).length = (bodyΘ.2.take 567).length
kernel_rfl bodyDold106 : (bodyΘ.1.take 567).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws106).isNone && !PRE_first_tail_x15_r0_body.ws106.contains v) = true
kernel_rfl bodyDfree106 : (bodyΘ.2.take 567).all (fun e => (PRE_first_tail_x15_r0_body.cws106 ++ PRE_first_tail_x15_r0_body.ws106).all fun w => e.noVar w) = true

theorem bodyStep106 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38806, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1030 PRE_first_tail_x15_r0_body.S1030)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38808, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1032 PRE_first_tail_x15_r0_body.S1032) (27 + 1) :=
  bodySite bodyFacts106.cfix bodyFacts106.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st106.S2.tab) (Es := bodyEs106) (qs := bodyQs106)
    (ok := PRE_first_tail_x15_r0_body.st106.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site106 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts106
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site106 r hr) hi (MapOk.sub hm (sub_of_all bodySub106)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk106 r hr) hi hm ho hq)
    bodyLq106 rfl bodyNrLo106 (postSub_sound bodyPost106)
    (Nat.le_of_ble_eq_true bodyDrop106) (by decide) (Nat.le_of_ble_eq_true bodyDropH106) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN106) (by decide)
    bodyDv106 bodyDe106 bodyDl106 bodyDold106 bodyDfree106 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
