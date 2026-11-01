import host.sim.compose.a4b.vw15.VWBodyJ132
import host.sim.compose.a4b.vw15.VWBodySite132
import host.sim.compose.a4b.vw15.VWBodyOracles_33
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift132 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1281.tab.length PRE_first_tail_x15_r0_body.s1281.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P132.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.s1283.ffi PRE_first_tail_x15_r0_body.s1282.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_132
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_132
  have hcl : SSt (· < 5744) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1281.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_132] <;> decide) PRE_first_tail_x15_r0_body.cnodesK132 PRE_first_tail_x15_r0_body.cobjsK132
      PRE_first_tail_x15_r0_body.citemsK132 PRE_first_tail_x15_r0_body.cbd132 PRE_first_tail_x15_r0_body.csst132
  exact PRE_first_tail_x15_r0_body.cshift132 bodyNcl132 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_132] at this; exact this)


kernel_rfl bodyFramesEmpty132 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1282 a).isEmpty) = true
kernel_rfl bodyJsRoots132 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1281.next) PRE_first_tail_x15_r0_body.s1283.trace PRE_first_tail_x15_r0_body.s1283 = true
kernel_rfl bodyJsNative132 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1283.ffi) = true
kernel_rfl bodyLow132 : (PRE_first_tail_x15_r0_body.cws132 ++ PRE_first_tail_x15_r0_body.ws132).all (Nat.ble 9) = true
kernel_rfl bodyCntM132 : countersOkB PRE_first_tail_x15_r0_body.s1281 PRE_first_tail_x15_r0_body.s1282 = true
kernel_rfl bodyHi132 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1283.ffi).next setupP.E = true
kernel_rfl bodyNhi132 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1283.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge132 : bridgeOf PRE_first_tail_x15_r0_body.s1282.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1281.ffi
kernel_rfl bodyNN132 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1281.ffi).nnext PRE_first_tail_x15_r0_body.P132.NL = true
kernel_rfl bodyXn132 : Nat.ble (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1283.ffi).next = true
kernel_rfl bodyLo132 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1283.ffi).next = true
theorem bodyFacts132 : BodySiteFacts PRE_first_tail_x15_r0_body.s1281 PRE_first_tail_x15_r0_body.s1282 PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1281 PRE_first_tail_x15_r0_body.S1282 PRE_first_tail_x15_r0_body.S1283
    PRE_first_tail_x15_r0_body.ws132 PRE_first_tail_x15_r0_body.cws132 PRE_first_tail_x15_r0_body.nr132 PRE_first_tail_x15_r0_body.pl132 PRE_first_tail_x15_r0_body.cl132 2780190 5744 PRE_first_tail_x15_r0_body.kd132 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.P132
    ⟨20812, 17885, 2779035, 5726⟩ ⟨20815, 17912, 2779041, 5744⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap132
  clean := bodyClean132
  cfix := PRE_first_tail_x15_r0_body.cfix132
  zpl := PRE_first_tail_x15_r0_body.zpl132
  zplnd := PRE_first_tail_x15_r0_body.zplnd132
  zn1 := PRE_first_tail_x15_r0_body.zn1132
  zfirst := PRE_first_tail_x15_r0_body.zfirst132
  zscn := PRE_first_tail_x15_r0_body.zscn132
  zsmn := PRE_first_tail_x15_r0_body.zsmn132
  zgrow := PRE_first_tail_x15_r0_body.zgrow132
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab132
  zfresh := PRE_first_tail_x15_r0_body.zfresh132
  zcnd := PRE_first_tail_x15_r0_body.zcnd132
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi132
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt132
  zgP := PRE_first_tail_x15_r0_body.zg132_2665
  zkP := PRE_first_tail_x15_r0_body.zk132_2665
  zmP := PRE_first_tail_x15_r0_body.zm132_2665
  zgC := PRE_first_tail_x15_r0_body.zg132_2673467
  zkC := PRE_first_tail_x15_r0_body.zk132_2673467
  zmC := PRE_first_tail_x15_r0_body.zm132_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw132_2673472
  zwV := PRE_first_tail_x15_r0_body.zw132_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap132
  zclbd := PRE_first_tail_x15_r0_body.zclbd132
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap132 PRE_first_tail_x15_r0_body.stFoot132 PRE_first_tail_x15_r0_body.iso132 PRE_first_tail_x15_r0_body.zwr132
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP132
  csupp := PRE_first_tail_x15_r0_body.csupp132
  cbound := PRE_first_tail_x15_r0_body.cbound132
  zimg := PRE_first_tail_x15_r0_body.zimg132
  zctl := PRE_first_tail_x15_r0_body.zctl132
  zstack := PRE_first_tail_x15_r0_body.zstack132
  zjobs := PRE_first_tail_x15_r0_body.zjobs132
  zstores := PRE_first_tail_x15_r0_body.zstores132
  zroots := PRE_first_tail_x15_r0_body.zroots132
  znC := PRE_first_tail_x15_r0_body.znC132
  ctab := PRE_first_tail_x15_r0_body.ctab132
  zbin := PRE_first_tail_x15_r0_body.zbin132
  cbridge := PRE_first_tail_x15_r0_body.cbridge132
  sbridge := bodyBridge132
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj132
  cshiftR := fun h hNL => bodyCshift132 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN132
  raised := PRE_first_tail_x15_r0_body.raised132
  cbigs := PRE_first_tail_x15_r0_body.cbigs132
  cjcl := PRE_first_tail_x15_r0_body.cjcl132
  xnLe := Nat.le_of_ble_eq_true bodyXn132
  loLe := Nat.le_of_ble_eq_true bodyLo132
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB132
  cntM := bodyCntM132
  hiLe := Nat.le_of_ble_eq_true bodyHi132
  nhiLe := Nat.le_of_ble_eq_true bodyNhi132
  jsHeap := bodyJs132
  jsRoots := bodyJsRoots132
  jsNative := bodyJsNative132
  framesEmpty := bodyFramesEmpty132
  trailOld := by decide
  lowVars := bodyLow132

def bodyQs132 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs132 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr132.map fun r => nth? PRE_first_tail_x15_r0_body.st132.S5.tab r
kernel_rfl bodyResChk132 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs132 bodyQs132) = true
kernel_rfl bodyLq132 : bodyQs132.length = PRE_first_tail_x15_r0_body.cws132.length
kernel_rfl bodyNrLo132 : PRE_first_tail_x15_r0_body.nr132.all (Nat.ble PRE_first_tail_x15_r0_body.S1281.tab.length) = true
kernel_rfl bodySub132 : (Oracles.PRE_first_tail_x15_r0_body.map_site132.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost132 : postSubB bodyM PRE_first_tail_x15_r0_body.ws132 PRE_first_tail_x15_r0_body.cws132 bodyQs132 = true
kernel_rfl bodyDrop132 : Nat.ble (46508 + (PRE_first_tail_x15_r0_body.s1282.next - PRE_first_tail_x15_r0_body.s1283.next)) 47657 = true
kernel_rfl bodyDropH132 : Nat.ble (868 + ((mlxOf PRE_first_tail_x15_r0_body.s1282.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1283.ffi).next)) 893 = true
kernel_rfl bodyDropN132 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1282.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1283.ffi).nnext)) 0 = true
kernel_rfl bodyDv132 : bodyΘ.1.take 711 = bodyΘ.1.take 693 ++ PRE_first_tail_x15_r0_body.cws132
kernel_rfl bodyDe132 : bodyΘ.2.take 711 = bodyΘ.2.take 693 ++ PRE_first_tail_x15_r0_body.nr132.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st132.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 693) (bodyΘ.2.take 693)))
kernel_rfl bodyDl132 : (bodyΘ.1.take 693).length = (bodyΘ.2.take 693).length
kernel_rfl bodyDold132 : (bodyΘ.1.take 693).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws132).isNone && !PRE_first_tail_x15_r0_body.ws132.contains v) = true
kernel_rfl bodyDfree132 : (bodyΘ.2.take 711).all (fun e => (PRE_first_tail_x15_r0_body.cws132 ++ PRE_first_tail_x15_r0_body.ws132).all fun w => e.noVar w) = true

theorem bodyStep132 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46508, 868, 0, 693⟩ bodyM PRE_first_tail_x15_r0_body.s1281 PRE_first_tail_x15_r0_body.S1281)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47657, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.S1283) (11334 + 1) :=
  bodySite bodyFacts132.cfix bodyFacts132.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st132.S5.tab) (Es := bodyEs132) (qs := bodyQs132)
    (ok := PRE_first_tail_x15_r0_body.st132.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site132 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts132
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site132 r hr) hi (MapOk.sub hm (sub_of_all bodySub132)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk132 r hr) hi hm ho hq)
    bodyLq132 rfl bodyNrLo132 (postSub_sound bodyPost132)
    (Nat.le_of_ble_eq_true bodyDrop132) (by decide) (Nat.le_of_ble_eq_true bodyDropH132) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN132) (by decide)
    bodyDv132 bodyDe132 bodyDl132 bodyDold132 bodyDfree132 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
