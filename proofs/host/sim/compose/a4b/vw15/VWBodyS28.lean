import host.sim.compose.a4b.vw15.VWBodyJ28
import host.sim.compose.a4b.vw15.VWBodySite28
import host.sim.compose.a4b.vw15.VWBodyOracles_7
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift28 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S283.tab.length PRE_first_tail_x15_r0_body.s283.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P28.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P28 1277 PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.s285.ffi PRE_first_tail_x15_r0_body.s284.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_28
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_28
  have hcl : SSt (· < 1277) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S283.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_28] <;> decide) PRE_first_tail_x15_r0_body.cnodesK28 PRE_first_tail_x15_r0_body.cobjsK28
      PRE_first_tail_x15_r0_body.citemsK28 PRE_first_tail_x15_r0_body.cbd28 PRE_first_tail_x15_r0_body.csst28
  exact PRE_first_tail_x15_r0_body.cshift28 bodyNcl28 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_28] at this; exact this)


kernel_rfl bodyFramesEmpty28 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s284 a).isEmpty) = true
kernel_rfl bodyJsRoots28 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s283.next) PRE_first_tail_x15_r0_body.s285.trace PRE_first_tail_x15_r0_body.s285 = true
kernel_rfl bodyJsNative28 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s285.ffi) = true
kernel_rfl bodyLow28 : (PRE_first_tail_x15_r0_body.cws28 ++ PRE_first_tail_x15_r0_body.ws28).all (Nat.ble 9) = true
kernel_rfl bodyCntM28 : countersOkB PRE_first_tail_x15_r0_body.s283 PRE_first_tail_x15_r0_body.s284 = true
kernel_rfl bodyHi28 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s285.ffi).next setupP.E = true
kernel_rfl bodyNhi28 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s285.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge28 : bridgeOf PRE_first_tail_x15_r0_body.s284.ffi = bridgeOf PRE_first_tail_x15_r0_body.s283.ffi
kernel_rfl bodyNN28 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s283.ffi).nnext PRE_first_tail_x15_r0_body.P28.NL = true
kernel_rfl bodyXn28 : Nat.ble (⟨18761, 15855, 2697039, 1277⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s285.ffi).next = true
kernel_rfl bodyLo28 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s285.ffi).next = true
theorem bodyFacts28 : BodySiteFacts PRE_first_tail_x15_r0_body.s283 PRE_first_tail_x15_r0_body.s284 PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S283 PRE_first_tail_x15_r0_body.S284 PRE_first_tail_x15_r0_body.S285
    PRE_first_tail_x15_r0_body.ws28 PRE_first_tail_x15_r0_body.cws28 PRE_first_tail_x15_r0_body.nr28 PRE_first_tail_x15_r0_body.pl28 PRE_first_tail_x15_r0_body.cl28 2697041 1277 PRE_first_tail_x15_r0_body.kd28 PRE_first_tail_x15_r0_body.kappa28 PRE_first_tail_x15_r0_body.P28
    ⟨18761, 15855, 2697039, 1277⟩ ⟨18761, 15855, 2697039, 1277⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap28
  clean := bodyClean28
  cfix := PRE_first_tail_x15_r0_body.cfix28
  zpl := PRE_first_tail_x15_r0_body.zpl28
  zplnd := PRE_first_tail_x15_r0_body.zplnd28
  zn1 := PRE_first_tail_x15_r0_body.zn128
  zfirst := PRE_first_tail_x15_r0_body.zfirst28
  zscn := PRE_first_tail_x15_r0_body.zscn28
  zsmn := PRE_first_tail_x15_r0_body.zsmn28
  zgrow := PRE_first_tail_x15_r0_body.zgrow28
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab28
  zfresh := PRE_first_tail_x15_r0_body.zfresh28
  zcnd := PRE_first_tail_x15_r0_body.zcnd28
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi28
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt28
  zgP := PRE_first_tail_x15_r0_body.zg28_2665
  zkP := PRE_first_tail_x15_r0_body.zk28_2665
  zmP := PRE_first_tail_x15_r0_body.zm28_2665
  zgC := PRE_first_tail_x15_r0_body.zg28_2673467
  zkC := PRE_first_tail_x15_r0_body.zk28_2673467
  zmC := PRE_first_tail_x15_r0_body.zm28_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw28_2673472
  zwV := PRE_first_tail_x15_r0_body.zw28_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap28
  zclbd := PRE_first_tail_x15_r0_body.zclbd28
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap28 PRE_first_tail_x15_r0_body.stFoot28 PRE_first_tail_x15_r0_body.iso28 PRE_first_tail_x15_r0_body.zwr28
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP28
  csupp := PRE_first_tail_x15_r0_body.csupp28
  cbound := PRE_first_tail_x15_r0_body.cbound28
  zimg := PRE_first_tail_x15_r0_body.zimg28
  zctl := PRE_first_tail_x15_r0_body.zctl28
  zstack := PRE_first_tail_x15_r0_body.zstack28
  zjobs := PRE_first_tail_x15_r0_body.zjobs28
  zstores := PRE_first_tail_x15_r0_body.zstores28
  zroots := PRE_first_tail_x15_r0_body.zroots28
  znC := PRE_first_tail_x15_r0_body.znC28
  ctab := PRE_first_tail_x15_r0_body.ctab28
  zbin := PRE_first_tail_x15_r0_body.zbin28
  cbridge := PRE_first_tail_x15_r0_body.cbridge28
  sbridge := bodyBridge28
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj28
  cshiftR := fun h hNL => bodyCshift28 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN28
  raised := PRE_first_tail_x15_r0_body.raised28
  cbigs := PRE_first_tail_x15_r0_body.cbigs28
  cjcl := PRE_first_tail_x15_r0_body.cjcl28
  xnLe := Nat.le_of_ble_eq_true bodyXn28
  loLe := Nat.le_of_ble_eq_true bodyLo28
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB28
  cntM := bodyCntM28
  hiLe := Nat.le_of_ble_eq_true bodyHi28
  nhiLe := Nat.le_of_ble_eq_true bodyNhi28
  jsHeap := bodyJs28
  jsRoots := bodyJsRoots28
  jsNative := bodyJsNative28
  framesEmpty := bodyFramesEmpty28
  trailOld := by decide
  lowVars := bodyLow28

def bodyQs28 : List (Option Q) := []
noncomputable def bodyEs28 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr28.map fun r => nth? PRE_first_tail_x15_r0_body.st28.S2.tab r
kernel_rfl bodyResChk28 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs28 bodyQs28) = true
kernel_rfl bodyLq28 : bodyQs28.length = PRE_first_tail_x15_r0_body.cws28.length
kernel_rfl bodyNrLo28 : PRE_first_tail_x15_r0_body.nr28.all (Nat.ble PRE_first_tail_x15_r0_body.S283.tab.length) = true
kernel_rfl bodySub28 : (Oracles.PRE_first_tail_x15_r0_body.map_site28.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost28 : postSubB bodyM PRE_first_tail_x15_r0_body.ws28 PRE_first_tail_x15_r0_body.cws28 bodyQs28 = true
kernel_rfl bodyDrop28 : Nat.ble (14123 + (PRE_first_tail_x15_r0_body.s284.next - PRE_first_tail_x15_r0_body.s285.next)) 14125 = true
kernel_rfl bodyDropH28 : Nat.ble (225 + ((mlxOf PRE_first_tail_x15_r0_body.s284.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s285.ffi).next)) 225 = true
kernel_rfl bodyDropN28 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s284.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s285.ffi).nnext)) 0 = true
kernel_rfl bodyDv28 : bodyΘ.1.take 162 = bodyΘ.1.take 162 ++ PRE_first_tail_x15_r0_body.cws28
kernel_rfl bodyDe28 : bodyΘ.2.take 162 = bodyΘ.2.take 162 ++ PRE_first_tail_x15_r0_body.nr28.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st28.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 162) (bodyΘ.2.take 162)))
kernel_rfl bodyDl28 : (bodyΘ.1.take 162).length = (bodyΘ.2.take 162).length
kernel_rfl bodyDold28 : (bodyΘ.1.take 162).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws28).isNone && !PRE_first_tail_x15_r0_body.ws28.contains v) = true
kernel_rfl bodyDfree28 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x15_r0_body.cws28 ++ PRE_first_tail_x15_r0_body.ws28).all fun w => e.noVar w) = true

theorem bodyStep28 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s283 PRE_first_tail_x15_r0_body.S283)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.S285) (27 + 1) :=
  bodySite bodyFacts28.cfix bodyFacts28.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st28.S2.tab) (Es := bodyEs28) (qs := bodyQs28)
    (ok := PRE_first_tail_x15_r0_body.st28.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site28 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts28
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site28 r hr) hi (MapOk.sub hm (sub_of_all bodySub28)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk28 r hr) hi hm ho hq)
    bodyLq28 rfl bodyNrLo28 (postSub_sound bodyPost28)
    (Nat.le_of_ble_eq_true bodyDrop28) (by decide) (Nat.le_of_ble_eq_true bodyDropH28) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN28) (by decide)
    bodyDv28 bodyDe28 bodyDl28 bodyDold28 bodyDfree28 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
