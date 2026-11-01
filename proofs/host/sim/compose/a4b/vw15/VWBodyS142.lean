import host.sim.compose.a4b.vw15.VWBodyJ142
import host.sim.compose.a4b.vw15.VWBodySite142
import host.sim.compose.a4b.vw15.VWBodyOracles_35
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift142 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1375.tab.length PRE_first_tail_x15_r0_body.s1375.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P142.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.s1377.ffi PRE_first_tail_x15_r0_body.s1376.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_142
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_142
  have hcl : SSt (· < 6149) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1375.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_142] <;> decide) PRE_first_tail_x15_r0_body.cnodesK142 PRE_first_tail_x15_r0_body.cobjsK142
      PRE_first_tail_x15_r0_body.citemsK142 PRE_first_tail_x15_r0_body.cbd142 PRE_first_tail_x15_r0_body.csst142
  exact PRE_first_tail_x15_r0_body.cshift142 bodyNcl142 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_142] at this; exact this)


kernel_rfl bodyFramesEmpty142 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1376 a).isEmpty) = true
kernel_rfl bodyJsRoots142 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1375.next) PRE_first_tail_x15_r0_body.s1377.trace PRE_first_tail_x15_r0_body.s1377 = true
kernel_rfl bodyJsNative142 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1377.ffi) = true
kernel_rfl bodyLow142 : (PRE_first_tail_x15_r0_body.cws142 ++ PRE_first_tail_x15_r0_body.ws142).all (Nat.ble 9) = true
kernel_rfl bodyCntM142 : countersOkB PRE_first_tail_x15_r0_body.s1375 PRE_first_tail_x15_r0_body.s1376 = true
kernel_rfl bodyHi142 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1377.ffi).next setupP.E = true
kernel_rfl bodyNhi142 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1377.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge142 : bridgeOf PRE_first_tail_x15_r0_body.s1376.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1375.ffi
kernel_rfl bodyNN142 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1375.ffi).nnext PRE_first_tail_x15_r0_body.P142.NL = true
kernel_rfl bodyXn142 : Nat.ble (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1377.ffi).next = true
kernel_rfl bodyLo142 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1377.ffi).next = true
theorem bodyFacts142 : BodySiteFacts PRE_first_tail_x15_r0_body.s1375 PRE_first_tail_x15_r0_body.s1376 PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1375 PRE_first_tail_x15_r0_body.S1376 PRE_first_tail_x15_r0_body.S1377
    PRE_first_tail_x15_r0_body.ws142 PRE_first_tail_x15_r0_body.cws142 PRE_first_tail_x15_r0_body.nr142 PRE_first_tail_x15_r0_body.pl142 PRE_first_tail_x15_r0_body.cl142 2786675 6149 PRE_first_tail_x15_r0_body.kd142 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.P142
    ⟨21006, 18099, 2786673, 6149⟩ ⟨21006, 18099, 2786673, 6149⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap142
  clean := bodyClean142
  cfix := PRE_first_tail_x15_r0_body.cfix142
  zpl := PRE_first_tail_x15_r0_body.zpl142
  zplnd := PRE_first_tail_x15_r0_body.zplnd142
  zn1 := PRE_first_tail_x15_r0_body.zn1142
  zfirst := PRE_first_tail_x15_r0_body.zfirst142
  zscn := PRE_first_tail_x15_r0_body.zscn142
  zsmn := PRE_first_tail_x15_r0_body.zsmn142
  zgrow := PRE_first_tail_x15_r0_body.zgrow142
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab142
  zfresh := PRE_first_tail_x15_r0_body.zfresh142
  zcnd := PRE_first_tail_x15_r0_body.zcnd142
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi142
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt142
  zgP := PRE_first_tail_x15_r0_body.zg142_2665
  zkP := PRE_first_tail_x15_r0_body.zk142_2665
  zmP := PRE_first_tail_x15_r0_body.zm142_2665
  zgC := PRE_first_tail_x15_r0_body.zg142_2673467
  zkC := PRE_first_tail_x15_r0_body.zk142_2673467
  zmC := PRE_first_tail_x15_r0_body.zm142_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw142_2673472
  zwV := PRE_first_tail_x15_r0_body.zw142_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap142
  zclbd := PRE_first_tail_x15_r0_body.zclbd142
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap142 PRE_first_tail_x15_r0_body.stFoot142 PRE_first_tail_x15_r0_body.iso142 PRE_first_tail_x15_r0_body.zwr142
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP142
  csupp := PRE_first_tail_x15_r0_body.csupp142
  cbound := PRE_first_tail_x15_r0_body.cbound142
  zimg := PRE_first_tail_x15_r0_body.zimg142
  zctl := PRE_first_tail_x15_r0_body.zctl142
  zstack := PRE_first_tail_x15_r0_body.zstack142
  zjobs := PRE_first_tail_x15_r0_body.zjobs142
  zstores := PRE_first_tail_x15_r0_body.zstores142
  zroots := PRE_first_tail_x15_r0_body.zroots142
  znC := PRE_first_tail_x15_r0_body.znC142
  ctab := PRE_first_tail_x15_r0_body.ctab142
  zbin := PRE_first_tail_x15_r0_body.zbin142
  cbridge := PRE_first_tail_x15_r0_body.cbridge142
  sbridge := bodyBridge142
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj142
  cshiftR := fun h hNL => bodyCshift142 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN142
  raised := PRE_first_tail_x15_r0_body.raised142
  cbigs := PRE_first_tail_x15_r0_body.cbigs142
  cjcl := PRE_first_tail_x15_r0_body.cjcl142
  xnLe := Nat.le_of_ble_eq_true bodyXn142
  loLe := Nat.le_of_ble_eq_true bodyLo142
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB142
  cntM := bodyCntM142
  hiLe := Nat.le_of_ble_eq_true bodyHi142
  nhiLe := Nat.le_of_ble_eq_true bodyNhi142
  jsHeap := bodyJs142
  jsRoots := bodyJsRoots142
  jsNative := bodyJsNative142
  framesEmpty := bodyFramesEmpty142
  trailOld := by decide
  lowVars := bodyLow142

def bodyQs142 : List (Option Q) := []
noncomputable def bodyEs142 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr142.map fun r => nth? PRE_first_tail_x15_r0_body.st142.S2.tab r
kernel_rfl bodyResChk142 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs142 bodyQs142) = true
kernel_rfl bodyLq142 : bodyQs142.length = PRE_first_tail_x15_r0_body.cws142.length
kernel_rfl bodyNrLo142 : PRE_first_tail_x15_r0_body.nr142.all (Nat.ble PRE_first_tail_x15_r0_body.S1375.tab.length) = true
kernel_rfl bodySub142 : (Oracles.PRE_first_tail_x15_r0_body.map_site142.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost142 : postSubB bodyM PRE_first_tail_x15_r0_body.ws142 PRE_first_tail_x15_r0_body.cws142 bodyQs142 = true
kernel_rfl bodyDrop142 : Nat.ble (50359 + (PRE_first_tail_x15_r0_body.s1376.next - PRE_first_tail_x15_r0_body.s1377.next)) 50361 = true
kernel_rfl bodyDropH142 : Nat.ble (945 + ((mlxOf PRE_first_tail_x15_r0_body.s1376.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1377.ffi).next)) 945 = true
kernel_rfl bodyDropN142 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1376.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1377.ffi).nnext)) 0 = true
kernel_rfl bodyDv142 : bodyΘ.1.take 756 = bodyΘ.1.take 756 ++ PRE_first_tail_x15_r0_body.cws142
kernel_rfl bodyDe142 : bodyΘ.2.take 756 = bodyΘ.2.take 756 ++ PRE_first_tail_x15_r0_body.nr142.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st142.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 756) (bodyΘ.2.take 756)))
kernel_rfl bodyDl142 : (bodyΘ.1.take 756).length = (bodyΘ.2.take 756).length
kernel_rfl bodyDold142 : (bodyΘ.1.take 756).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws142).isNone && !PRE_first_tail_x15_r0_body.ws142.contains v) = true
kernel_rfl bodyDfree142 : (bodyΘ.2.take 756).all (fun e => (PRE_first_tail_x15_r0_body.cws142 ++ PRE_first_tail_x15_r0_body.ws142).all fun w => e.noVar w) = true

theorem bodyStep142 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨50359, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1375 PRE_first_tail_x15_r0_body.S1375)
      (bodyCut NB T tk π i x0 bodyΘ ⟨50361, 945, 0, 756⟩ bodyM PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.S1377) (27 + 1) :=
  bodySite bodyFacts142.cfix bodyFacts142.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st142.S2.tab) (Es := bodyEs142) (qs := bodyQs142)
    (ok := PRE_first_tail_x15_r0_body.st142.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site142 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts142
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site142 r hr) hi (MapOk.sub hm (sub_of_all bodySub142)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk142 r hr) hi hm ho hq)
    bodyLq142 rfl bodyNrLo142 (postSub_sound bodyPost142)
    (Nat.le_of_ble_eq_true bodyDrop142) (by decide) (Nat.le_of_ble_eq_true bodyDropH142) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN142) (by decide)
    bodyDv142 bodyDe142 bodyDl142 bodyDold142 bodyDfree142 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
