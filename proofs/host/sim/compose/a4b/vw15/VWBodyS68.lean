import host.sim.compose.a4b.vw15.VWBodyJ68
import host.sim.compose.a4b.vw15.VWBodySite68
import host.sim.compose.a4b.vw15.VWBodyOracles_17
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B22
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift68 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S661.tab.length PRE_first_tail_x15_r0_body.s661.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P68.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P68 2962 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.s663.ffi PRE_first_tail_x15_r0_body.s662.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_68
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_68
  have hcl : SSt (· < 2962) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s663.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S661.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_68] <;> decide) PRE_first_tail_x15_r0_body.cnodesK68 PRE_first_tail_x15_r0_body.cobjsK68
      PRE_first_tail_x15_r0_body.citemsK68 PRE_first_tail_x15_r0_body.cbd68 PRE_first_tail_x15_r0_body.csst68
  exact PRE_first_tail_x15_r0_body.cshift68 bodyNcl68 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_68] at this; exact this)


kernel_rfl bodyFramesEmpty68 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s662 a).isEmpty) = true
kernel_rfl bodyJsRoots68 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s661.next) PRE_first_tail_x15_r0_body.s663.trace PRE_first_tail_x15_r0_body.s663 = true
kernel_rfl bodyJsNative68 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s663.ffi) = true
kernel_rfl bodyLow68 : (PRE_first_tail_x15_r0_body.cws68 ++ PRE_first_tail_x15_r0_body.ws68).all (Nat.ble 9) = true
kernel_rfl bodyCntM68 : countersOkB PRE_first_tail_x15_r0_body.s661 PRE_first_tail_x15_r0_body.s662 = true
kernel_rfl bodyHi68 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s663.ffi).next setupP.E = true
kernel_rfl bodyNhi68 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s663.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge68 : bridgeOf PRE_first_tail_x15_r0_body.s662.ffi = bridgeOf PRE_first_tail_x15_r0_body.s661.ffi
kernel_rfl bodyNN68 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s661.ffi).nnext PRE_first_tail_x15_r0_body.P68.NL = true
kernel_rfl bodyXn68 : Nat.ble (⟨19533, 16633, 2727844, 2962⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s663.ffi).next = true
kernel_rfl bodyLo68 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s663.ffi).next = true
theorem bodyFacts68 : BodySiteFacts PRE_first_tail_x15_r0_body.s661 PRE_first_tail_x15_r0_body.s662 PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S661 PRE_first_tail_x15_r0_body.S662 PRE_first_tail_x15_r0_body.S663
    PRE_first_tail_x15_r0_body.ws68 PRE_first_tail_x15_r0_body.cws68 PRE_first_tail_x15_r0_body.nr68 PRE_first_tail_x15_r0_body.pl68 PRE_first_tail_x15_r0_body.cl68 2727854 2962 PRE_first_tail_x15_r0_body.kd68 PRE_first_tail_x15_r0_body.kappa68 PRE_first_tail_x15_r0_body.P68
    ⟨19533, 16633, 2727843, 2962⟩ ⟨19533, 16633, 2727844, 2962⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap68
  clean := bodyClean68
  cfix := PRE_first_tail_x15_r0_body.cfix68
  zpl := PRE_first_tail_x15_r0_body.zpl68
  zplnd := PRE_first_tail_x15_r0_body.zplnd68
  zn1 := PRE_first_tail_x15_r0_body.zn168
  zfirst := PRE_first_tail_x15_r0_body.zfirst68
  zscn := PRE_first_tail_x15_r0_body.zscn68
  zsmn := PRE_first_tail_x15_r0_body.zsmn68
  zgrow := PRE_first_tail_x15_r0_body.zgrow68
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab68
  zfresh := PRE_first_tail_x15_r0_body.zfresh68
  zcnd := PRE_first_tail_x15_r0_body.zcnd68
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi68
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt68
  zgP := PRE_first_tail_x15_r0_body.zg68_2665
  zkP := PRE_first_tail_x15_r0_body.zk68_2665
  zmP := PRE_first_tail_x15_r0_body.zm68_2665
  zgC := PRE_first_tail_x15_r0_body.zg68_2673467
  zkC := PRE_first_tail_x15_r0_body.zk68_2673467
  zmC := PRE_first_tail_x15_r0_body.zm68_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw68_2673472
  zwV := PRE_first_tail_x15_r0_body.zw68_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap68
  zclbd := PRE_first_tail_x15_r0_body.zclbd68
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap68 PRE_first_tail_x15_r0_body.stFoot68 PRE_first_tail_x15_r0_body.iso68 PRE_first_tail_x15_r0_body.zwr68
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP68
  csupp := PRE_first_tail_x15_r0_body.csupp68
  cbound := PRE_first_tail_x15_r0_body.cbound68
  zimg := PRE_first_tail_x15_r0_body.zimg68
  zctl := PRE_first_tail_x15_r0_body.zctl68
  zstack := PRE_first_tail_x15_r0_body.zstack68
  zjobs := PRE_first_tail_x15_r0_body.zjobs68
  zstores := PRE_first_tail_x15_r0_body.zstores68
  zroots := PRE_first_tail_x15_r0_body.zroots68
  znC := PRE_first_tail_x15_r0_body.znC68
  ctab := PRE_first_tail_x15_r0_body.ctab68
  zbin := PRE_first_tail_x15_r0_body.zbin68
  cbridge := PRE_first_tail_x15_r0_body.cbridge68
  sbridge := bodyBridge68
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj68
  cshiftR := fun h hNL => bodyCshift68 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN68
  raised := PRE_first_tail_x15_r0_body.raised68
  cbigs := PRE_first_tail_x15_r0_body.cbigs68
  cjcl := PRE_first_tail_x15_r0_body.cjcl68
  xnLe := Nat.le_of_ble_eq_true bodyXn68
  loLe := Nat.le_of_ble_eq_true bodyLo68
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB68
  cntM := bodyCntM68
  hiLe := Nat.le_of_ble_eq_true bodyHi68
  nhiLe := Nat.le_of_ble_eq_true bodyNhi68
  jsHeap := bodyJs68
  jsRoots := bodyJsRoots68
  jsNative := bodyJsNative68
  framesEmpty := bodyFramesEmpty68
  trailOld := by decide
  lowVars := bodyLow68

def bodyQs68 : List (Option Q) := []
noncomputable def bodyEs68 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr68.map fun r => nth? PRE_first_tail_x15_r0_body.st68.S2.tab r
kernel_rfl bodyResChk68 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs68 bodyQs68) = true
kernel_rfl bodyLq68 : bodyQs68.length = PRE_first_tail_x15_r0_body.cws68.length
kernel_rfl bodyNrLo68 : PRE_first_tail_x15_r0_body.nr68.all (Nat.ble PRE_first_tail_x15_r0_body.S661.tab.length) = true
kernel_rfl bodySub68 : (Oracles.PRE_first_tail_x15_r0_body.map_site68.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost68 : postSubB bodyM PRE_first_tail_x15_r0_body.ws68 PRE_first_tail_x15_r0_body.cws68 bodyQs68 = true
kernel_rfl bodyDrop68 : Nat.ble (26875 + (PRE_first_tail_x15_r0_body.s662.next - PRE_first_tail_x15_r0_body.s663.next)) 26885 = true
kernel_rfl bodyDropH68 : Nat.ble (481 + ((mlxOf PRE_first_tail_x15_r0_body.s662.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s663.ffi).next)) 481 = true
kernel_rfl bodyDropN68 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s662.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s663.ffi).nnext)) 0 = true
kernel_rfl bodyDv68 : bodyΘ.1.take 369 = bodyΘ.1.take 369 ++ PRE_first_tail_x15_r0_body.cws68
kernel_rfl bodyDe68 : bodyΘ.2.take 369 = bodyΘ.2.take 369 ++ PRE_first_tail_x15_r0_body.nr68.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st68.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 369) (bodyΘ.2.take 369)))
kernel_rfl bodyDl68 : (bodyΘ.1.take 369).length = (bodyΘ.2.take 369).length
kernel_rfl bodyDold68 : (bodyΘ.1.take 369).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws68).isNone && !PRE_first_tail_x15_r0_body.ws68.contains v) = true
kernel_rfl bodyDfree68 : (bodyΘ.2.take 369).all (fun e => (PRE_first_tail_x15_r0_body.cws68 ++ PRE_first_tail_x15_r0_body.ws68).all fun w => e.noVar w) = true

theorem bodyStep68 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26875, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s661 PRE_first_tail_x15_r0_body.S661)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26885, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.S663) (98 + 1) :=
  bodySite bodyFacts68.cfix bodyFacts68.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 98) (S2 := PRE_first_tail_x15_r0_body.st68.S2.tab) (Es := bodyEs68) (qs := bodyQs68)
    (ok := PRE_first_tail_x15_r0_body.st68.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site68 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts68
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site68 r hr) hi (MapOk.sub hm (sub_of_all bodySub68)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk68 r hr) hi hm ho hq)
    bodyLq68 rfl bodyNrLo68 (postSub_sound bodyPost68)
    (Nat.le_of_ble_eq_true bodyDrop68) (by decide) (Nat.le_of_ble_eq_true bodyDropH68) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN68) (by decide)
    bodyDv68 bodyDe68 bodyDl68 bodyDold68 bodyDfree68 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
