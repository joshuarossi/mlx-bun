import host.sim.compose.a4b.vw15.VWBodyJ123
import host.sim.compose.a4b.vw15.VWBodySite123
import host.sim.compose.a4b.vw15.VWBodyOracles_30
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift123 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1195.tab.length PRE_first_tail_x15_r0_body.s1195.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P123.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P123 5360 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.s1197.ffi PRE_first_tail_x15_r0_body.s1196.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_123
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_123
  have hcl : SSt (· < 5360) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1197.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1195.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_123] <;> decide) PRE_first_tail_x15_r0_body.cnodesK123 PRE_first_tail_x15_r0_body.cobjsK123
      PRE_first_tail_x15_r0_body.citemsK123 PRE_first_tail_x15_r0_body.cbd123 PRE_first_tail_x15_r0_body.csst123
  exact PRE_first_tail_x15_r0_body.cshift123 bodyNcl123 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_123] at this; exact this)


kernel_rfl bodyFramesEmpty123 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1196 a).isEmpty) = true
kernel_rfl bodyJsRoots123 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1195.next) PRE_first_tail_x15_r0_body.s1197.trace PRE_first_tail_x15_r0_body.s1197 = true
kernel_rfl bodyJsNative123 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1197.ffi) = true
kernel_rfl bodyLow123 : (PRE_first_tail_x15_r0_body.cws123 ++ PRE_first_tail_x15_r0_body.ws123).all (Nat.ble 9) = true
kernel_rfl bodyCntM123 : countersOkB PRE_first_tail_x15_r0_body.s1195 PRE_first_tail_x15_r0_body.s1196 = true
kernel_rfl bodyHi123 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1197.ffi).next setupP.E = true
kernel_rfl bodyNhi123 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1197.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge123 : bridgeOf PRE_first_tail_x15_r0_body.s1196.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1195.ffi
kernel_rfl bodyNN123 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1195.ffi).nnext PRE_first_tail_x15_r0_body.P123.NL = true
kernel_rfl bodyXn123 : Nat.ble (⟨20636, 17738, 2771885, 5360⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1197.ffi).next = true
kernel_rfl bodyLo123 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1197.ffi).next = true
theorem bodyFacts123 : BodySiteFacts PRE_first_tail_x15_r0_body.s1195 PRE_first_tail_x15_r0_body.s1196 PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1195 PRE_first_tail_x15_r0_body.S1196 PRE_first_tail_x15_r0_body.S1197
    PRE_first_tail_x15_r0_body.ws123 PRE_first_tail_x15_r0_body.cws123 PRE_first_tail_x15_r0_body.nr123 PRE_first_tail_x15_r0_body.pl123 PRE_first_tail_x15_r0_body.cl123 2773034 5360 PRE_first_tail_x15_r0_body.kd123 PRE_first_tail_x15_r0_body.kappa123 PRE_first_tail_x15_r0_body.P123
    ⟨20633, 17711, 2771879, 5342⟩ ⟨20636, 17738, 2771885, 5360⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap123
  clean := bodyClean123
  cfix := PRE_first_tail_x15_r0_body.cfix123
  zpl := PRE_first_tail_x15_r0_body.zpl123
  zplnd := PRE_first_tail_x15_r0_body.zplnd123
  zn1 := PRE_first_tail_x15_r0_body.zn1123
  zfirst := PRE_first_tail_x15_r0_body.zfirst123
  zscn := PRE_first_tail_x15_r0_body.zscn123
  zsmn := PRE_first_tail_x15_r0_body.zsmn123
  zgrow := PRE_first_tail_x15_r0_body.zgrow123
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab123
  zfresh := PRE_first_tail_x15_r0_body.zfresh123
  zcnd := PRE_first_tail_x15_r0_body.zcnd123
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi123
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt123
  zgP := PRE_first_tail_x15_r0_body.zg123_2665
  zkP := PRE_first_tail_x15_r0_body.zk123_2665
  zmP := PRE_first_tail_x15_r0_body.zm123_2665
  zgC := PRE_first_tail_x15_r0_body.zg123_2673467
  zkC := PRE_first_tail_x15_r0_body.zk123_2673467
  zmC := PRE_first_tail_x15_r0_body.zm123_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw123_2673472
  zwV := PRE_first_tail_x15_r0_body.zw123_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap123
  zclbd := PRE_first_tail_x15_r0_body.zclbd123
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap123 PRE_first_tail_x15_r0_body.stFoot123 PRE_first_tail_x15_r0_body.iso123 PRE_first_tail_x15_r0_body.zwr123
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP123
  csupp := PRE_first_tail_x15_r0_body.csupp123
  cbound := PRE_first_tail_x15_r0_body.cbound123
  zimg := PRE_first_tail_x15_r0_body.zimg123
  zctl := PRE_first_tail_x15_r0_body.zctl123
  zstack := PRE_first_tail_x15_r0_body.zstack123
  zjobs := PRE_first_tail_x15_r0_body.zjobs123
  zstores := PRE_first_tail_x15_r0_body.zstores123
  zroots := PRE_first_tail_x15_r0_body.zroots123
  znC := PRE_first_tail_x15_r0_body.znC123
  ctab := PRE_first_tail_x15_r0_body.ctab123
  zbin := PRE_first_tail_x15_r0_body.zbin123
  cbridge := PRE_first_tail_x15_r0_body.cbridge123
  sbridge := bodyBridge123
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj123
  cshiftR := fun h hNL => bodyCshift123 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN123
  raised := PRE_first_tail_x15_r0_body.raised123
  cbigs := PRE_first_tail_x15_r0_body.cbigs123
  cjcl := PRE_first_tail_x15_r0_body.cjcl123
  xnLe := Nat.le_of_ble_eq_true bodyXn123
  loLe := Nat.le_of_ble_eq_true bodyLo123
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB123
  cntM := bodyCntM123
  hiLe := Nat.le_of_ble_eq_true bodyHi123
  nhiLe := Nat.le_of_ble_eq_true bodyNhi123
  jsHeap := bodyJs123
  jsRoots := bodyJsRoots123
  jsNative := bodyJsNative123
  framesEmpty := bodyFramesEmpty123
  trailOld := by decide
  lowVars := bodyLow123

def bodyQs123 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs123 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr123.map fun r => nth? PRE_first_tail_x15_r0_body.st123.S5.tab r
kernel_rfl bodyResChk123 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs123 bodyQs123) = true
kernel_rfl bodyLq123 : bodyQs123.length = PRE_first_tail_x15_r0_body.cws123.length
kernel_rfl bodyNrLo123 : PRE_first_tail_x15_r0_body.nr123.all (Nat.ble PRE_first_tail_x15_r0_body.S1195.tab.length) = true
kernel_rfl bodySub123 : (Oracles.PRE_first_tail_x15_r0_body.map_site123.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost123 : postSubB bodyM PRE_first_tail_x15_r0_body.ws123 PRE_first_tail_x15_r0_body.cws123 bodyQs123 = true
kernel_rfl bodyDrop123 : Nat.ble (43824 + (PRE_first_tail_x15_r0_body.s1196.next - PRE_first_tail_x15_r0_body.s1197.next)) 44973 = true
kernel_rfl bodyDropH123 : Nat.ble (816 + ((mlxOf PRE_first_tail_x15_r0_body.s1196.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1197.ffi).next)) 841 = true
kernel_rfl bodyDropN123 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1196.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1197.ffi).nnext)) 0 = true
kernel_rfl bodyDv123 : bodyΘ.1.take 666 = bodyΘ.1.take 648 ++ PRE_first_tail_x15_r0_body.cws123
kernel_rfl bodyDe123 : bodyΘ.2.take 666 = bodyΘ.2.take 648 ++ PRE_first_tail_x15_r0_body.nr123.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st123.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 648) (bodyΘ.2.take 648)))
kernel_rfl bodyDl123 : (bodyΘ.1.take 648).length = (bodyΘ.2.take 648).length
kernel_rfl bodyDold123 : (bodyΘ.1.take 648).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws123).isNone && !PRE_first_tail_x15_r0_body.ws123.contains v) = true
kernel_rfl bodyDfree123 : (bodyΘ.2.take 666).all (fun e => (PRE_first_tail_x15_r0_body.cws123 ++ PRE_first_tail_x15_r0_body.ws123).all fun w => e.noVar w) = true

theorem bodyStep123 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨43824, 816, 0, 648⟩ bodyM PRE_first_tail_x15_r0_body.s1195 PRE_first_tail_x15_r0_body.S1195)
      (bodyCut NB T tk π i x0 bodyΘ ⟨44973, 841, 0, 666⟩ bodyM PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.S1197) (11334 + 1) :=
  bodySite bodyFacts123.cfix bodyFacts123.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st123.S5.tab) (Es := bodyEs123) (qs := bodyQs123)
    (ok := PRE_first_tail_x15_r0_body.st123.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site123 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts123
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site123 r hr) hi (MapOk.sub hm (sub_of_all bodySub123)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk123 r hr) hi hm ho hq)
    bodyLq123 rfl bodyNrLo123 (postSub_sound bodyPost123)
    (Nat.le_of_ble_eq_true bodyDrop123) (by decide) (Nat.le_of_ble_eq_true bodyDropH123) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN123) (by decide)
    bodyDv123 bodyDe123 bodyDl123 bodyDold123 bodyDfree123 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
