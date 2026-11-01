import host.sim.compose.a4b.vw15.VWBodyJ141
import host.sim.compose.a4b.vw15.VWBodySite141
import host.sim.compose.a4b.vw15.VWBodyOracles_35
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift141 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1367.tab.length PRE_first_tail_x15_r0_body.s1367.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P141.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.s1369.ffi PRE_first_tail_x15_r0_body.s1368.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_141
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_141
  have hcl : SSt (· < 6126) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1367.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_141] <;> decide) PRE_first_tail_x15_r0_body.cnodesK141 PRE_first_tail_x15_r0_body.cobjsK141
      PRE_first_tail_x15_r0_body.citemsK141 PRE_first_tail_x15_r0_body.cbd141 PRE_first_tail_x15_r0_body.csst141
  exact PRE_first_tail_x15_r0_body.cshift141 bodyNcl141 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_141] at this; exact this)


kernel_rfl bodyFramesEmpty141 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1368 a).isEmpty) = true
kernel_rfl bodyJsRoots141 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1367.next) PRE_first_tail_x15_r0_body.s1369.trace PRE_first_tail_x15_r0_body.s1369 = true
kernel_rfl bodyJsNative141 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1369.ffi) = true
kernel_rfl bodyLow141 : (PRE_first_tail_x15_r0_body.cws141 ++ PRE_first_tail_x15_r0_body.ws141).all (Nat.ble 9) = true
kernel_rfl bodyCntM141 : countersOkB PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.s1368 = true
kernel_rfl bodyHi141 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1369.ffi).next setupP.E = true
kernel_rfl bodyNhi141 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1369.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge141 : bridgeOf PRE_first_tail_x15_r0_body.s1368.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1367.ffi
kernel_rfl bodyNN141 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1367.ffi).nnext PRE_first_tail_x15_r0_body.P141.NL = true
kernel_rfl bodyXn141 : Nat.ble (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1369.ffi).next = true
kernel_rfl bodyLo141 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1369.ffi).next = true
theorem bodyFacts141 : BodySiteFacts PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.s1368 PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1367 PRE_first_tail_x15_r0_body.S1368 PRE_first_tail_x15_r0_body.S1369
    PRE_first_tail_x15_r0_body.ws141 PRE_first_tail_x15_r0_body.cws141 PRE_first_tail_x15_r0_body.nr141 PRE_first_tail_x15_r0_body.pl141 PRE_first_tail_x15_r0_body.cl141 2786441 6126 PRE_first_tail_x15_r0_body.kd141 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.P141
    ⟨20989, 18083, 2786076, 6117⟩ ⟨20993, 18089, 2786091, 6126⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap141
  clean := bodyClean141
  cfix := PRE_first_tail_x15_r0_body.cfix141
  zpl := PRE_first_tail_x15_r0_body.zpl141
  zplnd := PRE_first_tail_x15_r0_body.zplnd141
  zn1 := PRE_first_tail_x15_r0_body.zn1141
  zfirst := PRE_first_tail_x15_r0_body.zfirst141
  zscn := PRE_first_tail_x15_r0_body.zscn141
  zsmn := PRE_first_tail_x15_r0_body.zsmn141
  zgrow := PRE_first_tail_x15_r0_body.zgrow141
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab141
  zfresh := PRE_first_tail_x15_r0_body.zfresh141
  zcnd := PRE_first_tail_x15_r0_body.zcnd141
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi141
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt141
  zgP := PRE_first_tail_x15_r0_body.zg141_2665
  zkP := PRE_first_tail_x15_r0_body.zk141_2665
  zmP := PRE_first_tail_x15_r0_body.zm141_2665
  zgC := PRE_first_tail_x15_r0_body.zg141_2673467
  zkC := PRE_first_tail_x15_r0_body.zk141_2673467
  zmC := PRE_first_tail_x15_r0_body.zm141_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw141_2673472
  zwV := PRE_first_tail_x15_r0_body.zw141_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap141
  zclbd := PRE_first_tail_x15_r0_body.zclbd141
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap141 PRE_first_tail_x15_r0_body.stFoot141 PRE_first_tail_x15_r0_body.iso141 PRE_first_tail_x15_r0_body.zwr141
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP141
  csupp := PRE_first_tail_x15_r0_body.csupp141
  cbound := PRE_first_tail_x15_r0_body.cbound141
  zimg := PRE_first_tail_x15_r0_body.zimg141
  zctl := PRE_first_tail_x15_r0_body.zctl141
  zstack := PRE_first_tail_x15_r0_body.zstack141
  zjobs := PRE_first_tail_x15_r0_body.zjobs141
  zstores := PRE_first_tail_x15_r0_body.zstores141
  zroots := PRE_first_tail_x15_r0_body.zroots141
  znC := PRE_first_tail_x15_r0_body.znC141
  ctab := PRE_first_tail_x15_r0_body.ctab141
  zbin := PRE_first_tail_x15_r0_body.zbin141
  cbridge := PRE_first_tail_x15_r0_body.cbridge141
  sbridge := bodyBridge141
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj141
  cshiftR := fun h hNL => bodyCshift141 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN141
  raised := PRE_first_tail_x15_r0_body.raised141
  cbigs := PRE_first_tail_x15_r0_body.cbigs141
  cjcl := PRE_first_tail_x15_r0_body.cjcl141
  xnLe := Nat.le_of_ble_eq_true bodyXn141
  loLe := Nat.le_of_ble_eq_true bodyLo141
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB141
  cntM := bodyCntM141
  hiLe := Nat.le_of_ble_eq_true bodyHi141
  nhiLe := Nat.le_of_ble_eq_true bodyNhi141
  jsHeap := bodyJs141
  jsRoots := bodyJsRoots141
  jsNative := bodyJsNative141
  framesEmpty := bodyFramesEmpty141
  trailOld := by decide
  lowVars := bodyLow141

def bodyQs141 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs141 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr141.map fun r => nth? PRE_first_tail_x15_r0_body.st141.S3.tab r
kernel_rfl bodyResChk141 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs141 bodyQs141) = true
kernel_rfl bodyLq141 : bodyQs141.length = PRE_first_tail_x15_r0_body.cws141.length
kernel_rfl bodyNrLo141 : PRE_first_tail_x15_r0_body.nr141.all (Nat.ble PRE_first_tail_x15_r0_body.S1367.tab.length) = true
kernel_rfl bodySub141 : (Oracles.PRE_first_tail_x15_r0_body.map_site141.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost141 : postSubB bodyM PRE_first_tail_x15_r0_body.ws141 PRE_first_tail_x15_r0_body.cws141 bodyQs141 = true
kernel_rfl bodyDrop141 : Nat.ble (50009 + (PRE_first_tail_x15_r0_body.s1368.next - PRE_first_tail_x15_r0_body.s1369.next)) 50359 = true
kernel_rfl bodyDropH141 : Nat.ble (943 + ((mlxOf PRE_first_tail_x15_r0_body.s1368.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1369.ffi).next)) 945 = true
kernel_rfl bodyDropN141 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1368.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1369.ffi).nnext)) 0 = true
kernel_rfl bodyDv141 : bodyΘ.1.take 756 = bodyΘ.1.take 747 ++ PRE_first_tail_x15_r0_body.cws141
kernel_rfl bodyDe141 : bodyΘ.2.take 756 = bodyΘ.2.take 747 ++ PRE_first_tail_x15_r0_body.nr141.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st141.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 747) (bodyΘ.2.take 747)))
kernel_rfl bodyDl141 : (bodyΘ.1.take 747).length = (bodyΘ.2.take 747).length
kernel_rfl bodyDold141 : (bodyΘ.1.take 747).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws141).isNone && !PRE_first_tail_x15_r0_body.ws141.contains v) = true
kernel_rfl bodyDfree141 : (bodyΘ.2.take 756).all (fun e => (PRE_first_tail_x15_r0_body.cws141 ++ PRE_first_tail_x15_r0_body.ws141).all fun w => e.noVar w) = true

theorem bodyStep141 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50009, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.S1367)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50359, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.S1369) (3452 + 1) :=
  bodySite bodyFacts141.cfix bodyFacts141.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st141.S3.tab) (Es := bodyEs141) (qs := bodyQs141)
    (ok := PRE_first_tail_x15_r0_body.st141.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site141 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts141
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site141 r hr) hi (MapOk.sub hm (sub_of_all bodySub141)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk141 r hr) hi hm ho hq)
    bodyLq141 rfl bodyNrLo141 (postSub_sound bodyPost141)
    (Nat.le_of_ble_eq_true bodyDrop141) (by decide) (Nat.le_of_ble_eq_true bodyDropH141) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN141) (by decide)
    bodyDv141 bodyDe141 bodyDl141 bodyDold141 bodyDfree141 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
