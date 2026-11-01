import host.sim.compose.a4b.vw15.VWBodyJ74
import host.sim.compose.a4b.vw15.VWBodySite74
import host.sim.compose.a4b.vw15.VWBodyOracles_18
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

theorem bodyCshift74 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S718.tab.length PRE_first_tail_x15_r0_body.s718.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P74.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P74 3217 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.s720.ffi PRE_first_tail_x15_r0_body.s719.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_74
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_74
  have hcl : SSt (· < 3217) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s720.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S718.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_74] <;> decide) PRE_first_tail_x15_r0_body.cnodesK74 PRE_first_tail_x15_r0_body.cobjsK74
      PRE_first_tail_x15_r0_body.citemsK74 PRE_first_tail_x15_r0_body.cbd74 PRE_first_tail_x15_r0_body.csst74
  exact PRE_first_tail_x15_r0_body.cshift74 bodyNcl74 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_74] at this; exact this)


kernel_rfl bodyFramesEmpty74 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s719 a).isEmpty) = true
kernel_rfl bodyJsRoots74 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s718.next) PRE_first_tail_x15_r0_body.s720.trace PRE_first_tail_x15_r0_body.s720 = true
kernel_rfl bodyJsNative74 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s720.ffi) = true
kernel_rfl bodyLow74 : (PRE_first_tail_x15_r0_body.cws74 ++ PRE_first_tail_x15_r0_body.ws74).all (Nat.ble 9) = true
kernel_rfl bodyCntM74 : countersOkB PRE_first_tail_x15_r0_body.s718 PRE_first_tail_x15_r0_body.s719 = true
kernel_rfl bodyHi74 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s720.ffi).next setupP.E = true
kernel_rfl bodyNhi74 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s720.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge74 : bridgeOf PRE_first_tail_x15_r0_body.s719.ffi = bridgeOf PRE_first_tail_x15_r0_body.s718.ffi
kernel_rfl bodyNN74 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s718.ffi).nnext PRE_first_tail_x15_r0_body.P74.NL = true
kernel_rfl bodyXn74 : Nat.ble (⟨19655, 16744, 2732744, 3217⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s720.ffi).next = true
kernel_rfl bodyLo74 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s720.ffi).next = true
theorem bodyFacts74 : BodySiteFacts PRE_first_tail_x15_r0_body.s718 PRE_first_tail_x15_r0_body.s719 PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S718 PRE_first_tail_x15_r0_body.S719 PRE_first_tail_x15_r0_body.S720
    PRE_first_tail_x15_r0_body.ws74 PRE_first_tail_x15_r0_body.cws74 PRE_first_tail_x15_r0_body.nr74 PRE_first_tail_x15_r0_body.pl74 PRE_first_tail_x15_r0_body.cl74 2732754 3217 PRE_first_tail_x15_r0_body.kd74 PRE_first_tail_x15_r0_body.kappa74 PRE_first_tail_x15_r0_body.P74
    ⟨19655, 16744, 2732743, 3217⟩ ⟨19655, 16744, 2732744, 3217⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap74
  clean := bodyClean74
  cfix := PRE_first_tail_x15_r0_body.cfix74
  zpl := PRE_first_tail_x15_r0_body.zpl74
  zplnd := PRE_first_tail_x15_r0_body.zplnd74
  zn1 := PRE_first_tail_x15_r0_body.zn174
  zfirst := PRE_first_tail_x15_r0_body.zfirst74
  zscn := PRE_first_tail_x15_r0_body.zscn74
  zsmn := PRE_first_tail_x15_r0_body.zsmn74
  zgrow := PRE_first_tail_x15_r0_body.zgrow74
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab74
  zfresh := PRE_first_tail_x15_r0_body.zfresh74
  zcnd := PRE_first_tail_x15_r0_body.zcnd74
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi74
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt74
  zgP := PRE_first_tail_x15_r0_body.zg74_2665
  zkP := PRE_first_tail_x15_r0_body.zk74_2665
  zmP := PRE_first_tail_x15_r0_body.zm74_2665
  zgC := PRE_first_tail_x15_r0_body.zg74_2673467
  zkC := PRE_first_tail_x15_r0_body.zk74_2673467
  zmC := PRE_first_tail_x15_r0_body.zm74_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw74_2673472
  zwV := PRE_first_tail_x15_r0_body.zw74_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap74
  zclbd := PRE_first_tail_x15_r0_body.zclbd74
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap74 PRE_first_tail_x15_r0_body.stFoot74 PRE_first_tail_x15_r0_body.iso74 PRE_first_tail_x15_r0_body.zwr74
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP74
  csupp := PRE_first_tail_x15_r0_body.csupp74
  cbound := PRE_first_tail_x15_r0_body.cbound74
  zimg := PRE_first_tail_x15_r0_body.zimg74
  zctl := PRE_first_tail_x15_r0_body.zctl74
  zstack := PRE_first_tail_x15_r0_body.zstack74
  zjobs := PRE_first_tail_x15_r0_body.zjobs74
  zstores := PRE_first_tail_x15_r0_body.zstores74
  zroots := PRE_first_tail_x15_r0_body.zroots74
  znC := PRE_first_tail_x15_r0_body.znC74
  ctab := PRE_first_tail_x15_r0_body.ctab74
  zbin := PRE_first_tail_x15_r0_body.zbin74
  cbridge := PRE_first_tail_x15_r0_body.cbridge74
  sbridge := bodyBridge74
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj74
  cshiftR := fun h hNL => bodyCshift74 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN74
  raised := PRE_first_tail_x15_r0_body.raised74
  cbigs := PRE_first_tail_x15_r0_body.cbigs74
  cjcl := PRE_first_tail_x15_r0_body.cjcl74
  xnLe := Nat.le_of_ble_eq_true bodyXn74
  loLe := Nat.le_of_ble_eq_true bodyLo74
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB74
  cntM := bodyCntM74
  hiLe := Nat.le_of_ble_eq_true bodyHi74
  nhiLe := Nat.le_of_ble_eq_true bodyNhi74
  jsHeap := bodyJs74
  jsRoots := bodyJsRoots74
  jsNative := bodyJsNative74
  framesEmpty := bodyFramesEmpty74
  trailOld := by decide
  lowVars := bodyLow74

def bodyQs74 : List (Option Q) := []
noncomputable def bodyEs74 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr74.map fun r => nth? PRE_first_tail_x15_r0_body.st74.S2.tab r
kernel_rfl bodyResChk74 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs74 bodyQs74) = true
kernel_rfl bodyLq74 : bodyQs74.length = PRE_first_tail_x15_r0_body.cws74.length
kernel_rfl bodyNrLo74 : PRE_first_tail_x15_r0_body.nr74.all (Nat.ble PRE_first_tail_x15_r0_body.S718.tab.length) = true
kernel_rfl bodySub74 : (Oracles.PRE_first_tail_x15_r0_body.map_site74.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost74 : postSubB bodyM PRE_first_tail_x15_r0_body.ws74 PRE_first_tail_x15_r0_body.cws74 bodyQs74 = true
kernel_rfl bodyDrop74 : Nat.ble (28398 + (PRE_first_tail_x15_r0_body.s719.next - PRE_first_tail_x15_r0_body.s720.next)) 28408 = true
kernel_rfl bodyDropH74 : Nat.ble (508 + ((mlxOf PRE_first_tail_x15_r0_body.s719.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s720.ffi).next)) 508 = true
kernel_rfl bodyDropN74 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s719.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s720.ffi).nnext)) 0 = true
kernel_rfl bodyDv74 : bodyΘ.1.take 396 = bodyΘ.1.take 396 ++ PRE_first_tail_x15_r0_body.cws74
kernel_rfl bodyDe74 : bodyΘ.2.take 396 = bodyΘ.2.take 396 ++ PRE_first_tail_x15_r0_body.nr74.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st74.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 396) (bodyΘ.2.take 396)))
kernel_rfl bodyDl74 : (bodyΘ.1.take 396).length = (bodyΘ.2.take 396).length
kernel_rfl bodyDold74 : (bodyΘ.1.take 396).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws74).isNone && !PRE_first_tail_x15_r0_body.ws74.contains v) = true
kernel_rfl bodyDfree74 : (bodyΘ.2.take 396).all (fun e => (PRE_first_tail_x15_r0_body.cws74 ++ PRE_first_tail_x15_r0_body.ws74).all fun w => e.noVar w) = true

theorem bodyStep74 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28398, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s718 PRE_first_tail_x15_r0_body.S718)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28408, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.S720) (98 + 1) :=
  bodySite bodyFacts74.cfix bodyFacts74.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st74.S2.tab) (Es := bodyEs74) (qs := bodyQs74)
    (ok := PRE_first_tail_x15_r0_body.st74.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site74 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts74
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site74 r hr) hi (MapOk.sub hm (sub_of_all bodySub74)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk74 r hr) hi hm ho hq)
    bodyLq74 rfl bodyNrLo74 (postSub_sound bodyPost74)
    (Nat.le_of_ble_eq_true bodyDrop74) (by decide) (Nat.le_of_ble_eq_true bodyDropH74) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN74) (by decide)
    bodyDv74 bodyDe74 bodyDl74 bodyDold74 bodyDfree74 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
