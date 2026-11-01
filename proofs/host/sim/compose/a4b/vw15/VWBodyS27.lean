import host.sim.compose.a4b.vw15.VWBodyJ27
import host.sim.compose.a4b.vw15.VWBodySite27
import host.sim.compose.a4b.vw15.VWBodyOracles_6
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift27 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S275.tab.length PRE_first_tail_x15_r0_body.s275.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P27.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P27 1256 PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.s277.ffi PRE_first_tail_x15_r0_body.s276.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_27
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_27
  have hcl : SSt (· < 1256) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S275.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_27] <;> decide) PRE_first_tail_x15_r0_body.cnodesK27 PRE_first_tail_x15_r0_body.cobjsK27
      PRE_first_tail_x15_r0_body.citemsK27 PRE_first_tail_x15_r0_body.cbd27 PRE_first_tail_x15_r0_body.csst27
  exact PRE_first_tail_x15_r0_body.cshift27 bodyNcl27 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_27] at this; exact this)


kernel_rfl bodyFramesEmpty27 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s276 a).isEmpty) = true
kernel_rfl bodyJsRoots27 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s275.next) PRE_first_tail_x15_r0_body.s277.trace PRE_first_tail_x15_r0_body.s277 = true
kernel_rfl bodyJsNative27 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s277.ffi) = true
kernel_rfl bodyLow27 : (PRE_first_tail_x15_r0_body.cws27 ++ PRE_first_tail_x15_r0_body.ws27).all (Nat.ble 9) = true
kernel_rfl bodyCntM27 : countersOkB PRE_first_tail_x15_r0_body.s275 PRE_first_tail_x15_r0_body.s276 = true
kernel_rfl bodyHi27 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s277.ffi).next setupP.E = true
kernel_rfl bodyNhi27 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s277.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge27 : bridgeOf PRE_first_tail_x15_r0_body.s276.ffi = bridgeOf PRE_first_tail_x15_r0_body.s275.ffi
kernel_rfl bodyNN27 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s275.ffi).nnext PRE_first_tail_x15_r0_body.P27.NL = true
kernel_rfl bodyXn27 : Nat.ble (⟨18748, 15842, 2696549, 1256⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s277.ffi).next = true
kernel_rfl bodyLo27 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s277.ffi).next = true
theorem bodyFacts27 : BodySiteFacts PRE_first_tail_x15_r0_body.s275 PRE_first_tail_x15_r0_body.s276 PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S275 PRE_first_tail_x15_r0_body.S276 PRE_first_tail_x15_r0_body.S277
    PRE_first_tail_x15_r0_body.ws27 PRE_first_tail_x15_r0_body.cws27 PRE_first_tail_x15_r0_body.nr27 PRE_first_tail_x15_r0_body.pl27 PRE_first_tail_x15_r0_body.cl27 2697698 1256 PRE_first_tail_x15_r0_body.kd27 PRE_first_tail_x15_r0_body.kappa27 PRE_first_tail_x15_r0_body.P27
    ⟨18745, 15815, 2696543, 1238⟩ ⟨18748, 15842, 2696549, 1256⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap27
  clean := bodyClean27
  cfix := PRE_first_tail_x15_r0_body.cfix27
  zpl := PRE_first_tail_x15_r0_body.zpl27
  zplnd := PRE_first_tail_x15_r0_body.zplnd27
  zn1 := PRE_first_tail_x15_r0_body.zn127
  zfirst := PRE_first_tail_x15_r0_body.zfirst27
  zscn := PRE_first_tail_x15_r0_body.zscn27
  zsmn := PRE_first_tail_x15_r0_body.zsmn27
  zgrow := PRE_first_tail_x15_r0_body.zgrow27
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab27
  zfresh := PRE_first_tail_x15_r0_body.zfresh27
  zcnd := PRE_first_tail_x15_r0_body.zcnd27
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi27
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt27
  zgP := PRE_first_tail_x15_r0_body.zg27_2665
  zkP := PRE_first_tail_x15_r0_body.zk27_2665
  zmP := PRE_first_tail_x15_r0_body.zm27_2665
  zgC := PRE_first_tail_x15_r0_body.zg27_2673467
  zkC := PRE_first_tail_x15_r0_body.zk27_2673467
  zmC := PRE_first_tail_x15_r0_body.zm27_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw27_2673472
  zwV := PRE_first_tail_x15_r0_body.zw27_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap27
  zclbd := PRE_first_tail_x15_r0_body.zclbd27
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap27 PRE_first_tail_x15_r0_body.stFoot27 PRE_first_tail_x15_r0_body.iso27 PRE_first_tail_x15_r0_body.zwr27
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP27
  csupp := PRE_first_tail_x15_r0_body.csupp27
  cbound := PRE_first_tail_x15_r0_body.cbound27
  zimg := PRE_first_tail_x15_r0_body.zimg27
  zctl := PRE_first_tail_x15_r0_body.zctl27
  zstack := PRE_first_tail_x15_r0_body.zstack27
  zjobs := PRE_first_tail_x15_r0_body.zjobs27
  zstores := PRE_first_tail_x15_r0_body.zstores27
  zroots := PRE_first_tail_x15_r0_body.zroots27
  znC := PRE_first_tail_x15_r0_body.znC27
  ctab := PRE_first_tail_x15_r0_body.ctab27
  zbin := PRE_first_tail_x15_r0_body.zbin27
  cbridge := PRE_first_tail_x15_r0_body.cbridge27
  sbridge := bodyBridge27
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj27
  cshiftR := fun h hNL => bodyCshift27 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN27
  raised := PRE_first_tail_x15_r0_body.raised27
  cbigs := PRE_first_tail_x15_r0_body.cbigs27
  cjcl := PRE_first_tail_x15_r0_body.cjcl27
  xnLe := Nat.le_of_ble_eq_true bodyXn27
  loLe := Nat.le_of_ble_eq_true bodyLo27
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB27
  cntM := bodyCntM27
  hiLe := Nat.le_of_ble_eq_true bodyHi27
  nhiLe := Nat.le_of_ble_eq_true bodyNhi27
  jsHeap := bodyJs27
  jsRoots := bodyJsRoots27
  jsNative := bodyJsNative27
  framesEmpty := bodyFramesEmpty27
  trailOld := by decide
  lowVars := bodyLow27

def bodyQs27 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs27 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr27.map fun r => nth? PRE_first_tail_x15_r0_body.st27.S5.tab r
kernel_rfl bodyResChk27 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs27 bodyQs27) = true
kernel_rfl bodyLq27 : bodyQs27.length = PRE_first_tail_x15_r0_body.cws27.length
kernel_rfl bodyNrLo27 : PRE_first_tail_x15_r0_body.nr27.all (Nat.ble PRE_first_tail_x15_r0_body.S275.tab.length) = true
kernel_rfl bodySub27 : (Oracles.PRE_first_tail_x15_r0_body.map_site27.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost27 : postSubB bodyM PRE_first_tail_x15_r0_body.ws27 PRE_first_tail_x15_r0_body.cws27 bodyQs27 = true
kernel_rfl bodyDrop27 : Nat.ble (12974 + (PRE_first_tail_x15_r0_body.s276.next - PRE_first_tail_x15_r0_body.s277.next)) 14123 = true
kernel_rfl bodyDropH27 : Nat.ble (200 + ((mlxOf PRE_first_tail_x15_r0_body.s276.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s277.ffi).next)) 225 = true
kernel_rfl bodyDropN27 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s276.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s277.ffi).nnext)) 0 = true
kernel_rfl bodyDv27 : bodyΘ.1.take 162 = bodyΘ.1.take 144 ++ PRE_first_tail_x15_r0_body.cws27
kernel_rfl bodyDe27 : bodyΘ.2.take 162 = bodyΘ.2.take 144 ++ PRE_first_tail_x15_r0_body.nr27.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st27.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 144) (bodyΘ.2.take 144)))
kernel_rfl bodyDl27 : (bodyΘ.1.take 144).length = (bodyΘ.2.take 144).length
kernel_rfl bodyDold27 : (bodyΘ.1.take 144).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws27).isNone && !PRE_first_tail_x15_r0_body.ws27.contains v) = true
kernel_rfl bodyDfree27 : (bodyΘ.2.take 162).all (fun e => (PRE_first_tail_x15_r0_body.cws27 ++ PRE_first_tail_x15_r0_body.ws27).all fun w => e.noVar w) = true

theorem bodyStep27 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s275 PRE_first_tail_x15_r0_body.S275)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.S277) (11334 + 1) :=
  bodySite bodyFacts27.cfix bodyFacts27.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st27.S5.tab) (Es := bodyEs27) (qs := bodyQs27)
    (ok := PRE_first_tail_x15_r0_body.st27.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site27 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts27
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site27 r hr) hi (MapOk.sub hm (sub_of_all bodySub27)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk27 r hr) hi hm ho hq)
    bodyLq27 rfl bodyNrLo27 (postSub_sound bodyPost27)
    (Nat.le_of_ble_eq_true bodyDrop27) (by decide) (Nat.le_of_ble_eq_true bodyDropH27) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN27) (by decide)
    bodyDv27 bodyDe27 bodyDl27 bodyDold27 bodyDfree27 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
