import host.sim.compose.a4b.vw15.VWBodyJ97
import host.sim.compose.a4b.vw15.VWBodySite97
import host.sim.compose.a4b.vw15.VWBodyOracles_24
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B24
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift97 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S944.tab.length PRE_first_tail_x15_r0_body.s944.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P97.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P97 4226 PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.s946.ffi PRE_first_tail_x15_r0_body.s945.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_97
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_97
  have hcl : SSt (· < 4226) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s946.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S944.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_97] <;> decide) PRE_first_tail_x15_r0_body.cnodesK97 PRE_first_tail_x15_r0_body.cobjsK97
      PRE_first_tail_x15_r0_body.citemsK97 PRE_first_tail_x15_r0_body.cbd97 PRE_first_tail_x15_r0_body.csst97
  exact PRE_first_tail_x15_r0_body.cshift97 bodyNcl97 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_97] at this; exact this)


kernel_rfl bodyFramesEmpty97 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s945 a).isEmpty) = true
kernel_rfl bodyJsRoots97 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s944.next) PRE_first_tail_x15_r0_body.s946.trace PRE_first_tail_x15_r0_body.s946 = true
kernel_rfl bodyJsNative97 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s946.ffi) = true
kernel_rfl bodyLow97 : (PRE_first_tail_x15_r0_body.cws97 ++ PRE_first_tail_x15_r0_body.ws97).all (Nat.ble 9) = true
kernel_rfl bodyCntM97 : countersOkB PRE_first_tail_x15_r0_body.s944 PRE_first_tail_x15_r0_body.s945 = true
kernel_rfl bodyHi97 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s946.ffi).next setupP.E = true
kernel_rfl bodyNhi97 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s946.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge97 : bridgeOf PRE_first_tail_x15_r0_body.s945.ffi = bridgeOf PRE_first_tail_x15_r0_body.s944.ffi
kernel_rfl bodyNN97 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s944.ffi).nnext PRE_first_tail_x15_r0_body.P97.NL = true
kernel_rfl bodyXn97 : Nat.ble (⟨20120, 17214, 2751287, 4226⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s946.ffi).next = true
kernel_rfl bodyLo97 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s946.ffi).next = true
theorem bodyFacts97 : BodySiteFacts PRE_first_tail_x15_r0_body.s944 PRE_first_tail_x15_r0_body.s945 PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S944 PRE_first_tail_x15_r0_body.S945 PRE_first_tail_x15_r0_body.S946
    PRE_first_tail_x15_r0_body.ws97 PRE_first_tail_x15_r0_body.cws97 PRE_first_tail_x15_r0_body.nr97 PRE_first_tail_x15_r0_body.pl97 PRE_first_tail_x15_r0_body.cl97 2751289 4226 PRE_first_tail_x15_r0_body.kd97 PRE_first_tail_x15_r0_body.kappa97 PRE_first_tail_x15_r0_body.P97
    ⟨20120, 17214, 2751287, 4226⟩ ⟨20120, 17214, 2751287, 4226⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap97
  clean := bodyClean97
  cfix := PRE_first_tail_x15_r0_body.cfix97
  zpl := PRE_first_tail_x15_r0_body.zpl97
  zplnd := PRE_first_tail_x15_r0_body.zplnd97
  zn1 := PRE_first_tail_x15_r0_body.zn197
  zfirst := PRE_first_tail_x15_r0_body.zfirst97
  zscn := PRE_first_tail_x15_r0_body.zscn97
  zsmn := PRE_first_tail_x15_r0_body.zsmn97
  zgrow := PRE_first_tail_x15_r0_body.zgrow97
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab97
  zfresh := PRE_first_tail_x15_r0_body.zfresh97
  zcnd := PRE_first_tail_x15_r0_body.zcnd97
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi97
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt97
  zgP := PRE_first_tail_x15_r0_body.zg97_2665
  zkP := PRE_first_tail_x15_r0_body.zk97_2665
  zmP := PRE_first_tail_x15_r0_body.zm97_2665
  zgC := PRE_first_tail_x15_r0_body.zg97_2673467
  zkC := PRE_first_tail_x15_r0_body.zk97_2673467
  zmC := PRE_first_tail_x15_r0_body.zm97_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw97_2673472
  zwV := PRE_first_tail_x15_r0_body.zw97_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap97
  zclbd := PRE_first_tail_x15_r0_body.zclbd97
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap97 PRE_first_tail_x15_r0_body.stFoot97 PRE_first_tail_x15_r0_body.iso97 PRE_first_tail_x15_r0_body.zwr97
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP97
  csupp := PRE_first_tail_x15_r0_body.csupp97
  cbound := PRE_first_tail_x15_r0_body.cbound97
  zimg := PRE_first_tail_x15_r0_body.zimg97
  zctl := PRE_first_tail_x15_r0_body.zctl97
  zstack := PRE_first_tail_x15_r0_body.zstack97
  zjobs := PRE_first_tail_x15_r0_body.zjobs97
  zstores := PRE_first_tail_x15_r0_body.zstores97
  zroots := PRE_first_tail_x15_r0_body.zroots97
  znC := PRE_first_tail_x15_r0_body.znC97
  ctab := PRE_first_tail_x15_r0_body.ctab97
  zbin := PRE_first_tail_x15_r0_body.zbin97
  cbridge := PRE_first_tail_x15_r0_body.cbridge97
  sbridge := bodyBridge97
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj97
  cshiftR := fun h hNL => bodyCshift97 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN97
  raised := PRE_first_tail_x15_r0_body.raised97
  cbigs := PRE_first_tail_x15_r0_body.cbigs97
  cjcl := PRE_first_tail_x15_r0_body.cjcl97
  xnLe := Nat.le_of_ble_eq_true bodyXn97
  loLe := Nat.le_of_ble_eq_true bodyLo97
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB97
  cntM := bodyCntM97
  hiLe := Nat.le_of_ble_eq_true bodyHi97
  nhiLe := Nat.le_of_ble_eq_true bodyNhi97
  jsHeap := bodyJs97
  jsRoots := bodyJsRoots97
  jsNative := bodyJsNative97
  framesEmpty := bodyFramesEmpty97
  trailOld := by decide
  lowVars := bodyLow97

def bodyQs97 : List (Option Q) := []
noncomputable def bodyEs97 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr97.map fun r => nth? PRE_first_tail_x15_r0_body.st97.S2.tab r
kernel_rfl bodyResChk97 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs97 bodyQs97) = true
kernel_rfl bodyLq97 : bodyQs97.length = PRE_first_tail_x15_r0_body.cws97.length
kernel_rfl bodyNrLo97 : PRE_first_tail_x15_r0_body.nr97.all (Nat.ble PRE_first_tail_x15_r0_body.S944.tab.length) = true
kernel_rfl bodySub97 : (Oracles.PRE_first_tail_x15_r0_body.map_site97.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost97 : postSubB bodyM PRE_first_tail_x15_r0_body.ws97 PRE_first_tail_x15_r0_body.cws97 bodyQs97 = true
kernel_rfl bodyDrop97 : Nat.ble (36104 + (PRE_first_tail_x15_r0_body.s945.next - PRE_first_tail_x15_r0_body.s946.next)) 36106 = true
kernel_rfl bodyDropH97 : Nat.ble (662 + ((mlxOf PRE_first_tail_x15_r0_body.s945.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s946.ffi).next)) 662 = true
kernel_rfl bodyDropN97 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s945.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s946.ffi).nnext)) 0 = true
kernel_rfl bodyDv97 : bodyΘ.1.take 522 = bodyΘ.1.take 522 ++ PRE_first_tail_x15_r0_body.cws97
kernel_rfl bodyDe97 : bodyΘ.2.take 522 = bodyΘ.2.take 522 ++ PRE_first_tail_x15_r0_body.nr97.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st97.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 522) (bodyΘ.2.take 522)))
kernel_rfl bodyDl97 : (bodyΘ.1.take 522).length = (bodyΘ.2.take 522).length
kernel_rfl bodyDold97 : (bodyΘ.1.take 522).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws97).isNone && !PRE_first_tail_x15_r0_body.ws97.contains v) = true
kernel_rfl bodyDfree97 : (bodyΘ.2.take 522).all (fun e => (PRE_first_tail_x15_r0_body.cws97 ++ PRE_first_tail_x15_r0_body.ws97).all fun w => e.noVar w) = true

theorem bodyStep97 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36104, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s944 PRE_first_tail_x15_r0_body.S944)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36106, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.S946) (27 + 1) :=
  bodySite bodyFacts97.cfix bodyFacts97.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st97.S2.tab) (Es := bodyEs97) (qs := bodyQs97)
    (ok := PRE_first_tail_x15_r0_body.st97.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site97 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts97
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site97 r hr) hi (MapOk.sub hm (sub_of_all bodySub97)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk97 r hr) hi hm ho hq)
    bodyLq97 rfl bodyNrLo97 (postSub_sound bodyPost97)
    (Nat.le_of_ble_eq_true bodyDrop97) (by decide) (Nat.le_of_ble_eq_true bodyDropH97) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN97) (by decide)
    bodyDv97 bodyDe97 bodyDl97 bodyDold97 bodyDfree97 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
