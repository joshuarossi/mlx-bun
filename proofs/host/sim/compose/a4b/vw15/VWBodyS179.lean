import host.sim.compose.a4b.vw15.VWBodyJ179
import host.sim.compose.a4b.vw15.VWBodySite179
import host.sim.compose.a4b.vw15.VWBodyOracles_44
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift179 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1724.tab.length PRE_first_tail_x15_r0_body.s1724.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P179.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P179 7705 PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.s1726.ffi PRE_first_tail_x15_r0_body.s1725.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_179
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_179
  have hcl : SSt (· < 7705) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1726.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1724.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_179] <;> decide) PRE_first_tail_x15_r0_body.cnodesK179 PRE_first_tail_x15_r0_body.cobjsK179
      PRE_first_tail_x15_r0_body.citemsK179 PRE_first_tail_x15_r0_body.cbd179 PRE_first_tail_x15_r0_body.csst179
  exact PRE_first_tail_x15_r0_body.cshift179 bodyNcl179 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_179] at this; exact this)


kernel_rfl bodyFramesEmpty179 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1725 a).isEmpty) = true
kernel_rfl bodyJsRoots179 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1724.next) PRE_first_tail_x15_r0_body.s1726.trace PRE_first_tail_x15_r0_body.s1726 = true
kernel_rfl bodyJsNative179 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1726.ffi) = true
kernel_rfl bodyLow179 : (PRE_first_tail_x15_r0_body.cws179 ++ PRE_first_tail_x15_r0_body.ws179).all (Nat.ble 9) = true
kernel_rfl bodyCntM179 : countersOkB PRE_first_tail_x15_r0_body.s1724 PRE_first_tail_x15_r0_body.s1725 = true
kernel_rfl bodyHi179 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1726.ffi).next setupP.E = true
kernel_rfl bodyNhi179 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1726.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge179 : bridgeOf PRE_first_tail_x15_r0_body.s1725.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1724.ffi
kernel_rfl bodyNN179 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1724.ffi).nnext PRE_first_tail_x15_r0_body.P179.NL = true
kernel_rfl bodyXn179 : Nat.ble (⟨21721, 18814, 2815230, 7705⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1726.ffi).next = true
kernel_rfl bodyLo179 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1726.ffi).next = true
theorem bodyFacts179 : BodySiteFacts PRE_first_tail_x15_r0_body.s1724 PRE_first_tail_x15_r0_body.s1725 PRE_first_tail_x15_r0_body.s1726 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1724 PRE_first_tail_x15_r0_body.S1725 PRE_first_tail_x15_r0_body.S1726
    PRE_first_tail_x15_r0_body.ws179 PRE_first_tail_x15_r0_body.cws179 PRE_first_tail_x15_r0_body.nr179 PRE_first_tail_x15_r0_body.pl179 PRE_first_tail_x15_r0_body.cl179 2815249 7705 PRE_first_tail_x15_r0_body.kd179 PRE_first_tail_x15_r0_body.kappa179 PRE_first_tail_x15_r0_body.P179
    ⟨21721, 18814, 2815229, 7705⟩ ⟨21721, 18814, 2815230, 7705⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap179
  clean := bodyClean179
  cfix := PRE_first_tail_x15_r0_body.cfix179
  zpl := PRE_first_tail_x15_r0_body.zpl179
  zplnd := PRE_first_tail_x15_r0_body.zplnd179
  zn1 := PRE_first_tail_x15_r0_body.zn1179
  zfirst := PRE_first_tail_x15_r0_body.zfirst179
  zscn := PRE_first_tail_x15_r0_body.zscn179
  zsmn := PRE_first_tail_x15_r0_body.zsmn179
  zgrow := PRE_first_tail_x15_r0_body.zgrow179
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab179
  zfresh := PRE_first_tail_x15_r0_body.zfresh179
  zcnd := PRE_first_tail_x15_r0_body.zcnd179
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi179
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt179
  zgP := PRE_first_tail_x15_r0_body.zg179_2665
  zkP := PRE_first_tail_x15_r0_body.zk179_2665
  zmP := PRE_first_tail_x15_r0_body.zm179_2665
  zgC := PRE_first_tail_x15_r0_body.zg179_2673467
  zkC := PRE_first_tail_x15_r0_body.zk179_2673467
  zmC := PRE_first_tail_x15_r0_body.zm179_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw179_2673472
  zwV := PRE_first_tail_x15_r0_body.zw179_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap179
  zclbd := PRE_first_tail_x15_r0_body.zclbd179
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap179 PRE_first_tail_x15_r0_body.stFoot179 PRE_first_tail_x15_r0_body.iso179 PRE_first_tail_x15_r0_body.zwr179
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP179
  csupp := PRE_first_tail_x15_r0_body.csupp179
  cbound := PRE_first_tail_x15_r0_body.cbound179
  zimg := PRE_first_tail_x15_r0_body.zimg179
  zctl := PRE_first_tail_x15_r0_body.zctl179
  zstack := PRE_first_tail_x15_r0_body.zstack179
  zjobs := PRE_first_tail_x15_r0_body.zjobs179
  zstores := PRE_first_tail_x15_r0_body.zstores179
  zroots := PRE_first_tail_x15_r0_body.zroots179
  znC := PRE_first_tail_x15_r0_body.znC179
  ctab := PRE_first_tail_x15_r0_body.ctab179
  zbin := PRE_first_tail_x15_r0_body.zbin179
  cbridge := PRE_first_tail_x15_r0_body.cbridge179
  sbridge := bodyBridge179
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj179
  cshiftR := fun h hNL => bodyCshift179 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN179
  raised := PRE_first_tail_x15_r0_body.raised179
  cbigs := PRE_first_tail_x15_r0_body.cbigs179
  cjcl := PRE_first_tail_x15_r0_body.cjcl179
  xnLe := Nat.le_of_ble_eq_true bodyXn179
  loLe := Nat.le_of_ble_eq_true bodyLo179
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB179
  cntM := bodyCntM179
  hiLe := Nat.le_of_ble_eq_true bodyHi179
  nhiLe := Nat.le_of_ble_eq_true bodyNhi179
  jsHeap := bodyJs179
  jsRoots := bodyJsRoots179
  jsNative := bodyJsNative179
  framesEmpty := bodyFramesEmpty179
  trailOld := by decide
  lowVars := bodyLow179

def bodyQs179 : List (Option Q) := []
noncomputable def bodyEs179 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr179.map fun r => nth? PRE_first_tail_x15_r0_body.st179.S2.tab r
kernel_rfl bodyResChk179 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs179 bodyQs179) = true
kernel_rfl bodyLq179 : bodyQs179.length = PRE_first_tail_x15_r0_body.cws179.length
kernel_rfl bodyNrLo179 : PRE_first_tail_x15_r0_body.nr179.all (Nat.ble PRE_first_tail_x15_r0_body.S1724.tab.length) = true
kernel_rfl bodySub179 : (Oracles.PRE_first_tail_x15_r0_body.map_site179.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost179 : postSubB bodyM PRE_first_tail_x15_r0_body.ws179 PRE_first_tail_x15_r0_body.cws179 bodyQs179 = true
kernel_rfl bodyDrop179 : Nat.ble (61968 + (PRE_first_tail_x15_r0_body.s1725.next - PRE_first_tail_x15_r0_body.s1726.next)) 61987 = true
kernel_rfl bodyDropH179 : Nat.ble (1176 + ((mlxOf PRE_first_tail_x15_r0_body.s1725.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1726.ffi).next)) 1176 = true
kernel_rfl bodyDropN179 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1725.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1726.ffi).nnext)) 0 = true
kernel_rfl bodyDv179 : bodyΘ.1.take 945 = bodyΘ.1.take 945 ++ PRE_first_tail_x15_r0_body.cws179
kernel_rfl bodyDe179 : bodyΘ.2.take 945 = bodyΘ.2.take 945 ++ PRE_first_tail_x15_r0_body.nr179.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st179.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 945) (bodyΘ.2.take 945)))
kernel_rfl bodyDl179 : (bodyΘ.1.take 945).length = (bodyΘ.2.take 945).length
kernel_rfl bodyDold179 : (bodyΘ.1.take 945).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws179).isNone && !PRE_first_tail_x15_r0_body.ws179.contains v) = true
kernel_rfl bodyDfree179 : (bodyΘ.2.take 945).all (fun e => (PRE_first_tail_x15_r0_body.cws179 ++ PRE_first_tail_x15_r0_body.ws179).all fun w => e.noVar w) = true

theorem bodyStep179 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61968, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1724 PRE_first_tail_x15_r0_body.S1724)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61987, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1726 PRE_first_tail_x15_r0_body.S1726) (206 + 1) :=
  bodySite bodyFacts179.cfix bodyFacts179.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st179.S2.tab) (Es := bodyEs179) (qs := bodyQs179)
    (ok := PRE_first_tail_x15_r0_body.st179.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site179 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts179
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site179 r hr) hi (MapOk.sub hm (sub_of_all bodySub179)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk179 r hr) hi hm ho hq)
    bodyLq179 rfl bodyNrLo179 (postSub_sound bodyPost179)
    (Nat.le_of_ble_eq_true bodyDrop179) (by decide) (Nat.le_of_ble_eq_true bodyDropH179) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN179) (by decide)
    bodyDv179 bodyDe179 bodyDl179 bodyDold179 bodyDfree179 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
