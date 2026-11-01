import host.sim.compose.a4b.vw15.VWBodyJ60
import host.sim.compose.a4b.vw15.VWBodySite60
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

theorem bodyCshift60 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S591.tab.length PRE_first_tail_x15_r0_body.s591.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P60.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P60 2666 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.s593.ffi PRE_first_tail_x15_r0_body.s592.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_60
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_60
  have hcl : SSt (· < 2666) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S591.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_60] <;> decide) PRE_first_tail_x15_r0_body.cnodesK60 PRE_first_tail_x15_r0_body.cobjsK60
      PRE_first_tail_x15_r0_body.citemsK60 PRE_first_tail_x15_r0_body.cbd60 PRE_first_tail_x15_r0_body.csst60
  exact PRE_first_tail_x15_r0_body.cshift60 bodyNcl60 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_60] at this; exact this)


kernel_rfl bodyFramesEmpty60 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s592 a).isEmpty) = true
kernel_rfl bodyJsRoots60 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s591.next) PRE_first_tail_x15_r0_body.s593.trace PRE_first_tail_x15_r0_body.s593 = true
kernel_rfl bodyJsNative60 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s593.ffi) = true
kernel_rfl bodyLow60 : (PRE_first_tail_x15_r0_body.cws60 ++ PRE_first_tail_x15_r0_body.ws60).all (Nat.ble 9) = true
kernel_rfl bodyCntM60 : countersOkB PRE_first_tail_x15_r0_body.s591 PRE_first_tail_x15_r0_body.s592 = true
kernel_rfl bodyHi60 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s593.ffi).next setupP.E = true
kernel_rfl bodyNhi60 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s593.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge60 : bridgeOf PRE_first_tail_x15_r0_body.s592.ffi = bridgeOf PRE_first_tail_x15_r0_body.s591.ffi
kernel_rfl bodyNN60 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s591.ffi).nnext PRE_first_tail_x15_r0_body.P60.NL = true
kernel_rfl bodyXn60 : Nat.ble (⟨19399, 16490, 2722553, 2666⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s593.ffi).next = true
kernel_rfl bodyLo60 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s593.ffi).next = true
theorem bodyFacts60 : BodySiteFacts PRE_first_tail_x15_r0_body.s591 PRE_first_tail_x15_r0_body.s592 PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S591 PRE_first_tail_x15_r0_body.S592 PRE_first_tail_x15_r0_body.S593
    PRE_first_tail_x15_r0_body.ws60 PRE_first_tail_x15_r0_body.cws60 PRE_first_tail_x15_r0_body.nr60 PRE_first_tail_x15_r0_body.pl60 PRE_first_tail_x15_r0_body.cl60 2723702 2666 PRE_first_tail_x15_r0_body.kd60 PRE_first_tail_x15_r0_body.kappa60 PRE_first_tail_x15_r0_body.P60
    ⟨19396, 16463, 2722547, 2648⟩ ⟨19399, 16490, 2722553, 2666⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap60
  clean := bodyClean60
  cfix := PRE_first_tail_x15_r0_body.cfix60
  zpl := PRE_first_tail_x15_r0_body.zpl60
  zplnd := PRE_first_tail_x15_r0_body.zplnd60
  zn1 := PRE_first_tail_x15_r0_body.zn160
  zfirst := PRE_first_tail_x15_r0_body.zfirst60
  zscn := PRE_first_tail_x15_r0_body.zscn60
  zsmn := PRE_first_tail_x15_r0_body.zsmn60
  zgrow := PRE_first_tail_x15_r0_body.zgrow60
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab60
  zfresh := PRE_first_tail_x15_r0_body.zfresh60
  zcnd := PRE_first_tail_x15_r0_body.zcnd60
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi60
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt60
  zgP := PRE_first_tail_x15_r0_body.zg60_2665
  zkP := PRE_first_tail_x15_r0_body.zk60_2665
  zmP := PRE_first_tail_x15_r0_body.zm60_2665
  zgC := PRE_first_tail_x15_r0_body.zg60_2673467
  zkC := PRE_first_tail_x15_r0_body.zk60_2673467
  zmC := PRE_first_tail_x15_r0_body.zm60_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw60_2673472
  zwV := PRE_first_tail_x15_r0_body.zw60_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap60
  zclbd := PRE_first_tail_x15_r0_body.zclbd60
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap60 PRE_first_tail_x15_r0_body.stFoot60 PRE_first_tail_x15_r0_body.iso60 PRE_first_tail_x15_r0_body.zwr60
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP60
  csupp := PRE_first_tail_x15_r0_body.csupp60
  cbound := PRE_first_tail_x15_r0_body.cbound60
  zimg := PRE_first_tail_x15_r0_body.zimg60
  zctl := PRE_first_tail_x15_r0_body.zctl60
  zstack := PRE_first_tail_x15_r0_body.zstack60
  zjobs := PRE_first_tail_x15_r0_body.zjobs60
  zstores := PRE_first_tail_x15_r0_body.zstores60
  zroots := PRE_first_tail_x15_r0_body.zroots60
  znC := PRE_first_tail_x15_r0_body.znC60
  ctab := PRE_first_tail_x15_r0_body.ctab60
  zbin := PRE_first_tail_x15_r0_body.zbin60
  cbridge := PRE_first_tail_x15_r0_body.cbridge60
  sbridge := bodyBridge60
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj60
  cshiftR := fun h hNL => bodyCshift60 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN60
  raised := PRE_first_tail_x15_r0_body.raised60
  cbigs := PRE_first_tail_x15_r0_body.cbigs60
  cjcl := PRE_first_tail_x15_r0_body.cjcl60
  xnLe := Nat.le_of_ble_eq_true bodyXn60
  loLe := Nat.le_of_ble_eq_true bodyLo60
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB60
  cntM := bodyCntM60
  hiLe := Nat.le_of_ble_eq_true bodyHi60
  nhiLe := Nat.le_of_ble_eq_true bodyNhi60
  jsHeap := bodyJs60
  jsRoots := bodyJsRoots60
  jsNative := bodyJsNative60
  framesEmpty := bodyFramesEmpty60
  trailOld := by decide
  lowVars := bodyLow60

def bodyQs60 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs60 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr60.map fun r => nth? PRE_first_tail_x15_r0_body.st60.S5.tab r
kernel_rfl bodyResChk60 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs60 bodyQs60) = true
kernel_rfl bodyLq60 : bodyQs60.length = PRE_first_tail_x15_r0_body.cws60.length
kernel_rfl bodyNrLo60 : PRE_first_tail_x15_r0_body.nr60.all (Nat.ble PRE_first_tail_x15_r0_body.S591.tab.length) = true
kernel_rfl bodySub60 : (Oracles.PRE_first_tail_x15_r0_body.map_site60.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost60 : postSubB bodyM PRE_first_tail_x15_r0_body.ws60 PRE_first_tail_x15_r0_body.cws60 bodyQs60 = true
kernel_rfl bodyDrop60 : Nat.ble (23402 + (PRE_first_tail_x15_r0_body.s592.next - PRE_first_tail_x15_r0_body.s593.next)) 24551 = true
kernel_rfl bodyDropH60 : Nat.ble (406 + ((mlxOf PRE_first_tail_x15_r0_body.s592.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s593.ffi).next)) 431 = true
kernel_rfl bodyDropN60 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s592.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s593.ffi).nnext)) 0 = true
kernel_rfl bodyDv60 : bodyΘ.1.take 333 = bodyΘ.1.take 315 ++ PRE_first_tail_x15_r0_body.cws60
kernel_rfl bodyDe60 : bodyΘ.2.take 333 = bodyΘ.2.take 315 ++ PRE_first_tail_x15_r0_body.nr60.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st60.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 315) (bodyΘ.2.take 315)))
kernel_rfl bodyDl60 : (bodyΘ.1.take 315).length = (bodyΘ.2.take 315).length
kernel_rfl bodyDold60 : (bodyΘ.1.take 315).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws60).isNone && !PRE_first_tail_x15_r0_body.ws60.contains v) = true
kernel_rfl bodyDfree60 : (bodyΘ.2.take 333).all (fun e => (PRE_first_tail_x15_r0_body.cws60 ++ PRE_first_tail_x15_r0_body.ws60).all fun w => e.noVar w) = true

theorem bodyStep60 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23402, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s591 PRE_first_tail_x15_r0_body.S591)
      (bodyCut NB T tk π i x0 bodyΘ ⟨24551, 431, 0, 333⟩ bodyM PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.S593) (11334 + 1) :=
  bodySite bodyFacts60.cfix bodyFacts60.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st60.S5.tab) (Es := bodyEs60) (qs := bodyQs60)
    (ok := PRE_first_tail_x15_r0_body.st60.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site60 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts60
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site60 r hr) hi (MapOk.sub hm (sub_of_all bodySub60)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk60 r hr) hi hm ho hq)
    bodyLq60 rfl bodyNrLo60 (postSub_sound bodyPost60)
    (Nat.le_of_ble_eq_true bodyDrop60) (by decide) (Nat.le_of_ble_eq_true bodyDropH60) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN60) (by decide)
    bodyDv60 bodyDe60 bodyDl60 bodyDold60 bodyDfree60 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
