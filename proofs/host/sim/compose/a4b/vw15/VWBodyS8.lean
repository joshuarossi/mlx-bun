import host.sim.compose.a4b.vw15.VWBodyJ8
import host.sim.compose.a4b.vw15.VWBodySite8
import host.sim.compose.a4b.vw15.VWBodyOracles_2
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift8 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S86.tab.length PRE_first_tail_x15_r0_body.s86.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P8.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P8 397 PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.s88.ffi PRE_first_tail_x15_r0_body.s87.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_8
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_8
  have hcl : SSt (· < 397) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s88.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S86.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_8] <;> decide) PRE_first_tail_x15_r0_body.cnodesK8 PRE_first_tail_x15_r0_body.cobjsK8
      PRE_first_tail_x15_r0_body.citemsK8 PRE_first_tail_x15_r0_body.cbd8 PRE_first_tail_x15_r0_body.csst8
  exact PRE_first_tail_x15_r0_body.cshift8 bodyNcl8 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_8] at this; exact this)


kernel_rfl bodyFramesEmpty8 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s87 a).isEmpty) = true
kernel_rfl bodyJsRoots8 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s86.next) PRE_first_tail_x15_r0_body.s88.trace PRE_first_tail_x15_r0_body.s88 = true
kernel_rfl bodyJsNative8 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s88.ffi) = true
kernel_rfl bodyLow8 : (PRE_first_tail_x15_r0_body.cws8 ++ PRE_first_tail_x15_r0_body.ws8).all (Nat.ble 9) = true
kernel_rfl bodyCntM8 : countersOkB PRE_first_tail_x15_r0_body.s86 PRE_first_tail_x15_r0_body.s87 = true
kernel_rfl bodyHi8 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s88.ffi).next setupP.E = true
kernel_rfl bodyNhi8 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s88.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge8 : bridgeOf PRE_first_tail_x15_r0_body.s87.ffi = bridgeOf PRE_first_tail_x15_r0_body.s86.ffi
kernel_rfl bodyNN8 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s86.ffi).nnext PRE_first_tail_x15_r0_body.P8.NL = true
kernel_rfl bodyXn8 : Nat.ble (⟨18353, 15448, 2680758, 397⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s88.ffi).next = true
kernel_rfl bodyLo8 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s88.ffi).next = true
theorem bodyFacts8 : BodySiteFacts PRE_first_tail_x15_r0_body.s86 PRE_first_tail_x15_r0_body.s87 PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S86 PRE_first_tail_x15_r0_body.S87 PRE_first_tail_x15_r0_body.S88
    PRE_first_tail_x15_r0_body.ws8 PRE_first_tail_x15_r0_body.cws8 PRE_first_tail_x15_r0_body.nr8 PRE_first_tail_x15_r0_body.pl8 PRE_first_tail_x15_r0_body.cl8 2680768 397 PRE_first_tail_x15_r0_body.kd8 PRE_first_tail_x15_r0_body.kappa8 PRE_first_tail_x15_r0_body.P8
    ⟨18353, 15448, 2680757, 397⟩ ⟨18353, 15448, 2680758, 397⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap8
  clean := bodyClean8
  cfix := PRE_first_tail_x15_r0_body.cfix8
  zpl := PRE_first_tail_x15_r0_body.zpl8
  zplnd := PRE_first_tail_x15_r0_body.zplnd8
  zn1 := PRE_first_tail_x15_r0_body.zn18
  zfirst := PRE_first_tail_x15_r0_body.zfirst8
  zscn := PRE_first_tail_x15_r0_body.zscn8
  zsmn := PRE_first_tail_x15_r0_body.zsmn8
  zgrow := PRE_first_tail_x15_r0_body.zgrow8
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab8
  zfresh := PRE_first_tail_x15_r0_body.zfresh8
  zcnd := PRE_first_tail_x15_r0_body.zcnd8
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi8
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt8
  zgP := PRE_first_tail_x15_r0_body.zg8_2665
  zkP := PRE_first_tail_x15_r0_body.zk8_2665
  zmP := PRE_first_tail_x15_r0_body.zm8_2665
  zgC := PRE_first_tail_x15_r0_body.zg8_2673467
  zkC := PRE_first_tail_x15_r0_body.zk8_2673467
  zmC := PRE_first_tail_x15_r0_body.zm8_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw8_2673472
  zwV := PRE_first_tail_x15_r0_body.zw8_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap8
  zclbd := PRE_first_tail_x15_r0_body.zclbd8
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap8 PRE_first_tail_x15_r0_body.stFoot8 PRE_first_tail_x15_r0_body.iso8 PRE_first_tail_x15_r0_body.zwr8
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP8
  csupp := PRE_first_tail_x15_r0_body.csupp8
  cbound := PRE_first_tail_x15_r0_body.cbound8
  zimg := PRE_first_tail_x15_r0_body.zimg8
  zctl := PRE_first_tail_x15_r0_body.zctl8
  zstack := PRE_first_tail_x15_r0_body.zstack8
  zjobs := PRE_first_tail_x15_r0_body.zjobs8
  zstores := PRE_first_tail_x15_r0_body.zstores8
  zroots := PRE_first_tail_x15_r0_body.zroots8
  znC := PRE_first_tail_x15_r0_body.znC8
  ctab := PRE_first_tail_x15_r0_body.ctab8
  zbin := PRE_first_tail_x15_r0_body.zbin8
  cbridge := PRE_first_tail_x15_r0_body.cbridge8
  sbridge := bodyBridge8
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj8
  cshiftR := fun h hNL => bodyCshift8 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN8
  raised := PRE_first_tail_x15_r0_body.raised8
  cbigs := PRE_first_tail_x15_r0_body.cbigs8
  cjcl := PRE_first_tail_x15_r0_body.cjcl8
  xnLe := Nat.le_of_ble_eq_true bodyXn8
  loLe := Nat.le_of_ble_eq_true bodyLo8
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB8
  cntM := bodyCntM8
  hiLe := Nat.le_of_ble_eq_true bodyHi8
  nhiLe := Nat.le_of_ble_eq_true bodyNhi8
  jsHeap := bodyJs8
  jsRoots := bodyJsRoots8
  jsNative := bodyJsNative8
  framesEmpty := bodyFramesEmpty8
  trailOld := by decide
  lowVars := bodyLow8

def bodyQs8 : List (Option Q) := []
noncomputable def bodyEs8 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr8.map fun r => nth? PRE_first_tail_x15_r0_body.st8.S2.tab r
kernel_rfl bodyResChk8 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs8 bodyQs8) = true
kernel_rfl bodyLq8 : bodyQs8.length = PRE_first_tail_x15_r0_body.cws8.length
kernel_rfl bodyNrLo8 : PRE_first_tail_x15_r0_body.nr8.all (Nat.ble PRE_first_tail_x15_r0_body.S86.tab.length) = true
kernel_rfl bodySub8 : (Oracles.PRE_first_tail_x15_r0_body.map_site8.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost8 : postSubB bodyM PRE_first_tail_x15_r0_body.ws8 PRE_first_tail_x15_r0_body.cws8 bodyQs8 = true
kernel_rfl bodyDrop8 : Nat.ble (7596 + (PRE_first_tail_x15_r0_body.s87.next - PRE_first_tail_x15_r0_body.s88.next)) 7606 = true
kernel_rfl bodyDropH8 : Nat.ble (96 + ((mlxOf PRE_first_tail_x15_r0_body.s87.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s88.ffi).next)) 96 = true
kernel_rfl bodyDropN8 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s87.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s88.ffi).nnext)) 0 = true
kernel_rfl bodyDv8 : bodyΘ.1.take 54 = bodyΘ.1.take 54 ++ PRE_first_tail_x15_r0_body.cws8
kernel_rfl bodyDe8 : bodyΘ.2.take 54 = bodyΘ.2.take 54 ++ PRE_first_tail_x15_r0_body.nr8.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st8.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 54) (bodyΘ.2.take 54)))
kernel_rfl bodyDl8 : (bodyΘ.1.take 54).length = (bodyΘ.2.take 54).length
kernel_rfl bodyDold8 : (bodyΘ.1.take 54).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws8).isNone && !PRE_first_tail_x15_r0_body.ws8.contains v) = true
kernel_rfl bodyDfree8 : (bodyΘ.2.take 54).all (fun e => (PRE_first_tail_x15_r0_body.cws8 ++ PRE_first_tail_x15_r0_body.ws8).all fun w => e.noVar w) = true

theorem bodyStep8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s86 PRE_first_tail_x15_r0_body.S86)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.S88) (98 + 1) :=
  bodySite bodyFacts8.cfix bodyFacts8.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st8.S2.tab) (Es := bodyEs8) (qs := bodyQs8)
    (ok := PRE_first_tail_x15_r0_body.st8.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site8 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts8
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site8 r hr) hi (MapOk.sub hm (sub_of_all bodySub8)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk8 r hr) hi hm ho hq)
    bodyLq8 rfl bodyNrLo8 (postSub_sound bodyPost8)
    (Nat.le_of_ble_eq_true bodyDrop8) (by decide) (Nat.le_of_ble_eq_true bodyDropH8) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN8) (by decide)
    bodyDv8 bodyDe8 bodyDl8 bodyDold8 bodyDfree8 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
