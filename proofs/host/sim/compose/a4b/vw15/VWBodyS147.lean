import host.sim.compose.a4b.vw15.VWBodyJ147
import host.sim.compose.a4b.vw15.VWBodySite147
import host.sim.compose.a4b.vw15.VWBodyOracles_36
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift147 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1425.tab.length PRE_first_tail_x15_r0_body.s1425.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P147.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P147 6386 PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.s1427.ffi PRE_first_tail_x15_r0_body.s1426.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_147
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_147
  have hcl : SSt (· < 6386) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1425.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_147] <;> decide) PRE_first_tail_x15_r0_body.cnodesK147 PRE_first_tail_x15_r0_body.cobjsK147
      PRE_first_tail_x15_r0_body.citemsK147 PRE_first_tail_x15_r0_body.cbd147 PRE_first_tail_x15_r0_body.csst147
  exact PRE_first_tail_x15_r0_body.cshift147 bodyNcl147 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_147] at this; exact this)


kernel_rfl bodyFramesEmpty147 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1426 a).isEmpty) = true
kernel_rfl bodyJsRoots147 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1425.next) PRE_first_tail_x15_r0_body.s1427.trace PRE_first_tail_x15_r0_body.s1427 = true
kernel_rfl bodyJsNative147 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1427.ffi) = true
kernel_rfl bodyLow147 : (PRE_first_tail_x15_r0_body.cws147 ++ PRE_first_tail_x15_r0_body.ws147).all (Nat.ble 9) = true
kernel_rfl bodyCntM147 : countersOkB PRE_first_tail_x15_r0_body.s1425 PRE_first_tail_x15_r0_body.s1426 = true
kernel_rfl bodyHi147 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1427.ffi).next setupP.E = true
kernel_rfl bodyNhi147 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1427.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge147 : bridgeOf PRE_first_tail_x15_r0_body.s1426.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1425.ffi
kernel_rfl bodyNN147 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1425.ffi).nnext PRE_first_tail_x15_r0_body.P147.NL = true
kernel_rfl bodyXn147 : Nat.ble (⟨21108, 18212, 2790725, 6386⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1427.ffi).next = true
kernel_rfl bodyLo147 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1427.ffi).next = true
theorem bodyFacts147 : BodySiteFacts PRE_first_tail_x15_r0_body.s1425 PRE_first_tail_x15_r0_body.s1426 PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1425 PRE_first_tail_x15_r0_body.S1426 PRE_first_tail_x15_r0_body.S1427
    PRE_first_tail_x15_r0_body.ws147 PRE_first_tail_x15_r0_body.cws147 PRE_first_tail_x15_r0_body.nr147 PRE_first_tail_x15_r0_body.pl147 PRE_first_tail_x15_r0_body.cl147 2791874 6386 PRE_first_tail_x15_r0_body.kd147 PRE_first_tail_x15_r0_body.kappa147 PRE_first_tail_x15_r0_body.P147
    ⟨21105, 18185, 2790719, 6368⟩ ⟨21108, 18212, 2790725, 6386⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap147
  clean := bodyClean147
  cfix := PRE_first_tail_x15_r0_body.cfix147
  zpl := PRE_first_tail_x15_r0_body.zpl147
  zplnd := PRE_first_tail_x15_r0_body.zplnd147
  zn1 := PRE_first_tail_x15_r0_body.zn1147
  zfirst := PRE_first_tail_x15_r0_body.zfirst147
  zscn := PRE_first_tail_x15_r0_body.zscn147
  zsmn := PRE_first_tail_x15_r0_body.zsmn147
  zgrow := PRE_first_tail_x15_r0_body.zgrow147
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab147
  zfresh := PRE_first_tail_x15_r0_body.zfresh147
  zcnd := PRE_first_tail_x15_r0_body.zcnd147
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi147
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt147
  zgP := PRE_first_tail_x15_r0_body.zg147_2665
  zkP := PRE_first_tail_x15_r0_body.zk147_2665
  zmP := PRE_first_tail_x15_r0_body.zm147_2665
  zgC := PRE_first_tail_x15_r0_body.zg147_2673467
  zkC := PRE_first_tail_x15_r0_body.zk147_2673467
  zmC := PRE_first_tail_x15_r0_body.zm147_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw147_2673472
  zwV := PRE_first_tail_x15_r0_body.zw147_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap147
  zclbd := PRE_first_tail_x15_r0_body.zclbd147
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap147 PRE_first_tail_x15_r0_body.stFoot147 PRE_first_tail_x15_r0_body.iso147 PRE_first_tail_x15_r0_body.zwr147
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP147
  csupp := PRE_first_tail_x15_r0_body.csupp147
  cbound := PRE_first_tail_x15_r0_body.cbound147
  zimg := PRE_first_tail_x15_r0_body.zimg147
  zctl := PRE_first_tail_x15_r0_body.zctl147
  zstack := PRE_first_tail_x15_r0_body.zstack147
  zjobs := PRE_first_tail_x15_r0_body.zjobs147
  zstores := PRE_first_tail_x15_r0_body.zstores147
  zroots := PRE_first_tail_x15_r0_body.zroots147
  znC := PRE_first_tail_x15_r0_body.znC147
  ctab := PRE_first_tail_x15_r0_body.ctab147
  zbin := PRE_first_tail_x15_r0_body.zbin147
  cbridge := PRE_first_tail_x15_r0_body.cbridge147
  sbridge := bodyBridge147
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj147
  cshiftR := fun h hNL => bodyCshift147 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN147
  raised := PRE_first_tail_x15_r0_body.raised147
  cbigs := PRE_first_tail_x15_r0_body.cbigs147
  cjcl := PRE_first_tail_x15_r0_body.cjcl147
  xnLe := Nat.le_of_ble_eq_true bodyXn147
  loLe := Nat.le_of_ble_eq_true bodyLo147
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB147
  cntM := bodyCntM147
  hiLe := Nat.le_of_ble_eq_true bodyHi147
  nhiLe := Nat.le_of_ble_eq_true bodyNhi147
  jsHeap := bodyJs147
  jsRoots := bodyJsRoots147
  jsNative := bodyJsNative147
  framesEmpty := bodyFramesEmpty147
  trailOld := by decide
  lowVars := bodyLow147

def bodyQs147 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs147 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr147.map fun r => nth? PRE_first_tail_x15_r0_body.st147.S5.tab r
kernel_rfl bodyResChk147 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs147 bodyQs147) = true
kernel_rfl bodyLq147 : bodyQs147.length = PRE_first_tail_x15_r0_body.cws147.length
kernel_rfl bodyNrLo147 : PRE_first_tail_x15_r0_body.nr147.all (Nat.ble PRE_first_tail_x15_r0_body.S1425.tab.length) = true
kernel_rfl bodySub147 : (Oracles.PRE_first_tail_x15_r0_body.map_site147.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost147 : postSubB bodyM PRE_first_tail_x15_r0_body.ws147 PRE_first_tail_x15_r0_body.cws147 bodyQs147 = true
kernel_rfl bodyDrop147 : Nat.ble (51550 + (PRE_first_tail_x15_r0_body.s1426.next - PRE_first_tail_x15_r0_body.s1427.next)) 52699 = true
kernel_rfl bodyDropH147 : Nat.ble (970 + ((mlxOf PRE_first_tail_x15_r0_body.s1426.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1427.ffi).next)) 995 = true
kernel_rfl bodyDropN147 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1426.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1427.ffi).nnext)) 0 = true
kernel_rfl bodyDv147 : bodyΘ.1.take 792 = bodyΘ.1.take 774 ++ PRE_first_tail_x15_r0_body.cws147
kernel_rfl bodyDe147 : bodyΘ.2.take 792 = bodyΘ.2.take 774 ++ PRE_first_tail_x15_r0_body.nr147.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st147.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 774) (bodyΘ.2.take 774)))
kernel_rfl bodyDl147 : (bodyΘ.1.take 774).length = (bodyΘ.2.take 774).length
kernel_rfl bodyDold147 : (bodyΘ.1.take 774).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws147).isNone && !PRE_first_tail_x15_r0_body.ws147.contains v) = true
kernel_rfl bodyDfree147 : (bodyΘ.2.take 792).all (fun e => (PRE_first_tail_x15_r0_body.cws147 ++ PRE_first_tail_x15_r0_body.ws147).all fun w => e.noVar w) = true

theorem bodyStep147 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51550, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1425 PRE_first_tail_x15_r0_body.S1425)
      (bodyCut NB T tk π i x0 bodyΘ ⟨52699, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.S1427) (11334 + 1) :=
  bodySite bodyFacts147.cfix bodyFacts147.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st147.S5.tab) (Es := bodyEs147) (qs := bodyQs147)
    (ok := PRE_first_tail_x15_r0_body.st147.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site147 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts147
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site147 r hr) hi (MapOk.sub hm (sub_of_all bodySub147)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk147 r hr) hi hm ho hq)
    bodyLq147 rfl bodyNrLo147 (postSub_sound bodyPost147)
    (Nat.le_of_ble_eq_true bodyDrop147) (by decide) (Nat.le_of_ble_eq_true bodyDropH147) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN147) (by decide)
    bodyDv147 bodyDe147 bodyDl147 bodyDold147 bodyDfree147 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
