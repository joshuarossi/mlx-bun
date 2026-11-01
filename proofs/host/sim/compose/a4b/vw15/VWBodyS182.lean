import host.sim.compose.a4b.vw15.VWBodyJ182
import host.sim.compose.a4b.vw15.VWBodySite182
import host.sim.compose.a4b.vw15.VWBodyOracles_45
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B32
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift182 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1753.tab.length PRE_first_tail_x15_r0_body.s1753.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P182.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P182 7834 PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.s1755.ffi PRE_first_tail_x15_r0_body.s1754.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_182
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_182
  have hcl : SSt (· < 7834) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1755.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1753.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_182] <;> decide) PRE_first_tail_x15_r0_body.cnodesK182 PRE_first_tail_x15_r0_body.cobjsK182
      PRE_first_tail_x15_r0_body.citemsK182 PRE_first_tail_x15_r0_body.cbd182 PRE_first_tail_x15_r0_body.csst182
  exact PRE_first_tail_x15_r0_body.cshift182 bodyNcl182 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_182] at this; exact this)


kernel_rfl bodyFramesEmpty182 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1754 a).isEmpty) = true
kernel_rfl bodyJsRoots182 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1753.next) PRE_first_tail_x15_r0_body.s1755.trace PRE_first_tail_x15_r0_body.s1755 = true
kernel_rfl bodyJsNative182 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1755.ffi) = true
kernel_rfl bodyLow182 : (PRE_first_tail_x15_r0_body.cws182 ++ PRE_first_tail_x15_r0_body.ws182).all (Nat.ble 9) = true
kernel_rfl bodyCntM182 : countersOkB PRE_first_tail_x15_r0_body.s1753 PRE_first_tail_x15_r0_body.s1754 = true
kernel_rfl bodyHi182 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1755.ffi).next setupP.E = true
kernel_rfl bodyNhi182 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1755.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge182 : bridgeOf PRE_first_tail_x15_r0_body.s1754.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1753.ffi
kernel_rfl bodyNN182 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1753.ffi).nnext PRE_first_tail_x15_r0_body.P182.NL = true
kernel_rfl bodyXn182 : Nat.ble (⟨21779, 18877, 2817512, 7834⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1755.ffi).next = true
kernel_rfl bodyLo182 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1755.ffi).next = true
theorem bodyFacts182 : BodySiteFacts PRE_first_tail_x15_r0_body.s1753 PRE_first_tail_x15_r0_body.s1754 PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1753 PRE_first_tail_x15_r0_body.S1754 PRE_first_tail_x15_r0_body.S1755
    PRE_first_tail_x15_r0_body.ws182 PRE_first_tail_x15_r0_body.cws182 PRE_first_tail_x15_r0_body.nr182 PRE_first_tail_x15_r0_body.pl182 PRE_first_tail_x15_r0_body.cl182 2817531 7834 PRE_first_tail_x15_r0_body.kd182 PRE_first_tail_x15_r0_body.kappa182 PRE_first_tail_x15_r0_body.P182
    ⟨21779, 18877, 2817511, 7834⟩ ⟨21779, 18877, 2817512, 7834⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap182
  clean := bodyClean182
  cfix := PRE_first_tail_x15_r0_body.cfix182
  zpl := PRE_first_tail_x15_r0_body.zpl182
  zplnd := PRE_first_tail_x15_r0_body.zplnd182
  zn1 := PRE_first_tail_x15_r0_body.zn1182
  zfirst := PRE_first_tail_x15_r0_body.zfirst182
  zscn := PRE_first_tail_x15_r0_body.zscn182
  zsmn := PRE_first_tail_x15_r0_body.zsmn182
  zgrow := PRE_first_tail_x15_r0_body.zgrow182
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab182
  zfresh := PRE_first_tail_x15_r0_body.zfresh182
  zcnd := PRE_first_tail_x15_r0_body.zcnd182
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi182
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt182
  zgP := PRE_first_tail_x15_r0_body.zg182_2665
  zkP := PRE_first_tail_x15_r0_body.zk182_2665
  zmP := PRE_first_tail_x15_r0_body.zm182_2665
  zgC := PRE_first_tail_x15_r0_body.zg182_2673467
  zkC := PRE_first_tail_x15_r0_body.zk182_2673467
  zmC := PRE_first_tail_x15_r0_body.zm182_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw182_2673472
  zwV := PRE_first_tail_x15_r0_body.zw182_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap182
  zclbd := PRE_first_tail_x15_r0_body.zclbd182
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap182 PRE_first_tail_x15_r0_body.stFoot182 PRE_first_tail_x15_r0_body.iso182 PRE_first_tail_x15_r0_body.zwr182
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP182
  csupp := PRE_first_tail_x15_r0_body.csupp182
  cbound := PRE_first_tail_x15_r0_body.cbound182
  zimg := PRE_first_tail_x15_r0_body.zimg182
  zctl := PRE_first_tail_x15_r0_body.zctl182
  zstack := PRE_first_tail_x15_r0_body.zstack182
  zjobs := PRE_first_tail_x15_r0_body.zjobs182
  zstores := PRE_first_tail_x15_r0_body.zstores182
  zroots := PRE_first_tail_x15_r0_body.zroots182
  znC := PRE_first_tail_x15_r0_body.znC182
  ctab := PRE_first_tail_x15_r0_body.ctab182
  zbin := PRE_first_tail_x15_r0_body.zbin182
  cbridge := PRE_first_tail_x15_r0_body.cbridge182
  sbridge := bodyBridge182
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj182
  cshiftR := fun h hNL => bodyCshift182 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN182
  raised := PRE_first_tail_x15_r0_body.raised182
  cbigs := PRE_first_tail_x15_r0_body.cbigs182
  cjcl := PRE_first_tail_x15_r0_body.cjcl182
  xnLe := Nat.le_of_ble_eq_true bodyXn182
  loLe := Nat.le_of_ble_eq_true bodyLo182
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB182
  cntM := bodyCntM182
  hiLe := Nat.le_of_ble_eq_true bodyHi182
  nhiLe := Nat.le_of_ble_eq_true bodyNhi182
  jsHeap := bodyJs182
  jsRoots := bodyJsRoots182
  jsNative := bodyJsNative182
  framesEmpty := bodyFramesEmpty182
  trailOld := by decide
  lowVars := bodyLow182

def bodyQs182 : List (Option Q) := []
noncomputable def bodyEs182 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr182.map fun r => nth? PRE_first_tail_x15_r0_body.st182.S2.tab r
kernel_rfl bodyResChk182 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs182 bodyQs182) = true
kernel_rfl bodyLq182 : bodyQs182.length = PRE_first_tail_x15_r0_body.cws182.length
kernel_rfl bodyNrLo182 : PRE_first_tail_x15_r0_body.nr182.all (Nat.ble PRE_first_tail_x15_r0_body.S1753.tab.length) = true
kernel_rfl bodySub182 : (Oracles.PRE_first_tail_x15_r0_body.map_site182.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost182 : postSubB bodyM PRE_first_tail_x15_r0_body.ws182 PRE_first_tail_x15_r0_body.cws182 bodyQs182 = true
kernel_rfl bodyDrop182 : Nat.ble (63138 + (PRE_first_tail_x15_r0_body.s1754.next - PRE_first_tail_x15_r0_body.s1755.next)) 63157 = true
kernel_rfl bodyDropH182 : Nat.ble (1201 + ((mlxOf PRE_first_tail_x15_r0_body.s1754.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1755.ffi).next)) 1201 = true
kernel_rfl bodyDropN182 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1754.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1755.ffi).nnext)) 0 = true
kernel_rfl bodyDv182 : bodyΘ.1.take 963 = bodyΘ.1.take 963 ++ PRE_first_tail_x15_r0_body.cws182
kernel_rfl bodyDe182 : bodyΘ.2.take 963 = bodyΘ.2.take 963 ++ PRE_first_tail_x15_r0_body.nr182.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st182.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 963) (bodyΘ.2.take 963)))
kernel_rfl bodyDl182 : (bodyΘ.1.take 963).length = (bodyΘ.2.take 963).length
kernel_rfl bodyDold182 : (bodyΘ.1.take 963).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws182).isNone && !PRE_first_tail_x15_r0_body.ws182.contains v) = true
kernel_rfl bodyDfree182 : (bodyΘ.2.take 963).all (fun e => (PRE_first_tail_x15_r0_body.cws182 ++ PRE_first_tail_x15_r0_body.ws182).all fun w => e.noVar w) = true

theorem bodyStep182 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63138, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1753 PRE_first_tail_x15_r0_body.S1753)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63157, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.S1755) (206 + 1) :=
  bodySite bodyFacts182.cfix bodyFacts182.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st182.S2.tab) (Es := bodyEs182) (qs := bodyQs182)
    (ok := PRE_first_tail_x15_r0_body.st182.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site182 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts182
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site182 r hr) hi (MapOk.sub hm (sub_of_all bodySub182)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk182 r hr) hi hm ho hq)
    bodyLq182 rfl bodyNrLo182 (postSub_sound bodyPost182)
    (Nat.le_of_ble_eq_true bodyDrop182) (by decide) (Nat.le_of_ble_eq_true bodyDropH182) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN182) (by decide)
    bodyDv182 bodyDe182 bodyDl182 bodyDold182 bodyDfree182 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
