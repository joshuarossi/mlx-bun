import host.sim.compose.a4b.vw15.VWBodyJ104
import host.sim.compose.a4b.vw15.VWBodySite104
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

theorem bodyCshift104 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1006.tab.length PRE_first_tail_x15_r0_body.s1006.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P104.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P104 4501 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.s1008.ffi PRE_first_tail_x15_r0_body.s1007.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_104
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_104
  have hcl : SSt (· < 4501) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1008.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1006.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_104] <;> decide) PRE_first_tail_x15_r0_body.cnodesK104 PRE_first_tail_x15_r0_body.cobjsK104
      PRE_first_tail_x15_r0_body.citemsK104 PRE_first_tail_x15_r0_body.cbd104 PRE_first_tail_x15_r0_body.csst104
  exact PRE_first_tail_x15_r0_body.cshift104 bodyNcl104 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_104] at this; exact this)


kernel_rfl bodyFramesEmpty104 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1007 a).isEmpty) = true
kernel_rfl bodyJsRoots104 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1006.next) PRE_first_tail_x15_r0_body.s1008.trace PRE_first_tail_x15_r0_body.s1008 = true
kernel_rfl bodyJsNative104 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1008.ffi) = true
kernel_rfl bodyLow104 : (PRE_first_tail_x15_r0_body.cws104 ++ PRE_first_tail_x15_r0_body.ws104).all (Nat.ble 9) = true
kernel_rfl bodyCntM104 : countersOkB PRE_first_tail_x15_r0_body.s1006 PRE_first_tail_x15_r0_body.s1007 = true
kernel_rfl bodyHi104 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1008.ffi).next setupP.E = true
kernel_rfl bodyNhi104 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1008.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge104 : bridgeOf PRE_first_tail_x15_r0_body.s1007.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1006.ffi
kernel_rfl bodyNN104 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1006.ffi).nnext PRE_first_tail_x15_r0_body.P104.NL = true
kernel_rfl bodyXn104 : Nat.ble (⟨20241, 17344, 2756096, 4501⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1008.ffi).next = true
kernel_rfl bodyLo104 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1008.ffi).next = true
theorem bodyFacts104 : BodySiteFacts PRE_first_tail_x15_r0_body.s1006 PRE_first_tail_x15_r0_body.s1007 PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1006 PRE_first_tail_x15_r0_body.S1007 PRE_first_tail_x15_r0_body.S1008
    PRE_first_tail_x15_r0_body.ws104 PRE_first_tail_x15_r0_body.cws104 PRE_first_tail_x15_r0_body.nr104 PRE_first_tail_x15_r0_body.pl104 PRE_first_tail_x15_r0_body.cl104 2756106 4501 PRE_first_tail_x15_r0_body.kd104 PRE_first_tail_x15_r0_body.kappa104 PRE_first_tail_x15_r0_body.P104
    ⟨20241, 17344, 2756095, 4501⟩ ⟨20241, 17344, 2756096, 4501⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap104
  clean := bodyClean104
  cfix := PRE_first_tail_x15_r0_body.cfix104
  zpl := PRE_first_tail_x15_r0_body.zpl104
  zplnd := PRE_first_tail_x15_r0_body.zplnd104
  zn1 := PRE_first_tail_x15_r0_body.zn1104
  zfirst := PRE_first_tail_x15_r0_body.zfirst104
  zscn := PRE_first_tail_x15_r0_body.zscn104
  zsmn := PRE_first_tail_x15_r0_body.zsmn104
  zgrow := PRE_first_tail_x15_r0_body.zgrow104
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab104
  zfresh := PRE_first_tail_x15_r0_body.zfresh104
  zcnd := PRE_first_tail_x15_r0_body.zcnd104
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi104
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt104
  zgP := PRE_first_tail_x15_r0_body.zg104_2665
  zkP := PRE_first_tail_x15_r0_body.zk104_2665
  zmP := PRE_first_tail_x15_r0_body.zm104_2665
  zgC := PRE_first_tail_x15_r0_body.zg104_2673467
  zkC := PRE_first_tail_x15_r0_body.zk104_2673467
  zmC := PRE_first_tail_x15_r0_body.zm104_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw104_2673472
  zwV := PRE_first_tail_x15_r0_body.zw104_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap104
  zclbd := PRE_first_tail_x15_r0_body.zclbd104
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap104 PRE_first_tail_x15_r0_body.stFoot104 PRE_first_tail_x15_r0_body.iso104 PRE_first_tail_x15_r0_body.zwr104
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP104
  csupp := PRE_first_tail_x15_r0_body.csupp104
  cbound := PRE_first_tail_x15_r0_body.cbound104
  zimg := PRE_first_tail_x15_r0_body.zimg104
  zctl := PRE_first_tail_x15_r0_body.zctl104
  zstack := PRE_first_tail_x15_r0_body.zstack104
  zjobs := PRE_first_tail_x15_r0_body.zjobs104
  zstores := PRE_first_tail_x15_r0_body.zstores104
  zroots := PRE_first_tail_x15_r0_body.zroots104
  znC := PRE_first_tail_x15_r0_body.znC104
  ctab := PRE_first_tail_x15_r0_body.ctab104
  zbin := PRE_first_tail_x15_r0_body.zbin104
  cbridge := PRE_first_tail_x15_r0_body.cbridge104
  sbridge := bodyBridge104
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj104
  cshiftR := fun h hNL => bodyCshift104 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN104
  raised := PRE_first_tail_x15_r0_body.raised104
  cbigs := PRE_first_tail_x15_r0_body.cbigs104
  cjcl := PRE_first_tail_x15_r0_body.cjcl104
  xnLe := Nat.le_of_ble_eq_true bodyXn104
  loLe := Nat.le_of_ble_eq_true bodyLo104
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB104
  cntM := bodyCntM104
  hiLe := Nat.le_of_ble_eq_true bodyHi104
  nhiLe := Nat.le_of_ble_eq_true bodyNhi104
  jsHeap := bodyJs104
  jsRoots := bodyJsRoots104
  jsNative := bodyJsNative104
  framesEmpty := bodyFramesEmpty104
  trailOld := by decide
  lowVars := bodyLow104

def bodyQs104 : List (Option Q) := []
noncomputable def bodyEs104 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr104.map fun r => nth? PRE_first_tail_x15_r0_body.st104.S2.tab r
kernel_rfl bodyResChk104 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs104 bodyQs104) = true
kernel_rfl bodyLq104 : bodyQs104.length = PRE_first_tail_x15_r0_body.cws104.length
kernel_rfl bodyNrLo104 : PRE_first_tail_x15_r0_body.nr104.all (Nat.ble PRE_first_tail_x15_r0_body.S1006.tab.length) = true
kernel_rfl bodySub104 : (Oracles.PRE_first_tail_x15_r0_body.map_site104.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost104 : postSubB bodyM PRE_first_tail_x15_r0_body.ws104 PRE_first_tail_x15_r0_body.cws104 bodyQs104 = true
kernel_rfl bodyDrop104 : Nat.ble (38446 + (PRE_first_tail_x15_r0_body.s1007.next - PRE_first_tail_x15_r0_body.s1008.next)) 38456 = true
kernel_rfl bodyDropH104 : Nat.ble (712 + ((mlxOf PRE_first_tail_x15_r0_body.s1007.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1008.ffi).next)) 712 = true
kernel_rfl bodyDropN104 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1007.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1008.ffi).nnext)) 0 = true
kernel_rfl bodyDv104 : bodyΘ.1.take 558 = bodyΘ.1.take 558 ++ PRE_first_tail_x15_r0_body.cws104
kernel_rfl bodyDe104 : bodyΘ.2.take 558 = bodyΘ.2.take 558 ++ PRE_first_tail_x15_r0_body.nr104.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st104.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 558) (bodyΘ.2.take 558)))
kernel_rfl bodyDl104 : (bodyΘ.1.take 558).length = (bodyΘ.2.take 558).length
kernel_rfl bodyDold104 : (bodyΘ.1.take 558).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws104).isNone && !PRE_first_tail_x15_r0_body.ws104.contains v) = true
kernel_rfl bodyDfree104 : (bodyΘ.2.take 558).all (fun e => (PRE_first_tail_x15_r0_body.cws104 ++ PRE_first_tail_x15_r0_body.ws104).all fun w => e.noVar w) = true

theorem bodyStep104 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38446, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1006 PRE_first_tail_x15_r0_body.S1006)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38456, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.S1008) (98 + 1) :=
  bodySite bodyFacts104.cfix bodyFacts104.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st104.S2.tab) (Es := bodyEs104) (qs := bodyQs104)
    (ok := PRE_first_tail_x15_r0_body.st104.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site104 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts104
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site104 r hr) hi (MapOk.sub hm (sub_of_all bodySub104)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk104 r hr) hi hm ho hq)
    bodyLq104 rfl bodyNrLo104 (postSub_sound bodyPost104)
    (Nat.le_of_ble_eq_true bodyDrop104) (by decide) (Nat.le_of_ble_eq_true bodyDropH104) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN104) (by decide)
    bodyDv104 bodyDe104 bodyDl104 bodyDold104 bodyDfree104 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
