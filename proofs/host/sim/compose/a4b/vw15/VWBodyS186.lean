import host.sim.compose.a4b.vw15.VWBodyJ186
import host.sim.compose.a4b.vw15.VWBodySite186
import host.sim.compose.a4b.vw15.VWBodyOracles_46
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

theorem bodyCshift186 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1799.tab.length PRE_first_tail_x15_r0_body.s1799.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P186.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P186 8054 PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.s1801.ffi PRE_first_tail_x15_r0_body.s1800.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_186
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_186
  have hcl : SSt (· < 8054) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1799.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_186] <;> decide) PRE_first_tail_x15_r0_body.cnodesK186 PRE_first_tail_x15_r0_body.cobjsK186
      PRE_first_tail_x15_r0_body.citemsK186 PRE_first_tail_x15_r0_body.cbd186 PRE_first_tail_x15_r0_body.csst186
  exact PRE_first_tail_x15_r0_body.cshift186 bodyNcl186 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_186] at this; exact this)


kernel_rfl bodyFramesEmpty186 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1800 a).isEmpty) = true
kernel_rfl bodyJsRoots186 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1799.next) PRE_first_tail_x15_r0_body.s1801.trace PRE_first_tail_x15_r0_body.s1801 = true
kernel_rfl bodyJsNative186 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1801.ffi) = true
kernel_rfl bodyLow186 : (PRE_first_tail_x15_r0_body.cws186 ++ PRE_first_tail_x15_r0_body.ws186).all (Nat.ble 9) = true
kernel_rfl bodyCntM186 : countersOkB PRE_first_tail_x15_r0_body.s1799 PRE_first_tail_x15_r0_body.s1800 = true
kernel_rfl bodyHi186 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1801.ffi).next setupP.E = true
kernel_rfl bodyNhi186 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1801.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge186 : bridgeOf PRE_first_tail_x15_r0_body.s1800.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1799.ffi
kernel_rfl bodyNN186 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1799.ffi).nnext PRE_first_tail_x15_r0_body.P186.NL = true
kernel_rfl bodyXn186 : Nat.ble (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1801.ffi).next = true
kernel_rfl bodyLo186 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1801.ffi).next = true
theorem bodyFacts186 : BodySiteFacts PRE_first_tail_x15_r0_body.s1799 PRE_first_tail_x15_r0_body.s1800 PRE_first_tail_x15_r0_body.s1801 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1799 PRE_first_tail_x15_r0_body.S1800 PRE_first_tail_x15_r0_body.S1801
    PRE_first_tail_x15_r0_body.ws186 PRE_first_tail_x15_r0_body.cws186 PRE_first_tail_x15_r0_body.nr186 PRE_first_tail_x15_r0_body.pl186 PRE_first_tail_x15_r0_body.cl186 2822402 8054 PRE_first_tail_x15_r0_body.kd186 PRE_first_tail_x15_r0_body.kappa186 PRE_first_tail_x15_r0_body.P186
    ⟨21870, 18959, 2821247, 8036⟩ ⟨21873, 18986, 2821253, 8054⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap186
  clean := bodyClean186
  cfix := PRE_first_tail_x15_r0_body.cfix186
  zpl := PRE_first_tail_x15_r0_body.zpl186
  zplnd := PRE_first_tail_x15_r0_body.zplnd186
  zn1 := PRE_first_tail_x15_r0_body.zn1186
  zfirst := PRE_first_tail_x15_r0_body.zfirst186
  zscn := PRE_first_tail_x15_r0_body.zscn186
  zsmn := PRE_first_tail_x15_r0_body.zsmn186
  zgrow := PRE_first_tail_x15_r0_body.zgrow186
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab186
  zfresh := PRE_first_tail_x15_r0_body.zfresh186
  zcnd := PRE_first_tail_x15_r0_body.zcnd186
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi186
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt186
  zgP := PRE_first_tail_x15_r0_body.zg186_2665
  zkP := PRE_first_tail_x15_r0_body.zk186_2665
  zmP := PRE_first_tail_x15_r0_body.zm186_2665
  zgC := PRE_first_tail_x15_r0_body.zg186_2673467
  zkC := PRE_first_tail_x15_r0_body.zk186_2673467
  zmC := PRE_first_tail_x15_r0_body.zm186_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw186_2673472
  zwV := PRE_first_tail_x15_r0_body.zw186_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap186
  zclbd := PRE_first_tail_x15_r0_body.zclbd186
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap186 PRE_first_tail_x15_r0_body.stFoot186 PRE_first_tail_x15_r0_body.iso186 PRE_first_tail_x15_r0_body.zwr186
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP186
  csupp := PRE_first_tail_x15_r0_body.csupp186
  cbound := PRE_first_tail_x15_r0_body.cbound186
  zimg := PRE_first_tail_x15_r0_body.zimg186
  zctl := PRE_first_tail_x15_r0_body.zctl186
  zstack := PRE_first_tail_x15_r0_body.zstack186
  zjobs := PRE_first_tail_x15_r0_body.zjobs186
  zstores := PRE_first_tail_x15_r0_body.zstores186
  zroots := PRE_first_tail_x15_r0_body.zroots186
  znC := PRE_first_tail_x15_r0_body.znC186
  ctab := PRE_first_tail_x15_r0_body.ctab186
  zbin := PRE_first_tail_x15_r0_body.zbin186
  cbridge := PRE_first_tail_x15_r0_body.cbridge186
  sbridge := bodyBridge186
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj186
  cshiftR := fun h hNL => bodyCshift186 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN186
  raised := PRE_first_tail_x15_r0_body.raised186
  cbigs := PRE_first_tail_x15_r0_body.cbigs186
  cjcl := PRE_first_tail_x15_r0_body.cjcl186
  xnLe := Nat.le_of_ble_eq_true bodyXn186
  loLe := Nat.le_of_ble_eq_true bodyLo186
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB186
  cntM := bodyCntM186
  hiLe := Nat.le_of_ble_eq_true bodyHi186
  nhiLe := Nat.le_of_ble_eq_true bodyNhi186
  jsHeap := bodyJs186
  jsRoots := bodyJsRoots186
  jsNative := bodyJsNative186
  framesEmpty := bodyFramesEmpty186
  trailOld := by decide
  lowVars := bodyLow186

def bodyQs186 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs186 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr186.map fun r => nth? PRE_first_tail_x15_r0_body.st186.S5.tab r
kernel_rfl bodyResChk186 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs186 bodyQs186) = true
kernel_rfl bodyLq186 : bodyQs186.length = PRE_first_tail_x15_r0_body.cws186.length
kernel_rfl bodyNrLo186 : PRE_first_tail_x15_r0_body.nr186.all (Nat.ble PRE_first_tail_x15_r0_body.S1799.tab.length) = true
kernel_rfl bodySub186 : (Oracles.PRE_first_tail_x15_r0_body.map_site186.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost186 : postSubB bodyM PRE_first_tail_x15_r0_body.ws186 PRE_first_tail_x15_r0_body.cws186 bodyQs186 = true
kernel_rfl bodyDrop186 : Nat.ble (64327 + (PRE_first_tail_x15_r0_body.s1800.next - PRE_first_tail_x15_r0_body.s1801.next)) 65476 = true
kernel_rfl bodyDropH186 : Nat.ble (1226 + ((mlxOf PRE_first_tail_x15_r0_body.s1800.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1801.ffi).next)) 1251 = true
kernel_rfl bodyDropN186 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1800.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1801.ffi).nnext)) 0 = true
kernel_rfl bodyDv186 : bodyΘ.1.take 999 = bodyΘ.1.take 981 ++ PRE_first_tail_x15_r0_body.cws186
kernel_rfl bodyDe186 : bodyΘ.2.take 999 = bodyΘ.2.take 981 ++ PRE_first_tail_x15_r0_body.nr186.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st186.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 981) (bodyΘ.2.take 981)))
kernel_rfl bodyDl186 : (bodyΘ.1.take 981).length = (bodyΘ.2.take 981).length
kernel_rfl bodyDold186 : (bodyΘ.1.take 981).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws186).isNone && !PRE_first_tail_x15_r0_body.ws186.contains v) = true
kernel_rfl bodyDfree186 : (bodyΘ.2.take 999).all (fun e => (PRE_first_tail_x15_r0_body.cws186 ++ PRE_first_tail_x15_r0_body.ws186).all fun w => e.noVar w) = true

theorem bodyStep186 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64327, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1799 PRE_first_tail_x15_r0_body.S1799)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65476, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1801 PRE_first_tail_x15_r0_body.S1801) (11334 + 1) :=
  bodySite bodyFacts186.cfix bodyFacts186.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st186.S5.tab) (Es := bodyEs186) (qs := bodyQs186)
    (ok := PRE_first_tail_x15_r0_body.st186.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site186 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts186
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site186 r hr) hi (MapOk.sub hm (sub_of_all bodySub186)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk186 r hr) hi hm ho hq)
    bodyLq186 rfl bodyNrLo186 (postSub_sound bodyPost186)
    (Nat.le_of_ble_eq_true bodyDrop186) (by decide) (Nat.le_of_ble_eq_true bodyDropH186) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN186) (by decide)
    bodyDv186 bodyDe186 bodyDl186 bodyDold186 bodyDfree186 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
