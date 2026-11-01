import host.sim.compose.a4b.vw15.VWBodyJ151
import host.sim.compose.a4b.vw15.VWBodySite151
import host.sim.compose.a4b.vw15.VWBodyOracles_37
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift151 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1462.tab.length PRE_first_tail_x15_r0_body.s1462.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P151.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P151 6536 PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.s1464.ffi PRE_first_tail_x15_r0_body.s1463.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_151
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_151
  have hcl : SSt (· < 6536) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1462.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_151] <;> decide) PRE_first_tail_x15_r0_body.cnodesK151 PRE_first_tail_x15_r0_body.cobjsK151
      PRE_first_tail_x15_r0_body.citemsK151 PRE_first_tail_x15_r0_body.cbd151 PRE_first_tail_x15_r0_body.csst151
  exact PRE_first_tail_x15_r0_body.cshift151 bodyNcl151 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_151] at this; exact this)


kernel_rfl bodyFramesEmpty151 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1463 a).isEmpty) = true
kernel_rfl bodyJsRoots151 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1462.next) PRE_first_tail_x15_r0_body.s1464.trace PRE_first_tail_x15_r0_body.s1464 = true
kernel_rfl bodyJsNative151 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1464.ffi) = true
kernel_rfl bodyLow151 : (PRE_first_tail_x15_r0_body.cws151 ++ PRE_first_tail_x15_r0_body.ws151).all (Nat.ble 9) = true
kernel_rfl bodyCntM151 : countersOkB PRE_first_tail_x15_r0_body.s1462 PRE_first_tail_x15_r0_body.s1463 = true
kernel_rfl bodyHi151 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1464.ffi).next setupP.E = true
kernel_rfl bodyNhi151 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1464.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge151 : bridgeOf PRE_first_tail_x15_r0_body.s1463.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1462.ffi
kernel_rfl bodyNN151 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1462.ffi).nnext PRE_first_tail_x15_r0_body.P151.NL = true
kernel_rfl bodyXn151 : Nat.ble (⟨21178, 18288, 2793475, 6536⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1464.ffi).next = true
kernel_rfl bodyLo151 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1464.ffi).next = true
theorem bodyFacts151 : BodySiteFacts PRE_first_tail_x15_r0_body.s1462 PRE_first_tail_x15_r0_body.s1463 PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1462 PRE_first_tail_x15_r0_body.S1463 PRE_first_tail_x15_r0_body.S1464
    PRE_first_tail_x15_r0_body.ws151 PRE_first_tail_x15_r0_body.cws151 PRE_first_tail_x15_r0_body.nr151 PRE_first_tail_x15_r0_body.pl151 PRE_first_tail_x15_r0_body.cl151 2793477 6536 PRE_first_tail_x15_r0_body.kd151 PRE_first_tail_x15_r0_body.kappa151 PRE_first_tail_x15_r0_body.P151
    ⟨21178, 18288, 2793475, 6536⟩ ⟨21178, 18288, 2793475, 6536⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap151
  clean := bodyClean151
  cfix := PRE_first_tail_x15_r0_body.cfix151
  zpl := PRE_first_tail_x15_r0_body.zpl151
  zplnd := PRE_first_tail_x15_r0_body.zplnd151
  zn1 := PRE_first_tail_x15_r0_body.zn1151
  zfirst := PRE_first_tail_x15_r0_body.zfirst151
  zscn := PRE_first_tail_x15_r0_body.zscn151
  zsmn := PRE_first_tail_x15_r0_body.zsmn151
  zgrow := PRE_first_tail_x15_r0_body.zgrow151
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab151
  zfresh := PRE_first_tail_x15_r0_body.zfresh151
  zcnd := PRE_first_tail_x15_r0_body.zcnd151
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi151
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt151
  zgP := PRE_first_tail_x15_r0_body.zg151_2665
  zkP := PRE_first_tail_x15_r0_body.zk151_2665
  zmP := PRE_first_tail_x15_r0_body.zm151_2665
  zgC := PRE_first_tail_x15_r0_body.zg151_2673467
  zkC := PRE_first_tail_x15_r0_body.zk151_2673467
  zmC := PRE_first_tail_x15_r0_body.zm151_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw151_2673472
  zwV := PRE_first_tail_x15_r0_body.zw151_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap151
  zclbd := PRE_first_tail_x15_r0_body.zclbd151
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap151 PRE_first_tail_x15_r0_body.stFoot151 PRE_first_tail_x15_r0_body.iso151 PRE_first_tail_x15_r0_body.zwr151
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP151
  csupp := PRE_first_tail_x15_r0_body.csupp151
  cbound := PRE_first_tail_x15_r0_body.cbound151
  zimg := PRE_first_tail_x15_r0_body.zimg151
  zctl := PRE_first_tail_x15_r0_body.zctl151
  zstack := PRE_first_tail_x15_r0_body.zstack151
  zjobs := PRE_first_tail_x15_r0_body.zjobs151
  zstores := PRE_first_tail_x15_r0_body.zstores151
  zroots := PRE_first_tail_x15_r0_body.zroots151
  znC := PRE_first_tail_x15_r0_body.znC151
  ctab := PRE_first_tail_x15_r0_body.ctab151
  zbin := PRE_first_tail_x15_r0_body.zbin151
  cbridge := PRE_first_tail_x15_r0_body.cbridge151
  sbridge := bodyBridge151
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj151
  cshiftR := fun h hNL => bodyCshift151 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN151
  raised := PRE_first_tail_x15_r0_body.raised151
  cbigs := PRE_first_tail_x15_r0_body.cbigs151
  cjcl := PRE_first_tail_x15_r0_body.cjcl151
  xnLe := Nat.le_of_ble_eq_true bodyXn151
  loLe := Nat.le_of_ble_eq_true bodyLo151
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB151
  cntM := bodyCntM151
  hiLe := Nat.le_of_ble_eq_true bodyHi151
  nhiLe := Nat.le_of_ble_eq_true bodyNhi151
  jsHeap := bodyJs151
  jsRoots := bodyJsRoots151
  jsNative := bodyJsNative151
  framesEmpty := bodyFramesEmpty151
  trailOld := by decide
  lowVars := bodyLow151

def bodyQs151 : List (Option Q) := []
noncomputable def bodyEs151 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr151.map fun r => nth? PRE_first_tail_x15_r0_body.st151.S2.tab r
kernel_rfl bodyResChk151 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs151 bodyQs151) = true
kernel_rfl bodyLq151 : bodyQs151.length = PRE_first_tail_x15_r0_body.cws151.length
kernel_rfl bodyNrLo151 : PRE_first_tail_x15_r0_body.nr151.all (Nat.ble PRE_first_tail_x15_r0_body.S1462.tab.length) = true
kernel_rfl bodySub151 : (Oracles.PRE_first_tail_x15_r0_body.map_site151.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost151 : postSubB bodyM PRE_first_tail_x15_r0_body.ws151 PRE_first_tail_x15_r0_body.cws151 bodyQs151 = true
kernel_rfl bodyDrop151 : Nat.ble (53869 + (PRE_first_tail_x15_r0_body.s1463.next - PRE_first_tail_x15_r0_body.s1464.next)) 53871 = true
kernel_rfl bodyDropH151 : Nat.ble (1020 + ((mlxOf PRE_first_tail_x15_r0_body.s1463.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1464.ffi).next)) 1020 = true
kernel_rfl bodyDropN151 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1463.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1464.ffi).nnext)) 0 = true
kernel_rfl bodyDv151 : bodyΘ.1.take 810 = bodyΘ.1.take 810 ++ PRE_first_tail_x15_r0_body.cws151
kernel_rfl bodyDe151 : bodyΘ.2.take 810 = bodyΘ.2.take 810 ++ PRE_first_tail_x15_r0_body.nr151.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st151.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 810) (bodyΘ.2.take 810)))
kernel_rfl bodyDl151 : (bodyΘ.1.take 810).length = (bodyΘ.2.take 810).length
kernel_rfl bodyDold151 : (bodyΘ.1.take 810).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws151).isNone && !PRE_first_tail_x15_r0_body.ws151.contains v) = true
kernel_rfl bodyDfree151 : (bodyΘ.2.take 810).all (fun e => (PRE_first_tail_x15_r0_body.cws151 ++ PRE_first_tail_x15_r0_body.ws151).all fun w => e.noVar w) = true

theorem bodyStep151 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53869, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1462 PRE_first_tail_x15_r0_body.S1462)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53871, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.S1464) (27 + 1) :=
  bodySite bodyFacts151.cfix bodyFacts151.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st151.S2.tab) (Es := bodyEs151) (qs := bodyQs151)
    (ok := PRE_first_tail_x15_r0_body.st151.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site151 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts151
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site151 r hr) hi (MapOk.sub hm (sub_of_all bodySub151)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk151 r hr) hi hm ho hq)
    bodyLq151 rfl bodyNrLo151 (postSub_sound bodyPost151)
    (Nat.le_of_ble_eq_true bodyDrop151) (by decide) (Nat.le_of_ble_eq_true bodyDropH151) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN151) (by decide)
    bodyDv151 bodyDe151 bodyDl151 bodyDold151 bodyDfree151 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
