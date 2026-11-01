import host.sim.compose.a4b.vw15.VWBodyJ45
import host.sim.compose.a4b.vw15.VWBodySite45
import host.sim.compose.a4b.vw15.VWBodyOracles_11
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

theorem bodyCshift45 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S447.tab.length PRE_first_tail_x15_r0_body.s447.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P45.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P45 2022 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.s449.ffi PRE_first_tail_x15_r0_body.s448.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_45
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_45
  have hcl : SSt (· < 2022) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s449.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S447.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_45] <;> decide) PRE_first_tail_x15_r0_body.cnodesK45 PRE_first_tail_x15_r0_body.cobjsK45
      PRE_first_tail_x15_r0_body.citemsK45 PRE_first_tail_x15_r0_body.cbd45 PRE_first_tail_x15_r0_body.csst45
  exact PRE_first_tail_x15_r0_body.cshift45 bodyNcl45 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_45] at this; exact this)


kernel_rfl bodyFramesEmpty45 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s448 a).isEmpty) = true
kernel_rfl bodyJsRoots45 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s447.next) PRE_first_tail_x15_r0_body.s449.trace PRE_first_tail_x15_r0_body.s449 = true
kernel_rfl bodyJsNative45 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s449.ffi) = true
kernel_rfl bodyLow45 : (PRE_first_tail_x15_r0_body.cws45 ++ PRE_first_tail_x15_r0_body.ws45).all (Nat.ble 9) = true
kernel_rfl bodyCntM45 : countersOkB PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.s448 = true
kernel_rfl bodyHi45 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next setupP.E = true
kernel_rfl bodyNhi45 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge45 : bridgeOf PRE_first_tail_x15_r0_body.s448.ffi = bridgeOf PRE_first_tail_x15_r0_body.s447.ffi
kernel_rfl bodyNN45 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s447.ffi).nnext PRE_first_tail_x15_r0_body.P45.NL = true
kernel_rfl bodyXn45 : Nat.ble (⟨19105, 16193, 2710755, 2022⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next = true
kernel_rfl bodyLo45 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next = true
theorem bodyFacts45 : BodySiteFacts PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.s448 PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S447 PRE_first_tail_x15_r0_body.S448 PRE_first_tail_x15_r0_body.S449
    PRE_first_tail_x15_r0_body.ws45 PRE_first_tail_x15_r0_body.cws45 PRE_first_tail_x15_r0_body.nr45 PRE_first_tail_x15_r0_body.pl45 PRE_first_tail_x15_r0_body.cl45 2711105 2022 PRE_first_tail_x15_r0_body.kd45 PRE_first_tail_x15_r0_body.kappa45 PRE_first_tail_x15_r0_body.P45
    ⟨19101, 16187, 2710740, 2013⟩ ⟨19105, 16193, 2710755, 2022⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap45
  clean := bodyClean45
  cfix := PRE_first_tail_x15_r0_body.cfix45
  zpl := PRE_first_tail_x15_r0_body.zpl45
  zplnd := PRE_first_tail_x15_r0_body.zplnd45
  zn1 := PRE_first_tail_x15_r0_body.zn145
  zfirst := PRE_first_tail_x15_r0_body.zfirst45
  zscn := PRE_first_tail_x15_r0_body.zscn45
  zsmn := PRE_first_tail_x15_r0_body.zsmn45
  zgrow := PRE_first_tail_x15_r0_body.zgrow45
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab45
  zfresh := PRE_first_tail_x15_r0_body.zfresh45
  zcnd := PRE_first_tail_x15_r0_body.zcnd45
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi45
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt45
  zgP := PRE_first_tail_x15_r0_body.zg45_2665
  zkP := PRE_first_tail_x15_r0_body.zk45_2665
  zmP := PRE_first_tail_x15_r0_body.zm45_2665
  zgC := PRE_first_tail_x15_r0_body.zg45_2673467
  zkC := PRE_first_tail_x15_r0_body.zk45_2673467
  zmC := PRE_first_tail_x15_r0_body.zm45_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw45_2673472
  zwV := PRE_first_tail_x15_r0_body.zw45_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap45
  zclbd := PRE_first_tail_x15_r0_body.zclbd45
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap45 PRE_first_tail_x15_r0_body.stFoot45 PRE_first_tail_x15_r0_body.iso45 PRE_first_tail_x15_r0_body.zwr45
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP45
  csupp := PRE_first_tail_x15_r0_body.csupp45
  cbound := PRE_first_tail_x15_r0_body.cbound45
  zimg := PRE_first_tail_x15_r0_body.zimg45
  zctl := PRE_first_tail_x15_r0_body.zctl45
  zstack := PRE_first_tail_x15_r0_body.zstack45
  zjobs := PRE_first_tail_x15_r0_body.zjobs45
  zstores := PRE_first_tail_x15_r0_body.zstores45
  zroots := PRE_first_tail_x15_r0_body.zroots45
  znC := PRE_first_tail_x15_r0_body.znC45
  ctab := PRE_first_tail_x15_r0_body.ctab45
  zbin := PRE_first_tail_x15_r0_body.zbin45
  cbridge := PRE_first_tail_x15_r0_body.cbridge45
  sbridge := bodyBridge45
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj45
  cshiftR := fun h hNL => bodyCshift45 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN45
  raised := PRE_first_tail_x15_r0_body.raised45
  cbigs := PRE_first_tail_x15_r0_body.cbigs45
  cjcl := PRE_first_tail_x15_r0_body.cjcl45
  xnLe := Nat.le_of_ble_eq_true bodyXn45
  loLe := Nat.le_of_ble_eq_true bodyLo45
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB45
  cntM := bodyCntM45
  hiLe := Nat.le_of_ble_eq_true bodyHi45
  nhiLe := Nat.le_of_ble_eq_true bodyNhi45
  jsHeap := bodyJs45
  jsRoots := bodyJsRoots45
  jsNative := bodyJsNative45
  framesEmpty := bodyFramesEmpty45
  trailOld := by decide
  lowVars := bodyLow45

def bodyQs45 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs45 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr45.map fun r => nth? PRE_first_tail_x15_r0_body.st45.S3.tab r
kernel_rfl bodyResChk45 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs45 bodyQs45) = true
kernel_rfl bodyLq45 : bodyQs45.length = PRE_first_tail_x15_r0_body.cws45.length
kernel_rfl bodyNrLo45 : PRE_first_tail_x15_r0_body.nr45.all (Nat.ble PRE_first_tail_x15_r0_body.S447.tab.length) = true
kernel_rfl bodySub45 : (Oracles.PRE_first_tail_x15_r0_body.map_site45.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost45 : postSubB bodyM PRE_first_tail_x15_r0_body.ws45 PRE_first_tail_x15_r0_body.cws45 bodyQs45 = true
kernel_rfl bodyDrop45 : Nat.ble (19159 + (PRE_first_tail_x15_r0_body.s448.next - PRE_first_tail_x15_r0_body.s449.next)) 19509 = true
kernel_rfl bodyDropH45 : Nat.ble (327 + ((mlxOf PRE_first_tail_x15_r0_body.s448.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).next)) 329 = true
kernel_rfl bodyDropN45 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s448.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s449.ffi).nnext)) 0 = true
kernel_rfl bodyDv45 : bodyΘ.1.take 252 = bodyΘ.1.take 243 ++ PRE_first_tail_x15_r0_body.cws45
kernel_rfl bodyDe45 : bodyΘ.2.take 252 = bodyΘ.2.take 243 ++ PRE_first_tail_x15_r0_body.nr45.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st45.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 243) (bodyΘ.2.take 243)))
kernel_rfl bodyDl45 : (bodyΘ.1.take 243).length = (bodyΘ.2.take 243).length
kernel_rfl bodyDold45 : (bodyΘ.1.take 243).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws45).isNone && !PRE_first_tail_x15_r0_body.ws45.contains v) = true
kernel_rfl bodyDfree45 : (bodyΘ.2.take 252).all (fun e => (PRE_first_tail_x15_r0_body.cws45 ++ PRE_first_tail_x15_r0_body.ws45).all fun w => e.noVar w) = true

theorem bodyStep45 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19159, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s447 PRE_first_tail_x15_r0_body.S447)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19509, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.S449) (3452 + 1) :=
  bodySite bodyFacts45.cfix bodyFacts45.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st45.S3.tab) (Es := bodyEs45) (qs := bodyQs45)
    (ok := PRE_first_tail_x15_r0_body.st45.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site45 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts45
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site45 r hr) hi (MapOk.sub hm (sub_of_all bodySub45)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk45 r hr) hi hm ho hq)
    bodyLq45 rfl bodyNrLo45 (postSub_sound bodyPost45)
    (Nat.le_of_ble_eq_true bodyDrop45) (by decide) (Nat.le_of_ble_eq_true bodyDropH45) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN45) (by decide)
    bodyDv45 bodyDe45 bodyDl45 bodyDold45 bodyDfree45 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
