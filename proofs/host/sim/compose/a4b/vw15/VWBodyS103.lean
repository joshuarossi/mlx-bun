import host.sim.compose.a4b.vw15.VWBodyJ103
import host.sim.compose.a4b.vw15.VWBodySite103
import host.sim.compose.a4b.vw15.VWBodyOracles_25
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

theorem bodyCshift103 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1002.tab.length PRE_first_tail_x15_r0_body.s1002.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P103.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P103 4484 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.s1004.ffi PRE_first_tail_x15_r0_body.s1003.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_103
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_103
  have hcl : SSt (· < 4484) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1002.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_103] <;> decide) PRE_first_tail_x15_r0_body.cnodesK103 PRE_first_tail_x15_r0_body.cobjsK103
      PRE_first_tail_x15_r0_body.citemsK103 PRE_first_tail_x15_r0_body.cbd103 PRE_first_tail_x15_r0_body.csst103
  exact PRE_first_tail_x15_r0_body.cshift103 bodyNcl103 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_103] at this; exact this)


kernel_rfl bodyFramesEmpty103 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1003 a).isEmpty) = true
kernel_rfl bodyJsRoots103 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1002.next) PRE_first_tail_x15_r0_body.s1004.trace PRE_first_tail_x15_r0_body.s1004 = true
kernel_rfl bodyJsNative103 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1004.ffi) = true
kernel_rfl bodyLow103 : (PRE_first_tail_x15_r0_body.cws103 ++ PRE_first_tail_x15_r0_body.ws103).all (Nat.ble 9) = true
kernel_rfl bodyCntM103 : countersOkB PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.s1003 = true
kernel_rfl bodyHi103 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1004.ffi).next setupP.E = true
kernel_rfl bodyNhi103 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1004.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge103 : bridgeOf PRE_first_tail_x15_r0_body.s1003.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1002.ffi
kernel_rfl bodyNN103 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1002.ffi).nnext PRE_first_tail_x15_r0_body.P103.NL = true
kernel_rfl bodyXn103 : Nat.ble (⟨20234, 17340, 2755807, 4484⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1004.ffi).next = true
kernel_rfl bodyLo103 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1004.ffi).next = true
theorem bodyFacts103 : BodySiteFacts PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.s1003 PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1002 PRE_first_tail_x15_r0_body.S1003 PRE_first_tail_x15_r0_body.S1004
    PRE_first_tail_x15_r0_body.ws103 PRE_first_tail_x15_r0_body.cws103 PRE_first_tail_x15_r0_body.nr103 PRE_first_tail_x15_r0_body.pl103 PRE_first_tail_x15_r0_body.cl103 2755809 4484 PRE_first_tail_x15_r0_body.kd103 PRE_first_tail_x15_r0_body.kappa103 PRE_first_tail_x15_r0_body.P103
    ⟨20234, 17340, 2755807, 4484⟩ ⟨20234, 17340, 2755807, 4484⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap103
  clean := bodyClean103
  cfix := PRE_first_tail_x15_r0_body.cfix103
  zpl := PRE_first_tail_x15_r0_body.zpl103
  zplnd := PRE_first_tail_x15_r0_body.zplnd103
  zn1 := PRE_first_tail_x15_r0_body.zn1103
  zfirst := PRE_first_tail_x15_r0_body.zfirst103
  zscn := PRE_first_tail_x15_r0_body.zscn103
  zsmn := PRE_first_tail_x15_r0_body.zsmn103
  zgrow := PRE_first_tail_x15_r0_body.zgrow103
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab103
  zfresh := PRE_first_tail_x15_r0_body.zfresh103
  zcnd := PRE_first_tail_x15_r0_body.zcnd103
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi103
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt103
  zgP := PRE_first_tail_x15_r0_body.zg103_2665
  zkP := PRE_first_tail_x15_r0_body.zk103_2665
  zmP := PRE_first_tail_x15_r0_body.zm103_2665
  zgC := PRE_first_tail_x15_r0_body.zg103_2673467
  zkC := PRE_first_tail_x15_r0_body.zk103_2673467
  zmC := PRE_first_tail_x15_r0_body.zm103_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw103_2673472
  zwV := PRE_first_tail_x15_r0_body.zw103_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap103
  zclbd := PRE_first_tail_x15_r0_body.zclbd103
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap103 PRE_first_tail_x15_r0_body.stFoot103 PRE_first_tail_x15_r0_body.iso103 PRE_first_tail_x15_r0_body.zwr103
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP103
  csupp := PRE_first_tail_x15_r0_body.csupp103
  cbound := PRE_first_tail_x15_r0_body.cbound103
  zimg := PRE_first_tail_x15_r0_body.zimg103
  zctl := PRE_first_tail_x15_r0_body.zctl103
  zstack := PRE_first_tail_x15_r0_body.zstack103
  zjobs := PRE_first_tail_x15_r0_body.zjobs103
  zstores := PRE_first_tail_x15_r0_body.zstores103
  zroots := PRE_first_tail_x15_r0_body.zroots103
  znC := PRE_first_tail_x15_r0_body.znC103
  ctab := PRE_first_tail_x15_r0_body.ctab103
  zbin := PRE_first_tail_x15_r0_body.zbin103
  cbridge := PRE_first_tail_x15_r0_body.cbridge103
  sbridge := bodyBridge103
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj103
  cshiftR := fun h hNL => bodyCshift103 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN103
  raised := PRE_first_tail_x15_r0_body.raised103
  cbigs := PRE_first_tail_x15_r0_body.cbigs103
  cjcl := PRE_first_tail_x15_r0_body.cjcl103
  xnLe := Nat.le_of_ble_eq_true bodyXn103
  loLe := Nat.le_of_ble_eq_true bodyLo103
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB103
  cntM := bodyCntM103
  hiLe := Nat.le_of_ble_eq_true bodyHi103
  nhiLe := Nat.le_of_ble_eq_true bodyNhi103
  jsHeap := bodyJs103
  jsRoots := bodyJsRoots103
  jsNative := bodyJsNative103
  framesEmpty := bodyFramesEmpty103
  trailOld := by decide
  lowVars := bodyLow103

def bodyQs103 : List (Option Q) := []
noncomputable def bodyEs103 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr103.map fun r => nth? PRE_first_tail_x15_r0_body.st103.S2.tab r
kernel_rfl bodyResChk103 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs103 bodyQs103) = true
kernel_rfl bodyLq103 : bodyQs103.length = PRE_first_tail_x15_r0_body.cws103.length
kernel_rfl bodyNrLo103 : PRE_first_tail_x15_r0_body.nr103.all (Nat.ble PRE_first_tail_x15_r0_body.S1002.tab.length) = true
kernel_rfl bodySub103 : (Oracles.PRE_first_tail_x15_r0_body.map_site103.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost103 : postSubB bodyM PRE_first_tail_x15_r0_body.ws103 PRE_first_tail_x15_r0_body.cws103 bodyQs103 = true
kernel_rfl bodyDrop103 : Nat.ble (38444 + (PRE_first_tail_x15_r0_body.s1003.next - PRE_first_tail_x15_r0_body.s1004.next)) 38446 = true
kernel_rfl bodyDropH103 : Nat.ble (712 + ((mlxOf PRE_first_tail_x15_r0_body.s1003.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1004.ffi).next)) 712 = true
kernel_rfl bodyDropN103 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1003.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1004.ffi).nnext)) 0 = true
kernel_rfl bodyDv103 : bodyΘ.1.take 558 = bodyΘ.1.take 558 ++ PRE_first_tail_x15_r0_body.cws103
kernel_rfl bodyDe103 : bodyΘ.2.take 558 = bodyΘ.2.take 558 ++ PRE_first_tail_x15_r0_body.nr103.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st103.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 558) (bodyΘ.2.take 558)))
kernel_rfl bodyDl103 : (bodyΘ.1.take 558).length = (bodyΘ.2.take 558).length
kernel_rfl bodyDold103 : (bodyΘ.1.take 558).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws103).isNone && !PRE_first_tail_x15_r0_body.ws103.contains v) = true
kernel_rfl bodyDfree103 : (bodyΘ.2.take 558).all (fun e => (PRE_first_tail_x15_r0_body.cws103 ++ PRE_first_tail_x15_r0_body.ws103).all fun w => e.noVar w) = true

theorem bodyStep103 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38444, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.S1002)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38446, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.S1004) (27 + 1) :=
  bodySite bodyFacts103.cfix bodyFacts103.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st103.S2.tab) (Es := bodyEs103) (qs := bodyQs103)
    (ok := PRE_first_tail_x15_r0_body.st103.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site103 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts103
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site103 r hr) hi (MapOk.sub hm (sub_of_all bodySub103)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk103 r hr) hi hm ho hq)
    bodyLq103 rfl bodyNrLo103 (postSub_sound bodyPost103)
    (Nat.le_of_ble_eq_true bodyDrop103) (by decide) (Nat.le_of_ble_eq_true bodyDropH103) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN103) (by decide)
    bodyDv103 bodyDe103 bodyDl103 bodyDold103 bodyDfree103 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
