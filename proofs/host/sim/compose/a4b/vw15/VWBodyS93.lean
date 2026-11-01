import host.sim.compose.a4b.vw15.VWBodyJ93
import host.sim.compose.a4b.vw15.VWBodySite93
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

theorem bodyCshift93 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S907.tab.length PRE_first_tail_x15_r0_body.s907.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P93.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P93 4074 PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.s909.ffi PRE_first_tail_x15_r0_body.s908.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_93
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_93
  have hcl : SSt (· < 4074) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s909.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S907.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_93] <;> decide) PRE_first_tail_x15_r0_body.cnodesK93 PRE_first_tail_x15_r0_body.cobjsK93
      PRE_first_tail_x15_r0_body.citemsK93 PRE_first_tail_x15_r0_body.cbd93 PRE_first_tail_x15_r0_body.csst93
  exact PRE_first_tail_x15_r0_body.cshift93 bodyNcl93 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_93] at this; exact this)


kernel_rfl bodyFramesEmpty93 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s908 a).isEmpty) = true
kernel_rfl bodyJsRoots93 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s907.next) PRE_first_tail_x15_r0_body.s909.trace PRE_first_tail_x15_r0_body.s909 = true
kernel_rfl bodyJsNative93 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s909.ffi) = true
kernel_rfl bodyLow93 : (PRE_first_tail_x15_r0_body.cws93 ++ PRE_first_tail_x15_r0_body.ws93).all (Nat.ble 9) = true
kernel_rfl bodyCntM93 : countersOkB PRE_first_tail_x15_r0_body.s907 PRE_first_tail_x15_r0_body.s908 = true
kernel_rfl bodyHi93 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s909.ffi).next setupP.E = true
kernel_rfl bodyNhi93 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s909.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge93 : bridgeOf PRE_first_tail_x15_r0_body.s908.ffi = bridgeOf PRE_first_tail_x15_r0_body.s907.ffi
kernel_rfl bodyNN93 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s907.ffi).nnext PRE_first_tail_x15_r0_body.P93.NL = true
kernel_rfl bodyXn93 : Nat.ble (⟨20049, 17141, 2748423, 4074⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s909.ffi).next = true
kernel_rfl bodyLo93 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s909.ffi).next = true
theorem bodyFacts93 : BodySiteFacts PRE_first_tail_x15_r0_body.s907 PRE_first_tail_x15_r0_body.s908 PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S907 PRE_first_tail_x15_r0_body.S908 PRE_first_tail_x15_r0_body.S909
    PRE_first_tail_x15_r0_body.ws93 PRE_first_tail_x15_r0_body.cws93 PRE_first_tail_x15_r0_body.nr93 PRE_first_tail_x15_r0_body.pl93 PRE_first_tail_x15_r0_body.cl93 2748773 4074 PRE_first_tail_x15_r0_body.kd93 PRE_first_tail_x15_r0_body.kappa93 PRE_first_tail_x15_r0_body.P93
    ⟨20045, 17135, 2748408, 4065⟩ ⟨20049, 17141, 2748423, 4074⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap93
  clean := bodyClean93
  cfix := PRE_first_tail_x15_r0_body.cfix93
  zpl := PRE_first_tail_x15_r0_body.zpl93
  zplnd := PRE_first_tail_x15_r0_body.zplnd93
  zn1 := PRE_first_tail_x15_r0_body.zn193
  zfirst := PRE_first_tail_x15_r0_body.zfirst93
  zscn := PRE_first_tail_x15_r0_body.zscn93
  zsmn := PRE_first_tail_x15_r0_body.zsmn93
  zgrow := PRE_first_tail_x15_r0_body.zgrow93
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab93
  zfresh := PRE_first_tail_x15_r0_body.zfresh93
  zcnd := PRE_first_tail_x15_r0_body.zcnd93
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi93
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt93
  zgP := PRE_first_tail_x15_r0_body.zg93_2665
  zkP := PRE_first_tail_x15_r0_body.zk93_2665
  zmP := PRE_first_tail_x15_r0_body.zm93_2665
  zgC := PRE_first_tail_x15_r0_body.zg93_2673467
  zkC := PRE_first_tail_x15_r0_body.zk93_2673467
  zmC := PRE_first_tail_x15_r0_body.zm93_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw93_2673472
  zwV := PRE_first_tail_x15_r0_body.zw93_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap93
  zclbd := PRE_first_tail_x15_r0_body.zclbd93
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap93 PRE_first_tail_x15_r0_body.stFoot93 PRE_first_tail_x15_r0_body.iso93 PRE_first_tail_x15_r0_body.zwr93
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP93
  csupp := PRE_first_tail_x15_r0_body.csupp93
  cbound := PRE_first_tail_x15_r0_body.cbound93
  zimg := PRE_first_tail_x15_r0_body.zimg93
  zctl := PRE_first_tail_x15_r0_body.zctl93
  zstack := PRE_first_tail_x15_r0_body.zstack93
  zjobs := PRE_first_tail_x15_r0_body.zjobs93
  zstores := PRE_first_tail_x15_r0_body.zstores93
  zroots := PRE_first_tail_x15_r0_body.zroots93
  znC := PRE_first_tail_x15_r0_body.znC93
  ctab := PRE_first_tail_x15_r0_body.ctab93
  zbin := PRE_first_tail_x15_r0_body.zbin93
  cbridge := PRE_first_tail_x15_r0_body.cbridge93
  sbridge := bodyBridge93
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj93
  cshiftR := fun h hNL => bodyCshift93 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN93
  raised := PRE_first_tail_x15_r0_body.raised93
  cbigs := PRE_first_tail_x15_r0_body.cbigs93
  cjcl := PRE_first_tail_x15_r0_body.cjcl93
  xnLe := Nat.le_of_ble_eq_true bodyXn93
  loLe := Nat.le_of_ble_eq_true bodyLo93
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB93
  cntM := bodyCntM93
  hiLe := Nat.le_of_ble_eq_true bodyHi93
  nhiLe := Nat.le_of_ble_eq_true bodyNhi93
  jsHeap := bodyJs93
  jsRoots := bodyJsRoots93
  jsNative := bodyJsNative93
  framesEmpty := bodyFramesEmpty93
  trailOld := by decide
  lowVars := bodyLow93

def bodyQs93 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs93 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr93.map fun r => nth? PRE_first_tail_x15_r0_body.st93.S3.tab r
kernel_rfl bodyResChk93 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs93 bodyQs93) = true
kernel_rfl bodyLq93 : bodyQs93.length = PRE_first_tail_x15_r0_body.cws93.length
kernel_rfl bodyNrLo93 : PRE_first_tail_x15_r0_body.nr93.all (Nat.ble PRE_first_tail_x15_r0_body.S907.tab.length) = true
kernel_rfl bodySub93 : (Oracles.PRE_first_tail_x15_r0_body.map_site93.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost93 : postSubB bodyM PRE_first_tail_x15_r0_body.ws93 PRE_first_tail_x15_r0_body.cws93 bodyQs93 = true
kernel_rfl bodyDrop93 : Nat.ble (34584 + (PRE_first_tail_x15_r0_body.s908.next - PRE_first_tail_x15_r0_body.s909.next)) 34934 = true
kernel_rfl bodyDropH93 : Nat.ble (635 + ((mlxOf PRE_first_tail_x15_r0_body.s908.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s909.ffi).next)) 637 = true
kernel_rfl bodyDropN93 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s908.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s909.ffi).nnext)) 0 = true
kernel_rfl bodyDv93 : bodyΘ.1.take 504 = bodyΘ.1.take 495 ++ PRE_first_tail_x15_r0_body.cws93
kernel_rfl bodyDe93 : bodyΘ.2.take 504 = bodyΘ.2.take 495 ++ PRE_first_tail_x15_r0_body.nr93.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st93.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 495) (bodyΘ.2.take 495)))
kernel_rfl bodyDl93 : (bodyΘ.1.take 495).length = (bodyΘ.2.take 495).length
kernel_rfl bodyDold93 : (bodyΘ.1.take 495).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws93).isNone && !PRE_first_tail_x15_r0_body.ws93.contains v) = true
kernel_rfl bodyDfree93 : (bodyΘ.2.take 504).all (fun e => (PRE_first_tail_x15_r0_body.cws93 ++ PRE_first_tail_x15_r0_body.ws93).all fun w => e.noVar w) = true

theorem bodyStep93 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34584, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s907 PRE_first_tail_x15_r0_body.S907)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34934, 637, 0, 504⟩ bodyM PRE_first_tail_x15_r0_body.s909 PRE_first_tail_x15_r0_body.S909) (3452 + 1) :=
  bodySite bodyFacts93.cfix bodyFacts93.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st93.S3.tab) (Es := bodyEs93) (qs := bodyQs93)
    (ok := PRE_first_tail_x15_r0_body.st93.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site93 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts93
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site93 r hr) hi (MapOk.sub hm (sub_of_all bodySub93)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk93 r hr) hi hm ho hq)
    bodyLq93 rfl bodyNrLo93 (postSub_sound bodyPost93)
    (Nat.le_of_ble_eq_true bodyDrop93) (by decide) (Nat.le_of_ble_eq_true bodyDropH93) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN93) (by decide)
    bodyDv93 bodyDe93 bodyDl93 bodyDold93 bodyDfree93 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
