import host.sim.compose.a4b.vw15.VWBodyJ26
import host.sim.compose.a4b.vw15.VWBodySite26
import host.sim.compose.a4b.vw15.VWBodyOracles_6
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift26 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S258.tab.length PRE_first_tail_x15_r0_body.s258.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P26.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P26 1165 PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.s260.ffi PRE_first_tail_x15_r0_body.s259.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_26
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_26
  have hcl : SSt (· < 1165) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s260.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S258.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_26] <;> decide) PRE_first_tail_x15_r0_body.cnodesK26 PRE_first_tail_x15_r0_body.cobjsK26
      PRE_first_tail_x15_r0_body.citemsK26 PRE_first_tail_x15_r0_body.cbd26 PRE_first_tail_x15_r0_body.csst26
  exact PRE_first_tail_x15_r0_body.cshift26 bodyNcl26 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_26] at this; exact this)


kernel_rfl bodyFramesEmpty26 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s259 a).isEmpty) = true
kernel_rfl bodyJsRoots26 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s258.next) PRE_first_tail_x15_r0_body.s260.trace PRE_first_tail_x15_r0_body.s260 = true
kernel_rfl bodyJsNative26 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s260.ffi) = true
kernel_rfl bodyLow26 : (PRE_first_tail_x15_r0_body.cws26 ++ PRE_first_tail_x15_r0_body.ws26).all (Nat.ble 9) = true
kernel_rfl bodyCntM26 : countersOkB PRE_first_tail_x15_r0_body.s258 PRE_first_tail_x15_r0_body.s259 = true
kernel_rfl bodyHi26 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s260.ffi).next setupP.E = true
kernel_rfl bodyNhi26 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s260.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge26 : bridgeOf PRE_first_tail_x15_r0_body.s259.ffi = bridgeOf PRE_first_tail_x15_r0_body.s258.ffi
kernel_rfl bodyNN26 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s258.ffi).nnext PRE_first_tail_x15_r0_body.P26.NL = true
kernel_rfl bodyXn26 : Nat.ble (⟨18711, 15796, 2695072, 1165⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s260.ffi).next = true
kernel_rfl bodyLo26 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s260.ffi).next = true
theorem bodyFacts26 : BodySiteFacts PRE_first_tail_x15_r0_body.s258 PRE_first_tail_x15_r0_body.s259 PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S258 PRE_first_tail_x15_r0_body.S259 PRE_first_tail_x15_r0_body.S260
    PRE_first_tail_x15_r0_body.ws26 PRE_first_tail_x15_r0_body.cws26 PRE_first_tail_x15_r0_body.nr26 PRE_first_tail_x15_r0_body.pl26 PRE_first_tail_x15_r0_body.cl26 2695082 1165 PRE_first_tail_x15_r0_body.kd26 PRE_first_tail_x15_r0_body.kappa26 PRE_first_tail_x15_r0_body.P26
    ⟨18711, 15796, 2695071, 1165⟩ ⟨18711, 15796, 2695072, 1165⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap26
  clean := bodyClean26
  cfix := PRE_first_tail_x15_r0_body.cfix26
  zpl := PRE_first_tail_x15_r0_body.zpl26
  zplnd := PRE_first_tail_x15_r0_body.zplnd26
  zn1 := PRE_first_tail_x15_r0_body.zn126
  zfirst := PRE_first_tail_x15_r0_body.zfirst26
  zscn := PRE_first_tail_x15_r0_body.zscn26
  zsmn := PRE_first_tail_x15_r0_body.zsmn26
  zgrow := PRE_first_tail_x15_r0_body.zgrow26
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab26
  zfresh := PRE_first_tail_x15_r0_body.zfresh26
  zcnd := PRE_first_tail_x15_r0_body.zcnd26
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi26
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt26
  zgP := PRE_first_tail_x15_r0_body.zg26_2665
  zkP := PRE_first_tail_x15_r0_body.zk26_2665
  zmP := PRE_first_tail_x15_r0_body.zm26_2665
  zgC := PRE_first_tail_x15_r0_body.zg26_2673467
  zkC := PRE_first_tail_x15_r0_body.zk26_2673467
  zmC := PRE_first_tail_x15_r0_body.zm26_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw26_2673472
  zwV := PRE_first_tail_x15_r0_body.zw26_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap26
  zclbd := PRE_first_tail_x15_r0_body.zclbd26
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap26 PRE_first_tail_x15_r0_body.stFoot26 PRE_first_tail_x15_r0_body.iso26 PRE_first_tail_x15_r0_body.zwr26
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP26
  csupp := PRE_first_tail_x15_r0_body.csupp26
  cbound := PRE_first_tail_x15_r0_body.cbound26
  zimg := PRE_first_tail_x15_r0_body.zimg26
  zctl := PRE_first_tail_x15_r0_body.zctl26
  zstack := PRE_first_tail_x15_r0_body.zstack26
  zjobs := PRE_first_tail_x15_r0_body.zjobs26
  zstores := PRE_first_tail_x15_r0_body.zstores26
  zroots := PRE_first_tail_x15_r0_body.zroots26
  znC := PRE_first_tail_x15_r0_body.znC26
  ctab := PRE_first_tail_x15_r0_body.ctab26
  zbin := PRE_first_tail_x15_r0_body.zbin26
  cbridge := PRE_first_tail_x15_r0_body.cbridge26
  sbridge := bodyBridge26
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj26
  cshiftR := fun h hNL => bodyCshift26 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN26
  raised := PRE_first_tail_x15_r0_body.raised26
  cbigs := PRE_first_tail_x15_r0_body.cbigs26
  cjcl := PRE_first_tail_x15_r0_body.cjcl26
  xnLe := Nat.le_of_ble_eq_true bodyXn26
  loLe := Nat.le_of_ble_eq_true bodyLo26
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB26
  cntM := bodyCntM26
  hiLe := Nat.le_of_ble_eq_true bodyHi26
  nhiLe := Nat.le_of_ble_eq_true bodyNhi26
  jsHeap := bodyJs26
  jsRoots := bodyJsRoots26
  jsNative := bodyJsNative26
  framesEmpty := bodyFramesEmpty26
  trailOld := by decide
  lowVars := bodyLow26

def bodyQs26 : List (Option Q) := []
noncomputable def bodyEs26 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr26.map fun r => nth? PRE_first_tail_x15_r0_body.st26.S2.tab r
kernel_rfl bodyResChk26 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs26 bodyQs26) = true
kernel_rfl bodyLq26 : bodyQs26.length = PRE_first_tail_x15_r0_body.cws26.length
kernel_rfl bodyNrLo26 : PRE_first_tail_x15_r0_body.nr26.all (Nat.ble PRE_first_tail_x15_r0_body.S258.tab.length) = true
kernel_rfl bodySub26 : (Oracles.PRE_first_tail_x15_r0_body.map_site26.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost26 : postSubB bodyM PRE_first_tail_x15_r0_body.ws26 PRE_first_tail_x15_r0_body.cws26 bodyQs26 = true
kernel_rfl bodyDrop26 : Nat.ble (12964 + (PRE_first_tail_x15_r0_body.s259.next - PRE_first_tail_x15_r0_body.s260.next)) 12974 = true
kernel_rfl bodyDropH26 : Nat.ble (200 + ((mlxOf PRE_first_tail_x15_r0_body.s259.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s260.ffi).next)) 200 = true
kernel_rfl bodyDropN26 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s259.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s260.ffi).nnext)) 0 = true
kernel_rfl bodyDv26 : bodyΘ.1.take 144 = bodyΘ.1.take 144 ++ PRE_first_tail_x15_r0_body.cws26
kernel_rfl bodyDe26 : bodyΘ.2.take 144 = bodyΘ.2.take 144 ++ PRE_first_tail_x15_r0_body.nr26.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st26.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl26 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold26 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws26).isNone && !PRE_first_tail_x15_r0_body.ws26.contains v) = true
kernel_rfl bodyDfree26 : (bodyΘ.2.take 144).all (fun e => (PRE_first_tail_x15_r0_body.cws26 ++ PRE_first_tail_x15_r0_body.ws26).all fun w => e.noVar w) = true

theorem bodyStep26 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s258 PRE_first_tail_x15_r0_body.S258)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.S260) (98 + 1) :=
  bodySite bodyFacts26.cfix bodyFacts26.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st26.S2.tab) (Es := bodyEs26) (qs := bodyQs26)
    (ok := PRE_first_tail_x15_r0_body.st26.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site26 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts26
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site26 r hr) hi (MapOk.sub hm (sub_of_all bodySub26)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk26 r hr) hi hm ho hq)
    bodyLq26 rfl bodyNrLo26 (postSub_sound bodyPost26)
    (Nat.le_of_ble_eq_true bodyDrop26) (by decide) (Nat.le_of_ble_eq_true bodyDropH26) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN26) (by decide)
    bodyDv26 bodyDe26 bodyDl26 bodyDold26 bodyDfree26 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
