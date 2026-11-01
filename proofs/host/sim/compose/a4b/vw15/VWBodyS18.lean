import host.sim.compose.a4b.vw15.VWBodyJ18
import host.sim.compose.a4b.vw15.VWBodySite18
import host.sim.compose.a4b.vw15.VWBodyOracles_4
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift18 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S189.tab.length PRE_first_tail_x15_r0_body.s189.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P18.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P18 872 PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.s191.ffi PRE_first_tail_x15_r0_body.s190.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_18
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_18
  have hcl : SSt (· < 872) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s191.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S189.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_18] <;> decide) PRE_first_tail_x15_r0_body.cnodesK18 PRE_first_tail_x15_r0_body.cobjsK18
      PRE_first_tail_x15_r0_body.citemsK18 PRE_first_tail_x15_r0_body.cbd18 PRE_first_tail_x15_r0_body.csst18
  exact PRE_first_tail_x15_r0_body.cshift18 bodyNcl18 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_18] at this; exact this)


kernel_rfl bodyFramesEmpty18 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s190 a).isEmpty) = true
kernel_rfl bodyJsRoots18 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s189.next) PRE_first_tail_x15_r0_body.s191.trace PRE_first_tail_x15_r0_body.s191 = true
kernel_rfl bodyJsNative18 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s191.ffi) = true
kernel_rfl bodyLow18 : (PRE_first_tail_x15_r0_body.cws18 ++ PRE_first_tail_x15_r0_body.ws18).all (Nat.ble 9) = true
kernel_rfl bodyCntM18 : countersOkB PRE_first_tail_x15_r0_body.s189 PRE_first_tail_x15_r0_body.s190 = true
kernel_rfl bodyHi18 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s191.ffi).next setupP.E = true
kernel_rfl bodyNhi18 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s191.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge18 : bridgeOf PRE_first_tail_x15_r0_body.s190.ffi = bridgeOf PRE_first_tail_x15_r0_body.s189.ffi
kernel_rfl bodyNN18 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s189.ffi).nnext PRE_first_tail_x15_r0_body.P18.NL = true
kernel_rfl bodyXn18 : Nat.ble (⟨18569, 15668, 2689393, 872⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s191.ffi).next = true
kernel_rfl bodyLo18 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s191.ffi).next = true
theorem bodyFacts18 : BodySiteFacts PRE_first_tail_x15_r0_body.s189 PRE_first_tail_x15_r0_body.s190 PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S189 PRE_first_tail_x15_r0_body.S190 PRE_first_tail_x15_r0_body.S191
    PRE_first_tail_x15_r0_body.ws18 PRE_first_tail_x15_r0_body.cws18 PRE_first_tail_x15_r0_body.nr18 PRE_first_tail_x15_r0_body.pl18 PRE_first_tail_x15_r0_body.cl18 2690542 872 PRE_first_tail_x15_r0_body.kd18 PRE_first_tail_x15_r0_body.kappa18 PRE_first_tail_x15_r0_body.P18
    ⟨18566, 15641, 2689387, 854⟩ ⟨18569, 15668, 2689393, 872⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap18
  clean := bodyClean18
  cfix := PRE_first_tail_x15_r0_body.cfix18
  zpl := PRE_first_tail_x15_r0_body.zpl18
  zplnd := PRE_first_tail_x15_r0_body.zplnd18
  zn1 := PRE_first_tail_x15_r0_body.zn118
  zfirst := PRE_first_tail_x15_r0_body.zfirst18
  zscn := PRE_first_tail_x15_r0_body.zscn18
  zsmn := PRE_first_tail_x15_r0_body.zsmn18
  zgrow := PRE_first_tail_x15_r0_body.zgrow18
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab18
  zfresh := PRE_first_tail_x15_r0_body.zfresh18
  zcnd := PRE_first_tail_x15_r0_body.zcnd18
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi18
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt18
  zgP := PRE_first_tail_x15_r0_body.zg18_2665
  zkP := PRE_first_tail_x15_r0_body.zk18_2665
  zmP := PRE_first_tail_x15_r0_body.zm18_2665
  zgC := PRE_first_tail_x15_r0_body.zg18_2673467
  zkC := PRE_first_tail_x15_r0_body.zk18_2673467
  zmC := PRE_first_tail_x15_r0_body.zm18_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw18_2673472
  zwV := PRE_first_tail_x15_r0_body.zw18_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap18
  zclbd := PRE_first_tail_x15_r0_body.zclbd18
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap18 PRE_first_tail_x15_r0_body.stFoot18 PRE_first_tail_x15_r0_body.iso18 PRE_first_tail_x15_r0_body.zwr18
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP18
  csupp := PRE_first_tail_x15_r0_body.csupp18
  cbound := PRE_first_tail_x15_r0_body.cbound18
  zimg := PRE_first_tail_x15_r0_body.zimg18
  zctl := PRE_first_tail_x15_r0_body.zctl18
  zstack := PRE_first_tail_x15_r0_body.zstack18
  zjobs := PRE_first_tail_x15_r0_body.zjobs18
  zstores := PRE_first_tail_x15_r0_body.zstores18
  zroots := PRE_first_tail_x15_r0_body.zroots18
  znC := PRE_first_tail_x15_r0_body.znC18
  ctab := PRE_first_tail_x15_r0_body.ctab18
  zbin := PRE_first_tail_x15_r0_body.zbin18
  cbridge := PRE_first_tail_x15_r0_body.cbridge18
  sbridge := bodyBridge18
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj18
  cshiftR := fun h hNL => bodyCshift18 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN18
  raised := PRE_first_tail_x15_r0_body.raised18
  cbigs := PRE_first_tail_x15_r0_body.cbigs18
  cjcl := PRE_first_tail_x15_r0_body.cjcl18
  xnLe := Nat.le_of_ble_eq_true bodyXn18
  loLe := Nat.le_of_ble_eq_true bodyLo18
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB18
  cntM := bodyCntM18
  hiLe := Nat.le_of_ble_eq_true bodyHi18
  nhiLe := Nat.le_of_ble_eq_true bodyNhi18
  jsHeap := bodyJs18
  jsRoots := bodyJsRoots18
  jsNative := bodyJsNative18
  framesEmpty := bodyFramesEmpty18
  trailOld := by decide
  lowVars := bodyLow18

def bodyQs18 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs18 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr18.map fun r => nth? PRE_first_tail_x15_r0_body.st18.S5.tab r
kernel_rfl bodyResChk18 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs18 bodyQs18) = true
kernel_rfl bodyLq18 : bodyQs18.length = PRE_first_tail_x15_r0_body.cws18.length
kernel_rfl bodyNrLo18 : PRE_first_tail_x15_r0_body.nr18.all (Nat.ble PRE_first_tail_x15_r0_body.S189.tab.length) = true
kernel_rfl bodySub18 : (Oracles.PRE_first_tail_x15_r0_body.map_site18.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost18 : postSubB bodyM PRE_first_tail_x15_r0_body.ws18 PRE_first_tail_x15_r0_body.cws18 bodyQs18 = true
kernel_rfl bodyDrop18 : Nat.ble (10290 + (PRE_first_tail_x15_r0_body.s190.next - PRE_first_tail_x15_r0_body.s191.next)) 11439 = true
kernel_rfl bodyDropH18 : Nat.ble (148 + ((mlxOf PRE_first_tail_x15_r0_body.s190.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s191.ffi).next)) 173 = true
kernel_rfl bodyDropN18 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s190.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s191.ffi).nnext)) 0 = true
kernel_rfl bodyDv18 : bodyΘ.1.take 117 = bodyΘ.1.take 99 ++ PRE_first_tail_x15_r0_body.cws18
kernel_rfl bodyDe18 : bodyΘ.2.take 117 = bodyΘ.2.take 99 ++ PRE_first_tail_x15_r0_body.nr18.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st18.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 99) (bodyΘ.2.take 99)))
kernel_rfl bodyDl18 : (bodyΘ.1.take 99).length = (bodyΘ.2.take 99).length
kernel_rfl bodyDold18 : (bodyΘ.1.take 99).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws18).isNone && !PRE_first_tail_x15_r0_body.ws18.contains v) = true
kernel_rfl bodyDfree18 : (bodyΘ.2.take 117).all (fun e => (PRE_first_tail_x15_r0_body.cws18 ++ PRE_first_tail_x15_r0_body.ws18).all fun w => e.noVar w) = true

theorem bodyStep18 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10290, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s189 PRE_first_tail_x15_r0_body.S189)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11439, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s191 PRE_first_tail_x15_r0_body.S191) (11334 + 1) :=
  bodySite bodyFacts18.cfix bodyFacts18.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st18.S5.tab) (Es := bodyEs18) (qs := bodyQs18)
    (ok := PRE_first_tail_x15_r0_body.st18.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site18 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts18
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site18 r hr) hi (MapOk.sub hm (sub_of_all bodySub18)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk18 r hr) hi hm ho hq)
    bodyLq18 rfl bodyNrLo18 (postSub_sound bodyPost18)
    (Nat.le_of_ble_eq_true bodyDrop18) (by decide) (Nat.le_of_ble_eq_true bodyDropH18) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN18) (by decide)
    bodyDv18 bodyDe18 bodyDl18 bodyDold18 bodyDfree18 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
