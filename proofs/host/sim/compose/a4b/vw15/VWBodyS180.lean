import host.sim.compose.a4b.vw15.VWBodyJ180
import host.sim.compose.a4b.vw15.VWBodySite180
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

theorem bodyCshift180 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1741.tab.length PRE_first_tail_x15_r0_body.s1741.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P180.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P180 7796 PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.s1743.ffi PRE_first_tail_x15_r0_body.s1742.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_180
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_180
  have hcl : SSt (· < 7796) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1741.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_180] <;> decide) PRE_first_tail_x15_r0_body.cnodesK180 PRE_first_tail_x15_r0_body.cobjsK180
      PRE_first_tail_x15_r0_body.citemsK180 PRE_first_tail_x15_r0_body.cbd180 PRE_first_tail_x15_r0_body.csst180
  exact PRE_first_tail_x15_r0_body.cshift180 bodyNcl180 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_180] at this; exact this)


kernel_rfl bodyFramesEmpty180 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1742 a).isEmpty) = true
kernel_rfl bodyJsRoots180 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1741.next) PRE_first_tail_x15_r0_body.s1743.trace PRE_first_tail_x15_r0_body.s1743 = true
kernel_rfl bodyJsNative180 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1743.ffi) = true
kernel_rfl bodyLow180 : (PRE_first_tail_x15_r0_body.cws180 ++ PRE_first_tail_x15_r0_body.ws180).all (Nat.ble 9) = true
kernel_rfl bodyCntM180 : countersOkB PRE_first_tail_x15_r0_body.s1741 PRE_first_tail_x15_r0_body.s1742 = true
kernel_rfl bodyHi180 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1743.ffi).next setupP.E = true
kernel_rfl bodyNhi180 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1743.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge180 : bridgeOf PRE_first_tail_x15_r0_body.s1742.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1741.ffi
kernel_rfl bodyNN180 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1741.ffi).nnext PRE_first_tail_x15_r0_body.P180.NL = true
kernel_rfl bodyXn180 : Nat.ble (⟨21759, 18860, 2816733, 7796⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1743.ffi).next = true
kernel_rfl bodyLo180 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1743.ffi).next = true
theorem bodyFacts180 : BodySiteFacts PRE_first_tail_x15_r0_body.s1741 PRE_first_tail_x15_r0_body.s1742 PRE_first_tail_x15_r0_body.s1743 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1741 PRE_first_tail_x15_r0_body.S1742 PRE_first_tail_x15_r0_body.S1743
    PRE_first_tail_x15_r0_body.ws180 PRE_first_tail_x15_r0_body.cws180 PRE_first_tail_x15_r0_body.nr180 PRE_first_tail_x15_r0_body.pl180 PRE_first_tail_x15_r0_body.cl180 2817882 7796 PRE_first_tail_x15_r0_body.kd180 PRE_first_tail_x15_r0_body.kappa180 PRE_first_tail_x15_r0_body.P180
    ⟨21756, 18833, 2816727, 7778⟩ ⟨21759, 18860, 2816733, 7796⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap180
  clean := bodyClean180
  cfix := PRE_first_tail_x15_r0_body.cfix180
  zpl := PRE_first_tail_x15_r0_body.zpl180
  zplnd := PRE_first_tail_x15_r0_body.zplnd180
  zn1 := PRE_first_tail_x15_r0_body.zn1180
  zfirst := PRE_first_tail_x15_r0_body.zfirst180
  zscn := PRE_first_tail_x15_r0_body.zscn180
  zsmn := PRE_first_tail_x15_r0_body.zsmn180
  zgrow := PRE_first_tail_x15_r0_body.zgrow180
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab180
  zfresh := PRE_first_tail_x15_r0_body.zfresh180
  zcnd := PRE_first_tail_x15_r0_body.zcnd180
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi180
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt180
  zgP := PRE_first_tail_x15_r0_body.zg180_2665
  zkP := PRE_first_tail_x15_r0_body.zk180_2665
  zmP := PRE_first_tail_x15_r0_body.zm180_2665
  zgC := PRE_first_tail_x15_r0_body.zg180_2673467
  zkC := PRE_first_tail_x15_r0_body.zk180_2673467
  zmC := PRE_first_tail_x15_r0_body.zm180_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw180_2673472
  zwV := PRE_first_tail_x15_r0_body.zw180_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap180
  zclbd := PRE_first_tail_x15_r0_body.zclbd180
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap180 PRE_first_tail_x15_r0_body.stFoot180 PRE_first_tail_x15_r0_body.iso180 PRE_first_tail_x15_r0_body.zwr180
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP180
  csupp := PRE_first_tail_x15_r0_body.csupp180
  cbound := PRE_first_tail_x15_r0_body.cbound180
  zimg := PRE_first_tail_x15_r0_body.zimg180
  zctl := PRE_first_tail_x15_r0_body.zctl180
  zstack := PRE_first_tail_x15_r0_body.zstack180
  zjobs := PRE_first_tail_x15_r0_body.zjobs180
  zstores := PRE_first_tail_x15_r0_body.zstores180
  zroots := PRE_first_tail_x15_r0_body.zroots180
  znC := PRE_first_tail_x15_r0_body.znC180
  ctab := PRE_first_tail_x15_r0_body.ctab180
  zbin := PRE_first_tail_x15_r0_body.zbin180
  cbridge := PRE_first_tail_x15_r0_body.cbridge180
  sbridge := bodyBridge180
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj180
  cshiftR := fun h hNL => bodyCshift180 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN180
  raised := PRE_first_tail_x15_r0_body.raised180
  cbigs := PRE_first_tail_x15_r0_body.cbigs180
  cjcl := PRE_first_tail_x15_r0_body.cjcl180
  xnLe := Nat.le_of_ble_eq_true bodyXn180
  loLe := Nat.le_of_ble_eq_true bodyLo180
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB180
  cntM := bodyCntM180
  hiLe := Nat.le_of_ble_eq_true bodyHi180
  nhiLe := Nat.le_of_ble_eq_true bodyNhi180
  jsHeap := bodyJs180
  jsRoots := bodyJsRoots180
  jsNative := bodyJsNative180
  framesEmpty := bodyFramesEmpty180
  trailOld := by decide
  lowVars := bodyLow180

def bodyQs180 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs180 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr180.map fun r => nth? PRE_first_tail_x15_r0_body.st180.S5.tab r
kernel_rfl bodyResChk180 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs180 bodyQs180) = true
kernel_rfl bodyLq180 : bodyQs180.length = PRE_first_tail_x15_r0_body.cws180.length
kernel_rfl bodyNrLo180 : PRE_first_tail_x15_r0_body.nr180.all (Nat.ble PRE_first_tail_x15_r0_body.S1741.tab.length) = true
kernel_rfl bodySub180 : (Oracles.PRE_first_tail_x15_r0_body.map_site180.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost180 : postSubB bodyM PRE_first_tail_x15_r0_body.ws180 PRE_first_tail_x15_r0_body.cws180 bodyQs180 = true
kernel_rfl bodyDrop180 : Nat.ble (61987 + (PRE_first_tail_x15_r0_body.s1742.next - PRE_first_tail_x15_r0_body.s1743.next)) 63136 = true
kernel_rfl bodyDropH180 : Nat.ble (1176 + ((mlxOf PRE_first_tail_x15_r0_body.s1742.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1743.ffi).next)) 1201 = true
kernel_rfl bodyDropN180 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1742.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1743.ffi).nnext)) 0 = true
kernel_rfl bodyDv180 : bodyΘ.1.take 963 = bodyΘ.1.take 945 ++ PRE_first_tail_x15_r0_body.cws180
kernel_rfl bodyDe180 : bodyΘ.2.take 963 = bodyΘ.2.take 945 ++ PRE_first_tail_x15_r0_body.nr180.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st180.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 945) (bodyΘ.2.take 945)))
kernel_rfl bodyDl180 : (bodyΘ.1.take 945).length = (bodyΘ.2.take 945).length
kernel_rfl bodyDold180 : (bodyΘ.1.take 945).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws180).isNone && !PRE_first_tail_x15_r0_body.ws180.contains v) = true
kernel_rfl bodyDfree180 : (bodyΘ.2.take 963).all (fun e => (PRE_first_tail_x15_r0_body.cws180 ++ PRE_first_tail_x15_r0_body.ws180).all fun w => e.noVar w) = true

theorem bodyStep180 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61987, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1741 PRE_first_tail_x15_r0_body.S1741)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63136, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1743 PRE_first_tail_x15_r0_body.S1743) (11334 + 1) :=
  bodySite bodyFacts180.cfix bodyFacts180.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st180.S5.tab) (Es := bodyEs180) (qs := bodyQs180)
    (ok := PRE_first_tail_x15_r0_body.st180.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site180 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts180
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site180 r hr) hi (MapOk.sub hm (sub_of_all bodySub180)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk180 r hr) hi hm ho hq)
    bodyLq180 rfl bodyNrLo180 (postSub_sound bodyPost180)
    (Nat.le_of_ble_eq_true bodyDrop180) (by decide) (Nat.le_of_ble_eq_true bodyDropH180) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN180) (by decide)
    bodyDv180 bodyDe180 bodyDl180 bodyDold180 bodyDfree180 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
