import host.sim.compose.a4b.vw15.VWBodyJ150
import host.sim.compose.a4b.vw15.VWBodySite150
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

theorem bodyCshift150 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1454.tab.length PRE_first_tail_x15_r0_body.s1454.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P150.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P150 6515 PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.s1456.ffi PRE_first_tail_x15_r0_body.s1455.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_150
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_150
  have hcl : SSt (· < 6515) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1456.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1454.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_150] <;> decide) PRE_first_tail_x15_r0_body.cnodesK150 PRE_first_tail_x15_r0_body.cobjsK150
      PRE_first_tail_x15_r0_body.citemsK150 PRE_first_tail_x15_r0_body.cbd150 PRE_first_tail_x15_r0_body.csst150
  exact PRE_first_tail_x15_r0_body.cshift150 bodyNcl150 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_150] at this; exact this)


kernel_rfl bodyFramesEmpty150 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1455 a).isEmpty) = true
kernel_rfl bodyJsRoots150 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1454.next) PRE_first_tail_x15_r0_body.s1456.trace PRE_first_tail_x15_r0_body.s1456 = true
kernel_rfl bodyJsNative150 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1456.ffi) = true
kernel_rfl bodyLow150 : (PRE_first_tail_x15_r0_body.cws150 ++ PRE_first_tail_x15_r0_body.ws150).all (Nat.ble 9) = true
kernel_rfl bodyCntM150 : countersOkB PRE_first_tail_x15_r0_body.s1454 PRE_first_tail_x15_r0_body.s1455 = true
kernel_rfl bodyHi150 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1456.ffi).next setupP.E = true
kernel_rfl bodyNhi150 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1456.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge150 : bridgeOf PRE_first_tail_x15_r0_body.s1455.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1454.ffi
kernel_rfl bodyNN150 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1454.ffi).nnext PRE_first_tail_x15_r0_body.P150.NL = true
kernel_rfl bodyXn150 : Nat.ble (⟨21165, 18275, 2792985, 6515⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1456.ffi).next = true
kernel_rfl bodyLo150 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1456.ffi).next = true
theorem bodyFacts150 : BodySiteFacts PRE_first_tail_x15_r0_body.s1454 PRE_first_tail_x15_r0_body.s1455 PRE_first_tail_x15_r0_body.s1456 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1454 PRE_first_tail_x15_r0_body.S1455 PRE_first_tail_x15_r0_body.S1456
    PRE_first_tail_x15_r0_body.ws150 PRE_first_tail_x15_r0_body.cws150 PRE_first_tail_x15_r0_body.nr150 PRE_first_tail_x15_r0_body.pl150 PRE_first_tail_x15_r0_body.cl150 2794134 6515 PRE_first_tail_x15_r0_body.kd150 PRE_first_tail_x15_r0_body.kappa150 PRE_first_tail_x15_r0_body.P150
    ⟨21162, 18248, 2792979, 6497⟩ ⟨21165, 18275, 2792985, 6515⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap150
  clean := bodyClean150
  cfix := PRE_first_tail_x15_r0_body.cfix150
  zpl := PRE_first_tail_x15_r0_body.zpl150
  zplnd := PRE_first_tail_x15_r0_body.zplnd150
  zn1 := PRE_first_tail_x15_r0_body.zn1150
  zfirst := PRE_first_tail_x15_r0_body.zfirst150
  zscn := PRE_first_tail_x15_r0_body.zscn150
  zsmn := PRE_first_tail_x15_r0_body.zsmn150
  zgrow := PRE_first_tail_x15_r0_body.zgrow150
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab150
  zfresh := PRE_first_tail_x15_r0_body.zfresh150
  zcnd := PRE_first_tail_x15_r0_body.zcnd150
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi150
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt150
  zgP := PRE_first_tail_x15_r0_body.zg150_2665
  zkP := PRE_first_tail_x15_r0_body.zk150_2665
  zmP := PRE_first_tail_x15_r0_body.zm150_2665
  zgC := PRE_first_tail_x15_r0_body.zg150_2673467
  zkC := PRE_first_tail_x15_r0_body.zk150_2673467
  zmC := PRE_first_tail_x15_r0_body.zm150_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw150_2673472
  zwV := PRE_first_tail_x15_r0_body.zw150_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap150
  zclbd := PRE_first_tail_x15_r0_body.zclbd150
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap150 PRE_first_tail_x15_r0_body.stFoot150 PRE_first_tail_x15_r0_body.iso150 PRE_first_tail_x15_r0_body.zwr150
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP150
  csupp := PRE_first_tail_x15_r0_body.csupp150
  cbound := PRE_first_tail_x15_r0_body.cbound150
  zimg := PRE_first_tail_x15_r0_body.zimg150
  zctl := PRE_first_tail_x15_r0_body.zctl150
  zstack := PRE_first_tail_x15_r0_body.zstack150
  zjobs := PRE_first_tail_x15_r0_body.zjobs150
  zstores := PRE_first_tail_x15_r0_body.zstores150
  zroots := PRE_first_tail_x15_r0_body.zroots150
  znC := PRE_first_tail_x15_r0_body.znC150
  ctab := PRE_first_tail_x15_r0_body.ctab150
  zbin := PRE_first_tail_x15_r0_body.zbin150
  cbridge := PRE_first_tail_x15_r0_body.cbridge150
  sbridge := bodyBridge150
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj150
  cshiftR := fun h hNL => bodyCshift150 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN150
  raised := PRE_first_tail_x15_r0_body.raised150
  cbigs := PRE_first_tail_x15_r0_body.cbigs150
  cjcl := PRE_first_tail_x15_r0_body.cjcl150
  xnLe := Nat.le_of_ble_eq_true bodyXn150
  loLe := Nat.le_of_ble_eq_true bodyLo150
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB150
  cntM := bodyCntM150
  hiLe := Nat.le_of_ble_eq_true bodyHi150
  nhiLe := Nat.le_of_ble_eq_true bodyNhi150
  jsHeap := bodyJs150
  jsRoots := bodyJsRoots150
  jsNative := bodyJsNative150
  framesEmpty := bodyFramesEmpty150
  trailOld := by decide
  lowVars := bodyLow150

def bodyQs150 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs150 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr150.map fun r => nth? PRE_first_tail_x15_r0_body.st150.S5.tab r
kernel_rfl bodyResChk150 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs150 bodyQs150) = true
kernel_rfl bodyLq150 : bodyQs150.length = PRE_first_tail_x15_r0_body.cws150.length
kernel_rfl bodyNrLo150 : PRE_first_tail_x15_r0_body.nr150.all (Nat.ble PRE_first_tail_x15_r0_body.S1454.tab.length) = true
kernel_rfl bodySub150 : (Oracles.PRE_first_tail_x15_r0_body.map_site150.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost150 : postSubB bodyM PRE_first_tail_x15_r0_body.ws150 PRE_first_tail_x15_r0_body.cws150 bodyQs150 = true
kernel_rfl bodyDrop150 : Nat.ble (52720 + (PRE_first_tail_x15_r0_body.s1455.next - PRE_first_tail_x15_r0_body.s1456.next)) 53869 = true
kernel_rfl bodyDropH150 : Nat.ble (995 + ((mlxOf PRE_first_tail_x15_r0_body.s1455.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1456.ffi).next)) 1020 = true
kernel_rfl bodyDropN150 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1455.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1456.ffi).nnext)) 0 = true
kernel_rfl bodyDv150 : bodyΘ.1.take 810 = bodyΘ.1.take 792 ++ PRE_first_tail_x15_r0_body.cws150
kernel_rfl bodyDe150 : bodyΘ.2.take 810 = bodyΘ.2.take 792 ++ PRE_first_tail_x15_r0_body.nr150.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st150.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 792) (bodyΘ.2.take 792)))
kernel_rfl bodyDl150 : (bodyΘ.1.take 792).length = (bodyΘ.2.take 792).length
kernel_rfl bodyDold150 : (bodyΘ.1.take 792).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws150).isNone && !PRE_first_tail_x15_r0_body.ws150.contains v) = true
kernel_rfl bodyDfree150 : (bodyΘ.2.take 810).all (fun e => (PRE_first_tail_x15_r0_body.cws150 ++ PRE_first_tail_x15_r0_body.ws150).all fun w => e.noVar w) = true

theorem bodyStep150 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨52720, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1454 PRE_first_tail_x15_r0_body.S1454)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53869, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1456 PRE_first_tail_x15_r0_body.S1456) (11334 + 1) :=
  bodySite bodyFacts150.cfix bodyFacts150.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st150.S5.tab) (Es := bodyEs150) (qs := bodyQs150)
    (ok := PRE_first_tail_x15_r0_body.st150.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site150 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts150
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site150 r hr) hi (MapOk.sub hm (sub_of_all bodySub150)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk150 r hr) hi hm ho hq)
    bodyLq150 rfl bodyNrLo150 (postSub_sound bodyPost150)
    (Nat.le_of_ble_eq_true bodyDrop150) (by decide) (Nat.le_of_ble_eq_true bodyDropH150) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN150) (by decide)
    bodyDv150 bodyDe150 bodyDl150 bodyDold150 bodyDfree150 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
