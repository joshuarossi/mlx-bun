import host.sim.compose.a4b.vw15.VWBodyJ82
import host.sim.compose.a4b.vw15.VWBodySite82
import host.sim.compose.a4b.vw15.VWBodyOracles_20
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

theorem bodyCshift82 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S800.tab.length PRE_first_tail_x15_r0_body.s800.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P82.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P82 3584 PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.s802.ffi PRE_first_tail_x15_r0_body.s801.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_82
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_82
  have hcl : SSt (· < 3584) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s802.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S800.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_82] <;> decide) PRE_first_tail_x15_r0_body.cnodesK82 PRE_first_tail_x15_r0_body.cobjsK82
      PRE_first_tail_x15_r0_body.citemsK82 PRE_first_tail_x15_r0_body.cbd82 PRE_first_tail_x15_r0_body.csst82
  exact PRE_first_tail_x15_r0_body.cshift82 bodyNcl82 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_82] at this; exact this)


kernel_rfl bodyFramesEmpty82 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s801 a).isEmpty) = true
kernel_rfl bodyJsRoots82 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s800.next) PRE_first_tail_x15_r0_body.s802.trace PRE_first_tail_x15_r0_body.s802 = true
kernel_rfl bodyJsNative82 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s802.ffi) = true
kernel_rfl bodyLow82 : (PRE_first_tail_x15_r0_body.cws82 ++ PRE_first_tail_x15_r0_body.ws82).all (Nat.ble 9) = true
kernel_rfl bodyCntM82 : countersOkB PRE_first_tail_x15_r0_body.s800 PRE_first_tail_x15_r0_body.s801 = true
kernel_rfl bodyHi82 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s802.ffi).next setupP.E = true
kernel_rfl bodyNhi82 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s802.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge82 : bridgeOf PRE_first_tail_x15_r0_body.s801.ffi = bridgeOf PRE_first_tail_x15_r0_body.s800.ffi
kernel_rfl bodyNN82 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s800.ffi).nnext PRE_first_tail_x15_r0_body.P82.NL = true
kernel_rfl bodyXn82 : Nat.ble (⟨19826, 16914, 2739589, 3584⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s802.ffi).next = true
kernel_rfl bodyLo82 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s802.ffi).next = true
theorem bodyFacts82 : BodySiteFacts PRE_first_tail_x15_r0_body.s800 PRE_first_tail_x15_r0_body.s801 PRE_first_tail_x15_r0_body.s802 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S800 PRE_first_tail_x15_r0_body.S801 PRE_first_tail_x15_r0_body.S802
    PRE_first_tail_x15_r0_body.ws82 PRE_first_tail_x15_r0_body.cws82 PRE_first_tail_x15_r0_body.nr82 PRE_first_tail_x15_r0_body.pl82 PRE_first_tail_x15_r0_body.cl82 2739591 3584 PRE_first_tail_x15_r0_body.kd82 PRE_first_tail_x15_r0_body.kappa82 PRE_first_tail_x15_r0_body.P82
    ⟨19826, 16914, 2739589, 3584⟩ ⟨19826, 16914, 2739589, 3584⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap82
  clean := bodyClean82
  cfix := PRE_first_tail_x15_r0_body.cfix82
  zpl := PRE_first_tail_x15_r0_body.zpl82
  zplnd := PRE_first_tail_x15_r0_body.zplnd82
  zn1 := PRE_first_tail_x15_r0_body.zn182
  zfirst := PRE_first_tail_x15_r0_body.zfirst82
  zscn := PRE_first_tail_x15_r0_body.zscn82
  zsmn := PRE_first_tail_x15_r0_body.zsmn82
  zgrow := PRE_first_tail_x15_r0_body.zgrow82
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab82
  zfresh := PRE_first_tail_x15_r0_body.zfresh82
  zcnd := PRE_first_tail_x15_r0_body.zcnd82
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi82
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt82
  zgP := PRE_first_tail_x15_r0_body.zg82_2665
  zkP := PRE_first_tail_x15_r0_body.zk82_2665
  zmP := PRE_first_tail_x15_r0_body.zm82_2665
  zgC := PRE_first_tail_x15_r0_body.zg82_2673467
  zkC := PRE_first_tail_x15_r0_body.zk82_2673467
  zmC := PRE_first_tail_x15_r0_body.zm82_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw82_2673472
  zwV := PRE_first_tail_x15_r0_body.zw82_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap82
  zclbd := PRE_first_tail_x15_r0_body.zclbd82
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap82 PRE_first_tail_x15_r0_body.stFoot82 PRE_first_tail_x15_r0_body.iso82 PRE_first_tail_x15_r0_body.zwr82
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP82
  csupp := PRE_first_tail_x15_r0_body.csupp82
  cbound := PRE_first_tail_x15_r0_body.cbound82
  zimg := PRE_first_tail_x15_r0_body.zimg82
  zctl := PRE_first_tail_x15_r0_body.zctl82
  zstack := PRE_first_tail_x15_r0_body.zstack82
  zjobs := PRE_first_tail_x15_r0_body.zjobs82
  zstores := PRE_first_tail_x15_r0_body.zstores82
  zroots := PRE_first_tail_x15_r0_body.zroots82
  znC := PRE_first_tail_x15_r0_body.znC82
  ctab := PRE_first_tail_x15_r0_body.ctab82
  zbin := PRE_first_tail_x15_r0_body.zbin82
  cbridge := PRE_first_tail_x15_r0_body.cbridge82
  sbridge := bodyBridge82
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj82
  cshiftR := fun h hNL => bodyCshift82 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN82
  raised := PRE_first_tail_x15_r0_body.raised82
  cbigs := PRE_first_tail_x15_r0_body.cbigs82
  cjcl := PRE_first_tail_x15_r0_body.cjcl82
  xnLe := Nat.le_of_ble_eq_true bodyXn82
  loLe := Nat.le_of_ble_eq_true bodyLo82
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB82
  cntM := bodyCntM82
  hiLe := Nat.le_of_ble_eq_true bodyHi82
  nhiLe := Nat.le_of_ble_eq_true bodyNhi82
  jsHeap := bodyJs82
  jsRoots := bodyJsRoots82
  jsNative := bodyJsNative82
  framesEmpty := bodyFramesEmpty82
  trailOld := by decide
  lowVars := bodyLow82

def bodyQs82 : List (Option Q) := []
noncomputable def bodyEs82 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr82.map fun r => nth? PRE_first_tail_x15_r0_body.st82.S2.tab r
kernel_rfl bodyResChk82 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs82 bodyQs82) = true
kernel_rfl bodyLq82 : bodyQs82.length = PRE_first_tail_x15_r0_body.cws82.length
kernel_rfl bodyNrLo82 : PRE_first_tail_x15_r0_body.nr82.all (Nat.ble PRE_first_tail_x15_r0_body.S800.tab.length) = true
kernel_rfl bodySub82 : (Oracles.PRE_first_tail_x15_r0_body.map_site82.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost82 : postSubB bodyM PRE_first_tail_x15_r0_body.ws82 PRE_first_tail_x15_r0_body.cws82 bodyQs82 = true
kernel_rfl bodyDrop82 : Nat.ble (31080 + (PRE_first_tail_x15_r0_body.s801.next - PRE_first_tail_x15_r0_body.s802.next)) 31082 = true
kernel_rfl bodyDropH82 : Nat.ble (560 + ((mlxOf PRE_first_tail_x15_r0_body.s801.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s802.ffi).next)) 560 = true
kernel_rfl bodyDropN82 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s801.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s802.ffi).nnext)) 0 = true
kernel_rfl bodyDv82 : bodyΘ.1.take 441 = bodyΘ.1.take 441 ++ PRE_first_tail_x15_r0_body.cws82
kernel_rfl bodyDe82 : bodyΘ.2.take 441 = bodyΘ.2.take 441 ++ PRE_first_tail_x15_r0_body.nr82.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st82.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 441) (bodyΘ.2.take 441)))
kernel_rfl bodyDl82 : (bodyΘ.1.take 441).length = (bodyΘ.2.take 441).length
kernel_rfl bodyDold82 : (bodyΘ.1.take 441).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws82).isNone && !PRE_first_tail_x15_r0_body.ws82.contains v) = true
kernel_rfl bodyDfree82 : (bodyΘ.2.take 441).all (fun e => (PRE_first_tail_x15_r0_body.cws82 ++ PRE_first_tail_x15_r0_body.ws82).all fun w => e.noVar w) = true

theorem bodyStep82 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31080, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s800 PRE_first_tail_x15_r0_body.S800)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31082, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s802 PRE_first_tail_x15_r0_body.S802) (27 + 1) :=
  bodySite bodyFacts82.cfix bodyFacts82.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st82.S2.tab) (Es := bodyEs82) (qs := bodyQs82)
    (ok := PRE_first_tail_x15_r0_body.st82.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site82 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts82
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site82 r hr) hi (MapOk.sub hm (sub_of_all bodySub82)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk82 r hr) hi hm ho hq)
    bodyLq82 rfl bodyNrLo82 (postSub_sound bodyPost82)
    (Nat.le_of_ble_eq_true bodyDrop82) (by decide) (Nat.le_of_ble_eq_true bodyDropH82) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN82) (by decide)
    bodyDv82 bodyDe82 bodyDl82 bodyDold82 bodyDfree82 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
