import host.sim.compose.a4b.vw15.VWBodyJ99
import host.sim.compose.a4b.vw15.VWBodySite99
import host.sim.compose.a4b.vw15.VWBodyOracles_24
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

theorem bodyCshift99 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S965.tab.length PRE_first_tail_x15_r0_body.s965.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P99.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P99 4334 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.s967.ffi PRE_first_tail_x15_r0_body.s966.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_99
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_99
  have hcl : SSt (· < 4334) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S965.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_99] <;> decide) PRE_first_tail_x15_r0_body.cnodesK99 PRE_first_tail_x15_r0_body.cobjsK99
      PRE_first_tail_x15_r0_body.citemsK99 PRE_first_tail_x15_r0_body.cbd99 PRE_first_tail_x15_r0_body.csst99
  exact PRE_first_tail_x15_r0_body.cshift99 bodyNcl99 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_99] at this; exact this)


kernel_rfl bodyFramesEmpty99 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s966 a).isEmpty) = true
kernel_rfl bodyJsRoots99 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s965.next) PRE_first_tail_x15_r0_body.s967.trace PRE_first_tail_x15_r0_body.s967 = true
kernel_rfl bodyJsNative99 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s967.ffi) = true
kernel_rfl bodyLow99 : (PRE_first_tail_x15_r0_body.cws99 ++ PRE_first_tail_x15_r0_body.ws99).all (Nat.ble 9) = true
kernel_rfl bodyCntM99 : countersOkB PRE_first_tail_x15_r0_body.s965 PRE_first_tail_x15_r0_body.s966 = true
kernel_rfl bodyHi99 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s967.ffi).next setupP.E = true
kernel_rfl bodyNhi99 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s967.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge99 : bridgeOf PRE_first_tail_x15_r0_body.s966.ffi = bridgeOf PRE_first_tail_x15_r0_body.s965.ffi
kernel_rfl bodyNN99 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s965.ffi).nnext PRE_first_tail_x15_r0_body.P99.NL = true
kernel_rfl bodyXn99 : Nat.ble (⟨20164, 17264, 2753057, 4334⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s967.ffi).next = true
kernel_rfl bodyLo99 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s967.ffi).next = true
theorem bodyFacts99 : BodySiteFacts PRE_first_tail_x15_r0_body.s965 PRE_first_tail_x15_r0_body.s966 PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S965 PRE_first_tail_x15_r0_body.S966 PRE_first_tail_x15_r0_body.S967
    PRE_first_tail_x15_r0_body.ws99 PRE_first_tail_x15_r0_body.cws99 PRE_first_tail_x15_r0_body.nr99 PRE_first_tail_x15_r0_body.pl99 PRE_first_tail_x15_r0_body.cl99 2754206 4334 PRE_first_tail_x15_r0_body.kd99 PRE_first_tail_x15_r0_body.kappa99 PRE_first_tail_x15_r0_body.P99
    ⟨20161, 17237, 2753051, 4316⟩ ⟨20164, 17264, 2753057, 4334⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap99
  clean := bodyClean99
  cfix := PRE_first_tail_x15_r0_body.cfix99
  zpl := PRE_first_tail_x15_r0_body.zpl99
  zplnd := PRE_first_tail_x15_r0_body.zplnd99
  zn1 := PRE_first_tail_x15_r0_body.zn199
  zfirst := PRE_first_tail_x15_r0_body.zfirst99
  zscn := PRE_first_tail_x15_r0_body.zscn99
  zsmn := PRE_first_tail_x15_r0_body.zsmn99
  zgrow := PRE_first_tail_x15_r0_body.zgrow99
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab99
  zfresh := PRE_first_tail_x15_r0_body.zfresh99
  zcnd := PRE_first_tail_x15_r0_body.zcnd99
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi99
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt99
  zgP := PRE_first_tail_x15_r0_body.zg99_2665
  zkP := PRE_first_tail_x15_r0_body.zk99_2665
  zmP := PRE_first_tail_x15_r0_body.zm99_2665
  zgC := PRE_first_tail_x15_r0_body.zg99_2673467
  zkC := PRE_first_tail_x15_r0_body.zk99_2673467
  zmC := PRE_first_tail_x15_r0_body.zm99_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw99_2673472
  zwV := PRE_first_tail_x15_r0_body.zw99_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap99
  zclbd := PRE_first_tail_x15_r0_body.zclbd99
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap99 PRE_first_tail_x15_r0_body.stFoot99 PRE_first_tail_x15_r0_body.iso99 PRE_first_tail_x15_r0_body.zwr99
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP99
  csupp := PRE_first_tail_x15_r0_body.csupp99
  cbound := PRE_first_tail_x15_r0_body.cbound99
  zimg := PRE_first_tail_x15_r0_body.zimg99
  zctl := PRE_first_tail_x15_r0_body.zctl99
  zstack := PRE_first_tail_x15_r0_body.zstack99
  zjobs := PRE_first_tail_x15_r0_body.zjobs99
  zstores := PRE_first_tail_x15_r0_body.zstores99
  zroots := PRE_first_tail_x15_r0_body.zroots99
  znC := PRE_first_tail_x15_r0_body.znC99
  ctab := PRE_first_tail_x15_r0_body.ctab99
  zbin := PRE_first_tail_x15_r0_body.zbin99
  cbridge := PRE_first_tail_x15_r0_body.cbridge99
  sbridge := bodyBridge99
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj99
  cshiftR := fun h hNL => bodyCshift99 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN99
  raised := PRE_first_tail_x15_r0_body.raised99
  cbigs := PRE_first_tail_x15_r0_body.cbigs99
  cjcl := PRE_first_tail_x15_r0_body.cjcl99
  xnLe := Nat.le_of_ble_eq_true bodyXn99
  loLe := Nat.le_of_ble_eq_true bodyLo99
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB99
  cntM := bodyCntM99
  hiLe := Nat.le_of_ble_eq_true bodyHi99
  nhiLe := Nat.le_of_ble_eq_true bodyNhi99
  jsHeap := bodyJs99
  jsRoots := bodyJsRoots99
  jsNative := bodyJsNative99
  framesEmpty := bodyFramesEmpty99
  trailOld := by decide
  lowVars := bodyLow99

def bodyQs99 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs99 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr99.map fun r => nth? PRE_first_tail_x15_r0_body.st99.S5.tab r
kernel_rfl bodyResChk99 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs99 bodyQs99) = true
kernel_rfl bodyLq99 : bodyQs99.length = PRE_first_tail_x15_r0_body.cws99.length
kernel_rfl bodyNrLo99 : PRE_first_tail_x15_r0_body.nr99.all (Nat.ble PRE_first_tail_x15_r0_body.S965.tab.length) = true
kernel_rfl bodySub99 : (Oracles.PRE_first_tail_x15_r0_body.map_site99.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost99 : postSubB bodyM PRE_first_tail_x15_r0_body.ws99 PRE_first_tail_x15_r0_body.cws99 bodyQs99 = true
kernel_rfl bodyDrop99 : Nat.ble (36125 + (PRE_first_tail_x15_r0_body.s966.next - PRE_first_tail_x15_r0_body.s967.next)) 37274 = true
kernel_rfl bodyDropH99 : Nat.ble (662 + ((mlxOf PRE_first_tail_x15_r0_body.s966.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s967.ffi).next)) 687 = true
kernel_rfl bodyDropN99 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s966.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s967.ffi).nnext)) 0 = true
kernel_rfl bodyDv99 : bodyΘ.1.take 540 = bodyΘ.1.take 522 ++ PRE_first_tail_x15_r0_body.cws99
kernel_rfl bodyDe99 : bodyΘ.2.take 540 = bodyΘ.2.take 522 ++ PRE_first_tail_x15_r0_body.nr99.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st99.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 522) (bodyΘ.2.take 522)))
kernel_rfl bodyDl99 : (bodyΘ.1.take 522).length = (bodyΘ.2.take 522).length
kernel_rfl bodyDold99 : (bodyΘ.1.take 522).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws99).isNone && !PRE_first_tail_x15_r0_body.ws99.contains v) = true
kernel_rfl bodyDfree99 : (bodyΘ.2.take 540).all (fun e => (PRE_first_tail_x15_r0_body.cws99 ++ PRE_first_tail_x15_r0_body.ws99).all fun w => e.noVar w) = true

theorem bodyStep99 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36125, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s965 PRE_first_tail_x15_r0_body.S965)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37274, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.S967) (11334 + 1) :=
  bodySite bodyFacts99.cfix bodyFacts99.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st99.S5.tab) (Es := bodyEs99) (qs := bodyQs99)
    (ok := PRE_first_tail_x15_r0_body.st99.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site99 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts99
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site99 r hr) hi (MapOk.sub hm (sub_of_all bodySub99)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk99 r hr) hi hm ho hq)
    bodyLq99 rfl bodyNrLo99 (postSub_sound bodyPost99)
    (Nat.le_of_ble_eq_true bodyDrop99) (by decide) (Nat.le_of_ble_eq_true bodyDropH99) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN99) (by decide)
    bodyDv99 bodyDe99 bodyDl99 bodyDold99 bodyDfree99 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
