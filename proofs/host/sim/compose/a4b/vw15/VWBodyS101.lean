import host.sim.compose.a4b.vw15.VWBodyJ101
import host.sim.compose.a4b.vw15.VWBodySite101
import host.sim.compose.a4b.vw15.VWBodyOracles_25
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B25
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift101 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S977.tab.length PRE_first_tail_x15_r0_body.s977.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P101.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P101 4372 PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.s979.ffi PRE_first_tail_x15_r0_body.s978.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_101
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_101
  have hcl : SSt (· < 4372) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s979.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S977.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_101] <;> decide) PRE_first_tail_x15_r0_body.cnodesK101 PRE_first_tail_x15_r0_body.cobjsK101
      PRE_first_tail_x15_r0_body.citemsK101 PRE_first_tail_x15_r0_body.cbd101 PRE_first_tail_x15_r0_body.csst101
  exact PRE_first_tail_x15_r0_body.cshift101 bodyNcl101 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_101] at this; exact this)


kernel_rfl bodyFramesEmpty101 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s978 a).isEmpty) = true
kernel_rfl bodyJsRoots101 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s977.next) PRE_first_tail_x15_r0_body.s979.trace PRE_first_tail_x15_r0_body.s979 = true
kernel_rfl bodyJsNative101 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s979.ffi) = true
kernel_rfl bodyLow101 : (PRE_first_tail_x15_r0_body.cws101 ++ PRE_first_tail_x15_r0_body.ws101).all (Nat.ble 9) = true
kernel_rfl bodyCntM101 : countersOkB PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.s978 = true
kernel_rfl bodyHi101 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s979.ffi).next setupP.E = true
kernel_rfl bodyNhi101 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s979.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge101 : bridgeOf PRE_first_tail_x15_r0_body.s978.ffi = bridgeOf PRE_first_tail_x15_r0_body.s977.ffi
kernel_rfl bodyNN101 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s977.ffi).nnext PRE_first_tail_x15_r0_body.P101.NL = true
kernel_rfl bodyXn101 : Nat.ble (⟨20184, 17281, 2753836, 4372⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s979.ffi).next = true
kernel_rfl bodyLo101 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s979.ffi).next = true
theorem bodyFacts101 : BodySiteFacts PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.s978 PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S977 PRE_first_tail_x15_r0_body.S978 PRE_first_tail_x15_r0_body.S979
    PRE_first_tail_x15_r0_body.ws101 PRE_first_tail_x15_r0_body.cws101 PRE_first_tail_x15_r0_body.nr101 PRE_first_tail_x15_r0_body.pl101 PRE_first_tail_x15_r0_body.cl101 2753855 4372 PRE_first_tail_x15_r0_body.kd101 PRE_first_tail_x15_r0_body.kappa101 PRE_first_tail_x15_r0_body.P101
    ⟨20184, 17281, 2753835, 4372⟩ ⟨20184, 17281, 2753836, 4372⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap101
  clean := bodyClean101
  cfix := PRE_first_tail_x15_r0_body.cfix101
  zpl := PRE_first_tail_x15_r0_body.zpl101
  zplnd := PRE_first_tail_x15_r0_body.zplnd101
  zn1 := PRE_first_tail_x15_r0_body.zn1101
  zfirst := PRE_first_tail_x15_r0_body.zfirst101
  zscn := PRE_first_tail_x15_r0_body.zscn101
  zsmn := PRE_first_tail_x15_r0_body.zsmn101
  zgrow := PRE_first_tail_x15_r0_body.zgrow101
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab101
  zfresh := PRE_first_tail_x15_r0_body.zfresh101
  zcnd := PRE_first_tail_x15_r0_body.zcnd101
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi101
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt101
  zgP := PRE_first_tail_x15_r0_body.zg101_2665
  zkP := PRE_first_tail_x15_r0_body.zk101_2665
  zmP := PRE_first_tail_x15_r0_body.zm101_2665
  zgC := PRE_first_tail_x15_r0_body.zg101_2673467
  zkC := PRE_first_tail_x15_r0_body.zk101_2673467
  zmC := PRE_first_tail_x15_r0_body.zm101_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw101_2673472
  zwV := PRE_first_tail_x15_r0_body.zw101_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap101
  zclbd := PRE_first_tail_x15_r0_body.zclbd101
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap101 PRE_first_tail_x15_r0_body.stFoot101 PRE_first_tail_x15_r0_body.iso101 PRE_first_tail_x15_r0_body.zwr101
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP101
  csupp := PRE_first_tail_x15_r0_body.csupp101
  cbound := PRE_first_tail_x15_r0_body.cbound101
  zimg := PRE_first_tail_x15_r0_body.zimg101
  zctl := PRE_first_tail_x15_r0_body.zctl101
  zstack := PRE_first_tail_x15_r0_body.zstack101
  zjobs := PRE_first_tail_x15_r0_body.zjobs101
  zstores := PRE_first_tail_x15_r0_body.zstores101
  zroots := PRE_first_tail_x15_r0_body.zroots101
  znC := PRE_first_tail_x15_r0_body.znC101
  ctab := PRE_first_tail_x15_r0_body.ctab101
  zbin := PRE_first_tail_x15_r0_body.zbin101
  cbridge := PRE_first_tail_x15_r0_body.cbridge101
  sbridge := bodyBridge101
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj101
  cshiftR := fun h hNL => bodyCshift101 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN101
  raised := PRE_first_tail_x15_r0_body.raised101
  cbigs := PRE_first_tail_x15_r0_body.cbigs101
  cjcl := PRE_first_tail_x15_r0_body.cjcl101
  xnLe := Nat.le_of_ble_eq_true bodyXn101
  loLe := Nat.le_of_ble_eq_true bodyLo101
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB101
  cntM := bodyCntM101
  hiLe := Nat.le_of_ble_eq_true bodyHi101
  nhiLe := Nat.le_of_ble_eq_true bodyNhi101
  jsHeap := bodyJs101
  jsRoots := bodyJsRoots101
  jsNative := bodyJsNative101
  framesEmpty := bodyFramesEmpty101
  trailOld := by decide
  lowVars := bodyLow101

def bodyQs101 : List (Option Q) := []
noncomputable def bodyEs101 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr101.map fun r => nth? PRE_first_tail_x15_r0_body.st101.S2.tab r
kernel_rfl bodyResChk101 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs101 bodyQs101) = true
kernel_rfl bodyLq101 : bodyQs101.length = PRE_first_tail_x15_r0_body.cws101.length
kernel_rfl bodyNrLo101 : PRE_first_tail_x15_r0_body.nr101.all (Nat.ble PRE_first_tail_x15_r0_body.S977.tab.length) = true
kernel_rfl bodySub101 : (Oracles.PRE_first_tail_x15_r0_body.map_site101.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost101 : postSubB bodyM PRE_first_tail_x15_r0_body.ws101 PRE_first_tail_x15_r0_body.cws101 bodyQs101 = true
kernel_rfl bodyDrop101 : Nat.ble (37276 + (PRE_first_tail_x15_r0_body.s978.next - PRE_first_tail_x15_r0_body.s979.next)) 37295 = true
kernel_rfl bodyDropH101 : Nat.ble (687 + ((mlxOf PRE_first_tail_x15_r0_body.s978.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s979.ffi).next)) 687 = true
kernel_rfl bodyDropN101 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s978.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s979.ffi).nnext)) 0 = true
kernel_rfl bodyDv101 : bodyΘ.1.take 540 = bodyΘ.1.take 540 ++ PRE_first_tail_x15_r0_body.cws101
kernel_rfl bodyDe101 : bodyΘ.2.take 540 = bodyΘ.2.take 540 ++ PRE_first_tail_x15_r0_body.nr101.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st101.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 540) (bodyΘ.2.take 540)))
kernel_rfl bodyDl101 : (bodyΘ.1.take 540).length = (bodyΘ.2.take 540).length
kernel_rfl bodyDold101 : (bodyΘ.1.take 540).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws101).isNone && !PRE_first_tail_x15_r0_body.ws101.contains v) = true
kernel_rfl bodyDfree101 : (bodyΘ.2.take 540).all (fun e => (PRE_first_tail_x15_r0_body.cws101 ++ PRE_first_tail_x15_r0_body.ws101).all fun w => e.noVar w) = true

theorem bodyStep101 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37276, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.S977)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37295, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s979 PRE_first_tail_x15_r0_body.S979) (206 + 1) :=
  bodySite bodyFacts101.cfix bodyFacts101.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st101.S2.tab) (Es := bodyEs101) (qs := bodyQs101)
    (ok := PRE_first_tail_x15_r0_body.st101.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site101 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts101
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site101 r hr) hi (MapOk.sub hm (sub_of_all bodySub101)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk101 r hr) hi hm ho hq)
    bodyLq101 rfl bodyNrLo101 (postSub_sound bodyPost101)
    (Nat.le_of_ble_eq_true bodyDrop101) (by decide) (Nat.le_of_ble_eq_true bodyDropH101) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN101) (by decide)
    bodyDv101 bodyDe101 bodyDl101 bodyDold101 bodyDfree101 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
