import host.sim.compose.a4b.vw15.VWBodyJ115
import host.sim.compose.a4b.vw15.VWBodySite115
import host.sim.compose.a4b.vw15.VWBodyOracles_28
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift115 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1117.tab.length PRE_first_tail_x15_r0_body.s1117.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P115.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P115 4997 PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.s1119.ffi PRE_first_tail_x15_r0_body.s1118.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_115
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_115
  have hcl : SSt (· < 4997) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1119.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1117.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_115] <;> decide) PRE_first_tail_x15_r0_body.cnodesK115 PRE_first_tail_x15_r0_body.cobjsK115
      PRE_first_tail_x15_r0_body.citemsK115 PRE_first_tail_x15_r0_body.cbd115 PRE_first_tail_x15_r0_body.csst115
  exact PRE_first_tail_x15_r0_body.cshift115 bodyNcl115 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_115] at this; exact this)


kernel_rfl bodyFramesEmpty115 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1118 a).isEmpty) = true
kernel_rfl bodyJsRoots115 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1117.next) PRE_first_tail_x15_r0_body.s1119.trace PRE_first_tail_x15_r0_body.s1119 = true
kernel_rfl bodyJsNative115 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1119.ffi) = true
kernel_rfl bodyLow115 : (PRE_first_tail_x15_r0_body.cws115 ++ PRE_first_tail_x15_r0_body.ws115).all (Nat.ble 9) = true
kernel_rfl bodyCntM115 : countersOkB PRE_first_tail_x15_r0_body.s1117 PRE_first_tail_x15_r0_body.s1118 = true
kernel_rfl bodyHi115 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1119.ffi).next setupP.E = true
kernel_rfl bodyNhi115 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1119.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge115 : bridgeOf PRE_first_tail_x15_r0_body.s1118.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1117.ffi
kernel_rfl bodyNN115 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1117.ffi).nnext PRE_first_tail_x15_r0_body.P115.NL = true
kernel_rfl bodyXn115 : Nat.ble (⟨20470, 17577, 2765219, 4997⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1119.ffi).next = true
kernel_rfl bodyLo115 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1119.ffi).next = true
theorem bodyFacts115 : BodySiteFacts PRE_first_tail_x15_r0_body.s1117 PRE_first_tail_x15_r0_body.s1118 PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1117 PRE_first_tail_x15_r0_body.S1118 PRE_first_tail_x15_r0_body.S1119
    PRE_first_tail_x15_r0_body.ws115 PRE_first_tail_x15_r0_body.cws115 PRE_first_tail_x15_r0_body.nr115 PRE_first_tail_x15_r0_body.pl115 PRE_first_tail_x15_r0_body.cl115 2765221 4997 PRE_first_tail_x15_r0_body.kd115 PRE_first_tail_x15_r0_body.kappa115 PRE_first_tail_x15_r0_body.P115
    ⟨20470, 17577, 2765219, 4997⟩ ⟨20470, 17577, 2765219, 4997⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap115
  clean := bodyClean115
  cfix := PRE_first_tail_x15_r0_body.cfix115
  zpl := PRE_first_tail_x15_r0_body.zpl115
  zplnd := PRE_first_tail_x15_r0_body.zplnd115
  zn1 := PRE_first_tail_x15_r0_body.zn1115
  zfirst := PRE_first_tail_x15_r0_body.zfirst115
  zscn := PRE_first_tail_x15_r0_body.zscn115
  zsmn := PRE_first_tail_x15_r0_body.zsmn115
  zgrow := PRE_first_tail_x15_r0_body.zgrow115
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab115
  zfresh := PRE_first_tail_x15_r0_body.zfresh115
  zcnd := PRE_first_tail_x15_r0_body.zcnd115
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi115
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt115
  zgP := PRE_first_tail_x15_r0_body.zg115_2665
  zkP := PRE_first_tail_x15_r0_body.zk115_2665
  zmP := PRE_first_tail_x15_r0_body.zm115_2665
  zgC := PRE_first_tail_x15_r0_body.zg115_2673467
  zkC := PRE_first_tail_x15_r0_body.zk115_2673467
  zmC := PRE_first_tail_x15_r0_body.zm115_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw115_2673472
  zwV := PRE_first_tail_x15_r0_body.zw115_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap115
  zclbd := PRE_first_tail_x15_r0_body.zclbd115
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap115 PRE_first_tail_x15_r0_body.stFoot115 PRE_first_tail_x15_r0_body.iso115 PRE_first_tail_x15_r0_body.zwr115
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP115
  csupp := PRE_first_tail_x15_r0_body.csupp115
  cbound := PRE_first_tail_x15_r0_body.cbound115
  zimg := PRE_first_tail_x15_r0_body.zimg115
  zctl := PRE_first_tail_x15_r0_body.zctl115
  zstack := PRE_first_tail_x15_r0_body.zstack115
  zjobs := PRE_first_tail_x15_r0_body.zjobs115
  zstores := PRE_first_tail_x15_r0_body.zstores115
  zroots := PRE_first_tail_x15_r0_body.zroots115
  znC := PRE_first_tail_x15_r0_body.znC115
  ctab := PRE_first_tail_x15_r0_body.ctab115
  zbin := PRE_first_tail_x15_r0_body.zbin115
  cbridge := PRE_first_tail_x15_r0_body.cbridge115
  sbridge := bodyBridge115
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj115
  cshiftR := fun h hNL => bodyCshift115 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN115
  raised := PRE_first_tail_x15_r0_body.raised115
  cbigs := PRE_first_tail_x15_r0_body.cbigs115
  cjcl := PRE_first_tail_x15_r0_body.cjcl115
  xnLe := Nat.le_of_ble_eq_true bodyXn115
  loLe := Nat.le_of_ble_eq_true bodyLo115
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB115
  cntM := bodyCntM115
  hiLe := Nat.le_of_ble_eq_true bodyHi115
  nhiLe := Nat.le_of_ble_eq_true bodyNhi115
  jsHeap := bodyJs115
  jsRoots := bodyJsRoots115
  jsNative := bodyJsNative115
  framesEmpty := bodyFramesEmpty115
  trailOld := by decide
  lowVars := bodyLow115

def bodyQs115 : List (Option Q) := []
noncomputable def bodyEs115 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr115.map fun r => nth? PRE_first_tail_x15_r0_body.st115.S2.tab r
kernel_rfl bodyResChk115 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs115 bodyQs115) = true
kernel_rfl bodyLq115 : bodyQs115.length = PRE_first_tail_x15_r0_body.cws115.length
kernel_rfl bodyNrLo115 : PRE_first_tail_x15_r0_body.nr115.all (Nat.ble PRE_first_tail_x15_r0_body.S1117.tab.length) = true
kernel_rfl bodySub115 : (Oracles.PRE_first_tail_x15_r0_body.map_site115.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost115 : postSubB bodyM PRE_first_tail_x15_r0_body.ws115 PRE_first_tail_x15_r0_body.cws115 bodyQs115 = true
kernel_rfl bodyDrop115 : Nat.ble (42289 + (PRE_first_tail_x15_r0_body.s1118.next - PRE_first_tail_x15_r0_body.s1119.next)) 42291 = true
kernel_rfl bodyDropH115 : Nat.ble (789 + ((mlxOf PRE_first_tail_x15_r0_body.s1118.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1119.ffi).next)) 789 = true
kernel_rfl bodyDropN115 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1118.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1119.ffi).nnext)) 0 = true
kernel_rfl bodyDv115 : bodyΘ.1.take 621 = bodyΘ.1.take 621 ++ PRE_first_tail_x15_r0_body.cws115
kernel_rfl bodyDe115 : bodyΘ.2.take 621 = bodyΘ.2.take 621 ++ PRE_first_tail_x15_r0_body.nr115.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st115.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 621) (bodyΘ.2.take 621)))
kernel_rfl bodyDl115 : (bodyΘ.1.take 621).length = (bodyΘ.2.take 621).length
kernel_rfl bodyDold115 : (bodyΘ.1.take 621).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws115).isNone && !PRE_first_tail_x15_r0_body.ws115.contains v) = true
kernel_rfl bodyDfree115 : (bodyΘ.2.take 621).all (fun e => (PRE_first_tail_x15_r0_body.cws115 ++ PRE_first_tail_x15_r0_body.ws115).all fun w => e.noVar w) = true

theorem bodyStep115 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42289, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1117 PRE_first_tail_x15_r0_body.S1117)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42291, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1119 PRE_first_tail_x15_r0_body.S1119) (27 + 1) :=
  bodySite bodyFacts115.cfix bodyFacts115.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st115.S2.tab) (Es := bodyEs115) (qs := bodyQs115)
    (ok := PRE_first_tail_x15_r0_body.st115.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site115 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts115
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site115 r hr) hi (MapOk.sub hm (sub_of_all bodySub115)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk115 r hr) hi hm ho hq)
    bodyLq115 rfl bodyNrLo115 (postSub_sound bodyPost115)
    (Nat.le_of_ble_eq_true bodyDrop115) (by decide) (Nat.le_of_ble_eq_true bodyDropH115) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN115) (by decide)
    bodyDv115 bodyDe115 bodyDl115 bodyDold115 bodyDfree115 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
