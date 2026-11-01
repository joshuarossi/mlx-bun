import host.sim.compose.a4b.vw15.VWBodyJ50
import host.sim.compose.a4b.vw15.VWBodySite50
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

theorem bodyCshift50 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S488.tab.length PRE_first_tail_x15_r0_body.s488.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P50.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P50 2191 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.s490.ffi PRE_first_tail_x15_r0_body.s489.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_50
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_50
  have hcl : SSt (· < 2191) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S488.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_50] <;> decide) PRE_first_tail_x15_r0_body.cnodesK50 PRE_first_tail_x15_r0_body.cobjsK50
      PRE_first_tail_x15_r0_body.citemsK50 PRE_first_tail_x15_r0_body.cbd50 PRE_first_tail_x15_r0_body.csst50
  exact PRE_first_tail_x15_r0_body.cshift50 bodyNcl50 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_50] at this; exact this)


kernel_rfl bodyFramesEmpty50 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s489 a).isEmpty) = true
kernel_rfl bodyJsRoots50 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s488.next) PRE_first_tail_x15_r0_body.s490.trace PRE_first_tail_x15_r0_body.s490 = true
kernel_rfl bodyJsNative50 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s490.ffi) = true
kernel_rfl bodyLow50 : (PRE_first_tail_x15_r0_body.cws50 ++ PRE_first_tail_x15_r0_body.ws50).all (Nat.ble 9) = true
kernel_rfl bodyCntM50 : countersOkB PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.s489 = true
kernel_rfl bodyHi50 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next setupP.E = true
kernel_rfl bodyNhi50 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge50 : bridgeOf PRE_first_tail_x15_r0_body.s489.ffi = bridgeOf PRE_first_tail_x15_r0_body.s488.ffi
kernel_rfl bodyNN50 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s488.ffi).nnext PRE_first_tail_x15_r0_body.P50.NL = true
kernel_rfl bodyXn50 : Nat.ble (⟨19183, 16270, 2713908, 2191⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next = true
kernel_rfl bodyLo50 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next = true
theorem bodyFacts50 : BodySiteFacts PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.s489 PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S488 PRE_first_tail_x15_r0_body.S489 PRE_first_tail_x15_r0_body.S490
    PRE_first_tail_x15_r0_body.ws50 PRE_first_tail_x15_r0_body.cws50 PRE_first_tail_x15_r0_body.nr50 PRE_first_tail_x15_r0_body.pl50 PRE_first_tail_x15_r0_body.cl50 2713927 2191 PRE_first_tail_x15_r0_body.kd50 PRE_first_tail_x15_r0_body.kappa50 PRE_first_tail_x15_r0_body.P50
    ⟨19183, 16270, 2713907, 2191⟩ ⟨19183, 16270, 2713908, 2191⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap50
  clean := bodyClean50
  cfix := PRE_first_tail_x15_r0_body.cfix50
  zpl := PRE_first_tail_x15_r0_body.zpl50
  zplnd := PRE_first_tail_x15_r0_body.zplnd50
  zn1 := PRE_first_tail_x15_r0_body.zn150
  zfirst := PRE_first_tail_x15_r0_body.zfirst50
  zscn := PRE_first_tail_x15_r0_body.zscn50
  zsmn := PRE_first_tail_x15_r0_body.zsmn50
  zgrow := PRE_first_tail_x15_r0_body.zgrow50
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab50
  zfresh := PRE_first_tail_x15_r0_body.zfresh50
  zcnd := PRE_first_tail_x15_r0_body.zcnd50
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi50
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt50
  zgP := PRE_first_tail_x15_r0_body.zg50_2665
  zkP := PRE_first_tail_x15_r0_body.zk50_2665
  zmP := PRE_first_tail_x15_r0_body.zm50_2665
  zgC := PRE_first_tail_x15_r0_body.zg50_2673467
  zkC := PRE_first_tail_x15_r0_body.zk50_2673467
  zmC := PRE_first_tail_x15_r0_body.zm50_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw50_2673472
  zwV := PRE_first_tail_x15_r0_body.zw50_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap50
  zclbd := PRE_first_tail_x15_r0_body.zclbd50
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap50 PRE_first_tail_x15_r0_body.stFoot50 PRE_first_tail_x15_r0_body.iso50 PRE_first_tail_x15_r0_body.zwr50
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP50
  csupp := PRE_first_tail_x15_r0_body.csupp50
  cbound := PRE_first_tail_x15_r0_body.cbound50
  zimg := PRE_first_tail_x15_r0_body.zimg50
  zctl := PRE_first_tail_x15_r0_body.zctl50
  zstack := PRE_first_tail_x15_r0_body.zstack50
  zjobs := PRE_first_tail_x15_r0_body.zjobs50
  zstores := PRE_first_tail_x15_r0_body.zstores50
  zroots := PRE_first_tail_x15_r0_body.zroots50
  znC := PRE_first_tail_x15_r0_body.znC50
  ctab := PRE_first_tail_x15_r0_body.ctab50
  zbin := PRE_first_tail_x15_r0_body.zbin50
  cbridge := PRE_first_tail_x15_r0_body.cbridge50
  sbridge := bodyBridge50
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj50
  cshiftR := fun h hNL => bodyCshift50 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN50
  raised := PRE_first_tail_x15_r0_body.raised50
  cbigs := PRE_first_tail_x15_r0_body.cbigs50
  cjcl := PRE_first_tail_x15_r0_body.cjcl50
  xnLe := Nat.le_of_ble_eq_true bodyXn50
  loLe := Nat.le_of_ble_eq_true bodyLo50
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB50
  cntM := bodyCntM50
  hiLe := Nat.le_of_ble_eq_true bodyHi50
  nhiLe := Nat.le_of_ble_eq_true bodyNhi50
  jsHeap := bodyJs50
  jsRoots := bodyJsRoots50
  jsNative := bodyJsNative50
  framesEmpty := bodyFramesEmpty50
  trailOld := by decide
  lowVars := bodyLow50

def bodyQs50 : List (Option Q) := []
noncomputable def bodyEs50 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr50.map fun r => nth? PRE_first_tail_x15_r0_body.st50.S2.tab r
kernel_rfl bodyResChk50 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs50 bodyQs50) = true
kernel_rfl bodyLq50 : bodyQs50.length = PRE_first_tail_x15_r0_body.cws50.length
kernel_rfl bodyNrLo50 : PRE_first_tail_x15_r0_body.nr50.all (Nat.ble PRE_first_tail_x15_r0_body.S488.tab.length) = true
kernel_rfl bodySub50 : (Oracles.PRE_first_tail_x15_r0_body.map_site50.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost50 : postSubB bodyM PRE_first_tail_x15_r0_body.ws50 PRE_first_tail_x15_r0_body.cws50 bodyQs50 = true
kernel_rfl bodyDrop50 : Nat.ble (20681 + (PRE_first_tail_x15_r0_body.s489.next - PRE_first_tail_x15_r0_body.s490.next)) 20700 = true
kernel_rfl bodyDropH50 : Nat.ble (354 + ((mlxOf PRE_first_tail_x15_r0_body.s489.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).next)) 354 = true
kernel_rfl bodyDropN50 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s489.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s490.ffi).nnext)) 0 = true
kernel_rfl bodyDv50 : bodyΘ.1.take 270 = bodyΘ.1.take 270 ++ PRE_first_tail_x15_r0_body.cws50
kernel_rfl bodyDe50 : bodyΘ.2.take 270 = bodyΘ.2.take 270 ++ PRE_first_tail_x15_r0_body.nr50.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st50.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 270) (bodyΘ.2.take 270)))
kernel_rfl bodyDl50 : (bodyΘ.1.take 270).length = (bodyΘ.2.take 270).length
kernel_rfl bodyDold50 : (bodyΘ.1.take 270).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws50).isNone && !PRE_first_tail_x15_r0_body.ws50.contains v) = true
kernel_rfl bodyDfree50 : (bodyΘ.2.take 270).all (fun e => (PRE_first_tail_x15_r0_body.cws50 ++ PRE_first_tail_x15_r0_body.ws50).all fun w => e.noVar w) = true

theorem bodyStep50 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.S488)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.S490) (206 + 1) :=
  bodySite bodyFacts50.cfix bodyFacts50.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st50.S2.tab) (Es := bodyEs50) (qs := bodyQs50)
    (ok := PRE_first_tail_x15_r0_body.st50.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site50 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts50
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site50 r hr) hi (MapOk.sub hm (sub_of_all bodySub50)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk50 r hr) hi hm ho hq)
    bodyLq50 rfl bodyNrLo50 (postSub_sound bodyPost50)
    (Nat.le_of_ble_eq_true bodyDrop50) (by decide) (Nat.le_of_ble_eq_true bodyDropH50) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN50) (by decide)
    bodyDv50 bodyDe50 bodyDl50 bodyDold50 bodyDfree50 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
