import host.sim.compose.a4b.vw15.VWBodyJ175
import host.sim.compose.a4b.vw15.VWBodySite175
import host.sim.compose.a4b.vw15.VWBodyOracles_43
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift175 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1692.tab.length PRE_first_tail_x15_r0_body.s1692.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P175.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P175 7562 PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.s1694.ffi PRE_first_tail_x15_r0_body.s1693.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_175
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_175
  have hcl : SSt (· < 7562) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1694.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1692.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_175] <;> decide) PRE_first_tail_x15_r0_body.cnodesK175 PRE_first_tail_x15_r0_body.cobjsK175
      PRE_first_tail_x15_r0_body.citemsK175 PRE_first_tail_x15_r0_body.cbd175 PRE_first_tail_x15_r0_body.csst175
  exact PRE_first_tail_x15_r0_body.cshift175 bodyNcl175 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_175] at this; exact this)


kernel_rfl bodyFramesEmpty175 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1693 a).isEmpty) = true
kernel_rfl bodyJsRoots175 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1692.next) PRE_first_tail_x15_r0_body.s1694.trace PRE_first_tail_x15_r0_body.s1694 = true
kernel_rfl bodyJsNative175 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1694.ffi) = true
kernel_rfl bodyLow175 : (PRE_first_tail_x15_r0_body.cws175 ++ PRE_first_tail_x15_r0_body.ws175).all (Nat.ble 9) = true
kernel_rfl bodyCntM175 : countersOkB PRE_first_tail_x15_r0_body.s1692 PRE_first_tail_x15_r0_body.s1693 = true
kernel_rfl bodyHi175 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1694.ffi).next setupP.E = true
kernel_rfl bodyNhi175 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1694.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge175 : bridgeOf PRE_first_tail_x15_r0_body.s1693.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1692.ffi
kernel_rfl bodyNN175 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1692.ffi).nnext PRE_first_tail_x15_r0_body.P175.NL = true
kernel_rfl bodyXn175 : Nat.ble (⟨21650, 18762, 2812315, 7562⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1694.ffi).next = true
kernel_rfl bodyLo175 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1694.ffi).next = true
theorem bodyFacts175 : BodySiteFacts PRE_first_tail_x15_r0_body.s1692 PRE_first_tail_x15_r0_body.s1693 PRE_first_tail_x15_r0_body.s1694 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1692 PRE_first_tail_x15_r0_body.S1693 PRE_first_tail_x15_r0_body.S1694
    PRE_first_tail_x15_r0_body.ws175 PRE_first_tail_x15_r0_body.cws175 PRE_first_tail_x15_r0_body.nr175 PRE_first_tail_x15_r0_body.pl175 PRE_first_tail_x15_r0_body.cl175 2812317 7562 PRE_first_tail_x15_r0_body.kd175 PRE_first_tail_x15_r0_body.kappa175 PRE_first_tail_x15_r0_body.P175
    ⟨21650, 18762, 2812315, 7562⟩ ⟨21650, 18762, 2812315, 7562⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap175
  clean := bodyClean175
  cfix := PRE_first_tail_x15_r0_body.cfix175
  zpl := PRE_first_tail_x15_r0_body.zpl175
  zplnd := PRE_first_tail_x15_r0_body.zplnd175
  zn1 := PRE_first_tail_x15_r0_body.zn1175
  zfirst := PRE_first_tail_x15_r0_body.zfirst175
  zscn := PRE_first_tail_x15_r0_body.zscn175
  zsmn := PRE_first_tail_x15_r0_body.zsmn175
  zgrow := PRE_first_tail_x15_r0_body.zgrow175
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab175
  zfresh := PRE_first_tail_x15_r0_body.zfresh175
  zcnd := PRE_first_tail_x15_r0_body.zcnd175
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi175
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt175
  zgP := PRE_first_tail_x15_r0_body.zg175_2665
  zkP := PRE_first_tail_x15_r0_body.zk175_2665
  zmP := PRE_first_tail_x15_r0_body.zm175_2665
  zgC := PRE_first_tail_x15_r0_body.zg175_2673467
  zkC := PRE_first_tail_x15_r0_body.zk175_2673467
  zmC := PRE_first_tail_x15_r0_body.zm175_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw175_2673472
  zwV := PRE_first_tail_x15_r0_body.zw175_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap175
  zclbd := PRE_first_tail_x15_r0_body.zclbd175
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap175 PRE_first_tail_x15_r0_body.stFoot175 PRE_first_tail_x15_r0_body.iso175 PRE_first_tail_x15_r0_body.zwr175
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP175
  csupp := PRE_first_tail_x15_r0_body.csupp175
  cbound := PRE_first_tail_x15_r0_body.cbound175
  zimg := PRE_first_tail_x15_r0_body.zimg175
  zctl := PRE_first_tail_x15_r0_body.zctl175
  zstack := PRE_first_tail_x15_r0_body.zstack175
  zjobs := PRE_first_tail_x15_r0_body.zjobs175
  zstores := PRE_first_tail_x15_r0_body.zstores175
  zroots := PRE_first_tail_x15_r0_body.zroots175
  znC := PRE_first_tail_x15_r0_body.znC175
  ctab := PRE_first_tail_x15_r0_body.ctab175
  zbin := PRE_first_tail_x15_r0_body.zbin175
  cbridge := PRE_first_tail_x15_r0_body.cbridge175
  sbridge := bodyBridge175
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj175
  cshiftR := fun h hNL => bodyCshift175 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN175
  raised := PRE_first_tail_x15_r0_body.raised175
  cbigs := PRE_first_tail_x15_r0_body.cbigs175
  cjcl := PRE_first_tail_x15_r0_body.cjcl175
  xnLe := Nat.le_of_ble_eq_true bodyXn175
  loLe := Nat.le_of_ble_eq_true bodyLo175
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB175
  cntM := bodyCntM175
  hiLe := Nat.le_of_ble_eq_true bodyHi175
  nhiLe := Nat.le_of_ble_eq_true bodyNhi175
  jsHeap := bodyJs175
  jsRoots := bodyJsRoots175
  jsNative := bodyJsNative175
  framesEmpty := bodyFramesEmpty175
  trailOld := by decide
  lowVars := bodyLow175

def bodyQs175 : List (Option Q) := []
noncomputable def bodyEs175 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr175.map fun r => nth? PRE_first_tail_x15_r0_body.st175.S2.tab r
kernel_rfl bodyResChk175 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs175 bodyQs175) = true
kernel_rfl bodyLq175 : bodyQs175.length = PRE_first_tail_x15_r0_body.cws175.length
kernel_rfl bodyNrLo175 : PRE_first_tail_x15_r0_body.nr175.all (Nat.ble PRE_first_tail_x15_r0_body.S1692.tab.length) = true
kernel_rfl bodySub175 : (Oracles.PRE_first_tail_x15_r0_body.map_site175.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost175 : postSubB bodyM PRE_first_tail_x15_r0_body.ws175 PRE_first_tail_x15_r0_body.cws175 bodyQs175 = true
kernel_rfl bodyDrop175 : Nat.ble (61595 + (PRE_first_tail_x15_r0_body.s1693.next - PRE_first_tail_x15_r0_body.s1694.next)) 61597 = true
kernel_rfl bodyDropH175 : Nat.ble (1174 + ((mlxOf PRE_first_tail_x15_r0_body.s1693.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1694.ffi).next)) 1174 = true
kernel_rfl bodyDropN175 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1693.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1694.ffi).nnext)) 0 = true
kernel_rfl bodyDv175 : bodyΘ.1.take 936 = bodyΘ.1.take 936 ++ PRE_first_tail_x15_r0_body.cws175
kernel_rfl bodyDe175 : bodyΘ.2.take 936 = bodyΘ.2.take 936 ++ PRE_first_tail_x15_r0_body.nr175.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st175.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 936) (bodyΘ.2.take 936)))
kernel_rfl bodyDl175 : (bodyΘ.1.take 936).length = (bodyΘ.2.take 936).length
kernel_rfl bodyDold175 : (bodyΘ.1.take 936).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws175).isNone && !PRE_first_tail_x15_r0_body.ws175.contains v) = true
kernel_rfl bodyDfree175 : (bodyΘ.2.take 936).all (fun e => (PRE_first_tail_x15_r0_body.cws175 ++ PRE_first_tail_x15_r0_body.ws175).all fun w => e.noVar w) = true

theorem bodyStep175 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61595, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1692 PRE_first_tail_x15_r0_body.S1692)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61597, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1694 PRE_first_tail_x15_r0_body.S1694) (27 + 1) :=
  bodySite bodyFacts175.cfix bodyFacts175.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st175.S2.tab) (Es := bodyEs175) (qs := bodyQs175)
    (ok := PRE_first_tail_x15_r0_body.st175.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site175 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts175
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site175 r hr) hi (MapOk.sub hm (sub_of_all bodySub175)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk175 r hr) hi hm ho hq)
    bodyLq175 rfl bodyNrLo175 (postSub_sound bodyPost175)
    (Nat.le_of_ble_eq_true bodyDrop175) (by decide) (Nat.le_of_ble_eq_true bodyDropH175) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN175) (by decide)
    bodyDv175 bodyDe175 bodyDl175 bodyDold175 bodyDfree175 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
