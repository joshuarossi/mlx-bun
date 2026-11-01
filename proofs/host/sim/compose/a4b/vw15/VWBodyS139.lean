import host.sim.compose.a4b.vw15.VWBodyJ139
import host.sim.compose.a4b.vw15.VWBodySite139
import host.sim.compose.a4b.vw15.VWBodyOracles_34
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift139 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1347.tab.length PRE_first_tail_x15_r0_body.s1347.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P139.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.s1349.ffi PRE_first_tail_x15_r0_body.s1348.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_139
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_139
  have hcl : SSt (· < 6023) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1347.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_139] <;> decide) PRE_first_tail_x15_r0_body.cnodesK139 PRE_first_tail_x15_r0_body.cobjsK139
      PRE_first_tail_x15_r0_body.citemsK139 PRE_first_tail_x15_r0_body.cbd139 PRE_first_tail_x15_r0_body.csst139
  exact PRE_first_tail_x15_r0_body.cshift139 bodyNcl139 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_139] at this; exact this)


kernel_rfl bodyFramesEmpty139 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1348 a).isEmpty) = true
kernel_rfl bodyJsRoots139 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1347.next) PRE_first_tail_x15_r0_body.s1349.trace PRE_first_tail_x15_r0_body.s1349 = true
kernel_rfl bodyJsNative139 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1349.ffi) = true
kernel_rfl bodyLow139 : (PRE_first_tail_x15_r0_body.cws139 ++ PRE_first_tail_x15_r0_body.ws139).all (Nat.ble 9) = true
kernel_rfl bodyCntM139 : countersOkB PRE_first_tail_x15_r0_body.s1347 PRE_first_tail_x15_r0_body.s1348 = true
kernel_rfl bodyHi139 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1349.ffi).next setupP.E = true
kernel_rfl bodyNhi139 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1349.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge139 : bridgeOf PRE_first_tail_x15_r0_body.s1348.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1347.ffi
kernel_rfl bodyNN139 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1347.ffi).nnext PRE_first_tail_x15_r0_body.P139.NL = true
kernel_rfl bodyXn139 : Nat.ble (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1349.ffi).next = true
kernel_rfl bodyLo139 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1349.ffi).next = true
theorem bodyFacts139 : BodySiteFacts PRE_first_tail_x15_r0_body.s1347 PRE_first_tail_x15_r0_body.s1348 PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1347 PRE_first_tail_x15_r0_body.S1348 PRE_first_tail_x15_r0_body.S1349
    PRE_first_tail_x15_r0_body.ws139 PRE_first_tail_x15_r0_body.cws139 PRE_first_tail_x15_r0_body.nr139 PRE_first_tail_x15_r0_body.pl139 PRE_first_tail_x15_r0_body.cl139 2784049 6023 PRE_first_tail_x15_r0_body.kd139 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.P139
    ⟨20942, 18051, 2784047, 6023⟩ ⟨20942, 18051, 2784047, 6023⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap139
  clean := bodyClean139
  cfix := PRE_first_tail_x15_r0_body.cfix139
  zpl := PRE_first_tail_x15_r0_body.zpl139
  zplnd := PRE_first_tail_x15_r0_body.zplnd139
  zn1 := PRE_first_tail_x15_r0_body.zn1139
  zfirst := PRE_first_tail_x15_r0_body.zfirst139
  zscn := PRE_first_tail_x15_r0_body.zscn139
  zsmn := PRE_first_tail_x15_r0_body.zsmn139
  zgrow := PRE_first_tail_x15_r0_body.zgrow139
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab139
  zfresh := PRE_first_tail_x15_r0_body.zfresh139
  zcnd := PRE_first_tail_x15_r0_body.zcnd139
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi139
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt139
  zgP := PRE_first_tail_x15_r0_body.zg139_2665
  zkP := PRE_first_tail_x15_r0_body.zk139_2665
  zmP := PRE_first_tail_x15_r0_body.zm139_2665
  zgC := PRE_first_tail_x15_r0_body.zg139_2673467
  zkC := PRE_first_tail_x15_r0_body.zk139_2673467
  zmC := PRE_first_tail_x15_r0_body.zm139_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw139_2673472
  zwV := PRE_first_tail_x15_r0_body.zw139_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap139
  zclbd := PRE_first_tail_x15_r0_body.zclbd139
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap139 PRE_first_tail_x15_r0_body.stFoot139 PRE_first_tail_x15_r0_body.iso139 PRE_first_tail_x15_r0_body.zwr139
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP139
  csupp := PRE_first_tail_x15_r0_body.csupp139
  cbound := PRE_first_tail_x15_r0_body.cbound139
  zimg := PRE_first_tail_x15_r0_body.zimg139
  zctl := PRE_first_tail_x15_r0_body.zctl139
  zstack := PRE_first_tail_x15_r0_body.zstack139
  zjobs := PRE_first_tail_x15_r0_body.zjobs139
  zstores := PRE_first_tail_x15_r0_body.zstores139
  zroots := PRE_first_tail_x15_r0_body.zroots139
  znC := PRE_first_tail_x15_r0_body.znC139
  ctab := PRE_first_tail_x15_r0_body.ctab139
  zbin := PRE_first_tail_x15_r0_body.zbin139
  cbridge := PRE_first_tail_x15_r0_body.cbridge139
  sbridge := bodyBridge139
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj139
  cshiftR := fun h hNL => bodyCshift139 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN139
  raised := PRE_first_tail_x15_r0_body.raised139
  cbigs := PRE_first_tail_x15_r0_body.cbigs139
  cjcl := PRE_first_tail_x15_r0_body.cjcl139
  xnLe := Nat.le_of_ble_eq_true bodyXn139
  loLe := Nat.le_of_ble_eq_true bodyLo139
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB139
  cntM := bodyCntM139
  hiLe := Nat.le_of_ble_eq_true bodyHi139
  nhiLe := Nat.le_of_ble_eq_true bodyNhi139
  jsHeap := bodyJs139
  jsRoots := bodyJsRoots139
  jsNative := bodyJsNative139
  framesEmpty := bodyFramesEmpty139
  trailOld := by decide
  lowVars := bodyLow139

def bodyQs139 : List (Option Q) := []
noncomputable def bodyEs139 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr139.map fun r => nth? PRE_first_tail_x15_r0_body.st139.S2.tab r
kernel_rfl bodyResChk139 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs139 bodyQs139) = true
kernel_rfl bodyLq139 : bodyQs139.length = PRE_first_tail_x15_r0_body.cws139.length
kernel_rfl bodyNrLo139 : PRE_first_tail_x15_r0_body.nr139.all (Nat.ble PRE_first_tail_x15_r0_body.S1347.tab.length) = true
kernel_rfl bodySub139 : (Oracles.PRE_first_tail_x15_r0_body.map_site139.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost139 : postSubB bodyM PRE_first_tail_x15_r0_body.ws139 PRE_first_tail_x15_r0_body.cws139 bodyQs139 = true
kernel_rfl bodyDrop139 : Nat.ble (49988 + (PRE_first_tail_x15_r0_body.s1348.next - PRE_first_tail_x15_r0_body.s1349.next)) 49990 = true
kernel_rfl bodyDropH139 : Nat.ble (943 + ((mlxOf PRE_first_tail_x15_r0_body.s1348.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1349.ffi).next)) 943 = true
kernel_rfl bodyDropN139 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1348.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1349.ffi).nnext)) 0 = true
kernel_rfl bodyDv139 : bodyΘ.1.take 747 = bodyΘ.1.take 747 ++ PRE_first_tail_x15_r0_body.cws139
kernel_rfl bodyDe139 : bodyΘ.2.take 747 = bodyΘ.2.take 747 ++ PRE_first_tail_x15_r0_body.nr139.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st139.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 747) (bodyΘ.2.take 747)))
kernel_rfl bodyDl139 : (bodyΘ.1.take 747).length = (bodyΘ.2.take 747).length
kernel_rfl bodyDold139 : (bodyΘ.1.take 747).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws139).isNone && !PRE_first_tail_x15_r0_body.ws139.contains v) = true
kernel_rfl bodyDfree139 : (bodyΘ.2.take 747).all (fun e => (PRE_first_tail_x15_r0_body.cws139 ++ PRE_first_tail_x15_r0_body.ws139).all fun w => e.noVar w) = true

theorem bodyStep139 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49988, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1347 PRE_first_tail_x15_r0_body.S1347)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49990, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.S1349) (27 + 1) :=
  bodySite bodyFacts139.cfix bodyFacts139.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st139.S2.tab) (Es := bodyEs139) (qs := bodyQs139)
    (ok := PRE_first_tail_x15_r0_body.st139.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site139 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts139
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site139 r hr) hi (MapOk.sub hm (sub_of_all bodySub139)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk139 r hr) hi hm ho hq)
    bodyLq139 rfl bodyNrLo139 (postSub_sound bodyPost139)
    (Nat.le_of_ble_eq_true bodyDrop139) (by decide) (Nat.le_of_ble_eq_true bodyDropH139) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN139) (by decide)
    bodyDv139 bodyDe139 bodyDl139 bodyDold139 bodyDfree139 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
