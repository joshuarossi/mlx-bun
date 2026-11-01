import host.sim.compose.a4b.vw15.VWBodyJ158
import host.sim.compose.a4b.vw15.VWBodySite158
import host.sim.compose.a4b.vw15.VWBodyOracles_39
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift158 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1523.tab.length PRE_first_tail_x15_r0_body.s1523.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P158.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P158 6808 PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.s1525.ffi PRE_first_tail_x15_r0_body.s1524.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_158
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_158
  have hcl : SSt (· < 6808) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1525.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1523.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_158] <;> decide) PRE_first_tail_x15_r0_body.cnodesK158 PRE_first_tail_x15_r0_body.cobjsK158
      PRE_first_tail_x15_r0_body.citemsK158 PRE_first_tail_x15_r0_body.cbd158 PRE_first_tail_x15_r0_body.csst158
  exact PRE_first_tail_x15_r0_body.cshift158 bodyNcl158 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_158] at this; exact this)


kernel_rfl bodyFramesEmpty158 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1524 a).isEmpty) = true
kernel_rfl bodyJsRoots158 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1523.next) PRE_first_tail_x15_r0_body.s1525.trace PRE_first_tail_x15_r0_body.s1525 = true
kernel_rfl bodyJsNative158 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1525.ffi) = true
kernel_rfl bodyLow158 : (PRE_first_tail_x15_r0_body.cws158 ++ PRE_first_tail_x15_r0_body.ws158).all (Nat.ble 9) = true
kernel_rfl bodyCntM158 : countersOkB PRE_first_tail_x15_r0_body.s1523 PRE_first_tail_x15_r0_body.s1524 = true
kernel_rfl bodyHi158 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1525.ffi).next setupP.E = true
kernel_rfl bodyNhi158 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1525.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge158 : bridgeOf PRE_first_tail_x15_r0_body.s1524.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1523.ffi
kernel_rfl bodyNN158 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1523.ffi).nnext PRE_first_tail_x15_r0_body.P158.NL = true
kernel_rfl bodyXn158 : Nat.ble (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1525.ffi).next = true
kernel_rfl bodyLo158 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1525.ffi).next = true
theorem bodyFacts158 : BodySiteFacts PRE_first_tail_x15_r0_body.s1523 PRE_first_tail_x15_r0_body.s1524 PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1523 PRE_first_tail_x15_r0_body.S1524 PRE_first_tail_x15_r0_body.S1525
    PRE_first_tail_x15_r0_body.ws158 PRE_first_tail_x15_r0_body.cws158 PRE_first_tail_x15_r0_body.nr158 PRE_first_tail_x15_r0_body.pl158 PRE_first_tail_x15_r0_body.cl158 2798674 6808 PRE_first_tail_x15_r0_body.kd158 PRE_first_tail_x15_r0_body.kappa158 PRE_first_tail_x15_r0_body.P158
    ⟨21307, 18403, 2798663, 6808⟩ ⟨21307, 18403, 2798664, 6808⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap158
  clean := bodyClean158
  cfix := PRE_first_tail_x15_r0_body.cfix158
  zpl := PRE_first_tail_x15_r0_body.zpl158
  zplnd := PRE_first_tail_x15_r0_body.zplnd158
  zn1 := PRE_first_tail_x15_r0_body.zn1158
  zfirst := PRE_first_tail_x15_r0_body.zfirst158
  zscn := PRE_first_tail_x15_r0_body.zscn158
  zsmn := PRE_first_tail_x15_r0_body.zsmn158
  zgrow := PRE_first_tail_x15_r0_body.zgrow158
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab158
  zfresh := PRE_first_tail_x15_r0_body.zfresh158
  zcnd := PRE_first_tail_x15_r0_body.zcnd158
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi158
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt158
  zgP := PRE_first_tail_x15_r0_body.zg158_2665
  zkP := PRE_first_tail_x15_r0_body.zk158_2665
  zmP := PRE_first_tail_x15_r0_body.zm158_2665
  zgC := PRE_first_tail_x15_r0_body.zg158_2673467
  zkC := PRE_first_tail_x15_r0_body.zk158_2673467
  zmC := PRE_first_tail_x15_r0_body.zm158_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw158_2673472
  zwV := PRE_first_tail_x15_r0_body.zw158_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap158
  zclbd := PRE_first_tail_x15_r0_body.zclbd158
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap158 PRE_first_tail_x15_r0_body.stFoot158 PRE_first_tail_x15_r0_body.iso158 PRE_first_tail_x15_r0_body.zwr158
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP158
  csupp := PRE_first_tail_x15_r0_body.csupp158
  cbound := PRE_first_tail_x15_r0_body.cbound158
  zimg := PRE_first_tail_x15_r0_body.zimg158
  zctl := PRE_first_tail_x15_r0_body.zctl158
  zstack := PRE_first_tail_x15_r0_body.zstack158
  zjobs := PRE_first_tail_x15_r0_body.zjobs158
  zstores := PRE_first_tail_x15_r0_body.zstores158
  zroots := PRE_first_tail_x15_r0_body.zroots158
  znC := PRE_first_tail_x15_r0_body.znC158
  ctab := PRE_first_tail_x15_r0_body.ctab158
  zbin := PRE_first_tail_x15_r0_body.zbin158
  cbridge := PRE_first_tail_x15_r0_body.cbridge158
  sbridge := bodyBridge158
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj158
  cshiftR := fun h hNL => bodyCshift158 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN158
  raised := PRE_first_tail_x15_r0_body.raised158
  cbigs := PRE_first_tail_x15_r0_body.cbigs158
  cjcl := PRE_first_tail_x15_r0_body.cjcl158
  xnLe := Nat.le_of_ble_eq_true bodyXn158
  loLe := Nat.le_of_ble_eq_true bodyLo158
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB158
  cntM := bodyCntM158
  hiLe := Nat.le_of_ble_eq_true bodyHi158
  nhiLe := Nat.le_of_ble_eq_true bodyNhi158
  jsHeap := bodyJs158
  jsRoots := bodyJsRoots158
  jsNative := bodyJsNative158
  framesEmpty := bodyFramesEmpty158
  trailOld := by decide
  lowVars := bodyLow158

def bodyQs158 : List (Option Q) := []
noncomputable def bodyEs158 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr158.map fun r => nth? PRE_first_tail_x15_r0_body.st158.S2.tab r
kernel_rfl bodyResChk158 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs158 bodyQs158) = true
kernel_rfl bodyLq158 : bodyQs158.length = PRE_first_tail_x15_r0_body.cws158.length
kernel_rfl bodyNrLo158 : PRE_first_tail_x15_r0_body.nr158.all (Nat.ble PRE_first_tail_x15_r0_body.S1523.tab.length) = true
kernel_rfl bodySub158 : (Oracles.PRE_first_tail_x15_r0_body.map_site158.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost158 : postSubB bodyM PRE_first_tail_x15_r0_body.ws158 PRE_first_tail_x15_r0_body.cws158 bodyQs158 = true
kernel_rfl bodyDrop158 : Nat.ble (55394 + (PRE_first_tail_x15_r0_body.s1524.next - PRE_first_tail_x15_r0_body.s1525.next)) 55404 = true
kernel_rfl bodyDropH158 : Nat.ble (1047 + ((mlxOf PRE_first_tail_x15_r0_body.s1524.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1525.ffi).next)) 1047 = true
kernel_rfl bodyDropN158 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1524.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1525.ffi).nnext)) 0 = true
kernel_rfl bodyDv158 : bodyΘ.1.take 837 = bodyΘ.1.take 837 ++ PRE_first_tail_x15_r0_body.cws158
kernel_rfl bodyDe158 : bodyΘ.2.take 837 = bodyΘ.2.take 837 ++ PRE_first_tail_x15_r0_body.nr158.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st158.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 837) (bodyΘ.2.take 837)))
kernel_rfl bodyDl158 : (bodyΘ.1.take 837).length = (bodyΘ.2.take 837).length
kernel_rfl bodyDold158 : (bodyΘ.1.take 837).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws158).isNone && !PRE_first_tail_x15_r0_body.ws158.contains v) = true
kernel_rfl bodyDfree158 : (bodyΘ.2.take 837).all (fun e => (PRE_first_tail_x15_r0_body.cws158 ++ PRE_first_tail_x15_r0_body.ws158).all fun w => e.noVar w) = true

theorem bodyStep158 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55394, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1523 PRE_first_tail_x15_r0_body.S1523)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55404, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.S1525) (98 + 1) :=
  bodySite bodyFacts158.cfix bodyFacts158.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st158.S2.tab) (Es := bodyEs158) (qs := bodyQs158)
    (ok := PRE_first_tail_x15_r0_body.st158.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site158 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts158
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site158 r hr) hi (MapOk.sub hm (sub_of_all bodySub158)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk158 r hr) hi hm ho hq)
    bodyLq158 rfl bodyNrLo158 (postSub_sound bodyPost158)
    (Nat.le_of_ble_eq_true bodyDrop158) (by decide) (Nat.le_of_ble_eq_true bodyDropH158) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN158) (by decide)
    bodyDv158 bodyDe158 bodyDl158 bodyDold158 bodyDfree158 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
