import host.sim.compose.a4b.vw15.VWBodyJ35
import host.sim.compose.a4b.vw15.VWBodySite35
import host.sim.compose.a4b.vw15.VWBodyOracles_8
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

theorem bodyCshift35 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S344.tab.length PRE_first_tail_x15_r0_body.s344.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P35.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P35 1549 PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.s346.ffi PRE_first_tail_x15_r0_body.s345.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_35
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_35
  have hcl : SSt (· < 1549) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S344.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_35] <;> decide) PRE_first_tail_x15_r0_body.cnodesK35 PRE_first_tail_x15_r0_body.cobjsK35
      PRE_first_tail_x15_r0_body.citemsK35 PRE_first_tail_x15_r0_body.cbd35 PRE_first_tail_x15_r0_body.csst35
  exact PRE_first_tail_x15_r0_body.cshift35 bodyNcl35 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_35] at this; exact this)


kernel_rfl bodyFramesEmpty35 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s345 a).isEmpty) = true
kernel_rfl bodyJsRoots35 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s344.next) PRE_first_tail_x15_r0_body.s346.trace PRE_first_tail_x15_r0_body.s346 = true
kernel_rfl bodyJsNative35 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s346.ffi) = true
kernel_rfl bodyLow35 : (PRE_first_tail_x15_r0_body.cws35 ++ PRE_first_tail_x15_r0_body.ws35).all (Nat.ble 9) = true
kernel_rfl bodyCntM35 : countersOkB PRE_first_tail_x15_r0_body.s344 PRE_first_tail_x15_r0_body.s345 = true
kernel_rfl bodyHi35 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s346.ffi).next setupP.E = true
kernel_rfl bodyNhi35 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s346.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge35 : bridgeOf PRE_first_tail_x15_r0_body.s345.ffi = bridgeOf PRE_first_tail_x15_r0_body.s344.ffi
kernel_rfl bodyNN35 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s344.ffi).nnext PRE_first_tail_x15_r0_body.P35.NL = true
kernel_rfl bodyXn35 : Nat.ble (⟨18889, 15970, 2702206, 1549⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s346.ffi).next = true
kernel_rfl bodyLo35 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s346.ffi).next = true
theorem bodyFacts35 : BodySiteFacts PRE_first_tail_x15_r0_body.s344 PRE_first_tail_x15_r0_body.s345 PRE_first_tail_x15_r0_body.s346 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S344 PRE_first_tail_x15_r0_body.S345 PRE_first_tail_x15_r0_body.S346
    PRE_first_tail_x15_r0_body.ws35 PRE_first_tail_x15_r0_body.cws35 PRE_first_tail_x15_r0_body.nr35 PRE_first_tail_x15_r0_body.pl35 PRE_first_tail_x15_r0_body.cl35 2702225 1549 PRE_first_tail_x15_r0_body.kd35 PRE_first_tail_x15_r0_body.kappa35 PRE_first_tail_x15_r0_body.P35
    ⟨18889, 15970, 2702205, 1549⟩ ⟨18889, 15970, 2702206, 1549⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap35
  clean := bodyClean35
  cfix := PRE_first_tail_x15_r0_body.cfix35
  zpl := PRE_first_tail_x15_r0_body.zpl35
  zplnd := PRE_first_tail_x15_r0_body.zplnd35
  zn1 := PRE_first_tail_x15_r0_body.zn135
  zfirst := PRE_first_tail_x15_r0_body.zfirst35
  zscn := PRE_first_tail_x15_r0_body.zscn35
  zsmn := PRE_first_tail_x15_r0_body.zsmn35
  zgrow := PRE_first_tail_x15_r0_body.zgrow35
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab35
  zfresh := PRE_first_tail_x15_r0_body.zfresh35
  zcnd := PRE_first_tail_x15_r0_body.zcnd35
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi35
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt35
  zgP := PRE_first_tail_x15_r0_body.zg35_2665
  zkP := PRE_first_tail_x15_r0_body.zk35_2665
  zmP := PRE_first_tail_x15_r0_body.zm35_2665
  zgC := PRE_first_tail_x15_r0_body.zg35_2673467
  zkC := PRE_first_tail_x15_r0_body.zk35_2673467
  zmC := PRE_first_tail_x15_r0_body.zm35_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw35_2673472
  zwV := PRE_first_tail_x15_r0_body.zw35_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap35
  zclbd := PRE_first_tail_x15_r0_body.zclbd35
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap35 PRE_first_tail_x15_r0_body.stFoot35 PRE_first_tail_x15_r0_body.iso35 PRE_first_tail_x15_r0_body.zwr35
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP35
  csupp := PRE_first_tail_x15_r0_body.csupp35
  cbound := PRE_first_tail_x15_r0_body.cbound35
  zimg := PRE_first_tail_x15_r0_body.zimg35
  zctl := PRE_first_tail_x15_r0_body.zctl35
  zstack := PRE_first_tail_x15_r0_body.zstack35
  zjobs := PRE_first_tail_x15_r0_body.zjobs35
  zstores := PRE_first_tail_x15_r0_body.zstores35
  zroots := PRE_first_tail_x15_r0_body.zroots35
  znC := PRE_first_tail_x15_r0_body.znC35
  ctab := PRE_first_tail_x15_r0_body.ctab35
  zbin := PRE_first_tail_x15_r0_body.zbin35
  cbridge := PRE_first_tail_x15_r0_body.cbridge35
  sbridge := bodyBridge35
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj35
  cshiftR := fun h hNL => bodyCshift35 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN35
  raised := PRE_first_tail_x15_r0_body.raised35
  cbigs := PRE_first_tail_x15_r0_body.cbigs35
  cjcl := PRE_first_tail_x15_r0_body.cjcl35
  xnLe := Nat.le_of_ble_eq_true bodyXn35
  loLe := Nat.le_of_ble_eq_true bodyLo35
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB35
  cntM := bodyCntM35
  hiLe := Nat.le_of_ble_eq_true bodyHi35
  nhiLe := Nat.le_of_ble_eq_true bodyNhi35
  jsHeap := bodyJs35
  jsRoots := bodyJsRoots35
  jsNative := bodyJsNative35
  framesEmpty := bodyFramesEmpty35
  trailOld := by decide
  lowVars := bodyLow35

def bodyQs35 : List (Option Q) := []
noncomputable def bodyEs35 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr35.map fun r => nth? PRE_first_tail_x15_r0_body.st35.S2.tab r
kernel_rfl bodyResChk35 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs35 bodyQs35) = true
kernel_rfl bodyLq35 : bodyQs35.length = PRE_first_tail_x15_r0_body.cws35.length
kernel_rfl bodyNrLo35 : PRE_first_tail_x15_r0_body.nr35.all (Nat.ble PRE_first_tail_x15_r0_body.S344.tab.length) = true
kernel_rfl bodySub35 : (Oracles.PRE_first_tail_x15_r0_body.map_site35.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost35 : postSubB bodyM PRE_first_tail_x15_r0_body.ws35 PRE_first_tail_x15_r0_body.cws35 bodyQs35 = true
kernel_rfl bodyDrop35 : Nat.ble (15648 + (PRE_first_tail_x15_r0_body.s345.next - PRE_first_tail_x15_r0_body.s346.next)) 15667 = true
kernel_rfl bodyDropH35 : Nat.ble (252 + ((mlxOf PRE_first_tail_x15_r0_body.s345.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s346.ffi).next)) 252 = true
kernel_rfl bodyDropN35 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s345.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s346.ffi).nnext)) 0 = true
kernel_rfl bodyDv35 : bodyΘ.1.take 189 = bodyΘ.1.take 189 ++ PRE_first_tail_x15_r0_body.cws35
kernel_rfl bodyDe35 : bodyΘ.2.take 189 = bodyΘ.2.take 189 ++ PRE_first_tail_x15_r0_body.nr35.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st35.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl35 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold35 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws35).isNone && !PRE_first_tail_x15_r0_body.ws35.contains v) = true
kernel_rfl bodyDfree35 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x15_r0_body.cws35 ++ PRE_first_tail_x15_r0_body.ws35).all fun w => e.noVar w) = true

theorem bodyStep35 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15648, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s344 PRE_first_tail_x15_r0_body.S344)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15667, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s346 PRE_first_tail_x15_r0_body.S346) (206 + 1) :=
  bodySite bodyFacts35.cfix bodyFacts35.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st35.S2.tab) (Es := bodyEs35) (qs := bodyQs35)
    (ok := PRE_first_tail_x15_r0_body.st35.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site35 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts35
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site35 r hr) hi (MapOk.sub hm (sub_of_all bodySub35)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk35 r hr) hi hm ho hq)
    bodyLq35 rfl bodyNrLo35 (postSub_sound bodyPost35)
    (Nat.le_of_ble_eq_true bodyDrop35) (by decide) (Nat.le_of_ble_eq_true bodyDropH35) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN35) (by decide)
    bodyDv35 bodyDe35 bodyDl35 bodyDold35 bodyDfree35 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
