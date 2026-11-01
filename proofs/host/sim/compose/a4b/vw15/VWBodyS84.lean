import host.sim.compose.a4b.vw15.VWBodyJ84
import host.sim.compose.a4b.vw15.VWBodySite84
import host.sim.compose.a4b.vw15.VWBodyOracles_21
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

theorem bodyCshift84 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S821.tab.length PRE_first_tail_x15_r0_body.s821.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P84.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P84 3692 PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.s823.ffi PRE_first_tail_x15_r0_body.s822.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_84
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_84
  have hcl : SSt (· < 3692) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s823.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S821.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_84] <;> decide) PRE_first_tail_x15_r0_body.cnodesK84 PRE_first_tail_x15_r0_body.cobjsK84
      PRE_first_tail_x15_r0_body.citemsK84 PRE_first_tail_x15_r0_body.cbd84 PRE_first_tail_x15_r0_body.csst84
  exact PRE_first_tail_x15_r0_body.cshift84 bodyNcl84 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_84] at this; exact this)


kernel_rfl bodyFramesEmpty84 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s822 a).isEmpty) = true
kernel_rfl bodyJsRoots84 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s821.next) PRE_first_tail_x15_r0_body.s823.trace PRE_first_tail_x15_r0_body.s823 = true
kernel_rfl bodyJsNative84 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s823.ffi) = true
kernel_rfl bodyLow84 : (PRE_first_tail_x15_r0_body.cws84 ++ PRE_first_tail_x15_r0_body.ws84).all (Nat.ble 9) = true
kernel_rfl bodyCntM84 : countersOkB PRE_first_tail_x15_r0_body.s821 PRE_first_tail_x15_r0_body.s822 = true
kernel_rfl bodyHi84 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s823.ffi).next setupP.E = true
kernel_rfl bodyNhi84 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s823.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge84 : bridgeOf PRE_first_tail_x15_r0_body.s822.ffi = bridgeOf PRE_first_tail_x15_r0_body.s821.ffi
kernel_rfl bodyNN84 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s821.ffi).nnext PRE_first_tail_x15_r0_body.P84.NL = true
kernel_rfl bodyXn84 : Nat.ble (⟨19871, 16964, 2741377, 3692⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s823.ffi).next = true
kernel_rfl bodyLo84 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s823.ffi).next = true
theorem bodyFacts84 : BodySiteFacts PRE_first_tail_x15_r0_body.s821 PRE_first_tail_x15_r0_body.s822 PRE_first_tail_x15_r0_body.s823 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S821 PRE_first_tail_x15_r0_body.S822 PRE_first_tail_x15_r0_body.S823
    PRE_first_tail_x15_r0_body.ws84 PRE_first_tail_x15_r0_body.cws84 PRE_first_tail_x15_r0_body.nr84 PRE_first_tail_x15_r0_body.pl84 PRE_first_tail_x15_r0_body.cl84 2742526 3692 PRE_first_tail_x15_r0_body.kd84 PRE_first_tail_x15_r0_body.kappa84 PRE_first_tail_x15_r0_body.P84
    ⟨19868, 16937, 2741371, 3674⟩ ⟨19871, 16964, 2741377, 3692⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap84
  clean := bodyClean84
  cfix := PRE_first_tail_x15_r0_body.cfix84
  zpl := PRE_first_tail_x15_r0_body.zpl84
  zplnd := PRE_first_tail_x15_r0_body.zplnd84
  zn1 := PRE_first_tail_x15_r0_body.zn184
  zfirst := PRE_first_tail_x15_r0_body.zfirst84
  zscn := PRE_first_tail_x15_r0_body.zscn84
  zsmn := PRE_first_tail_x15_r0_body.zsmn84
  zgrow := PRE_first_tail_x15_r0_body.zgrow84
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab84
  zfresh := PRE_first_tail_x15_r0_body.zfresh84
  zcnd := PRE_first_tail_x15_r0_body.zcnd84
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi84
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt84
  zgP := PRE_first_tail_x15_r0_body.zg84_2665
  zkP := PRE_first_tail_x15_r0_body.zk84_2665
  zmP := PRE_first_tail_x15_r0_body.zm84_2665
  zgC := PRE_first_tail_x15_r0_body.zg84_2673467
  zkC := PRE_first_tail_x15_r0_body.zk84_2673467
  zmC := PRE_first_tail_x15_r0_body.zm84_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw84_2673472
  zwV := PRE_first_tail_x15_r0_body.zw84_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap84
  zclbd := PRE_first_tail_x15_r0_body.zclbd84
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap84 PRE_first_tail_x15_r0_body.stFoot84 PRE_first_tail_x15_r0_body.iso84 PRE_first_tail_x15_r0_body.zwr84
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP84
  csupp := PRE_first_tail_x15_r0_body.csupp84
  cbound := PRE_first_tail_x15_r0_body.cbound84
  zimg := PRE_first_tail_x15_r0_body.zimg84
  zctl := PRE_first_tail_x15_r0_body.zctl84
  zstack := PRE_first_tail_x15_r0_body.zstack84
  zjobs := PRE_first_tail_x15_r0_body.zjobs84
  zstores := PRE_first_tail_x15_r0_body.zstores84
  zroots := PRE_first_tail_x15_r0_body.zroots84
  znC := PRE_first_tail_x15_r0_body.znC84
  ctab := PRE_first_tail_x15_r0_body.ctab84
  zbin := PRE_first_tail_x15_r0_body.zbin84
  cbridge := PRE_first_tail_x15_r0_body.cbridge84
  sbridge := bodyBridge84
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj84
  cshiftR := fun h hNL => bodyCshift84 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN84
  raised := PRE_first_tail_x15_r0_body.raised84
  cbigs := PRE_first_tail_x15_r0_body.cbigs84
  cjcl := PRE_first_tail_x15_r0_body.cjcl84
  xnLe := Nat.le_of_ble_eq_true bodyXn84
  loLe := Nat.le_of_ble_eq_true bodyLo84
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB84
  cntM := bodyCntM84
  hiLe := Nat.le_of_ble_eq_true bodyHi84
  nhiLe := Nat.le_of_ble_eq_true bodyNhi84
  jsHeap := bodyJs84
  jsRoots := bodyJsRoots84
  jsNative := bodyJsNative84
  framesEmpty := bodyFramesEmpty84
  trailOld := by decide
  lowVars := bodyLow84

def bodyQs84 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs84 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr84.map fun r => nth? PRE_first_tail_x15_r0_body.st84.S5.tab r
kernel_rfl bodyResChk84 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs84 bodyQs84) = true
kernel_rfl bodyLq84 : bodyQs84.length = PRE_first_tail_x15_r0_body.cws84.length
kernel_rfl bodyNrLo84 : PRE_first_tail_x15_r0_body.nr84.all (Nat.ble PRE_first_tail_x15_r0_body.S821.tab.length) = true
kernel_rfl bodySub84 : (Oracles.PRE_first_tail_x15_r0_body.map_site84.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost84 : postSubB bodyM PRE_first_tail_x15_r0_body.ws84 PRE_first_tail_x15_r0_body.cws84 bodyQs84 = true
kernel_rfl bodyDrop84 : Nat.ble (31092 + (PRE_first_tail_x15_r0_body.s822.next - PRE_first_tail_x15_r0_body.s823.next)) 32241 = true
kernel_rfl bodyDropH84 : Nat.ble (560 + ((mlxOf PRE_first_tail_x15_r0_body.s822.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s823.ffi).next)) 585 = true
kernel_rfl bodyDropN84 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s822.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s823.ffi).nnext)) 0 = true
kernel_rfl bodyDv84 : bodyΘ.1.take 459 = bodyΘ.1.take 441 ++ PRE_first_tail_x15_r0_body.cws84
kernel_rfl bodyDe84 : bodyΘ.2.take 459 = bodyΘ.2.take 441 ++ PRE_first_tail_x15_r0_body.nr84.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st84.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 441) (bodyΘ.2.take 441)))
kernel_rfl bodyDl84 : (bodyΘ.1.take 441).length = (bodyΘ.2.take 441).length
kernel_rfl bodyDold84 : (bodyΘ.1.take 441).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws84).isNone && !PRE_first_tail_x15_r0_body.ws84.contains v) = true
kernel_rfl bodyDfree84 : (bodyΘ.2.take 459).all (fun e => (PRE_first_tail_x15_r0_body.cws84 ++ PRE_first_tail_x15_r0_body.ws84).all fun w => e.noVar w) = true

theorem bodyStep84 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31092, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s821 PRE_first_tail_x15_r0_body.S821)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32241, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s823 PRE_first_tail_x15_r0_body.S823) (11334 + 1) :=
  bodySite bodyFacts84.cfix bodyFacts84.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st84.S5.tab) (Es := bodyEs84) (qs := bodyQs84)
    (ok := PRE_first_tail_x15_r0_body.st84.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site84 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts84
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site84 r hr) hi (MapOk.sub hm (sub_of_all bodySub84)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk84 r hr) hi hm ho hq)
    bodyLq84 rfl bodyNrLo84 (postSub_sound bodyPost84)
    (Nat.le_of_ble_eq_true bodyDrop84) (by decide) (Nat.le_of_ble_eq_true bodyDropH84) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN84) (by decide)
    bodyDv84 bodyDe84 bodyDl84 bodyDold84 bodyDfree84 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
