import host.sim.compose.a4b.vw15.VWBodyJ76
import host.sim.compose.a4b.vw15.VWBodySite76
import host.sim.compose.a4b.vw15.VWBodyOracles_19
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift76 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S743.tab.length PRE_first_tail_x15_r0_body.s743.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P76.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P76 3329 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.s745.ffi PRE_first_tail_x15_r0_body.s744.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_76
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_76
  have hcl : SSt (· < 3329) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S743.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_76] <;> decide) PRE_first_tail_x15_r0_body.cnodesK76 PRE_first_tail_x15_r0_body.cobjsK76
      PRE_first_tail_x15_r0_body.citemsK76 PRE_first_tail_x15_r0_body.cbd76 PRE_first_tail_x15_r0_body.csst76
  exact PRE_first_tail_x15_r0_body.cshift76 bodyNcl76 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_76] at this; exact this)


kernel_rfl bodyFramesEmpty76 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s744 a).isEmpty) = true
kernel_rfl bodyJsRoots76 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s743.next) PRE_first_tail_x15_r0_body.s745.trace PRE_first_tail_x15_r0_body.s745 = true
kernel_rfl bodyJsNative76 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s745.ffi) = true
kernel_rfl bodyLow76 : (PRE_first_tail_x15_r0_body.cws76 ++ PRE_first_tail_x15_r0_body.ws76).all (Nat.ble 9) = true
kernel_rfl bodyCntM76 : countersOkB PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.s744 = true
kernel_rfl bodyHi76 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s745.ffi).next setupP.E = true
kernel_rfl bodyNhi76 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s745.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge76 : bridgeOf PRE_first_tail_x15_r0_body.s744.ffi = bridgeOf PRE_first_tail_x15_r0_body.s743.ffi
kernel_rfl bodyNN76 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s743.ffi).nnext PRE_first_tail_x15_r0_body.P76.NL = true
kernel_rfl bodyXn76 : Nat.ble (⟨19705, 16803, 2734711, 3329⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s745.ffi).next = true
kernel_rfl bodyLo76 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s745.ffi).next = true
theorem bodyFacts76 : BodySiteFacts PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.s744 PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S743 PRE_first_tail_x15_r0_body.S744 PRE_first_tail_x15_r0_body.S745
    PRE_first_tail_x15_r0_body.ws76 PRE_first_tail_x15_r0_body.cws76 PRE_first_tail_x15_r0_body.nr76 PRE_first_tail_x15_r0_body.pl76 PRE_first_tail_x15_r0_body.cl76 2734713 3329 PRE_first_tail_x15_r0_body.kd76 PRE_first_tail_x15_r0_body.kappa76 PRE_first_tail_x15_r0_body.P76
    ⟨19705, 16803, 2734711, 3329⟩ ⟨19705, 16803, 2734711, 3329⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap76
  clean := bodyClean76
  cfix := PRE_first_tail_x15_r0_body.cfix76
  zpl := PRE_first_tail_x15_r0_body.zpl76
  zplnd := PRE_first_tail_x15_r0_body.zplnd76
  zn1 := PRE_first_tail_x15_r0_body.zn176
  zfirst := PRE_first_tail_x15_r0_body.zfirst76
  zscn := PRE_first_tail_x15_r0_body.zscn76
  zsmn := PRE_first_tail_x15_r0_body.zsmn76
  zgrow := PRE_first_tail_x15_r0_body.zgrow76
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab76
  zfresh := PRE_first_tail_x15_r0_body.zfresh76
  zcnd := PRE_first_tail_x15_r0_body.zcnd76
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi76
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt76
  zgP := PRE_first_tail_x15_r0_body.zg76_2665
  zkP := PRE_first_tail_x15_r0_body.zk76_2665
  zmP := PRE_first_tail_x15_r0_body.zm76_2665
  zgC := PRE_first_tail_x15_r0_body.zg76_2673467
  zkC := PRE_first_tail_x15_r0_body.zk76_2673467
  zmC := PRE_first_tail_x15_r0_body.zm76_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw76_2673472
  zwV := PRE_first_tail_x15_r0_body.zw76_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap76
  zclbd := PRE_first_tail_x15_r0_body.zclbd76
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap76 PRE_first_tail_x15_r0_body.stFoot76 PRE_first_tail_x15_r0_body.iso76 PRE_first_tail_x15_r0_body.zwr76
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP76
  csupp := PRE_first_tail_x15_r0_body.csupp76
  cbound := PRE_first_tail_x15_r0_body.cbound76
  zimg := PRE_first_tail_x15_r0_body.zimg76
  zctl := PRE_first_tail_x15_r0_body.zctl76
  zstack := PRE_first_tail_x15_r0_body.zstack76
  zjobs := PRE_first_tail_x15_r0_body.zjobs76
  zstores := PRE_first_tail_x15_r0_body.zstores76
  zroots := PRE_first_tail_x15_r0_body.zroots76
  znC := PRE_first_tail_x15_r0_body.znC76
  ctab := PRE_first_tail_x15_r0_body.ctab76
  zbin := PRE_first_tail_x15_r0_body.zbin76
  cbridge := PRE_first_tail_x15_r0_body.cbridge76
  sbridge := bodyBridge76
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj76
  cshiftR := fun h hNL => bodyCshift76 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN76
  raised := PRE_first_tail_x15_r0_body.raised76
  cbigs := PRE_first_tail_x15_r0_body.cbigs76
  cjcl := PRE_first_tail_x15_r0_body.cjcl76
  xnLe := Nat.le_of_ble_eq_true bodyXn76
  loLe := Nat.le_of_ble_eq_true bodyLo76
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB76
  cntM := bodyCntM76
  hiLe := Nat.le_of_ble_eq_true bodyHi76
  nhiLe := Nat.le_of_ble_eq_true bodyNhi76
  jsHeap := bodyJs76
  jsRoots := bodyJsRoots76
  jsNative := bodyJsNative76
  framesEmpty := bodyFramesEmpty76
  trailOld := by decide
  lowVars := bodyLow76

def bodyQs76 : List (Option Q) := []
noncomputable def bodyEs76 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr76.map fun r => nth? PRE_first_tail_x15_r0_body.st76.S2.tab r
kernel_rfl bodyResChk76 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs76 bodyQs76) = true
kernel_rfl bodyLq76 : bodyQs76.length = PRE_first_tail_x15_r0_body.cws76.length
kernel_rfl bodyNrLo76 : PRE_first_tail_x15_r0_body.nr76.all (Nat.ble PRE_first_tail_x15_r0_body.S743.tab.length) = true
kernel_rfl bodySub76 : (Oracles.PRE_first_tail_x15_r0_body.map_site76.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost76 : postSubB bodyM PRE_first_tail_x15_r0_body.ws76 PRE_first_tail_x15_r0_body.cws76 bodyQs76 = true
kernel_rfl bodyDrop76 : Nat.ble (29557 + (PRE_first_tail_x15_r0_body.s744.next - PRE_first_tail_x15_r0_body.s745.next)) 29559 = true
kernel_rfl bodyDropH76 : Nat.ble (533 + ((mlxOf PRE_first_tail_x15_r0_body.s744.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s745.ffi).next)) 533 = true
kernel_rfl bodyDropN76 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s744.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s745.ffi).nnext)) 0 = true
kernel_rfl bodyDv76 : bodyΘ.1.take 414 = bodyΘ.1.take 414 ++ PRE_first_tail_x15_r0_body.cws76
kernel_rfl bodyDe76 : bodyΘ.2.take 414 = bodyΘ.2.take 414 ++ PRE_first_tail_x15_r0_body.nr76.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st76.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 414) (bodyΘ.2.take 414)))
kernel_rfl bodyDl76 : (bodyΘ.1.take 414).length = (bodyΘ.2.take 414).length
kernel_rfl bodyDold76 : (bodyΘ.1.take 414).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws76).isNone && !PRE_first_tail_x15_r0_body.ws76.contains v) = true
kernel_rfl bodyDfree76 : (bodyΘ.2.take 414).all (fun e => (PRE_first_tail_x15_r0_body.cws76 ++ PRE_first_tail_x15_r0_body.ws76).all fun w => e.noVar w) = true

theorem bodyStep76 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29557, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.S743)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29559, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.S745) (27 + 1) :=
  bodySite bodyFacts76.cfix bodyFacts76.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st76.S2.tab) (Es := bodyEs76) (qs := bodyQs76)
    (ok := PRE_first_tail_x15_r0_body.st76.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site76 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts76
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site76 r hr) hi (MapOk.sub hm (sub_of_all bodySub76)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk76 r hr) hi hm ho hq)
    bodyLq76 rfl bodyNrLo76 (postSub_sound bodyPost76)
    (Nat.le_of_ble_eq_true bodyDrop76) (by decide) (Nat.le_of_ble_eq_true bodyDropH76) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN76) (by decide)
    bodyDv76 bodyDe76 bodyDl76 bodyDold76 bodyDfree76 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
