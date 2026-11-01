import host.sim.compose.a4b.vw15.VWBodyJ165
import host.sim.compose.a4b.vw15.VWBodySite165
import host.sim.compose.a4b.vw15.VWBodyOracles_41
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift165 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1597.tab.length PRE_first_tail_x15_r0_body.s1597.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P165.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P165 7152 PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.s1599.ffi PRE_first_tail_x15_r0_body.s1598.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_165
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_165
  have hcl : SSt (· < 7152) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1597.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_165] <;> decide) PRE_first_tail_x15_r0_body.cnodesK165 PRE_first_tail_x15_r0_body.cobjsK165
      PRE_first_tail_x15_r0_body.citemsK165 PRE_first_tail_x15_r0_body.cbd165 PRE_first_tail_x15_r0_body.csst165
  exact PRE_first_tail_x15_r0_body.cshift165 bodyNcl165 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_165] at this; exact this)


kernel_rfl bodyFramesEmpty165 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1598 a).isEmpty) = true
kernel_rfl bodyJsRoots165 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1597.next) PRE_first_tail_x15_r0_body.s1599.trace PRE_first_tail_x15_r0_body.s1599 = true
kernel_rfl bodyJsNative165 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1599.ffi) = true
kernel_rfl bodyLow165 : (PRE_first_tail_x15_r0_body.cws165 ++ PRE_first_tail_x15_r0_body.ws165).all (Nat.ble 9) = true
kernel_rfl bodyCntM165 : countersOkB PRE_first_tail_x15_r0_body.s1597 PRE_first_tail_x15_r0_body.s1598 = true
kernel_rfl bodyHi165 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1599.ffi).next setupP.E = true
kernel_rfl bodyNhi165 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1599.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge165 : bridgeOf PRE_first_tail_x15_r0_body.s1598.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1597.ffi
kernel_rfl bodyNN165 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1597.ffi).nnext PRE_first_tail_x15_r0_body.P165.NL = true
kernel_rfl bodyXn165 : Nat.ble (⟨21465, 18563, 2804931, 7152⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1599.ffi).next = true
kernel_rfl bodyLo165 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1599.ffi).next = true
theorem bodyFacts165 : BodySiteFacts PRE_first_tail_x15_r0_body.s1597 PRE_first_tail_x15_r0_body.s1598 PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1597 PRE_first_tail_x15_r0_body.S1598 PRE_first_tail_x15_r0_body.S1599
    PRE_first_tail_x15_r0_body.ws165 PRE_first_tail_x15_r0_body.cws165 PRE_first_tail_x15_r0_body.nr165 PRE_first_tail_x15_r0_body.pl165 PRE_first_tail_x15_r0_body.cl165 2805281 7152 PRE_first_tail_x15_r0_body.kd165 PRE_first_tail_x15_r0_body.kappa165 PRE_first_tail_x15_r0_body.P165
    ⟨21461, 18557, 2804916, 7143⟩ ⟨21465, 18563, 2804931, 7152⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap165
  clean := bodyClean165
  cfix := PRE_first_tail_x15_r0_body.cfix165
  zpl := PRE_first_tail_x15_r0_body.zpl165
  zplnd := PRE_first_tail_x15_r0_body.zplnd165
  zn1 := PRE_first_tail_x15_r0_body.zn1165
  zfirst := PRE_first_tail_x15_r0_body.zfirst165
  zscn := PRE_first_tail_x15_r0_body.zscn165
  zsmn := PRE_first_tail_x15_r0_body.zsmn165
  zgrow := PRE_first_tail_x15_r0_body.zgrow165
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab165
  zfresh := PRE_first_tail_x15_r0_body.zfresh165
  zcnd := PRE_first_tail_x15_r0_body.zcnd165
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi165
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt165
  zgP := PRE_first_tail_x15_r0_body.zg165_2665
  zkP := PRE_first_tail_x15_r0_body.zk165_2665
  zmP := PRE_first_tail_x15_r0_body.zm165_2665
  zgC := PRE_first_tail_x15_r0_body.zg165_2673467
  zkC := PRE_first_tail_x15_r0_body.zk165_2673467
  zmC := PRE_first_tail_x15_r0_body.zm165_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw165_2673472
  zwV := PRE_first_tail_x15_r0_body.zw165_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap165
  zclbd := PRE_first_tail_x15_r0_body.zclbd165
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap165 PRE_first_tail_x15_r0_body.stFoot165 PRE_first_tail_x15_r0_body.iso165 PRE_first_tail_x15_r0_body.zwr165
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP165
  csupp := PRE_first_tail_x15_r0_body.csupp165
  cbound := PRE_first_tail_x15_r0_body.cbound165
  zimg := PRE_first_tail_x15_r0_body.zimg165
  zctl := PRE_first_tail_x15_r0_body.zctl165
  zstack := PRE_first_tail_x15_r0_body.zstack165
  zjobs := PRE_first_tail_x15_r0_body.zjobs165
  zstores := PRE_first_tail_x15_r0_body.zstores165
  zroots := PRE_first_tail_x15_r0_body.zroots165
  znC := PRE_first_tail_x15_r0_body.znC165
  ctab := PRE_first_tail_x15_r0_body.ctab165
  zbin := PRE_first_tail_x15_r0_body.zbin165
  cbridge := PRE_first_tail_x15_r0_body.cbridge165
  sbridge := bodyBridge165
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj165
  cshiftR := fun h hNL => bodyCshift165 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN165
  raised := PRE_first_tail_x15_r0_body.raised165
  cbigs := PRE_first_tail_x15_r0_body.cbigs165
  cjcl := PRE_first_tail_x15_r0_body.cjcl165
  xnLe := Nat.le_of_ble_eq_true bodyXn165
  loLe := Nat.le_of_ble_eq_true bodyLo165
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB165
  cntM := bodyCntM165
  hiLe := Nat.le_of_ble_eq_true bodyHi165
  nhiLe := Nat.le_of_ble_eq_true bodyNhi165
  jsHeap := bodyJs165
  jsRoots := bodyJsRoots165
  jsNative := bodyJsNative165
  framesEmpty := bodyFramesEmpty165
  trailOld := by decide
  lowVars := bodyLow165

def bodyQs165 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs165 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr165.map fun r => nth? PRE_first_tail_x15_r0_body.st165.S3.tab r
kernel_rfl bodyResChk165 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs165 bodyQs165) = true
kernel_rfl bodyLq165 : bodyQs165.length = PRE_first_tail_x15_r0_body.cws165.length
kernel_rfl bodyNrLo165 : PRE_first_tail_x15_r0_body.nr165.all (Nat.ble PRE_first_tail_x15_r0_body.S1597.tab.length) = true
kernel_rfl bodySub165 : (Oracles.PRE_first_tail_x15_r0_body.map_site165.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost165 : postSubB bodyM PRE_first_tail_x15_r0_body.ws165 PRE_first_tail_x15_r0_body.cws165 bodyQs165 = true
kernel_rfl bodyDrop165 : Nat.ble (57735 + (PRE_first_tail_x15_r0_body.s1598.next - PRE_first_tail_x15_r0_body.s1599.next)) 58085 = true
kernel_rfl bodyDropH165 : Nat.ble (1097 + ((mlxOf PRE_first_tail_x15_r0_body.s1598.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1599.ffi).next)) 1099 = true
kernel_rfl bodyDropN165 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1598.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1599.ffi).nnext)) 0 = true
kernel_rfl bodyDv165 : bodyΘ.1.take 882 = bodyΘ.1.take 873 ++ PRE_first_tail_x15_r0_body.cws165
kernel_rfl bodyDe165 : bodyΘ.2.take 882 = bodyΘ.2.take 873 ++ PRE_first_tail_x15_r0_body.nr165.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st165.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 873) (bodyΘ.2.take 873)))
kernel_rfl bodyDl165 : (bodyΘ.1.take 873).length = (bodyΘ.2.take 873).length
kernel_rfl bodyDold165 : (bodyΘ.1.take 873).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws165).isNone && !PRE_first_tail_x15_r0_body.ws165.contains v) = true
kernel_rfl bodyDfree165 : (bodyΘ.2.take 882).all (fun e => (PRE_first_tail_x15_r0_body.cws165 ++ PRE_first_tail_x15_r0_body.ws165).all fun w => e.noVar w) = true

theorem bodyStep165 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57735, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1597 PRE_first_tail_x15_r0_body.S1597)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58085, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.S1599) (3452 + 1) :=
  bodySite bodyFacts165.cfix bodyFacts165.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st165.S3.tab) (Es := bodyEs165) (qs := bodyQs165)
    (ok := PRE_first_tail_x15_r0_body.st165.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site165 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts165
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site165 r hr) hi (MapOk.sub hm (sub_of_all bodySub165)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk165 r hr) hi hm ho hq)
    bodyLq165 rfl bodyNrLo165 (postSub_sound bodyPost165)
    (Nat.le_of_ble_eq_true bodyDrop165) (by decide) (Nat.le_of_ble_eq_true bodyDropH165) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN165) (by decide)
    bodyDv165 bodyDe165 bodyDl165 bodyDold165 bodyDfree165 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
