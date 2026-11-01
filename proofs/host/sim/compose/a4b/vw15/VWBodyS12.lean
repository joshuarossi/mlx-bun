import host.sim.compose.a4b.vw15.VWBodyJ12
import host.sim.compose.a4b.vw15.VWBodySite12
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

theorem bodyCshift12 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S131.tab.length PRE_first_tail_x15_r0_body.s131.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P12.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P12 614 PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.s133.ffi PRE_first_tail_x15_r0_body.s132.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_12
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_12
  have hcl : SSt (· < 614) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s133.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S131.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_12] <;> decide) PRE_first_tail_x15_r0_body.cnodesK12 PRE_first_tail_x15_r0_body.cobjsK12
      PRE_first_tail_x15_r0_body.citemsK12 PRE_first_tail_x15_r0_body.cbd12 PRE_first_tail_x15_r0_body.csst12
  exact PRE_first_tail_x15_r0_body.cshift12 bodyNcl12 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_12] at this; exact this)


kernel_rfl bodyFramesEmpty12 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s132 a).isEmpty) = true
kernel_rfl bodyJsRoots12 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s131.next) PRE_first_tail_x15_r0_body.s133.trace PRE_first_tail_x15_r0_body.s133 = true
kernel_rfl bodyJsNative12 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s133.ffi) = true
kernel_rfl bodyLow12 : (PRE_first_tail_x15_r0_body.cws12 ++ PRE_first_tail_x15_r0_body.ws12).all (Nat.ble 9) = true
kernel_rfl bodyCntM12 : countersOkB PRE_first_tail_x15_r0_body.s131 PRE_first_tail_x15_r0_body.s132 = true
kernel_rfl bodyHi12 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s133.ffi).next setupP.E = true
kernel_rfl bodyNhi12 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s133.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge12 : bridgeOf PRE_first_tail_x15_r0_body.s132.ffi = bridgeOf PRE_first_tail_x15_r0_body.s131.ffi
kernel_rfl bodyNN12 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s131.ffi).nnext PRE_first_tail_x15_r0_body.P12.NL = true
kernel_rfl bodyXn12 : Nat.ble (⟨18455, 15542, 2684881, 614⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s133.ffi).next = true
kernel_rfl bodyLo12 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s133.ffi).next = true
theorem bodyFacts12 : BodySiteFacts PRE_first_tail_x15_r0_body.s131 PRE_first_tail_x15_r0_body.s132 PRE_first_tail_x15_r0_body.s133 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S131 PRE_first_tail_x15_r0_body.S132 PRE_first_tail_x15_r0_body.S133
    PRE_first_tail_x15_r0_body.ws12 PRE_first_tail_x15_r0_body.cws12 PRE_first_tail_x15_r0_body.nr12 PRE_first_tail_x15_r0_body.pl12 PRE_first_tail_x15_r0_body.cl12 2686030 614 PRE_first_tail_x15_r0_body.kd12 PRE_first_tail_x15_r0_body.kappa12 PRE_first_tail_x15_r0_body.P12
    ⟨18452, 15515, 2684875, 596⟩ ⟨18455, 15542, 2684881, 614⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap12
  clean := bodyClean12
  cfix := PRE_first_tail_x15_r0_body.cfix12
  zpl := PRE_first_tail_x15_r0_body.zpl12
  zplnd := PRE_first_tail_x15_r0_body.zplnd12
  zn1 := PRE_first_tail_x15_r0_body.zn112
  zfirst := PRE_first_tail_x15_r0_body.zfirst12
  zscn := PRE_first_tail_x15_r0_body.zscn12
  zsmn := PRE_first_tail_x15_r0_body.zsmn12
  zgrow := PRE_first_tail_x15_r0_body.zgrow12
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab12
  zfresh := PRE_first_tail_x15_r0_body.zfresh12
  zcnd := PRE_first_tail_x15_r0_body.zcnd12
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi12
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt12
  zgP := PRE_first_tail_x15_r0_body.zg12_2665
  zkP := PRE_first_tail_x15_r0_body.zk12_2665
  zmP := PRE_first_tail_x15_r0_body.zm12_2665
  zgC := PRE_first_tail_x15_r0_body.zg12_2673467
  zkC := PRE_first_tail_x15_r0_body.zk12_2673467
  zmC := PRE_first_tail_x15_r0_body.zm12_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw12_2673472
  zwV := PRE_first_tail_x15_r0_body.zw12_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap12
  zclbd := PRE_first_tail_x15_r0_body.zclbd12
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap12 PRE_first_tail_x15_r0_body.stFoot12 PRE_first_tail_x15_r0_body.iso12 PRE_first_tail_x15_r0_body.zwr12
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP12
  csupp := PRE_first_tail_x15_r0_body.csupp12
  cbound := PRE_first_tail_x15_r0_body.cbound12
  zimg := PRE_first_tail_x15_r0_body.zimg12
  zctl := PRE_first_tail_x15_r0_body.zctl12
  zstack := PRE_first_tail_x15_r0_body.zstack12
  zjobs := PRE_first_tail_x15_r0_body.zjobs12
  zstores := PRE_first_tail_x15_r0_body.zstores12
  zroots := PRE_first_tail_x15_r0_body.zroots12
  znC := PRE_first_tail_x15_r0_body.znC12
  ctab := PRE_first_tail_x15_r0_body.ctab12
  zbin := PRE_first_tail_x15_r0_body.zbin12
  cbridge := PRE_first_tail_x15_r0_body.cbridge12
  sbridge := bodyBridge12
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj12
  cshiftR := fun h hNL => bodyCshift12 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN12
  raised := PRE_first_tail_x15_r0_body.raised12
  cbigs := PRE_first_tail_x15_r0_body.cbigs12
  cjcl := PRE_first_tail_x15_r0_body.cjcl12
  xnLe := Nat.le_of_ble_eq_true bodyXn12
  loLe := Nat.le_of_ble_eq_true bodyLo12
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB12
  cntM := bodyCntM12
  hiLe := Nat.le_of_ble_eq_true bodyHi12
  nhiLe := Nat.le_of_ble_eq_true bodyNhi12
  jsHeap := bodyJs12
  jsRoots := bodyJsRoots12
  jsNative := bodyJsNative12
  framesEmpty := bodyFramesEmpty12
  trailOld := by decide
  lowVars := bodyLow12

def bodyQs12 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs12 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr12.map fun r => nth? PRE_first_tail_x15_r0_body.st12.S5.tab r
kernel_rfl bodyResChk12 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs12 bodyQs12) = true
kernel_rfl bodyLq12 : bodyQs12.length = PRE_first_tail_x15_r0_body.cws12.length
kernel_rfl bodyNrLo12 : PRE_first_tail_x15_r0_body.nr12.all (Nat.ble PRE_first_tail_x15_r0_body.S131.tab.length) = true
kernel_rfl bodySub12 : (Oracles.PRE_first_tail_x15_r0_body.map_site12.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost12 : postSubB bodyM PRE_first_tail_x15_r0_body.ws12 PRE_first_tail_x15_r0_body.cws12 bodyQs12 = true
kernel_rfl bodyDrop12 : Nat.ble (7968 + (PRE_first_tail_x15_r0_body.s132.next - PRE_first_tail_x15_r0_body.s133.next)) 9117 = true
kernel_rfl bodyDropH12 : Nat.ble (98 + ((mlxOf PRE_first_tail_x15_r0_body.s132.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s133.ffi).next)) 123 = true
kernel_rfl bodyDropN12 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s132.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s133.ffi).nnext)) 0 = true
kernel_rfl bodyDv12 : bodyΘ.1.take 81 = bodyΘ.1.take 63 ++ PRE_first_tail_x15_r0_body.cws12
kernel_rfl bodyDe12 : bodyΘ.2.take 81 = bodyΘ.2.take 63 ++ PRE_first_tail_x15_r0_body.nr12.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st12.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 63) (bodyΘ.2.take 63)))
kernel_rfl bodyDl12 : (bodyΘ.1.take 63).length = (bodyΘ.2.take 63).length
kernel_rfl bodyDold12 : (bodyΘ.1.take 63).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws12).isNone && !PRE_first_tail_x15_r0_body.ws12.contains v) = true
kernel_rfl bodyDfree12 : (bodyΘ.2.take 81).all (fun e => (PRE_first_tail_x15_r0_body.cws12 ++ PRE_first_tail_x15_r0_body.ws12).all fun w => e.noVar w) = true

theorem bodyStep12 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7968, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s131 PRE_first_tail_x15_r0_body.S131)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9117, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s133 PRE_first_tail_x15_r0_body.S133) (11334 + 1) :=
  bodySite bodyFacts12.cfix bodyFacts12.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st12.S5.tab) (Es := bodyEs12) (qs := bodyQs12)
    (ok := PRE_first_tail_x15_r0_body.st12.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site12 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts12
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site12 r hr) hi (MapOk.sub hm (sub_of_all bodySub12)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk12 r hr) hi hm ho hq)
    bodyLq12 rfl bodyNrLo12 (postSub_sound bodyPost12)
    (Nat.le_of_ble_eq_true bodyDrop12) (by decide) (Nat.le_of_ble_eq_true bodyDropH12) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN12) (by decide)
    bodyDv12 bodyDe12 bodyDl12 bodyDold12 bodyDfree12 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
