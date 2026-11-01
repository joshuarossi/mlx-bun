import host.sim.compose.a4b.vw15.VWBodyJ37
import host.sim.compose.a4b.vw15.VWBodySite37
import host.sim.compose.a4b.vw15.VWBodyOracles_9
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift37 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S369.tab.length PRE_first_tail_x15_r0_body.s369.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P37.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P37 1661 PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.s371.ffi PRE_first_tail_x15_r0_body.s370.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_37
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_37
  have hcl : SSt (· < 1661) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S369.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_37] <;> decide) PRE_first_tail_x15_r0_body.cnodesK37 PRE_first_tail_x15_r0_body.cobjsK37
      PRE_first_tail_x15_r0_body.citemsK37 PRE_first_tail_x15_r0_body.cbd37 PRE_first_tail_x15_r0_body.csst37
  exact PRE_first_tail_x15_r0_body.cshift37 bodyNcl37 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_37] at this; exact this)


kernel_rfl bodyFramesEmpty37 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s370 a).isEmpty) = true
kernel_rfl bodyJsRoots37 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s369.next) PRE_first_tail_x15_r0_body.s371.trace PRE_first_tail_x15_r0_body.s371 = true
kernel_rfl bodyJsNative37 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s371.ffi) = true
kernel_rfl bodyLow37 : (PRE_first_tail_x15_r0_body.cws37 ++ PRE_first_tail_x15_r0_body.ws37).all (Nat.ble 9) = true
kernel_rfl bodyCntM37 : countersOkB PRE_first_tail_x15_r0_body.s369 PRE_first_tail_x15_r0_body.s370 = true
kernel_rfl bodyHi37 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s371.ffi).next setupP.E = true
kernel_rfl bodyNhi37 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s371.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge37 : bridgeOf PRE_first_tail_x15_r0_body.s370.ffi = bridgeOf PRE_first_tail_x15_r0_body.s369.ffi
kernel_rfl bodyNN37 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s369.ffi).nnext PRE_first_tail_x15_r0_body.P37.NL = true
kernel_rfl bodyXn37 : Nat.ble (⟨18940, 16029, 2704199, 1661⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s371.ffi).next = true
kernel_rfl bodyLo37 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s371.ffi).next = true
theorem bodyFacts37 : BodySiteFacts PRE_first_tail_x15_r0_body.s369 PRE_first_tail_x15_r0_body.s370 PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S369 PRE_first_tail_x15_r0_body.S370 PRE_first_tail_x15_r0_body.S371
    PRE_first_tail_x15_r0_body.ws37 PRE_first_tail_x15_r0_body.cws37 PRE_first_tail_x15_r0_body.nr37 PRE_first_tail_x15_r0_body.pl37 PRE_first_tail_x15_r0_body.cl37 2704201 1661 PRE_first_tail_x15_r0_body.kd37 PRE_first_tail_x15_r0_body.kappa37 PRE_first_tail_x15_r0_body.P37
    ⟨18940, 16029, 2704199, 1661⟩ ⟨18940, 16029, 2704199, 1661⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap37
  clean := bodyClean37
  cfix := PRE_first_tail_x15_r0_body.cfix37
  zpl := PRE_first_tail_x15_r0_body.zpl37
  zplnd := PRE_first_tail_x15_r0_body.zplnd37
  zn1 := PRE_first_tail_x15_r0_body.zn137
  zfirst := PRE_first_tail_x15_r0_body.zfirst37
  zscn := PRE_first_tail_x15_r0_body.zscn37
  zsmn := PRE_first_tail_x15_r0_body.zsmn37
  zgrow := PRE_first_tail_x15_r0_body.zgrow37
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab37
  zfresh := PRE_first_tail_x15_r0_body.zfresh37
  zcnd := PRE_first_tail_x15_r0_body.zcnd37
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi37
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt37
  zgP := PRE_first_tail_x15_r0_body.zg37_2665
  zkP := PRE_first_tail_x15_r0_body.zk37_2665
  zmP := PRE_first_tail_x15_r0_body.zm37_2665
  zgC := PRE_first_tail_x15_r0_body.zg37_2673467
  zkC := PRE_first_tail_x15_r0_body.zk37_2673467
  zmC := PRE_first_tail_x15_r0_body.zm37_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw37_2673472
  zwV := PRE_first_tail_x15_r0_body.zw37_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap37
  zclbd := PRE_first_tail_x15_r0_body.zclbd37
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap37 PRE_first_tail_x15_r0_body.stFoot37 PRE_first_tail_x15_r0_body.iso37 PRE_first_tail_x15_r0_body.zwr37
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP37
  csupp := PRE_first_tail_x15_r0_body.csupp37
  cbound := PRE_first_tail_x15_r0_body.cbound37
  zimg := PRE_first_tail_x15_r0_body.zimg37
  zctl := PRE_first_tail_x15_r0_body.zctl37
  zstack := PRE_first_tail_x15_r0_body.zstack37
  zjobs := PRE_first_tail_x15_r0_body.zjobs37
  zstores := PRE_first_tail_x15_r0_body.zstores37
  zroots := PRE_first_tail_x15_r0_body.zroots37
  znC := PRE_first_tail_x15_r0_body.znC37
  ctab := PRE_first_tail_x15_r0_body.ctab37
  zbin := PRE_first_tail_x15_r0_body.zbin37
  cbridge := PRE_first_tail_x15_r0_body.cbridge37
  sbridge := bodyBridge37
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj37
  cshiftR := fun h hNL => bodyCshift37 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN37
  raised := PRE_first_tail_x15_r0_body.raised37
  cbigs := PRE_first_tail_x15_r0_body.cbigs37
  cjcl := PRE_first_tail_x15_r0_body.cjcl37
  xnLe := Nat.le_of_ble_eq_true bodyXn37
  loLe := Nat.le_of_ble_eq_true bodyLo37
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB37
  cntM := bodyCntM37
  hiLe := Nat.le_of_ble_eq_true bodyHi37
  nhiLe := Nat.le_of_ble_eq_true bodyNhi37
  jsHeap := bodyJs37
  jsRoots := bodyJsRoots37
  jsNative := bodyJsNative37
  framesEmpty := bodyFramesEmpty37
  trailOld := by decide
  lowVars := bodyLow37

def bodyQs37 : List (Option Q) := []
noncomputable def bodyEs37 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr37.map fun r => nth? PRE_first_tail_x15_r0_body.st37.S2.tab r
kernel_rfl bodyResChk37 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs37 bodyQs37) = true
kernel_rfl bodyLq37 : bodyQs37.length = PRE_first_tail_x15_r0_body.cws37.length
kernel_rfl bodyNrLo37 : PRE_first_tail_x15_r0_body.nr37.all (Nat.ble PRE_first_tail_x15_r0_body.S369.tab.length) = true
kernel_rfl bodySub37 : (Oracles.PRE_first_tail_x15_r0_body.map_site37.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost37 : postSubB bodyM PRE_first_tail_x15_r0_body.ws37 PRE_first_tail_x15_r0_body.cws37 bodyQs37 = true
kernel_rfl bodyDrop37 : Nat.ble (16816 + (PRE_first_tail_x15_r0_body.s370.next - PRE_first_tail_x15_r0_body.s371.next)) 16818 = true
kernel_rfl bodyDropH37 : Nat.ble (277 + ((mlxOf PRE_first_tail_x15_r0_body.s370.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s371.ffi).next)) 277 = true
kernel_rfl bodyDropN37 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s370.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s371.ffi).nnext)) 0 = true
kernel_rfl bodyDv37 : bodyΘ.1.take 207 = bodyΘ.1.take 207 ++ PRE_first_tail_x15_r0_body.cws37
kernel_rfl bodyDe37 : bodyΘ.2.take 207 = bodyΘ.2.take 207 ++ PRE_first_tail_x15_r0_body.nr37.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st37.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 207) (bodyΘ.2.take 207)))
kernel_rfl bodyDl37 : (bodyΘ.1.take 207).length = (bodyΘ.2.take 207).length
kernel_rfl bodyDold37 : (bodyΘ.1.take 207).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws37).isNone && !PRE_first_tail_x15_r0_body.ws37.contains v) = true
kernel_rfl bodyDfree37 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x15_r0_body.cws37 ++ PRE_first_tail_x15_r0_body.ws37).all fun w => e.noVar w) = true

theorem bodyStep37 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16816, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s369 PRE_first_tail_x15_r0_body.S369)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.S371) (27 + 1) :=
  bodySite bodyFacts37.cfix bodyFacts37.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st37.S2.tab) (Es := bodyEs37) (qs := bodyQs37)
    (ok := PRE_first_tail_x15_r0_body.st37.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site37 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts37
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site37 r hr) hi (MapOk.sub hm (sub_of_all bodySub37)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk37 r hr) hi hm ho hq)
    bodyLq37 rfl bodyNrLo37 (postSub_sound bodyPost37)
    (Nat.le_of_ble_eq_true bodyDrop37) (by decide) (Nat.le_of_ble_eq_true bodyDropH37) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN37) (by decide)
    bodyDv37 bodyDe37 bodyDl37 bodyDold37 bodyDfree37 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
