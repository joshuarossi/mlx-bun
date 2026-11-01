import host.sim.compose.a4b.vw15.VWBodyJ66
import host.sim.compose.a4b.vw15.VWBodySite66
import host.sim.compose.a4b.vw15.VWBodyOracles_16
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

theorem bodyCshift66 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S649.tab.length PRE_first_tail_x15_r0_body.s649.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P66.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P66 2924 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.s651.ffi PRE_first_tail_x15_r0_body.s650.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_66
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_66
  have hcl : SSt (· < 2924) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s651.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S649.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_66] <;> decide) PRE_first_tail_x15_r0_body.cnodesK66 PRE_first_tail_x15_r0_body.cobjsK66
      PRE_first_tail_x15_r0_body.citemsK66 PRE_first_tail_x15_r0_body.cbd66 PRE_first_tail_x15_r0_body.csst66
  exact PRE_first_tail_x15_r0_body.cshift66 bodyNcl66 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_66] at this; exact this)


kernel_rfl bodyFramesEmpty66 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s650 a).isEmpty) = true
kernel_rfl bodyJsRoots66 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s649.next) PRE_first_tail_x15_r0_body.s651.trace PRE_first_tail_x15_r0_body.s651 = true
kernel_rfl bodyJsNative66 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s651.ffi) = true
kernel_rfl bodyLow66 : (PRE_first_tail_x15_r0_body.cws66 ++ PRE_first_tail_x15_r0_body.ws66).all (Nat.ble 9) = true
kernel_rfl bodyCntM66 : countersOkB PRE_first_tail_x15_r0_body.s649 PRE_first_tail_x15_r0_body.s650 = true
kernel_rfl bodyHi66 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s651.ffi).next setupP.E = true
kernel_rfl bodyNhi66 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s651.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge66 : bridgeOf PRE_first_tail_x15_r0_body.s650.ffi = bridgeOf PRE_first_tail_x15_r0_body.s649.ffi
kernel_rfl bodyNN66 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s649.ffi).nnext PRE_first_tail_x15_r0_body.P66.NL = true
kernel_rfl bodyXn66 : Nat.ble (⟨19513, 16616, 2727065, 2924⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s651.ffi).next = true
kernel_rfl bodyLo66 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s651.ffi).next = true
theorem bodyFacts66 : BodySiteFacts PRE_first_tail_x15_r0_body.s649 PRE_first_tail_x15_r0_body.s650 PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S649 PRE_first_tail_x15_r0_body.S650 PRE_first_tail_x15_r0_body.S651
    PRE_first_tail_x15_r0_body.ws66 PRE_first_tail_x15_r0_body.cws66 PRE_first_tail_x15_r0_body.nr66 PRE_first_tail_x15_r0_body.pl66 PRE_first_tail_x15_r0_body.cl66 2728214 2924 PRE_first_tail_x15_r0_body.kd66 PRE_first_tail_x15_r0_body.kappa66 PRE_first_tail_x15_r0_body.P66
    ⟨19510, 16589, 2727059, 2906⟩ ⟨19513, 16616, 2727065, 2924⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap66
  clean := bodyClean66
  cfix := PRE_first_tail_x15_r0_body.cfix66
  zpl := PRE_first_tail_x15_r0_body.zpl66
  zplnd := PRE_first_tail_x15_r0_body.zplnd66
  zn1 := PRE_first_tail_x15_r0_body.zn166
  zfirst := PRE_first_tail_x15_r0_body.zfirst66
  zscn := PRE_first_tail_x15_r0_body.zscn66
  zsmn := PRE_first_tail_x15_r0_body.zsmn66
  zgrow := PRE_first_tail_x15_r0_body.zgrow66
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab66
  zfresh := PRE_first_tail_x15_r0_body.zfresh66
  zcnd := PRE_first_tail_x15_r0_body.zcnd66
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi66
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt66
  zgP := PRE_first_tail_x15_r0_body.zg66_2665
  zkP := PRE_first_tail_x15_r0_body.zk66_2665
  zmP := PRE_first_tail_x15_r0_body.zm66_2665
  zgC := PRE_first_tail_x15_r0_body.zg66_2673467
  zkC := PRE_first_tail_x15_r0_body.zk66_2673467
  zmC := PRE_first_tail_x15_r0_body.zm66_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw66_2673472
  zwV := PRE_first_tail_x15_r0_body.zw66_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap66
  zclbd := PRE_first_tail_x15_r0_body.zclbd66
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap66 PRE_first_tail_x15_r0_body.stFoot66 PRE_first_tail_x15_r0_body.iso66 PRE_first_tail_x15_r0_body.zwr66
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP66
  csupp := PRE_first_tail_x15_r0_body.csupp66
  cbound := PRE_first_tail_x15_r0_body.cbound66
  zimg := PRE_first_tail_x15_r0_body.zimg66
  zctl := PRE_first_tail_x15_r0_body.zctl66
  zstack := PRE_first_tail_x15_r0_body.zstack66
  zjobs := PRE_first_tail_x15_r0_body.zjobs66
  zstores := PRE_first_tail_x15_r0_body.zstores66
  zroots := PRE_first_tail_x15_r0_body.zroots66
  znC := PRE_first_tail_x15_r0_body.znC66
  ctab := PRE_first_tail_x15_r0_body.ctab66
  zbin := PRE_first_tail_x15_r0_body.zbin66
  cbridge := PRE_first_tail_x15_r0_body.cbridge66
  sbridge := bodyBridge66
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj66
  cshiftR := fun h hNL => bodyCshift66 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN66
  raised := PRE_first_tail_x15_r0_body.raised66
  cbigs := PRE_first_tail_x15_r0_body.cbigs66
  cjcl := PRE_first_tail_x15_r0_body.cjcl66
  xnLe := Nat.le_of_ble_eq_true bodyXn66
  loLe := Nat.le_of_ble_eq_true bodyLo66
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB66
  cntM := bodyCntM66
  hiLe := Nat.le_of_ble_eq_true bodyHi66
  nhiLe := Nat.le_of_ble_eq_true bodyNhi66
  jsHeap := bodyJs66
  jsRoots := bodyJsRoots66
  jsNative := bodyJsNative66
  framesEmpty := bodyFramesEmpty66
  trailOld := by decide
  lowVars := bodyLow66

def bodyQs66 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs66 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr66.map fun r => nth? PRE_first_tail_x15_r0_body.st66.S5.tab r
kernel_rfl bodyResChk66 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs66 bodyQs66) = true
kernel_rfl bodyLq66 : bodyQs66.length = PRE_first_tail_x15_r0_body.cws66.length
kernel_rfl bodyNrLo66 : PRE_first_tail_x15_r0_body.nr66.all (Nat.ble PRE_first_tail_x15_r0_body.S649.tab.length) = true
kernel_rfl bodySub66 : (Oracles.PRE_first_tail_x15_r0_body.map_site66.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost66 : postSubB bodyM PRE_first_tail_x15_r0_body.ws66 PRE_first_tail_x15_r0_body.cws66 bodyQs66 = true
kernel_rfl bodyDrop66 : Nat.ble (25724 + (PRE_first_tail_x15_r0_body.s650.next - PRE_first_tail_x15_r0_body.s651.next)) 26873 = true
kernel_rfl bodyDropH66 : Nat.ble (456 + ((mlxOf PRE_first_tail_x15_r0_body.s650.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s651.ffi).next)) 481 = true
kernel_rfl bodyDropN66 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s650.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s651.ffi).nnext)) 0 = true
kernel_rfl bodyDv66 : bodyΘ.1.take 369 = bodyΘ.1.take 351 ++ PRE_first_tail_x15_r0_body.cws66
kernel_rfl bodyDe66 : bodyΘ.2.take 369 = bodyΘ.2.take 351 ++ PRE_first_tail_x15_r0_body.nr66.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st66.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 351) (bodyΘ.2.take 351)))
kernel_rfl bodyDl66 : (bodyΘ.1.take 351).length = (bodyΘ.2.take 351).length
kernel_rfl bodyDold66 : (bodyΘ.1.take 351).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws66).isNone && !PRE_first_tail_x15_r0_body.ws66.contains v) = true
kernel_rfl bodyDfree66 : (bodyΘ.2.take 369).all (fun e => (PRE_first_tail_x15_r0_body.cws66 ++ PRE_first_tail_x15_r0_body.ws66).all fun w => e.noVar w) = true

theorem bodyStep66 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨25724, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s649 PRE_first_tail_x15_r0_body.S649)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26873, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s651 PRE_first_tail_x15_r0_body.S651) (11334 + 1) :=
  bodySite bodyFacts66.cfix bodyFacts66.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st66.S5.tab) (Es := bodyEs66) (qs := bodyQs66)
    (ok := PRE_first_tail_x15_r0_body.st66.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site66 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts66
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site66 r hr) hi (MapOk.sub hm (sub_of_all bodySub66)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk66 r hr) hi hm ho hq)
    bodyLq66 rfl bodyNrLo66 (postSub_sound bodyPost66)
    (Nat.le_of_ble_eq_true bodyDrop66) (by decide) (Nat.le_of_ble_eq_true bodyDropH66) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN66) (by decide)
    bodyDv66 bodyDe66 bodyDl66 bodyDold66 bodyDfree66 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
