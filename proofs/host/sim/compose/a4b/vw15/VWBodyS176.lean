import host.sim.compose.a4b.vw15.VWBodyJ176
import host.sim.compose.a4b.vw15.VWBodySite176
import host.sim.compose.a4b.vw15.VWBodyOracles_44
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

theorem bodyCshift176 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1696.tab.length PRE_first_tail_x15_r0_body.s1696.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P176.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P176 7579 PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.s1698.ffi PRE_first_tail_x15_r0_body.s1697.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_176
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_176
  have hcl : SSt (· < 7579) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1698.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1696.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_176] <;> decide) PRE_first_tail_x15_r0_body.cnodesK176 PRE_first_tail_x15_r0_body.cobjsK176
      PRE_first_tail_x15_r0_body.citemsK176 PRE_first_tail_x15_r0_body.cbd176 PRE_first_tail_x15_r0_body.csst176
  exact PRE_first_tail_x15_r0_body.cshift176 bodyNcl176 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_176] at this; exact this)


kernel_rfl bodyFramesEmpty176 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1697 a).isEmpty) = true
kernel_rfl bodyJsRoots176 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1696.next) PRE_first_tail_x15_r0_body.s1698.trace PRE_first_tail_x15_r0_body.s1698 = true
kernel_rfl bodyJsNative176 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1698.ffi) = true
kernel_rfl bodyLow176 : (PRE_first_tail_x15_r0_body.cws176 ++ PRE_first_tail_x15_r0_body.ws176).all (Nat.ble 9) = true
kernel_rfl bodyCntM176 : countersOkB PRE_first_tail_x15_r0_body.s1696 PRE_first_tail_x15_r0_body.s1697 = true
kernel_rfl bodyHi176 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1698.ffi).next setupP.E = true
kernel_rfl bodyNhi176 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1698.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge176 : bridgeOf PRE_first_tail_x15_r0_body.s1697.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1696.ffi
kernel_rfl bodyNN176 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1696.ffi).nnext PRE_first_tail_x15_r0_body.P176.NL = true
kernel_rfl bodyXn176 : Nat.ble (⟨21657, 18766, 2812604, 7579⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1698.ffi).next = true
kernel_rfl bodyLo176 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1698.ffi).next = true
theorem bodyFacts176 : BodySiteFacts PRE_first_tail_x15_r0_body.s1696 PRE_first_tail_x15_r0_body.s1697 PRE_first_tail_x15_r0_body.s1698 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1696 PRE_first_tail_x15_r0_body.S1697 PRE_first_tail_x15_r0_body.S1698
    PRE_first_tail_x15_r0_body.ws176 PRE_first_tail_x15_r0_body.cws176 PRE_first_tail_x15_r0_body.nr176 PRE_first_tail_x15_r0_body.pl176 PRE_first_tail_x15_r0_body.cl176 2812623 7579 PRE_first_tail_x15_r0_body.kd176 PRE_first_tail_x15_r0_body.kappa176 PRE_first_tail_x15_r0_body.P176
    ⟨21657, 18766, 2812603, 7579⟩ ⟨21657, 18766, 2812604, 7579⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap176
  clean := bodyClean176
  cfix := PRE_first_tail_x15_r0_body.cfix176
  zpl := PRE_first_tail_x15_r0_body.zpl176
  zplnd := PRE_first_tail_x15_r0_body.zplnd176
  zn1 := PRE_first_tail_x15_r0_body.zn1176
  zfirst := PRE_first_tail_x15_r0_body.zfirst176
  zscn := PRE_first_tail_x15_r0_body.zscn176
  zsmn := PRE_first_tail_x15_r0_body.zsmn176
  zgrow := PRE_first_tail_x15_r0_body.zgrow176
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab176
  zfresh := PRE_first_tail_x15_r0_body.zfresh176
  zcnd := PRE_first_tail_x15_r0_body.zcnd176
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi176
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt176
  zgP := PRE_first_tail_x15_r0_body.zg176_2665
  zkP := PRE_first_tail_x15_r0_body.zk176_2665
  zmP := PRE_first_tail_x15_r0_body.zm176_2665
  zgC := PRE_first_tail_x15_r0_body.zg176_2673467
  zkC := PRE_first_tail_x15_r0_body.zk176_2673467
  zmC := PRE_first_tail_x15_r0_body.zm176_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw176_2673472
  zwV := PRE_first_tail_x15_r0_body.zw176_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap176
  zclbd := PRE_first_tail_x15_r0_body.zclbd176
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap176 PRE_first_tail_x15_r0_body.stFoot176 PRE_first_tail_x15_r0_body.iso176 PRE_first_tail_x15_r0_body.zwr176
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP176
  csupp := PRE_first_tail_x15_r0_body.csupp176
  cbound := PRE_first_tail_x15_r0_body.cbound176
  zimg := PRE_first_tail_x15_r0_body.zimg176
  zctl := PRE_first_tail_x15_r0_body.zctl176
  zstack := PRE_first_tail_x15_r0_body.zstack176
  zjobs := PRE_first_tail_x15_r0_body.zjobs176
  zstores := PRE_first_tail_x15_r0_body.zstores176
  zroots := PRE_first_tail_x15_r0_body.zroots176
  znC := PRE_first_tail_x15_r0_body.znC176
  ctab := PRE_first_tail_x15_r0_body.ctab176
  zbin := PRE_first_tail_x15_r0_body.zbin176
  cbridge := PRE_first_tail_x15_r0_body.cbridge176
  sbridge := bodyBridge176
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj176
  cshiftR := fun h hNL => bodyCshift176 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN176
  raised := PRE_first_tail_x15_r0_body.raised176
  cbigs := PRE_first_tail_x15_r0_body.cbigs176
  cjcl := PRE_first_tail_x15_r0_body.cjcl176
  xnLe := Nat.le_of_ble_eq_true bodyXn176
  loLe := Nat.le_of_ble_eq_true bodyLo176
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB176
  cntM := bodyCntM176
  hiLe := Nat.le_of_ble_eq_true bodyHi176
  nhiLe := Nat.le_of_ble_eq_true bodyNhi176
  jsHeap := bodyJs176
  jsRoots := bodyJsRoots176
  jsNative := bodyJsNative176
  framesEmpty := bodyFramesEmpty176
  trailOld := by decide
  lowVars := bodyLow176

def bodyQs176 : List (Option Q) := []
noncomputable def bodyEs176 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr176.map fun r => nth? PRE_first_tail_x15_r0_body.st176.S2.tab r
kernel_rfl bodyResChk176 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs176 bodyQs176) = true
kernel_rfl bodyLq176 : bodyQs176.length = PRE_first_tail_x15_r0_body.cws176.length
kernel_rfl bodyNrLo176 : PRE_first_tail_x15_r0_body.nr176.all (Nat.ble PRE_first_tail_x15_r0_body.S1696.tab.length) = true
kernel_rfl bodySub176 : (Oracles.PRE_first_tail_x15_r0_body.map_site176.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost176 : postSubB bodyM PRE_first_tail_x15_r0_body.ws176 PRE_first_tail_x15_r0_body.cws176 bodyQs176 = true
kernel_rfl bodyDrop176 : Nat.ble (61597 + (PRE_first_tail_x15_r0_body.s1697.next - PRE_first_tail_x15_r0_body.s1698.next)) 61616 = true
kernel_rfl bodyDropH176 : Nat.ble (1174 + ((mlxOf PRE_first_tail_x15_r0_body.s1697.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1698.ffi).next)) 1174 = true
kernel_rfl bodyDropN176 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1697.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1698.ffi).nnext)) 0 = true
kernel_rfl bodyDv176 : bodyΘ.1.take 936 = bodyΘ.1.take 936 ++ PRE_first_tail_x15_r0_body.cws176
kernel_rfl bodyDe176 : bodyΘ.2.take 936 = bodyΘ.2.take 936 ++ PRE_first_tail_x15_r0_body.nr176.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st176.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 936) (bodyΘ.2.take 936)))
kernel_rfl bodyDl176 : (bodyΘ.1.take 936).length = (bodyΘ.2.take 936).length
kernel_rfl bodyDold176 : (bodyΘ.1.take 936).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws176).isNone && !PRE_first_tail_x15_r0_body.ws176.contains v) = true
kernel_rfl bodyDfree176 : (bodyΘ.2.take 936).all (fun e => (PRE_first_tail_x15_r0_body.cws176 ++ PRE_first_tail_x15_r0_body.ws176).all fun w => e.noVar w) = true

theorem bodyStep176 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61597, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1696 PRE_first_tail_x15_r0_body.S1696)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61616, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1698 PRE_first_tail_x15_r0_body.S1698) (206 + 1) :=
  bodySite bodyFacts176.cfix bodyFacts176.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st176.S2.tab) (Es := bodyEs176) (qs := bodyQs176)
    (ok := PRE_first_tail_x15_r0_body.st176.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site176 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts176
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site176 r hr) hi (MapOk.sub hm (sub_of_all bodySub176)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk176 r hr) hi hm ho hq)
    bodyLq176 rfl bodyNrLo176 (postSub_sound bodyPost176)
    (Nat.le_of_ble_eq_true bodyDrop176) (by decide) (Nat.le_of_ble_eq_true bodyDropH176) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN176) (by decide)
    bodyDv176 bodyDe176 bodyDl176 bodyDold176 bodyDfree176 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
