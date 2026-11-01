import host.sim.compose.a4b.vw15.VWBodyJ149
import host.sim.compose.a4b.vw15.VWBodySite149
import host.sim.compose.a4b.vw15.VWBodyOracles_37
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

theorem bodyCshift149 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1437.tab.length PRE_first_tail_x15_r0_body.s1437.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P149.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P149 6424 PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.s1439.ffi PRE_first_tail_x15_r0_body.s1438.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_149
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_149
  have hcl : SSt (· < 6424) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1437.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_149] <;> decide) PRE_first_tail_x15_r0_body.cnodesK149 PRE_first_tail_x15_r0_body.cobjsK149
      PRE_first_tail_x15_r0_body.citemsK149 PRE_first_tail_x15_r0_body.cbd149 PRE_first_tail_x15_r0_body.csst149
  exact PRE_first_tail_x15_r0_body.cshift149 bodyNcl149 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_149] at this; exact this)


kernel_rfl bodyFramesEmpty149 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1438 a).isEmpty) = true
kernel_rfl bodyJsRoots149 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1437.next) PRE_first_tail_x15_r0_body.s1439.trace PRE_first_tail_x15_r0_body.s1439 = true
kernel_rfl bodyJsNative149 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1439.ffi) = true
kernel_rfl bodyLow149 : (PRE_first_tail_x15_r0_body.cws149 ++ PRE_first_tail_x15_r0_body.ws149).all (Nat.ble 9) = true
kernel_rfl bodyCntM149 : countersOkB PRE_first_tail_x15_r0_body.s1437 PRE_first_tail_x15_r0_body.s1438 = true
kernel_rfl bodyHi149 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1439.ffi).next setupP.E = true
kernel_rfl bodyNhi149 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1439.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge149 : bridgeOf PRE_first_tail_x15_r0_body.s1438.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1437.ffi
kernel_rfl bodyNN149 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1437.ffi).nnext PRE_first_tail_x15_r0_body.P149.NL = true
kernel_rfl bodyXn149 : Nat.ble (⟨21128, 18229, 2791504, 6424⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1439.ffi).next = true
kernel_rfl bodyLo149 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1439.ffi).next = true
theorem bodyFacts149 : BodySiteFacts PRE_first_tail_x15_r0_body.s1437 PRE_first_tail_x15_r0_body.s1438 PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1437 PRE_first_tail_x15_r0_body.S1438 PRE_first_tail_x15_r0_body.S1439
    PRE_first_tail_x15_r0_body.ws149 PRE_first_tail_x15_r0_body.cws149 PRE_first_tail_x15_r0_body.nr149 PRE_first_tail_x15_r0_body.pl149 PRE_first_tail_x15_r0_body.cl149 2791523 6424 PRE_first_tail_x15_r0_body.kd149 PRE_first_tail_x15_r0_body.kappa149 PRE_first_tail_x15_r0_body.P149
    ⟨21128, 18229, 2791503, 6424⟩ ⟨21128, 18229, 2791504, 6424⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap149
  clean := bodyClean149
  cfix := PRE_first_tail_x15_r0_body.cfix149
  zpl := PRE_first_tail_x15_r0_body.zpl149
  zplnd := PRE_first_tail_x15_r0_body.zplnd149
  zn1 := PRE_first_tail_x15_r0_body.zn1149
  zfirst := PRE_first_tail_x15_r0_body.zfirst149
  zscn := PRE_first_tail_x15_r0_body.zscn149
  zsmn := PRE_first_tail_x15_r0_body.zsmn149
  zgrow := PRE_first_tail_x15_r0_body.zgrow149
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab149
  zfresh := PRE_first_tail_x15_r0_body.zfresh149
  zcnd := PRE_first_tail_x15_r0_body.zcnd149
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi149
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt149
  zgP := PRE_first_tail_x15_r0_body.zg149_2665
  zkP := PRE_first_tail_x15_r0_body.zk149_2665
  zmP := PRE_first_tail_x15_r0_body.zm149_2665
  zgC := PRE_first_tail_x15_r0_body.zg149_2673467
  zkC := PRE_first_tail_x15_r0_body.zk149_2673467
  zmC := PRE_first_tail_x15_r0_body.zm149_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw149_2673472
  zwV := PRE_first_tail_x15_r0_body.zw149_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap149
  zclbd := PRE_first_tail_x15_r0_body.zclbd149
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap149 PRE_first_tail_x15_r0_body.stFoot149 PRE_first_tail_x15_r0_body.iso149 PRE_first_tail_x15_r0_body.zwr149
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP149
  csupp := PRE_first_tail_x15_r0_body.csupp149
  cbound := PRE_first_tail_x15_r0_body.cbound149
  zimg := PRE_first_tail_x15_r0_body.zimg149
  zctl := PRE_first_tail_x15_r0_body.zctl149
  zstack := PRE_first_tail_x15_r0_body.zstack149
  zjobs := PRE_first_tail_x15_r0_body.zjobs149
  zstores := PRE_first_tail_x15_r0_body.zstores149
  zroots := PRE_first_tail_x15_r0_body.zroots149
  znC := PRE_first_tail_x15_r0_body.znC149
  ctab := PRE_first_tail_x15_r0_body.ctab149
  zbin := PRE_first_tail_x15_r0_body.zbin149
  cbridge := PRE_first_tail_x15_r0_body.cbridge149
  sbridge := bodyBridge149
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj149
  cshiftR := fun h hNL => bodyCshift149 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN149
  raised := PRE_first_tail_x15_r0_body.raised149
  cbigs := PRE_first_tail_x15_r0_body.cbigs149
  cjcl := PRE_first_tail_x15_r0_body.cjcl149
  xnLe := Nat.le_of_ble_eq_true bodyXn149
  loLe := Nat.le_of_ble_eq_true bodyLo149
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB149
  cntM := bodyCntM149
  hiLe := Nat.le_of_ble_eq_true bodyHi149
  nhiLe := Nat.le_of_ble_eq_true bodyNhi149
  jsHeap := bodyJs149
  jsRoots := bodyJsRoots149
  jsNative := bodyJsNative149
  framesEmpty := bodyFramesEmpty149
  trailOld := by decide
  lowVars := bodyLow149

def bodyQs149 : List (Option Q) := []
noncomputable def bodyEs149 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr149.map fun r => nth? PRE_first_tail_x15_r0_body.st149.S2.tab r
kernel_rfl bodyResChk149 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs149 bodyQs149) = true
kernel_rfl bodyLq149 : bodyQs149.length = PRE_first_tail_x15_r0_body.cws149.length
kernel_rfl bodyNrLo149 : PRE_first_tail_x15_r0_body.nr149.all (Nat.ble PRE_first_tail_x15_r0_body.S1437.tab.length) = true
kernel_rfl bodySub149 : (Oracles.PRE_first_tail_x15_r0_body.map_site149.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost149 : postSubB bodyM PRE_first_tail_x15_r0_body.ws149 PRE_first_tail_x15_r0_body.cws149 bodyQs149 = true
kernel_rfl bodyDrop149 : Nat.ble (52701 + (PRE_first_tail_x15_r0_body.s1438.next - PRE_first_tail_x15_r0_body.s1439.next)) 52720 = true
kernel_rfl bodyDropH149 : Nat.ble (995 + ((mlxOf PRE_first_tail_x15_r0_body.s1438.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1439.ffi).next)) 995 = true
kernel_rfl bodyDropN149 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1438.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1439.ffi).nnext)) 0 = true
kernel_rfl bodyDv149 : bodyΘ.1.take 792 = bodyΘ.1.take 792 ++ PRE_first_tail_x15_r0_body.cws149
kernel_rfl bodyDe149 : bodyΘ.2.take 792 = bodyΘ.2.take 792 ++ PRE_first_tail_x15_r0_body.nr149.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st149.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 792) (bodyΘ.2.take 792)))
kernel_rfl bodyDl149 : (bodyΘ.1.take 792).length = (bodyΘ.2.take 792).length
kernel_rfl bodyDold149 : (bodyΘ.1.take 792).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws149).isNone && !PRE_first_tail_x15_r0_body.ws149.contains v) = true
kernel_rfl bodyDfree149 : (bodyΘ.2.take 792).all (fun e => (PRE_first_tail_x15_r0_body.cws149 ++ PRE_first_tail_x15_r0_body.ws149).all fun w => e.noVar w) = true

theorem bodyStep149 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨52701, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1437 PRE_first_tail_x15_r0_body.S1437)
      (bodyCut NB T tk π i x0 bodyΘ ⟨52720, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.S1439) (206 + 1) :=
  bodySite bodyFacts149.cfix bodyFacts149.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st149.S2.tab) (Es := bodyEs149) (qs := bodyQs149)
    (ok := PRE_first_tail_x15_r0_body.st149.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site149 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts149
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site149 r hr) hi (MapOk.sub hm (sub_of_all bodySub149)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk149 r hr) hi hm ho hq)
    bodyLq149 rfl bodyNrLo149 (postSub_sound bodyPost149)
    (Nat.le_of_ble_eq_true bodyDrop149) (by decide) (Nat.le_of_ble_eq_true bodyDropH149) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN149) (by decide)
    bodyDv149 bodyDe149 bodyDl149 bodyDold149 bodyDfree149 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
