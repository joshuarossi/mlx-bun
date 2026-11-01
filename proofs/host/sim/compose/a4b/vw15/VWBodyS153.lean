import host.sim.compose.a4b.vw15.VWBodyJ153
import host.sim.compose.a4b.vw15.VWBodySite153
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

theorem bodyCshift153 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1482.tab.length PRE_first_tail_x15_r0_body.s1482.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P153.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P153 6639 PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.s1484.ffi PRE_first_tail_x15_r0_body.s1483.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_153
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_153
  have hcl : SSt (· < 6639) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1484.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1482.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_153] <;> decide) PRE_first_tail_x15_r0_body.cnodesK153 PRE_first_tail_x15_r0_body.cobjsK153
      PRE_first_tail_x15_r0_body.citemsK153 PRE_first_tail_x15_r0_body.cbd153 PRE_first_tail_x15_r0_body.csst153
  exact PRE_first_tail_x15_r0_body.cshift153 bodyNcl153 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_153] at this; exact this)


kernel_rfl bodyFramesEmpty153 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1483 a).isEmpty) = true
kernel_rfl bodyJsRoots153 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1482.next) PRE_first_tail_x15_r0_body.s1484.trace PRE_first_tail_x15_r0_body.s1484 = true
kernel_rfl bodyJsNative153 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1484.ffi) = true
kernel_rfl bodyLow153 : (PRE_first_tail_x15_r0_body.cws153 ++ PRE_first_tail_x15_r0_body.ws153).all (Nat.ble 9) = true
kernel_rfl bodyCntM153 : countersOkB PRE_first_tail_x15_r0_body.s1482 PRE_first_tail_x15_r0_body.s1483 = true
kernel_rfl bodyHi153 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1484.ffi).next setupP.E = true
kernel_rfl bodyNhi153 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1484.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge153 : bridgeOf PRE_first_tail_x15_r0_body.s1483.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1482.ffi
kernel_rfl bodyNN153 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1482.ffi).nnext PRE_first_tail_x15_r0_body.P153.NL = true
kernel_rfl bodyXn153 : Nat.ble (⟨21229, 18326, 2795515, 6639⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1484.ffi).next = true
kernel_rfl bodyLo153 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1484.ffi).next = true
theorem bodyFacts153 : BodySiteFacts PRE_first_tail_x15_r0_body.s1482 PRE_first_tail_x15_r0_body.s1483 PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1482 PRE_first_tail_x15_r0_body.S1483 PRE_first_tail_x15_r0_body.S1484
    PRE_first_tail_x15_r0_body.ws153 PRE_first_tail_x15_r0_body.cws153 PRE_first_tail_x15_r0_body.nr153 PRE_first_tail_x15_r0_body.pl153 PRE_first_tail_x15_r0_body.cl153 2795865 6639 PRE_first_tail_x15_r0_body.kd153 PRE_first_tail_x15_r0_body.kappa153 PRE_first_tail_x15_r0_body.P153
    ⟨21225, 18320, 2795500, 6630⟩ ⟨21229, 18326, 2795515, 6639⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap153
  clean := bodyClean153
  cfix := PRE_first_tail_x15_r0_body.cfix153
  zpl := PRE_first_tail_x15_r0_body.zpl153
  zplnd := PRE_first_tail_x15_r0_body.zplnd153
  zn1 := PRE_first_tail_x15_r0_body.zn1153
  zfirst := PRE_first_tail_x15_r0_body.zfirst153
  zscn := PRE_first_tail_x15_r0_body.zscn153
  zsmn := PRE_first_tail_x15_r0_body.zsmn153
  zgrow := PRE_first_tail_x15_r0_body.zgrow153
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab153
  zfresh := PRE_first_tail_x15_r0_body.zfresh153
  zcnd := PRE_first_tail_x15_r0_body.zcnd153
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi153
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt153
  zgP := PRE_first_tail_x15_r0_body.zg153_2665
  zkP := PRE_first_tail_x15_r0_body.zk153_2665
  zmP := PRE_first_tail_x15_r0_body.zm153_2665
  zgC := PRE_first_tail_x15_r0_body.zg153_2673467
  zkC := PRE_first_tail_x15_r0_body.zk153_2673467
  zmC := PRE_first_tail_x15_r0_body.zm153_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw153_2673472
  zwV := PRE_first_tail_x15_r0_body.zw153_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap153
  zclbd := PRE_first_tail_x15_r0_body.zclbd153
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap153 PRE_first_tail_x15_r0_body.stFoot153 PRE_first_tail_x15_r0_body.iso153 PRE_first_tail_x15_r0_body.zwr153
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP153
  csupp := PRE_first_tail_x15_r0_body.csupp153
  cbound := PRE_first_tail_x15_r0_body.cbound153
  zimg := PRE_first_tail_x15_r0_body.zimg153
  zctl := PRE_first_tail_x15_r0_body.zctl153
  zstack := PRE_first_tail_x15_r0_body.zstack153
  zjobs := PRE_first_tail_x15_r0_body.zjobs153
  zstores := PRE_first_tail_x15_r0_body.zstores153
  zroots := PRE_first_tail_x15_r0_body.zroots153
  znC := PRE_first_tail_x15_r0_body.znC153
  ctab := PRE_first_tail_x15_r0_body.ctab153
  zbin := PRE_first_tail_x15_r0_body.zbin153
  cbridge := PRE_first_tail_x15_r0_body.cbridge153
  sbridge := bodyBridge153
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj153
  cshiftR := fun h hNL => bodyCshift153 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN153
  raised := PRE_first_tail_x15_r0_body.raised153
  cbigs := PRE_first_tail_x15_r0_body.cbigs153
  cjcl := PRE_first_tail_x15_r0_body.cjcl153
  xnLe := Nat.le_of_ble_eq_true bodyXn153
  loLe := Nat.le_of_ble_eq_true bodyLo153
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB153
  cntM := bodyCntM153
  hiLe := Nat.le_of_ble_eq_true bodyHi153
  nhiLe := Nat.le_of_ble_eq_true bodyNhi153
  jsHeap := bodyJs153
  jsRoots := bodyJsRoots153
  jsNative := bodyJsNative153
  framesEmpty := bodyFramesEmpty153
  trailOld := by decide
  lowVars := bodyLow153

def bodyQs153 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs153 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr153.map fun r => nth? PRE_first_tail_x15_r0_body.st153.S3.tab r
kernel_rfl bodyResChk153 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs153 bodyQs153) = true
kernel_rfl bodyLq153 : bodyQs153.length = PRE_first_tail_x15_r0_body.cws153.length
kernel_rfl bodyNrLo153 : PRE_first_tail_x15_r0_body.nr153.all (Nat.ble PRE_first_tail_x15_r0_body.S1482.tab.length) = true
kernel_rfl bodySub153 : (Oracles.PRE_first_tail_x15_r0_body.map_site153.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost153 : postSubB bodyM PRE_first_tail_x15_r0_body.ws153 PRE_first_tail_x15_r0_body.cws153 bodyQs153 = true
kernel_rfl bodyDrop153 : Nat.ble (53881 + (PRE_first_tail_x15_r0_body.s1483.next - PRE_first_tail_x15_r0_body.s1484.next)) 54231 = true
kernel_rfl bodyDropH153 : Nat.ble (1020 + ((mlxOf PRE_first_tail_x15_r0_body.s1483.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1484.ffi).next)) 1022 = true
kernel_rfl bodyDropN153 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1483.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1484.ffi).nnext)) 0 = true
kernel_rfl bodyDv153 : bodyΘ.1.take 819 = bodyΘ.1.take 810 ++ PRE_first_tail_x15_r0_body.cws153
kernel_rfl bodyDe153 : bodyΘ.2.take 819 = bodyΘ.2.take 810 ++ PRE_first_tail_x15_r0_body.nr153.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st153.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 810) (bodyΘ.2.take 810)))
kernel_rfl bodyDl153 : (bodyΘ.1.take 810).length = (bodyΘ.2.take 810).length
kernel_rfl bodyDold153 : (bodyΘ.1.take 810).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws153).isNone && !PRE_first_tail_x15_r0_body.ws153.contains v) = true
kernel_rfl bodyDfree153 : (bodyΘ.2.take 819).all (fun e => (PRE_first_tail_x15_r0_body.cws153 ++ PRE_first_tail_x15_r0_body.ws153).all fun w => e.noVar w) = true

theorem bodyStep153 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53881, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1482 PRE_first_tail_x15_r0_body.S1482)
      (bodyCut NB T tk π i x0 bodyΘ ⟨54231, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.S1484) (3452 + 1) :=
  bodySite bodyFacts153.cfix bodyFacts153.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st153.S3.tab) (Es := bodyEs153) (qs := bodyQs153)
    (ok := PRE_first_tail_x15_r0_body.st153.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site153 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts153
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site153 r hr) hi (MapOk.sub hm (sub_of_all bodySub153)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk153 r hr) hi hm ho hq)
    bodyLq153 rfl bodyNrLo153 (postSub_sound bodyPost153)
    (Nat.le_of_ble_eq_true bodyDrop153) (by decide) (Nat.le_of_ble_eq_true bodyDropH153) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN153) (by decide)
    bodyDv153 bodyDe153 bodyDl153 bodyDold153 bodyDfree153 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
