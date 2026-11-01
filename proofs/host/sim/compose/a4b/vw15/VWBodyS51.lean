import host.sim.compose.a4b.vw15.VWBodyJ51
import host.sim.compose.a4b.vw15.VWBodySite51
import host.sim.compose.a4b.vw15.VWBodyOracles_12
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift51 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S505.tab.length PRE_first_tail_x15_r0_body.s505.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P51.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P51 2282 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.s507.ffi PRE_first_tail_x15_r0_body.s506.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_51
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_51
  have hcl : SSt (· < 2282) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s507.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S505.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_51] <;> decide) PRE_first_tail_x15_r0_body.cnodesK51 PRE_first_tail_x15_r0_body.cobjsK51
      PRE_first_tail_x15_r0_body.citemsK51 PRE_first_tail_x15_r0_body.cbd51 PRE_first_tail_x15_r0_body.csst51
  exact PRE_first_tail_x15_r0_body.cshift51 bodyNcl51 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_51] at this; exact this)


kernel_rfl bodyFramesEmpty51 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s506 a).isEmpty) = true
kernel_rfl bodyJsRoots51 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s505.next) PRE_first_tail_x15_r0_body.s507.trace PRE_first_tail_x15_r0_body.s507 = true
kernel_rfl bodyJsNative51 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s507.ffi) = true
kernel_rfl bodyLow51 : (PRE_first_tail_x15_r0_body.cws51 ++ PRE_first_tail_x15_r0_body.ws51).all (Nat.ble 9) = true
kernel_rfl bodyCntM51 : countersOkB PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.s506 = true
kernel_rfl bodyHi51 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next setupP.E = true
kernel_rfl bodyNhi51 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge51 : bridgeOf PRE_first_tail_x15_r0_body.s506.ffi = bridgeOf PRE_first_tail_x15_r0_body.s505.ffi
kernel_rfl bodyNN51 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s505.ffi).nnext PRE_first_tail_x15_r0_body.P51.NL = true
kernel_rfl bodyXn51 : Nat.ble (⟨19220, 16316, 2715389, 2282⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next = true
kernel_rfl bodyLo51 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next = true
theorem bodyFacts51 : BodySiteFacts PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.s506 PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S505 PRE_first_tail_x15_r0_body.S506 PRE_first_tail_x15_r0_body.S507
    PRE_first_tail_x15_r0_body.ws51 PRE_first_tail_x15_r0_body.cws51 PRE_first_tail_x15_r0_body.nr51 PRE_first_tail_x15_r0_body.pl51 PRE_first_tail_x15_r0_body.cl51 2716538 2282 PRE_first_tail_x15_r0_body.kd51 PRE_first_tail_x15_r0_body.kappa51 PRE_first_tail_x15_r0_body.P51
    ⟨19217, 16289, 2715383, 2264⟩ ⟨19220, 16316, 2715389, 2282⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap51
  clean := bodyClean51
  cfix := PRE_first_tail_x15_r0_body.cfix51
  zpl := PRE_first_tail_x15_r0_body.zpl51
  zplnd := PRE_first_tail_x15_r0_body.zplnd51
  zn1 := PRE_first_tail_x15_r0_body.zn151
  zfirst := PRE_first_tail_x15_r0_body.zfirst51
  zscn := PRE_first_tail_x15_r0_body.zscn51
  zsmn := PRE_first_tail_x15_r0_body.zsmn51
  zgrow := PRE_first_tail_x15_r0_body.zgrow51
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab51
  zfresh := PRE_first_tail_x15_r0_body.zfresh51
  zcnd := PRE_first_tail_x15_r0_body.zcnd51
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi51
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt51
  zgP := PRE_first_tail_x15_r0_body.zg51_2665
  zkP := PRE_first_tail_x15_r0_body.zk51_2665
  zmP := PRE_first_tail_x15_r0_body.zm51_2665
  zgC := PRE_first_tail_x15_r0_body.zg51_2673467
  zkC := PRE_first_tail_x15_r0_body.zk51_2673467
  zmC := PRE_first_tail_x15_r0_body.zm51_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw51_2673472
  zwV := PRE_first_tail_x15_r0_body.zw51_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap51
  zclbd := PRE_first_tail_x15_r0_body.zclbd51
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap51 PRE_first_tail_x15_r0_body.stFoot51 PRE_first_tail_x15_r0_body.iso51 PRE_first_tail_x15_r0_body.zwr51
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP51
  csupp := PRE_first_tail_x15_r0_body.csupp51
  cbound := PRE_first_tail_x15_r0_body.cbound51
  zimg := PRE_first_tail_x15_r0_body.zimg51
  zctl := PRE_first_tail_x15_r0_body.zctl51
  zstack := PRE_first_tail_x15_r0_body.zstack51
  zjobs := PRE_first_tail_x15_r0_body.zjobs51
  zstores := PRE_first_tail_x15_r0_body.zstores51
  zroots := PRE_first_tail_x15_r0_body.zroots51
  znC := PRE_first_tail_x15_r0_body.znC51
  ctab := PRE_first_tail_x15_r0_body.ctab51
  zbin := PRE_first_tail_x15_r0_body.zbin51
  cbridge := PRE_first_tail_x15_r0_body.cbridge51
  sbridge := bodyBridge51
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj51
  cshiftR := fun h hNL => bodyCshift51 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN51
  raised := PRE_first_tail_x15_r0_body.raised51
  cbigs := PRE_first_tail_x15_r0_body.cbigs51
  cjcl := PRE_first_tail_x15_r0_body.cjcl51
  xnLe := Nat.le_of_ble_eq_true bodyXn51
  loLe := Nat.le_of_ble_eq_true bodyLo51
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB51
  cntM := bodyCntM51
  hiLe := Nat.le_of_ble_eq_true bodyHi51
  nhiLe := Nat.le_of_ble_eq_true bodyNhi51
  jsHeap := bodyJs51
  jsRoots := bodyJsRoots51
  jsNative := bodyJsNative51
  framesEmpty := bodyFramesEmpty51
  trailOld := by decide
  lowVars := bodyLow51

def bodyQs51 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs51 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr51.map fun r => nth? PRE_first_tail_x15_r0_body.st51.S5.tab r
kernel_rfl bodyResChk51 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs51 bodyQs51) = true
kernel_rfl bodyLq51 : bodyQs51.length = PRE_first_tail_x15_r0_body.cws51.length
kernel_rfl bodyNrLo51 : PRE_first_tail_x15_r0_body.nr51.all (Nat.ble PRE_first_tail_x15_r0_body.S505.tab.length) = true
kernel_rfl bodySub51 : (Oracles.PRE_first_tail_x15_r0_body.map_site51.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost51 : postSubB bodyM PRE_first_tail_x15_r0_body.ws51 PRE_first_tail_x15_r0_body.cws51 bodyQs51 = true
kernel_rfl bodyDrop51 : Nat.ble (20700 + (PRE_first_tail_x15_r0_body.s506.next - PRE_first_tail_x15_r0_body.s507.next)) 21849 = true
kernel_rfl bodyDropH51 : Nat.ble (354 + ((mlxOf PRE_first_tail_x15_r0_body.s506.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).next)) 379 = true
kernel_rfl bodyDropN51 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s506.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s507.ffi).nnext)) 0 = true
kernel_rfl bodyDv51 : bodyΘ.1.take 288 = bodyΘ.1.take 270 ++ PRE_first_tail_x15_r0_body.cws51
kernel_rfl bodyDe51 : bodyΘ.2.take 288 = bodyΘ.2.take 270 ++ PRE_first_tail_x15_r0_body.nr51.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st51.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 270) (bodyΘ.2.take 270)))
kernel_rfl bodyDl51 : (bodyΘ.1.take 270).length = (bodyΘ.2.take 270).length
kernel_rfl bodyDold51 : (bodyΘ.1.take 270).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws51).isNone && !PRE_first_tail_x15_r0_body.ws51.contains v) = true
kernel_rfl bodyDfree51 : (bodyΘ.2.take 288).all (fun e => (PRE_first_tail_x15_r0_body.cws51 ++ PRE_first_tail_x15_r0_body.ws51).all fun w => e.noVar w) = true

theorem bodyStep51 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.S505)
      (bodyCut NB T tk π i x0 bodyΘ ⟨21849, 379, 0, 288⟩ bodyM PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.S507) (11334 + 1) :=
  bodySite bodyFacts51.cfix bodyFacts51.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st51.S5.tab) (Es := bodyEs51) (qs := bodyQs51)
    (ok := PRE_first_tail_x15_r0_body.st51.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site51 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts51
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site51 r hr) hi (MapOk.sub hm (sub_of_all bodySub51)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk51 r hr) hi hm ho hq)
    bodyLq51 rfl bodyNrLo51 (postSub_sound bodyPost51)
    (Nat.le_of_ble_eq_true bodyDrop51) (by decide) (Nat.le_of_ble_eq_true bodyDropH51) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN51) (by decide)
    bodyDv51 bodyDe51 bodyDl51 bodyDold51 bodyDfree51 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
