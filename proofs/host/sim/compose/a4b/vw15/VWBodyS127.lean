import host.sim.compose.a4b.vw15.VWBodyJ127
import host.sim.compose.a4b.vw15.VWBodySite127
import host.sim.compose.a4b.vw15.VWBodyOracles_31
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

theorem bodyCshift127 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1232.tab.length PRE_first_tail_x15_r0_body.s1232.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P127.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P127 5510 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.s1234.ffi PRE_first_tail_x15_r0_body.s1233.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_127
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_127
  have hcl : SSt (· < 5510) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1232.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_127] <;> decide) PRE_first_tail_x15_r0_body.cnodesK127 PRE_first_tail_x15_r0_body.cobjsK127
      PRE_first_tail_x15_r0_body.citemsK127 PRE_first_tail_x15_r0_body.cbd127 PRE_first_tail_x15_r0_body.csst127
  exact PRE_first_tail_x15_r0_body.cshift127 bodyNcl127 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_127] at this; exact this)


kernel_rfl bodyFramesEmpty127 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1233 a).isEmpty) = true
kernel_rfl bodyJsRoots127 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1232.next) PRE_first_tail_x15_r0_body.s1234.trace PRE_first_tail_x15_r0_body.s1234 = true
kernel_rfl bodyJsNative127 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1234.ffi) = true
kernel_rfl bodyLow127 : (PRE_first_tail_x15_r0_body.cws127 ++ PRE_first_tail_x15_r0_body.ws127).all (Nat.ble 9) = true
kernel_rfl bodyCntM127 : countersOkB PRE_first_tail_x15_r0_body.s1232 PRE_first_tail_x15_r0_body.s1233 = true
kernel_rfl bodyHi127 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1234.ffi).next setupP.E = true
kernel_rfl bodyNhi127 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1234.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge127 : bridgeOf PRE_first_tail_x15_r0_body.s1233.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1232.ffi
kernel_rfl bodyNN127 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1232.ffi).nnext PRE_first_tail_x15_r0_body.P127.NL = true
kernel_rfl bodyXn127 : Nat.ble (⟨20706, 17814, 2774631, 5510⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1234.ffi).next = true
kernel_rfl bodyLo127 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1234.ffi).next = true
theorem bodyFacts127 : BodySiteFacts PRE_first_tail_x15_r0_body.s1232 PRE_first_tail_x15_r0_body.s1233 PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1232 PRE_first_tail_x15_r0_body.S1233 PRE_first_tail_x15_r0_body.S1234
    PRE_first_tail_x15_r0_body.ws127 PRE_first_tail_x15_r0_body.cws127 PRE_first_tail_x15_r0_body.nr127 PRE_first_tail_x15_r0_body.pl127 PRE_first_tail_x15_r0_body.cl127 2774633 5510 PRE_first_tail_x15_r0_body.kd127 PRE_first_tail_x15_r0_body.kappa127 PRE_first_tail_x15_r0_body.P127
    ⟨20706, 17814, 2774631, 5510⟩ ⟨20706, 17814, 2774631, 5510⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap127
  clean := bodyClean127
  cfix := PRE_first_tail_x15_r0_body.cfix127
  zpl := PRE_first_tail_x15_r0_body.zpl127
  zplnd := PRE_first_tail_x15_r0_body.zplnd127
  zn1 := PRE_first_tail_x15_r0_body.zn1127
  zfirst := PRE_first_tail_x15_r0_body.zfirst127
  zscn := PRE_first_tail_x15_r0_body.zscn127
  zsmn := PRE_first_tail_x15_r0_body.zsmn127
  zgrow := PRE_first_tail_x15_r0_body.zgrow127
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab127
  zfresh := PRE_first_tail_x15_r0_body.zfresh127
  zcnd := PRE_first_tail_x15_r0_body.zcnd127
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi127
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt127
  zgP := PRE_first_tail_x15_r0_body.zg127_2665
  zkP := PRE_first_tail_x15_r0_body.zk127_2665
  zmP := PRE_first_tail_x15_r0_body.zm127_2665
  zgC := PRE_first_tail_x15_r0_body.zg127_2673467
  zkC := PRE_first_tail_x15_r0_body.zk127_2673467
  zmC := PRE_first_tail_x15_r0_body.zm127_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw127_2673472
  zwV := PRE_first_tail_x15_r0_body.zw127_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap127
  zclbd := PRE_first_tail_x15_r0_body.zclbd127
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap127 PRE_first_tail_x15_r0_body.stFoot127 PRE_first_tail_x15_r0_body.iso127 PRE_first_tail_x15_r0_body.zwr127
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP127
  csupp := PRE_first_tail_x15_r0_body.csupp127
  cbound := PRE_first_tail_x15_r0_body.cbound127
  zimg := PRE_first_tail_x15_r0_body.zimg127
  zctl := PRE_first_tail_x15_r0_body.zctl127
  zstack := PRE_first_tail_x15_r0_body.zstack127
  zjobs := PRE_first_tail_x15_r0_body.zjobs127
  zstores := PRE_first_tail_x15_r0_body.zstores127
  zroots := PRE_first_tail_x15_r0_body.zroots127
  znC := PRE_first_tail_x15_r0_body.znC127
  ctab := PRE_first_tail_x15_r0_body.ctab127
  zbin := PRE_first_tail_x15_r0_body.zbin127
  cbridge := PRE_first_tail_x15_r0_body.cbridge127
  sbridge := bodyBridge127
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj127
  cshiftR := fun h hNL => bodyCshift127 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN127
  raised := PRE_first_tail_x15_r0_body.raised127
  cbigs := PRE_first_tail_x15_r0_body.cbigs127
  cjcl := PRE_first_tail_x15_r0_body.cjcl127
  xnLe := Nat.le_of_ble_eq_true bodyXn127
  loLe := Nat.le_of_ble_eq_true bodyLo127
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB127
  cntM := bodyCntM127
  hiLe := Nat.le_of_ble_eq_true bodyHi127
  nhiLe := Nat.le_of_ble_eq_true bodyNhi127
  jsHeap := bodyJs127
  jsRoots := bodyJsRoots127
  jsNative := bodyJsNative127
  framesEmpty := bodyFramesEmpty127
  trailOld := by decide
  lowVars := bodyLow127

def bodyQs127 : List (Option Q) := []
noncomputable def bodyEs127 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr127.map fun r => nth? PRE_first_tail_x15_r0_body.st127.S2.tab r
kernel_rfl bodyResChk127 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs127 bodyQs127) = true
kernel_rfl bodyLq127 : bodyQs127.length = PRE_first_tail_x15_r0_body.cws127.length
kernel_rfl bodyNrLo127 : PRE_first_tail_x15_r0_body.nr127.all (Nat.ble PRE_first_tail_x15_r0_body.S1232.tab.length) = true
kernel_rfl bodySub127 : (Oracles.PRE_first_tail_x15_r0_body.map_site127.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost127 : postSubB bodyM PRE_first_tail_x15_r0_body.ws127 PRE_first_tail_x15_r0_body.cws127 bodyQs127 = true
kernel_rfl bodyDrop127 : Nat.ble (46134 + (PRE_first_tail_x15_r0_body.s1233.next - PRE_first_tail_x15_r0_body.s1234.next)) 46136 = true
kernel_rfl bodyDropH127 : Nat.ble (866 + ((mlxOf PRE_first_tail_x15_r0_body.s1233.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1234.ffi).next)) 866 = true
kernel_rfl bodyDropN127 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1233.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1234.ffi).nnext)) 0 = true
kernel_rfl bodyDv127 : bodyΘ.1.take 684 = bodyΘ.1.take 684 ++ PRE_first_tail_x15_r0_body.cws127
kernel_rfl bodyDe127 : bodyΘ.2.take 684 = bodyΘ.2.take 684 ++ PRE_first_tail_x15_r0_body.nr127.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st127.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 684) (bodyΘ.2.take 684)))
kernel_rfl bodyDl127 : (bodyΘ.1.take 684).length = (bodyΘ.2.take 684).length
kernel_rfl bodyDold127 : (bodyΘ.1.take 684).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws127).isNone && !PRE_first_tail_x15_r0_body.ws127.contains v) = true
kernel_rfl bodyDfree127 : (bodyΘ.2.take 684).all (fun e => (PRE_first_tail_x15_r0_body.cws127 ++ PRE_first_tail_x15_r0_body.ws127).all fun w => e.noVar w) = true

theorem bodyStep127 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46134, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1232 PRE_first_tail_x15_r0_body.S1232)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46136, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.S1234) (27 + 1) :=
  bodySite bodyFacts127.cfix bodyFacts127.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st127.S2.tab) (Es := bodyEs127) (qs := bodyQs127)
    (ok := PRE_first_tail_x15_r0_body.st127.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site127 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts127
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site127 r hr) hi (MapOk.sub hm (sub_of_all bodySub127)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk127 r hr) hi hm ho hq)
    bodyLq127 rfl bodyNrLo127 (postSub_sound bodyPost127)
    (Nat.le_of_ble_eq_true bodyDrop127) (by decide) (Nat.le_of_ble_eq_true bodyDropH127) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN127) (by decide)
    bodyDv127 bodyDe127 bodyDl127 bodyDold127 bodyDfree127 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
