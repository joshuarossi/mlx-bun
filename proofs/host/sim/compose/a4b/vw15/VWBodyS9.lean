import host.sim.compose.a4b.vw15.VWBodyJ9
import host.sim.compose.a4b.vw15.VWBodySite9
import host.sim.compose.a4b.vw15.VWBodyOracles_2
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B16
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift9 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S102.tab.length PRE_first_tail_x15_r0_body.s102.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P9.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P9 483 PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.s104.ffi PRE_first_tail_x15_r0_body.s103.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_9
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_9
  have hcl : SSt (· < 483) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s104.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S102.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_9] <;> decide) PRE_first_tail_x15_r0_body.cnodesK9 PRE_first_tail_x15_r0_body.cobjsK9
      PRE_first_tail_x15_r0_body.citemsK9 PRE_first_tail_x15_r0_body.cbd9 PRE_first_tail_x15_r0_body.csst9
  exact PRE_first_tail_x15_r0_body.cshift9 bodyNcl9 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_9] at this; exact this)


kernel_rfl bodyFramesEmpty9 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s103 a).isEmpty) = true
kernel_rfl bodyJsRoots9 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s102.next) PRE_first_tail_x15_r0_body.s104.trace PRE_first_tail_x15_r0_body.s104 = true
kernel_rfl bodyJsNative9 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s104.ffi) = true
kernel_rfl bodyLow9 : (PRE_first_tail_x15_r0_body.cws9 ++ PRE_first_tail_x15_r0_body.ws9).all (Nat.ble 9) = true
kernel_rfl bodyCntM9 : countersOkB PRE_first_tail_x15_r0_body.s102 PRE_first_tail_x15_r0_body.s103 = true
kernel_rfl bodyHi9 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s104.ffi).next setupP.E = true
kernel_rfl bodyNhi9 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s104.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge9 : bridgeOf PRE_first_tail_x15_r0_body.s103.ffi = bridgeOf PRE_first_tail_x15_r0_body.s102.ffi
kernel_rfl bodyNN9 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s102.ffi).nnext PRE_first_tail_x15_r0_body.P9.NL = true
kernel_rfl bodyXn9 : Nat.ble (⟨18397, 15482, 2682509, 483⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s104.ffi).next = true
kernel_rfl bodyLo9 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s104.ffi).next = true
theorem bodyFacts9 : BodySiteFacts PRE_first_tail_x15_r0_body.s102 PRE_first_tail_x15_r0_body.s103 PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S102 PRE_first_tail_x15_r0_body.S103 PRE_first_tail_x15_r0_body.S104
    PRE_first_tail_x15_r0_body.ws9 PRE_first_tail_x15_r0_body.cws9 PRE_first_tail_x15_r0_body.nr9 PRE_first_tail_x15_r0_body.pl9 PRE_first_tail_x15_r0_body.cl9 2682859 483 PRE_first_tail_x15_r0_body.kd9 PRE_first_tail_x15_r0_body.kappa9 PRE_first_tail_x15_r0_body.P9
    ⟨18393, 15476, 2682494, 474⟩ ⟨18397, 15482, 2682509, 483⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap9
  clean := bodyClean9
  cfix := PRE_first_tail_x15_r0_body.cfix9
  zpl := PRE_first_tail_x15_r0_body.zpl9
  zplnd := PRE_first_tail_x15_r0_body.zplnd9
  zn1 := PRE_first_tail_x15_r0_body.zn19
  zfirst := PRE_first_tail_x15_r0_body.zfirst9
  zscn := PRE_first_tail_x15_r0_body.zscn9
  zsmn := PRE_first_tail_x15_r0_body.zsmn9
  zgrow := PRE_first_tail_x15_r0_body.zgrow9
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab9
  zfresh := PRE_first_tail_x15_r0_body.zfresh9
  zcnd := PRE_first_tail_x15_r0_body.zcnd9
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi9
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt9
  zgP := PRE_first_tail_x15_r0_body.zg9_2665
  zkP := PRE_first_tail_x15_r0_body.zk9_2665
  zmP := PRE_first_tail_x15_r0_body.zm9_2665
  zgC := PRE_first_tail_x15_r0_body.zg9_2673467
  zkC := PRE_first_tail_x15_r0_body.zk9_2673467
  zmC := PRE_first_tail_x15_r0_body.zm9_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw9_2673472
  zwV := PRE_first_tail_x15_r0_body.zw9_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap9
  zclbd := PRE_first_tail_x15_r0_body.zclbd9
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap9 PRE_first_tail_x15_r0_body.stFoot9 PRE_first_tail_x15_r0_body.iso9 PRE_first_tail_x15_r0_body.zwr9
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP9
  csupp := PRE_first_tail_x15_r0_body.csupp9
  cbound := PRE_first_tail_x15_r0_body.cbound9
  zimg := PRE_first_tail_x15_r0_body.zimg9
  zctl := PRE_first_tail_x15_r0_body.zctl9
  zstack := PRE_first_tail_x15_r0_body.zstack9
  zjobs := PRE_first_tail_x15_r0_body.zjobs9
  zstores := PRE_first_tail_x15_r0_body.zstores9
  zroots := PRE_first_tail_x15_r0_body.zroots9
  znC := PRE_first_tail_x15_r0_body.znC9
  ctab := PRE_first_tail_x15_r0_body.ctab9
  zbin := PRE_first_tail_x15_r0_body.zbin9
  cbridge := PRE_first_tail_x15_r0_body.cbridge9
  sbridge := bodyBridge9
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj9
  cshiftR := fun h hNL => bodyCshift9 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN9
  raised := PRE_first_tail_x15_r0_body.raised9
  cbigs := PRE_first_tail_x15_r0_body.cbigs9
  cjcl := PRE_first_tail_x15_r0_body.cjcl9
  xnLe := Nat.le_of_ble_eq_true bodyXn9
  loLe := Nat.le_of_ble_eq_true bodyLo9
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB9
  cntM := bodyCntM9
  hiLe := Nat.le_of_ble_eq_true bodyHi9
  nhiLe := Nat.le_of_ble_eq_true bodyNhi9
  jsHeap := bodyJs9
  jsRoots := bodyJsRoots9
  jsNative := bodyJsNative9
  framesEmpty := bodyFramesEmpty9
  trailOld := by decide
  lowVars := bodyLow9

def bodyQs9 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs9 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr9.map fun r => nth? PRE_first_tail_x15_r0_body.st9.S3.tab r
kernel_rfl bodyResChk9 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs9 bodyQs9) = true
kernel_rfl bodyLq9 : bodyQs9.length = PRE_first_tail_x15_r0_body.cws9.length
kernel_rfl bodyNrLo9 : PRE_first_tail_x15_r0_body.nr9.all (Nat.ble PRE_first_tail_x15_r0_body.S102.tab.length) = true
kernel_rfl bodySub9 : (Oracles.PRE_first_tail_x15_r0_body.map_site9.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost9 : postSubB bodyM PRE_first_tail_x15_r0_body.ws9 PRE_first_tail_x15_r0_body.cws9 bodyQs9 = true
kernel_rfl bodyDrop9 : Nat.ble (7606 + (PRE_first_tail_x15_r0_body.s103.next - PRE_first_tail_x15_r0_body.s104.next)) 7956 = true
kernel_rfl bodyDropH9 : Nat.ble (96 + ((mlxOf PRE_first_tail_x15_r0_body.s103.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s104.ffi).next)) 98 = true
kernel_rfl bodyDropN9 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s103.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s104.ffi).nnext)) 0 = true
kernel_rfl bodyDv9 : bodyΘ.1.take 63 = bodyΘ.1.take 54 ++ PRE_first_tail_x15_r0_body.cws9
kernel_rfl bodyDe9 : bodyΘ.2.take 63 = bodyΘ.2.take 54 ++ PRE_first_tail_x15_r0_body.nr9.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st9.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 54) (bodyΘ.2.take 54)))
kernel_rfl bodyDl9 : (bodyΘ.1.take 54).length = (bodyΘ.2.take 54).length
kernel_rfl bodyDold9 : (bodyΘ.1.take 54).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws9).isNone && !PRE_first_tail_x15_r0_body.ws9.contains v) = true
kernel_rfl bodyDfree9 : (bodyΘ.2.take 63).all (fun e => (PRE_first_tail_x15_r0_body.cws9 ++ PRE_first_tail_x15_r0_body.ws9).all fun w => e.noVar w) = true

theorem bodyStep9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s102 PRE_first_tail_x15_r0_body.S102)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7956, 98, 0, 63⟩ bodyM PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.S104) (3452 + 1) :=
  bodySite bodyFacts9.cfix bodyFacts9.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st9.S3.tab) (Es := bodyEs9) (qs := bodyQs9)
    (ok := PRE_first_tail_x15_r0_body.st9.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site9 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts9
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site9 r hr) hi (MapOk.sub hm (sub_of_all bodySub9)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk9 r hr) hi hm ho hq)
    bodyLq9 rfl bodyNrLo9 (postSub_sound bodyPost9)
    (Nat.le_of_ble_eq_true bodyDrop9) (by decide) (Nat.le_of_ble_eq_true bodyDropH9) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN9) (by decide)
    bodyDv9 bodyDe9 bodyDl9 bodyDold9 bodyDfree9 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
