import host.sim.compose.a4b.vw15.VWBodyJ114
import host.sim.compose.a4b.vw15.VWBodySite114
import host.sim.compose.a4b.vw15.VWBodyOracles_28
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B26
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift114 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1109.tab.length PRE_first_tail_x15_r0_body.s1109.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P114.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P114 4976 PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.s1111.ffi PRE_first_tail_x15_r0_body.s1110.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_114
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_114
  have hcl : SSt (· < 4976) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1111.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1109.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_114] <;> decide) PRE_first_tail_x15_r0_body.cnodesK114 PRE_first_tail_x15_r0_body.cobjsK114
      PRE_first_tail_x15_r0_body.citemsK114 PRE_first_tail_x15_r0_body.cbd114 PRE_first_tail_x15_r0_body.csst114
  exact PRE_first_tail_x15_r0_body.cshift114 bodyNcl114 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_114] at this; exact this)


kernel_rfl bodyFramesEmpty114 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1110 a).isEmpty) = true
kernel_rfl bodyJsRoots114 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1109.next) PRE_first_tail_x15_r0_body.s1111.trace PRE_first_tail_x15_r0_body.s1111 = true
kernel_rfl bodyJsNative114 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1111.ffi) = true
kernel_rfl bodyLow114 : (PRE_first_tail_x15_r0_body.cws114 ++ PRE_first_tail_x15_r0_body.ws114).all (Nat.ble 9) = true
kernel_rfl bodyCntM114 : countersOkB PRE_first_tail_x15_r0_body.s1109 PRE_first_tail_x15_r0_body.s1110 = true
kernel_rfl bodyHi114 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1111.ffi).next setupP.E = true
kernel_rfl bodyNhi114 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1111.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge114 : bridgeOf PRE_first_tail_x15_r0_body.s1110.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1109.ffi
kernel_rfl bodyNN114 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1109.ffi).nnext PRE_first_tail_x15_r0_body.P114.NL = true
kernel_rfl bodyXn114 : Nat.ble (⟨20457, 17564, 2764729, 4976⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1111.ffi).next = true
kernel_rfl bodyLo114 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1111.ffi).next = true
theorem bodyFacts114 : BodySiteFacts PRE_first_tail_x15_r0_body.s1109 PRE_first_tail_x15_r0_body.s1110 PRE_first_tail_x15_r0_body.s1111 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1109 PRE_first_tail_x15_r0_body.S1110 PRE_first_tail_x15_r0_body.S1111
    PRE_first_tail_x15_r0_body.ws114 PRE_first_tail_x15_r0_body.cws114 PRE_first_tail_x15_r0_body.nr114 PRE_first_tail_x15_r0_body.pl114 PRE_first_tail_x15_r0_body.cl114 2765878 4976 PRE_first_tail_x15_r0_body.kd114 PRE_first_tail_x15_r0_body.kappa114 PRE_first_tail_x15_r0_body.P114
    ⟨20454, 17537, 2764723, 4958⟩ ⟨20457, 17564, 2764729, 4976⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap114
  clean := bodyClean114
  cfix := PRE_first_tail_x15_r0_body.cfix114
  zpl := PRE_first_tail_x15_r0_body.zpl114
  zplnd := PRE_first_tail_x15_r0_body.zplnd114
  zn1 := PRE_first_tail_x15_r0_body.zn1114
  zfirst := PRE_first_tail_x15_r0_body.zfirst114
  zscn := PRE_first_tail_x15_r0_body.zscn114
  zsmn := PRE_first_tail_x15_r0_body.zsmn114
  zgrow := PRE_first_tail_x15_r0_body.zgrow114
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab114
  zfresh := PRE_first_tail_x15_r0_body.zfresh114
  zcnd := PRE_first_tail_x15_r0_body.zcnd114
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi114
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt114
  zgP := PRE_first_tail_x15_r0_body.zg114_2665
  zkP := PRE_first_tail_x15_r0_body.zk114_2665
  zmP := PRE_first_tail_x15_r0_body.zm114_2665
  zgC := PRE_first_tail_x15_r0_body.zg114_2673467
  zkC := PRE_first_tail_x15_r0_body.zk114_2673467
  zmC := PRE_first_tail_x15_r0_body.zm114_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw114_2673472
  zwV := PRE_first_tail_x15_r0_body.zw114_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap114
  zclbd := PRE_first_tail_x15_r0_body.zclbd114
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap114 PRE_first_tail_x15_r0_body.stFoot114 PRE_first_tail_x15_r0_body.iso114 PRE_first_tail_x15_r0_body.zwr114
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP114
  csupp := PRE_first_tail_x15_r0_body.csupp114
  cbound := PRE_first_tail_x15_r0_body.cbound114
  zimg := PRE_first_tail_x15_r0_body.zimg114
  zctl := PRE_first_tail_x15_r0_body.zctl114
  zstack := PRE_first_tail_x15_r0_body.zstack114
  zjobs := PRE_first_tail_x15_r0_body.zjobs114
  zstores := PRE_first_tail_x15_r0_body.zstores114
  zroots := PRE_first_tail_x15_r0_body.zroots114
  znC := PRE_first_tail_x15_r0_body.znC114
  ctab := PRE_first_tail_x15_r0_body.ctab114
  zbin := PRE_first_tail_x15_r0_body.zbin114
  cbridge := PRE_first_tail_x15_r0_body.cbridge114
  sbridge := bodyBridge114
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj114
  cshiftR := fun h hNL => bodyCshift114 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN114
  raised := PRE_first_tail_x15_r0_body.raised114
  cbigs := PRE_first_tail_x15_r0_body.cbigs114
  cjcl := PRE_first_tail_x15_r0_body.cjcl114
  xnLe := Nat.le_of_ble_eq_true bodyXn114
  loLe := Nat.le_of_ble_eq_true bodyLo114
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB114
  cntM := bodyCntM114
  hiLe := Nat.le_of_ble_eq_true bodyHi114
  nhiLe := Nat.le_of_ble_eq_true bodyNhi114
  jsHeap := bodyJs114
  jsRoots := bodyJsRoots114
  jsNative := bodyJsNative114
  framesEmpty := bodyFramesEmpty114
  trailOld := by decide
  lowVars := bodyLow114

def bodyQs114 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs114 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr114.map fun r => nth? PRE_first_tail_x15_r0_body.st114.S5.tab r
kernel_rfl bodyResChk114 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs114 bodyQs114) = true
kernel_rfl bodyLq114 : bodyQs114.length = PRE_first_tail_x15_r0_body.cws114.length
kernel_rfl bodyNrLo114 : PRE_first_tail_x15_r0_body.nr114.all (Nat.ble PRE_first_tail_x15_r0_body.S1109.tab.length) = true
kernel_rfl bodySub114 : (Oracles.PRE_first_tail_x15_r0_body.map_site114.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost114 : postSubB bodyM PRE_first_tail_x15_r0_body.ws114 PRE_first_tail_x15_r0_body.cws114 bodyQs114 = true
kernel_rfl bodyDrop114 : Nat.ble (41140 + (PRE_first_tail_x15_r0_body.s1110.next - PRE_first_tail_x15_r0_body.s1111.next)) 42289 = true
kernel_rfl bodyDropH114 : Nat.ble (764 + ((mlxOf PRE_first_tail_x15_r0_body.s1110.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1111.ffi).next)) 789 = true
kernel_rfl bodyDropN114 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1110.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1111.ffi).nnext)) 0 = true
kernel_rfl bodyDv114 : bodyΘ.1.take 621 = bodyΘ.1.take 603 ++ PRE_first_tail_x15_r0_body.cws114
kernel_rfl bodyDe114 : bodyΘ.2.take 621 = bodyΘ.2.take 603 ++ PRE_first_tail_x15_r0_body.nr114.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st114.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 603) (bodyΘ.2.take 603)))
kernel_rfl bodyDl114 : (bodyΘ.1.take 603).length = (bodyΘ.2.take 603).length
kernel_rfl bodyDold114 : (bodyΘ.1.take 603).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws114).isNone && !PRE_first_tail_x15_r0_body.ws114.contains v) = true
kernel_rfl bodyDfree114 : (bodyΘ.2.take 621).all (fun e => (PRE_first_tail_x15_r0_body.cws114 ++ PRE_first_tail_x15_r0_body.ws114).all fun w => e.noVar w) = true

theorem bodyStep114 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨41140, 764, 0, 603⟩ bodyM PRE_first_tail_x15_r0_body.s1109 PRE_first_tail_x15_r0_body.S1109)
      (bodyCut NB T tk π i x0 bodyΘ ⟨42289, 789, 0, 621⟩ bodyM PRE_first_tail_x15_r0_body.s1111 PRE_first_tail_x15_r0_body.S1111) (11334 + 1) :=
  bodySite bodyFacts114.cfix bodyFacts114.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st114.S5.tab) (Es := bodyEs114) (qs := bodyQs114)
    (ok := PRE_first_tail_x15_r0_body.st114.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site114 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts114
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site114 r hr) hi (MapOk.sub hm (sub_of_all bodySub114)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk114 r hr) hi hm ho hq)
    bodyLq114 rfl bodyNrLo114 (postSub_sound bodyPost114)
    (Nat.le_of_ble_eq_true bodyDrop114) (by decide) (Nat.le_of_ble_eq_true bodyDropH114) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN114) (by decide)
    bodyDv114 bodyDe114 bodyDl114 bodyDold114 bodyDfree114 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
