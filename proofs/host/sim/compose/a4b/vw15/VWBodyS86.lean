import host.sim.compose.a4b.vw15.VWBodyJ86
import host.sim.compose.a4b.vw15.VWBodySite86
import host.sim.compose.a4b.vw15.VWBodyOracles_21
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift86 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S833.tab.length PRE_first_tail_x15_r0_body.s833.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P86.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P86 3730 PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.s835.ffi PRE_first_tail_x15_r0_body.s834.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_86
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_86
  have hcl : SSt (· < 3730) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s835.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S833.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_86] <;> decide) PRE_first_tail_x15_r0_body.cnodesK86 PRE_first_tail_x15_r0_body.cobjsK86
      PRE_first_tail_x15_r0_body.citemsK86 PRE_first_tail_x15_r0_body.cbd86 PRE_first_tail_x15_r0_body.csst86
  exact PRE_first_tail_x15_r0_body.cshift86 bodyNcl86 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_86] at this; exact this)


kernel_rfl bodyFramesEmpty86 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s834 a).isEmpty) = true
kernel_rfl bodyJsRoots86 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s833.next) PRE_first_tail_x15_r0_body.s835.trace PRE_first_tail_x15_r0_body.s835 = true
kernel_rfl bodyJsNative86 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s835.ffi) = true
kernel_rfl bodyLow86 : (PRE_first_tail_x15_r0_body.cws86 ++ PRE_first_tail_x15_r0_body.ws86).all (Nat.ble 9) = true
kernel_rfl bodyCntM86 : countersOkB PRE_first_tail_x15_r0_body.s833 PRE_first_tail_x15_r0_body.s834 = true
kernel_rfl bodyHi86 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s835.ffi).next setupP.E = true
kernel_rfl bodyNhi86 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s835.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge86 : bridgeOf PRE_first_tail_x15_r0_body.s834.ffi = bridgeOf PRE_first_tail_x15_r0_body.s833.ffi
kernel_rfl bodyNN86 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s833.ffi).nnext PRE_first_tail_x15_r0_body.P86.NL = true
kernel_rfl bodyXn86 : Nat.ble (⟨19891, 16981, 2742156, 3730⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s835.ffi).next = true
kernel_rfl bodyLo86 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s835.ffi).next = true
theorem bodyFacts86 : BodySiteFacts PRE_first_tail_x15_r0_body.s833 PRE_first_tail_x15_r0_body.s834 PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S833 PRE_first_tail_x15_r0_body.S834 PRE_first_tail_x15_r0_body.S835
    PRE_first_tail_x15_r0_body.ws86 PRE_first_tail_x15_r0_body.cws86 PRE_first_tail_x15_r0_body.nr86 PRE_first_tail_x15_r0_body.pl86 PRE_first_tail_x15_r0_body.cl86 2742166 3730 PRE_first_tail_x15_r0_body.kd86 PRE_first_tail_x15_r0_body.kappa86 PRE_first_tail_x15_r0_body.P86
    ⟨19891, 16981, 2742155, 3730⟩ ⟨19891, 16981, 2742156, 3730⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap86
  clean := bodyClean86
  cfix := PRE_first_tail_x15_r0_body.cfix86
  zpl := PRE_first_tail_x15_r0_body.zpl86
  zplnd := PRE_first_tail_x15_r0_body.zplnd86
  zn1 := PRE_first_tail_x15_r0_body.zn186
  zfirst := PRE_first_tail_x15_r0_body.zfirst86
  zscn := PRE_first_tail_x15_r0_body.zscn86
  zsmn := PRE_first_tail_x15_r0_body.zsmn86
  zgrow := PRE_first_tail_x15_r0_body.zgrow86
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab86
  zfresh := PRE_first_tail_x15_r0_body.zfresh86
  zcnd := PRE_first_tail_x15_r0_body.zcnd86
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi86
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt86
  zgP := PRE_first_tail_x15_r0_body.zg86_2665
  zkP := PRE_first_tail_x15_r0_body.zk86_2665
  zmP := PRE_first_tail_x15_r0_body.zm86_2665
  zgC := PRE_first_tail_x15_r0_body.zg86_2673467
  zkC := PRE_first_tail_x15_r0_body.zk86_2673467
  zmC := PRE_first_tail_x15_r0_body.zm86_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw86_2673472
  zwV := PRE_first_tail_x15_r0_body.zw86_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap86
  zclbd := PRE_first_tail_x15_r0_body.zclbd86
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap86 PRE_first_tail_x15_r0_body.stFoot86 PRE_first_tail_x15_r0_body.iso86 PRE_first_tail_x15_r0_body.zwr86
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP86
  csupp := PRE_first_tail_x15_r0_body.csupp86
  cbound := PRE_first_tail_x15_r0_body.cbound86
  zimg := PRE_first_tail_x15_r0_body.zimg86
  zctl := PRE_first_tail_x15_r0_body.zctl86
  zstack := PRE_first_tail_x15_r0_body.zstack86
  zjobs := PRE_first_tail_x15_r0_body.zjobs86
  zstores := PRE_first_tail_x15_r0_body.zstores86
  zroots := PRE_first_tail_x15_r0_body.zroots86
  znC := PRE_first_tail_x15_r0_body.znC86
  ctab := PRE_first_tail_x15_r0_body.ctab86
  zbin := PRE_first_tail_x15_r0_body.zbin86
  cbridge := PRE_first_tail_x15_r0_body.cbridge86
  sbridge := bodyBridge86
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj86
  cshiftR := fun h hNL => bodyCshift86 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN86
  raised := PRE_first_tail_x15_r0_body.raised86
  cbigs := PRE_first_tail_x15_r0_body.cbigs86
  cjcl := PRE_first_tail_x15_r0_body.cjcl86
  xnLe := Nat.le_of_ble_eq_true bodyXn86
  loLe := Nat.le_of_ble_eq_true bodyLo86
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB86
  cntM := bodyCntM86
  hiLe := Nat.le_of_ble_eq_true bodyHi86
  nhiLe := Nat.le_of_ble_eq_true bodyNhi86
  jsHeap := bodyJs86
  jsRoots := bodyJsRoots86
  jsNative := bodyJsNative86
  framesEmpty := bodyFramesEmpty86
  trailOld := by decide
  lowVars := bodyLow86

def bodyQs86 : List (Option Q) := []
noncomputable def bodyEs86 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr86.map fun r => nth? PRE_first_tail_x15_r0_body.st86.S2.tab r
kernel_rfl bodyResChk86 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs86 bodyQs86) = true
kernel_rfl bodyLq86 : bodyQs86.length = PRE_first_tail_x15_r0_body.cws86.length
kernel_rfl bodyNrLo86 : PRE_first_tail_x15_r0_body.nr86.all (Nat.ble PRE_first_tail_x15_r0_body.S833.tab.length) = true
kernel_rfl bodySub86 : (Oracles.PRE_first_tail_x15_r0_body.map_site86.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost86 : postSubB bodyM PRE_first_tail_x15_r0_body.ws86 PRE_first_tail_x15_r0_body.cws86 bodyQs86 = true
kernel_rfl bodyDrop86 : Nat.ble (32243 + (PRE_first_tail_x15_r0_body.s834.next - PRE_first_tail_x15_r0_body.s835.next)) 32253 = true
kernel_rfl bodyDropH86 : Nat.ble (585 + ((mlxOf PRE_first_tail_x15_r0_body.s834.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s835.ffi).next)) 585 = true
kernel_rfl bodyDropN86 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s834.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s835.ffi).nnext)) 0 = true
kernel_rfl bodyDv86 : bodyΘ.1.take 459 = bodyΘ.1.take 459 ++ PRE_first_tail_x15_r0_body.cws86
kernel_rfl bodyDe86 : bodyΘ.2.take 459 = bodyΘ.2.take 459 ++ PRE_first_tail_x15_r0_body.nr86.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st86.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 459) (bodyΘ.2.take 459)))
kernel_rfl bodyDl86 : (bodyΘ.1.take 459).length = (bodyΘ.2.take 459).length
kernel_rfl bodyDold86 : (bodyΘ.1.take 459).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws86).isNone && !PRE_first_tail_x15_r0_body.ws86.contains v) = true
kernel_rfl bodyDfree86 : (bodyΘ.2.take 459).all (fun e => (PRE_first_tail_x15_r0_body.cws86 ++ PRE_first_tail_x15_r0_body.ws86).all fun w => e.noVar w) = true

theorem bodyStep86 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32243, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s833 PRE_first_tail_x15_r0_body.S833)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32253, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s835 PRE_first_tail_x15_r0_body.S835) (98 + 1) :=
  bodySite bodyFacts86.cfix bodyFacts86.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st86.S2.tab) (Es := bodyEs86) (qs := bodyQs86)
    (ok := PRE_first_tail_x15_r0_body.st86.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site86 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts86
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site86 r hr) hi (MapOk.sub hm (sub_of_all bodySub86)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk86 r hr) hi hm ho hq)
    bodyLq86 rfl bodyNrLo86 (postSub_sound bodyPost86)
    (Nat.le_of_ble_eq_true bodyDrop86) (by decide) (Nat.le_of_ble_eq_true bodyDropH86) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN86) (by decide)
    bodyDv86 bodyDe86 bodyDl86 bodyDold86 bodyDfree86 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
