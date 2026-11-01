import host.sim.compose.a4b.vw15.VWBodyJ63
import host.sim.compose.a4b.vw15.VWBodySite63
import host.sim.compose.a4b.vw15.VWBodyOracles_15
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift63 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S620.tab.length PRE_first_tail_x15_r0_body.s620.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P63.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P63 2795 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.s622.ffi PRE_first_tail_x15_r0_body.s621.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_63
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_63
  have hcl : SSt (· < 2795) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s622.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S620.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_63] <;> decide) PRE_first_tail_x15_r0_body.cnodesK63 PRE_first_tail_x15_r0_body.cobjsK63
      PRE_first_tail_x15_r0_body.citemsK63 PRE_first_tail_x15_r0_body.cbd63 PRE_first_tail_x15_r0_body.csst63
  exact PRE_first_tail_x15_r0_body.cshift63 bodyNcl63 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_63] at this; exact this)


kernel_rfl bodyFramesEmpty63 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s621 a).isEmpty) = true
kernel_rfl bodyJsRoots63 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s620.next) PRE_first_tail_x15_r0_body.s622.trace PRE_first_tail_x15_r0_body.s622 = true
kernel_rfl bodyJsNative63 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s622.ffi) = true
kernel_rfl bodyLow63 : (PRE_first_tail_x15_r0_body.cws63 ++ PRE_first_tail_x15_r0_body.ws63).all (Nat.ble 9) = true
kernel_rfl bodyCntM63 : countersOkB PRE_first_tail_x15_r0_body.s620 PRE_first_tail_x15_r0_body.s621 = true
kernel_rfl bodyHi63 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s622.ffi).next setupP.E = true
kernel_rfl bodyNhi63 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s622.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge63 : bridgeOf PRE_first_tail_x15_r0_body.s621.ffi = bridgeOf PRE_first_tail_x15_r0_body.s620.ffi
kernel_rfl bodyNN63 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s620.ffi).nnext PRE_first_tail_x15_r0_body.P63.NL = true
kernel_rfl bodyXn63 : Nat.ble (⟨19456, 16553, 2724809, 2795⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s622.ffi).next = true
kernel_rfl bodyLo63 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s622.ffi).next = true
theorem bodyFacts63 : BodySiteFacts PRE_first_tail_x15_r0_body.s620 PRE_first_tail_x15_r0_body.s621 PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S620 PRE_first_tail_x15_r0_body.S621 PRE_first_tail_x15_r0_body.S622
    PRE_first_tail_x15_r0_body.ws63 PRE_first_tail_x15_r0_body.cws63 PRE_first_tail_x15_r0_body.nr63 PRE_first_tail_x15_r0_body.pl63 PRE_first_tail_x15_r0_body.cl63 2725958 2795 PRE_first_tail_x15_r0_body.kd63 PRE_first_tail_x15_r0_body.kappa63 PRE_first_tail_x15_r0_body.P63
    ⟨19453, 16526, 2724803, 2777⟩ ⟨19456, 16553, 2724809, 2795⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap63
  clean := bodyClean63
  cfix := PRE_first_tail_x15_r0_body.cfix63
  zpl := PRE_first_tail_x15_r0_body.zpl63
  zplnd := PRE_first_tail_x15_r0_body.zplnd63
  zn1 := PRE_first_tail_x15_r0_body.zn163
  zfirst := PRE_first_tail_x15_r0_body.zfirst63
  zscn := PRE_first_tail_x15_r0_body.zscn63
  zsmn := PRE_first_tail_x15_r0_body.zsmn63
  zgrow := PRE_first_tail_x15_r0_body.zgrow63
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab63
  zfresh := PRE_first_tail_x15_r0_body.zfresh63
  zcnd := PRE_first_tail_x15_r0_body.zcnd63
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi63
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt63
  zgP := PRE_first_tail_x15_r0_body.zg63_2665
  zkP := PRE_first_tail_x15_r0_body.zk63_2665
  zmP := PRE_first_tail_x15_r0_body.zm63_2665
  zgC := PRE_first_tail_x15_r0_body.zg63_2673467
  zkC := PRE_first_tail_x15_r0_body.zk63_2673467
  zmC := PRE_first_tail_x15_r0_body.zm63_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw63_2673472
  zwV := PRE_first_tail_x15_r0_body.zw63_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap63
  zclbd := PRE_first_tail_x15_r0_body.zclbd63
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap63 PRE_first_tail_x15_r0_body.stFoot63 PRE_first_tail_x15_r0_body.iso63 PRE_first_tail_x15_r0_body.zwr63
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP63
  csupp := PRE_first_tail_x15_r0_body.csupp63
  cbound := PRE_first_tail_x15_r0_body.cbound63
  zimg := PRE_first_tail_x15_r0_body.zimg63
  zctl := PRE_first_tail_x15_r0_body.zctl63
  zstack := PRE_first_tail_x15_r0_body.zstack63
  zjobs := PRE_first_tail_x15_r0_body.zjobs63
  zstores := PRE_first_tail_x15_r0_body.zstores63
  zroots := PRE_first_tail_x15_r0_body.zroots63
  znC := PRE_first_tail_x15_r0_body.znC63
  ctab := PRE_first_tail_x15_r0_body.ctab63
  zbin := PRE_first_tail_x15_r0_body.zbin63
  cbridge := PRE_first_tail_x15_r0_body.cbridge63
  sbridge := bodyBridge63
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj63
  cshiftR := fun h hNL => bodyCshift63 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN63
  raised := PRE_first_tail_x15_r0_body.raised63
  cbigs := PRE_first_tail_x15_r0_body.cbigs63
  cjcl := PRE_first_tail_x15_r0_body.cjcl63
  xnLe := Nat.le_of_ble_eq_true bodyXn63
  loLe := Nat.le_of_ble_eq_true bodyLo63
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB63
  cntM := bodyCntM63
  hiLe := Nat.le_of_ble_eq_true bodyHi63
  nhiLe := Nat.le_of_ble_eq_true bodyNhi63
  jsHeap := bodyJs63
  jsRoots := bodyJsRoots63
  jsNative := bodyJsNative63
  framesEmpty := bodyFramesEmpty63
  trailOld := by decide
  lowVars := bodyLow63

def bodyQs63 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs63 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr63.map fun r => nth? PRE_first_tail_x15_r0_body.st63.S5.tab r
kernel_rfl bodyResChk63 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs63 bodyQs63) = true
kernel_rfl bodyLq63 : bodyQs63.length = PRE_first_tail_x15_r0_body.cws63.length
kernel_rfl bodyNrLo63 : PRE_first_tail_x15_r0_body.nr63.all (Nat.ble PRE_first_tail_x15_r0_body.S620.tab.length) = true
kernel_rfl bodySub63 : (Oracles.PRE_first_tail_x15_r0_body.map_site63.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost63 : postSubB bodyM PRE_first_tail_x15_r0_body.ws63 PRE_first_tail_x15_r0_body.cws63 bodyQs63 = true
kernel_rfl bodyDrop63 : Nat.ble (24563 + (PRE_first_tail_x15_r0_body.s621.next - PRE_first_tail_x15_r0_body.s622.next)) 25712 = true
kernel_rfl bodyDropH63 : Nat.ble (431 + ((mlxOf PRE_first_tail_x15_r0_body.s621.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s622.ffi).next)) 456 = true
kernel_rfl bodyDropN63 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s621.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s622.ffi).nnext)) 0 = true
kernel_rfl bodyDv63 : bodyΘ.1.take 351 = bodyΘ.1.take 333 ++ PRE_first_tail_x15_r0_body.cws63
kernel_rfl bodyDe63 : bodyΘ.2.take 351 = bodyΘ.2.take 333 ++ PRE_first_tail_x15_r0_body.nr63.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st63.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 333) (bodyΘ.2.take 333)))
kernel_rfl bodyDl63 : (bodyΘ.1.take 333).length = (bodyΘ.2.take 333).length
kernel_rfl bodyDold63 : (bodyΘ.1.take 333).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws63).isNone && !PRE_first_tail_x15_r0_body.ws63.contains v) = true
kernel_rfl bodyDfree63 : (bodyΘ.2.take 351).all (fun e => (PRE_first_tail_x15_r0_body.cws63 ++ PRE_first_tail_x15_r0_body.ws63).all fun w => e.noVar w) = true

theorem bodyStep63 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨24563, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s620 PRE_first_tail_x15_r0_body.S620)
      (bodyCut NB T tk π i x0 bodyΘ ⟨25712, 456, 0, 351⟩ bodyM PRE_first_tail_x15_r0_body.s622 PRE_first_tail_x15_r0_body.S622) (11334 + 1) :=
  bodySite bodyFacts63.cfix bodyFacts63.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st63.S5.tab) (Es := bodyEs63) (qs := bodyQs63)
    (ok := PRE_first_tail_x15_r0_body.st63.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site63 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts63
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site63 r hr) hi (MapOk.sub hm (sub_of_all bodySub63)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk63 r hr) hi hm ho hq)
    bodyLq63 rfl bodyNrLo63 (postSub_sound bodyPost63)
    (Nat.le_of_ble_eq_true bodyDrop63) (by decide) (Nat.le_of_ble_eq_true bodyDropH63) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN63) (by decide)
    bodyDv63 bodyDe63 bodyDl63 bodyDold63 bodyDfree63 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
