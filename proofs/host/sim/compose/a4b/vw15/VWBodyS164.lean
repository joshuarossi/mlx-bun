import host.sim.compose.a4b.vw15.VWBodyJ164
import host.sim.compose.a4b.vw15.VWBodySite164
import host.sim.compose.a4b.vw15.VWBodyOracles_41
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B30
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B31
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyCshift164 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S1581.tab.length PRE_first_tail_x15_r0_body.s1581.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P164.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P164 7066 PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.s1583.ffi PRE_first_tail_x15_r0_body.s1582.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_164
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_164
  have hcl : SSt (· < 7066) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1583.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S1581.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_164] <;> decide) PRE_first_tail_x15_r0_body.cnodesK164 PRE_first_tail_x15_r0_body.cobjsK164
      PRE_first_tail_x15_r0_body.citemsK164 PRE_first_tail_x15_r0_body.cbd164 PRE_first_tail_x15_r0_body.csst164
  exact PRE_first_tail_x15_r0_body.cshift164 bodyNcl164 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_164] at this; exact this)


kernel_rfl bodyFramesEmpty164 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s1582 a).isEmpty) = true
kernel_rfl bodyJsRoots164 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s1581.next) PRE_first_tail_x15_r0_body.s1583.trace PRE_first_tail_x15_r0_body.s1583 = true
kernel_rfl bodyJsNative164 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s1583.ffi) = true
kernel_rfl bodyLow164 : (PRE_first_tail_x15_r0_body.cws164 ++ PRE_first_tail_x15_r0_body.ws164).all (Nat.ble 9) = true
kernel_rfl bodyCntM164 : countersOkB PRE_first_tail_x15_r0_body.s1581 PRE_first_tail_x15_r0_body.s1582 = true
kernel_rfl bodyHi164 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1583.ffi).next setupP.E = true
kernel_rfl bodyNhi164 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1583.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge164 : bridgeOf PRE_first_tail_x15_r0_body.s1582.ffi = bridgeOf PRE_first_tail_x15_r0_body.s1581.ffi
kernel_rfl bodyNN164 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s1581.ffi).nnext PRE_first_tail_x15_r0_body.P164.NL = true
kernel_rfl bodyXn164 : Nat.ble (⟨21421, 18529, 2803176, 7066⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s1583.ffi).next = true
kernel_rfl bodyLo164 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s1583.ffi).next = true
theorem bodyFacts164 : BodySiteFacts PRE_first_tail_x15_r0_body.s1581 PRE_first_tail_x15_r0_body.s1582 PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S1581 PRE_first_tail_x15_r0_body.S1582 PRE_first_tail_x15_r0_body.S1583
    PRE_first_tail_x15_r0_body.ws164 PRE_first_tail_x15_r0_body.cws164 PRE_first_tail_x15_r0_body.nr164 PRE_first_tail_x15_r0_body.pl164 PRE_first_tail_x15_r0_body.cl164 2803195 7066 PRE_first_tail_x15_r0_body.kd164 PRE_first_tail_x15_r0_body.kappa164 PRE_first_tail_x15_r0_body.P164
    ⟨21421, 18529, 2803175, 7066⟩ ⟨21421, 18529, 2803176, 7066⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap164
  clean := bodyClean164
  cfix := PRE_first_tail_x15_r0_body.cfix164
  zpl := PRE_first_tail_x15_r0_body.zpl164
  zplnd := PRE_first_tail_x15_r0_body.zplnd164
  zn1 := PRE_first_tail_x15_r0_body.zn1164
  zfirst := PRE_first_tail_x15_r0_body.zfirst164
  zscn := PRE_first_tail_x15_r0_body.zscn164
  zsmn := PRE_first_tail_x15_r0_body.zsmn164
  zgrow := PRE_first_tail_x15_r0_body.zgrow164
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab164
  zfresh := PRE_first_tail_x15_r0_body.zfresh164
  zcnd := PRE_first_tail_x15_r0_body.zcnd164
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi164
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt164
  zgP := PRE_first_tail_x15_r0_body.zg164_2665
  zkP := PRE_first_tail_x15_r0_body.zk164_2665
  zmP := PRE_first_tail_x15_r0_body.zm164_2665
  zgC := PRE_first_tail_x15_r0_body.zg164_2673467
  zkC := PRE_first_tail_x15_r0_body.zk164_2673467
  zmC := PRE_first_tail_x15_r0_body.zm164_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw164_2673472
  zwV := PRE_first_tail_x15_r0_body.zw164_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap164
  zclbd := PRE_first_tail_x15_r0_body.zclbd164
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap164 PRE_first_tail_x15_r0_body.stFoot164 PRE_first_tail_x15_r0_body.iso164 PRE_first_tail_x15_r0_body.zwr164
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP164
  csupp := PRE_first_tail_x15_r0_body.csupp164
  cbound := PRE_first_tail_x15_r0_body.cbound164
  zimg := PRE_first_tail_x15_r0_body.zimg164
  zctl := PRE_first_tail_x15_r0_body.zctl164
  zstack := PRE_first_tail_x15_r0_body.zstack164
  zjobs := PRE_first_tail_x15_r0_body.zjobs164
  zstores := PRE_first_tail_x15_r0_body.zstores164
  zroots := PRE_first_tail_x15_r0_body.zroots164
  znC := PRE_first_tail_x15_r0_body.znC164
  ctab := PRE_first_tail_x15_r0_body.ctab164
  zbin := PRE_first_tail_x15_r0_body.zbin164
  cbridge := PRE_first_tail_x15_r0_body.cbridge164
  sbridge := bodyBridge164
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj164
  cshiftR := fun h hNL => bodyCshift164 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN164
  raised := PRE_first_tail_x15_r0_body.raised164
  cbigs := PRE_first_tail_x15_r0_body.cbigs164
  cjcl := PRE_first_tail_x15_r0_body.cjcl164
  xnLe := Nat.le_of_ble_eq_true bodyXn164
  loLe := Nat.le_of_ble_eq_true bodyLo164
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB164
  cntM := bodyCntM164
  hiLe := Nat.le_of_ble_eq_true bodyHi164
  nhiLe := Nat.le_of_ble_eq_true bodyNhi164
  jsHeap := bodyJs164
  jsRoots := bodyJsRoots164
  jsNative := bodyJsNative164
  framesEmpty := bodyFramesEmpty164
  trailOld := by decide
  lowVars := bodyLow164

def bodyQs164 : List (Option Q) := []
noncomputable def bodyEs164 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr164.map fun r => nth? PRE_first_tail_x15_r0_body.st164.S2.tab r
kernel_rfl bodyResChk164 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs164 bodyQs164) = true
kernel_rfl bodyLq164 : bodyQs164.length = PRE_first_tail_x15_r0_body.cws164.length
kernel_rfl bodyNrLo164 : PRE_first_tail_x15_r0_body.nr164.all (Nat.ble PRE_first_tail_x15_r0_body.S1581.tab.length) = true
kernel_rfl bodySub164 : (Oracles.PRE_first_tail_x15_r0_body.map_site164.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost164 : postSubB bodyM PRE_first_tail_x15_r0_body.ws164 PRE_first_tail_x15_r0_body.cws164 bodyQs164 = true
kernel_rfl bodyDrop164 : Nat.ble (57716 + (PRE_first_tail_x15_r0_body.s1582.next - PRE_first_tail_x15_r0_body.s1583.next)) 57735 = true
kernel_rfl bodyDropH164 : Nat.ble (1097 + ((mlxOf PRE_first_tail_x15_r0_body.s1582.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s1583.ffi).next)) 1097 = true
kernel_rfl bodyDropN164 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s1582.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s1583.ffi).nnext)) 0 = true
kernel_rfl bodyDv164 : bodyΘ.1.take 873 = bodyΘ.1.take 873 ++ PRE_first_tail_x15_r0_body.cws164
kernel_rfl bodyDe164 : bodyΘ.2.take 873 = bodyΘ.2.take 873 ++ PRE_first_tail_x15_r0_body.nr164.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st164.S2.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 873) (bodyΘ.2.take 873)))
kernel_rfl bodyDl164 : (bodyΘ.1.take 873).length = (bodyΘ.2.take 873).length
kernel_rfl bodyDold164 : (bodyΘ.1.take 873).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws164).isNone && !PRE_first_tail_x15_r0_body.ws164.contains v) = true
kernel_rfl bodyDfree164 : (bodyΘ.2.take 873).all (fun e => (PRE_first_tail_x15_r0_body.cws164 ++ PRE_first_tail_x15_r0_body.ws164).all fun w => e.noVar w) = true

theorem bodyStep164 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨57716, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1581 PRE_first_tail_x15_r0_body.S1581)
      (bodyCut NB T tk π i x0 bodyΘ ⟨57735, 1097, 0, 873⟩ bodyM PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.S1583) (206 + 1) :=
  bodySite bodyFacts164.cfix bodyFacts164.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 206) (S2 := PRE_first_tail_x15_r0_body.st164.S2.tab) (Es := bodyEs164) (qs := bodyQs164)
    (ok := PRE_first_tail_x15_r0_body.st164.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site164 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts164
    (fun _ _ ν hm => good_of_row_enum
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site164 r hr) hi (MapOk.sub hm (sub_of_all bodySub164)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk164 r hr) hi hm ho hq)
    bodyLq164 rfl bodyNrLo164 (postSub_sound bodyPost164)
    (Nat.le_of_ble_eq_true bodyDrop164) (by decide) (Nat.le_of_ble_eq_true bodyDropH164) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN164) (by decide)
    bodyDv164 bodyDe164 bodyDl164 bodyDold164 bodyDfree164 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
