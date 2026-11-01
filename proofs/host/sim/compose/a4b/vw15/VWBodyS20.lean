import host.sim.compose.a4b.vw15.VWBodyJ20
import host.sim.compose.a4b.vw15.VWBodySite20
import host.sim.compose.a4b.vw15.VWBodyOracles_5
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

theorem bodyCshift20 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S201.tab.length PRE_first_tail_x15_r0_body.s201.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P20.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P20 910 PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.s203.ffi PRE_first_tail_x15_r0_body.s202.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_20
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_20
  have hcl : SSt (· < 910) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s203.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S201.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_20] <;> decide) PRE_first_tail_x15_r0_body.cnodesK20 PRE_first_tail_x15_r0_body.cobjsK20
      PRE_first_tail_x15_r0_body.citemsK20 PRE_first_tail_x15_r0_body.cbd20 PRE_first_tail_x15_r0_body.csst20
  exact PRE_first_tail_x15_r0_body.cshift20 bodyNcl20 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_20] at this; exact this)


kernel_rfl bodyFramesEmpty20 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s202 a).isEmpty) = true
kernel_rfl bodyJsRoots20 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s201.next) PRE_first_tail_x15_r0_body.s203.trace PRE_first_tail_x15_r0_body.s203 = true
kernel_rfl bodyJsNative20 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s203.ffi) = true
kernel_rfl bodyLow20 : (PRE_first_tail_x15_r0_body.cws20 ++ PRE_first_tail_x15_r0_body.ws20).all (Nat.ble 9) = true
kernel_rfl bodyCntM20 : countersOkB PRE_first_tail_x15_r0_body.s201 PRE_first_tail_x15_r0_body.s202 = true
kernel_rfl bodyHi20 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s203.ffi).next setupP.E = true
kernel_rfl bodyNhi20 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s203.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge20 : bridgeOf PRE_first_tail_x15_r0_body.s202.ffi = bridgeOf PRE_first_tail_x15_r0_body.s201.ffi
kernel_rfl bodyNN20 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s201.ffi).nnext PRE_first_tail_x15_r0_body.P20.NL = true
kernel_rfl bodyXn20 : Nat.ble (⟨18589, 15685, 2690172, 910⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s203.ffi).next = true
kernel_rfl bodyLo20 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s203.ffi).next = true
theorem bodyFacts20 : BodySiteFacts PRE_first_tail_x15_r0_body.s201 PRE_first_tail_x15_r0_body.s202 PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S201 PRE_first_tail_x15_r0_body.S202 PRE_first_tail_x15_r0_body.S203
    PRE_first_tail_x15_r0_body.ws20 PRE_first_tail_x15_r0_body.cws20 PRE_first_tail_x15_r0_body.nr20 PRE_first_tail_x15_r0_body.pl20 PRE_first_tail_x15_r0_body.cl20 2690182 910 PRE_first_tail_x15_r0_body.kd20 PRE_first_tail_x15_r0_body.kappa20 PRE_first_tail_x15_r0_body.P20
    ⟨18589, 15685, 2690171, 910⟩ ⟨18589, 15685, 2690172, 910⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap20
  clean := bodyClean20
  cfix := PRE_first_tail_x15_r0_body.cfix20
  zpl := PRE_first_tail_x15_r0_body.zpl20
  zplnd := PRE_first_tail_x15_r0_body.zplnd20
  zn1 := PRE_first_tail_x15_r0_body.zn120
  zfirst := PRE_first_tail_x15_r0_body.zfirst20
  zscn := PRE_first_tail_x15_r0_body.zscn20
  zsmn := PRE_first_tail_x15_r0_body.zsmn20
  zgrow := PRE_first_tail_x15_r0_body.zgrow20
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab20
  zfresh := PRE_first_tail_x15_r0_body.zfresh20
  zcnd := PRE_first_tail_x15_r0_body.zcnd20
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi20
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt20
  zgP := PRE_first_tail_x15_r0_body.zg20_2665
  zkP := PRE_first_tail_x15_r0_body.zk20_2665
  zmP := PRE_first_tail_x15_r0_body.zm20_2665
  zgC := PRE_first_tail_x15_r0_body.zg20_2673467
  zkC := PRE_first_tail_x15_r0_body.zk20_2673467
  zmC := PRE_first_tail_x15_r0_body.zm20_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw20_2673472
  zwV := PRE_first_tail_x15_r0_body.zw20_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap20
  zclbd := PRE_first_tail_x15_r0_body.zclbd20
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap20 PRE_first_tail_x15_r0_body.stFoot20 PRE_first_tail_x15_r0_body.iso20 PRE_first_tail_x15_r0_body.zwr20
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP20
  csupp := PRE_first_tail_x15_r0_body.csupp20
  cbound := PRE_first_tail_x15_r0_body.cbound20
  zimg := PRE_first_tail_x15_r0_body.zimg20
  zctl := PRE_first_tail_x15_r0_body.zctl20
  zstack := PRE_first_tail_x15_r0_body.zstack20
  zjobs := PRE_first_tail_x15_r0_body.zjobs20
  zstores := PRE_first_tail_x15_r0_body.zstores20
  zroots := PRE_first_tail_x15_r0_body.zroots20
  znC := PRE_first_tail_x15_r0_body.znC20
  ctab := PRE_first_tail_x15_r0_body.ctab20
  zbin := PRE_first_tail_x15_r0_body.zbin20
  cbridge := PRE_first_tail_x15_r0_body.cbridge20
  sbridge := bodyBridge20
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj20
  cshiftR := fun h hNL => bodyCshift20 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN20
  raised := PRE_first_tail_x15_r0_body.raised20
  cbigs := PRE_first_tail_x15_r0_body.cbigs20
  cjcl := PRE_first_tail_x15_r0_body.cjcl20
  xnLe := Nat.le_of_ble_eq_true bodyXn20
  loLe := Nat.le_of_ble_eq_true bodyLo20
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB20
  cntM := bodyCntM20
  hiLe := Nat.le_of_ble_eq_true bodyHi20
  nhiLe := Nat.le_of_ble_eq_true bodyNhi20
  jsHeap := bodyJs20
  jsRoots := bodyJsRoots20
  jsNative := bodyJsNative20
  framesEmpty := bodyFramesEmpty20
  trailOld := by decide
  lowVars := bodyLow20

def bodyQs20 : List (Option Q) := []
noncomputable def bodyEs20 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr20.map fun r => nth? PRE_first_tail_x15_r0_body.st20.S2.tab r
kernel_rfl bodyResChk20 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs20 bodyQs20) = true
kernel_rfl bodyLq20 : bodyQs20.length = PRE_first_tail_x15_r0_body.cws20.length
kernel_rfl bodyNrLo20 : PRE_first_tail_x15_r0_body.nr20.all (Nat.ble PRE_first_tail_x15_r0_body.S201.tab.length) = true
kernel_rfl bodySub20 : (Oracles.PRE_first_tail_x15_r0_body.map_site20.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost20 : postSubB bodyM PRE_first_tail_x15_r0_body.ws20 PRE_first_tail_x15_r0_body.cws20 bodyQs20 = true
kernel_rfl bodyDrop20 : Nat.ble (11441 + (PRE_first_tail_x15_r0_body.s202.next - PRE_first_tail_x15_r0_body.s203.next)) 11451 = true
kernel_rfl bodyDropH20 : Nat.ble (173 + ((mlxOf PRE_first_tail_x15_r0_body.s202.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s203.ffi).next)) 173 = true
kernel_rfl bodyDropN20 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s202.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s203.ffi).nnext)) 0 = true
kernel_rfl bodyDv20 : bodyΘ.1.take 117 = bodyΘ.1.take 117 ++ PRE_first_tail_x15_r0_body.cws20
kernel_rfl bodyDe20 : bodyΘ.2.take 117 = bodyΘ.2.take 117 ++ PRE_first_tail_x15_r0_body.nr20.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st20.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 117) (bodyΘ.2.take 117)))
kernel_rfl bodyDl20 : (bodyΘ.1.take 117).length = (bodyΘ.2.take 117).length
kernel_rfl bodyDold20 : (bodyΘ.1.take 117).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws20).isNone && !PRE_first_tail_x15_r0_body.ws20.contains v) = true
kernel_rfl bodyDfree20 : (bodyΘ.2.take 117).all (fun e => (PRE_first_tail_x15_r0_body.cws20 ++ PRE_first_tail_x15_r0_body.ws20).all fun w => e.noVar w) = true

theorem bodyStep20 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11441, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s201 PRE_first_tail_x15_r0_body.S201)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11451, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.S203) (98 + 1) :=
  bodySite bodyFacts20.cfix bodyFacts20.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st20.S2.tab) (Es := bodyEs20) (qs := bodyQs20)
    (ok := PRE_first_tail_x15_r0_body.st20.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site20 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts20
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site20 r hr) hi (MapOk.sub hm (sub_of_all bodySub20)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk20 r hr) hi hm ho hq)
    bodyLq20 rfl bodyNrLo20 (postSub_sound bodyPost20)
    (Nat.le_of_ble_eq_true bodyDrop20) (by decide) (Nat.le_of_ble_eq_true bodyDropH20) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN20) (by decide)
    bodyDv20 bodyDe20 bodyDl20 bodyDold20 bodyDfree20 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
