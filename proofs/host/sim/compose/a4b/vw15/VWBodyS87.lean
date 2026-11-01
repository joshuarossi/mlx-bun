import host.sim.compose.a4b.vw15.VWBodyJ87
import host.sim.compose.a4b.vw15.VWBodySite87
import host.sim.compose.a4b.vw15.VWBodyOracles_21
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift87 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S850.tab.length PRE_first_tail_x15_r0_body.s850.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P87.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P87 3821 PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.s852.ffi PRE_first_tail_x15_r0_body.s851.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_87
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_87
  have hcl : SSt (· < 3821) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S850.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_87] <;> decide) PRE_first_tail_x15_r0_body.cnodesK87 PRE_first_tail_x15_r0_body.cobjsK87
      PRE_first_tail_x15_r0_body.citemsK87 PRE_first_tail_x15_r0_body.cbd87 PRE_first_tail_x15_r0_body.csst87
  exact PRE_first_tail_x15_r0_body.cshift87 bodyNcl87 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_87] at this; exact this)


kernel_rfl bodyFramesEmpty87 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s851 a).isEmpty) = true
kernel_rfl bodyJsRoots87 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s850.next) PRE_first_tail_x15_r0_body.s852.trace PRE_first_tail_x15_r0_body.s852 = true
kernel_rfl bodyJsNative87 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s852.ffi) = true
kernel_rfl bodyLow87 : (PRE_first_tail_x15_r0_body.cws87 ++ PRE_first_tail_x15_r0_body.ws87).all (Nat.ble 9) = true
kernel_rfl bodyCntM87 : countersOkB PRE_first_tail_x15_r0_body.s850 PRE_first_tail_x15_r0_body.s851 = true
kernel_rfl bodyHi87 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s852.ffi).next setupP.E = true
kernel_rfl bodyNhi87 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s852.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge87 : bridgeOf PRE_first_tail_x15_r0_body.s851.ffi = bridgeOf PRE_first_tail_x15_r0_body.s850.ffi
kernel_rfl bodyNN87 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s850.ffi).nnext PRE_first_tail_x15_r0_body.P87.NL = true
kernel_rfl bodyXn87 : Nat.ble (⟨19928, 17027, 2743633, 3821⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s852.ffi).next = true
kernel_rfl bodyLo87 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s852.ffi).next = true
theorem bodyFacts87 : BodySiteFacts PRE_first_tail_x15_r0_body.s850 PRE_first_tail_x15_r0_body.s851 PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S850 PRE_first_tail_x15_r0_body.S851 PRE_first_tail_x15_r0_body.S852
    PRE_first_tail_x15_r0_body.ws87 PRE_first_tail_x15_r0_body.cws87 PRE_first_tail_x15_r0_body.nr87 PRE_first_tail_x15_r0_body.pl87 PRE_first_tail_x15_r0_body.cl87 2744782 3821 PRE_first_tail_x15_r0_body.kd87 PRE_first_tail_x15_r0_body.kappa87 PRE_first_tail_x15_r0_body.P87
    ⟨19925, 17000, 2743627, 3803⟩ ⟨19928, 17027, 2743633, 3821⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap87
  clean := bodyClean87
  cfix := PRE_first_tail_x15_r0_body.cfix87
  zpl := PRE_first_tail_x15_r0_body.zpl87
  zplnd := PRE_first_tail_x15_r0_body.zplnd87
  zn1 := PRE_first_tail_x15_r0_body.zn187
  zfirst := PRE_first_tail_x15_r0_body.zfirst87
  zscn := PRE_first_tail_x15_r0_body.zscn87
  zsmn := PRE_first_tail_x15_r0_body.zsmn87
  zgrow := PRE_first_tail_x15_r0_body.zgrow87
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab87
  zfresh := PRE_first_tail_x15_r0_body.zfresh87
  zcnd := PRE_first_tail_x15_r0_body.zcnd87
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi87
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt87
  zgP := PRE_first_tail_x15_r0_body.zg87_2665
  zkP := PRE_first_tail_x15_r0_body.zk87_2665
  zmP := PRE_first_tail_x15_r0_body.zm87_2665
  zgC := PRE_first_tail_x15_r0_body.zg87_2673467
  zkC := PRE_first_tail_x15_r0_body.zk87_2673467
  zmC := PRE_first_tail_x15_r0_body.zm87_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw87_2673472
  zwV := PRE_first_tail_x15_r0_body.zw87_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap87
  zclbd := PRE_first_tail_x15_r0_body.zclbd87
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap87 PRE_first_tail_x15_r0_body.stFoot87 PRE_first_tail_x15_r0_body.iso87 PRE_first_tail_x15_r0_body.zwr87
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP87
  csupp := PRE_first_tail_x15_r0_body.csupp87
  cbound := PRE_first_tail_x15_r0_body.cbound87
  zimg := PRE_first_tail_x15_r0_body.zimg87
  zctl := PRE_first_tail_x15_r0_body.zctl87
  zstack := PRE_first_tail_x15_r0_body.zstack87
  zjobs := PRE_first_tail_x15_r0_body.zjobs87
  zstores := PRE_first_tail_x15_r0_body.zstores87
  zroots := PRE_first_tail_x15_r0_body.zroots87
  znC := PRE_first_tail_x15_r0_body.znC87
  ctab := PRE_first_tail_x15_r0_body.ctab87
  zbin := PRE_first_tail_x15_r0_body.zbin87
  cbridge := PRE_first_tail_x15_r0_body.cbridge87
  sbridge := bodyBridge87
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj87
  cshiftR := fun h hNL => bodyCshift87 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN87
  raised := PRE_first_tail_x15_r0_body.raised87
  cbigs := PRE_first_tail_x15_r0_body.cbigs87
  cjcl := PRE_first_tail_x15_r0_body.cjcl87
  xnLe := Nat.le_of_ble_eq_true bodyXn87
  loLe := Nat.le_of_ble_eq_true bodyLo87
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB87
  cntM := bodyCntM87
  hiLe := Nat.le_of_ble_eq_true bodyHi87
  nhiLe := Nat.le_of_ble_eq_true bodyNhi87
  jsHeap := bodyJs87
  jsRoots := bodyJsRoots87
  jsNative := bodyJsNative87
  framesEmpty := bodyFramesEmpty87
  trailOld := by decide
  lowVars := bodyLow87

def bodyQs87 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs87 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr87.map fun r => nth? PRE_first_tail_x15_r0_body.st87.S5.tab r
kernel_rfl bodyResChk87 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs87 bodyQs87) = true
kernel_rfl bodyLq87 : bodyQs87.length = PRE_first_tail_x15_r0_body.cws87.length
kernel_rfl bodyNrLo87 : PRE_first_tail_x15_r0_body.nr87.all (Nat.ble PRE_first_tail_x15_r0_body.S850.tab.length) = true
kernel_rfl bodySub87 : (Oracles.PRE_first_tail_x15_r0_body.map_site87.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost87 : postSubB bodyM PRE_first_tail_x15_r0_body.ws87 PRE_first_tail_x15_r0_body.cws87 bodyQs87 = true
kernel_rfl bodyDrop87 : Nat.ble (32253 + (PRE_first_tail_x15_r0_body.s851.next - PRE_first_tail_x15_r0_body.s852.next)) 33402 = true
kernel_rfl bodyDropH87 : Nat.ble (585 + ((mlxOf PRE_first_tail_x15_r0_body.s851.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s852.ffi).next)) 610 = true
kernel_rfl bodyDropN87 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s851.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s852.ffi).nnext)) 0 = true
kernel_rfl bodyDv87 : bodyΘ.1.take 477 = bodyΘ.1.take 459 ++ PRE_first_tail_x15_r0_body.cws87
kernel_rfl bodyDe87 : bodyΘ.2.take 477 = bodyΘ.2.take 459 ++ PRE_first_tail_x15_r0_body.nr87.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st87.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 459) (bodyΘ.2.take 459)))
kernel_rfl bodyDl87 : (bodyΘ.1.take 459).length = (bodyΘ.2.take 459).length
kernel_rfl bodyDold87 : (bodyΘ.1.take 459).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws87).isNone && !PRE_first_tail_x15_r0_body.ws87.contains v) = true
kernel_rfl bodyDfree87 : (bodyΘ.2.take 477).all (fun e => (PRE_first_tail_x15_r0_body.cws87 ++ PRE_first_tail_x15_r0_body.ws87).all fun w => e.noVar w) = true

theorem bodyStep87 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32253, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s850 PRE_first_tail_x15_r0_body.S850)
      (bodyCut NB T tk π i x0 bodyΘ ⟨33402, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.S852) (11334 + 1) :=
  bodySite bodyFacts87.cfix bodyFacts87.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st87.S5.tab) (Es := bodyEs87) (qs := bodyQs87)
    (ok := PRE_first_tail_x15_r0_body.st87.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site87 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts87
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site87 r hr) hi (MapOk.sub hm (sub_of_all bodySub87)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk87 r hr) hi hm ho hq)
    bodyLq87 rfl bodyNrLo87 (postSub_sound bodyPost87)
    (Nat.le_of_ble_eq_true bodyDrop87) (by decide) (Nat.le_of_ble_eq_true bodyDropH87) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN87) (by decide)
    bodyDv87 bodyDe87 bodyDl87 bodyDold87 bodyDfree87 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
