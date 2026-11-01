import host.sim.compose.a4b.vw15.VWBodyJ118
import host.sim.compose.a4b.vw15.VWBodySite118
import host.sim.compose.a4b.vw15.VWBodyOracles_29
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

theorem bodyCshift118 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1145.tab.length PRE_first_tail_x15_r0_body.s1145.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P118.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P118 5123 PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.s1147.ffi PRE_first_tail_x15_r0_body.s1146.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_118
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_118
  have hcl : SSt (· < 5123) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1147.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1145.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_118] <;> decide) PRE_first_tail_x15_r0_body.cnodesK118 PRE_first_tail_x15_r0_body.cobjsK118
      PRE_first_tail_x15_r0_body.citemsK118 PRE_first_tail_x15_r0_body.cbd118 PRE_first_tail_x15_r0_body.csst118
  exact PRE_first_tail_x15_r0_body.cshift118 bodyNcl118 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_118] at this; exact this)


kernel_rfl bodyFramesEmpty118 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1146 a).isEmpty) = true
kernel_rfl bodyJsRoots118 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1145.next) PRE_first_tail_x15_r0_body.s1147.trace PRE_first_tail_x15_r0_body.s1147 = true
kernel_rfl bodyJsNative118 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1147.ffi) = true
kernel_rfl bodyLow118 : (PRE_first_tail_x15_r0_body.cws118 ++ PRE_first_tail_x15_r0_body.ws118).all (Nat.ble 9) = true
kernel_rfl bodyCntM118 : countersOkB PRE_first_tail_x15_r0_body.s1145 PRE_first_tail_x15_r0_body.s1146 = true
kernel_rfl bodyHi118 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1147.ffi).next setupP.E = true
kernel_rfl bodyNhi118 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1147.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge118 : bridgeOf PRE_first_tail_x15_r0_body.s1146.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1145.ffi
kernel_rfl bodyNN118 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1145.ffi).nnext PRE_first_tail_x15_r0_body.P118.NL = true
kernel_rfl bodyXn118 : Nat.ble (⟨20534, 17625, 2767841, 5123⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1147.ffi).next = true
kernel_rfl bodyLo118 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1147.ffi).next = true
theorem bodyFacts118 : BodySiteFacts PRE_first_tail_x15_r0_body.s1145 PRE_first_tail_x15_r0_body.s1146 PRE_first_tail_x15_r0_body.s1147 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1145 PRE_first_tail_x15_r0_body.S1146 PRE_first_tail_x15_r0_body.S1147
    PRE_first_tail_x15_r0_body.ws118 PRE_first_tail_x15_r0_body.cws118 PRE_first_tail_x15_r0_body.nr118 PRE_first_tail_x15_r0_body.pl118 PRE_first_tail_x15_r0_body.cl118 2767843 5123 PRE_first_tail_x15_r0_body.kd118 PRE_first_tail_x15_r0_body.kappa118 PRE_first_tail_x15_r0_body.P118
    ⟨20534, 17625, 2767841, 5123⟩ ⟨20534, 17625, 2767841, 5123⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap118
  clean := bodyClean118
  cfix := PRE_first_tail_x15_r0_body.cfix118
  zpl := PRE_first_tail_x15_r0_body.zpl118
  zplnd := PRE_first_tail_x15_r0_body.zplnd118
  zn1 := PRE_first_tail_x15_r0_body.zn1118
  zfirst := PRE_first_tail_x15_r0_body.zfirst118
  zscn := PRE_first_tail_x15_r0_body.zscn118
  zsmn := PRE_first_tail_x15_r0_body.zsmn118
  zgrow := PRE_first_tail_x15_r0_body.zgrow118
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab118
  zfresh := PRE_first_tail_x15_r0_body.zfresh118
  zcnd := PRE_first_tail_x15_r0_body.zcnd118
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi118
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt118
  zgP := PRE_first_tail_x15_r0_body.zg118_2665
  zkP := PRE_first_tail_x15_r0_body.zk118_2665
  zmP := PRE_first_tail_x15_r0_body.zm118_2665
  zgC := PRE_first_tail_x15_r0_body.zg118_2673467
  zkC := PRE_first_tail_x15_r0_body.zk118_2673467
  zmC := PRE_first_tail_x15_r0_body.zm118_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw118_2673472
  zwV := PRE_first_tail_x15_r0_body.zw118_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap118
  zclbd := PRE_first_tail_x15_r0_body.zclbd118
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap118 PRE_first_tail_x15_r0_body.stFoot118 PRE_first_tail_x15_r0_body.iso118 PRE_first_tail_x15_r0_body.zwr118
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP118
  csupp := PRE_first_tail_x15_r0_body.csupp118
  cbound := PRE_first_tail_x15_r0_body.cbound118
  zimg := PRE_first_tail_x15_r0_body.zimg118
  zctl := PRE_first_tail_x15_r0_body.zctl118
  zstack := PRE_first_tail_x15_r0_body.zstack118
  zjobs := PRE_first_tail_x15_r0_body.zjobs118
  zstores := PRE_first_tail_x15_r0_body.zstores118
  zroots := PRE_first_tail_x15_r0_body.zroots118
  znC := PRE_first_tail_x15_r0_body.znC118
  ctab := PRE_first_tail_x15_r0_body.ctab118
  zbin := PRE_first_tail_x15_r0_body.zbin118
  cbridge := PRE_first_tail_x15_r0_body.cbridge118
  sbridge := bodyBridge118
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj118
  cshiftR := fun h hNL => bodyCshift118 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN118
  raised := PRE_first_tail_x15_r0_body.raised118
  cbigs := PRE_first_tail_x15_r0_body.cbigs118
  cjcl := PRE_first_tail_x15_r0_body.cjcl118
  xnLe := Nat.le_of_ble_eq_true bodyXn118
  loLe := Nat.le_of_ble_eq_true bodyLo118
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB118
  cntM := bodyCntM118
  hiLe := Nat.le_of_ble_eq_true bodyHi118
  nhiLe := Nat.le_of_ble_eq_true bodyNhi118
  jsHeap := bodyJs118
  jsRoots := bodyJsRoots118
  jsNative := bodyJsNative118
  framesEmpty := bodyFramesEmpty118
  trailOld := by decide
  lowVars := bodyLow118

def bodyQs118 : List (Option Q) := []
noncomputable def bodyEs118 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr118.map fun r => nth? PRE_first_tail_x15_r0_body.st118.S2.tab r
kernel_rfl bodyResChk118 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs118 bodyQs118) = true
kernel_rfl bodyLq118 : bodyQs118.length = PRE_first_tail_x15_r0_body.cws118.length
kernel_rfl bodyNrLo118 : PRE_first_tail_x15_r0_body.nr118.all (Nat.ble PRE_first_tail_x15_r0_body.S1145.tab.length) = true
kernel_rfl bodySub118 : (Oracles.PRE_first_tail_x15_r0_body.map_site118.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost118 : postSubB bodyM PRE_first_tail_x15_r0_body.ws118 PRE_first_tail_x15_r0_body.cws118 bodyQs118 = true
kernel_rfl bodyDrop118 : Nat.ble (42651 + (PRE_first_tail_x15_r0_body.s1146.next - PRE_first_tail_x15_r0_body.s1147.next)) 42653 = true
kernel_rfl bodyDropH118 : Nat.ble (791 + ((mlxOf PRE_first_tail_x15_r0_body.s1146.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1147.ffi).next)) 791 = true
kernel_rfl bodyDropN118 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1146.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1147.ffi).nnext)) 0 = true
kernel_rfl bodyDv118 : bodyΘ.1.take 630 = bodyΘ.1.take 630 ++ PRE_first_tail_x15_r0_body.cws118
kernel_rfl bodyDe118 : bodyΘ.2.take 630 = bodyΘ.2.take 630 ++ PRE_first_tail_x15_r0_body.nr118.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st118.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 630) (bodyΘ.2.take 630)))
kernel_rfl bodyDl118 : (bodyΘ.1.take 630).length = (bodyΘ.2.take 630).length
kernel_rfl bodyDold118 : (bodyΘ.1.take 630).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws118).isNone && !PRE_first_tail_x15_r0_body.ws118.contains v) = true
kernel_rfl bodyDfree118 : (bodyΘ.2.take 630).all (fun e => (PRE_first_tail_x15_r0_body.cws118 ++ PRE_first_tail_x15_r0_body.ws118).all fun w => e.noVar w) = true

theorem bodyStep118 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨42651, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1145 PRE_first_tail_x15_r0_body.S1145)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42653, 791, 0, 630⟩ bodyM PRE_first_tail_x15_r0_body.s1147 PRE_first_tail_x15_r0_body.S1147) (27 + 1) :=
  bodySite bodyFacts118.cfix bodyFacts118.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st118.S2.tab) (Es := bodyEs118) (qs := bodyQs118)
    (ok := PRE_first_tail_x15_r0_body.st118.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site118 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts118
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site118 r hr) hi (MapOk.sub hm (sub_of_all bodySub118)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk118 r hr) hi hm ho hq)
    bodyLq118 rfl bodyNrLo118 (postSub_sound bodyPost118)
    (Nat.le_of_ble_eq_true bodyDrop118) (by decide) (Nat.le_of_ble_eq_true bodyDropH118) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN118) (by decide)
    bodyDv118 bodyDe118 bodyDl118 bodyDold118 bodyDfree118 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
