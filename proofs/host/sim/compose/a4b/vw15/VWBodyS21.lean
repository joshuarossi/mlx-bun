import host.sim.compose.a4b.vw15.VWBodyJ21
import host.sim.compose.a4b.vw15.VWBodySite21
import host.sim.compose.a4b.vw15.VWBodyOracles_5
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B18
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift21 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S217.tab.length PRE_first_tail_x15_r0_body.s217.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P21.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P21 996 PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.s219.ffi PRE_first_tail_x15_r0_body.s218.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_21
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_21
  have hcl : SSt (· < 996) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S217.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_21] <;> decide) PRE_first_tail_x15_r0_body.cnodesK21 PRE_first_tail_x15_r0_body.cobjsK21
      PRE_first_tail_x15_r0_body.citemsK21 PRE_first_tail_x15_r0_body.cbd21 PRE_first_tail_x15_r0_body.csst21
  exact PRE_first_tail_x15_r0_body.cshift21 bodyNcl21 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_21] at this; exact this)


kernel_rfl bodyFramesEmpty21 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s218 a).isEmpty) = true
kernel_rfl bodyJsRoots21 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s217.next) PRE_first_tail_x15_r0_body.s219.trace PRE_first_tail_x15_r0_body.s219 = true
kernel_rfl bodyJsNative21 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s219.ffi) = true
kernel_rfl bodyLow21 : (PRE_first_tail_x15_r0_body.cws21 ++ PRE_first_tail_x15_r0_body.ws21).all (Nat.ble 9) = true
kernel_rfl bodyCntM21 : countersOkB PRE_first_tail_x15_r0_body.s217 PRE_first_tail_x15_r0_body.s218 = true
kernel_rfl bodyHi21 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s219.ffi).next setupP.E = true
kernel_rfl bodyNhi21 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s219.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge21 : bridgeOf PRE_first_tail_x15_r0_body.s218.ffi = bridgeOf PRE_first_tail_x15_r0_body.s217.ffi
kernel_rfl bodyNN21 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s217.ffi).nnext PRE_first_tail_x15_r0_body.P21.NL = true
kernel_rfl bodyXn21 : Nat.ble (⟨18633, 15719, 2691923, 996⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s219.ffi).next = true
kernel_rfl bodyLo21 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s219.ffi).next = true
theorem bodyFacts21 : BodySiteFacts PRE_first_tail_x15_r0_body.s217 PRE_first_tail_x15_r0_body.s218 PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S217 PRE_first_tail_x15_r0_body.S218 PRE_first_tail_x15_r0_body.S219
    PRE_first_tail_x15_r0_body.ws21 PRE_first_tail_x15_r0_body.cws21 PRE_first_tail_x15_r0_body.nr21 PRE_first_tail_x15_r0_body.pl21 PRE_first_tail_x15_r0_body.cl21 2692273 996 PRE_first_tail_x15_r0_body.kd21 PRE_first_tail_x15_r0_body.kappa21 PRE_first_tail_x15_r0_body.P21
    ⟨18629, 15713, 2691908, 987⟩ ⟨18633, 15719, 2691923, 996⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap21
  clean := bodyClean21
  cfix := PRE_first_tail_x15_r0_body.cfix21
  zpl := PRE_first_tail_x15_r0_body.zpl21
  zplnd := PRE_first_tail_x15_r0_body.zplnd21
  zn1 := PRE_first_tail_x15_r0_body.zn121
  zfirst := PRE_first_tail_x15_r0_body.zfirst21
  zscn := PRE_first_tail_x15_r0_body.zscn21
  zsmn := PRE_first_tail_x15_r0_body.zsmn21
  zgrow := PRE_first_tail_x15_r0_body.zgrow21
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab21
  zfresh := PRE_first_tail_x15_r0_body.zfresh21
  zcnd := PRE_first_tail_x15_r0_body.zcnd21
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi21
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt21
  zgP := PRE_first_tail_x15_r0_body.zg21_2665
  zkP := PRE_first_tail_x15_r0_body.zk21_2665
  zmP := PRE_first_tail_x15_r0_body.zm21_2665
  zgC := PRE_first_tail_x15_r0_body.zg21_2673467
  zkC := PRE_first_tail_x15_r0_body.zk21_2673467
  zmC := PRE_first_tail_x15_r0_body.zm21_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw21_2673472
  zwV := PRE_first_tail_x15_r0_body.zw21_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap21
  zclbd := PRE_first_tail_x15_r0_body.zclbd21
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap21 PRE_first_tail_x15_r0_body.stFoot21 PRE_first_tail_x15_r0_body.iso21 PRE_first_tail_x15_r0_body.zwr21
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP21
  csupp := PRE_first_tail_x15_r0_body.csupp21
  cbound := PRE_first_tail_x15_r0_body.cbound21
  zimg := PRE_first_tail_x15_r0_body.zimg21
  zctl := PRE_first_tail_x15_r0_body.zctl21
  zstack := PRE_first_tail_x15_r0_body.zstack21
  zjobs := PRE_first_tail_x15_r0_body.zjobs21
  zstores := PRE_first_tail_x15_r0_body.zstores21
  zroots := PRE_first_tail_x15_r0_body.zroots21
  znC := PRE_first_tail_x15_r0_body.znC21
  ctab := PRE_first_tail_x15_r0_body.ctab21
  zbin := PRE_first_tail_x15_r0_body.zbin21
  cbridge := PRE_first_tail_x15_r0_body.cbridge21
  sbridge := bodyBridge21
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj21
  cshiftR := fun h hNL => bodyCshift21 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN21
  raised := PRE_first_tail_x15_r0_body.raised21
  cbigs := PRE_first_tail_x15_r0_body.cbigs21
  cjcl := PRE_first_tail_x15_r0_body.cjcl21
  xnLe := Nat.le_of_ble_eq_true bodyXn21
  loLe := Nat.le_of_ble_eq_true bodyLo21
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB21
  cntM := bodyCntM21
  hiLe := Nat.le_of_ble_eq_true bodyHi21
  nhiLe := Nat.le_of_ble_eq_true bodyNhi21
  jsHeap := bodyJs21
  jsRoots := bodyJsRoots21
  jsNative := bodyJsNative21
  framesEmpty := bodyFramesEmpty21
  trailOld := by decide
  lowVars := bodyLow21

def bodyQs21 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs21 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr21.map fun r => nth? PRE_first_tail_x15_r0_body.st21.S3.tab r
kernel_rfl bodyResChk21 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs21 bodyQs21) = true
kernel_rfl bodyLq21 : bodyQs21.length = PRE_first_tail_x15_r0_body.cws21.length
kernel_rfl bodyNrLo21 : PRE_first_tail_x15_r0_body.nr21.all (Nat.ble PRE_first_tail_x15_r0_body.S217.tab.length) = true
kernel_rfl bodySub21 : (Oracles.PRE_first_tail_x15_r0_body.map_site21.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost21 : postSubB bodyM PRE_first_tail_x15_r0_body.ws21 PRE_first_tail_x15_r0_body.cws21 bodyQs21 = true
kernel_rfl bodyDrop21 : Nat.ble (11451 + (PRE_first_tail_x15_r0_body.s218.next - PRE_first_tail_x15_r0_body.s219.next)) 11801 = true
kernel_rfl bodyDropH21 : Nat.ble (173 + ((mlxOf PRE_first_tail_x15_r0_body.s218.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s219.ffi).next)) 175 = true
kernel_rfl bodyDropN21 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s218.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s219.ffi).nnext)) 0 = true
kernel_rfl bodyDv21 : bodyΘ.1.take 126 = bodyΘ.1.take 117 ++ PRE_first_tail_x15_r0_body.cws21
kernel_rfl bodyDe21 : bodyΘ.2.take 126 = bodyΘ.2.take 117 ++ PRE_first_tail_x15_r0_body.nr21.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st21.S3.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 117) (bodyΘ.2.take 117)))
kernel_rfl bodyDl21 : (bodyΘ.1.take 117).length = (bodyΘ.2.take 117).length
kernel_rfl bodyDold21 : (bodyΘ.1.take 117).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws21).isNone && !PRE_first_tail_x15_r0_body.ws21.contains v) = true
kernel_rfl bodyDfree21 : (bodyΘ.2.take 126).all (fun e => (PRE_first_tail_x15_r0_body.cws21 ++ PRE_first_tail_x15_r0_body.ws21).all fun w => e.noVar w) = true

theorem bodyStep21 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨11451, 173, 0, 117⟩ bodyM PRE_first_tail_x15_r0_body.s217 PRE_first_tail_x15_r0_body.S217)
      (bodyCut NB T tk π i x0 bodyΘ ⟨11801, 175, 0, 126⟩ bodyM PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.S219) (3452 + 1) :=
  bodySite bodyFacts21.cfix bodyFacts21.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 3452) (S2 := PRE_first_tail_x15_r0_body.st21.S3.tab) (Es := bodyEs21) (qs := bodyQs21)
    (ok := PRE_first_tail_x15_r0_body.st21.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site21 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts21
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site21 r hr) hi (MapOk.sub hm (sub_of_all bodySub21)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk21 r hr) hi hm ho hq)
    bodyLq21 rfl bodyNrLo21 (postSub_sound bodyPost21)
    (Nat.le_of_ble_eq_true bodyDrop21) (by decide) (Nat.le_of_ble_eq_true bodyDropH21) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN21) (by decide)
    bodyDv21 bodyDe21 bodyDl21 bodyDold21 bodyDfree21 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
