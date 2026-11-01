import host.sim.compose.a4b.vw15.VWBodyJ170
import host.sim.compose.a4b.vw15.VWBodySite170
import host.sim.compose.a4b.vw15.VWBodyOracles_42
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift170 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1638.tab.length PRE_first_tail_x15_r0_body.s1638.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P170.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P170 7321 PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.s1640.ffi PRE_first_tail_x15_r0_body.s1639.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_170
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_170
  have hcl : SSt (· < 7321) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1640.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1638.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_170] <;> decide) PRE_first_tail_x15_r0_body.cnodesK170 PRE_first_tail_x15_r0_body.cobjsK170
      PRE_first_tail_x15_r0_body.citemsK170 PRE_first_tail_x15_r0_body.cbd170 PRE_first_tail_x15_r0_body.csst170
  exact PRE_first_tail_x15_r0_body.cshift170 bodyNcl170 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_170] at this; exact this)


kernel_rfl bodyFramesEmpty170 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1639 a).isEmpty) = true
kernel_rfl bodyJsRoots170 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1638.next) PRE_first_tail_x15_r0_body.s1640.trace PRE_first_tail_x15_r0_body.s1640 = true
kernel_rfl bodyJsNative170 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1640.ffi) = true
kernel_rfl bodyLow170 : (PRE_first_tail_x15_r0_body.cws170 ++ PRE_first_tail_x15_r0_body.ws170).all (Nat.ble 9) = true
kernel_rfl bodyCntM170 : countersOkB PRE_first_tail_x15_r0_body.s1638 PRE_first_tail_x15_r0_body.s1639 = true
kernel_rfl bodyHi170 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1640.ffi).next setupP.E = true
kernel_rfl bodyNhi170 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1640.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge170 : bridgeOf PRE_first_tail_x15_r0_body.s1639.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1638.ffi
kernel_rfl bodyNN170 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1638.ffi).nnext PRE_first_tail_x15_r0_body.P170.NL = true
kernel_rfl bodyXn170 : Nat.ble (⟨21543, 18640, 2808084, 7321⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1640.ffi).next = true
kernel_rfl bodyLo170 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1640.ffi).next = true
theorem bodyFacts170 : BodySiteFacts PRE_first_tail_x15_r0_body.s1638 PRE_first_tail_x15_r0_body.s1639 PRE_first_tail_x15_r0_body.s1640 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1638 PRE_first_tail_x15_r0_body.S1639 PRE_first_tail_x15_r0_body.S1640
    PRE_first_tail_x15_r0_body.ws170 PRE_first_tail_x15_r0_body.cws170 PRE_first_tail_x15_r0_body.nr170 PRE_first_tail_x15_r0_body.pl170 PRE_first_tail_x15_r0_body.cl170 2808103 7321 PRE_first_tail_x15_r0_body.kd170 PRE_first_tail_x15_r0_body.kappa170 PRE_first_tail_x15_r0_body.P170
    ⟨21543, 18640, 2808083, 7321⟩ ⟨21543, 18640, 2808084, 7321⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap170
  clean := bodyClean170
  cfix := PRE_first_tail_x15_r0_body.cfix170
  zpl := PRE_first_tail_x15_r0_body.zpl170
  zplnd := PRE_first_tail_x15_r0_body.zplnd170
  zn1 := PRE_first_tail_x15_r0_body.zn1170
  zfirst := PRE_first_tail_x15_r0_body.zfirst170
  zscn := PRE_first_tail_x15_r0_body.zscn170
  zsmn := PRE_first_tail_x15_r0_body.zsmn170
  zgrow := PRE_first_tail_x15_r0_body.zgrow170
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab170
  zfresh := PRE_first_tail_x15_r0_body.zfresh170
  zcnd := PRE_first_tail_x15_r0_body.zcnd170
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi170
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt170
  zgP := PRE_first_tail_x15_r0_body.zg170_2665
  zkP := PRE_first_tail_x15_r0_body.zk170_2665
  zmP := PRE_first_tail_x15_r0_body.zm170_2665
  zgC := PRE_first_tail_x15_r0_body.zg170_2673467
  zkC := PRE_first_tail_x15_r0_body.zk170_2673467
  zmC := PRE_first_tail_x15_r0_body.zm170_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw170_2673472
  zwV := PRE_first_tail_x15_r0_body.zw170_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap170
  zclbd := PRE_first_tail_x15_r0_body.zclbd170
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap170 PRE_first_tail_x15_r0_body.stFoot170 PRE_first_tail_x15_r0_body.iso170 PRE_first_tail_x15_r0_body.zwr170
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP170
  csupp := PRE_first_tail_x15_r0_body.csupp170
  cbound := PRE_first_tail_x15_r0_body.cbound170
  zimg := PRE_first_tail_x15_r0_body.zimg170
  zctl := PRE_first_tail_x15_r0_body.zctl170
  zstack := PRE_first_tail_x15_r0_body.zstack170
  zjobs := PRE_first_tail_x15_r0_body.zjobs170
  zstores := PRE_first_tail_x15_r0_body.zstores170
  zroots := PRE_first_tail_x15_r0_body.zroots170
  znC := PRE_first_tail_x15_r0_body.znC170
  ctab := PRE_first_tail_x15_r0_body.ctab170
  zbin := PRE_first_tail_x15_r0_body.zbin170
  cbridge := PRE_first_tail_x15_r0_body.cbridge170
  sbridge := bodyBridge170
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj170
  cshiftR := fun h hNL => bodyCshift170 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN170
  raised := PRE_first_tail_x15_r0_body.raised170
  cbigs := PRE_first_tail_x15_r0_body.cbigs170
  cjcl := PRE_first_tail_x15_r0_body.cjcl170
  xnLe := Nat.le_of_ble_eq_true bodyXn170
  loLe := Nat.le_of_ble_eq_true bodyLo170
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB170
  cntM := bodyCntM170
  hiLe := Nat.le_of_ble_eq_true bodyHi170
  nhiLe := Nat.le_of_ble_eq_true bodyNhi170
  jsHeap := bodyJs170
  jsRoots := bodyJsRoots170
  jsNative := bodyJsNative170
  framesEmpty := bodyFramesEmpty170
  trailOld := by decide
  lowVars := bodyLow170

def bodyQs170 : List (Option Q) := []
noncomputable def bodyEs170 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr170.map fun r => nth? PRE_first_tail_x15_r0_body.st170.S2.tab r
kernel_rfl bodyResChk170 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs170 bodyQs170) = true
kernel_rfl bodyLq170 : bodyQs170.length = PRE_first_tail_x15_r0_body.cws170.length
kernel_rfl bodyNrLo170 : PRE_first_tail_x15_r0_body.nr170.all (Nat.ble PRE_first_tail_x15_r0_body.S1638.tab.length) = true
kernel_rfl bodySub170 : (Oracles.PRE_first_tail_x15_r0_body.map_site170.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost170 : postSubB bodyM PRE_first_tail_x15_r0_body.ws170 PRE_first_tail_x15_r0_body.cws170 bodyQs170 = true
kernel_rfl bodyDrop170 : Nat.ble (59257 + (PRE_first_tail_x15_r0_body.s1639.next - PRE_first_tail_x15_r0_body.s1640.next)) 59276 = true
kernel_rfl bodyDropH170 : Nat.ble (1124 + ((mlxOf PRE_first_tail_x15_r0_body.s1639.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1640.ffi).next)) 1124 = true
kernel_rfl bodyDropN170 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1639.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1640.ffi).nnext)) 0 = true
kernel_rfl bodyDv170 : bodyΘ.1.take 900 = bodyΘ.1.take 900 ++ PRE_first_tail_x15_r0_body.cws170
kernel_rfl bodyDe170 : bodyΘ.2.take 900 = bodyΘ.2.take 900 ++ PRE_first_tail_x15_r0_body.nr170.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st170.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 900) (bodyΘ.2.take 900)))
kernel_rfl bodyDl170 : (bodyΘ.1.take 900).length = (bodyΘ.2.take 900).length
kernel_rfl bodyDold170 : (bodyΘ.1.take 900).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws170).isNone && !PRE_first_tail_x15_r0_body.ws170.contains v) = true
kernel_rfl bodyDfree170 : (bodyΘ.2.take 900).all (fun e => (PRE_first_tail_x15_r0_body.cws170 ++ PRE_first_tail_x15_r0_body.ws170).all fun w => e.noVar w) = true

theorem bodyStep170 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59257, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1638 PRE_first_tail_x15_r0_body.S1638)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59276, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1640 PRE_first_tail_x15_r0_body.S1640) (206 + 1) :=
  bodySite bodyFacts170.cfix bodyFacts170.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st170.S2.tab) (Es := bodyEs170) (qs := bodyQs170)
    (ok := PRE_first_tail_x15_r0_body.st170.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site170 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts170
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site170 r hr) hi (MapOk.sub hm (sub_of_all bodySub170)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk170 r hr) hi hm ho hq)
    bodyLq170 rfl bodyNrLo170 (postSub_sound bodyPost170)
    (Nat.le_of_ble_eq_true bodyDrop170) (by decide) (Nat.le_of_ble_eq_true bodyDropH170) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN170) (by decide)
    bodyDv170 bodyDe170 bodyDl170 bodyDold170 bodyDfree170 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
