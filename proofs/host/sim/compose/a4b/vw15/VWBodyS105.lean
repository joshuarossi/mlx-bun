import host.sim.compose.a4b.vw15.VWBodyJ105
import host.sim.compose.a4b.vw15.VWBodySite105
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

theorem bodyCshift105 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1022.tab.length PRE_first_tail_x15_r0_body.s1022.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P105.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P105 4587 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.s1024.ffi PRE_first_tail_x15_r0_body.s1023.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_105
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_105
  have hcl : SSt (· < 4587) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1022.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_105] <;> decide) PRE_first_tail_x15_r0_body.cnodesK105 PRE_first_tail_x15_r0_body.cobjsK105
      PRE_first_tail_x15_r0_body.citemsK105 PRE_first_tail_x15_r0_body.cbd105 PRE_first_tail_x15_r0_body.csst105
  exact PRE_first_tail_x15_r0_body.cshift105 bodyNcl105 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_105] at this; exact this)


kernel_rfl bodyFramesEmpty105 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1023 a).isEmpty) = true
kernel_rfl bodyJsRoots105 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1022.next) PRE_first_tail_x15_r0_body.s1024.trace PRE_first_tail_x15_r0_body.s1024 = true
kernel_rfl bodyJsNative105 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1024.ffi) = true
kernel_rfl bodyLow105 : (PRE_first_tail_x15_r0_body.cws105 ++ PRE_first_tail_x15_r0_body.ws105).all (Nat.ble 9) = true
kernel_rfl bodyCntM105 : countersOkB PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.s1023 = true
kernel_rfl bodyHi105 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1024.ffi).next setupP.E = true
kernel_rfl bodyNhi105 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1024.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge105 : bridgeOf PRE_first_tail_x15_r0_body.s1023.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1022.ffi
kernel_rfl bodyNN105 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1022.ffi).nnext PRE_first_tail_x15_r0_body.P105.NL = true
kernel_rfl bodyXn105 : Nat.ble (⟨20285, 17378, 2757847, 4587⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1024.ffi).next = true
kernel_rfl bodyLo105 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1024.ffi).next = true
theorem bodyFacts105 : BodySiteFacts PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.s1023 PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1022 PRE_first_tail_x15_r0_body.S1023 PRE_first_tail_x15_r0_body.S1024
    PRE_first_tail_x15_r0_body.ws105 PRE_first_tail_x15_r0_body.cws105 PRE_first_tail_x15_r0_body.nr105 PRE_first_tail_x15_r0_body.pl105 PRE_first_tail_x15_r0_body.cl105 2758197 4587 PRE_first_tail_x15_r0_body.kd105 PRE_first_tail_x15_r0_body.kappa105 PRE_first_tail_x15_r0_body.P105
    ⟨20281, 17372, 2757832, 4578⟩ ⟨20285, 17378, 2757847, 4587⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap105
  clean := bodyClean105
  cfix := PRE_first_tail_x15_r0_body.cfix105
  zpl := PRE_first_tail_x15_r0_body.zpl105
  zplnd := PRE_first_tail_x15_r0_body.zplnd105
  zn1 := PRE_first_tail_x15_r0_body.zn1105
  zfirst := PRE_first_tail_x15_r0_body.zfirst105
  zscn := PRE_first_tail_x15_r0_body.zscn105
  zsmn := PRE_first_tail_x15_r0_body.zsmn105
  zgrow := PRE_first_tail_x15_r0_body.zgrow105
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab105
  zfresh := PRE_first_tail_x15_r0_body.zfresh105
  zcnd := PRE_first_tail_x15_r0_body.zcnd105
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi105
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt105
  zgP := PRE_first_tail_x15_r0_body.zg105_2665
  zkP := PRE_first_tail_x15_r0_body.zk105_2665
  zmP := PRE_first_tail_x15_r0_body.zm105_2665
  zgC := PRE_first_tail_x15_r0_body.zg105_2673467
  zkC := PRE_first_tail_x15_r0_body.zk105_2673467
  zmC := PRE_first_tail_x15_r0_body.zm105_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw105_2673472
  zwV := PRE_first_tail_x15_r0_body.zw105_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap105
  zclbd := PRE_first_tail_x15_r0_body.zclbd105
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap105 PRE_first_tail_x15_r0_body.stFoot105 PRE_first_tail_x15_r0_body.iso105 PRE_first_tail_x15_r0_body.zwr105
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP105
  csupp := PRE_first_tail_x15_r0_body.csupp105
  cbound := PRE_first_tail_x15_r0_body.cbound105
  zimg := PRE_first_tail_x15_r0_body.zimg105
  zctl := PRE_first_tail_x15_r0_body.zctl105
  zstack := PRE_first_tail_x15_r0_body.zstack105
  zjobs := PRE_first_tail_x15_r0_body.zjobs105
  zstores := PRE_first_tail_x15_r0_body.zstores105
  zroots := PRE_first_tail_x15_r0_body.zroots105
  znC := PRE_first_tail_x15_r0_body.znC105
  ctab := PRE_first_tail_x15_r0_body.ctab105
  zbin := PRE_first_tail_x15_r0_body.zbin105
  cbridge := PRE_first_tail_x15_r0_body.cbridge105
  sbridge := bodyBridge105
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj105
  cshiftR := fun h hNL => bodyCshift105 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN105
  raised := PRE_first_tail_x15_r0_body.raised105
  cbigs := PRE_first_tail_x15_r0_body.cbigs105
  cjcl := PRE_first_tail_x15_r0_body.cjcl105
  xnLe := Nat.le_of_ble_eq_true bodyXn105
  loLe := Nat.le_of_ble_eq_true bodyLo105
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB105
  cntM := bodyCntM105
  hiLe := Nat.le_of_ble_eq_true bodyHi105
  nhiLe := Nat.le_of_ble_eq_true bodyNhi105
  jsHeap := bodyJs105
  jsRoots := bodyJsRoots105
  jsNative := bodyJsNative105
  framesEmpty := bodyFramesEmpty105
  trailOld := by decide
  lowVars := bodyLow105

def bodyQs105 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs105 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr105.map fun r => nth? PRE_first_tail_x15_r0_body.st105.S3.tab r
kernel_rfl bodyResChk105 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs105 bodyQs105) = true
kernel_rfl bodyLq105 : bodyQs105.length = PRE_first_tail_x15_r0_body.cws105.length
kernel_rfl bodyNrLo105 : PRE_first_tail_x15_r0_body.nr105.all (Nat.ble PRE_first_tail_x15_r0_body.S1022.tab.length) = true
kernel_rfl bodySub105 : (Oracles.PRE_first_tail_x15_r0_body.map_site105.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost105 : postSubB bodyM PRE_first_tail_x15_r0_body.ws105 PRE_first_tail_x15_r0_body.cws105 bodyQs105 = true
kernel_rfl bodyDrop105 : Nat.ble (38456 + (PRE_first_tail_x15_r0_body.s1023.next - PRE_first_tail_x15_r0_body.s1024.next)) 38806 = true
kernel_rfl bodyDropH105 : Nat.ble (712 + ((mlxOf PRE_first_tail_x15_r0_body.s1023.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1024.ffi).next)) 714 = true
kernel_rfl bodyDropN105 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1023.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1024.ffi).nnext)) 0 = true
kernel_rfl bodyDv105 : bodyΘ.1.take 567 = bodyΘ.1.take 558 ++ PRE_first_tail_x15_r0_body.cws105
kernel_rfl bodyDe105 : bodyΘ.2.take 567 = bodyΘ.2.take 558 ++ PRE_first_tail_x15_r0_body.nr105.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st105.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 558) (bodyΘ.2.take 558)))
kernel_rfl bodyDl105 : (bodyΘ.1.take 558).length = (bodyΘ.2.take 558).length
kernel_rfl bodyDold105 : (bodyΘ.1.take 558).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws105).isNone && !PRE_first_tail_x15_r0_body.ws105.contains v) = true
kernel_rfl bodyDfree105 : (bodyΘ.2.take 567).all (fun e => (PRE_first_tail_x15_r0_body.cws105 ++ PRE_first_tail_x15_r0_body.ws105).all fun w => e.noVar w) = true

theorem bodyStep105 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38456, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.S1022)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38806, 714, 0, 567⟩ bodyM PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.S1024) (3452 + 1) :=
  bodySite bodyFacts105.cfix bodyFacts105.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st105.S3.tab) (Es := bodyEs105) (qs := bodyQs105)
    (ok := PRE_first_tail_x15_r0_body.st105.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site105 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts105
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site105 r hr) hi (MapOk.sub hm (sub_of_all bodySub105)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk105 r hr) hi hm ho hq)
    bodyLq105 rfl bodyNrLo105 (postSub_sound bodyPost105)
    (Nat.le_of_ble_eq_true bodyDrop105) (by decide) (Nat.le_of_ble_eq_true bodyDropH105) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN105) (by decide)
    bodyDv105 bodyDe105 bodyDl105 bodyDold105 bodyDfree105 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
