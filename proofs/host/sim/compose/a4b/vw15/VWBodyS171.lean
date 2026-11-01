import host.sim.compose.a4b.vw15.VWBodyJ171
import host.sim.compose.a4b.vw15.VWBodySite171
import host.sim.compose.a4b.vw15.VWBodyOracles_42
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift171 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1655.tab.length PRE_first_tail_x15_r0_body.s1655.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P171.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P171 7412 PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.s1657.ffi PRE_first_tail_x15_r0_body.s1656.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_171
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_171
  have hcl : SSt (· < 7412) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1655.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_171] <;> decide) PRE_first_tail_x15_r0_body.cnodesK171 PRE_first_tail_x15_r0_body.cobjsK171
      PRE_first_tail_x15_r0_body.citemsK171 PRE_first_tail_x15_r0_body.cbd171 PRE_first_tail_x15_r0_body.csst171
  exact PRE_first_tail_x15_r0_body.cshift171 bodyNcl171 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_171] at this; exact this)


kernel_rfl bodyFramesEmpty171 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1656 a).isEmpty) = true
kernel_rfl bodyJsRoots171 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1655.next) PRE_first_tail_x15_r0_body.s1657.trace PRE_first_tail_x15_r0_body.s1657 = true
kernel_rfl bodyJsNative171 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1657.ffi) = true
kernel_rfl bodyLow171 : (PRE_first_tail_x15_r0_body.cws171 ++ PRE_first_tail_x15_r0_body.ws171).all (Nat.ble 9) = true
kernel_rfl bodyCntM171 : countersOkB PRE_first_tail_x15_r0_body.s1655 PRE_first_tail_x15_r0_body.s1656 = true
kernel_rfl bodyHi171 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1657.ffi).next setupP.E = true
kernel_rfl bodyNhi171 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1657.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge171 : bridgeOf PRE_first_tail_x15_r0_body.s1656.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1655.ffi
kernel_rfl bodyNN171 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1655.ffi).nnext PRE_first_tail_x15_r0_body.P171.NL = true
kernel_rfl bodyXn171 : Nat.ble (⟨21580, 18686, 2809565, 7412⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1657.ffi).next = true
kernel_rfl bodyLo171 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1657.ffi).next = true
theorem bodyFacts171 : BodySiteFacts PRE_first_tail_x15_r0_body.s1655 PRE_first_tail_x15_r0_body.s1656 PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1655 PRE_first_tail_x15_r0_body.S1656 PRE_first_tail_x15_r0_body.S1657
    PRE_first_tail_x15_r0_body.ws171 PRE_first_tail_x15_r0_body.cws171 PRE_first_tail_x15_r0_body.nr171 PRE_first_tail_x15_r0_body.pl171 PRE_first_tail_x15_r0_body.cl171 2810714 7412 PRE_first_tail_x15_r0_body.kd171 PRE_first_tail_x15_r0_body.kappa171 PRE_first_tail_x15_r0_body.P171
    ⟨21577, 18659, 2809559, 7394⟩ ⟨21580, 18686, 2809565, 7412⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap171
  clean := bodyClean171
  cfix := PRE_first_tail_x15_r0_body.cfix171
  zpl := PRE_first_tail_x15_r0_body.zpl171
  zplnd := PRE_first_tail_x15_r0_body.zplnd171
  zn1 := PRE_first_tail_x15_r0_body.zn1171
  zfirst := PRE_first_tail_x15_r0_body.zfirst171
  zscn := PRE_first_tail_x15_r0_body.zscn171
  zsmn := PRE_first_tail_x15_r0_body.zsmn171
  zgrow := PRE_first_tail_x15_r0_body.zgrow171
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab171
  zfresh := PRE_first_tail_x15_r0_body.zfresh171
  zcnd := PRE_first_tail_x15_r0_body.zcnd171
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi171
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt171
  zgP := PRE_first_tail_x15_r0_body.zg171_2665
  zkP := PRE_first_tail_x15_r0_body.zk171_2665
  zmP := PRE_first_tail_x15_r0_body.zm171_2665
  zgC := PRE_first_tail_x15_r0_body.zg171_2673467
  zkC := PRE_first_tail_x15_r0_body.zk171_2673467
  zmC := PRE_first_tail_x15_r0_body.zm171_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw171_2673472
  zwV := PRE_first_tail_x15_r0_body.zw171_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap171
  zclbd := PRE_first_tail_x15_r0_body.zclbd171
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap171 PRE_first_tail_x15_r0_body.stFoot171 PRE_first_tail_x15_r0_body.iso171 PRE_first_tail_x15_r0_body.zwr171
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP171
  csupp := PRE_first_tail_x15_r0_body.csupp171
  cbound := PRE_first_tail_x15_r0_body.cbound171
  zimg := PRE_first_tail_x15_r0_body.zimg171
  zctl := PRE_first_tail_x15_r0_body.zctl171
  zstack := PRE_first_tail_x15_r0_body.zstack171
  zjobs := PRE_first_tail_x15_r0_body.zjobs171
  zstores := PRE_first_tail_x15_r0_body.zstores171
  zroots := PRE_first_tail_x15_r0_body.zroots171
  znC := PRE_first_tail_x15_r0_body.znC171
  ctab := PRE_first_tail_x15_r0_body.ctab171
  zbin := PRE_first_tail_x15_r0_body.zbin171
  cbridge := PRE_first_tail_x15_r0_body.cbridge171
  sbridge := bodyBridge171
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj171
  cshiftR := fun h hNL => bodyCshift171 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN171
  raised := PRE_first_tail_x15_r0_body.raised171
  cbigs := PRE_first_tail_x15_r0_body.cbigs171
  cjcl := PRE_first_tail_x15_r0_body.cjcl171
  xnLe := Nat.le_of_ble_eq_true bodyXn171
  loLe := Nat.le_of_ble_eq_true bodyLo171
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB171
  cntM := bodyCntM171
  hiLe := Nat.le_of_ble_eq_true bodyHi171
  nhiLe := Nat.le_of_ble_eq_true bodyNhi171
  jsHeap := bodyJs171
  jsRoots := bodyJsRoots171
  jsNative := bodyJsNative171
  framesEmpty := bodyFramesEmpty171
  trailOld := by decide
  lowVars := bodyLow171

def bodyQs171 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs171 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr171.map fun r => nth? PRE_first_tail_x15_r0_body.st171.S5.tab r
kernel_rfl bodyResChk171 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs171 bodyQs171) = true
kernel_rfl bodyLq171 : bodyQs171.length = PRE_first_tail_x15_r0_body.cws171.length
kernel_rfl bodyNrLo171 : PRE_first_tail_x15_r0_body.nr171.all (Nat.ble PRE_first_tail_x15_r0_body.S1655.tab.length) = true
kernel_rfl bodySub171 : (Oracles.PRE_first_tail_x15_r0_body.map_site171.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost171 : postSubB bodyM PRE_first_tail_x15_r0_body.ws171 PRE_first_tail_x15_r0_body.cws171 bodyQs171 = true
kernel_rfl bodyDrop171 : Nat.ble (59276 + (PRE_first_tail_x15_r0_body.s1656.next - PRE_first_tail_x15_r0_body.s1657.next)) 60425 = true
kernel_rfl bodyDropH171 : Nat.ble (1124 + ((mlxOf PRE_first_tail_x15_r0_body.s1656.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1657.ffi).next)) 1149 = true
kernel_rfl bodyDropN171 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1656.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1657.ffi).nnext)) 0 = true
kernel_rfl bodyDv171 : bodyΘ.1.take 918 = bodyΘ.1.take 900 ++ PRE_first_tail_x15_r0_body.cws171
kernel_rfl bodyDe171 : bodyΘ.2.take 918 = bodyΘ.2.take 900 ++ PRE_first_tail_x15_r0_body.nr171.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st171.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 900) (bodyΘ.2.take 900)))
kernel_rfl bodyDl171 : (bodyΘ.1.take 900).length = (bodyΘ.2.take 900).length
kernel_rfl bodyDold171 : (bodyΘ.1.take 900).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws171).isNone && !PRE_first_tail_x15_r0_body.ws171.contains v) = true
kernel_rfl bodyDfree171 : (bodyΘ.2.take 918).all (fun e => (PRE_first_tail_x15_r0_body.cws171 ++ PRE_first_tail_x15_r0_body.ws171).all fun w => e.noVar w) = true

theorem bodyStep171 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59276, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1655 PRE_first_tail_x15_r0_body.S1655)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60425, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.S1657) (11334 + 1) :=
  bodySite bodyFacts171.cfix bodyFacts171.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st171.S5.tab) (Es := bodyEs171) (qs := bodyQs171)
    (ok := PRE_first_tail_x15_r0_body.st171.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site171 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts171
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site171 r hr) hi (MapOk.sub hm (sub_of_all bodySub171)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk171 r hr) hi hm ho hq)
    bodyLq171 rfl bodyNrLo171 (postSub_sound bodyPost171)
    (Nat.le_of_ble_eq_true bodyDrop171) (by decide) (Nat.le_of_ble_eq_true bodyDropH171) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN171) (by decide)
    bodyDv171 bodyDe171 bodyDl171 bodyDold171 bodyDfree171 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
