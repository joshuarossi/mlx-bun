import host.sim.compose.a4b.vw15.VWBodyJ4
import host.sim.compose.a4b.vw15.VWBodySite4
import host.sim.compose.a4b.vw15.VWBodyOracles_1
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift4 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S53.tab.length PRE_first_tail_x15_r0_body.s53.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P4.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P4 251 PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.s55.ffi PRE_first_tail_x15_r0_body.s54.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_4
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_4
  have hcl : SSt (· < 251) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s55.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S53.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_4] <;> decide) PRE_first_tail_x15_r0_body.cnodesK4 PRE_first_tail_x15_r0_body.cobjsK4
      PRE_first_tail_x15_r0_body.citemsK4 PRE_first_tail_x15_r0_body.cbd4 PRE_first_tail_x15_r0_body.csst4
  exact PRE_first_tail_x15_r0_body.cshift4 bodyNcl4 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_4] at this; exact this)


kernel_rfl bodyFramesEmpty4 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s54 a).isEmpty) = true
kernel_rfl bodyJsRoots4 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s53.next) PRE_first_tail_x15_r0_body.s55.trace PRE_first_tail_x15_r0_body.s55 = true
kernel_rfl bodyJsNative4 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s55.ffi) = true
kernel_rfl bodyLow4 : (PRE_first_tail_x15_r0_body.cws4 ++ PRE_first_tail_x15_r0_body.ws4).all (Nat.ble 9) = true
kernel_rfl bodyCntM4 : countersOkB PRE_first_tail_x15_r0_body.s53 PRE_first_tail_x15_r0_body.s54 = true
kernel_rfl bodyHi4 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s55.ffi).next setupP.E = true
kernel_rfl bodyNhi4 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s55.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge4 : bridgeOf PRE_first_tail_x15_r0_body.s54.ffi = bridgeOf PRE_first_tail_x15_r0_body.s53.ffi
kernel_rfl bodyNN4 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s53.ffi).nnext PRE_first_tail_x15_r0_body.P4.NL = true
kernel_rfl bodyXn4 : Nat.ble (⟨18286, 15381, 2678119, 251⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s55.ffi).next = true
kernel_rfl bodyLo4 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s55.ffi).next = true
theorem bodyFacts4 : BodySiteFacts PRE_first_tail_x15_r0_body.s53 PRE_first_tail_x15_r0_body.s54 PRE_first_tail_x15_r0_body.s55 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S53 PRE_first_tail_x15_r0_body.S54 PRE_first_tail_x15_r0_body.S55
    PRE_first_tail_x15_r0_body.ws4 PRE_first_tail_x15_r0_body.cws4 PRE_first_tail_x15_r0_body.nr4 PRE_first_tail_x15_r0_body.pl4 PRE_first_tail_x15_r0_body.cl4 2678121 251 PRE_first_tail_x15_r0_body.kd4 PRE_first_tail_x15_r0_body.kappa4 PRE_first_tail_x15_r0_body.P4
    ⟨18286, 15381, 2678119, 251⟩ ⟨18286, 15381, 2678119, 251⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap4
  clean := bodyClean4
  cfix := PRE_first_tail_x15_r0_body.cfix4
  zpl := PRE_first_tail_x15_r0_body.zpl4
  zplnd := PRE_first_tail_x15_r0_body.zplnd4
  zn1 := PRE_first_tail_x15_r0_body.zn14
  zfirst := PRE_first_tail_x15_r0_body.zfirst4
  zscn := PRE_first_tail_x15_r0_body.zscn4
  zsmn := PRE_first_tail_x15_r0_body.zsmn4
  zgrow := PRE_first_tail_x15_r0_body.zgrow4
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab4
  zfresh := PRE_first_tail_x15_r0_body.zfresh4
  zcnd := PRE_first_tail_x15_r0_body.zcnd4
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi4
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt4
  zgP := PRE_first_tail_x15_r0_body.zg4_2665
  zkP := PRE_first_tail_x15_r0_body.zk4_2665
  zmP := PRE_first_tail_x15_r0_body.zm4_2665
  zgC := PRE_first_tail_x15_r0_body.zg4_2673467
  zkC := PRE_first_tail_x15_r0_body.zk4_2673467
  zmC := PRE_first_tail_x15_r0_body.zm4_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw4_2673472
  zwV := PRE_first_tail_x15_r0_body.zw4_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap4
  zclbd := PRE_first_tail_x15_r0_body.zclbd4
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap4 PRE_first_tail_x15_r0_body.stFoot4 PRE_first_tail_x15_r0_body.iso4 PRE_first_tail_x15_r0_body.zwr4
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP4
  csupp := PRE_first_tail_x15_r0_body.csupp4
  cbound := PRE_first_tail_x15_r0_body.cbound4
  zimg := PRE_first_tail_x15_r0_body.zimg4
  zctl := PRE_first_tail_x15_r0_body.zctl4
  zstack := PRE_first_tail_x15_r0_body.zstack4
  zjobs := PRE_first_tail_x15_r0_body.zjobs4
  zstores := PRE_first_tail_x15_r0_body.zstores4
  zroots := PRE_first_tail_x15_r0_body.zroots4
  znC := PRE_first_tail_x15_r0_body.znC4
  ctab := PRE_first_tail_x15_r0_body.ctab4
  zbin := PRE_first_tail_x15_r0_body.zbin4
  cbridge := PRE_first_tail_x15_r0_body.cbridge4
  sbridge := bodyBridge4
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj4
  cshiftR := fun h hNL => bodyCshift4 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN4
  raised := PRE_first_tail_x15_r0_body.raised4
  cbigs := PRE_first_tail_x15_r0_body.cbigs4
  cjcl := PRE_first_tail_x15_r0_body.cjcl4
  xnLe := Nat.le_of_ble_eq_true bodyXn4
  loLe := Nat.le_of_ble_eq_true bodyLo4
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB4
  cntM := bodyCntM4
  hiLe := Nat.le_of_ble_eq_true bodyHi4
  nhiLe := Nat.le_of_ble_eq_true bodyNhi4
  jsHeap := bodyJs4
  jsRoots := bodyJsRoots4
  jsNative := bodyJsNative4
  framesEmpty := bodyFramesEmpty4
  trailOld := by decide
  lowVars := bodyLow4

def bodyQs4 : List (Option Q) := []
noncomputable def bodyEs4 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr4.map fun r => nth? PRE_first_tail_x15_r0_body.st4.S2.tab r
kernel_rfl bodyResChk4 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs4 bodyQs4) = true
kernel_rfl bodyLq4 : bodyQs4.length = PRE_first_tail_x15_r0_body.cws4.length
kernel_rfl bodyNrLo4 : PRE_first_tail_x15_r0_body.nr4.all (Nat.ble PRE_first_tail_x15_r0_body.S53.tab.length) = true
kernel_rfl bodySub4 : (Oracles.PRE_first_tail_x15_r0_body.map_site4.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost4 : postSubB bodyM PRE_first_tail_x15_r0_body.ws4 PRE_first_tail_x15_r0_body.cws4 bodyQs4 = true
kernel_rfl bodyDrop4 : Nat.ble (6433 + (PRE_first_tail_x15_r0_body.s54.next - PRE_first_tail_x15_r0_body.s55.next)) 6435 = true
kernel_rfl bodyDropH4 : Nat.ble (71 + ((mlxOf PRE_first_tail_x15_r0_body.s54.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s55.ffi).next)) 71 = true
kernel_rfl bodyDropN4 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s54.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s55.ffi).nnext)) 0 = true
kernel_rfl bodyDv4 : bodyΘ.1.take 36 = bodyΘ.1.take 36 ++ PRE_first_tail_x15_r0_body.cws4
kernel_rfl bodyDe4 : bodyΘ.2.take 36 = bodyΘ.2.take 36 ++ PRE_first_tail_x15_r0_body.nr4.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st4.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 36) (bodyΘ.2.take 36)))
kernel_rfl bodyDl4 : (bodyΘ.1.take 36).length = (bodyΘ.2.take 36).length
kernel_rfl bodyDold4 : (bodyΘ.1.take 36).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws4).isNone && !PRE_first_tail_x15_r0_body.ws4.contains v) = true
kernel_rfl bodyDfree4 : (bodyΘ.2.take 36).all (fun e => (PRE_first_tail_x15_r0_body.cws4 ++ PRE_first_tail_x15_r0_body.ws4).all fun w => e.noVar w) = true

theorem bodyStep4 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6433, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s53 PRE_first_tail_x15_r0_body.S53)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s55 PRE_first_tail_x15_r0_body.S55) (27 + 1) :=
  bodySite bodyFacts4.cfix bodyFacts4.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st4.S2.tab) (Es := bodyEs4) (qs := bodyQs4)
    (ok := PRE_first_tail_x15_r0_body.st4.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site4 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts4
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site4 r hr) hi (MapOk.sub hm (sub_of_all bodySub4)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk4 r hr) hi hm ho hq)
    bodyLq4 rfl bodyNrLo4 (postSub_sound bodyPost4)
    (Nat.le_of_ble_eq_true bodyDrop4) (by decide) (Nat.le_of_ble_eq_true bodyDropH4) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN4) (by decide)
    bodyDv4 bodyDe4 bodyDl4 bodyDold4 bodyDfree4 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
