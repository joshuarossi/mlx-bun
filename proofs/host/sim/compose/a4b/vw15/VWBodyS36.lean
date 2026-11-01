import host.sim.compose.a4b.vw15.VWBodyJ36
import host.sim.compose.a4b.vw15.VWBodySite36
import host.sim.compose.a4b.vw15.VWBodyOracles_9
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift36 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S361.tab.length PRE_first_tail_x15_r0_body.s361.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P36.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P36 1640 PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.s363.ffi PRE_first_tail_x15_r0_body.s362.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_36
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_36
  have hcl : SSt (· < 1640) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s363.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S361.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_36] <;> decide) PRE_first_tail_x15_r0_body.cnodesK36 PRE_first_tail_x15_r0_body.cobjsK36
      PRE_first_tail_x15_r0_body.citemsK36 PRE_first_tail_x15_r0_body.cbd36 PRE_first_tail_x15_r0_body.csst36
  exact PRE_first_tail_x15_r0_body.cshift36 bodyNcl36 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_36] at this; exact this)


kernel_rfl bodyFramesEmpty36 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s362 a).isEmpty) = true
kernel_rfl bodyJsRoots36 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s361.next) PRE_first_tail_x15_r0_body.s363.trace PRE_first_tail_x15_r0_body.s363 = true
kernel_rfl bodyJsNative36 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s363.ffi) = true
kernel_rfl bodyLow36 : (PRE_first_tail_x15_r0_body.cws36 ++ PRE_first_tail_x15_r0_body.ws36).all (Nat.ble 9) = true
kernel_rfl bodyCntM36 : countersOkB PRE_first_tail_x15_r0_body.s361 PRE_first_tail_x15_r0_body.s362 = true
kernel_rfl bodyHi36 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s363.ffi).next setupP.E = true
kernel_rfl bodyNhi36 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s363.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge36 : bridgeOf PRE_first_tail_x15_r0_body.s362.ffi = bridgeOf PRE_first_tail_x15_r0_body.s361.ffi
kernel_rfl bodyNN36 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s361.ffi).nnext PRE_first_tail_x15_r0_body.P36.NL = true
kernel_rfl bodyXn36 : Nat.ble (⟨18927, 16016, 2703709, 1640⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s363.ffi).next = true
kernel_rfl bodyLo36 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s363.ffi).next = true
theorem bodyFacts36 : BodySiteFacts PRE_first_tail_x15_r0_body.s361 PRE_first_tail_x15_r0_body.s362 PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S361 PRE_first_tail_x15_r0_body.S362 PRE_first_tail_x15_r0_body.S363
    PRE_first_tail_x15_r0_body.ws36 PRE_first_tail_x15_r0_body.cws36 PRE_first_tail_x15_r0_body.nr36 PRE_first_tail_x15_r0_body.pl36 PRE_first_tail_x15_r0_body.cl36 2704858 1640 PRE_first_tail_x15_r0_body.kd36 PRE_first_tail_x15_r0_body.kappa36 PRE_first_tail_x15_r0_body.P36
    ⟨18924, 15989, 2703703, 1622⟩ ⟨18927, 16016, 2703709, 1640⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap36
  clean := bodyClean36
  cfix := PRE_first_tail_x15_r0_body.cfix36
  zpl := PRE_first_tail_x15_r0_body.zpl36
  zplnd := PRE_first_tail_x15_r0_body.zplnd36
  zn1 := PRE_first_tail_x15_r0_body.zn136
  zfirst := PRE_first_tail_x15_r0_body.zfirst36
  zscn := PRE_first_tail_x15_r0_body.zscn36
  zsmn := PRE_first_tail_x15_r0_body.zsmn36
  zgrow := PRE_first_tail_x15_r0_body.zgrow36
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab36
  zfresh := PRE_first_tail_x15_r0_body.zfresh36
  zcnd := PRE_first_tail_x15_r0_body.zcnd36
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi36
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt36
  zgP := PRE_first_tail_x15_r0_body.zg36_2665
  zkP := PRE_first_tail_x15_r0_body.zk36_2665
  zmP := PRE_first_tail_x15_r0_body.zm36_2665
  zgC := PRE_first_tail_x15_r0_body.zg36_2673467
  zkC := PRE_first_tail_x15_r0_body.zk36_2673467
  zmC := PRE_first_tail_x15_r0_body.zm36_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw36_2673472
  zwV := PRE_first_tail_x15_r0_body.zw36_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap36
  zclbd := PRE_first_tail_x15_r0_body.zclbd36
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap36 PRE_first_tail_x15_r0_body.stFoot36 PRE_first_tail_x15_r0_body.iso36 PRE_first_tail_x15_r0_body.zwr36
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP36
  csupp := PRE_first_tail_x15_r0_body.csupp36
  cbound := PRE_first_tail_x15_r0_body.cbound36
  zimg := PRE_first_tail_x15_r0_body.zimg36
  zctl := PRE_first_tail_x15_r0_body.zctl36
  zstack := PRE_first_tail_x15_r0_body.zstack36
  zjobs := PRE_first_tail_x15_r0_body.zjobs36
  zstores := PRE_first_tail_x15_r0_body.zstores36
  zroots := PRE_first_tail_x15_r0_body.zroots36
  znC := PRE_first_tail_x15_r0_body.znC36
  ctab := PRE_first_tail_x15_r0_body.ctab36
  zbin := PRE_first_tail_x15_r0_body.zbin36
  cbridge := PRE_first_tail_x15_r0_body.cbridge36
  sbridge := bodyBridge36
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj36
  cshiftR := fun h hNL => bodyCshift36 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN36
  raised := PRE_first_tail_x15_r0_body.raised36
  cbigs := PRE_first_tail_x15_r0_body.cbigs36
  cjcl := PRE_first_tail_x15_r0_body.cjcl36
  xnLe := Nat.le_of_ble_eq_true bodyXn36
  loLe := Nat.le_of_ble_eq_true bodyLo36
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB36
  cntM := bodyCntM36
  hiLe := Nat.le_of_ble_eq_true bodyHi36
  nhiLe := Nat.le_of_ble_eq_true bodyNhi36
  jsHeap := bodyJs36
  jsRoots := bodyJsRoots36
  jsNative := bodyJsNative36
  framesEmpty := bodyFramesEmpty36
  trailOld := by decide
  lowVars := bodyLow36

def bodyQs36 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs36 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr36.map fun r => nth? PRE_first_tail_x15_r0_body.st36.S5.tab r
kernel_rfl bodyResChk36 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs36 bodyQs36) = true
kernel_rfl bodyLq36 : bodyQs36.length = PRE_first_tail_x15_r0_body.cws36.length
kernel_rfl bodyNrLo36 : PRE_first_tail_x15_r0_body.nr36.all (Nat.ble PRE_first_tail_x15_r0_body.S361.tab.length) = true
kernel_rfl bodySub36 : (Oracles.PRE_first_tail_x15_r0_body.map_site36.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost36 : postSubB bodyM PRE_first_tail_x15_r0_body.ws36 PRE_first_tail_x15_r0_body.cws36 bodyQs36 = true
kernel_rfl bodyDrop36 : Nat.ble (15667 + (PRE_first_tail_x15_r0_body.s362.next - PRE_first_tail_x15_r0_body.s363.next)) 16816 = true
kernel_rfl bodyDropH36 : Nat.ble (252 + ((mlxOf PRE_first_tail_x15_r0_body.s362.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s363.ffi).next)) 277 = true
kernel_rfl bodyDropN36 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s362.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s363.ffi).nnext)) 0 = true
kernel_rfl bodyDv36 : bodyΘ.1.take 207 = bodyΘ.1.take 189 ++ PRE_first_tail_x15_r0_body.cws36
kernel_rfl bodyDe36 : bodyΘ.2.take 207 = bodyΘ.2.take 189 ++ PRE_first_tail_x15_r0_body.nr36.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st36.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl36 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold36 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws36).isNone && !PRE_first_tail_x15_r0_body.ws36.contains v) = true
kernel_rfl bodyDfree36 : (bodyΘ.2.take 207).all (fun e => (PRE_first_tail_x15_r0_body.cws36 ++ PRE_first_tail_x15_r0_body.ws36).all fun w => e.noVar w) = true

theorem bodyStep36 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15667, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s361 PRE_first_tail_x15_r0_body.S361)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16816, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.S363) (11334 + 1) :=
  bodySite bodyFacts36.cfix bodyFacts36.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st36.S5.tab) (Es := bodyEs36) (qs := bodyQs36)
    (ok := PRE_first_tail_x15_r0_body.st36.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site36 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts36
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site36 r hr) hi (MapOk.sub hm (sub_of_all bodySub36)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk36 r hr) hi hm ho hq)
    bodyLq36 rfl bodyNrLo36 (postSub_sound bodyPost36)
    (Nat.le_of_ble_eq_true bodyDrop36) (by decide) (Nat.le_of_ble_eq_true bodyDropH36) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN36) (by decide)
    bodyDv36 bodyDe36 bodyDl36 bodyDold36 bodyDfree36 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
