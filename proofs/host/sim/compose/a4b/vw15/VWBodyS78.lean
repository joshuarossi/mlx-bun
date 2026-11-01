import host.sim.compose.a4b.vw15.VWBodyJ78
import host.sim.compose.a4b.vw15.VWBodySite78
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

theorem bodyCshift78 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S764.tab.length PRE_first_tail_x15_r0_body.s764.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P78.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P78 3437 PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.s766.ffi PRE_first_tail_x15_r0_body.s765.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_78
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_78
  have hcl : SSt (· < 3437) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s766.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S764.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_78] <;> decide) PRE_first_tail_x15_r0_body.cnodesK78 PRE_first_tail_x15_r0_body.cobjsK78
      PRE_first_tail_x15_r0_body.citemsK78 PRE_first_tail_x15_r0_body.cbd78 PRE_first_tail_x15_r0_body.csst78
  exact PRE_first_tail_x15_r0_body.cshift78 bodyNcl78 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_78] at this; exact this)


kernel_rfl bodyFramesEmpty78 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s765 a).isEmpty) = true
kernel_rfl bodyJsRoots78 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s764.next) PRE_first_tail_x15_r0_body.s766.trace PRE_first_tail_x15_r0_body.s766 = true
kernel_rfl bodyJsNative78 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s766.ffi) = true
kernel_rfl bodyLow78 : (PRE_first_tail_x15_r0_body.cws78 ++ PRE_first_tail_x15_r0_body.ws78).all (Nat.ble 9) = true
kernel_rfl bodyCntM78 : countersOkB PRE_first_tail_x15_r0_body.s764 PRE_first_tail_x15_r0_body.s765 = true
kernel_rfl bodyHi78 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s766.ffi).next setupP.E = true
kernel_rfl bodyNhi78 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s766.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge78 : bridgeOf PRE_first_tail_x15_r0_body.s765.ffi = bridgeOf PRE_first_tail_x15_r0_body.s764.ffi
kernel_rfl bodyNN78 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s764.ffi).nnext PRE_first_tail_x15_r0_body.P78.NL = true
kernel_rfl bodyXn78 : Nat.ble (⟨19749, 16853, 2736477, 3437⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s766.ffi).next = true
kernel_rfl bodyLo78 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s766.ffi).next = true
theorem bodyFacts78 : BodySiteFacts PRE_first_tail_x15_r0_body.s764 PRE_first_tail_x15_r0_body.s765 PRE_first_tail_x15_r0_body.s766 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S764 PRE_first_tail_x15_r0_body.S765 PRE_first_tail_x15_r0_body.S766
    PRE_first_tail_x15_r0_body.ws78 PRE_first_tail_x15_r0_body.cws78 PRE_first_tail_x15_r0_body.nr78 PRE_first_tail_x15_r0_body.pl78 PRE_first_tail_x15_r0_body.cl78 2737626 3437 PRE_first_tail_x15_r0_body.kd78 PRE_first_tail_x15_r0_body.kappa78 PRE_first_tail_x15_r0_body.P78
    ⟨19746, 16826, 2736471, 3419⟩ ⟨19749, 16853, 2736477, 3437⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap78
  clean := bodyClean78
  cfix := PRE_first_tail_x15_r0_body.cfix78
  zpl := PRE_first_tail_x15_r0_body.zpl78
  zplnd := PRE_first_tail_x15_r0_body.zplnd78
  zn1 := PRE_first_tail_x15_r0_body.zn178
  zfirst := PRE_first_tail_x15_r0_body.zfirst78
  zscn := PRE_first_tail_x15_r0_body.zscn78
  zsmn := PRE_first_tail_x15_r0_body.zsmn78
  zgrow := PRE_first_tail_x15_r0_body.zgrow78
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab78
  zfresh := PRE_first_tail_x15_r0_body.zfresh78
  zcnd := PRE_first_tail_x15_r0_body.zcnd78
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi78
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt78
  zgP := PRE_first_tail_x15_r0_body.zg78_2665
  zkP := PRE_first_tail_x15_r0_body.zk78_2665
  zmP := PRE_first_tail_x15_r0_body.zm78_2665
  zgC := PRE_first_tail_x15_r0_body.zg78_2673467
  zkC := PRE_first_tail_x15_r0_body.zk78_2673467
  zmC := PRE_first_tail_x15_r0_body.zm78_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw78_2673472
  zwV := PRE_first_tail_x15_r0_body.zw78_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap78
  zclbd := PRE_first_tail_x15_r0_body.zclbd78
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap78 PRE_first_tail_x15_r0_body.stFoot78 PRE_first_tail_x15_r0_body.iso78 PRE_first_tail_x15_r0_body.zwr78
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP78
  csupp := PRE_first_tail_x15_r0_body.csupp78
  cbound := PRE_first_tail_x15_r0_body.cbound78
  zimg := PRE_first_tail_x15_r0_body.zimg78
  zctl := PRE_first_tail_x15_r0_body.zctl78
  zstack := PRE_first_tail_x15_r0_body.zstack78
  zjobs := PRE_first_tail_x15_r0_body.zjobs78
  zstores := PRE_first_tail_x15_r0_body.zstores78
  zroots := PRE_first_tail_x15_r0_body.zroots78
  znC := PRE_first_tail_x15_r0_body.znC78
  ctab := PRE_first_tail_x15_r0_body.ctab78
  zbin := PRE_first_tail_x15_r0_body.zbin78
  cbridge := PRE_first_tail_x15_r0_body.cbridge78
  sbridge := bodyBridge78
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj78
  cshiftR := fun h hNL => bodyCshift78 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN78
  raised := PRE_first_tail_x15_r0_body.raised78
  cbigs := PRE_first_tail_x15_r0_body.cbigs78
  cjcl := PRE_first_tail_x15_r0_body.cjcl78
  xnLe := Nat.le_of_ble_eq_true bodyXn78
  loLe := Nat.le_of_ble_eq_true bodyLo78
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB78
  cntM := bodyCntM78
  hiLe := Nat.le_of_ble_eq_true bodyHi78
  nhiLe := Nat.le_of_ble_eq_true bodyNhi78
  jsHeap := bodyJs78
  jsRoots := bodyJsRoots78
  jsNative := bodyJsNative78
  framesEmpty := bodyFramesEmpty78
  trailOld := by decide
  lowVars := bodyLow78

def bodyQs78 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs78 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr78.map fun r => nth? PRE_first_tail_x15_r0_body.st78.S5.tab r
kernel_rfl bodyResChk78 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs78 bodyQs78) = true
kernel_rfl bodyLq78 : bodyQs78.length = PRE_first_tail_x15_r0_body.cws78.length
kernel_rfl bodyNrLo78 : PRE_first_tail_x15_r0_body.nr78.all (Nat.ble PRE_first_tail_x15_r0_body.S764.tab.length) = true
kernel_rfl bodySub78 : (Oracles.PRE_first_tail_x15_r0_body.map_site78.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost78 : postSubB bodyM PRE_first_tail_x15_r0_body.ws78 PRE_first_tail_x15_r0_body.cws78 bodyQs78 = true
kernel_rfl bodyDrop78 : Nat.ble (29569 + (PRE_first_tail_x15_r0_body.s765.next - PRE_first_tail_x15_r0_body.s766.next)) 30718 = true
kernel_rfl bodyDropH78 : Nat.ble (533 + ((mlxOf PRE_first_tail_x15_r0_body.s765.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s766.ffi).next)) 558 = true
kernel_rfl bodyDropN78 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s765.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s766.ffi).nnext)) 0 = true
kernel_rfl bodyDv78 : bodyΘ.1.take 432 = bodyΘ.1.take 414 ++ PRE_first_tail_x15_r0_body.cws78
kernel_rfl bodyDe78 : bodyΘ.2.take 432 = bodyΘ.2.take 414 ++ PRE_first_tail_x15_r0_body.nr78.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st78.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 414) (bodyΘ.2.take 414)))
kernel_rfl bodyDl78 : (bodyΘ.1.take 414).length = (bodyΘ.2.take 414).length
kernel_rfl bodyDold78 : (bodyΘ.1.take 414).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws78).isNone && !PRE_first_tail_x15_r0_body.ws78.contains v) = true
kernel_rfl bodyDfree78 : (bodyΘ.2.take 432).all (fun e => (PRE_first_tail_x15_r0_body.cws78 ++ PRE_first_tail_x15_r0_body.ws78).all fun w => e.noVar w) = true

theorem bodyStep78 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29569, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s764 PRE_first_tail_x15_r0_body.S764)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30718, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s766 PRE_first_tail_x15_r0_body.S766) (11334 + 1) :=
  bodySite bodyFacts78.cfix bodyFacts78.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st78.S5.tab) (Es := bodyEs78) (qs := bodyQs78)
    (ok := PRE_first_tail_x15_r0_body.st78.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site78 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts78
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site78 r hr) hi (MapOk.sub hm (sub_of_all bodySub78)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk78 r hr) hi hm ho hq)
    bodyLq78 rfl bodyNrLo78 (postSub_sound bodyPost78)
    (Nat.le_of_ble_eq_true bodyDrop78) (by decide) (Nat.le_of_ble_eq_true bodyDropH78) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN78) (by decide)
    bodyDv78 bodyDe78 bodyDl78 bodyDold78 bodyDfree78 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
