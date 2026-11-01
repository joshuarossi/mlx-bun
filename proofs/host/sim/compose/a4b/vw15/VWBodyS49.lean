import host.sim.compose.a4b.vw15.VWBodyJ49
import host.sim.compose.a4b.vw15.VWBodySite49
import host.sim.compose.a4b.vw15.VWBodyOracles_12
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

theorem bodyCshift49 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S484.tab.length PRE_first_tail_x15_r0_body.s484.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P49.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P49 2174 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.s486.ffi PRE_first_tail_x15_r0_body.s485.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_49
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_49
  have hcl : SSt (· < 2174) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S484.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_49] <;> decide) PRE_first_tail_x15_r0_body.cnodesK49 PRE_first_tail_x15_r0_body.cobjsK49
      PRE_first_tail_x15_r0_body.citemsK49 PRE_first_tail_x15_r0_body.cbd49 PRE_first_tail_x15_r0_body.csst49
  exact PRE_first_tail_x15_r0_body.cshift49 bodyNcl49 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_49] at this; exact this)


kernel_rfl bodyFramesEmpty49 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s485 a).isEmpty) = true
kernel_rfl bodyJsRoots49 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s484.next) PRE_first_tail_x15_r0_body.s486.trace PRE_first_tail_x15_r0_body.s486 = true
kernel_rfl bodyJsNative49 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s486.ffi) = true
kernel_rfl bodyLow49 : (PRE_first_tail_x15_r0_body.cws49 ++ PRE_first_tail_x15_r0_body.ws49).all (Nat.ble 9) = true
kernel_rfl bodyCntM49 : countersOkB PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.s485 = true
kernel_rfl bodyHi49 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next setupP.E = true
kernel_rfl bodyNhi49 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge49 : bridgeOf PRE_first_tail_x15_r0_body.s485.ffi = bridgeOf PRE_first_tail_x15_r0_body.s484.ffi
kernel_rfl bodyNN49 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s484.ffi).nnext PRE_first_tail_x15_r0_body.P49.NL = true
kernel_rfl bodyXn49 : Nat.ble (⟨19176, 16266, 2713619, 2174⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next = true
kernel_rfl bodyLo49 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next = true
theorem bodyFacts49 : BodySiteFacts PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.s485 PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S484 PRE_first_tail_x15_r0_body.S485 PRE_first_tail_x15_r0_body.S486
    PRE_first_tail_x15_r0_body.ws49 PRE_first_tail_x15_r0_body.cws49 PRE_first_tail_x15_r0_body.nr49 PRE_first_tail_x15_r0_body.pl49 PRE_first_tail_x15_r0_body.cl49 2713621 2174 PRE_first_tail_x15_r0_body.kd49 PRE_first_tail_x15_r0_body.kappa49 PRE_first_tail_x15_r0_body.P49
    ⟨19176, 16266, 2713619, 2174⟩ ⟨19176, 16266, 2713619, 2174⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap49
  clean := bodyClean49
  cfix := PRE_first_tail_x15_r0_body.cfix49
  zpl := PRE_first_tail_x15_r0_body.zpl49
  zplnd := PRE_first_tail_x15_r0_body.zplnd49
  zn1 := PRE_first_tail_x15_r0_body.zn149
  zfirst := PRE_first_tail_x15_r0_body.zfirst49
  zscn := PRE_first_tail_x15_r0_body.zscn49
  zsmn := PRE_first_tail_x15_r0_body.zsmn49
  zgrow := PRE_first_tail_x15_r0_body.zgrow49
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab49
  zfresh := PRE_first_tail_x15_r0_body.zfresh49
  zcnd := PRE_first_tail_x15_r0_body.zcnd49
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi49
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt49
  zgP := PRE_first_tail_x15_r0_body.zg49_2665
  zkP := PRE_first_tail_x15_r0_body.zk49_2665
  zmP := PRE_first_tail_x15_r0_body.zm49_2665
  zgC := PRE_first_tail_x15_r0_body.zg49_2673467
  zkC := PRE_first_tail_x15_r0_body.zk49_2673467
  zmC := PRE_first_tail_x15_r0_body.zm49_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw49_2673472
  zwV := PRE_first_tail_x15_r0_body.zw49_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap49
  zclbd := PRE_first_tail_x15_r0_body.zclbd49
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap49 PRE_first_tail_x15_r0_body.stFoot49 PRE_first_tail_x15_r0_body.iso49 PRE_first_tail_x15_r0_body.zwr49
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP49
  csupp := PRE_first_tail_x15_r0_body.csupp49
  cbound := PRE_first_tail_x15_r0_body.cbound49
  zimg := PRE_first_tail_x15_r0_body.zimg49
  zctl := PRE_first_tail_x15_r0_body.zctl49
  zstack := PRE_first_tail_x15_r0_body.zstack49
  zjobs := PRE_first_tail_x15_r0_body.zjobs49
  zstores := PRE_first_tail_x15_r0_body.zstores49
  zroots := PRE_first_tail_x15_r0_body.zroots49
  znC := PRE_first_tail_x15_r0_body.znC49
  ctab := PRE_first_tail_x15_r0_body.ctab49
  zbin := PRE_first_tail_x15_r0_body.zbin49
  cbridge := PRE_first_tail_x15_r0_body.cbridge49
  sbridge := bodyBridge49
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj49
  cshiftR := fun h hNL => bodyCshift49 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN49
  raised := PRE_first_tail_x15_r0_body.raised49
  cbigs := PRE_first_tail_x15_r0_body.cbigs49
  cjcl := PRE_first_tail_x15_r0_body.cjcl49
  xnLe := Nat.le_of_ble_eq_true bodyXn49
  loLe := Nat.le_of_ble_eq_true bodyLo49
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB49
  cntM := bodyCntM49
  hiLe := Nat.le_of_ble_eq_true bodyHi49
  nhiLe := Nat.le_of_ble_eq_true bodyNhi49
  jsHeap := bodyJs49
  jsRoots := bodyJsRoots49
  jsNative := bodyJsNative49
  framesEmpty := bodyFramesEmpty49
  trailOld := by decide
  lowVars := bodyLow49

def bodyQs49 : List (Option Q) := []
noncomputable def bodyEs49 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr49.map fun r => nth? PRE_first_tail_x15_r0_body.st49.S2.tab r
kernel_rfl bodyResChk49 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs49 bodyQs49) = true
kernel_rfl bodyLq49 : bodyQs49.length = PRE_first_tail_x15_r0_body.cws49.length
kernel_rfl bodyNrLo49 : PRE_first_tail_x15_r0_body.nr49.all (Nat.ble PRE_first_tail_x15_r0_body.S484.tab.length) = true
kernel_rfl bodySub49 : (Oracles.PRE_first_tail_x15_r0_body.map_site49.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost49 : postSubB bodyM PRE_first_tail_x15_r0_body.ws49 PRE_first_tail_x15_r0_body.cws49 bodyQs49 = true
kernel_rfl bodyDrop49 : Nat.ble (20679 + (PRE_first_tail_x15_r0_body.s485.next - PRE_first_tail_x15_r0_body.s486.next)) 20681 = true
kernel_rfl bodyDropH49 : Nat.ble (354 + ((mlxOf PRE_first_tail_x15_r0_body.s485.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).next)) 354 = true
kernel_rfl bodyDropN49 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s485.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s486.ffi).nnext)) 0 = true
kernel_rfl bodyDv49 : bodyΘ.1.take 270 = bodyΘ.1.take 270 ++ PRE_first_tail_x15_r0_body.cws49
kernel_rfl bodyDe49 : bodyΘ.2.take 270 = bodyΘ.2.take 270 ++ PRE_first_tail_x15_r0_body.nr49.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st49.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 270) (bodyΘ.2.take 270)))
kernel_rfl bodyDl49 : (bodyΘ.1.take 270).length = (bodyΘ.2.take 270).length
kernel_rfl bodyDold49 : (bodyΘ.1.take 270).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws49).isNone && !PRE_first_tail_x15_r0_body.ws49.contains v) = true
kernel_rfl bodyDfree49 : (bodyΘ.2.take 270).all (fun e => (PRE_first_tail_x15_r0_body.cws49 ++ PRE_first_tail_x15_r0_body.ws49).all fun w => e.noVar w) = true

theorem bodyStep49 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.S484)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.S486) (27 + 1) :=
  bodySite bodyFacts49.cfix bodyFacts49.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st49.S2.tab) (Es := bodyEs49) (qs := bodyQs49)
    (ok := PRE_first_tail_x15_r0_body.st49.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site49 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts49
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site49 r hr) hi (MapOk.sub hm (sub_of_all bodySub49)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk49 r hr) hi hm ho hq)
    bodyLq49 rfl bodyNrLo49 (postSub_sound bodyPost49)
    (Nat.le_of_ble_eq_true bodyDrop49) (by decide) (Nat.le_of_ble_eq_true bodyDropH49) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN49) (by decide)
    bodyDv49 bodyDe49 bodyDl49 bodyDold49 bodyDfree49 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
