import host.sim.compose.a4b.vw15.VWBodyJ121
import host.sim.compose.a4b.vw15.VWBodySite121
import host.sim.compose.a4b.vw15.VWBodyOracles_30
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift121 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1174.tab.length PRE_first_tail_x15_r0_body.s1174.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P121.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P121 5252 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.s1176.ffi PRE_first_tail_x15_r0_body.s1175.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_121
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_121
  have hcl : SSt (· < 5252) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1176.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1174.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_121] <;> decide) PRE_first_tail_x15_r0_body.cnodesK121 PRE_first_tail_x15_r0_body.cobjsK121
      PRE_first_tail_x15_r0_body.citemsK121 PRE_first_tail_x15_r0_body.cbd121 PRE_first_tail_x15_r0_body.csst121
  exact PRE_first_tail_x15_r0_body.cshift121 bodyNcl121 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_121] at this; exact this)


kernel_rfl bodyFramesEmpty121 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1175 a).isEmpty) = true
kernel_rfl bodyJsRoots121 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1174.next) PRE_first_tail_x15_r0_body.s1176.trace PRE_first_tail_x15_r0_body.s1176 = true
kernel_rfl bodyJsNative121 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1176.ffi) = true
kernel_rfl bodyLow121 : (PRE_first_tail_x15_r0_body.cws121 ++ PRE_first_tail_x15_r0_body.ws121).all (Nat.ble 9) = true
kernel_rfl bodyCntM121 : countersOkB PRE_first_tail_x15_r0_body.s1174 PRE_first_tail_x15_r0_body.s1175 = true
kernel_rfl bodyHi121 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1176.ffi).next setupP.E = true
kernel_rfl bodyNhi121 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1176.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge121 : bridgeOf PRE_first_tail_x15_r0_body.s1175.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1174.ffi
kernel_rfl bodyNN121 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1174.ffi).nnext PRE_first_tail_x15_r0_body.P121.NL = true
kernel_rfl bodyXn121 : Nat.ble (⟨20592, 17688, 2770119, 5252⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1176.ffi).next = true
kernel_rfl bodyLo121 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1176.ffi).next = true
theorem bodyFacts121 : BodySiteFacts PRE_first_tail_x15_r0_body.s1174 PRE_first_tail_x15_r0_body.s1175 PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1174 PRE_first_tail_x15_r0_body.S1175 PRE_first_tail_x15_r0_body.S1176
    PRE_first_tail_x15_r0_body.ws121 PRE_first_tail_x15_r0_body.cws121 PRE_first_tail_x15_r0_body.nr121 PRE_first_tail_x15_r0_body.pl121 PRE_first_tail_x15_r0_body.cl121 2770121 5252 PRE_first_tail_x15_r0_body.kd121 PRE_first_tail_x15_r0_body.kappa121 PRE_first_tail_x15_r0_body.P121
    ⟨20592, 17688, 2770119, 5252⟩ ⟨20592, 17688, 2770119, 5252⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap121
  clean := bodyClean121
  cfix := PRE_first_tail_x15_r0_body.cfix121
  zpl := PRE_first_tail_x15_r0_body.zpl121
  zplnd := PRE_first_tail_x15_r0_body.zplnd121
  zn1 := PRE_first_tail_x15_r0_body.zn1121
  zfirst := PRE_first_tail_x15_r0_body.zfirst121
  zscn := PRE_first_tail_x15_r0_body.zscn121
  zsmn := PRE_first_tail_x15_r0_body.zsmn121
  zgrow := PRE_first_tail_x15_r0_body.zgrow121
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab121
  zfresh := PRE_first_tail_x15_r0_body.zfresh121
  zcnd := PRE_first_tail_x15_r0_body.zcnd121
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi121
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt121
  zgP := PRE_first_tail_x15_r0_body.zg121_2665
  zkP := PRE_first_tail_x15_r0_body.zk121_2665
  zmP := PRE_first_tail_x15_r0_body.zm121_2665
  zgC := PRE_first_tail_x15_r0_body.zg121_2673467
  zkC := PRE_first_tail_x15_r0_body.zk121_2673467
  zmC := PRE_first_tail_x15_r0_body.zm121_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw121_2673472
  zwV := PRE_first_tail_x15_r0_body.zw121_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap121
  zclbd := PRE_first_tail_x15_r0_body.zclbd121
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap121 PRE_first_tail_x15_r0_body.stFoot121 PRE_first_tail_x15_r0_body.iso121 PRE_first_tail_x15_r0_body.zwr121
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP121
  csupp := PRE_first_tail_x15_r0_body.csupp121
  cbound := PRE_first_tail_x15_r0_body.cbound121
  zimg := PRE_first_tail_x15_r0_body.zimg121
  zctl := PRE_first_tail_x15_r0_body.zctl121
  zstack := PRE_first_tail_x15_r0_body.zstack121
  zjobs := PRE_first_tail_x15_r0_body.zjobs121
  zstores := PRE_first_tail_x15_r0_body.zstores121
  zroots := PRE_first_tail_x15_r0_body.zroots121
  znC := PRE_first_tail_x15_r0_body.znC121
  ctab := PRE_first_tail_x15_r0_body.ctab121
  zbin := PRE_first_tail_x15_r0_body.zbin121
  cbridge := PRE_first_tail_x15_r0_body.cbridge121
  sbridge := bodyBridge121
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj121
  cshiftR := fun h hNL => bodyCshift121 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN121
  raised := PRE_first_tail_x15_r0_body.raised121
  cbigs := PRE_first_tail_x15_r0_body.cbigs121
  cjcl := PRE_first_tail_x15_r0_body.cjcl121
  xnLe := Nat.le_of_ble_eq_true bodyXn121
  loLe := Nat.le_of_ble_eq_true bodyLo121
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB121
  cntM := bodyCntM121
  hiLe := Nat.le_of_ble_eq_true bodyHi121
  nhiLe := Nat.le_of_ble_eq_true bodyNhi121
  jsHeap := bodyJs121
  jsRoots := bodyJsRoots121
  jsNative := bodyJsNative121
  framesEmpty := bodyFramesEmpty121
  trailOld := by decide
  lowVars := bodyLow121

def bodyQs121 : List (Option Q) := []
noncomputable def bodyEs121 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr121.map fun r => nth? PRE_first_tail_x15_r0_body.st121.S2.tab r
kernel_rfl bodyResChk121 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs121 bodyQs121) = true
kernel_rfl bodyLq121 : bodyQs121.length = PRE_first_tail_x15_r0_body.cws121.length
kernel_rfl bodyNrLo121 : PRE_first_tail_x15_r0_body.nr121.all (Nat.ble PRE_first_tail_x15_r0_body.S1174.tab.length) = true
kernel_rfl bodySub121 : (Oracles.PRE_first_tail_x15_r0_body.map_site121.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost121 : postSubB bodyM PRE_first_tail_x15_r0_body.ws121 PRE_first_tail_x15_r0_body.cws121 bodyQs121 = true
kernel_rfl bodyDrop121 : Nat.ble (43812 + (PRE_first_tail_x15_r0_body.s1175.next - PRE_first_tail_x15_r0_body.s1176.next)) 43814 = true
kernel_rfl bodyDropH121 : Nat.ble (816 + ((mlxOf PRE_first_tail_x15_r0_body.s1175.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1176.ffi).next)) 816 = true
kernel_rfl bodyDropN121 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1175.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1176.ffi).nnext)) 0 = true
kernel_rfl bodyDv121 : bodyΘ.1.take 648 = bodyΘ.1.take 648 ++ PRE_first_tail_x15_r0_body.cws121
kernel_rfl bodyDe121 : bodyΘ.2.take 648 = bodyΘ.2.take 648 ++ PRE_first_tail_x15_r0_body.nr121.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st121.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 648) (bodyΘ.2.take 648)))
kernel_rfl bodyDl121 : (bodyΘ.1.take 648).length = (bodyΘ.2.take 648).length
kernel_rfl bodyDold121 : (bodyΘ.1.take 648).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws121).isNone && !PRE_first_tail_x15_r0_body.ws121.contains v) = true
kernel_rfl bodyDfree121 : (bodyΘ.2.take 648).all (fun e => (PRE_first_tail_x15_r0_body.cws121 ++ PRE_first_tail_x15_r0_body.ws121).all fun w => e.noVar w) = true

theorem bodyStep121 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43812, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1174 PRE_first_tail_x15_r0_body.S1174)
      (bodyCut NB T tk π i x0 bodyΘ ⟨43814, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1176 PRE_first_tail_x15_r0_body.S1176) (27 + 1) :=
  bodySite bodyFacts121.cfix bodyFacts121.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st121.S2.tab) (Es := bodyEs121) (qs := bodyQs121)
    (ok := PRE_first_tail_x15_r0_body.st121.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site121 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts121
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site121 r hr) hi (MapOk.sub hm (sub_of_all bodySub121)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk121 r hr) hi hm ho hq)
    bodyLq121 rfl bodyNrLo121 (postSub_sound bodyPost121)
    (Nat.le_of_ble_eq_true bodyDrop121) (by decide) (Nat.le_of_ble_eq_true bodyDropH121) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN121) (by decide)
    bodyDv121 bodyDe121 bodyDl121 bodyDold121 bodyDfree121 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
