import host.sim.compose.a4b.vw15.VWBodyJ131
import host.sim.compose.a4b.vw15.VWBodySite131
import host.sim.compose.a4b.vw15.VWBodyOracles_32
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift131 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1264.tab.length PRE_first_tail_x15_r0_body.s1264.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P131.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P131 5653 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.s1266.ffi PRE_first_tail_x15_r0_body.s1265.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_131
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_131
  have hcl : SSt (· < 5653) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1266.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1264.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_131] <;> decide) PRE_first_tail_x15_r0_body.cnodesK131 PRE_first_tail_x15_r0_body.cobjsK131
      PRE_first_tail_x15_r0_body.citemsK131 PRE_first_tail_x15_r0_body.cbd131 PRE_first_tail_x15_r0_body.csst131
  exact PRE_first_tail_x15_r0_body.cshift131 bodyNcl131 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_131] at this; exact this)


kernel_rfl bodyFramesEmpty131 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1265 a).isEmpty) = true
kernel_rfl bodyJsRoots131 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1264.next) PRE_first_tail_x15_r0_body.s1266.trace PRE_first_tail_x15_r0_body.s1266 = true
kernel_rfl bodyJsNative131 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1266.ffi) = true
kernel_rfl bodyLow131 : (PRE_first_tail_x15_r0_body.cws131 ++ PRE_first_tail_x15_r0_body.ws131).all (Nat.ble 9) = true
kernel_rfl bodyCntM131 : countersOkB PRE_first_tail_x15_r0_body.s1264 PRE_first_tail_x15_r0_body.s1265 = true
kernel_rfl bodyHi131 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1266.ffi).next setupP.E = true
kernel_rfl bodyNhi131 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1266.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge131 : bridgeOf PRE_first_tail_x15_r0_body.s1265.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1264.ffi
kernel_rfl bodyNN131 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1264.ffi).nnext PRE_first_tail_x15_r0_body.P131.NL = true
kernel_rfl bodyXn131 : Nat.ble (⟨20777, 17866, 2777542, 5653⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1266.ffi).next = true
kernel_rfl bodyLo131 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1266.ffi).next = true
theorem bodyFacts131 : BodySiteFacts PRE_first_tail_x15_r0_body.s1264 PRE_first_tail_x15_r0_body.s1265 PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1264 PRE_first_tail_x15_r0_body.S1265 PRE_first_tail_x15_r0_body.S1266
    PRE_first_tail_x15_r0_body.ws131 PRE_first_tail_x15_r0_body.cws131 PRE_first_tail_x15_r0_body.nr131 PRE_first_tail_x15_r0_body.pl131 PRE_first_tail_x15_r0_body.cl131 2777552 5653 PRE_first_tail_x15_r0_body.kd131 PRE_first_tail_x15_r0_body.kappa131 PRE_first_tail_x15_r0_body.P131
    ⟨20777, 17866, 2777541, 5653⟩ ⟨20777, 17866, 2777542, 5653⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap131
  clean := bodyClean131
  cfix := PRE_first_tail_x15_r0_body.cfix131
  zpl := PRE_first_tail_x15_r0_body.zpl131
  zplnd := PRE_first_tail_x15_r0_body.zplnd131
  zn1 := PRE_first_tail_x15_r0_body.zn1131
  zfirst := PRE_first_tail_x15_r0_body.zfirst131
  zscn := PRE_first_tail_x15_r0_body.zscn131
  zsmn := PRE_first_tail_x15_r0_body.zsmn131
  zgrow := PRE_first_tail_x15_r0_body.zgrow131
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab131
  zfresh := PRE_first_tail_x15_r0_body.zfresh131
  zcnd := PRE_first_tail_x15_r0_body.zcnd131
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi131
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt131
  zgP := PRE_first_tail_x15_r0_body.zg131_2665
  zkP := PRE_first_tail_x15_r0_body.zk131_2665
  zmP := PRE_first_tail_x15_r0_body.zm131_2665
  zgC := PRE_first_tail_x15_r0_body.zg131_2673467
  zkC := PRE_first_tail_x15_r0_body.zk131_2673467
  zmC := PRE_first_tail_x15_r0_body.zm131_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw131_2673472
  zwV := PRE_first_tail_x15_r0_body.zw131_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap131
  zclbd := PRE_first_tail_x15_r0_body.zclbd131
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap131 PRE_first_tail_x15_r0_body.stFoot131 PRE_first_tail_x15_r0_body.iso131 PRE_first_tail_x15_r0_body.zwr131
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP131
  csupp := PRE_first_tail_x15_r0_body.csupp131
  cbound := PRE_first_tail_x15_r0_body.cbound131
  zimg := PRE_first_tail_x15_r0_body.zimg131
  zctl := PRE_first_tail_x15_r0_body.zctl131
  zstack := PRE_first_tail_x15_r0_body.zstack131
  zjobs := PRE_first_tail_x15_r0_body.zjobs131
  zstores := PRE_first_tail_x15_r0_body.zstores131
  zroots := PRE_first_tail_x15_r0_body.zroots131
  znC := PRE_first_tail_x15_r0_body.znC131
  ctab := PRE_first_tail_x15_r0_body.ctab131
  zbin := PRE_first_tail_x15_r0_body.zbin131
  cbridge := PRE_first_tail_x15_r0_body.cbridge131
  sbridge := bodyBridge131
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj131
  cshiftR := fun h hNL => bodyCshift131 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN131
  raised := PRE_first_tail_x15_r0_body.raised131
  cbigs := PRE_first_tail_x15_r0_body.cbigs131
  cjcl := PRE_first_tail_x15_r0_body.cjcl131
  xnLe := Nat.le_of_ble_eq_true bodyXn131
  loLe := Nat.le_of_ble_eq_true bodyLo131
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB131
  cntM := bodyCntM131
  hiLe := Nat.le_of_ble_eq_true bodyHi131
  nhiLe := Nat.le_of_ble_eq_true bodyNhi131
  jsHeap := bodyJs131
  jsRoots := bodyJsRoots131
  jsNative := bodyJsNative131
  framesEmpty := bodyFramesEmpty131
  trailOld := by decide
  lowVars := bodyLow131

def bodyQs131 : List (Option Q) := []
noncomputable def bodyEs131 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr131.map fun r => nth? PRE_first_tail_x15_r0_body.st131.S2.tab r
kernel_rfl bodyResChk131 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs131 bodyQs131) = true
kernel_rfl bodyLq131 : bodyQs131.length = PRE_first_tail_x15_r0_body.cws131.length
kernel_rfl bodyNrLo131 : PRE_first_tail_x15_r0_body.nr131.all (Nat.ble PRE_first_tail_x15_r0_body.S1264.tab.length) = true
kernel_rfl bodySub131 : (Oracles.PRE_first_tail_x15_r0_body.map_site131.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost131 : postSubB bodyM PRE_first_tail_x15_r0_body.ws131 PRE_first_tail_x15_r0_body.cws131 bodyQs131 = true
kernel_rfl bodyDrop131 : Nat.ble (46498 + (PRE_first_tail_x15_r0_body.s1265.next - PRE_first_tail_x15_r0_body.s1266.next)) 46508 = true
kernel_rfl bodyDropH131 : Nat.ble (868 + ((mlxOf PRE_first_tail_x15_r0_body.s1265.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1266.ffi).next)) 868 = true
kernel_rfl bodyDropN131 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1265.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1266.ffi).nnext)) 0 = true
kernel_rfl bodyDv131 : bodyΘ.1.take 693 = bodyΘ.1.take 693 ++ PRE_first_tail_x15_r0_body.cws131
kernel_rfl bodyDe131 : bodyΘ.2.take 693 = bodyΘ.2.take 693 ++ PRE_first_tail_x15_r0_body.nr131.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st131.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 693) (bodyΘ.2.take 693)))
kernel_rfl bodyDl131 : (bodyΘ.1.take 693).length = (bodyΘ.2.take 693).length
kernel_rfl bodyDold131 : (bodyΘ.1.take 693).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws131).isNone && !PRE_first_tail_x15_r0_body.ws131.contains v) = true
kernel_rfl bodyDfree131 : (bodyΘ.2.take 693).all (fun e => (PRE_first_tail_x15_r0_body.cws131 ++ PRE_first_tail_x15_r0_body.ws131).all fun w => e.noVar w) = true

theorem bodyStep131 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46498, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1264 PRE_first_tail_x15_r0_body.S1264)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46508, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.S1266) (98 + 1) :=
  bodySite bodyFacts131.cfix bodyFacts131.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st131.S2.tab) (Es := bodyEs131) (qs := bodyQs131)
    (ok := PRE_first_tail_x15_r0_body.st131.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site131 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts131
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site131 r hr) hi (MapOk.sub hm (sub_of_all bodySub131)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk131 r hr) hi hm ho hq)
    bodyLq131 rfl bodyNrLo131 (postSub_sound bodyPost131)
    (Nat.le_of_ble_eq_true bodyDrop131) (by decide) (Nat.le_of_ble_eq_true bodyDropH131) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN131) (by decide)
    bodyDv131 bodyDe131 bodyDl131 bodyDold131 bodyDfree131 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
