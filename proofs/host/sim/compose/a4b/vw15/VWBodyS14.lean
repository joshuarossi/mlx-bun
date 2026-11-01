import host.sim.compose.a4b.vw15.VWBodyJ14
import host.sim.compose.a4b.vw15.VWBodySite14
import host.sim.compose.a4b.vw15.VWBodyOracles_3
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift14 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S143.tab.length PRE_first_tail_x15_r0_body.s143.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P14.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P14 652 PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.s145.ffi PRE_first_tail_x15_r0_body.s144.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_14
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_14
  have hcl : SSt (· < 652) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S143.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_14] <;> decide) PRE_first_tail_x15_r0_body.cnodesK14 PRE_first_tail_x15_r0_body.cobjsK14
      PRE_first_tail_x15_r0_body.citemsK14 PRE_first_tail_x15_r0_body.cbd14 PRE_first_tail_x15_r0_body.csst14
  exact PRE_first_tail_x15_r0_body.cshift14 bodyNcl14 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_14] at this; exact this)


kernel_rfl bodyFramesEmpty14 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s144 a).isEmpty) = true
kernel_rfl bodyJsRoots14 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s143.next) PRE_first_tail_x15_r0_body.s145.trace PRE_first_tail_x15_r0_body.s145 = true
kernel_rfl bodyJsNative14 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s145.ffi) = true
kernel_rfl bodyLow14 : (PRE_first_tail_x15_r0_body.cws14 ++ PRE_first_tail_x15_r0_body.ws14).all (Nat.ble 9) = true
kernel_rfl bodyCntM14 : countersOkB PRE_first_tail_x15_r0_body.s143 PRE_first_tail_x15_r0_body.s144 = true
kernel_rfl bodyHi14 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s145.ffi).next setupP.E = true
kernel_rfl bodyNhi14 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s145.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge14 : bridgeOf PRE_first_tail_x15_r0_body.s144.ffi = bridgeOf PRE_first_tail_x15_r0_body.s143.ffi
kernel_rfl bodyNN14 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s143.ffi).nnext PRE_first_tail_x15_r0_body.P14.NL = true
kernel_rfl bodyXn14 : Nat.ble (⟨18475, 15559, 2685660, 652⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s145.ffi).next = true
kernel_rfl bodyLo14 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s145.ffi).next = true
theorem bodyFacts14 : BodySiteFacts PRE_first_tail_x15_r0_body.s143 PRE_first_tail_x15_r0_body.s144 PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S143 PRE_first_tail_x15_r0_body.S144 PRE_first_tail_x15_r0_body.S145
    PRE_first_tail_x15_r0_body.ws14 PRE_first_tail_x15_r0_body.cws14 PRE_first_tail_x15_r0_body.nr14 PRE_first_tail_x15_r0_body.pl14 PRE_first_tail_x15_r0_body.cl14 2685670 652 PRE_first_tail_x15_r0_body.kd14 PRE_first_tail_x15_r0_body.kappa14 PRE_first_tail_x15_r0_body.P14
    ⟨18475, 15559, 2685659, 652⟩ ⟨18475, 15559, 2685660, 652⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap14
  clean := bodyClean14
  cfix := PRE_first_tail_x15_r0_body.cfix14
  zpl := PRE_first_tail_x15_r0_body.zpl14
  zplnd := PRE_first_tail_x15_r0_body.zplnd14
  zn1 := PRE_first_tail_x15_r0_body.zn114
  zfirst := PRE_first_tail_x15_r0_body.zfirst14
  zscn := PRE_first_tail_x15_r0_body.zscn14
  zsmn := PRE_first_tail_x15_r0_body.zsmn14
  zgrow := PRE_first_tail_x15_r0_body.zgrow14
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab14
  zfresh := PRE_first_tail_x15_r0_body.zfresh14
  zcnd := PRE_first_tail_x15_r0_body.zcnd14
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi14
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt14
  zgP := PRE_first_tail_x15_r0_body.zg14_2665
  zkP := PRE_first_tail_x15_r0_body.zk14_2665
  zmP := PRE_first_tail_x15_r0_body.zm14_2665
  zgC := PRE_first_tail_x15_r0_body.zg14_2673467
  zkC := PRE_first_tail_x15_r0_body.zk14_2673467
  zmC := PRE_first_tail_x15_r0_body.zm14_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw14_2673472
  zwV := PRE_first_tail_x15_r0_body.zw14_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap14
  zclbd := PRE_first_tail_x15_r0_body.zclbd14
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap14 PRE_first_tail_x15_r0_body.stFoot14 PRE_first_tail_x15_r0_body.iso14 PRE_first_tail_x15_r0_body.zwr14
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP14
  csupp := PRE_first_tail_x15_r0_body.csupp14
  cbound := PRE_first_tail_x15_r0_body.cbound14
  zimg := PRE_first_tail_x15_r0_body.zimg14
  zctl := PRE_first_tail_x15_r0_body.zctl14
  zstack := PRE_first_tail_x15_r0_body.zstack14
  zjobs := PRE_first_tail_x15_r0_body.zjobs14
  zstores := PRE_first_tail_x15_r0_body.zstores14
  zroots := PRE_first_tail_x15_r0_body.zroots14
  znC := PRE_first_tail_x15_r0_body.znC14
  ctab := PRE_first_tail_x15_r0_body.ctab14
  zbin := PRE_first_tail_x15_r0_body.zbin14
  cbridge := PRE_first_tail_x15_r0_body.cbridge14
  sbridge := bodyBridge14
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj14
  cshiftR := fun h hNL => bodyCshift14 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN14
  raised := PRE_first_tail_x15_r0_body.raised14
  cbigs := PRE_first_tail_x15_r0_body.cbigs14
  cjcl := PRE_first_tail_x15_r0_body.cjcl14
  xnLe := Nat.le_of_ble_eq_true bodyXn14
  loLe := Nat.le_of_ble_eq_true bodyLo14
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB14
  cntM := bodyCntM14
  hiLe := Nat.le_of_ble_eq_true bodyHi14
  nhiLe := Nat.le_of_ble_eq_true bodyNhi14
  jsHeap := bodyJs14
  jsRoots := bodyJsRoots14
  jsNative := bodyJsNative14
  framesEmpty := bodyFramesEmpty14
  trailOld := by decide
  lowVars := bodyLow14

def bodyQs14 : List (Option Q) := []
noncomputable def bodyEs14 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr14.map fun r => nth? PRE_first_tail_x15_r0_body.st14.S2.tab r
kernel_rfl bodyResChk14 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs14 bodyQs14) = true
kernel_rfl bodyLq14 : bodyQs14.length = PRE_first_tail_x15_r0_body.cws14.length
kernel_rfl bodyNrLo14 : PRE_first_tail_x15_r0_body.nr14.all (Nat.ble PRE_first_tail_x15_r0_body.S143.tab.length) = true
kernel_rfl bodySub14 : (Oracles.PRE_first_tail_x15_r0_body.map_site14.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost14 : postSubB bodyM PRE_first_tail_x15_r0_body.ws14 PRE_first_tail_x15_r0_body.cws14 bodyQs14 = true
kernel_rfl bodyDrop14 : Nat.ble (9119 + (PRE_first_tail_x15_r0_body.s144.next - PRE_first_tail_x15_r0_body.s145.next)) 9129 = true
kernel_rfl bodyDropH14 : Nat.ble (123 + ((mlxOf PRE_first_tail_x15_r0_body.s144.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s145.ffi).next)) 123 = true
kernel_rfl bodyDropN14 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s144.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s145.ffi).nnext)) 0 = true
kernel_rfl bodyDv14 : bodyΘ.1.take 81 = bodyΘ.1.take 81 ++ PRE_first_tail_x15_r0_body.cws14
kernel_rfl bodyDe14 : bodyΘ.2.take 81 = bodyΘ.2.take 81 ++ PRE_first_tail_x15_r0_body.nr14.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st14.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 81) (bodyΘ.2.take 81)))
kernel_rfl bodyDl14 : (bodyΘ.1.take 81).length = (bodyΘ.2.take 81).length
kernel_rfl bodyDold14 : (bodyΘ.1.take 81).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws14).isNone && !PRE_first_tail_x15_r0_body.ws14.contains v) = true
kernel_rfl bodyDfree14 : (bodyΘ.2.take 81).all (fun e => (PRE_first_tail_x15_r0_body.cws14 ++ PRE_first_tail_x15_r0_body.ws14).all fun w => e.noVar w) = true

theorem bodyStep14 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨9119, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s143 PRE_first_tail_x15_r0_body.S143)
      (bodyCut NB T tk π i x0 bodyΘ ⟨9129, 123, 0, 81⟩ bodyM PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.S145) (98 + 1) :=
  bodySite bodyFacts14.cfix bodyFacts14.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st14.S2.tab) (Es := bodyEs14) (qs := bodyQs14)
    (ok := PRE_first_tail_x15_r0_body.st14.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site14 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts14
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site14 r hr) hi (MapOk.sub hm (sub_of_all bodySub14)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk14 r hr) hi hm ho hq)
    bodyLq14 rfl bodyNrLo14 (postSub_sound bodyPost14)
    (Nat.le_of_ble_eq_true bodyDrop14) (by decide) (Nat.le_of_ble_eq_true bodyDropH14) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN14) (by decide)
    bodyDv14 bodyDe14 bodyDl14 bodyDold14 bodyDfree14 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
