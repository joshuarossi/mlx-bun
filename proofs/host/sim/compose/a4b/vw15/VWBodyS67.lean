import host.sim.compose.a4b.vw15.VWBodyJ67
import host.sim.compose.a4b.vw15.VWBodySite67
import host.sim.compose.a4b.vw15.VWBodyOracles_16
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift67 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S657.tab.length PRE_first_tail_x15_r0_body.s657.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P67.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P67 2945 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.s659.ffi PRE_first_tail_x15_r0_body.s658.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_67
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_67
  have hcl : SSt (· < 2945) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S657.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_67] <;> decide) PRE_first_tail_x15_r0_body.cnodesK67 PRE_first_tail_x15_r0_body.cobjsK67
      PRE_first_tail_x15_r0_body.citemsK67 PRE_first_tail_x15_r0_body.cbd67 PRE_first_tail_x15_r0_body.csst67
  exact PRE_first_tail_x15_r0_body.cshift67 bodyNcl67 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_67] at this; exact this)


kernel_rfl bodyFramesEmpty67 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s658 a).isEmpty) = true
kernel_rfl bodyJsRoots67 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s657.next) PRE_first_tail_x15_r0_body.s659.trace PRE_first_tail_x15_r0_body.s659 = true
kernel_rfl bodyJsNative67 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s659.ffi) = true
kernel_rfl bodyLow67 : (PRE_first_tail_x15_r0_body.cws67 ++ PRE_first_tail_x15_r0_body.ws67).all (Nat.ble 9) = true
kernel_rfl bodyCntM67 : countersOkB PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.s658 = true
kernel_rfl bodyHi67 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s659.ffi).next setupP.E = true
kernel_rfl bodyNhi67 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s659.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge67 : bridgeOf PRE_first_tail_x15_r0_body.s658.ffi = bridgeOf PRE_first_tail_x15_r0_body.s657.ffi
kernel_rfl bodyNN67 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s657.ffi).nnext PRE_first_tail_x15_r0_body.P67.NL = true
kernel_rfl bodyXn67 : Nat.ble (⟨19526, 16629, 2727555, 2945⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s659.ffi).next = true
kernel_rfl bodyLo67 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s659.ffi).next = true
theorem bodyFacts67 : BodySiteFacts PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.s658 PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S657 PRE_first_tail_x15_r0_body.S658 PRE_first_tail_x15_r0_body.S659
    PRE_first_tail_x15_r0_body.ws67 PRE_first_tail_x15_r0_body.cws67 PRE_first_tail_x15_r0_body.nr67 PRE_first_tail_x15_r0_body.pl67 PRE_first_tail_x15_r0_body.cl67 2727557 2945 PRE_first_tail_x15_r0_body.kd67 PRE_first_tail_x15_r0_body.kappa67 PRE_first_tail_x15_r0_body.P67
    ⟨19526, 16629, 2727555, 2945⟩ ⟨19526, 16629, 2727555, 2945⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap67
  clean := bodyClean67
  cfix := PRE_first_tail_x15_r0_body.cfix67
  zpl := PRE_first_tail_x15_r0_body.zpl67
  zplnd := PRE_first_tail_x15_r0_body.zplnd67
  zn1 := PRE_first_tail_x15_r0_body.zn167
  zfirst := PRE_first_tail_x15_r0_body.zfirst67
  zscn := PRE_first_tail_x15_r0_body.zscn67
  zsmn := PRE_first_tail_x15_r0_body.zsmn67
  zgrow := PRE_first_tail_x15_r0_body.zgrow67
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab67
  zfresh := PRE_first_tail_x15_r0_body.zfresh67
  zcnd := PRE_first_tail_x15_r0_body.zcnd67
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi67
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt67
  zgP := PRE_first_tail_x15_r0_body.zg67_2665
  zkP := PRE_first_tail_x15_r0_body.zk67_2665
  zmP := PRE_first_tail_x15_r0_body.zm67_2665
  zgC := PRE_first_tail_x15_r0_body.zg67_2673467
  zkC := PRE_first_tail_x15_r0_body.zk67_2673467
  zmC := PRE_first_tail_x15_r0_body.zm67_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw67_2673472
  zwV := PRE_first_tail_x15_r0_body.zw67_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap67
  zclbd := PRE_first_tail_x15_r0_body.zclbd67
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap67 PRE_first_tail_x15_r0_body.stFoot67 PRE_first_tail_x15_r0_body.iso67 PRE_first_tail_x15_r0_body.zwr67
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP67
  csupp := PRE_first_tail_x15_r0_body.csupp67
  cbound := PRE_first_tail_x15_r0_body.cbound67
  zimg := PRE_first_tail_x15_r0_body.zimg67
  zctl := PRE_first_tail_x15_r0_body.zctl67
  zstack := PRE_first_tail_x15_r0_body.zstack67
  zjobs := PRE_first_tail_x15_r0_body.zjobs67
  zstores := PRE_first_tail_x15_r0_body.zstores67
  zroots := PRE_first_tail_x15_r0_body.zroots67
  znC := PRE_first_tail_x15_r0_body.znC67
  ctab := PRE_first_tail_x15_r0_body.ctab67
  zbin := PRE_first_tail_x15_r0_body.zbin67
  cbridge := PRE_first_tail_x15_r0_body.cbridge67
  sbridge := bodyBridge67
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj67
  cshiftR := fun h hNL => bodyCshift67 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN67
  raised := PRE_first_tail_x15_r0_body.raised67
  cbigs := PRE_first_tail_x15_r0_body.cbigs67
  cjcl := PRE_first_tail_x15_r0_body.cjcl67
  xnLe := Nat.le_of_ble_eq_true bodyXn67
  loLe := Nat.le_of_ble_eq_true bodyLo67
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB67
  cntM := bodyCntM67
  hiLe := Nat.le_of_ble_eq_true bodyHi67
  nhiLe := Nat.le_of_ble_eq_true bodyNhi67
  jsHeap := bodyJs67
  jsRoots := bodyJsRoots67
  jsNative := bodyJsNative67
  framesEmpty := bodyFramesEmpty67
  trailOld := by decide
  lowVars := bodyLow67

def bodyQs67 : List (Option Q) := []
noncomputable def bodyEs67 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr67.map fun r => nth? PRE_first_tail_x15_r0_body.st67.S2.tab r
kernel_rfl bodyResChk67 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs67 bodyQs67) = true
kernel_rfl bodyLq67 : bodyQs67.length = PRE_first_tail_x15_r0_body.cws67.length
kernel_rfl bodyNrLo67 : PRE_first_tail_x15_r0_body.nr67.all (Nat.ble PRE_first_tail_x15_r0_body.S657.tab.length) = true
kernel_rfl bodySub67 : (Oracles.PRE_first_tail_x15_r0_body.map_site67.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost67 : postSubB bodyM PRE_first_tail_x15_r0_body.ws67 PRE_first_tail_x15_r0_body.cws67 bodyQs67 = true
kernel_rfl bodyDrop67 : Nat.ble (26873 + (PRE_first_tail_x15_r0_body.s658.next - PRE_first_tail_x15_r0_body.s659.next)) 26875 = true
kernel_rfl bodyDropH67 : Nat.ble (481 + ((mlxOf PRE_first_tail_x15_r0_body.s658.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s659.ffi).next)) 481 = true
kernel_rfl bodyDropN67 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s658.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s659.ffi).nnext)) 0 = true
kernel_rfl bodyDv67 : bodyΘ.1.take 369 = bodyΘ.1.take 369 ++ PRE_first_tail_x15_r0_body.cws67
kernel_rfl bodyDe67 : bodyΘ.2.take 369 = bodyΘ.2.take 369 ++ PRE_first_tail_x15_r0_body.nr67.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st67.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 369) (bodyΘ.2.take 369)))
kernel_rfl bodyDl67 : (bodyΘ.1.take 369).length = (bodyΘ.2.take 369).length
kernel_rfl bodyDold67 : (bodyΘ.1.take 369).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws67).isNone && !PRE_first_tail_x15_r0_body.ws67.contains v) = true
kernel_rfl bodyDfree67 : (bodyΘ.2.take 369).all (fun e => (PRE_first_tail_x15_r0_body.cws67 ++ PRE_first_tail_x15_r0_body.ws67).all fun w => e.noVar w) = true

theorem bodyStep67 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26873, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.S657)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26875, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s659 PRE_first_tail_x15_r0_body.S659) (27 + 1) :=
  bodySite bodyFacts67.cfix bodyFacts67.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st67.S2.tab) (Es := bodyEs67) (qs := bodyQs67)
    (ok := PRE_first_tail_x15_r0_body.st67.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site67 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts67
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site67 r hr) hi (MapOk.sub hm (sub_of_all bodySub67)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk67 r hr) hi hm ho hq)
    bodyLq67 rfl bodyNrLo67 (postSub_sound bodyPost67)
    (Nat.le_of_ble_eq_true bodyDrop67) (by decide) (Nat.le_of_ble_eq_true bodyDropH67) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN67) (by decide)
    bodyDv67 bodyDe67 bodyDl67 bodyDold67 bodyDfree67 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
