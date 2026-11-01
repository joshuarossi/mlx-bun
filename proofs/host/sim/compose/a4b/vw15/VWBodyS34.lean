import host.sim.compose.a4b.vw15.VWBodyJ34
import host.sim.compose.a4b.vw15.VWBodySite34
import host.sim.compose.a4b.vw15.VWBodyOracles_8
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift34 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S340.tab.length PRE_first_tail_x15_r0_body.s340.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P34.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P34 1532 PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.s342.ffi PRE_first_tail_x15_r0_body.s341.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_34
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_34
  have hcl : SSt (· < 1532) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S340.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_34] <;> decide) PRE_first_tail_x15_r0_body.cnodesK34 PRE_first_tail_x15_r0_body.cobjsK34
      PRE_first_tail_x15_r0_body.citemsK34 PRE_first_tail_x15_r0_body.cbd34 PRE_first_tail_x15_r0_body.csst34
  exact PRE_first_tail_x15_r0_body.cshift34 bodyNcl34 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_34] at this; exact this)


kernel_rfl bodyFramesEmpty34 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s341 a).isEmpty) = true
kernel_rfl bodyJsRoots34 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s340.next) PRE_first_tail_x15_r0_body.s342.trace PRE_first_tail_x15_r0_body.s342 = true
kernel_rfl bodyJsNative34 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s342.ffi) = true
kernel_rfl bodyLow34 : (PRE_first_tail_x15_r0_body.cws34 ++ PRE_first_tail_x15_r0_body.ws34).all (Nat.ble 9) = true
kernel_rfl bodyCntM34 : countersOkB PRE_first_tail_x15_r0_body.s340 PRE_first_tail_x15_r0_body.s341 = true
kernel_rfl bodyHi34 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s342.ffi).next setupP.E = true
kernel_rfl bodyNhi34 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s342.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge34 : bridgeOf PRE_first_tail_x15_r0_body.s341.ffi = bridgeOf PRE_first_tail_x15_r0_body.s340.ffi
kernel_rfl bodyNN34 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s340.ffi).nnext PRE_first_tail_x15_r0_body.P34.NL = true
kernel_rfl bodyXn34 : Nat.ble (⟨18882, 15966, 2701917, 1532⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s342.ffi).next = true
kernel_rfl bodyLo34 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s342.ffi).next = true
theorem bodyFacts34 : BodySiteFacts PRE_first_tail_x15_r0_body.s340 PRE_first_tail_x15_r0_body.s341 PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S340 PRE_first_tail_x15_r0_body.S341 PRE_first_tail_x15_r0_body.S342
    PRE_first_tail_x15_r0_body.ws34 PRE_first_tail_x15_r0_body.cws34 PRE_first_tail_x15_r0_body.nr34 PRE_first_tail_x15_r0_body.pl34 PRE_first_tail_x15_r0_body.cl34 2701919 1532 PRE_first_tail_x15_r0_body.kd34 PRE_first_tail_x15_r0_body.kappa34 PRE_first_tail_x15_r0_body.P34
    ⟨18882, 15966, 2701917, 1532⟩ ⟨18882, 15966, 2701917, 1532⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap34
  clean := bodyClean34
  cfix := PRE_first_tail_x15_r0_body.cfix34
  zpl := PRE_first_tail_x15_r0_body.zpl34
  zplnd := PRE_first_tail_x15_r0_body.zplnd34
  zn1 := PRE_first_tail_x15_r0_body.zn134
  zfirst := PRE_first_tail_x15_r0_body.zfirst34
  zscn := PRE_first_tail_x15_r0_body.zscn34
  zsmn := PRE_first_tail_x15_r0_body.zsmn34
  zgrow := PRE_first_tail_x15_r0_body.zgrow34
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab34
  zfresh := PRE_first_tail_x15_r0_body.zfresh34
  zcnd := PRE_first_tail_x15_r0_body.zcnd34
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi34
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt34
  zgP := PRE_first_tail_x15_r0_body.zg34_2665
  zkP := PRE_first_tail_x15_r0_body.zk34_2665
  zmP := PRE_first_tail_x15_r0_body.zm34_2665
  zgC := PRE_first_tail_x15_r0_body.zg34_2673467
  zkC := PRE_first_tail_x15_r0_body.zk34_2673467
  zmC := PRE_first_tail_x15_r0_body.zm34_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw34_2673472
  zwV := PRE_first_tail_x15_r0_body.zw34_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap34
  zclbd := PRE_first_tail_x15_r0_body.zclbd34
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap34 PRE_first_tail_x15_r0_body.stFoot34 PRE_first_tail_x15_r0_body.iso34 PRE_first_tail_x15_r0_body.zwr34
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP34
  csupp := PRE_first_tail_x15_r0_body.csupp34
  cbound := PRE_first_tail_x15_r0_body.cbound34
  zimg := PRE_first_tail_x15_r0_body.zimg34
  zctl := PRE_first_tail_x15_r0_body.zctl34
  zstack := PRE_first_tail_x15_r0_body.zstack34
  zjobs := PRE_first_tail_x15_r0_body.zjobs34
  zstores := PRE_first_tail_x15_r0_body.zstores34
  zroots := PRE_first_tail_x15_r0_body.zroots34
  znC := PRE_first_tail_x15_r0_body.znC34
  ctab := PRE_first_tail_x15_r0_body.ctab34
  zbin := PRE_first_tail_x15_r0_body.zbin34
  cbridge := PRE_first_tail_x15_r0_body.cbridge34
  sbridge := bodyBridge34
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj34
  cshiftR := fun h hNL => bodyCshift34 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN34
  raised := PRE_first_tail_x15_r0_body.raised34
  cbigs := PRE_first_tail_x15_r0_body.cbigs34
  cjcl := PRE_first_tail_x15_r0_body.cjcl34
  xnLe := Nat.le_of_ble_eq_true bodyXn34
  loLe := Nat.le_of_ble_eq_true bodyLo34
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB34
  cntM := bodyCntM34
  hiLe := Nat.le_of_ble_eq_true bodyHi34
  nhiLe := Nat.le_of_ble_eq_true bodyNhi34
  jsHeap := bodyJs34
  jsRoots := bodyJsRoots34
  jsNative := bodyJsNative34
  framesEmpty := bodyFramesEmpty34
  trailOld := by decide
  lowVars := bodyLow34

def bodyQs34 : List (Option Q) := []
noncomputable def bodyEs34 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr34.map fun r => nth? PRE_first_tail_x15_r0_body.st34.S2.tab r
kernel_rfl bodyResChk34 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs34 bodyQs34) = true
kernel_rfl bodyLq34 : bodyQs34.length = PRE_first_tail_x15_r0_body.cws34.length
kernel_rfl bodyNrLo34 : PRE_first_tail_x15_r0_body.nr34.all (Nat.ble PRE_first_tail_x15_r0_body.S340.tab.length) = true
kernel_rfl bodySub34 : (Oracles.PRE_first_tail_x15_r0_body.map_site34.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost34 : postSubB bodyM PRE_first_tail_x15_r0_body.ws34 PRE_first_tail_x15_r0_body.cws34 bodyQs34 = true
kernel_rfl bodyDrop34 : Nat.ble (15646 + (PRE_first_tail_x15_r0_body.s341.next - PRE_first_tail_x15_r0_body.s342.next)) 15648 = true
kernel_rfl bodyDropH34 : Nat.ble (252 + ((mlxOf PRE_first_tail_x15_r0_body.s341.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s342.ffi).next)) 252 = true
kernel_rfl bodyDropN34 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s341.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s342.ffi).nnext)) 0 = true
kernel_rfl bodyDv34 : bodyΘ.1.take 189 = bodyΘ.1.take 189 ++ PRE_first_tail_x15_r0_body.cws34
kernel_rfl bodyDe34 : bodyΘ.2.take 189 = bodyΘ.2.take 189 ++ PRE_first_tail_x15_r0_body.nr34.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st34.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 189) (bodyΘ.2.take 189)))
kernel_rfl bodyDl34 : (bodyΘ.1.take 189).length = (bodyΘ.2.take 189).length
kernel_rfl bodyDold34 : (bodyΘ.1.take 189).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws34).isNone && !PRE_first_tail_x15_r0_body.ws34.contains v) = true
kernel_rfl bodyDfree34 : (bodyΘ.2.take 189).all (fun e => (PRE_first_tail_x15_r0_body.cws34 ++ PRE_first_tail_x15_r0_body.ws34).all fun w => e.noVar w) = true

theorem bodyStep34 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15646, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s340 PRE_first_tail_x15_r0_body.S340)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15648, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.S342) (27 + 1) :=
  bodySite bodyFacts34.cfix bodyFacts34.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 27) (S2 := PRE_first_tail_x15_r0_body.st34.S2.tab) (Es := bodyEs34) (qs := bodyQs34)
    (ok := PRE_first_tail_x15_r0_body.st34.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site34 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts34
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site34 r hr) hi (MapOk.sub hm (sub_of_all bodySub34)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk34 r hr) hi hm ho hq)
    bodyLq34 rfl bodyNrLo34 (postSub_sound bodyPost34)
    (Nat.le_of_ble_eq_true bodyDrop34) (by decide) (Nat.le_of_ble_eq_true bodyDropH34) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN34) (by decide)
    bodyDv34 bodyDe34 bodyDl34 bodyDold34 bodyDfree34 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
