import host.sim.compose.a4b.vw15.VWBodyJ46
import host.sim.compose.a4b.vw15.VWBodySite46
import host.sim.compose.a4b.vw15.VWBodyOracles_11
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift46 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S455.tab.length PRE_first_tail_x15_r0_body.s455.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P46.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P46 2045 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.s457.ffi PRE_first_tail_x15_r0_body.s456.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_46
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_46
  have hcl : SSt (· < 2045) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S455.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_46] <;> decide) PRE_first_tail_x15_r0_body.cnodesK46 PRE_first_tail_x15_r0_body.cobjsK46
      PRE_first_tail_x15_r0_body.citemsK46 PRE_first_tail_x15_r0_body.cbd46 PRE_first_tail_x15_r0_body.csst46
  exact PRE_first_tail_x15_r0_body.cshift46 bodyNcl46 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_46] at this; exact this)


kernel_rfl bodyFramesEmpty46 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s456 a).isEmpty) = true
kernel_rfl bodyJsRoots46 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s455.next) PRE_first_tail_x15_r0_body.s457.trace PRE_first_tail_x15_r0_body.s457 = true
kernel_rfl bodyJsNative46 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s457.ffi) = true
kernel_rfl bodyLow46 : (PRE_first_tail_x15_r0_body.cws46 ++ PRE_first_tail_x15_r0_body.ws46).all (Nat.ble 9) = true
kernel_rfl bodyCntM46 : countersOkB PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.s456 = true
kernel_rfl bodyHi46 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next setupP.E = true
kernel_rfl bodyNhi46 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge46 : bridgeOf PRE_first_tail_x15_r0_body.s456.ffi = bridgeOf PRE_first_tail_x15_r0_body.s455.ffi
kernel_rfl bodyNN46 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s455.ffi).nnext PRE_first_tail_x15_r0_body.P46.NL = true
kernel_rfl bodyXn46 : Nat.ble (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next = true
kernel_rfl bodyLo46 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next = true
theorem bodyFacts46 : BodySiteFacts PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.s456 PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S455 PRE_first_tail_x15_r0_body.S456 PRE_first_tail_x15_r0_body.S457
    PRE_first_tail_x15_r0_body.ws46 PRE_first_tail_x15_r0_body.cws46 PRE_first_tail_x15_r0_body.nr46 PRE_first_tail_x15_r0_body.pl46 PRE_first_tail_x15_r0_body.cl46 2711339 2045 PRE_first_tail_x15_r0_body.kd46 PRE_first_tail_x15_r0_body.kappa46 PRE_first_tail_x15_r0_body.P46
    ⟨19118, 16203, 2711337, 2045⟩ ⟨19118, 16203, 2711337, 2045⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap46
  clean := bodyClean46
  cfix := PRE_first_tail_x15_r0_body.cfix46
  zpl := PRE_first_tail_x15_r0_body.zpl46
  zplnd := PRE_first_tail_x15_r0_body.zplnd46
  zn1 := PRE_first_tail_x15_r0_body.zn146
  zfirst := PRE_first_tail_x15_r0_body.zfirst46
  zscn := PRE_first_tail_x15_r0_body.zscn46
  zsmn := PRE_first_tail_x15_r0_body.zsmn46
  zgrow := PRE_first_tail_x15_r0_body.zgrow46
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab46
  zfresh := PRE_first_tail_x15_r0_body.zfresh46
  zcnd := PRE_first_tail_x15_r0_body.zcnd46
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi46
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt46
  zgP := PRE_first_tail_x15_r0_body.zg46_2665
  zkP := PRE_first_tail_x15_r0_body.zk46_2665
  zmP := PRE_first_tail_x15_r0_body.zm46_2665
  zgC := PRE_first_tail_x15_r0_body.zg46_2673467
  zkC := PRE_first_tail_x15_r0_body.zk46_2673467
  zmC := PRE_first_tail_x15_r0_body.zm46_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw46_2673472
  zwV := PRE_first_tail_x15_r0_body.zw46_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap46
  zclbd := PRE_first_tail_x15_r0_body.zclbd46
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap46 PRE_first_tail_x15_r0_body.stFoot46 PRE_first_tail_x15_r0_body.iso46 PRE_first_tail_x15_r0_body.zwr46
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP46
  csupp := PRE_first_tail_x15_r0_body.csupp46
  cbound := PRE_first_tail_x15_r0_body.cbound46
  zimg := PRE_first_tail_x15_r0_body.zimg46
  zctl := PRE_first_tail_x15_r0_body.zctl46
  zstack := PRE_first_tail_x15_r0_body.zstack46
  zjobs := PRE_first_tail_x15_r0_body.zjobs46
  zstores := PRE_first_tail_x15_r0_body.zstores46
  zroots := PRE_first_tail_x15_r0_body.zroots46
  znC := PRE_first_tail_x15_r0_body.znC46
  ctab := PRE_first_tail_x15_r0_body.ctab46
  zbin := PRE_first_tail_x15_r0_body.zbin46
  cbridge := PRE_first_tail_x15_r0_body.cbridge46
  sbridge := bodyBridge46
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj46
  cshiftR := fun h hNL => bodyCshift46 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN46
  raised := PRE_first_tail_x15_r0_body.raised46
  cbigs := PRE_first_tail_x15_r0_body.cbigs46
  cjcl := PRE_first_tail_x15_r0_body.cjcl46
  xnLe := Nat.le_of_ble_eq_true bodyXn46
  loLe := Nat.le_of_ble_eq_true bodyLo46
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB46
  cntM := bodyCntM46
  hiLe := Nat.le_of_ble_eq_true bodyHi46
  nhiLe := Nat.le_of_ble_eq_true bodyNhi46
  jsHeap := bodyJs46
  jsRoots := bodyJsRoots46
  jsNative := bodyJsNative46
  framesEmpty := bodyFramesEmpty46
  trailOld := by decide
  lowVars := bodyLow46

def bodyQs46 : List (Option Q) := []
noncomputable def bodyEs46 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr46.map fun r => nth? PRE_first_tail_x15_r0_body.st46.S2.tab r
kernel_rfl bodyResChk46 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs46 bodyQs46) = true
kernel_rfl bodyLq46 : bodyQs46.length = PRE_first_tail_x15_r0_body.cws46.length
kernel_rfl bodyNrLo46 : PRE_first_tail_x15_r0_body.nr46.all (Nat.ble PRE_first_tail_x15_r0_body.S455.tab.length) = true
kernel_rfl bodySub46 : (Oracles.PRE_first_tail_x15_r0_body.map_site46.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost46 : postSubB bodyM PRE_first_tail_x15_r0_body.ws46 PRE_first_tail_x15_r0_body.cws46 bodyQs46 = true
kernel_rfl bodyDrop46 : Nat.ble (19509 + (PRE_first_tail_x15_r0_body.s456.next - PRE_first_tail_x15_r0_body.s457.next)) 19511 = true
kernel_rfl bodyDropH46 : Nat.ble (329 + ((mlxOf PRE_first_tail_x15_r0_body.s456.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).next)) 329 = true
kernel_rfl bodyDropN46 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s456.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s457.ffi).nnext)) 0 = true
kernel_rfl bodyDv46 : bodyΘ.1.take 252 = bodyΘ.1.take 252 ++ PRE_first_tail_x15_r0_body.cws46
kernel_rfl bodyDe46 : bodyΘ.2.take 252 = bodyΘ.2.take 252 ++ PRE_first_tail_x15_r0_body.nr46.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st46.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 252) (bodyΘ.2.take 252)))
kernel_rfl bodyDl46 : (bodyΘ.1.take 252).length = (bodyΘ.2.take 252).length
kernel_rfl bodyDold46 : (bodyΘ.1.take 252).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws46).isNone && !PRE_first_tail_x15_r0_body.ws46.contains v) = true
kernel_rfl bodyDfree46 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x15_r0_body.cws46 ++ PRE_first_tail_x15_r0_body.ws46).all fun w => e.noVar w) = true

theorem bodyStep46 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s455 PRE_first_tail_x15_r0_body.S455)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.S457) (27 + 1) :=
  bodySite bodyFacts46.cfix bodyFacts46.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st46.S2.tab) (Es := bodyEs46) (qs := bodyQs46)
    (ok := PRE_first_tail_x15_r0_body.st46.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site46 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts46
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site46 r hr) hi (MapOk.sub hm (sub_of_all bodySub46)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk46 r hr) hi hm ho hq)
    bodyLq46 rfl bodyNrLo46 (postSub_sound bodyPost46)
    (Nat.le_of_ble_eq_true bodyDrop46) (by decide) (Nat.le_of_ble_eq_true bodyDropH46) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN46) (by decide)
    bodyDv46 bodyDe46 bodyDl46 bodyDold46 bodyDfree46 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
