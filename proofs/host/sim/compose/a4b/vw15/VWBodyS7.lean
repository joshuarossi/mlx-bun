import host.sim.compose.a4b.vw15.VWBodyJ7
import host.sim.compose.a4b.vw15.VWBodySite7
import host.sim.compose.a4b.vw15.VWBodyOracles_1
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

theorem bodyCshift7 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S82.tab.length PRE_first_tail_x15_r0_body.s82.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P7.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P7 380 PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.s84.ffi PRE_first_tail_x15_r0_body.s83.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_7
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_7
  have hcl : SSt (· < 380) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s84.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S82.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_7] <;> decide) PRE_first_tail_x15_r0_body.cnodesK7 PRE_first_tail_x15_r0_body.cobjsK7
      PRE_first_tail_x15_r0_body.citemsK7 PRE_first_tail_x15_r0_body.cbd7 PRE_first_tail_x15_r0_body.csst7
  exact PRE_first_tail_x15_r0_body.cshift7 bodyNcl7 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_7] at this; exact this)


kernel_rfl bodyFramesEmpty7 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s83 a).isEmpty) = true
kernel_rfl bodyJsRoots7 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s82.next) PRE_first_tail_x15_r0_body.s84.trace PRE_first_tail_x15_r0_body.s84 = true
kernel_rfl bodyJsNative7 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s84.ffi) = true
kernel_rfl bodyLow7 : (PRE_first_tail_x15_r0_body.cws7 ++ PRE_first_tail_x15_r0_body.ws7).all (Nat.ble 9) = true
kernel_rfl bodyCntM7 : countersOkB PRE_first_tail_x15_r0_body.s82 PRE_first_tail_x15_r0_body.s83 = true
kernel_rfl bodyHi7 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s84.ffi).next setupP.E = true
kernel_rfl bodyNhi7 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s84.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge7 : bridgeOf PRE_first_tail_x15_r0_body.s83.ffi = bridgeOf PRE_first_tail_x15_r0_body.s82.ffi
kernel_rfl bodyNN7 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s82.ffi).nnext PRE_first_tail_x15_r0_body.P7.NL = true
kernel_rfl bodyXn7 : Nat.ble (⟨18346, 15444, 2680469, 380⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s84.ffi).next = true
kernel_rfl bodyLo7 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s84.ffi).next = true
theorem bodyFacts7 : BodySiteFacts PRE_first_tail_x15_r0_body.s82 PRE_first_tail_x15_r0_body.s83 PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S82 PRE_first_tail_x15_r0_body.S83 PRE_first_tail_x15_r0_body.S84
    PRE_first_tail_x15_r0_body.ws7 PRE_first_tail_x15_r0_body.cws7 PRE_first_tail_x15_r0_body.nr7 PRE_first_tail_x15_r0_body.pl7 PRE_first_tail_x15_r0_body.cl7 2680471 380 PRE_first_tail_x15_r0_body.kd7 PRE_first_tail_x15_r0_body.kappa7 PRE_first_tail_x15_r0_body.P7
    ⟨18346, 15444, 2680469, 380⟩ ⟨18346, 15444, 2680469, 380⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap7
  clean := bodyClean7
  cfix := PRE_first_tail_x15_r0_body.cfix7
  zpl := PRE_first_tail_x15_r0_body.zpl7
  zplnd := PRE_first_tail_x15_r0_body.zplnd7
  zn1 := PRE_first_tail_x15_r0_body.zn17
  zfirst := PRE_first_tail_x15_r0_body.zfirst7
  zscn := PRE_first_tail_x15_r0_body.zscn7
  zsmn := PRE_first_tail_x15_r0_body.zsmn7
  zgrow := PRE_first_tail_x15_r0_body.zgrow7
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab7
  zfresh := PRE_first_tail_x15_r0_body.zfresh7
  zcnd := PRE_first_tail_x15_r0_body.zcnd7
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi7
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt7
  zgP := PRE_first_tail_x15_r0_body.zg7_2665
  zkP := PRE_first_tail_x15_r0_body.zk7_2665
  zmP := PRE_first_tail_x15_r0_body.zm7_2665
  zgC := PRE_first_tail_x15_r0_body.zg7_2673467
  zkC := PRE_first_tail_x15_r0_body.zk7_2673467
  zmC := PRE_first_tail_x15_r0_body.zm7_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw7_2673472
  zwV := PRE_first_tail_x15_r0_body.zw7_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap7
  zclbd := PRE_first_tail_x15_r0_body.zclbd7
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap7 PRE_first_tail_x15_r0_body.stFoot7 PRE_first_tail_x15_r0_body.iso7 PRE_first_tail_x15_r0_body.zwr7
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP7
  csupp := PRE_first_tail_x15_r0_body.csupp7
  cbound := PRE_first_tail_x15_r0_body.cbound7
  zimg := PRE_first_tail_x15_r0_body.zimg7
  zctl := PRE_first_tail_x15_r0_body.zctl7
  zstack := PRE_first_tail_x15_r0_body.zstack7
  zjobs := PRE_first_tail_x15_r0_body.zjobs7
  zstores := PRE_first_tail_x15_r0_body.zstores7
  zroots := PRE_first_tail_x15_r0_body.zroots7
  znC := PRE_first_tail_x15_r0_body.znC7
  ctab := PRE_first_tail_x15_r0_body.ctab7
  zbin := PRE_first_tail_x15_r0_body.zbin7
  cbridge := PRE_first_tail_x15_r0_body.cbridge7
  sbridge := bodyBridge7
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj7
  cshiftR := fun h hNL => bodyCshift7 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN7
  raised := PRE_first_tail_x15_r0_body.raised7
  cbigs := PRE_first_tail_x15_r0_body.cbigs7
  cjcl := PRE_first_tail_x15_r0_body.cjcl7
  xnLe := Nat.le_of_ble_eq_true bodyXn7
  loLe := Nat.le_of_ble_eq_true bodyLo7
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB7
  cntM := bodyCntM7
  hiLe := Nat.le_of_ble_eq_true bodyHi7
  nhiLe := Nat.le_of_ble_eq_true bodyNhi7
  jsHeap := bodyJs7
  jsRoots := bodyJsRoots7
  jsNative := bodyJsNative7
  framesEmpty := bodyFramesEmpty7
  trailOld := by decide
  lowVars := bodyLow7

def bodyQs7 : List (Option Q) := []
noncomputable def bodyEs7 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr7.map fun r => nth? PRE_first_tail_x15_r0_body.st7.S2.tab r
kernel_rfl bodyResChk7 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs7 bodyQs7) = true
kernel_rfl bodyLq7 : bodyQs7.length = PRE_first_tail_x15_r0_body.cws7.length
kernel_rfl bodyNrLo7 : PRE_first_tail_x15_r0_body.nr7.all (Nat.ble PRE_first_tail_x15_r0_body.S82.tab.length) = true
kernel_rfl bodySub7 : (Oracles.PRE_first_tail_x15_r0_body.map_site7.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost7 : postSubB bodyM PRE_first_tail_x15_r0_body.ws7 PRE_first_tail_x15_r0_body.cws7 bodyQs7 = true
kernel_rfl bodyDrop7 : Nat.ble (7594 + (PRE_first_tail_x15_r0_body.s83.next - PRE_first_tail_x15_r0_body.s84.next)) 7596 = true
kernel_rfl bodyDropH7 : Nat.ble (96 + ((mlxOf PRE_first_tail_x15_r0_body.s83.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s84.ffi).next)) 96 = true
kernel_rfl bodyDropN7 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s83.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s84.ffi).nnext)) 0 = true
kernel_rfl bodyDv7 : bodyΘ.1.take 54 = bodyΘ.1.take 54 ++ PRE_first_tail_x15_r0_body.cws7
kernel_rfl bodyDe7 : bodyΘ.2.take 54 = bodyΘ.2.take 54 ++ PRE_first_tail_x15_r0_body.nr7.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st7.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 54) (bodyΘ.2.take 54)))
kernel_rfl bodyDl7 : (bodyΘ.1.take 54).length = (bodyΘ.2.take 54).length
kernel_rfl bodyDold7 : (bodyΘ.1.take 54).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws7).isNone && !PRE_first_tail_x15_r0_body.ws7.contains v) = true
kernel_rfl bodyDfree7 : (bodyΘ.2.take 54).all (fun e => (PRE_first_tail_x15_r0_body.cws7 ++ PRE_first_tail_x15_r0_body.ws7).all fun w => e.noVar w) = true

theorem bodyStep7 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7594, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s82 PRE_first_tail_x15_r0_body.S82)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.S84) (27 + 1) :=
  bodySite bodyFacts7.cfix bodyFacts7.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st7.S2.tab) (Es := bodyEs7) (qs := bodyQs7)
    (ok := PRE_first_tail_x15_r0_body.st7.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site7 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts7
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site7 r hr) hi (MapOk.sub hm (sub_of_all bodySub7)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk7 r hr) hi hm ho hq)
    bodyLq7 rfl bodyNrLo7 (postSub_sound bodyPost7)
    (Nat.le_of_ble_eq_true bodyDrop7) (by decide) (Nat.le_of_ble_eq_true bodyDropH7) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN7) (by decide)
    bodyDv7 bodyDe7 bodyDl7 bodyDold7 bodyDfree7 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
