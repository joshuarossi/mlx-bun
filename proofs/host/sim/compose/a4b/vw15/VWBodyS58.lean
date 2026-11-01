import host.sim.compose.a4b.vw15.VWBodyJ58
import host.sim.compose.a4b.vw15.VWBodySite58
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

theorem bodyCshift58 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S570.tab.length PRE_first_tail_x15_r0_body.s570.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P58.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P58 2558 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.s572.ffi PRE_first_tail_x15_r0_body.s571.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_58
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_58
  have hcl : SSt (· < 2558) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s572.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S570.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_58] <;> decide) PRE_first_tail_x15_r0_body.cnodesK58 PRE_first_tail_x15_r0_body.cobjsK58
      PRE_first_tail_x15_r0_body.citemsK58 PRE_first_tail_x15_r0_body.cbd58 PRE_first_tail_x15_r0_body.csst58
  exact PRE_first_tail_x15_r0_body.cshift58 bodyNcl58 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_58] at this; exact this)


kernel_rfl bodyFramesEmpty58 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s571 a).isEmpty) = true
kernel_rfl bodyJsRoots58 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s570.next) PRE_first_tail_x15_r0_body.s572.trace PRE_first_tail_x15_r0_body.s572 = true
kernel_rfl bodyJsNative58 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s572.ffi) = true
kernel_rfl bodyLow58 : (PRE_first_tail_x15_r0_body.cws58 ++ PRE_first_tail_x15_r0_body.ws58).all (Nat.ble 9) = true
kernel_rfl bodyCntM58 : countersOkB PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.s571 = true
kernel_rfl bodyHi58 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s572.ffi).next setupP.E = true
kernel_rfl bodyNhi58 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s572.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge58 : bridgeOf PRE_first_tail_x15_r0_body.s571.ffi = bridgeOf PRE_first_tail_x15_r0_body.s570.ffi
kernel_rfl bodyNN58 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s570.ffi).nnext PRE_first_tail_x15_r0_body.P58.NL = true
kernel_rfl bodyXn58 : Nat.ble (⟨19354, 16440, 2720765, 2558⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s572.ffi).next = true
kernel_rfl bodyLo58 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s572.ffi).next = true
theorem bodyFacts58 : BodySiteFacts PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.s571 PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S570 PRE_first_tail_x15_r0_body.S571 PRE_first_tail_x15_r0_body.S572
    PRE_first_tail_x15_r0_body.ws58 PRE_first_tail_x15_r0_body.cws58 PRE_first_tail_x15_r0_body.nr58 PRE_first_tail_x15_r0_body.pl58 PRE_first_tail_x15_r0_body.cl58 2720767 2558 PRE_first_tail_x15_r0_body.kd58 PRE_first_tail_x15_r0_body.kappa58 PRE_first_tail_x15_r0_body.P58
    ⟨19354, 16440, 2720765, 2558⟩ ⟨19354, 16440, 2720765, 2558⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap58
  clean := bodyClean58
  cfix := PRE_first_tail_x15_r0_body.cfix58
  zpl := PRE_first_tail_x15_r0_body.zpl58
  zplnd := PRE_first_tail_x15_r0_body.zplnd58
  zn1 := PRE_first_tail_x15_r0_body.zn158
  zfirst := PRE_first_tail_x15_r0_body.zfirst58
  zscn := PRE_first_tail_x15_r0_body.zscn58
  zsmn := PRE_first_tail_x15_r0_body.zsmn58
  zgrow := PRE_first_tail_x15_r0_body.zgrow58
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab58
  zfresh := PRE_first_tail_x15_r0_body.zfresh58
  zcnd := PRE_first_tail_x15_r0_body.zcnd58
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi58
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt58
  zgP := PRE_first_tail_x15_r0_body.zg58_2665
  zkP := PRE_first_tail_x15_r0_body.zk58_2665
  zmP := PRE_first_tail_x15_r0_body.zm58_2665
  zgC := PRE_first_tail_x15_r0_body.zg58_2673467
  zkC := PRE_first_tail_x15_r0_body.zk58_2673467
  zmC := PRE_first_tail_x15_r0_body.zm58_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw58_2673472
  zwV := PRE_first_tail_x15_r0_body.zw58_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap58
  zclbd := PRE_first_tail_x15_r0_body.zclbd58
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap58 PRE_first_tail_x15_r0_body.stFoot58 PRE_first_tail_x15_r0_body.iso58 PRE_first_tail_x15_r0_body.zwr58
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP58
  csupp := PRE_first_tail_x15_r0_body.csupp58
  cbound := PRE_first_tail_x15_r0_body.cbound58
  zimg := PRE_first_tail_x15_r0_body.zimg58
  zctl := PRE_first_tail_x15_r0_body.zctl58
  zstack := PRE_first_tail_x15_r0_body.zstack58
  zjobs := PRE_first_tail_x15_r0_body.zjobs58
  zstores := PRE_first_tail_x15_r0_body.zstores58
  zroots := PRE_first_tail_x15_r0_body.zroots58
  znC := PRE_first_tail_x15_r0_body.znC58
  ctab := PRE_first_tail_x15_r0_body.ctab58
  zbin := PRE_first_tail_x15_r0_body.zbin58
  cbridge := PRE_first_tail_x15_r0_body.cbridge58
  sbridge := bodyBridge58
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj58
  cshiftR := fun h hNL => bodyCshift58 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN58
  raised := PRE_first_tail_x15_r0_body.raised58
  cbigs := PRE_first_tail_x15_r0_body.cbigs58
  cjcl := PRE_first_tail_x15_r0_body.cjcl58
  xnLe := Nat.le_of_ble_eq_true bodyXn58
  loLe := Nat.le_of_ble_eq_true bodyLo58
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB58
  cntM := bodyCntM58
  hiLe := Nat.le_of_ble_eq_true bodyHi58
  nhiLe := Nat.le_of_ble_eq_true bodyNhi58
  jsHeap := bodyJs58
  jsRoots := bodyJsRoots58
  jsNative := bodyJsNative58
  framesEmpty := bodyFramesEmpty58
  trailOld := by decide
  lowVars := bodyLow58

def bodyQs58 : List (Option Q) := []
noncomputable def bodyEs58 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr58.map fun r => nth? PRE_first_tail_x15_r0_body.st58.S2.tab r
kernel_rfl bodyResChk58 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs58 bodyQs58) = true
kernel_rfl bodyLq58 : bodyQs58.length = PRE_first_tail_x15_r0_body.cws58.length
kernel_rfl bodyNrLo58 : PRE_first_tail_x15_r0_body.nr58.all (Nat.ble PRE_first_tail_x15_r0_body.S570.tab.length) = true
kernel_rfl bodySub58 : (Oracles.PRE_first_tail_x15_r0_body.map_site58.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost58 : postSubB bodyM PRE_first_tail_x15_r0_body.ws58 PRE_first_tail_x15_r0_body.cws58 bodyQs58 = true
kernel_rfl bodyDrop58 : Nat.ble (23390 + (PRE_first_tail_x15_r0_body.s571.next - PRE_first_tail_x15_r0_body.s572.next)) 23392 = true
kernel_rfl bodyDropH58 : Nat.ble (406 + ((mlxOf PRE_first_tail_x15_r0_body.s571.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s572.ffi).next)) 406 = true
kernel_rfl bodyDropN58 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s571.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s572.ffi).nnext)) 0 = true
kernel_rfl bodyDv58 : bodyΘ.1.take 315 = bodyΘ.1.take 315 ++ PRE_first_tail_x15_r0_body.cws58
kernel_rfl bodyDe58 : bodyΘ.2.take 315 = bodyΘ.2.take 315 ++ PRE_first_tail_x15_r0_body.nr58.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st58.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 315) (bodyΘ.2.take 315)))
kernel_rfl bodyDl58 : (bodyΘ.1.take 315).length = (bodyΘ.2.take 315).length
kernel_rfl bodyDold58 : (bodyΘ.1.take 315).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws58).isNone && !PRE_first_tail_x15_r0_body.ws58.contains v) = true
kernel_rfl bodyDfree58 : (bodyΘ.2.take 315).all (fun e => (PRE_first_tail_x15_r0_body.cws58 ++ PRE_first_tail_x15_r0_body.ws58).all fun w => e.noVar w) = true

theorem bodyStep58 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23390, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s570 PRE_first_tail_x15_r0_body.S570)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23392, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.S572) (27 + 1) :=
  bodySite bodyFacts58.cfix bodyFacts58.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st58.S2.tab) (Es := bodyEs58) (qs := bodyQs58)
    (ok := PRE_first_tail_x15_r0_body.st58.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site58 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts58
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site58 r hr) hi (MapOk.sub hm (sub_of_all bodySub58)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk58 r hr) hi hm ho hq)
    bodyLq58 rfl bodyNrLo58 (postSub_sound bodyPost58)
    (Nat.le_of_ble_eq_true bodyDrop58) (by decide) (Nat.le_of_ble_eq_true bodyDropH58) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN58) (by decide)
    bodyDv58 bodyDe58 bodyDl58 bodyDold58 bodyDfree58 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
