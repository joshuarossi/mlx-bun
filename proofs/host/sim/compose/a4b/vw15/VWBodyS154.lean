import host.sim.compose.a4b.vw15.VWBodyJ154
import host.sim.compose.a4b.vw15.VWBodySite154
import host.sim.compose.a4b.vw15.VWBodyOracles_38
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift154 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1490.tab.length PRE_first_tail_x15_r0_body.s1490.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P154.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P154 6662 PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.s1492.ffi PRE_first_tail_x15_r0_body.s1491.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_154
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_154
  have hcl : SSt (· < 6662) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1492.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1490.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_154] <;> decide) PRE_first_tail_x15_r0_body.cnodesK154 PRE_first_tail_x15_r0_body.cobjsK154
      PRE_first_tail_x15_r0_body.citemsK154 PRE_first_tail_x15_r0_body.cbd154 PRE_first_tail_x15_r0_body.csst154
  exact PRE_first_tail_x15_r0_body.cshift154 bodyNcl154 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_154] at this; exact this)


kernel_rfl bodyFramesEmpty154 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1491 a).isEmpty) = true
kernel_rfl bodyJsRoots154 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1490.next) PRE_first_tail_x15_r0_body.s1492.trace PRE_first_tail_x15_r0_body.s1492 = true
kernel_rfl bodyJsNative154 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1492.ffi) = true
kernel_rfl bodyLow154 : (PRE_first_tail_x15_r0_body.cws154 ++ PRE_first_tail_x15_r0_body.ws154).all (Nat.ble 9) = true
kernel_rfl bodyCntM154 : countersOkB PRE_first_tail_x15_r0_body.s1490 PRE_first_tail_x15_r0_body.s1491 = true
kernel_rfl bodyHi154 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1492.ffi).next setupP.E = true
kernel_rfl bodyNhi154 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1492.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge154 : bridgeOf PRE_first_tail_x15_r0_body.s1491.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1490.ffi
kernel_rfl bodyNN154 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1490.ffi).nnext PRE_first_tail_x15_r0_body.P154.NL = true
kernel_rfl bodyXn154 : Nat.ble (⟨21242, 18336, 2796097, 6662⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1492.ffi).next = true
kernel_rfl bodyLo154 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1492.ffi).next = true
theorem bodyFacts154 : BodySiteFacts PRE_first_tail_x15_r0_body.s1490 PRE_first_tail_x15_r0_body.s1491 PRE_first_tail_x15_r0_body.s1492 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1490 PRE_first_tail_x15_r0_body.S1491 PRE_first_tail_x15_r0_body.S1492
    PRE_first_tail_x15_r0_body.ws154 PRE_first_tail_x15_r0_body.cws154 PRE_first_tail_x15_r0_body.nr154 PRE_first_tail_x15_r0_body.pl154 PRE_first_tail_x15_r0_body.cl154 2796099 6662 PRE_first_tail_x15_r0_body.kd154 PRE_first_tail_x15_r0_body.kappa154 PRE_first_tail_x15_r0_body.P154
    ⟨21242, 18336, 2796097, 6662⟩ ⟨21242, 18336, 2796097, 6662⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap154
  clean := bodyClean154
  cfix := PRE_first_tail_x15_r0_body.cfix154
  zpl := PRE_first_tail_x15_r0_body.zpl154
  zplnd := PRE_first_tail_x15_r0_body.zplnd154
  zn1 := PRE_first_tail_x15_r0_body.zn1154
  zfirst := PRE_first_tail_x15_r0_body.zfirst154
  zscn := PRE_first_tail_x15_r0_body.zscn154
  zsmn := PRE_first_tail_x15_r0_body.zsmn154
  zgrow := PRE_first_tail_x15_r0_body.zgrow154
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab154
  zfresh := PRE_first_tail_x15_r0_body.zfresh154
  zcnd := PRE_first_tail_x15_r0_body.zcnd154
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi154
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt154
  zgP := PRE_first_tail_x15_r0_body.zg154_2665
  zkP := PRE_first_tail_x15_r0_body.zk154_2665
  zmP := PRE_first_tail_x15_r0_body.zm154_2665
  zgC := PRE_first_tail_x15_r0_body.zg154_2673467
  zkC := PRE_first_tail_x15_r0_body.zk154_2673467
  zmC := PRE_first_tail_x15_r0_body.zm154_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw154_2673472
  zwV := PRE_first_tail_x15_r0_body.zw154_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap154
  zclbd := PRE_first_tail_x15_r0_body.zclbd154
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap154 PRE_first_tail_x15_r0_body.stFoot154 PRE_first_tail_x15_r0_body.iso154 PRE_first_tail_x15_r0_body.zwr154
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP154
  csupp := PRE_first_tail_x15_r0_body.csupp154
  cbound := PRE_first_tail_x15_r0_body.cbound154
  zimg := PRE_first_tail_x15_r0_body.zimg154
  zctl := PRE_first_tail_x15_r0_body.zctl154
  zstack := PRE_first_tail_x15_r0_body.zstack154
  zjobs := PRE_first_tail_x15_r0_body.zjobs154
  zstores := PRE_first_tail_x15_r0_body.zstores154
  zroots := PRE_first_tail_x15_r0_body.zroots154
  znC := PRE_first_tail_x15_r0_body.znC154
  ctab := PRE_first_tail_x15_r0_body.ctab154
  zbin := PRE_first_tail_x15_r0_body.zbin154
  cbridge := PRE_first_tail_x15_r0_body.cbridge154
  sbridge := bodyBridge154
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj154
  cshiftR := fun h hNL => bodyCshift154 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN154
  raised := PRE_first_tail_x15_r0_body.raised154
  cbigs := PRE_first_tail_x15_r0_body.cbigs154
  cjcl := PRE_first_tail_x15_r0_body.cjcl154
  xnLe := Nat.le_of_ble_eq_true bodyXn154
  loLe := Nat.le_of_ble_eq_true bodyLo154
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB154
  cntM := bodyCntM154
  hiLe := Nat.le_of_ble_eq_true bodyHi154
  nhiLe := Nat.le_of_ble_eq_true bodyNhi154
  jsHeap := bodyJs154
  jsRoots := bodyJsRoots154
  jsNative := bodyJsNative154
  framesEmpty := bodyFramesEmpty154
  trailOld := by decide
  lowVars := bodyLow154

def bodyQs154 : List (Option Q) := []
noncomputable def bodyEs154 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr154.map fun r => nth? PRE_first_tail_x15_r0_body.st154.S2.tab r
kernel_rfl bodyResChk154 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs154 bodyQs154) = true
kernel_rfl bodyLq154 : bodyQs154.length = PRE_first_tail_x15_r0_body.cws154.length
kernel_rfl bodyNrLo154 : PRE_first_tail_x15_r0_body.nr154.all (Nat.ble PRE_first_tail_x15_r0_body.S1490.tab.length) = true
kernel_rfl bodySub154 : (Oracles.PRE_first_tail_x15_r0_body.map_site154.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost154 : postSubB bodyM PRE_first_tail_x15_r0_body.ws154 PRE_first_tail_x15_r0_body.cws154 bodyQs154 = true
kernel_rfl bodyDrop154 : Nat.ble (54231 + (PRE_first_tail_x15_r0_body.s1491.next - PRE_first_tail_x15_r0_body.s1492.next)) 54233 = true
kernel_rfl bodyDropH154 : Nat.ble (1022 + ((mlxOf PRE_first_tail_x15_r0_body.s1491.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1492.ffi).next)) 1022 = true
kernel_rfl bodyDropN154 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1491.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1492.ffi).nnext)) 0 = true
kernel_rfl bodyDv154 : bodyΘ.1.take 819 = bodyΘ.1.take 819 ++ PRE_first_tail_x15_r0_body.cws154
kernel_rfl bodyDe154 : bodyΘ.2.take 819 = bodyΘ.2.take 819 ++ PRE_first_tail_x15_r0_body.nr154.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st154.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 819) (bodyΘ.2.take 819)))
kernel_rfl bodyDl154 : (bodyΘ.1.take 819).length = (bodyΘ.2.take 819).length
kernel_rfl bodyDold154 : (bodyΘ.1.take 819).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws154).isNone && !PRE_first_tail_x15_r0_body.ws154.contains v) = true
kernel_rfl bodyDfree154 : (bodyΘ.2.take 819).all (fun e => (PRE_first_tail_x15_r0_body.cws154 ++ PRE_first_tail_x15_r0_body.ws154).all fun w => e.noVar w) = true

theorem bodyStep154 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨54231, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1490 PRE_first_tail_x15_r0_body.S1490)
      (bodyCut NB T tk π i x0 bodyΘ ⟨54233, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1492 PRE_first_tail_x15_r0_body.S1492) (27 + 1) :=
  bodySite bodyFacts154.cfix bodyFacts154.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st154.S2.tab) (Es := bodyEs154) (qs := bodyQs154)
    (ok := PRE_first_tail_x15_r0_body.st154.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site154 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts154
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site154 r hr) hi (MapOk.sub hm (sub_of_all bodySub154)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk154 r hr) hi hm ho hq)
    bodyLq154 rfl bodyNrLo154 (postSub_sound bodyPost154)
    (Nat.le_of_ble_eq_true bodyDrop154) (by decide) (Nat.le_of_ble_eq_true bodyDropH154) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN154) (by decide)
    bodyDv154 bodyDe154 bodyDl154 bodyDold154 bodyDfree154 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
