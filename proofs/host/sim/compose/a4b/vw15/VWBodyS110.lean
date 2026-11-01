import host.sim.compose.a4b.vw15.VWBodyJ110
import host.sim.compose.a4b.vw15.VWBodySite110
import host.sim.compose.a4b.vw15.VWBodyOracles_27
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

theorem bodyCshift110 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1063.tab.length PRE_first_tail_x15_r0_body.s1063.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P110.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P110 4756 PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.s1065.ffi PRE_first_tail_x15_r0_body.s1064.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_110
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_110
  have hcl : SSt (· < 4756) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1063.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_110] <;> decide) PRE_first_tail_x15_r0_body.cnodesK110 PRE_first_tail_x15_r0_body.cobjsK110
      PRE_first_tail_x15_r0_body.citemsK110 PRE_first_tail_x15_r0_body.cbd110 PRE_first_tail_x15_r0_body.csst110
  exact PRE_first_tail_x15_r0_body.cshift110 bodyNcl110 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_110] at this; exact this)


kernel_rfl bodyFramesEmpty110 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1064 a).isEmpty) = true
kernel_rfl bodyJsRoots110 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1063.next) PRE_first_tail_x15_r0_body.s1065.trace PRE_first_tail_x15_r0_body.s1065 = true
kernel_rfl bodyJsNative110 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1065.ffi) = true
kernel_rfl bodyLow110 : (PRE_first_tail_x15_r0_body.cws110 ++ PRE_first_tail_x15_r0_body.ws110).all (Nat.ble 9) = true
kernel_rfl bodyCntM110 : countersOkB PRE_first_tail_x15_r0_body.s1063 PRE_first_tail_x15_r0_body.s1064 = true
kernel_rfl bodyHi110 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1065.ffi).next setupP.E = true
kernel_rfl bodyNhi110 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1065.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge110 : bridgeOf PRE_first_tail_x15_r0_body.s1064.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1063.ffi
kernel_rfl bodyNN110 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1063.ffi).nnext PRE_first_tail_x15_r0_body.P110.NL = true
kernel_rfl bodyXn110 : Nat.ble (⟨20363, 17455, 2760996, 4756⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1065.ffi).next = true
kernel_rfl bodyLo110 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1065.ffi).next = true
theorem bodyFacts110 : BodySiteFacts PRE_first_tail_x15_r0_body.s1063 PRE_first_tail_x15_r0_body.s1064 PRE_first_tail_x15_r0_body.s1065 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1063 PRE_first_tail_x15_r0_body.S1064 PRE_first_tail_x15_r0_body.S1065
    PRE_first_tail_x15_r0_body.ws110 PRE_first_tail_x15_r0_body.cws110 PRE_first_tail_x15_r0_body.nr110 PRE_first_tail_x15_r0_body.pl110 PRE_first_tail_x15_r0_body.cl110 2761006 4756 PRE_first_tail_x15_r0_body.kd110 PRE_first_tail_x15_r0_body.kappa110 PRE_first_tail_x15_r0_body.P110
    ⟨20363, 17455, 2760995, 4756⟩ ⟨20363, 17455, 2760996, 4756⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap110
  clean := bodyClean110
  cfix := PRE_first_tail_x15_r0_body.cfix110
  zpl := PRE_first_tail_x15_r0_body.zpl110
  zplnd := PRE_first_tail_x15_r0_body.zplnd110
  zn1 := PRE_first_tail_x15_r0_body.zn1110
  zfirst := PRE_first_tail_x15_r0_body.zfirst110
  zscn := PRE_first_tail_x15_r0_body.zscn110
  zsmn := PRE_first_tail_x15_r0_body.zsmn110
  zgrow := PRE_first_tail_x15_r0_body.zgrow110
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab110
  zfresh := PRE_first_tail_x15_r0_body.zfresh110
  zcnd := PRE_first_tail_x15_r0_body.zcnd110
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi110
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt110
  zgP := PRE_first_tail_x15_r0_body.zg110_2665
  zkP := PRE_first_tail_x15_r0_body.zk110_2665
  zmP := PRE_first_tail_x15_r0_body.zm110_2665
  zgC := PRE_first_tail_x15_r0_body.zg110_2673467
  zkC := PRE_first_tail_x15_r0_body.zk110_2673467
  zmC := PRE_first_tail_x15_r0_body.zm110_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw110_2673472
  zwV := PRE_first_tail_x15_r0_body.zw110_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap110
  zclbd := PRE_first_tail_x15_r0_body.zclbd110
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap110 PRE_first_tail_x15_r0_body.stFoot110 PRE_first_tail_x15_r0_body.iso110 PRE_first_tail_x15_r0_body.zwr110
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP110
  csupp := PRE_first_tail_x15_r0_body.csupp110
  cbound := PRE_first_tail_x15_r0_body.cbound110
  zimg := PRE_first_tail_x15_r0_body.zimg110
  zctl := PRE_first_tail_x15_r0_body.zctl110
  zstack := PRE_first_tail_x15_r0_body.zstack110
  zjobs := PRE_first_tail_x15_r0_body.zjobs110
  zstores := PRE_first_tail_x15_r0_body.zstores110
  zroots := PRE_first_tail_x15_r0_body.zroots110
  znC := PRE_first_tail_x15_r0_body.znC110
  ctab := PRE_first_tail_x15_r0_body.ctab110
  zbin := PRE_first_tail_x15_r0_body.zbin110
  cbridge := PRE_first_tail_x15_r0_body.cbridge110
  sbridge := bodyBridge110
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj110
  cshiftR := fun h hNL => bodyCshift110 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN110
  raised := PRE_first_tail_x15_r0_body.raised110
  cbigs := PRE_first_tail_x15_r0_body.cbigs110
  cjcl := PRE_first_tail_x15_r0_body.cjcl110
  xnLe := Nat.le_of_ble_eq_true bodyXn110
  loLe := Nat.le_of_ble_eq_true bodyLo110
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB110
  cntM := bodyCntM110
  hiLe := Nat.le_of_ble_eq_true bodyHi110
  nhiLe := Nat.le_of_ble_eq_true bodyNhi110
  jsHeap := bodyJs110
  jsRoots := bodyJsRoots110
  jsNative := bodyJsNative110
  framesEmpty := bodyFramesEmpty110
  trailOld := by decide
  lowVars := bodyLow110

def bodyQs110 : List (Option Q) := []
noncomputable def bodyEs110 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr110.map fun r => nth? PRE_first_tail_x15_r0_body.st110.S2.tab r
kernel_rfl bodyResChk110 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs110 bodyQs110) = true
kernel_rfl bodyLq110 : bodyQs110.length = PRE_first_tail_x15_r0_body.cws110.length
kernel_rfl bodyNrLo110 : PRE_first_tail_x15_r0_body.nr110.all (Nat.ble PRE_first_tail_x15_r0_body.S1063.tab.length) = true
kernel_rfl bodySub110 : (Oracles.PRE_first_tail_x15_r0_body.map_site110.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost110 : postSubB bodyM PRE_first_tail_x15_r0_body.ws110 PRE_first_tail_x15_r0_body.cws110 bodyQs110 = true
kernel_rfl bodyDrop110 : Nat.ble (39969 + (PRE_first_tail_x15_r0_body.s1064.next - PRE_first_tail_x15_r0_body.s1065.next)) 39979 = true
kernel_rfl bodyDropH110 : Nat.ble (739 + ((mlxOf PRE_first_tail_x15_r0_body.s1064.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1065.ffi).next)) 739 = true
kernel_rfl bodyDropN110 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1064.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1065.ffi).nnext)) 0 = true
kernel_rfl bodyDv110 : bodyΘ.1.take 585 = bodyΘ.1.take 585 ++ PRE_first_tail_x15_r0_body.cws110
kernel_rfl bodyDe110 : bodyΘ.2.take 585 = bodyΘ.2.take 585 ++ PRE_first_tail_x15_r0_body.nr110.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st110.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 585) (bodyΘ.2.take 585)))
kernel_rfl bodyDl110 : (bodyΘ.1.take 585).length = (bodyΘ.2.take 585).length
kernel_rfl bodyDold110 : (bodyΘ.1.take 585).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws110).isNone && !PRE_first_tail_x15_r0_body.ws110.contains v) = true
kernel_rfl bodyDfree110 : (bodyΘ.2.take 585).all (fun e => (PRE_first_tail_x15_r0_body.cws110 ++ PRE_first_tail_x15_r0_body.ws110).all fun w => e.noVar w) = true

theorem bodyStep110 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨39969, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1063 PRE_first_tail_x15_r0_body.S1063)
      (bodyCut NB T tk π i x0 bodyΘ ⟨39979, 739, 0, 585⟩ bodyM PRE_first_tail_x15_r0_body.s1065 PRE_first_tail_x15_r0_body.S1065) (98 + 1) :=
  bodySite bodyFacts110.cfix bodyFacts110.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st110.S2.tab) (Es := bodyEs110) (qs := bodyQs110)
    (ok := PRE_first_tail_x15_r0_body.st110.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site110 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts110
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site110 r hr) hi (MapOk.sub hm (sub_of_all bodySub110)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk110 r hr) hi hm ho hq)
    bodyLq110 rfl bodyNrLo110 (postSub_sound bodyPost110)
    (Nat.le_of_ble_eq_true bodyDrop110) (by decide) (Nat.le_of_ble_eq_true bodyDropH110) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN110) (by decide)
    bodyDv110 bodyDe110 bodyDl110 bodyDold110 bodyDfree110 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
