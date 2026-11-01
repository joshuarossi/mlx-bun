import host.sim.compose.a4b.vw15.VWBodyJ13
import host.sim.compose.a4b.vw15.VWBodySite13
import host.sim.compose.a4b.vw15.VWBodyOracles_3
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift13 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S139.tab.length PRE_first_tail_x15_r0_body.s139.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P13.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P13 635 PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.s141.ffi PRE_first_tail_x15_r0_body.s140.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_13
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_13
  have hcl : SSt (· < 635) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s141.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S139.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_13] <;> decide) PRE_first_tail_x15_r0_body.cnodesK13 PRE_first_tail_x15_r0_body.cobjsK13
      PRE_first_tail_x15_r0_body.citemsK13 PRE_first_tail_x15_r0_body.cbd13 PRE_first_tail_x15_r0_body.csst13
  exact PRE_first_tail_x15_r0_body.cshift13 bodyNcl13 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_13] at this; exact this)


kernel_rfl bodyFramesEmpty13 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s140 a).isEmpty) = true
kernel_rfl bodyJsRoots13 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s139.next) PRE_first_tail_x15_r0_body.s141.trace PRE_first_tail_x15_r0_body.s141 = true
kernel_rfl bodyJsNative13 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s141.ffi) = true
kernel_rfl bodyLow13 : (PRE_first_tail_x15_r0_body.cws13 ++ PRE_first_tail_x15_r0_body.ws13).all (Nat.ble 9) = true
kernel_rfl bodyCntM13 : countersOkB PRE_first_tail_x15_r0_body.s139 PRE_first_tail_x15_r0_body.s140 = true
kernel_rfl bodyHi13 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s141.ffi).next setupP.E = true
kernel_rfl bodyNhi13 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s141.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge13 : bridgeOf PRE_first_tail_x15_r0_body.s140.ffi = bridgeOf PRE_first_tail_x15_r0_body.s139.ffi
kernel_rfl bodyNN13 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s139.ffi).nnext PRE_first_tail_x15_r0_body.P13.NL = true
kernel_rfl bodyXn13 : Nat.ble (⟨18468, 15555, 2685371, 635⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s141.ffi).next = true
kernel_rfl bodyLo13 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s141.ffi).next = true
theorem bodyFacts13 : BodySiteFacts PRE_first_tail_x15_r0_body.s139 PRE_first_tail_x15_r0_body.s140 PRE_first_tail_x15_r0_body.s141 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S139 PRE_first_tail_x15_r0_body.S140 PRE_first_tail_x15_r0_body.S141
    PRE_first_tail_x15_r0_body.ws13 PRE_first_tail_x15_r0_body.cws13 PRE_first_tail_x15_r0_body.nr13 PRE_first_tail_x15_r0_body.pl13 PRE_first_tail_x15_r0_body.cl13 2685373 635 PRE_first_tail_x15_r0_body.kd13 PRE_first_tail_x15_r0_body.kappa13 PRE_first_tail_x15_r0_body.P13
    ⟨18468, 15555, 2685371, 635⟩ ⟨18468, 15555, 2685371, 635⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap13
  clean := bodyClean13
  cfix := PRE_first_tail_x15_r0_body.cfix13
  zpl := PRE_first_tail_x15_r0_body.zpl13
  zplnd := PRE_first_tail_x15_r0_body.zplnd13
  zn1 := PRE_first_tail_x15_r0_body.zn113
  zfirst := PRE_first_tail_x15_r0_body.zfirst13
  zscn := PRE_first_tail_x15_r0_body.zscn13
  zsmn := PRE_first_tail_x15_r0_body.zsmn13
  zgrow := PRE_first_tail_x15_r0_body.zgrow13
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab13
  zfresh := PRE_first_tail_x15_r0_body.zfresh13
  zcnd := PRE_first_tail_x15_r0_body.zcnd13
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi13
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt13
  zgP := PRE_first_tail_x15_r0_body.zg13_2665
  zkP := PRE_first_tail_x15_r0_body.zk13_2665
  zmP := PRE_first_tail_x15_r0_body.zm13_2665
  zgC := PRE_first_tail_x15_r0_body.zg13_2673467
  zkC := PRE_first_tail_x15_r0_body.zk13_2673467
  zmC := PRE_first_tail_x15_r0_body.zm13_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw13_2673472
  zwV := PRE_first_tail_x15_r0_body.zw13_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap13
  zclbd := PRE_first_tail_x15_r0_body.zclbd13
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap13 PRE_first_tail_x15_r0_body.stFoot13 PRE_first_tail_x15_r0_body.iso13 PRE_first_tail_x15_r0_body.zwr13
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP13
  csupp := PRE_first_tail_x15_r0_body.csupp13
  cbound := PRE_first_tail_x15_r0_body.cbound13
  zimg := PRE_first_tail_x15_r0_body.zimg13
  zctl := PRE_first_tail_x15_r0_body.zctl13
  zstack := PRE_first_tail_x15_r0_body.zstack13
  zjobs := PRE_first_tail_x15_r0_body.zjobs13
  zstores := PRE_first_tail_x15_r0_body.zstores13
  zroots := PRE_first_tail_x15_r0_body.zroots13
  znC := PRE_first_tail_x15_r0_body.znC13
  ctab := PRE_first_tail_x15_r0_body.ctab13
  zbin := PRE_first_tail_x15_r0_body.zbin13
  cbridge := PRE_first_tail_x15_r0_body.cbridge13
  sbridge := bodyBridge13
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj13
  cshiftR := fun h hNL => bodyCshift13 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN13
  raised := PRE_first_tail_x15_r0_body.raised13
  cbigs := PRE_first_tail_x15_r0_body.cbigs13
  cjcl := PRE_first_tail_x15_r0_body.cjcl13
  xnLe := Nat.le_of_ble_eq_true bodyXn13
  loLe := Nat.le_of_ble_eq_true bodyLo13
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB13
  cntM := bodyCntM13
  hiLe := Nat.le_of_ble_eq_true bodyHi13
  nhiLe := Nat.le_of_ble_eq_true bodyNhi13
  jsHeap := bodyJs13
  jsRoots := bodyJsRoots13
  jsNative := bodyJsNative13
  framesEmpty := bodyFramesEmpty13
  trailOld := by decide
  lowVars := bodyLow13

def bodyQs13 : List (Option Q) := []
noncomputable def bodyEs13 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr13.map fun r => nth? PRE_first_tail_x15_r0_body.st13.S2.tab r
kernel_rfl bodyResChk13 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs13 bodyQs13) = true
kernel_rfl bodyLq13 : bodyQs13.length = PRE_first_tail_x15_r0_body.cws13.length
kernel_rfl bodyNrLo13 : PRE_first_tail_x15_r0_body.nr13.all (Nat.ble PRE_first_tail_x15_r0_body.S139.tab.length) = true
kernel_rfl bodySub13 : (Oracles.PRE_first_tail_x15_r0_body.map_site13.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost13 : postSubB bodyM PRE_first_tail_x15_r0_body.ws13 PRE_first_tail_x15_r0_body.cws13 bodyQs13 = true
kernel_rfl bodyDrop13 : Nat.ble (9117 + (PRE_first_tail_x15_r0_body.s140.next - PRE_first_tail_x15_r0_body.s141.next)) 9119 = true
kernel_rfl bodyDropH13 : Nat.ble (123 + ((mlxOf PRE_first_tail_x15_r0_body.s140.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s141.ffi).next)) 123 = true
kernel_rfl bodyDropN13 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s140.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s141.ffi).nnext)) 0 = true
kernel_rfl bodyDv13 : bodyΘ.1.take 81 = bodyΘ.1.take 81 ++ PRE_first_tail_x15_r0_body.cws13
kernel_rfl bodyDe13 : bodyΘ.2.take 81 = bodyΘ.2.take 81 ++ PRE_first_tail_x15_r0_body.nr13.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st13.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 81) (bodyΘ.2.take 81)))
kernel_rfl bodyDl13 : (bodyΘ.1.take 81).length = (bodyΘ.2.take 81).length
kernel_rfl bodyDold13 : (bodyΘ.1.take 81).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws13).isNone && !PRE_first_tail_x15_r0_body.ws13.contains v) = true
kernel_rfl bodyDfree13 : (bodyΘ.2.take 81).all (fun e => (PRE_first_tail_x15_r0_body.cws13 ++ PRE_first_tail_x15_r0_body.ws13).all fun w => e.noVar w) = true

theorem bodyStep13 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s139 PRE_first_tail_x15_r0_body.S139)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s141 PRE_first_tail_x15_r0_body.S141) (27 + 1) :=
  bodySite bodyFacts13.cfix bodyFacts13.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st13.S2.tab) (Es := bodyEs13) (qs := bodyQs13)
    (ok := PRE_first_tail_x15_r0_body.st13.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site13 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts13
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site13 r hr) hi (MapOk.sub hm (sub_of_all bodySub13)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk13 r hr) hi hm ho hq)
    bodyLq13 rfl bodyNrLo13 (postSub_sound bodyPost13)
    (Nat.le_of_ble_eq_true bodyDrop13) (by decide) (Nat.le_of_ble_eq_true bodyDropH13) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN13) (by decide)
    bodyDv13 bodyDe13 bodyDl13 bodyDold13 bodyDfree13 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
