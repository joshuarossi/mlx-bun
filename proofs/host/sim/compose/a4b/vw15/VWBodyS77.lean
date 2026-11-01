import host.sim.compose.a4b.vw15.VWBodyJ77
import host.sim.compose.a4b.vw15.VWBodySite77
import host.sim.compose.a4b.vw15.VWBodyOracles_19
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift77 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S747.tab.length PRE_first_tail_x15_r0_body.s747.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P77.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P77 3346 PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.s749.ffi PRE_first_tail_x15_r0_body.s748.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_77
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_77
  have hcl : SSt (· < 3346) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S747.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_77] <;> decide) PRE_first_tail_x15_r0_body.cnodesK77 PRE_first_tail_x15_r0_body.cobjsK77
      PRE_first_tail_x15_r0_body.citemsK77 PRE_first_tail_x15_r0_body.cbd77 PRE_first_tail_x15_r0_body.csst77
  exact PRE_first_tail_x15_r0_body.cshift77 bodyNcl77 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_77] at this; exact this)


kernel_rfl bodyFramesEmpty77 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s748 a).isEmpty) = true
kernel_rfl bodyJsRoots77 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s747.next) PRE_first_tail_x15_r0_body.s749.trace PRE_first_tail_x15_r0_body.s749 = true
kernel_rfl bodyJsNative77 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s749.ffi) = true
kernel_rfl bodyLow77 : (PRE_first_tail_x15_r0_body.cws77 ++ PRE_first_tail_x15_r0_body.ws77).all (Nat.ble 9) = true
kernel_rfl bodyCntM77 : countersOkB PRE_first_tail_x15_r0_body.s747 PRE_first_tail_x15_r0_body.s748 = true
kernel_rfl bodyHi77 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s749.ffi).next setupP.E = true
kernel_rfl bodyNhi77 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s749.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge77 : bridgeOf PRE_first_tail_x15_r0_body.s748.ffi = bridgeOf PRE_first_tail_x15_r0_body.s747.ffi
kernel_rfl bodyNN77 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s747.ffi).nnext PRE_first_tail_x15_r0_body.P77.NL = true
kernel_rfl bodyXn77 : Nat.ble (⟨19712, 16807, 2735000, 3346⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s749.ffi).next = true
kernel_rfl bodyLo77 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s749.ffi).next = true
theorem bodyFacts77 : BodySiteFacts PRE_first_tail_x15_r0_body.s747 PRE_first_tail_x15_r0_body.s748 PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S747 PRE_first_tail_x15_r0_body.S748 PRE_first_tail_x15_r0_body.S749
    PRE_first_tail_x15_r0_body.ws77 PRE_first_tail_x15_r0_body.cws77 PRE_first_tail_x15_r0_body.nr77 PRE_first_tail_x15_r0_body.pl77 PRE_first_tail_x15_r0_body.cl77 2735010 3346 PRE_first_tail_x15_r0_body.kd77 PRE_first_tail_x15_r0_body.kappa77 PRE_first_tail_x15_r0_body.P77
    ⟨19712, 16807, 2734999, 3346⟩ ⟨19712, 16807, 2735000, 3346⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap77
  clean := bodyClean77
  cfix := PRE_first_tail_x15_r0_body.cfix77
  zpl := PRE_first_tail_x15_r0_body.zpl77
  zplnd := PRE_first_tail_x15_r0_body.zplnd77
  zn1 := PRE_first_tail_x15_r0_body.zn177
  zfirst := PRE_first_tail_x15_r0_body.zfirst77
  zscn := PRE_first_tail_x15_r0_body.zscn77
  zsmn := PRE_first_tail_x15_r0_body.zsmn77
  zgrow := PRE_first_tail_x15_r0_body.zgrow77
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab77
  zfresh := PRE_first_tail_x15_r0_body.zfresh77
  zcnd := PRE_first_tail_x15_r0_body.zcnd77
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi77
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt77
  zgP := PRE_first_tail_x15_r0_body.zg77_2665
  zkP := PRE_first_tail_x15_r0_body.zk77_2665
  zmP := PRE_first_tail_x15_r0_body.zm77_2665
  zgC := PRE_first_tail_x15_r0_body.zg77_2673467
  zkC := PRE_first_tail_x15_r0_body.zk77_2673467
  zmC := PRE_first_tail_x15_r0_body.zm77_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw77_2673472
  zwV := PRE_first_tail_x15_r0_body.zw77_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap77
  zclbd := PRE_first_tail_x15_r0_body.zclbd77
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap77 PRE_first_tail_x15_r0_body.stFoot77 PRE_first_tail_x15_r0_body.iso77 PRE_first_tail_x15_r0_body.zwr77
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP77
  csupp := PRE_first_tail_x15_r0_body.csupp77
  cbound := PRE_first_tail_x15_r0_body.cbound77
  zimg := PRE_first_tail_x15_r0_body.zimg77
  zctl := PRE_first_tail_x15_r0_body.zctl77
  zstack := PRE_first_tail_x15_r0_body.zstack77
  zjobs := PRE_first_tail_x15_r0_body.zjobs77
  zstores := PRE_first_tail_x15_r0_body.zstores77
  zroots := PRE_first_tail_x15_r0_body.zroots77
  znC := PRE_first_tail_x15_r0_body.znC77
  ctab := PRE_first_tail_x15_r0_body.ctab77
  zbin := PRE_first_tail_x15_r0_body.zbin77
  cbridge := PRE_first_tail_x15_r0_body.cbridge77
  sbridge := bodyBridge77
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj77
  cshiftR := fun h hNL => bodyCshift77 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN77
  raised := PRE_first_tail_x15_r0_body.raised77
  cbigs := PRE_first_tail_x15_r0_body.cbigs77
  cjcl := PRE_first_tail_x15_r0_body.cjcl77
  xnLe := Nat.le_of_ble_eq_true bodyXn77
  loLe := Nat.le_of_ble_eq_true bodyLo77
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB77
  cntM := bodyCntM77
  hiLe := Nat.le_of_ble_eq_true bodyHi77
  nhiLe := Nat.le_of_ble_eq_true bodyNhi77
  jsHeap := bodyJs77
  jsRoots := bodyJsRoots77
  jsNative := bodyJsNative77
  framesEmpty := bodyFramesEmpty77
  trailOld := by decide
  lowVars := bodyLow77

def bodyQs77 : List (Option Q) := []
noncomputable def bodyEs77 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr77.map fun r => nth? PRE_first_tail_x15_r0_body.st77.S2.tab r
kernel_rfl bodyResChk77 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs77 bodyQs77) = true
kernel_rfl bodyLq77 : bodyQs77.length = PRE_first_tail_x15_r0_body.cws77.length
kernel_rfl bodyNrLo77 : PRE_first_tail_x15_r0_body.nr77.all (Nat.ble PRE_first_tail_x15_r0_body.S747.tab.length) = true
kernel_rfl bodySub77 : (Oracles.PRE_first_tail_x15_r0_body.map_site77.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost77 : postSubB bodyM PRE_first_tail_x15_r0_body.ws77 PRE_first_tail_x15_r0_body.cws77 bodyQs77 = true
kernel_rfl bodyDrop77 : Nat.ble (29559 + (PRE_first_tail_x15_r0_body.s748.next - PRE_first_tail_x15_r0_body.s749.next)) 29569 = true
kernel_rfl bodyDropH77 : Nat.ble (533 + ((mlxOf PRE_first_tail_x15_r0_body.s748.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s749.ffi).next)) 533 = true
kernel_rfl bodyDropN77 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s748.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s749.ffi).nnext)) 0 = true
kernel_rfl bodyDv77 : bodyΘ.1.take 414 = bodyΘ.1.take 414 ++ PRE_first_tail_x15_r0_body.cws77
kernel_rfl bodyDe77 : bodyΘ.2.take 414 = bodyΘ.2.take 414 ++ PRE_first_tail_x15_r0_body.nr77.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st77.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 414) (bodyΘ.2.take 414)))
kernel_rfl bodyDl77 : (bodyΘ.1.take 414).length = (bodyΘ.2.take 414).length
kernel_rfl bodyDold77 : (bodyΘ.1.take 414).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws77).isNone && !PRE_first_tail_x15_r0_body.ws77.contains v) = true
kernel_rfl bodyDfree77 : (bodyΘ.2.take 414).all (fun e => (PRE_first_tail_x15_r0_body.cws77 ++ PRE_first_tail_x15_r0_body.ws77).all fun w => e.noVar w) = true

theorem bodyStep77 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29559, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s747 PRE_first_tail_x15_r0_body.S747)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29569, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s749 PRE_first_tail_x15_r0_body.S749) (98 + 1) :=
  bodySite bodyFacts77.cfix bodyFacts77.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st77.S2.tab) (Es := bodyEs77) (qs := bodyQs77)
    (ok := PRE_first_tail_x15_r0_body.st77.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site77 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts77
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site77 r hr) hi (MapOk.sub hm (sub_of_all bodySub77)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk77 r hr) hi hm ho hq)
    bodyLq77 rfl bodyNrLo77 (postSub_sound bodyPost77)
    (Nat.le_of_ble_eq_true bodyDrop77) (by decide) (Nat.le_of_ble_eq_true bodyDropH77) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN77) (by decide)
    bodyDv77 bodyDe77 bodyDl77 bodyDold77 bodyDfree77 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
