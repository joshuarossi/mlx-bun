import host.sim.compose.a4b.vw15.VWBodyJ94
import host.sim.compose.a4b.vw15.VWBodySite94
import host.sim.compose.a4b.vw15.VWBodyOracles_23
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift94 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S915.tab.length PRE_first_tail_x15_r0_body.s915.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P94.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P94 4097 PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.s917.ffi PRE_first_tail_x15_r0_body.s916.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_94
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_94
  have hcl : SSt (· < 4097) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S915.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_94] <;> decide) PRE_first_tail_x15_r0_body.cnodesK94 PRE_first_tail_x15_r0_body.cobjsK94
      PRE_first_tail_x15_r0_body.citemsK94 PRE_first_tail_x15_r0_body.cbd94 PRE_first_tail_x15_r0_body.csst94
  exact PRE_first_tail_x15_r0_body.cshift94 bodyNcl94 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_94] at this; exact this)


kernel_rfl bodyFramesEmpty94 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s916 a).isEmpty) = true
kernel_rfl bodyJsRoots94 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s915.next) PRE_first_tail_x15_r0_body.s917.trace PRE_first_tail_x15_r0_body.s917 = true
kernel_rfl bodyJsNative94 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s917.ffi) = true
kernel_rfl bodyLow94 : (PRE_first_tail_x15_r0_body.cws94 ++ PRE_first_tail_x15_r0_body.ws94).all (Nat.ble 9) = true
kernel_rfl bodyCntM94 : countersOkB PRE_first_tail_x15_r0_body.s915 PRE_first_tail_x15_r0_body.s916 = true
kernel_rfl bodyHi94 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s917.ffi).next setupP.E = true
kernel_rfl bodyNhi94 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s917.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge94 : bridgeOf PRE_first_tail_x15_r0_body.s916.ffi = bridgeOf PRE_first_tail_x15_r0_body.s915.ffi
kernel_rfl bodyNN94 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s915.ffi).nnext PRE_first_tail_x15_r0_body.P94.NL = true
kernel_rfl bodyXn94 : Nat.ble (⟨20062, 17151, 2749005, 4097⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s917.ffi).next = true
kernel_rfl bodyLo94 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s917.ffi).next = true
theorem bodyFacts94 : BodySiteFacts PRE_first_tail_x15_r0_body.s915 PRE_first_tail_x15_r0_body.s916 PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S915 PRE_first_tail_x15_r0_body.S916 PRE_first_tail_x15_r0_body.S917
    PRE_first_tail_x15_r0_body.ws94 PRE_first_tail_x15_r0_body.cws94 PRE_first_tail_x15_r0_body.nr94 PRE_first_tail_x15_r0_body.pl94 PRE_first_tail_x15_r0_body.cl94 2749007 4097 PRE_first_tail_x15_r0_body.kd94 PRE_first_tail_x15_r0_body.kappa94 PRE_first_tail_x15_r0_body.P94
    ⟨20062, 17151, 2749005, 4097⟩ ⟨20062, 17151, 2749005, 4097⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap94
  clean := bodyClean94
  cfix := PRE_first_tail_x15_r0_body.cfix94
  zpl := PRE_first_tail_x15_r0_body.zpl94
  zplnd := PRE_first_tail_x15_r0_body.zplnd94
  zn1 := PRE_first_tail_x15_r0_body.zn194
  zfirst := PRE_first_tail_x15_r0_body.zfirst94
  zscn := PRE_first_tail_x15_r0_body.zscn94
  zsmn := PRE_first_tail_x15_r0_body.zsmn94
  zgrow := PRE_first_tail_x15_r0_body.zgrow94
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab94
  zfresh := PRE_first_tail_x15_r0_body.zfresh94
  zcnd := PRE_first_tail_x15_r0_body.zcnd94
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi94
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt94
  zgP := PRE_first_tail_x15_r0_body.zg94_2665
  zkP := PRE_first_tail_x15_r0_body.zk94_2665
  zmP := PRE_first_tail_x15_r0_body.zm94_2665
  zgC := PRE_first_tail_x15_r0_body.zg94_2673467
  zkC := PRE_first_tail_x15_r0_body.zk94_2673467
  zmC := PRE_first_tail_x15_r0_body.zm94_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw94_2673472
  zwV := PRE_first_tail_x15_r0_body.zw94_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap94
  zclbd := PRE_first_tail_x15_r0_body.zclbd94
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap94 PRE_first_tail_x15_r0_body.stFoot94 PRE_first_tail_x15_r0_body.iso94 PRE_first_tail_x15_r0_body.zwr94
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP94
  csupp := PRE_first_tail_x15_r0_body.csupp94
  cbound := PRE_first_tail_x15_r0_body.cbound94
  zimg := PRE_first_tail_x15_r0_body.zimg94
  zctl := PRE_first_tail_x15_r0_body.zctl94
  zstack := PRE_first_tail_x15_r0_body.zstack94
  zjobs := PRE_first_tail_x15_r0_body.zjobs94
  zstores := PRE_first_tail_x15_r0_body.zstores94
  zroots := PRE_first_tail_x15_r0_body.zroots94
  znC := PRE_first_tail_x15_r0_body.znC94
  ctab := PRE_first_tail_x15_r0_body.ctab94
  zbin := PRE_first_tail_x15_r0_body.zbin94
  cbridge := PRE_first_tail_x15_r0_body.cbridge94
  sbridge := bodyBridge94
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj94
  cshiftR := fun h hNL => bodyCshift94 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN94
  raised := PRE_first_tail_x15_r0_body.raised94
  cbigs := PRE_first_tail_x15_r0_body.cbigs94
  cjcl := PRE_first_tail_x15_r0_body.cjcl94
  xnLe := Nat.le_of_ble_eq_true bodyXn94
  loLe := Nat.le_of_ble_eq_true bodyLo94
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB94
  cntM := bodyCntM94
  hiLe := Nat.le_of_ble_eq_true bodyHi94
  nhiLe := Nat.le_of_ble_eq_true bodyNhi94
  jsHeap := bodyJs94
  jsRoots := bodyJsRoots94
  jsNative := bodyJsNative94
  framesEmpty := bodyFramesEmpty94
  trailOld := by decide
  lowVars := bodyLow94

def bodyQs94 : List (Option Q) := []
noncomputable def bodyEs94 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr94.map fun r => nth? PRE_first_tail_x15_r0_body.st94.S2.tab r
kernel_rfl bodyResChk94 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs94 bodyQs94) = true
kernel_rfl bodyLq94 : bodyQs94.length = PRE_first_tail_x15_r0_body.cws94.length
kernel_rfl bodyNrLo94 : PRE_first_tail_x15_r0_body.nr94.all (Nat.ble PRE_first_tail_x15_r0_body.S915.tab.length) = true
kernel_rfl bodySub94 : (Oracles.PRE_first_tail_x15_r0_body.map_site94.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost94 : postSubB bodyM PRE_first_tail_x15_r0_body.ws94 PRE_first_tail_x15_r0_body.cws94 bodyQs94 = true
kernel_rfl bodyDrop94 : Nat.ble (34934 + (PRE_first_tail_x15_r0_body.s916.next - PRE_first_tail_x15_r0_body.s917.next)) 34936 = true
kernel_rfl bodyDropH94 : Nat.ble (637 + ((mlxOf PRE_first_tail_x15_r0_body.s916.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s917.ffi).next)) 637 = true
kernel_rfl bodyDropN94 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s916.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s917.ffi).nnext)) 0 = true
kernel_rfl bodyDv94 : bodyΘ.1.take 504 = bodyΘ.1.take 504 ++ PRE_first_tail_x15_r0_body.cws94
kernel_rfl bodyDe94 : bodyΘ.2.take 504 = bodyΘ.2.take 504 ++ PRE_first_tail_x15_r0_body.nr94.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st94.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 504) (bodyΘ.2.take 504)))
kernel_rfl bodyDl94 : (bodyΘ.1.take 504).length = (bodyΘ.2.take 504).length
kernel_rfl bodyDold94 : (bodyΘ.1.take 504).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws94).isNone && !PRE_first_tail_x15_r0_body.ws94.contains v) = true
kernel_rfl bodyDfree94 : (bodyΘ.2.take 504).all (fun e => (PRE_first_tail_x15_r0_body.cws94 ++ PRE_first_tail_x15_r0_body.ws94).all fun w => e.noVar w) = true

theorem bodyStep94 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34934, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s915 PRE_first_tail_x15_r0_body.S915)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34936, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.S917) (27 + 1) :=
  bodySite bodyFacts94.cfix bodyFacts94.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st94.S2.tab) (Es := bodyEs94) (qs := bodyQs94)
    (ok := PRE_first_tail_x15_r0_body.st94.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site94 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts94
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site94 r hr) hi (MapOk.sub hm (sub_of_all bodySub94)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk94 r hr) hi hm ho hq)
    bodyLq94 rfl bodyNrLo94 (postSub_sound bodyPost94)
    (Nat.le_of_ble_eq_true bodyDrop94) (by decide) (Nat.le_of_ble_eq_true bodyDropH94) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN94) (by decide)
    bodyDv94 bodyDe94 bodyDl94 bodyDold94 bodyDfree94 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
