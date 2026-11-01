import host.sim.compose.a4b.vw15.VWBodyJ80
import host.sim.compose.a4b.vw15.VWBodySite80
import host.sim.compose.a4b.vw15.VWBodyOracles_20
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B23
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift80 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S776.tab.length PRE_first_tail_x15_r0_body.s776.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P80.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P80 3475 PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.s778.ffi PRE_first_tail_x15_r0_body.s777.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_80
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_80
  have hcl : SSt (· < 3475) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s778.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S776.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_80] <;> decide) PRE_first_tail_x15_r0_body.cnodesK80 PRE_first_tail_x15_r0_body.cobjsK80
      PRE_first_tail_x15_r0_body.citemsK80 PRE_first_tail_x15_r0_body.cbd80 PRE_first_tail_x15_r0_body.csst80
  exact PRE_first_tail_x15_r0_body.cshift80 bodyNcl80 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_80] at this; exact this)


kernel_rfl bodyFramesEmpty80 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s777 a).isEmpty) = true
kernel_rfl bodyJsRoots80 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s776.next) PRE_first_tail_x15_r0_body.s778.trace PRE_first_tail_x15_r0_body.s778 = true
kernel_rfl bodyJsNative80 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s778.ffi) = true
kernel_rfl bodyLow80 : (PRE_first_tail_x15_r0_body.cws80 ++ PRE_first_tail_x15_r0_body.ws80).all (Nat.ble 9) = true
kernel_rfl bodyCntM80 : countersOkB PRE_first_tail_x15_r0_body.s776 PRE_first_tail_x15_r0_body.s777 = true
kernel_rfl bodyHi80 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s778.ffi).next setupP.E = true
kernel_rfl bodyNhi80 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s778.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge80 : bridgeOf PRE_first_tail_x15_r0_body.s777.ffi = bridgeOf PRE_first_tail_x15_r0_body.s776.ffi
kernel_rfl bodyNN80 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s776.ffi).nnext PRE_first_tail_x15_r0_body.P80.NL = true
kernel_rfl bodyXn80 : Nat.ble (⟨19769, 16870, 2737256, 3475⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s778.ffi).next = true
kernel_rfl bodyLo80 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s778.ffi).next = true
theorem bodyFacts80 : BodySiteFacts PRE_first_tail_x15_r0_body.s776 PRE_first_tail_x15_r0_body.s777 PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S776 PRE_first_tail_x15_r0_body.S777 PRE_first_tail_x15_r0_body.S778
    PRE_first_tail_x15_r0_body.ws80 PRE_first_tail_x15_r0_body.cws80 PRE_first_tail_x15_r0_body.nr80 PRE_first_tail_x15_r0_body.pl80 PRE_first_tail_x15_r0_body.cl80 2737266 3475 PRE_first_tail_x15_r0_body.kd80 PRE_first_tail_x15_r0_body.kappa80 PRE_first_tail_x15_r0_body.P80
    ⟨19769, 16870, 2737255, 3475⟩ ⟨19769, 16870, 2737256, 3475⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap80
  clean := bodyClean80
  cfix := PRE_first_tail_x15_r0_body.cfix80
  zpl := PRE_first_tail_x15_r0_body.zpl80
  zplnd := PRE_first_tail_x15_r0_body.zplnd80
  zn1 := PRE_first_tail_x15_r0_body.zn180
  zfirst := PRE_first_tail_x15_r0_body.zfirst80
  zscn := PRE_first_tail_x15_r0_body.zscn80
  zsmn := PRE_first_tail_x15_r0_body.zsmn80
  zgrow := PRE_first_tail_x15_r0_body.zgrow80
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab80
  zfresh := PRE_first_tail_x15_r0_body.zfresh80
  zcnd := PRE_first_tail_x15_r0_body.zcnd80
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi80
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt80
  zgP := PRE_first_tail_x15_r0_body.zg80_2665
  zkP := PRE_first_tail_x15_r0_body.zk80_2665
  zmP := PRE_first_tail_x15_r0_body.zm80_2665
  zgC := PRE_first_tail_x15_r0_body.zg80_2673467
  zkC := PRE_first_tail_x15_r0_body.zk80_2673467
  zmC := PRE_first_tail_x15_r0_body.zm80_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw80_2673472
  zwV := PRE_first_tail_x15_r0_body.zw80_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap80
  zclbd := PRE_first_tail_x15_r0_body.zclbd80
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap80 PRE_first_tail_x15_r0_body.stFoot80 PRE_first_tail_x15_r0_body.iso80 PRE_first_tail_x15_r0_body.zwr80
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP80
  csupp := PRE_first_tail_x15_r0_body.csupp80
  cbound := PRE_first_tail_x15_r0_body.cbound80
  zimg := PRE_first_tail_x15_r0_body.zimg80
  zctl := PRE_first_tail_x15_r0_body.zctl80
  zstack := PRE_first_tail_x15_r0_body.zstack80
  zjobs := PRE_first_tail_x15_r0_body.zjobs80
  zstores := PRE_first_tail_x15_r0_body.zstores80
  zroots := PRE_first_tail_x15_r0_body.zroots80
  znC := PRE_first_tail_x15_r0_body.znC80
  ctab := PRE_first_tail_x15_r0_body.ctab80
  zbin := PRE_first_tail_x15_r0_body.zbin80
  cbridge := PRE_first_tail_x15_r0_body.cbridge80
  sbridge := bodyBridge80
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj80
  cshiftR := fun h hNL => bodyCshift80 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN80
  raised := PRE_first_tail_x15_r0_body.raised80
  cbigs := PRE_first_tail_x15_r0_body.cbigs80
  cjcl := PRE_first_tail_x15_r0_body.cjcl80
  xnLe := Nat.le_of_ble_eq_true bodyXn80
  loLe := Nat.le_of_ble_eq_true bodyLo80
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB80
  cntM := bodyCntM80
  hiLe := Nat.le_of_ble_eq_true bodyHi80
  nhiLe := Nat.le_of_ble_eq_true bodyNhi80
  jsHeap := bodyJs80
  jsRoots := bodyJsRoots80
  jsNative := bodyJsNative80
  framesEmpty := bodyFramesEmpty80
  trailOld := by decide
  lowVars := bodyLow80

def bodyQs80 : List (Option Q) := []
noncomputable def bodyEs80 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr80.map fun r => nth? PRE_first_tail_x15_r0_body.st80.S2.tab r
kernel_rfl bodyResChk80 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs80 bodyQs80) = true
kernel_rfl bodyLq80 : bodyQs80.length = PRE_first_tail_x15_r0_body.cws80.length
kernel_rfl bodyNrLo80 : PRE_first_tail_x15_r0_body.nr80.all (Nat.ble PRE_first_tail_x15_r0_body.S776.tab.length) = true
kernel_rfl bodySub80 : (Oracles.PRE_first_tail_x15_r0_body.map_site80.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost80 : postSubB bodyM PRE_first_tail_x15_r0_body.ws80 PRE_first_tail_x15_r0_body.cws80 bodyQs80 = true
kernel_rfl bodyDrop80 : Nat.ble (30720 + (PRE_first_tail_x15_r0_body.s777.next - PRE_first_tail_x15_r0_body.s778.next)) 30730 = true
kernel_rfl bodyDropH80 : Nat.ble (558 + ((mlxOf PRE_first_tail_x15_r0_body.s777.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s778.ffi).next)) 558 = true
kernel_rfl bodyDropN80 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s777.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s778.ffi).nnext)) 0 = true
kernel_rfl bodyDv80 : bodyΘ.1.take 432 = bodyΘ.1.take 432 ++ PRE_first_tail_x15_r0_body.cws80
kernel_rfl bodyDe80 : bodyΘ.2.take 432 = bodyΘ.2.take 432 ++ PRE_first_tail_x15_r0_body.nr80.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st80.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 432) (bodyΘ.2.take 432)))
kernel_rfl bodyDl80 : (bodyΘ.1.take 432).length = (bodyΘ.2.take 432).length
kernel_rfl bodyDold80 : (bodyΘ.1.take 432).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws80).isNone && !PRE_first_tail_x15_r0_body.ws80.contains v) = true
kernel_rfl bodyDfree80 : (bodyΘ.2.take 432).all (fun e => (PRE_first_tail_x15_r0_body.cws80 ++ PRE_first_tail_x15_r0_body.ws80).all fun w => e.noVar w) = true

theorem bodyStep80 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨30720, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s776 PRE_first_tail_x15_r0_body.S776)
      (bodyCut NB T tk π i x0 bodyΘ ⟨30730, 558, 0, 432⟩ bodyM PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.S778) (98 + 1) :=
  bodySite bodyFacts80.cfix bodyFacts80.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st80.S2.tab) (Es := bodyEs80) (qs := bodyQs80)
    (ok := PRE_first_tail_x15_r0_body.st80.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site80 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts80
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site80 r hr) hi (MapOk.sub hm (sub_of_all bodySub80)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk80 r hr) hi hm ho hq)
    bodyLq80 rfl bodyNrLo80 (postSub_sound bodyPost80)
    (Nat.le_of_ble_eq_true bodyDrop80) (by decide) (Nat.le_of_ble_eq_true bodyDropH80) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN80) (by decide)
    bodyDv80 bodyDe80 bodyDl80 bodyDold80 bodyDfree80 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
