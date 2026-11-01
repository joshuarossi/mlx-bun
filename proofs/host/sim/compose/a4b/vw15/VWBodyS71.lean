import host.sim.compose.a4b.vw15.VWBodyJ71
import host.sim.compose.a4b.vw15.VWBodySite71
import host.sim.compose.a4b.vw15.VWBodyOracles_17
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift71 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S689.tab.length PRE_first_tail_x15_r0_body.s689.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P71.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P71 3088 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.s691.ffi PRE_first_tail_x15_r0_body.s690.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_71
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_71
  have hcl : SSt (· < 3088) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S689.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_71] <;> decide) PRE_first_tail_x15_r0_body.cnodesK71 PRE_first_tail_x15_r0_body.cobjsK71
      PRE_first_tail_x15_r0_body.citemsK71 PRE_first_tail_x15_r0_body.cbd71 PRE_first_tail_x15_r0_body.csst71
  exact PRE_first_tail_x15_r0_body.cshift71 bodyNcl71 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_71] at this; exact this)


kernel_rfl bodyFramesEmpty71 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s690 a).isEmpty) = true
kernel_rfl bodyJsRoots71 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s689.next) PRE_first_tail_x15_r0_body.s691.trace PRE_first_tail_x15_r0_body.s691 = true
kernel_rfl bodyJsNative71 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s691.ffi) = true
kernel_rfl bodyLow71 : (PRE_first_tail_x15_r0_body.cws71 ++ PRE_first_tail_x15_r0_body.ws71).all (Nat.ble 9) = true
kernel_rfl bodyCntM71 : countersOkB PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.s690 = true
kernel_rfl bodyHi71 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s691.ffi).next setupP.E = true
kernel_rfl bodyNhi71 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s691.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge71 : bridgeOf PRE_first_tail_x15_r0_body.s690.ffi = bridgeOf PRE_first_tail_x15_r0_body.s689.ffi
kernel_rfl bodyNN71 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s689.ffi).nnext PRE_first_tail_x15_r0_body.P71.NL = true
kernel_rfl bodyXn71 : Nat.ble (⟨19597, 16681, 2730466, 3088⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s691.ffi).next = true
kernel_rfl bodyLo71 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s691.ffi).next = true
theorem bodyFacts71 : BodySiteFacts PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.s690 PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S689 PRE_first_tail_x15_r0_body.S690 PRE_first_tail_x15_r0_body.S691
    PRE_first_tail_x15_r0_body.ws71 PRE_first_tail_x15_r0_body.cws71 PRE_first_tail_x15_r0_body.nr71 PRE_first_tail_x15_r0_body.pl71 PRE_first_tail_x15_r0_body.cl71 2730476 3088 PRE_first_tail_x15_r0_body.kd71 PRE_first_tail_x15_r0_body.kappa71 PRE_first_tail_x15_r0_body.P71
    ⟨19597, 16681, 2730465, 3088⟩ ⟨19597, 16681, 2730466, 3088⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap71
  clean := bodyClean71
  cfix := PRE_first_tail_x15_r0_body.cfix71
  zpl := PRE_first_tail_x15_r0_body.zpl71
  zplnd := PRE_first_tail_x15_r0_body.zplnd71
  zn1 := PRE_first_tail_x15_r0_body.zn171
  zfirst := PRE_first_tail_x15_r0_body.zfirst71
  zscn := PRE_first_tail_x15_r0_body.zscn71
  zsmn := PRE_first_tail_x15_r0_body.zsmn71
  zgrow := PRE_first_tail_x15_r0_body.zgrow71
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab71
  zfresh := PRE_first_tail_x15_r0_body.zfresh71
  zcnd := PRE_first_tail_x15_r0_body.zcnd71
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi71
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt71
  zgP := PRE_first_tail_x15_r0_body.zg71_2665
  zkP := PRE_first_tail_x15_r0_body.zk71_2665
  zmP := PRE_first_tail_x15_r0_body.zm71_2665
  zgC := PRE_first_tail_x15_r0_body.zg71_2673467
  zkC := PRE_first_tail_x15_r0_body.zk71_2673467
  zmC := PRE_first_tail_x15_r0_body.zm71_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw71_2673472
  zwV := PRE_first_tail_x15_r0_body.zw71_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap71
  zclbd := PRE_first_tail_x15_r0_body.zclbd71
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap71 PRE_first_tail_x15_r0_body.stFoot71 PRE_first_tail_x15_r0_body.iso71 PRE_first_tail_x15_r0_body.zwr71
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP71
  csupp := PRE_first_tail_x15_r0_body.csupp71
  cbound := PRE_first_tail_x15_r0_body.cbound71
  zimg := PRE_first_tail_x15_r0_body.zimg71
  zctl := PRE_first_tail_x15_r0_body.zctl71
  zstack := PRE_first_tail_x15_r0_body.zstack71
  zjobs := PRE_first_tail_x15_r0_body.zjobs71
  zstores := PRE_first_tail_x15_r0_body.zstores71
  zroots := PRE_first_tail_x15_r0_body.zroots71
  znC := PRE_first_tail_x15_r0_body.znC71
  ctab := PRE_first_tail_x15_r0_body.ctab71
  zbin := PRE_first_tail_x15_r0_body.zbin71
  cbridge := PRE_first_tail_x15_r0_body.cbridge71
  sbridge := bodyBridge71
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj71
  cshiftR := fun h hNL => bodyCshift71 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN71
  raised := PRE_first_tail_x15_r0_body.raised71
  cbigs := PRE_first_tail_x15_r0_body.cbigs71
  cjcl := PRE_first_tail_x15_r0_body.cjcl71
  xnLe := Nat.le_of_ble_eq_true bodyXn71
  loLe := Nat.le_of_ble_eq_true bodyLo71
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB71
  cntM := bodyCntM71
  hiLe := Nat.le_of_ble_eq_true bodyHi71
  nhiLe := Nat.le_of_ble_eq_true bodyNhi71
  jsHeap := bodyJs71
  jsRoots := bodyJsRoots71
  jsNative := bodyJsNative71
  framesEmpty := bodyFramesEmpty71
  trailOld := by decide
  lowVars := bodyLow71

def bodyQs71 : List (Option Q) := []
noncomputable def bodyEs71 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr71.map fun r => nth? PRE_first_tail_x15_r0_body.st71.S2.tab r
kernel_rfl bodyResChk71 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs71 bodyQs71) = true
kernel_rfl bodyLq71 : bodyQs71.length = PRE_first_tail_x15_r0_body.cws71.length
kernel_rfl bodyNrLo71 : PRE_first_tail_x15_r0_body.nr71.all (Nat.ble PRE_first_tail_x15_r0_body.S689.tab.length) = true
kernel_rfl bodySub71 : (Oracles.PRE_first_tail_x15_r0_body.map_site71.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost71 : postSubB bodyM PRE_first_tail_x15_r0_body.ws71 PRE_first_tail_x15_r0_body.cws71 bodyQs71 = true
kernel_rfl bodyDrop71 : Nat.ble (27237 + (PRE_first_tail_x15_r0_body.s690.next - PRE_first_tail_x15_r0_body.s691.next)) 27247 = true
kernel_rfl bodyDropH71 : Nat.ble (483 + ((mlxOf PRE_first_tail_x15_r0_body.s690.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s691.ffi).next)) 483 = true
kernel_rfl bodyDropN71 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s690.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s691.ffi).nnext)) 0 = true
kernel_rfl bodyDv71 : bodyΘ.1.take 378 = bodyΘ.1.take 378 ++ PRE_first_tail_x15_r0_body.cws71
kernel_rfl bodyDe71 : bodyΘ.2.take 378 = bodyΘ.2.take 378 ++ PRE_first_tail_x15_r0_body.nr71.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st71.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 378) (bodyΘ.2.take 378)))
kernel_rfl bodyDl71 : (bodyΘ.1.take 378).length = (bodyΘ.2.take 378).length
kernel_rfl bodyDold71 : (bodyΘ.1.take 378).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws71).isNone && !PRE_first_tail_x15_r0_body.ws71.contains v) = true
kernel_rfl bodyDfree71 : (bodyΘ.2.take 378).all (fun e => (PRE_first_tail_x15_r0_body.cws71 ++ PRE_first_tail_x15_r0_body.ws71).all fun w => e.noVar w) = true

theorem bodyStep71 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨27237, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.S689)
      (bodyCut NB T tk π i x0 bodyΘ ⟨27247, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.S691) (98 + 1) :=
  bodySite bodyFacts71.cfix bodyFacts71.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st71.S2.tab) (Es := bodyEs71) (qs := bodyQs71)
    (ok := PRE_first_tail_x15_r0_body.st71.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site71 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts71
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site71 r hr) hi (MapOk.sub hm (sub_of_all bodySub71)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk71 r hr) hi hm ho hq)
    bodyLq71 rfl bodyNrLo71 (postSub_sound bodyPost71)
    (Nat.le_of_ble_eq_true bodyDrop71) (by decide) (Nat.le_of_ble_eq_true bodyDropH71) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN71) (by decide)
    bodyDv71 bodyDe71 bodyDl71 bodyDold71 bodyDfree71 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
