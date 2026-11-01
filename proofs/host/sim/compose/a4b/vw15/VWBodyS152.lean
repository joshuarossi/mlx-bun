import host.sim.compose.a4b.vw15.VWBodyJ152
import host.sim.compose.a4b.vw15.VWBodySite152
import host.sim.compose.a4b.vw15.VWBodyOracles_38
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

theorem bodyCshift152 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1466.tab.length PRE_first_tail_x15_r0_body.s1466.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P152.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P152 6553 PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.s1468.ffi PRE_first_tail_x15_r0_body.s1467.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_152
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_152
  have hcl : SSt (· < 6553) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1468.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1466.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_152] <;> decide) PRE_first_tail_x15_r0_body.cnodesK152 PRE_first_tail_x15_r0_body.cobjsK152
      PRE_first_tail_x15_r0_body.citemsK152 PRE_first_tail_x15_r0_body.cbd152 PRE_first_tail_x15_r0_body.csst152
  exact PRE_first_tail_x15_r0_body.cshift152 bodyNcl152 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_152] at this; exact this)


kernel_rfl bodyFramesEmpty152 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1467 a).isEmpty) = true
kernel_rfl bodyJsRoots152 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1466.next) PRE_first_tail_x15_r0_body.s1468.trace PRE_first_tail_x15_r0_body.s1468 = true
kernel_rfl bodyJsNative152 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1468.ffi) = true
kernel_rfl bodyLow152 : (PRE_first_tail_x15_r0_body.cws152 ++ PRE_first_tail_x15_r0_body.ws152).all (Nat.ble 9) = true
kernel_rfl bodyCntM152 : countersOkB PRE_first_tail_x15_r0_body.s1466 PRE_first_tail_x15_r0_body.s1467 = true
kernel_rfl bodyHi152 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1468.ffi).next setupP.E = true
kernel_rfl bodyNhi152 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1468.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge152 : bridgeOf PRE_first_tail_x15_r0_body.s1467.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1466.ffi
kernel_rfl bodyNN152 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1466.ffi).nnext PRE_first_tail_x15_r0_body.P152.NL = true
kernel_rfl bodyXn152 : Nat.ble (⟨21185, 18292, 2793764, 6553⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1468.ffi).next = true
kernel_rfl bodyLo152 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1468.ffi).next = true
theorem bodyFacts152 : BodySiteFacts PRE_first_tail_x15_r0_body.s1466 PRE_first_tail_x15_r0_body.s1467 PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1466 PRE_first_tail_x15_r0_body.S1467 PRE_first_tail_x15_r0_body.S1468
    PRE_first_tail_x15_r0_body.ws152 PRE_first_tail_x15_r0_body.cws152 PRE_first_tail_x15_r0_body.nr152 PRE_first_tail_x15_r0_body.pl152 PRE_first_tail_x15_r0_body.cl152 2793774 6553 PRE_first_tail_x15_r0_body.kd152 PRE_first_tail_x15_r0_body.kappa152 PRE_first_tail_x15_r0_body.P152
    ⟨21185, 18292, 2793763, 6553⟩ ⟨21185, 18292, 2793764, 6553⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap152
  clean := bodyClean152
  cfix := PRE_first_tail_x15_r0_body.cfix152
  zpl := PRE_first_tail_x15_r0_body.zpl152
  zplnd := PRE_first_tail_x15_r0_body.zplnd152
  zn1 := PRE_first_tail_x15_r0_body.zn1152
  zfirst := PRE_first_tail_x15_r0_body.zfirst152
  zscn := PRE_first_tail_x15_r0_body.zscn152
  zsmn := PRE_first_tail_x15_r0_body.zsmn152
  zgrow := PRE_first_tail_x15_r0_body.zgrow152
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab152
  zfresh := PRE_first_tail_x15_r0_body.zfresh152
  zcnd := PRE_first_tail_x15_r0_body.zcnd152
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi152
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt152
  zgP := PRE_first_tail_x15_r0_body.zg152_2665
  zkP := PRE_first_tail_x15_r0_body.zk152_2665
  zmP := PRE_first_tail_x15_r0_body.zm152_2665
  zgC := PRE_first_tail_x15_r0_body.zg152_2673467
  zkC := PRE_first_tail_x15_r0_body.zk152_2673467
  zmC := PRE_first_tail_x15_r0_body.zm152_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw152_2673472
  zwV := PRE_first_tail_x15_r0_body.zw152_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap152
  zclbd := PRE_first_tail_x15_r0_body.zclbd152
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap152 PRE_first_tail_x15_r0_body.stFoot152 PRE_first_tail_x15_r0_body.iso152 PRE_first_tail_x15_r0_body.zwr152
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP152
  csupp := PRE_first_tail_x15_r0_body.csupp152
  cbound := PRE_first_tail_x15_r0_body.cbound152
  zimg := PRE_first_tail_x15_r0_body.zimg152
  zctl := PRE_first_tail_x15_r0_body.zctl152
  zstack := PRE_first_tail_x15_r0_body.zstack152
  zjobs := PRE_first_tail_x15_r0_body.zjobs152
  zstores := PRE_first_tail_x15_r0_body.zstores152
  zroots := PRE_first_tail_x15_r0_body.zroots152
  znC := PRE_first_tail_x15_r0_body.znC152
  ctab := PRE_first_tail_x15_r0_body.ctab152
  zbin := PRE_first_tail_x15_r0_body.zbin152
  cbridge := PRE_first_tail_x15_r0_body.cbridge152
  sbridge := bodyBridge152
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj152
  cshiftR := fun h hNL => bodyCshift152 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN152
  raised := PRE_first_tail_x15_r0_body.raised152
  cbigs := PRE_first_tail_x15_r0_body.cbigs152
  cjcl := PRE_first_tail_x15_r0_body.cjcl152
  xnLe := Nat.le_of_ble_eq_true bodyXn152
  loLe := Nat.le_of_ble_eq_true bodyLo152
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB152
  cntM := bodyCntM152
  hiLe := Nat.le_of_ble_eq_true bodyHi152
  nhiLe := Nat.le_of_ble_eq_true bodyNhi152
  jsHeap := bodyJs152
  jsRoots := bodyJsRoots152
  jsNative := bodyJsNative152
  framesEmpty := bodyFramesEmpty152
  trailOld := by decide
  lowVars := bodyLow152

def bodyQs152 : List (Option Q) := []
noncomputable def bodyEs152 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr152.map fun r => nth? PRE_first_tail_x15_r0_body.st152.S2.tab r
kernel_rfl bodyResChk152 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs152 bodyQs152) = true
kernel_rfl bodyLq152 : bodyQs152.length = PRE_first_tail_x15_r0_body.cws152.length
kernel_rfl bodyNrLo152 : PRE_first_tail_x15_r0_body.nr152.all (Nat.ble PRE_first_tail_x15_r0_body.S1466.tab.length) = true
kernel_rfl bodySub152 : (Oracles.PRE_first_tail_x15_r0_body.map_site152.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost152 : postSubB bodyM PRE_first_tail_x15_r0_body.ws152 PRE_first_tail_x15_r0_body.cws152 bodyQs152 = true
kernel_rfl bodyDrop152 : Nat.ble (53871 + (PRE_first_tail_x15_r0_body.s1467.next - PRE_first_tail_x15_r0_body.s1468.next)) 53881 = true
kernel_rfl bodyDropH152 : Nat.ble (1020 + ((mlxOf PRE_first_tail_x15_r0_body.s1467.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1468.ffi).next)) 1020 = true
kernel_rfl bodyDropN152 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1467.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1468.ffi).nnext)) 0 = true
kernel_rfl bodyDv152 : bodyΘ.1.take 810 = bodyΘ.1.take 810 ++ PRE_first_tail_x15_r0_body.cws152
kernel_rfl bodyDe152 : bodyΘ.2.take 810 = bodyΘ.2.take 810 ++ PRE_first_tail_x15_r0_body.nr152.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st152.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 810) (bodyΘ.2.take 810)))
kernel_rfl bodyDl152 : (bodyΘ.1.take 810).length = (bodyΘ.2.take 810).length
kernel_rfl bodyDold152 : (bodyΘ.1.take 810).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws152).isNone && !PRE_first_tail_x15_r0_body.ws152.contains v) = true
kernel_rfl bodyDfree152 : (bodyΘ.2.take 810).all (fun e => (PRE_first_tail_x15_r0_body.cws152 ++ PRE_first_tail_x15_r0_body.ws152).all fun w => e.noVar w) = true

theorem bodyStep152 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53871, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1466 PRE_first_tail_x15_r0_body.S1466)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53881, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.S1468) (98 + 1) :=
  bodySite bodyFacts152.cfix bodyFacts152.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st152.S2.tab) (Es := bodyEs152) (qs := bodyQs152)
    (ok := PRE_first_tail_x15_r0_body.st152.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site152 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts152
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site152 r hr) hi (MapOk.sub hm (sub_of_all bodySub152)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk152 r hr) hi hm ho hq)
    bodyLq152 rfl bodyNrLo152 (postSub_sound bodyPost152)
    (Nat.le_of_ble_eq_true bodyDrop152) (by decide) (Nat.le_of_ble_eq_true bodyDropH152) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN152) (by decide)
    bodyDv152 bodyDe152 bodyDl152 bodyDold152 bodyDfree152 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
