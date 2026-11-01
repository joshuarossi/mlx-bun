import host.sim.compose.a4b.vw15.VWBodyJ100
import host.sim.compose.a4b.vw15.VWBodySite100
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

theorem bodyCshift100 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S973.tab.length PRE_first_tail_x15_r0_body.s973.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P100.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P100 4355 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.s975.ffi PRE_first_tail_x15_r0_body.s974.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_100
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_100
  have hcl : SSt (· < 4355) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s975.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S973.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_100] <;> decide) PRE_first_tail_x15_r0_body.cnodesK100 PRE_first_tail_x15_r0_body.cobjsK100
      PRE_first_tail_x15_r0_body.citemsK100 PRE_first_tail_x15_r0_body.cbd100 PRE_first_tail_x15_r0_body.csst100
  exact PRE_first_tail_x15_r0_body.cshift100 bodyNcl100 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_100] at this; exact this)


kernel_rfl bodyFramesEmpty100 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s974 a).isEmpty) = true
kernel_rfl bodyJsRoots100 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s973.next) PRE_first_tail_x15_r0_body.s975.trace PRE_first_tail_x15_r0_body.s975 = true
kernel_rfl bodyJsNative100 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s975.ffi) = true
kernel_rfl bodyLow100 : (PRE_first_tail_x15_r0_body.cws100 ++ PRE_first_tail_x15_r0_body.ws100).all (Nat.ble 9) = true
kernel_rfl bodyCntM100 : countersOkB PRE_first_tail_x15_r0_body.s973 PRE_first_tail_x15_r0_body.s974 = true
kernel_rfl bodyHi100 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s975.ffi).next setupP.E = true
kernel_rfl bodyNhi100 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s975.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge100 : bridgeOf PRE_first_tail_x15_r0_body.s974.ffi = bridgeOf PRE_first_tail_x15_r0_body.s973.ffi
kernel_rfl bodyNN100 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s973.ffi).nnext PRE_first_tail_x15_r0_body.P100.NL = true
kernel_rfl bodyXn100 : Nat.ble (⟨20177, 17277, 2753547, 4355⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s975.ffi).next = true
kernel_rfl bodyLo100 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s975.ffi).next = true
theorem bodyFacts100 : BodySiteFacts PRE_first_tail_x15_r0_body.s973 PRE_first_tail_x15_r0_body.s974 PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S973 PRE_first_tail_x15_r0_body.S974 PRE_first_tail_x15_r0_body.S975
    PRE_first_tail_x15_r0_body.ws100 PRE_first_tail_x15_r0_body.cws100 PRE_first_tail_x15_r0_body.nr100 PRE_first_tail_x15_r0_body.pl100 PRE_first_tail_x15_r0_body.cl100 2753549 4355 PRE_first_tail_x15_r0_body.kd100 PRE_first_tail_x15_r0_body.kappa100 PRE_first_tail_x15_r0_body.P100
    ⟨20177, 17277, 2753547, 4355⟩ ⟨20177, 17277, 2753547, 4355⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap100
  clean := bodyClean100
  cfix := PRE_first_tail_x15_r0_body.cfix100
  zpl := PRE_first_tail_x15_r0_body.zpl100
  zplnd := PRE_first_tail_x15_r0_body.zplnd100
  zn1 := PRE_first_tail_x15_r0_body.zn1100
  zfirst := PRE_first_tail_x15_r0_body.zfirst100
  zscn := PRE_first_tail_x15_r0_body.zscn100
  zsmn := PRE_first_tail_x15_r0_body.zsmn100
  zgrow := PRE_first_tail_x15_r0_body.zgrow100
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab100
  zfresh := PRE_first_tail_x15_r0_body.zfresh100
  zcnd := PRE_first_tail_x15_r0_body.zcnd100
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi100
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt100
  zgP := PRE_first_tail_x15_r0_body.zg100_2665
  zkP := PRE_first_tail_x15_r0_body.zk100_2665
  zmP := PRE_first_tail_x15_r0_body.zm100_2665
  zgC := PRE_first_tail_x15_r0_body.zg100_2673467
  zkC := PRE_first_tail_x15_r0_body.zk100_2673467
  zmC := PRE_first_tail_x15_r0_body.zm100_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw100_2673472
  zwV := PRE_first_tail_x15_r0_body.zw100_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap100
  zclbd := PRE_first_tail_x15_r0_body.zclbd100
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap100 PRE_first_tail_x15_r0_body.stFoot100 PRE_first_tail_x15_r0_body.iso100 PRE_first_tail_x15_r0_body.zwr100
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP100
  csupp := PRE_first_tail_x15_r0_body.csupp100
  cbound := PRE_first_tail_x15_r0_body.cbound100
  zimg := PRE_first_tail_x15_r0_body.zimg100
  zctl := PRE_first_tail_x15_r0_body.zctl100
  zstack := PRE_first_tail_x15_r0_body.zstack100
  zjobs := PRE_first_tail_x15_r0_body.zjobs100
  zstores := PRE_first_tail_x15_r0_body.zstores100
  zroots := PRE_first_tail_x15_r0_body.zroots100
  znC := PRE_first_tail_x15_r0_body.znC100
  ctab := PRE_first_tail_x15_r0_body.ctab100
  zbin := PRE_first_tail_x15_r0_body.zbin100
  cbridge := PRE_first_tail_x15_r0_body.cbridge100
  sbridge := bodyBridge100
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj100
  cshiftR := fun h hNL => bodyCshift100 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN100
  raised := PRE_first_tail_x15_r0_body.raised100
  cbigs := PRE_first_tail_x15_r0_body.cbigs100
  cjcl := PRE_first_tail_x15_r0_body.cjcl100
  xnLe := Nat.le_of_ble_eq_true bodyXn100
  loLe := Nat.le_of_ble_eq_true bodyLo100
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB100
  cntM := bodyCntM100
  hiLe := Nat.le_of_ble_eq_true bodyHi100
  nhiLe := Nat.le_of_ble_eq_true bodyNhi100
  jsHeap := bodyJs100
  jsRoots := bodyJsRoots100
  jsNative := bodyJsNative100
  framesEmpty := bodyFramesEmpty100
  trailOld := by decide
  lowVars := bodyLow100

def bodyQs100 : List (Option Q) := []
noncomputable def bodyEs100 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr100.map fun r => nth? PRE_first_tail_x15_r0_body.st100.S2.tab r
kernel_rfl bodyResChk100 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs100 bodyQs100) = true
kernel_rfl bodyLq100 : bodyQs100.length = PRE_first_tail_x15_r0_body.cws100.length
kernel_rfl bodyNrLo100 : PRE_first_tail_x15_r0_body.nr100.all (Nat.ble PRE_first_tail_x15_r0_body.S973.tab.length) = true
kernel_rfl bodySub100 : (Oracles.PRE_first_tail_x15_r0_body.map_site100.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost100 : postSubB bodyM PRE_first_tail_x15_r0_body.ws100 PRE_first_tail_x15_r0_body.cws100 bodyQs100 = true
kernel_rfl bodyDrop100 : Nat.ble (37274 + (PRE_first_tail_x15_r0_body.s974.next - PRE_first_tail_x15_r0_body.s975.next)) 37276 = true
kernel_rfl bodyDropH100 : Nat.ble (687 + ((mlxOf PRE_first_tail_x15_r0_body.s974.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s975.ffi).next)) 687 = true
kernel_rfl bodyDropN100 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s974.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s975.ffi).nnext)) 0 = true
kernel_rfl bodyDv100 : bodyΘ.1.take 540 = bodyΘ.1.take 540 ++ PRE_first_tail_x15_r0_body.cws100
kernel_rfl bodyDe100 : bodyΘ.2.take 540 = bodyΘ.2.take 540 ++ PRE_first_tail_x15_r0_body.nr100.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st100.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 540) (bodyΘ.2.take 540)))
kernel_rfl bodyDl100 : (bodyΘ.1.take 540).length = (bodyΘ.2.take 540).length
kernel_rfl bodyDold100 : (bodyΘ.1.take 540).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws100).isNone && !PRE_first_tail_x15_r0_body.ws100.contains v) = true
kernel_rfl bodyDfree100 : (bodyΘ.2.take 540).all (fun e => (PRE_first_tail_x15_r0_body.cws100 ++ PRE_first_tail_x15_r0_body.ws100).all fun w => e.noVar w) = true

theorem bodyStep100 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37274, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s973 PRE_first_tail_x15_r0_body.S973)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37276, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.S975) (27 + 1) :=
  bodySite bodyFacts100.cfix bodyFacts100.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st100.S2.tab) (Es := bodyEs100) (qs := bodyQs100)
    (ok := PRE_first_tail_x15_r0_body.st100.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site100 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts100
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site100 r hr) hi (MapOk.sub hm (sub_of_all bodySub100)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk100 r hr) hi hm ho hq)
    bodyLq100 rfl bodyNrLo100 (postSub_sound bodyPost100)
    (Nat.le_of_ble_eq_true bodyDrop100) (by decide) (Nat.le_of_ble_eq_true bodyDropH100) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN100) (by decide)
    bodyDv100 bodyDe100 bodyDl100 bodyDold100 bodyDfree100 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
