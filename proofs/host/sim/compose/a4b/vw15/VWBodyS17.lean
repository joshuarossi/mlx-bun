import host.sim.compose.a4b.vw15.VWBodyJ17
import host.sim.compose.a4b.vw15.VWBodySite17
import host.sim.compose.a4b.vw15.VWBodyOracles_4
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift17 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S172.tab.length PRE_first_tail_x15_r0_body.s172.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P17.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P17 781 PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.s174.ffi PRE_first_tail_x15_r0_body.s173.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_17
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_17
  have hcl : SSt (· < 781) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S172.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_17] <;> decide) PRE_first_tail_x15_r0_body.cnodesK17 PRE_first_tail_x15_r0_body.cobjsK17
      PRE_first_tail_x15_r0_body.citemsK17 PRE_first_tail_x15_r0_body.cbd17 PRE_first_tail_x15_r0_body.csst17
  exact PRE_first_tail_x15_r0_body.cshift17 bodyNcl17 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_17] at this; exact this)


kernel_rfl bodyFramesEmpty17 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s173 a).isEmpty) = true
kernel_rfl bodyJsRoots17 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s172.next) PRE_first_tail_x15_r0_body.s174.trace PRE_first_tail_x15_r0_body.s174 = true
kernel_rfl bodyJsNative17 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s174.ffi) = true
kernel_rfl bodyLow17 : (PRE_first_tail_x15_r0_body.cws17 ++ PRE_first_tail_x15_r0_body.ws17).all (Nat.ble 9) = true
kernel_rfl bodyCntM17 : countersOkB PRE_first_tail_x15_r0_body.s172 PRE_first_tail_x15_r0_body.s173 = true
kernel_rfl bodyHi17 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s174.ffi).next setupP.E = true
kernel_rfl bodyNhi17 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s174.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge17 : bridgeOf PRE_first_tail_x15_r0_body.s173.ffi = bridgeOf PRE_first_tail_x15_r0_body.s172.ffi
kernel_rfl bodyNN17 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s172.ffi).nnext PRE_first_tail_x15_r0_body.P17.NL = true
kernel_rfl bodyXn17 : Nat.ble (⟨18532, 15622, 2687916, 781⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s174.ffi).next = true
kernel_rfl bodyLo17 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s174.ffi).next = true
theorem bodyFacts17 : BodySiteFacts PRE_first_tail_x15_r0_body.s172 PRE_first_tail_x15_r0_body.s173 PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S172 PRE_first_tail_x15_r0_body.S173 PRE_first_tail_x15_r0_body.S174
    PRE_first_tail_x15_r0_body.ws17 PRE_first_tail_x15_r0_body.cws17 PRE_first_tail_x15_r0_body.nr17 PRE_first_tail_x15_r0_body.pl17 PRE_first_tail_x15_r0_body.cl17 2687926 781 PRE_first_tail_x15_r0_body.kd17 PRE_first_tail_x15_r0_body.kappa17 PRE_first_tail_x15_r0_body.P17
    ⟨18532, 15622, 2687915, 781⟩ ⟨18532, 15622, 2687916, 781⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap17
  clean := bodyClean17
  cfix := PRE_first_tail_x15_r0_body.cfix17
  zpl := PRE_first_tail_x15_r0_body.zpl17
  zplnd := PRE_first_tail_x15_r0_body.zplnd17
  zn1 := PRE_first_tail_x15_r0_body.zn117
  zfirst := PRE_first_tail_x15_r0_body.zfirst17
  zscn := PRE_first_tail_x15_r0_body.zscn17
  zsmn := PRE_first_tail_x15_r0_body.zsmn17
  zgrow := PRE_first_tail_x15_r0_body.zgrow17
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab17
  zfresh := PRE_first_tail_x15_r0_body.zfresh17
  zcnd := PRE_first_tail_x15_r0_body.zcnd17
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi17
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt17
  zgP := PRE_first_tail_x15_r0_body.zg17_2665
  zkP := PRE_first_tail_x15_r0_body.zk17_2665
  zmP := PRE_first_tail_x15_r0_body.zm17_2665
  zgC := PRE_first_tail_x15_r0_body.zg17_2673467
  zkC := PRE_first_tail_x15_r0_body.zk17_2673467
  zmC := PRE_first_tail_x15_r0_body.zm17_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw17_2673472
  zwV := PRE_first_tail_x15_r0_body.zw17_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap17
  zclbd := PRE_first_tail_x15_r0_body.zclbd17
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap17 PRE_first_tail_x15_r0_body.stFoot17 PRE_first_tail_x15_r0_body.iso17 PRE_first_tail_x15_r0_body.zwr17
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP17
  csupp := PRE_first_tail_x15_r0_body.csupp17
  cbound := PRE_first_tail_x15_r0_body.cbound17
  zimg := PRE_first_tail_x15_r0_body.zimg17
  zctl := PRE_first_tail_x15_r0_body.zctl17
  zstack := PRE_first_tail_x15_r0_body.zstack17
  zjobs := PRE_first_tail_x15_r0_body.zjobs17
  zstores := PRE_first_tail_x15_r0_body.zstores17
  zroots := PRE_first_tail_x15_r0_body.zroots17
  znC := PRE_first_tail_x15_r0_body.znC17
  ctab := PRE_first_tail_x15_r0_body.ctab17
  zbin := PRE_first_tail_x15_r0_body.zbin17
  cbridge := PRE_first_tail_x15_r0_body.cbridge17
  sbridge := bodyBridge17
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj17
  cshiftR := fun h hNL => bodyCshift17 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN17
  raised := PRE_first_tail_x15_r0_body.raised17
  cbigs := PRE_first_tail_x15_r0_body.cbigs17
  cjcl := PRE_first_tail_x15_r0_body.cjcl17
  xnLe := Nat.le_of_ble_eq_true bodyXn17
  loLe := Nat.le_of_ble_eq_true bodyLo17
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB17
  cntM := bodyCntM17
  hiLe := Nat.le_of_ble_eq_true bodyHi17
  nhiLe := Nat.le_of_ble_eq_true bodyNhi17
  jsHeap := bodyJs17
  jsRoots := bodyJsRoots17
  jsNative := bodyJsNative17
  framesEmpty := bodyFramesEmpty17
  trailOld := by decide
  lowVars := bodyLow17

def bodyQs17 : List (Option Q) := []
noncomputable def bodyEs17 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr17.map fun r => nth? PRE_first_tail_x15_r0_body.st17.S2.tab r
kernel_rfl bodyResChk17 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs17 bodyQs17) = true
kernel_rfl bodyLq17 : bodyQs17.length = PRE_first_tail_x15_r0_body.cws17.length
kernel_rfl bodyNrLo17 : PRE_first_tail_x15_r0_body.nr17.all (Nat.ble PRE_first_tail_x15_r0_body.S172.tab.length) = true
kernel_rfl bodySub17 : (Oracles.PRE_first_tail_x15_r0_body.map_site17.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost17 : postSubB bodyM PRE_first_tail_x15_r0_body.ws17 PRE_first_tail_x15_r0_body.cws17 bodyQs17 = true
kernel_rfl bodyDrop17 : Nat.ble (10280 + (PRE_first_tail_x15_r0_body.s173.next - PRE_first_tail_x15_r0_body.s174.next)) 10290 = true
kernel_rfl bodyDropH17 : Nat.ble (148 + ((mlxOf PRE_first_tail_x15_r0_body.s173.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s174.ffi).next)) 148 = true
kernel_rfl bodyDropN17 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s173.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s174.ffi).nnext)) 0 = true
kernel_rfl bodyDv17 : bodyΘ.1.take 99 = bodyΘ.1.take 99 ++ PRE_first_tail_x15_r0_body.cws17
kernel_rfl bodyDe17 : bodyΘ.2.take 99 = bodyΘ.2.take 99 ++ PRE_first_tail_x15_r0_body.nr17.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st17.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 99) (bodyΘ.2.take 99)))
kernel_rfl bodyDl17 : (bodyΘ.1.take 99).length = (bodyΘ.2.take 99).length
kernel_rfl bodyDold17 : (bodyΘ.1.take 99).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws17).isNone && !PRE_first_tail_x15_r0_body.ws17.contains v) = true
kernel_rfl bodyDfree17 : (bodyΘ.2.take 99).all (fun e => (PRE_first_tail_x15_r0_body.cws17 ++ PRE_first_tail_x15_r0_body.ws17).all fun w => e.noVar w) = true

theorem bodyStep17 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10280, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s172 PRE_first_tail_x15_r0_body.S172)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10290, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s174 PRE_first_tail_x15_r0_body.S174) (98 + 1) :=
  bodySite bodyFacts17.cfix bodyFacts17.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st17.S2.tab) (Es := bodyEs17) (qs := bodyQs17)
    (ok := PRE_first_tail_x15_r0_body.st17.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site17 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts17
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site17 r hr) hi (MapOk.sub hm (sub_of_all bodySub17)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk17 r hr) hi hm ho hq)
    bodyLq17 rfl bodyNrLo17 (postSub_sound bodyPost17)
    (Nat.le_of_ble_eq_true bodyDrop17) (by decide) (Nat.le_of_ble_eq_true bodyDropH17) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN17) (by decide)
    bodyDv17 bodyDe17 bodyDl17 bodyDold17 bodyDfree17 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
