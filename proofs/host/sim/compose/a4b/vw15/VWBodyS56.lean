import host.sim.compose.a4b.vw15.VWBodyJ56
import host.sim.compose.a4b.vw15.VWBodySite56
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

theorem bodyCshift56 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S546.tab.length PRE_first_tail_x15_r0_body.s546.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P56.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P56 2449 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.s548.ffi PRE_first_tail_x15_r0_body.s547.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_56
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_56
  have hcl : SSt (· < 2449) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s548.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S546.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_56] <;> decide) PRE_first_tail_x15_r0_body.cnodesK56 PRE_first_tail_x15_r0_body.cobjsK56
      PRE_first_tail_x15_r0_body.citemsK56 PRE_first_tail_x15_r0_body.cbd56 PRE_first_tail_x15_r0_body.csst56
  exact PRE_first_tail_x15_r0_body.cshift56 bodyNcl56 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_56] at this; exact this)


kernel_rfl bodyFramesEmpty56 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s547 a).isEmpty) = true
kernel_rfl bodyJsRoots56 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s546.next) PRE_first_tail_x15_r0_body.s548.trace PRE_first_tail_x15_r0_body.s548 = true
kernel_rfl bodyJsNative56 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s548.ffi) = true
kernel_rfl bodyLow56 : (PRE_first_tail_x15_r0_body.cws56 ++ PRE_first_tail_x15_r0_body.ws56).all (Nat.ble 9) = true
kernel_rfl bodyCntM56 : countersOkB PRE_first_tail_x15_r0_body.s546 PRE_first_tail_x15_r0_body.s547 = true
kernel_rfl bodyHi56 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s548.ffi).next setupP.E = true
kernel_rfl bodyNhi56 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s548.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge56 : bridgeOf PRE_first_tail_x15_r0_body.s547.ffi = bridgeOf PRE_first_tail_x15_r0_body.s546.ffi
kernel_rfl bodyNN56 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s546.ffi).nnext PRE_first_tail_x15_r0_body.P56.NL = true
kernel_rfl bodyXn56 : Nat.ble (⟨19297, 16396, 2718428, 2449⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s548.ffi).next = true
kernel_rfl bodyLo56 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s548.ffi).next = true
theorem bodyFacts56 : BodySiteFacts PRE_first_tail_x15_r0_body.s546 PRE_first_tail_x15_r0_body.s547 PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S546 PRE_first_tail_x15_r0_body.S547 PRE_first_tail_x15_r0_body.S548
    PRE_first_tail_x15_r0_body.ws56 PRE_first_tail_x15_r0_body.cws56 PRE_first_tail_x15_r0_body.nr56 PRE_first_tail_x15_r0_body.pl56 PRE_first_tail_x15_r0_body.cl56 2718447 2449 PRE_first_tail_x15_r0_body.kd56 PRE_first_tail_x15_r0_body.kappa56 PRE_first_tail_x15_r0_body.P56
    ⟨19297, 16396, 2718427, 2449⟩ ⟨19297, 16396, 2718428, 2449⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap56
  clean := bodyClean56
  cfix := PRE_first_tail_x15_r0_body.cfix56
  zpl := PRE_first_tail_x15_r0_body.zpl56
  zplnd := PRE_first_tail_x15_r0_body.zplnd56
  zn1 := PRE_first_tail_x15_r0_body.zn156
  zfirst := PRE_first_tail_x15_r0_body.zfirst56
  zscn := PRE_first_tail_x15_r0_body.zscn56
  zsmn := PRE_first_tail_x15_r0_body.zsmn56
  zgrow := PRE_first_tail_x15_r0_body.zgrow56
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab56
  zfresh := PRE_first_tail_x15_r0_body.zfresh56
  zcnd := PRE_first_tail_x15_r0_body.zcnd56
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi56
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt56
  zgP := PRE_first_tail_x15_r0_body.zg56_2665
  zkP := PRE_first_tail_x15_r0_body.zk56_2665
  zmP := PRE_first_tail_x15_r0_body.zm56_2665
  zgC := PRE_first_tail_x15_r0_body.zg56_2673467
  zkC := PRE_first_tail_x15_r0_body.zk56_2673467
  zmC := PRE_first_tail_x15_r0_body.zm56_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw56_2673472
  zwV := PRE_first_tail_x15_r0_body.zw56_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap56
  zclbd := PRE_first_tail_x15_r0_body.zclbd56
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap56 PRE_first_tail_x15_r0_body.stFoot56 PRE_first_tail_x15_r0_body.iso56 PRE_first_tail_x15_r0_body.zwr56
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP56
  csupp := PRE_first_tail_x15_r0_body.csupp56
  cbound := PRE_first_tail_x15_r0_body.cbound56
  zimg := PRE_first_tail_x15_r0_body.zimg56
  zctl := PRE_first_tail_x15_r0_body.zctl56
  zstack := PRE_first_tail_x15_r0_body.zstack56
  zjobs := PRE_first_tail_x15_r0_body.zjobs56
  zstores := PRE_first_tail_x15_r0_body.zstores56
  zroots := PRE_first_tail_x15_r0_body.zroots56
  znC := PRE_first_tail_x15_r0_body.znC56
  ctab := PRE_first_tail_x15_r0_body.ctab56
  zbin := PRE_first_tail_x15_r0_body.zbin56
  cbridge := PRE_first_tail_x15_r0_body.cbridge56
  sbridge := bodyBridge56
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj56
  cshiftR := fun h hNL => bodyCshift56 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN56
  raised := PRE_first_tail_x15_r0_body.raised56
  cbigs := PRE_first_tail_x15_r0_body.cbigs56
  cjcl := PRE_first_tail_x15_r0_body.cjcl56
  xnLe := Nat.le_of_ble_eq_true bodyXn56
  loLe := Nat.le_of_ble_eq_true bodyLo56
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB56
  cntM := bodyCntM56
  hiLe := Nat.le_of_ble_eq_true bodyHi56
  nhiLe := Nat.le_of_ble_eq_true bodyNhi56
  jsHeap := bodyJs56
  jsRoots := bodyJsRoots56
  jsNative := bodyJsNative56
  framesEmpty := bodyFramesEmpty56
  trailOld := by decide
  lowVars := bodyLow56

def bodyQs56 : List (Option Q) := []
noncomputable def bodyEs56 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr56.map fun r => nth? PRE_first_tail_x15_r0_body.st56.S2.tab r
kernel_rfl bodyResChk56 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs56 bodyQs56) = true
kernel_rfl bodyLq56 : bodyQs56.length = PRE_first_tail_x15_r0_body.cws56.length
kernel_rfl bodyNrLo56 : PRE_first_tail_x15_r0_body.nr56.all (Nat.ble PRE_first_tail_x15_r0_body.S546.tab.length) = true
kernel_rfl bodySub56 : (Oracles.PRE_first_tail_x15_r0_body.map_site56.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost56 : postSubB bodyM PRE_first_tail_x15_r0_body.ws56 PRE_first_tail_x15_r0_body.cws56 bodyQs56 = true
kernel_rfl bodyDrop56 : Nat.ble (23021 + (PRE_first_tail_x15_r0_body.s547.next - PRE_first_tail_x15_r0_body.s548.next)) 23040 = true
kernel_rfl bodyDropH56 : Nat.ble (404 + ((mlxOf PRE_first_tail_x15_r0_body.s547.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s548.ffi).next)) 404 = true
kernel_rfl bodyDropN56 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s547.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s548.ffi).nnext)) 0 = true
kernel_rfl bodyDv56 : bodyΘ.1.take 306 = bodyΘ.1.take 306 ++ PRE_first_tail_x15_r0_body.cws56
kernel_rfl bodyDe56 : bodyΘ.2.take 306 = bodyΘ.2.take 306 ++ PRE_first_tail_x15_r0_body.nr56.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st56.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 306) (bodyΘ.2.take 306)))
kernel_rfl bodyDl56 : (bodyΘ.1.take 306).length = (bodyΘ.2.take 306).length
kernel_rfl bodyDold56 : (bodyΘ.1.take 306).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws56).isNone && !PRE_first_tail_x15_r0_body.ws56.contains v) = true
kernel_rfl bodyDfree56 : (bodyΘ.2.take 306).all (fun e => (PRE_first_tail_x15_r0_body.cws56 ++ PRE_first_tail_x15_r0_body.ws56).all fun w => e.noVar w) = true

theorem bodyStep56 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23021, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s546 PRE_first_tail_x15_r0_body.S546)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23040, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.S548) (206 + 1) :=
  bodySite bodyFacts56.cfix bodyFacts56.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st56.S2.tab) (Es := bodyEs56) (qs := bodyQs56)
    (ok := PRE_first_tail_x15_r0_body.st56.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site56 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts56
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site56 r hr) hi (MapOk.sub hm (sub_of_all bodySub56)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk56 r hr) hi hm ho hq)
    bodyLq56 rfl bodyNrLo56 (postSub_sound bodyPost56)
    (Nat.le_of_ble_eq_true bodyDrop56) (by decide) (Nat.le_of_ble_eq_true bodyDropH56) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN56) (by decide)
    bodyDv56 bodyDe56 bodyDl56 bodyDold56 bodyDfree56 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
