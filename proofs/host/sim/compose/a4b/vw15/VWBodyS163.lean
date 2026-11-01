import host.sim.compose.a4b.vw15.VWBodyJ163
import host.sim.compose.a4b.vw15.VWBodySite163
import host.sim.compose.a4b.vw15.VWBodyOracles_40
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift163 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1577.tab.length PRE_first_tail_x15_r0_body.s1577.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P163.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P163 7049 PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.s1579.ffi PRE_first_tail_x15_r0_body.s1578.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_163
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_163
  have hcl : SSt (· < 7049) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1579.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1577.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_163] <;> decide) PRE_first_tail_x15_r0_body.cnodesK163 PRE_first_tail_x15_r0_body.cobjsK163
      PRE_first_tail_x15_r0_body.citemsK163 PRE_first_tail_x15_r0_body.cbd163 PRE_first_tail_x15_r0_body.csst163
  exact PRE_first_tail_x15_r0_body.cshift163 bodyNcl163 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_163] at this; exact this)


kernel_rfl bodyFramesEmpty163 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1578 a).isEmpty) = true
kernel_rfl bodyJsRoots163 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1577.next) PRE_first_tail_x15_r0_body.s1579.trace PRE_first_tail_x15_r0_body.s1579 = true
kernel_rfl bodyJsNative163 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1579.ffi) = true
kernel_rfl bodyLow163 : (PRE_first_tail_x15_r0_body.cws163 ++ PRE_first_tail_x15_r0_body.ws163).all (Nat.ble 9) = true
kernel_rfl bodyCntM163 : countersOkB PRE_first_tail_x15_r0_body.s1577 PRE_first_tail_x15_r0_body.s1578 = true
kernel_rfl bodyHi163 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1579.ffi).next setupP.E = true
kernel_rfl bodyNhi163 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1579.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge163 : bridgeOf PRE_first_tail_x15_r0_body.s1578.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1577.ffi
kernel_rfl bodyNN163 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1577.ffi).nnext PRE_first_tail_x15_r0_body.P163.NL = true
kernel_rfl bodyXn163 : Nat.ble (⟨21414, 18525, 2802887, 7049⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1579.ffi).next = true
kernel_rfl bodyLo163 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1579.ffi).next = true
theorem bodyFacts163 : BodySiteFacts PRE_first_tail_x15_r0_body.s1577 PRE_first_tail_x15_r0_body.s1578 PRE_first_tail_x15_r0_body.s1579 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1577 PRE_first_tail_x15_r0_body.S1578 PRE_first_tail_x15_r0_body.S1579
    PRE_first_tail_x15_r0_body.ws163 PRE_first_tail_x15_r0_body.cws163 PRE_first_tail_x15_r0_body.nr163 PRE_first_tail_x15_r0_body.pl163 PRE_first_tail_x15_r0_body.cl163 2802889 7049 PRE_first_tail_x15_r0_body.kd163 PRE_first_tail_x15_r0_body.kappa163 PRE_first_tail_x15_r0_body.P163
    ⟨21414, 18525, 2802887, 7049⟩ ⟨21414, 18525, 2802887, 7049⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap163
  clean := bodyClean163
  cfix := PRE_first_tail_x15_r0_body.cfix163
  zpl := PRE_first_tail_x15_r0_body.zpl163
  zplnd := PRE_first_tail_x15_r0_body.zplnd163
  zn1 := PRE_first_tail_x15_r0_body.zn1163
  zfirst := PRE_first_tail_x15_r0_body.zfirst163
  zscn := PRE_first_tail_x15_r0_body.zscn163
  zsmn := PRE_first_tail_x15_r0_body.zsmn163
  zgrow := PRE_first_tail_x15_r0_body.zgrow163
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab163
  zfresh := PRE_first_tail_x15_r0_body.zfresh163
  zcnd := PRE_first_tail_x15_r0_body.zcnd163
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi163
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt163
  zgP := PRE_first_tail_x15_r0_body.zg163_2665
  zkP := PRE_first_tail_x15_r0_body.zk163_2665
  zmP := PRE_first_tail_x15_r0_body.zm163_2665
  zgC := PRE_first_tail_x15_r0_body.zg163_2673467
  zkC := PRE_first_tail_x15_r0_body.zk163_2673467
  zmC := PRE_first_tail_x15_r0_body.zm163_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw163_2673472
  zwV := PRE_first_tail_x15_r0_body.zw163_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap163
  zclbd := PRE_first_tail_x15_r0_body.zclbd163
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap163 PRE_first_tail_x15_r0_body.stFoot163 PRE_first_tail_x15_r0_body.iso163 PRE_first_tail_x15_r0_body.zwr163
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP163
  csupp := PRE_first_tail_x15_r0_body.csupp163
  cbound := PRE_first_tail_x15_r0_body.cbound163
  zimg := PRE_first_tail_x15_r0_body.zimg163
  zctl := PRE_first_tail_x15_r0_body.zctl163
  zstack := PRE_first_tail_x15_r0_body.zstack163
  zjobs := PRE_first_tail_x15_r0_body.zjobs163
  zstores := PRE_first_tail_x15_r0_body.zstores163
  zroots := PRE_first_tail_x15_r0_body.zroots163
  znC := PRE_first_tail_x15_r0_body.znC163
  ctab := PRE_first_tail_x15_r0_body.ctab163
  zbin := PRE_first_tail_x15_r0_body.zbin163
  cbridge := PRE_first_tail_x15_r0_body.cbridge163
  sbridge := bodyBridge163
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj163
  cshiftR := fun h hNL => bodyCshift163 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN163
  raised := PRE_first_tail_x15_r0_body.raised163
  cbigs := PRE_first_tail_x15_r0_body.cbigs163
  cjcl := PRE_first_tail_x15_r0_body.cjcl163
  xnLe := Nat.le_of_ble_eq_true bodyXn163
  loLe := Nat.le_of_ble_eq_true bodyLo163
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB163
  cntM := bodyCntM163
  hiLe := Nat.le_of_ble_eq_true bodyHi163
  nhiLe := Nat.le_of_ble_eq_true bodyNhi163
  jsHeap := bodyJs163
  jsRoots := bodyJsRoots163
  jsNative := bodyJsNative163
  framesEmpty := bodyFramesEmpty163
  trailOld := by decide
  lowVars := bodyLow163

def bodyQs163 : List (Option Q) := []
noncomputable def bodyEs163 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr163.map fun r => nth? PRE_first_tail_x15_r0_body.st163.S2.tab r
kernel_rfl bodyResChk163 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs163 bodyQs163) = true
kernel_rfl bodyLq163 : bodyQs163.length = PRE_first_tail_x15_r0_body.cws163.length
kernel_rfl bodyNrLo163 : PRE_first_tail_x15_r0_body.nr163.all (Nat.ble PRE_first_tail_x15_r0_body.S1577.tab.length) = true
kernel_rfl bodySub163 : (Oracles.PRE_first_tail_x15_r0_body.map_site163.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost163 : postSubB bodyM PRE_first_tail_x15_r0_body.ws163 PRE_first_tail_x15_r0_body.cws163 bodyQs163 = true
kernel_rfl bodyDrop163 : Nat.ble (57714 + (PRE_first_tail_x15_r0_body.s1578.next - PRE_first_tail_x15_r0_body.s1579.next)) 57716 = true
kernel_rfl bodyDropH163 : Nat.ble (1097 + ((mlxOf PRE_first_tail_x15_r0_body.s1578.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1579.ffi).next)) 1097 = true
kernel_rfl bodyDropN163 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1578.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1579.ffi).nnext)) 0 = true
kernel_rfl bodyDv163 : bodyΘ.1.take 873 = bodyΘ.1.take 873 ++ PRE_first_tail_x15_r0_body.cws163
kernel_rfl bodyDe163 : bodyΘ.2.take 873 = bodyΘ.2.take 873 ++ PRE_first_tail_x15_r0_body.nr163.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st163.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 873) (bodyΘ.2.take 873)))
kernel_rfl bodyDl163 : (bodyΘ.1.take 873).length = (bodyΘ.2.take 873).length
kernel_rfl bodyDold163 : (bodyΘ.1.take 873).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws163).isNone && !PRE_first_tail_x15_r0_body.ws163.contains v) = true
kernel_rfl bodyDfree163 : (bodyΘ.2.take 873).all (fun e => (PRE_first_tail_x15_r0_body.cws163 ++ PRE_first_tail_x15_r0_body.ws163).all fun w => e.noVar w) = true

theorem bodyStep163 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57714, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1577 PRE_first_tail_x15_r0_body.S1577)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57716, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1579 PRE_first_tail_x15_r0_body.S1579) (27 + 1) :=
  bodySite bodyFacts163.cfix bodyFacts163.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st163.S2.tab) (Es := bodyEs163) (qs := bodyQs163)
    (ok := PRE_first_tail_x15_r0_body.st163.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site163 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts163
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site163 r hr) hi (MapOk.sub hm (sub_of_all bodySub163)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk163 r hr) hi hm ho hq)
    bodyLq163 rfl bodyNrLo163 (postSub_sound bodyPost163)
    (Nat.le_of_ble_eq_true bodyDrop163) (by decide) (Nat.le_of_ble_eq_true bodyDropH163) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN163) (by decide)
    bodyDv163 bodyDe163 bodyDl163 bodyDold163 bodyDfree163 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
