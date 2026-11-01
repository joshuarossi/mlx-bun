import host.sim.compose.a4b.vw15.VWBodyJ57
import host.sim.compose.a4b.vw15.VWBodySite57
import host.sim.compose.a4b.vw15.VWBodyOracles_14
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift57 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S562.tab.length PRE_first_tail_x15_r0_body.s562.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P57.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P57 2535 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.s564.ffi PRE_first_tail_x15_r0_body.s563.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_57
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_57
  have hcl : SSt (· < 2535) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S562.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_57] <;> decide) PRE_first_tail_x15_r0_body.cnodesK57 PRE_first_tail_x15_r0_body.cobjsK57
      PRE_first_tail_x15_r0_body.citemsK57 PRE_first_tail_x15_r0_body.cbd57 PRE_first_tail_x15_r0_body.csst57
  exact PRE_first_tail_x15_r0_body.cshift57 bodyNcl57 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_57] at this; exact this)


kernel_rfl bodyFramesEmpty57 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s563 a).isEmpty) = true
kernel_rfl bodyJsRoots57 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s562.next) PRE_first_tail_x15_r0_body.s564.trace PRE_first_tail_x15_r0_body.s564 = true
kernel_rfl bodyJsNative57 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s564.ffi) = true
kernel_rfl bodyLow57 : (PRE_first_tail_x15_r0_body.cws57 ++ PRE_first_tail_x15_r0_body.ws57).all (Nat.ble 9) = true
kernel_rfl bodyCntM57 : countersOkB PRE_first_tail_x15_r0_body.s562 PRE_first_tail_x15_r0_body.s563 = true
kernel_rfl bodyHi57 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s564.ffi).next setupP.E = true
kernel_rfl bodyNhi57 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s564.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge57 : bridgeOf PRE_first_tail_x15_r0_body.s563.ffi = bridgeOf PRE_first_tail_x15_r0_body.s562.ffi
kernel_rfl bodyNN57 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s562.ffi).nnext PRE_first_tail_x15_r0_body.P57.NL = true
kernel_rfl bodyXn57 : Nat.ble (⟨19341, 16430, 2720183, 2535⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s564.ffi).next = true
kernel_rfl bodyLo57 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s564.ffi).next = true
theorem bodyFacts57 : BodySiteFacts PRE_first_tail_x15_r0_body.s562 PRE_first_tail_x15_r0_body.s563 PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S562 PRE_first_tail_x15_r0_body.S563 PRE_first_tail_x15_r0_body.S564
    PRE_first_tail_x15_r0_body.ws57 PRE_first_tail_x15_r0_body.cws57 PRE_first_tail_x15_r0_body.nr57 PRE_first_tail_x15_r0_body.pl57 PRE_first_tail_x15_r0_body.cl57 2720533 2535 PRE_first_tail_x15_r0_body.kd57 PRE_first_tail_x15_r0_body.kappa57 PRE_first_tail_x15_r0_body.P57
    ⟨19337, 16424, 2720168, 2526⟩ ⟨19341, 16430, 2720183, 2535⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap57
  clean := bodyClean57
  cfix := PRE_first_tail_x15_r0_body.cfix57
  zpl := PRE_first_tail_x15_r0_body.zpl57
  zplnd := PRE_first_tail_x15_r0_body.zplnd57
  zn1 := PRE_first_tail_x15_r0_body.zn157
  zfirst := PRE_first_tail_x15_r0_body.zfirst57
  zscn := PRE_first_tail_x15_r0_body.zscn57
  zsmn := PRE_first_tail_x15_r0_body.zsmn57
  zgrow := PRE_first_tail_x15_r0_body.zgrow57
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab57
  zfresh := PRE_first_tail_x15_r0_body.zfresh57
  zcnd := PRE_first_tail_x15_r0_body.zcnd57
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi57
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt57
  zgP := PRE_first_tail_x15_r0_body.zg57_2665
  zkP := PRE_first_tail_x15_r0_body.zk57_2665
  zmP := PRE_first_tail_x15_r0_body.zm57_2665
  zgC := PRE_first_tail_x15_r0_body.zg57_2673467
  zkC := PRE_first_tail_x15_r0_body.zk57_2673467
  zmC := PRE_first_tail_x15_r0_body.zm57_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw57_2673472
  zwV := PRE_first_tail_x15_r0_body.zw57_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap57
  zclbd := PRE_first_tail_x15_r0_body.zclbd57
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap57 PRE_first_tail_x15_r0_body.stFoot57 PRE_first_tail_x15_r0_body.iso57 PRE_first_tail_x15_r0_body.zwr57
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP57
  csupp := PRE_first_tail_x15_r0_body.csupp57
  cbound := PRE_first_tail_x15_r0_body.cbound57
  zimg := PRE_first_tail_x15_r0_body.zimg57
  zctl := PRE_first_tail_x15_r0_body.zctl57
  zstack := PRE_first_tail_x15_r0_body.zstack57
  zjobs := PRE_first_tail_x15_r0_body.zjobs57
  zstores := PRE_first_tail_x15_r0_body.zstores57
  zroots := PRE_first_tail_x15_r0_body.zroots57
  znC := PRE_first_tail_x15_r0_body.znC57
  ctab := PRE_first_tail_x15_r0_body.ctab57
  zbin := PRE_first_tail_x15_r0_body.zbin57
  cbridge := PRE_first_tail_x15_r0_body.cbridge57
  sbridge := bodyBridge57
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj57
  cshiftR := fun h hNL => bodyCshift57 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN57
  raised := PRE_first_tail_x15_r0_body.raised57
  cbigs := PRE_first_tail_x15_r0_body.cbigs57
  cjcl := PRE_first_tail_x15_r0_body.cjcl57
  xnLe := Nat.le_of_ble_eq_true bodyXn57
  loLe := Nat.le_of_ble_eq_true bodyLo57
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB57
  cntM := bodyCntM57
  hiLe := Nat.le_of_ble_eq_true bodyHi57
  nhiLe := Nat.le_of_ble_eq_true bodyNhi57
  jsHeap := bodyJs57
  jsRoots := bodyJsRoots57
  jsNative := bodyJsNative57
  framesEmpty := bodyFramesEmpty57
  trailOld := by decide
  lowVars := bodyLow57

def bodyQs57 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs57 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr57.map fun r => nth? PRE_first_tail_x15_r0_body.st57.S3.tab r
kernel_rfl bodyResChk57 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs57 bodyQs57) = true
kernel_rfl bodyLq57 : bodyQs57.length = PRE_first_tail_x15_r0_body.cws57.length
kernel_rfl bodyNrLo57 : PRE_first_tail_x15_r0_body.nr57.all (Nat.ble PRE_first_tail_x15_r0_body.S562.tab.length) = true
kernel_rfl bodySub57 : (Oracles.PRE_first_tail_x15_r0_body.map_site57.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost57 : postSubB bodyM PRE_first_tail_x15_r0_body.ws57 PRE_first_tail_x15_r0_body.cws57 bodyQs57 = true
kernel_rfl bodyDrop57 : Nat.ble (23040 + (PRE_first_tail_x15_r0_body.s563.next - PRE_first_tail_x15_r0_body.s564.next)) 23390 = true
kernel_rfl bodyDropH57 : Nat.ble (404 + ((mlxOf PRE_first_tail_x15_r0_body.s563.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s564.ffi).next)) 406 = true
kernel_rfl bodyDropN57 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s563.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s564.ffi).nnext)) 0 = true
kernel_rfl bodyDv57 : bodyΘ.1.take 315 = bodyΘ.1.take 306 ++ PRE_first_tail_x15_r0_body.cws57
kernel_rfl bodyDe57 : bodyΘ.2.take 315 = bodyΘ.2.take 306 ++ PRE_first_tail_x15_r0_body.nr57.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st57.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 306) (bodyΘ.2.take 306)))
kernel_rfl bodyDl57 : (bodyΘ.1.take 306).length = (bodyΘ.2.take 306).length
kernel_rfl bodyDold57 : (bodyΘ.1.take 306).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws57).isNone && !PRE_first_tail_x15_r0_body.ws57.contains v) = true
kernel_rfl bodyDfree57 : (bodyΘ.2.take 315).all (fun e => (PRE_first_tail_x15_r0_body.cws57 ++ PRE_first_tail_x15_r0_body.ws57).all fun w => e.noVar w) = true

theorem bodyStep57 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23040, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s562 PRE_first_tail_x15_r0_body.S562)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23390, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.S564) (3452 + 1) :=
  bodySite bodyFacts57.cfix bodyFacts57.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st57.S3.tab) (Es := bodyEs57) (qs := bodyQs57)
    (ok := PRE_first_tail_x15_r0_body.st57.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site57 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts57
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site57 r hr) hi (MapOk.sub hm (sub_of_all bodySub57)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk57 r hr) hi hm ho hq)
    bodyLq57 rfl bodyNrLo57 (postSub_sound bodyPost57)
    (Nat.le_of_ble_eq_true bodyDrop57) (by decide) (Nat.le_of_ble_eq_true bodyDropH57) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN57) (by decide)
    bodyDv57 bodyDe57 bodyDl57 bodyDold57 bodyDfree57 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
