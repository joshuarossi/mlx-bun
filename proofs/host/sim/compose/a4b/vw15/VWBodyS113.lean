import host.sim.compose.a4b.vw15.VWBodyJ113
import host.sim.compose.a4b.vw15.VWBodySite113
import host.sim.compose.a4b.vw15.VWBodyOracles_28
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift113 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1092.tab.length PRE_first_tail_x15_r0_body.s1092.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P113.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P113 4885 PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.s1094.ffi PRE_first_tail_x15_r0_body.s1093.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_113
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_113
  have hcl : SSt (· < 4885) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1094.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1092.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_113] <;> decide) PRE_first_tail_x15_r0_body.cnodesK113 PRE_first_tail_x15_r0_body.cobjsK113
      PRE_first_tail_x15_r0_body.citemsK113 PRE_first_tail_x15_r0_body.cbd113 PRE_first_tail_x15_r0_body.csst113
  exact PRE_first_tail_x15_r0_body.cshift113 bodyNcl113 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_113] at this; exact this)


kernel_rfl bodyFramesEmpty113 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1093 a).isEmpty) = true
kernel_rfl bodyJsRoots113 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1092.next) PRE_first_tail_x15_r0_body.s1094.trace PRE_first_tail_x15_r0_body.s1094 = true
kernel_rfl bodyJsNative113 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1094.ffi) = true
kernel_rfl bodyLow113 : (PRE_first_tail_x15_r0_body.cws113 ++ PRE_first_tail_x15_r0_body.ws113).all (Nat.ble 9) = true
kernel_rfl bodyCntM113 : countersOkB PRE_first_tail_x15_r0_body.s1092 PRE_first_tail_x15_r0_body.s1093 = true
kernel_rfl bodyHi113 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1094.ffi).next setupP.E = true
kernel_rfl bodyNhi113 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1094.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge113 : bridgeOf PRE_first_tail_x15_r0_body.s1093.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1092.ffi
kernel_rfl bodyNN113 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1092.ffi).nnext PRE_first_tail_x15_r0_body.P113.NL = true
kernel_rfl bodyXn113 : Nat.ble (⟨20420, 17518, 2763252, 4885⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1094.ffi).next = true
kernel_rfl bodyLo113 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1094.ffi).next = true
theorem bodyFacts113 : BodySiteFacts PRE_first_tail_x15_r0_body.s1092 PRE_first_tail_x15_r0_body.s1093 PRE_first_tail_x15_r0_body.s1094 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1092 PRE_first_tail_x15_r0_body.S1093 PRE_first_tail_x15_r0_body.S1094
    PRE_first_tail_x15_r0_body.ws113 PRE_first_tail_x15_r0_body.cws113 PRE_first_tail_x15_r0_body.nr113 PRE_first_tail_x15_r0_body.pl113 PRE_first_tail_x15_r0_body.cl113 2763262 4885 PRE_first_tail_x15_r0_body.kd113 PRE_first_tail_x15_r0_body.kappa113 PRE_first_tail_x15_r0_body.P113
    ⟨20420, 17518, 2763251, 4885⟩ ⟨20420, 17518, 2763252, 4885⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap113
  clean := bodyClean113
  cfix := PRE_first_tail_x15_r0_body.cfix113
  zpl := PRE_first_tail_x15_r0_body.zpl113
  zplnd := PRE_first_tail_x15_r0_body.zplnd113
  zn1 := PRE_first_tail_x15_r0_body.zn1113
  zfirst := PRE_first_tail_x15_r0_body.zfirst113
  zscn := PRE_first_tail_x15_r0_body.zscn113
  zsmn := PRE_first_tail_x15_r0_body.zsmn113
  zgrow := PRE_first_tail_x15_r0_body.zgrow113
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab113
  zfresh := PRE_first_tail_x15_r0_body.zfresh113
  zcnd := PRE_first_tail_x15_r0_body.zcnd113
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi113
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt113
  zgP := PRE_first_tail_x15_r0_body.zg113_2665
  zkP := PRE_first_tail_x15_r0_body.zk113_2665
  zmP := PRE_first_tail_x15_r0_body.zm113_2665
  zgC := PRE_first_tail_x15_r0_body.zg113_2673467
  zkC := PRE_first_tail_x15_r0_body.zk113_2673467
  zmC := PRE_first_tail_x15_r0_body.zm113_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw113_2673472
  zwV := PRE_first_tail_x15_r0_body.zw113_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap113
  zclbd := PRE_first_tail_x15_r0_body.zclbd113
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap113 PRE_first_tail_x15_r0_body.stFoot113 PRE_first_tail_x15_r0_body.iso113 PRE_first_tail_x15_r0_body.zwr113
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP113
  csupp := PRE_first_tail_x15_r0_body.csupp113
  cbound := PRE_first_tail_x15_r0_body.cbound113
  zimg := PRE_first_tail_x15_r0_body.zimg113
  zctl := PRE_first_tail_x15_r0_body.zctl113
  zstack := PRE_first_tail_x15_r0_body.zstack113
  zjobs := PRE_first_tail_x15_r0_body.zjobs113
  zstores := PRE_first_tail_x15_r0_body.zstores113
  zroots := PRE_first_tail_x15_r0_body.zroots113
  znC := PRE_first_tail_x15_r0_body.znC113
  ctab := PRE_first_tail_x15_r0_body.ctab113
  zbin := PRE_first_tail_x15_r0_body.zbin113
  cbridge := PRE_first_tail_x15_r0_body.cbridge113
  sbridge := bodyBridge113
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj113
  cshiftR := fun h hNL => bodyCshift113 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN113
  raised := PRE_first_tail_x15_r0_body.raised113
  cbigs := PRE_first_tail_x15_r0_body.cbigs113
  cjcl := PRE_first_tail_x15_r0_body.cjcl113
  xnLe := Nat.le_of_ble_eq_true bodyXn113
  loLe := Nat.le_of_ble_eq_true bodyLo113
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB113
  cntM := bodyCntM113
  hiLe := Nat.le_of_ble_eq_true bodyHi113
  nhiLe := Nat.le_of_ble_eq_true bodyNhi113
  jsHeap := bodyJs113
  jsRoots := bodyJsRoots113
  jsNative := bodyJsNative113
  framesEmpty := bodyFramesEmpty113
  trailOld := by decide
  lowVars := bodyLow113

def bodyQs113 : List (Option Q) := []
noncomputable def bodyEs113 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr113.map fun r => nth? PRE_first_tail_x15_r0_body.st113.S2.tab r
kernel_rfl bodyResChk113 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs113 bodyQs113) = true
kernel_rfl bodyLq113 : bodyQs113.length = PRE_first_tail_x15_r0_body.cws113.length
kernel_rfl bodyNrLo113 : PRE_first_tail_x15_r0_body.nr113.all (Nat.ble PRE_first_tail_x15_r0_body.S1092.tab.length) = true
kernel_rfl bodySub113 : (Oracles.PRE_first_tail_x15_r0_body.map_site113.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost113 : postSubB bodyM PRE_first_tail_x15_r0_body.ws113 PRE_first_tail_x15_r0_body.cws113 bodyQs113 = true
kernel_rfl bodyDrop113 : Nat.ble (41130 + (PRE_first_tail_x15_r0_body.s1093.next - PRE_first_tail_x15_r0_body.s1094.next)) 41140 = true
kernel_rfl bodyDropH113 : Nat.ble (764 + ((mlxOf PRE_first_tail_x15_r0_body.s1093.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1094.ffi).next)) 764 = true
kernel_rfl bodyDropN113 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1093.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1094.ffi).nnext)) 0 = true
kernel_rfl bodyDv113 : bodyΘ.1.take 603 = bodyΘ.1.take 603 ++ PRE_first_tail_x15_r0_body.cws113
kernel_rfl bodyDe113 : bodyΘ.2.take 603 = bodyΘ.2.take 603 ++ PRE_first_tail_x15_r0_body.nr113.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st113.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 603) (bodyΘ.2.take 603)))
kernel_rfl bodyDl113 : (bodyΘ.1.take 603).length = (bodyΘ.2.take 603).length
kernel_rfl bodyDold113 : (bodyΘ.1.take 603).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws113).isNone && !PRE_first_tail_x15_r0_body.ws113.contains v) = true
kernel_rfl bodyDfree113 : (bodyΘ.2.take 603).all (fun e => (PRE_first_tail_x15_r0_body.cws113 ++ PRE_first_tail_x15_r0_body.ws113).all fun w => e.noVar w) = true

theorem bodyStep113 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41130, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1092 PRE_first_tail_x15_r0_body.S1092)
      (bodyCut NB T tk π i x0 bodyΘ ⟨41140, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1094 PRE_first_tail_x15_r0_body.S1094) (98 + 1) :=
  bodySite bodyFacts113.cfix bodyFacts113.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st113.S2.tab) (Es := bodyEs113) (qs := bodyQs113)
    (ok := PRE_first_tail_x15_r0_body.st113.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site113 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts113
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site113 r hr) hi (MapOk.sub hm (sub_of_all bodySub113)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk113 r hr) hi hm ho hq)
    bodyLq113 rfl bodyNrLo113 (postSub_sound bodyPost113)
    (Nat.le_of_ble_eq_true bodyDrop113) (by decide) (Nat.le_of_ble_eq_true bodyDropH113) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN113) (by decide)
    bodyDv113 bodyDe113 bodyDl113 bodyDold113 bodyDfree113 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
