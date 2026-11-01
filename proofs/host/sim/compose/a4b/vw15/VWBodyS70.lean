import host.sim.compose.a4b.vw15.VWBodyJ70
import host.sim.compose.a4b.vw15.VWBodySite70
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

theorem bodyCshift70 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S685.tab.length PRE_first_tail_x15_r0_body.s685.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P70.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P70 3071 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.s687.ffi PRE_first_tail_x15_r0_body.s686.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_70
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_70
  have hcl : SSt (· < 3071) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S685.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_70] <;> decide) PRE_first_tail_x15_r0_body.cnodesK70 PRE_first_tail_x15_r0_body.cobjsK70
      PRE_first_tail_x15_r0_body.citemsK70 PRE_first_tail_x15_r0_body.cbd70 PRE_first_tail_x15_r0_body.csst70
  exact PRE_first_tail_x15_r0_body.cshift70 bodyNcl70 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_70] at this; exact this)


kernel_rfl bodyFramesEmpty70 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s686 a).isEmpty) = true
kernel_rfl bodyJsRoots70 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s685.next) PRE_first_tail_x15_r0_body.s687.trace PRE_first_tail_x15_r0_body.s687 = true
kernel_rfl bodyJsNative70 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s687.ffi) = true
kernel_rfl bodyLow70 : (PRE_first_tail_x15_r0_body.cws70 ++ PRE_first_tail_x15_r0_body.ws70).all (Nat.ble 9) = true
kernel_rfl bodyCntM70 : countersOkB PRE_first_tail_x15_r0_body.s685 PRE_first_tail_x15_r0_body.s686 = true
kernel_rfl bodyHi70 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s687.ffi).next setupP.E = true
kernel_rfl bodyNhi70 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s687.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge70 : bridgeOf PRE_first_tail_x15_r0_body.s686.ffi = bridgeOf PRE_first_tail_x15_r0_body.s685.ffi
kernel_rfl bodyNN70 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s685.ffi).nnext PRE_first_tail_x15_r0_body.P70.NL = true
kernel_rfl bodyXn70 : Nat.ble (⟨19590, 16677, 2730177, 3071⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s687.ffi).next = true
kernel_rfl bodyLo70 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s687.ffi).next = true
theorem bodyFacts70 : BodySiteFacts PRE_first_tail_x15_r0_body.s685 PRE_first_tail_x15_r0_body.s686 PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S685 PRE_first_tail_x15_r0_body.S686 PRE_first_tail_x15_r0_body.S687
    PRE_first_tail_x15_r0_body.ws70 PRE_first_tail_x15_r0_body.cws70 PRE_first_tail_x15_r0_body.nr70 PRE_first_tail_x15_r0_body.pl70 PRE_first_tail_x15_r0_body.cl70 2730179 3071 PRE_first_tail_x15_r0_body.kd70 PRE_first_tail_x15_r0_body.kappa70 PRE_first_tail_x15_r0_body.P70
    ⟨19590, 16677, 2730177, 3071⟩ ⟨19590, 16677, 2730177, 3071⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap70
  clean := bodyClean70
  cfix := PRE_first_tail_x15_r0_body.cfix70
  zpl := PRE_first_tail_x15_r0_body.zpl70
  zplnd := PRE_first_tail_x15_r0_body.zplnd70
  zn1 := PRE_first_tail_x15_r0_body.zn170
  zfirst := PRE_first_tail_x15_r0_body.zfirst70
  zscn := PRE_first_tail_x15_r0_body.zscn70
  zsmn := PRE_first_tail_x15_r0_body.zsmn70
  zgrow := PRE_first_tail_x15_r0_body.zgrow70
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab70
  zfresh := PRE_first_tail_x15_r0_body.zfresh70
  zcnd := PRE_first_tail_x15_r0_body.zcnd70
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi70
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt70
  zgP := PRE_first_tail_x15_r0_body.zg70_2665
  zkP := PRE_first_tail_x15_r0_body.zk70_2665
  zmP := PRE_first_tail_x15_r0_body.zm70_2665
  zgC := PRE_first_tail_x15_r0_body.zg70_2673467
  zkC := PRE_first_tail_x15_r0_body.zk70_2673467
  zmC := PRE_first_tail_x15_r0_body.zm70_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw70_2673472
  zwV := PRE_first_tail_x15_r0_body.zw70_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap70
  zclbd := PRE_first_tail_x15_r0_body.zclbd70
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap70 PRE_first_tail_x15_r0_body.stFoot70 PRE_first_tail_x15_r0_body.iso70 PRE_first_tail_x15_r0_body.zwr70
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP70
  csupp := PRE_first_tail_x15_r0_body.csupp70
  cbound := PRE_first_tail_x15_r0_body.cbound70
  zimg := PRE_first_tail_x15_r0_body.zimg70
  zctl := PRE_first_tail_x15_r0_body.zctl70
  zstack := PRE_first_tail_x15_r0_body.zstack70
  zjobs := PRE_first_tail_x15_r0_body.zjobs70
  zstores := PRE_first_tail_x15_r0_body.zstores70
  zroots := PRE_first_tail_x15_r0_body.zroots70
  znC := PRE_first_tail_x15_r0_body.znC70
  ctab := PRE_first_tail_x15_r0_body.ctab70
  zbin := PRE_first_tail_x15_r0_body.zbin70
  cbridge := PRE_first_tail_x15_r0_body.cbridge70
  sbridge := bodyBridge70
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj70
  cshiftR := fun h hNL => bodyCshift70 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN70
  raised := PRE_first_tail_x15_r0_body.raised70
  cbigs := PRE_first_tail_x15_r0_body.cbigs70
  cjcl := PRE_first_tail_x15_r0_body.cjcl70
  xnLe := Nat.le_of_ble_eq_true bodyXn70
  loLe := Nat.le_of_ble_eq_true bodyLo70
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB70
  cntM := bodyCntM70
  hiLe := Nat.le_of_ble_eq_true bodyHi70
  nhiLe := Nat.le_of_ble_eq_true bodyNhi70
  jsHeap := bodyJs70
  jsRoots := bodyJsRoots70
  jsNative := bodyJsNative70
  framesEmpty := bodyFramesEmpty70
  trailOld := by decide
  lowVars := bodyLow70

def bodyQs70 : List (Option Q) := []
noncomputable def bodyEs70 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr70.map fun r => nth? PRE_first_tail_x15_r0_body.st70.S2.tab r
kernel_rfl bodyResChk70 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs70 bodyQs70) = true
kernel_rfl bodyLq70 : bodyQs70.length = PRE_first_tail_x15_r0_body.cws70.length
kernel_rfl bodyNrLo70 : PRE_first_tail_x15_r0_body.nr70.all (Nat.ble PRE_first_tail_x15_r0_body.S685.tab.length) = true
kernel_rfl bodySub70 : (Oracles.PRE_first_tail_x15_r0_body.map_site70.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost70 : postSubB bodyM PRE_first_tail_x15_r0_body.ws70 PRE_first_tail_x15_r0_body.cws70 bodyQs70 = true
kernel_rfl bodyDrop70 : Nat.ble (27235 + (PRE_first_tail_x15_r0_body.s686.next - PRE_first_tail_x15_r0_body.s687.next)) 27237 = true
kernel_rfl bodyDropH70 : Nat.ble (483 + ((mlxOf PRE_first_tail_x15_r0_body.s686.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s687.ffi).next)) 483 = true
kernel_rfl bodyDropN70 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s686.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s687.ffi).nnext)) 0 = true
kernel_rfl bodyDv70 : bodyΘ.1.take 378 = bodyΘ.1.take 378 ++ PRE_first_tail_x15_r0_body.cws70
kernel_rfl bodyDe70 : bodyΘ.2.take 378 = bodyΘ.2.take 378 ++ PRE_first_tail_x15_r0_body.nr70.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st70.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 378) (bodyΘ.2.take 378)))
kernel_rfl bodyDl70 : (bodyΘ.1.take 378).length = (bodyΘ.2.take 378).length
kernel_rfl bodyDold70 : (bodyΘ.1.take 378).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws70).isNone && !PRE_first_tail_x15_r0_body.ws70.contains v) = true
kernel_rfl bodyDfree70 : (bodyΘ.2.take 378).all (fun e => (PRE_first_tail_x15_r0_body.cws70 ++ PRE_first_tail_x15_r0_body.ws70).all fun w => e.noVar w) = true

theorem bodyStep70 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨27235, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s685 PRE_first_tail_x15_r0_body.S685)
      (bodyCut NB T tk π i x0 bodyΘ ⟨27237, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.S687) (27 + 1) :=
  bodySite bodyFacts70.cfix bodyFacts70.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st70.S2.tab) (Es := bodyEs70) (qs := bodyQs70)
    (ok := PRE_first_tail_x15_r0_body.st70.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site70 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts70
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site70 r hr) hi (MapOk.sub hm (sub_of_all bodySub70)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk70 r hr) hi hm ho hq)
    bodyLq70 rfl bodyNrLo70 (postSub_sound bodyPost70)
    (Nat.le_of_ble_eq_true bodyDrop70) (by decide) (Nat.le_of_ble_eq_true bodyDropH70) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN70) (by decide)
    bodyDv70 bodyDe70 bodyDl70 bodyDold70 bodyDfree70 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
