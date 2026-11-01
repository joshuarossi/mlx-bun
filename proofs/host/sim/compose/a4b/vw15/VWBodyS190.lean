import host.sim.compose.a4b.vw15.VWBodyJ190
import host.sim.compose.a4b.vw15.VWBodySite190
import host.sim.compose.a4b.vw15.VWBodyOracles_47
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift190 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1835.tab.length PRE_first_tail_x15_r0_body.s1835.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P190.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P190 8201 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.s1837.ffi PRE_first_tail_x15_r0_body.s1836.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_190
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_190
  have hcl : SSt (· < 8201) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1837.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1835.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_190] <;> decide) PRE_first_tail_x15_r0_body.cnodesK190 PRE_first_tail_x15_r0_body.cobjsK190
      PRE_first_tail_x15_r0_body.citemsK190 PRE_first_tail_x15_r0_body.cbd190 PRE_first_tail_x15_r0_body.csst190
  exact PRE_first_tail_x15_r0_body.cshift190 bodyNcl190 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_190] at this; exact this)


kernel_rfl bodyFramesEmpty190 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1836 a).isEmpty) = true
kernel_rfl bodyJsRoots190 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1835.next) PRE_first_tail_x15_r0_body.s1837.trace PRE_first_tail_x15_r0_body.s1837 = true
kernel_rfl bodyJsNative190 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1837.ffi) = true
kernel_rfl bodyLow190 : (PRE_first_tail_x15_r0_body.cws190 ++ PRE_first_tail_x15_r0_body.ws190).all (Nat.ble 9) = true
kernel_rfl bodyCntM190 : countersOkB PRE_first_tail_x15_r0_body.s1835 PRE_first_tail_x15_r0_body.s1836 = true
kernel_rfl bodyHi190 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1837.ffi).next setupP.E = true
kernel_rfl bodyNhi190 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1837.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge190 : bridgeOf PRE_first_tail_x15_r0_body.s1836.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1835.ffi
kernel_rfl bodyNN190 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1835.ffi).nnext PRE_first_tail_x15_r0_body.P190.NL = true
kernel_rfl bodyXn190 : Nat.ble (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1837.ffi).next = true
kernel_rfl bodyLo190 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1837.ffi).next = true
theorem bodyFacts190 : BodySiteFacts PRE_first_tail_x15_r0_body.s1835 PRE_first_tail_x15_r0_body.s1836 PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1835 PRE_first_tail_x15_r0_body.S1836 PRE_first_tail_x15_r0_body.S1837
    PRE_first_tail_x15_r0_body.ws190 PRE_first_tail_x15_r0_body.cws190 PRE_first_tail_x15_r0_body.nr190 PRE_first_tail_x15_r0_body.pl190 PRE_first_tail_x15_r0_body.cl190 2824367 8201 PRE_first_tail_x15_r0_body.kd190 PRE_first_tail_x15_r0_body.kappa190 PRE_first_tail_x15_r0_body.P190
    ⟨21950, 19047, 2824365, 8201⟩ ⟨21950, 19047, 2824365, 8201⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap190
  clean := bodyClean190
  cfix := PRE_first_tail_x15_r0_body.cfix190
  zpl := PRE_first_tail_x15_r0_body.zpl190
  zplnd := PRE_first_tail_x15_r0_body.zplnd190
  zn1 := PRE_first_tail_x15_r0_body.zn1190
  zfirst := PRE_first_tail_x15_r0_body.zfirst190
  zscn := PRE_first_tail_x15_r0_body.zscn190
  zsmn := PRE_first_tail_x15_r0_body.zsmn190
  zgrow := PRE_first_tail_x15_r0_body.zgrow190
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab190
  zfresh := PRE_first_tail_x15_r0_body.zfresh190
  zcnd := PRE_first_tail_x15_r0_body.zcnd190
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi190
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt190
  zgP := PRE_first_tail_x15_r0_body.zg190_2665
  zkP := PRE_first_tail_x15_r0_body.zk190_2665
  zmP := PRE_first_tail_x15_r0_body.zm190_2665
  zgC := PRE_first_tail_x15_r0_body.zg190_2673467
  zkC := PRE_first_tail_x15_r0_body.zk190_2673467
  zmC := PRE_first_tail_x15_r0_body.zm190_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw190_2673472
  zwV := PRE_first_tail_x15_r0_body.zw190_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap190
  zclbd := PRE_first_tail_x15_r0_body.zclbd190
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap190 PRE_first_tail_x15_r0_body.stFoot190 PRE_first_tail_x15_r0_body.iso190 PRE_first_tail_x15_r0_body.zwr190
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP190
  csupp := PRE_first_tail_x15_r0_body.csupp190
  cbound := PRE_first_tail_x15_r0_body.cbound190
  zimg := PRE_first_tail_x15_r0_body.zimg190
  zctl := PRE_first_tail_x15_r0_body.zctl190
  zstack := PRE_first_tail_x15_r0_body.zstack190
  zjobs := PRE_first_tail_x15_r0_body.zjobs190
  zstores := PRE_first_tail_x15_r0_body.zstores190
  zroots := PRE_first_tail_x15_r0_body.zroots190
  znC := PRE_first_tail_x15_r0_body.znC190
  ctab := PRE_first_tail_x15_r0_body.ctab190
  zbin := PRE_first_tail_x15_r0_body.zbin190
  cbridge := PRE_first_tail_x15_r0_body.cbridge190
  sbridge := bodyBridge190
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj190
  cshiftR := fun h hNL => bodyCshift190 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN190
  raised := PRE_first_tail_x15_r0_body.raised190
  cbigs := PRE_first_tail_x15_r0_body.cbigs190
  cjcl := PRE_first_tail_x15_r0_body.cjcl190
  xnLe := Nat.le_of_ble_eq_true bodyXn190
  loLe := Nat.le_of_ble_eq_true bodyLo190
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB190
  cntM := bodyCntM190
  hiLe := Nat.le_of_ble_eq_true bodyHi190
  nhiLe := Nat.le_of_ble_eq_true bodyNhi190
  jsHeap := bodyJs190
  jsRoots := bodyJsRoots190
  jsNative := bodyJsNative190
  framesEmpty := bodyFramesEmpty190
  trailOld := by decide
  lowVars := bodyLow190

def bodyQs190 : List (Option Q) := []
noncomputable def bodyEs190 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr190.map fun r => nth? PRE_first_tail_x15_r0_body.st190.S2.tab r
kernel_rfl bodyResChk190 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs190 bodyQs190) = true
kernel_rfl bodyLq190 : bodyQs190.length = PRE_first_tail_x15_r0_body.cws190.length
kernel_rfl bodyNrLo190 : PRE_first_tail_x15_r0_body.nr190.all (Nat.ble PRE_first_tail_x15_r0_body.S1835.tab.length) = true
kernel_rfl bodySub190 : (Oracles.PRE_first_tail_x15_r0_body.map_site190.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost190 : postSubB bodyM PRE_first_tail_x15_r0_body.ws190 PRE_first_tail_x15_r0_body.cws190 bodyQs190 = true
kernel_rfl bodyDrop190 : Nat.ble (65838 + (PRE_first_tail_x15_r0_body.s1836.next - PRE_first_tail_x15_r0_body.s1837.next)) 65840 = true
kernel_rfl bodyDropH190 : Nat.ble (1253 + ((mlxOf PRE_first_tail_x15_r0_body.s1836.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1837.ffi).next)) 1253 = true
kernel_rfl bodyDropN190 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1836.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1837.ffi).nnext)) 0 = true
kernel_rfl bodyDv190 : bodyΘ.1.take 1008 = bodyΘ.1.take 1008 ++ PRE_first_tail_x15_r0_body.cws190
kernel_rfl bodyDe190 : bodyΘ.2.take 1008 = bodyΘ.2.take 1008 ++ PRE_first_tail_x15_r0_body.nr190.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st190.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 1008) (bodyΘ.2.take 1008)))
kernel_rfl bodyDl190 : (bodyΘ.1.take 1008).length = (bodyΘ.2.take 1008).length
kernel_rfl bodyDold190 : (bodyΘ.1.take 1008).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws190).isNone && !PRE_first_tail_x15_r0_body.ws190.contains v) = true
kernel_rfl bodyDfree190 : (bodyΘ.2.take 1008).all (fun e => (PRE_first_tail_x15_r0_body.cws190 ++ PRE_first_tail_x15_r0_body.ws190).all fun w => e.noVar w) = true

theorem bodyStep190 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65838, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1835 PRE_first_tail_x15_r0_body.S1835)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65840, 1253, 0, 1008⟩ bodyM PRE_first_tail_x15_r0_body.s1837 PRE_first_tail_x15_r0_body.S1837) (27 + 1) :=
  bodySite bodyFacts190.cfix bodyFacts190.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st190.S2.tab) (Es := bodyEs190) (qs := bodyQs190)
    (ok := PRE_first_tail_x15_r0_body.st190.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site190 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts190
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site190 r hr) hi (MapOk.sub hm (sub_of_all bodySub190)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk190 r hr) hi hm ho hq)
    bodyLq190 rfl bodyNrLo190 (postSub_sound bodyPost190)
    (Nat.le_of_ble_eq_true bodyDrop190) (by decide) (Nat.le_of_ble_eq_true bodyDropH190) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN190) (by decide)
    bodyDv190 bodyDe190 bodyDl190 bodyDold190 bodyDfree190 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
