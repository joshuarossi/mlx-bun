import host.sim.compose.a4b.vw15.VWBodyJ69
import host.sim.compose.a4b.vw15.VWBodySite69
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

theorem bodyCshift69 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S677.tab.length PRE_first_tail_x15_r0_body.s677.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P69.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P69 3048 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.s679.ffi PRE_first_tail_x15_r0_body.s678.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_69
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_69
  have hcl : SSt (· < 3048) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S677.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_69] <;> decide) PRE_first_tail_x15_r0_body.cnodesK69 PRE_first_tail_x15_r0_body.cobjsK69
      PRE_first_tail_x15_r0_body.citemsK69 PRE_first_tail_x15_r0_body.cbd69 PRE_first_tail_x15_r0_body.csst69
  exact PRE_first_tail_x15_r0_body.cshift69 bodyNcl69 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_69] at this; exact this)


kernel_rfl bodyFramesEmpty69 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s678 a).isEmpty) = true
kernel_rfl bodyJsRoots69 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s677.next) PRE_first_tail_x15_r0_body.s679.trace PRE_first_tail_x15_r0_body.s679 = true
kernel_rfl bodyJsNative69 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s679.ffi) = true
kernel_rfl bodyLow69 : (PRE_first_tail_x15_r0_body.cws69 ++ PRE_first_tail_x15_r0_body.ws69).all (Nat.ble 9) = true
kernel_rfl bodyCntM69 : countersOkB PRE_first_tail_x15_r0_body.s677 PRE_first_tail_x15_r0_body.s678 = true
kernel_rfl bodyHi69 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s679.ffi).next setupP.E = true
kernel_rfl bodyNhi69 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s679.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge69 : bridgeOf PRE_first_tail_x15_r0_body.s678.ffi = bridgeOf PRE_first_tail_x15_r0_body.s677.ffi
kernel_rfl bodyNN69 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s677.ffi).nnext PRE_first_tail_x15_r0_body.P69.NL = true
kernel_rfl bodyXn69 : Nat.ble (⟨19577, 16667, 2729595, 3048⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s679.ffi).next = true
kernel_rfl bodyLo69 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s679.ffi).next = true
theorem bodyFacts69 : BodySiteFacts PRE_first_tail_x15_r0_body.s677 PRE_first_tail_x15_r0_body.s678 PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S677 PRE_first_tail_x15_r0_body.S678 PRE_first_tail_x15_r0_body.S679
    PRE_first_tail_x15_r0_body.ws69 PRE_first_tail_x15_r0_body.cws69 PRE_first_tail_x15_r0_body.nr69 PRE_first_tail_x15_r0_body.pl69 PRE_first_tail_x15_r0_body.cl69 2729945 3048 PRE_first_tail_x15_r0_body.kd69 PRE_first_tail_x15_r0_body.kappa69 PRE_first_tail_x15_r0_body.P69
    ⟨19573, 16661, 2729580, 3039⟩ ⟨19577, 16667, 2729595, 3048⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap69
  clean := bodyClean69
  cfix := PRE_first_tail_x15_r0_body.cfix69
  zpl := PRE_first_tail_x15_r0_body.zpl69
  zplnd := PRE_first_tail_x15_r0_body.zplnd69
  zn1 := PRE_first_tail_x15_r0_body.zn169
  zfirst := PRE_first_tail_x15_r0_body.zfirst69
  zscn := PRE_first_tail_x15_r0_body.zscn69
  zsmn := PRE_first_tail_x15_r0_body.zsmn69
  zgrow := PRE_first_tail_x15_r0_body.zgrow69
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab69
  zfresh := PRE_first_tail_x15_r0_body.zfresh69
  zcnd := PRE_first_tail_x15_r0_body.zcnd69
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi69
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt69
  zgP := PRE_first_tail_x15_r0_body.zg69_2665
  zkP := PRE_first_tail_x15_r0_body.zk69_2665
  zmP := PRE_first_tail_x15_r0_body.zm69_2665
  zgC := PRE_first_tail_x15_r0_body.zg69_2673467
  zkC := PRE_first_tail_x15_r0_body.zk69_2673467
  zmC := PRE_first_tail_x15_r0_body.zm69_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw69_2673472
  zwV := PRE_first_tail_x15_r0_body.zw69_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap69
  zclbd := PRE_first_tail_x15_r0_body.zclbd69
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap69 PRE_first_tail_x15_r0_body.stFoot69 PRE_first_tail_x15_r0_body.iso69 PRE_first_tail_x15_r0_body.zwr69
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP69
  csupp := PRE_first_tail_x15_r0_body.csupp69
  cbound := PRE_first_tail_x15_r0_body.cbound69
  zimg := PRE_first_tail_x15_r0_body.zimg69
  zctl := PRE_first_tail_x15_r0_body.zctl69
  zstack := PRE_first_tail_x15_r0_body.zstack69
  zjobs := PRE_first_tail_x15_r0_body.zjobs69
  zstores := PRE_first_tail_x15_r0_body.zstores69
  zroots := PRE_first_tail_x15_r0_body.zroots69
  znC := PRE_first_tail_x15_r0_body.znC69
  ctab := PRE_first_tail_x15_r0_body.ctab69
  zbin := PRE_first_tail_x15_r0_body.zbin69
  cbridge := PRE_first_tail_x15_r0_body.cbridge69
  sbridge := bodyBridge69
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj69
  cshiftR := fun h hNL => bodyCshift69 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN69
  raised := PRE_first_tail_x15_r0_body.raised69
  cbigs := PRE_first_tail_x15_r0_body.cbigs69
  cjcl := PRE_first_tail_x15_r0_body.cjcl69
  xnLe := Nat.le_of_ble_eq_true bodyXn69
  loLe := Nat.le_of_ble_eq_true bodyLo69
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB69
  cntM := bodyCntM69
  hiLe := Nat.le_of_ble_eq_true bodyHi69
  nhiLe := Nat.le_of_ble_eq_true bodyNhi69
  jsHeap := bodyJs69
  jsRoots := bodyJsRoots69
  jsNative := bodyJsNative69
  framesEmpty := bodyFramesEmpty69
  trailOld := by decide
  lowVars := bodyLow69

def bodyQs69 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs69 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr69.map fun r => nth? PRE_first_tail_x15_r0_body.st69.S3.tab r
kernel_rfl bodyResChk69 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs69 bodyQs69) = true
kernel_rfl bodyLq69 : bodyQs69.length = PRE_first_tail_x15_r0_body.cws69.length
kernel_rfl bodyNrLo69 : PRE_first_tail_x15_r0_body.nr69.all (Nat.ble PRE_first_tail_x15_r0_body.S677.tab.length) = true
kernel_rfl bodySub69 : (Oracles.PRE_first_tail_x15_r0_body.map_site69.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost69 : postSubB bodyM PRE_first_tail_x15_r0_body.ws69 PRE_first_tail_x15_r0_body.cws69 bodyQs69 = true
kernel_rfl bodyDrop69 : Nat.ble (26885 + (PRE_first_tail_x15_r0_body.s678.next - PRE_first_tail_x15_r0_body.s679.next)) 27235 = true
kernel_rfl bodyDropH69 : Nat.ble (481 + ((mlxOf PRE_first_tail_x15_r0_body.s678.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s679.ffi).next)) 483 = true
kernel_rfl bodyDropN69 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s678.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s679.ffi).nnext)) 0 = true
kernel_rfl bodyDv69 : bodyΘ.1.take 378 = bodyΘ.1.take 369 ++ PRE_first_tail_x15_r0_body.cws69
kernel_rfl bodyDe69 : bodyΘ.2.take 378 = bodyΘ.2.take 369 ++ PRE_first_tail_x15_r0_body.nr69.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st69.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 369) (bodyΘ.2.take 369)))
kernel_rfl bodyDl69 : (bodyΘ.1.take 369).length = (bodyΘ.2.take 369).length
kernel_rfl bodyDold69 : (bodyΘ.1.take 369).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws69).isNone && !PRE_first_tail_x15_r0_body.ws69.contains v) = true
kernel_rfl bodyDfree69 : (bodyΘ.2.take 378).all (fun e => (PRE_first_tail_x15_r0_body.cws69 ++ PRE_first_tail_x15_r0_body.ws69).all fun w => e.noVar w) = true

theorem bodyStep69 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26885, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s677 PRE_first_tail_x15_r0_body.S677)
      (bodyCut NB T tk π i x0 bodyΘ ⟨27235, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.S679) (3452 + 1) :=
  bodySite bodyFacts69.cfix bodyFacts69.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st69.S3.tab) (Es := bodyEs69) (qs := bodyQs69)
    (ok := PRE_first_tail_x15_r0_body.st69.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site69 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts69
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site69 r hr) hi (MapOk.sub hm (sub_of_all bodySub69)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk69 r hr) hi hm ho hq)
    bodyLq69 rfl bodyNrLo69 (postSub_sound bodyPost69)
    (Nat.le_of_ble_eq_true bodyDrop69) (by decide) (Nat.le_of_ble_eq_true bodyDropH69) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN69) (by decide)
    bodyDv69 bodyDe69 bodyDl69 bodyDold69 bodyDfree69 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
