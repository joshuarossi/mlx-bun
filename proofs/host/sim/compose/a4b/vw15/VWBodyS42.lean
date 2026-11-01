import host.sim.compose.a4b.vw15.VWBodyJ42
import host.sim.compose.a4b.vw15.VWBodySite42
import host.sim.compose.a4b.vw15.VWBodyOracles_10
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

theorem bodyCshift42 {BR : Map → Host.Ts.Sim.Full.FF.S → Host.Ts.Sim.Full.FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map}
    {y : Host.Ts.Sim.Full.FF.S} (h : Host.Ts.Sim.Full.FullRB BR P NB M PRE_first_tail_x15_r0_body.S419.tab.length PRE_first_tail_x15_r0_body.s419.ffi y)
    (hNL : P.NL ≤ PRE_first_tail_x15_r0_body.P42.NL) : Conv.FullShiftQ PRE_first_tail_x15_r0_body.P42 1898 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.s421.ffi PRE_first_tail_x15_r0_body.s420.ffi := by
  have hr := h.load.mlx
  obtain ⟨_, _, hF⟩ := h.live _ PRE_first_tail_x15_r0_body.ofxC_42
  obtain ⟨_, _, hK⟩ := h.kern _ PRE_first_tail_x15_r0_body.okrC_42
  have hcl : SSt (· < 1898) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s421.ffi).mlx :=
    sst_of_callK (n0 := PRE_first_tail_x15_r0_body.S419.tab.length) hr.cl (by rw [PRE_first_tail_x15_r0_body.n0_42] <;> decide) PRE_first_tail_x15_r0_body.cnodesK42 PRE_first_tail_x15_r0_body.cobjsK42
      PRE_first_tail_x15_r0_body.citemsK42 PRE_first_tail_x15_r0_body.cbd42 PRE_first_tail_x15_r0_body.csst42
  exact PRE_first_tail_x15_r0_body.cshift42 bodyNcl42 hr.hlt hr.nlt (fun k v hg => hr.itemsPresent k (by rw [hg]; rfl))
    (fun h o hg i hi => Nat.lt_of_lt_of_le (hr.traced h o hg i hi) hNL) (sst_clear hcl) hF.obj hK.flagsObj hK.targsObj
    (fun h l hl => by have := hK.cl h l hl; rw [PRE_first_tail_x15_r0_body.n0_42] at this; exact this)


kernel_rfl bodyFramesEmpty42 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s420 a).isEmpty) = true
kernel_rfl bodyJsRoots42 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s419.next) PRE_first_tail_x15_r0_body.s421.trace PRE_first_tail_x15_r0_body.s421 = true
kernel_rfl bodyJsNative42 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s421.ffi) = true
kernel_rfl bodyLow42 : (PRE_first_tail_x15_r0_body.cws42 ++ PRE_first_tail_x15_r0_body.ws42).all (Nat.ble 9) = true
kernel_rfl bodyCntM42 : countersOkB PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.s420 = true
kernel_rfl bodyHi42 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next setupP.E = true
kernel_rfl bodyNhi42 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge42 : bridgeOf PRE_first_tail_x15_r0_body.s420.ffi = bridgeOf PRE_first_tail_x15_r0_body.s419.ffi
kernel_rfl bodyNN42 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s419.ffi).nnext PRE_first_tail_x15_r0_body.P42.NL = true
kernel_rfl bodyXn42 : Nat.ble (⟨19041, 16142, 2708225, 1898⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next = true
kernel_rfl bodyLo42 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next = true
theorem bodyFacts42 : BodySiteFacts PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.s420 PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S419 PRE_first_tail_x15_r0_body.S420 PRE_first_tail_x15_r0_body.S421
    PRE_first_tail_x15_r0_body.ws42 PRE_first_tail_x15_r0_body.cws42 PRE_first_tail_x15_r0_body.nr42 PRE_first_tail_x15_r0_body.pl42 PRE_first_tail_x15_r0_body.cl42 2709374 1898 PRE_first_tail_x15_r0_body.kd42 PRE_first_tail_x15_r0_body.kappa42 PRE_first_tail_x15_r0_body.P42
    ⟨19038, 16115, 2708219, 1880⟩ ⟨19041, 16142, 2708225, 1898⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap42
  clean := bodyClean42
  cfix := PRE_first_tail_x15_r0_body.cfix42
  zpl := PRE_first_tail_x15_r0_body.zpl42
  zplnd := PRE_first_tail_x15_r0_body.zplnd42
  zn1 := PRE_first_tail_x15_r0_body.zn142
  zfirst := PRE_first_tail_x15_r0_body.zfirst42
  zscn := PRE_first_tail_x15_r0_body.zscn42
  zsmn := PRE_first_tail_x15_r0_body.zsmn42
  zgrow := PRE_first_tail_x15_r0_body.zgrow42
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab42
  zfresh := PRE_first_tail_x15_r0_body.zfresh42
  zcnd := PRE_first_tail_x15_r0_body.zcnd42
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi42
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt42
  zgP := PRE_first_tail_x15_r0_body.zg42_2665
  zkP := PRE_first_tail_x15_r0_body.zk42_2665
  zmP := PRE_first_tail_x15_r0_body.zm42_2665
  zgC := PRE_first_tail_x15_r0_body.zg42_2673467
  zkC := PRE_first_tail_x15_r0_body.zk42_2673467
  zmC := PRE_first_tail_x15_r0_body.zm42_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw42_2673472
  zwV := PRE_first_tail_x15_r0_body.zw42_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap42
  zclbd := PRE_first_tail_x15_r0_body.zclbd42
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap42 PRE_first_tail_x15_r0_body.stFoot42 PRE_first_tail_x15_r0_body.iso42 PRE_first_tail_x15_r0_body.zwr42
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP42
  csupp := PRE_first_tail_x15_r0_body.csupp42
  cbound := PRE_first_tail_x15_r0_body.cbound42
  zimg := PRE_first_tail_x15_r0_body.zimg42
  zctl := PRE_first_tail_x15_r0_body.zctl42
  zstack := PRE_first_tail_x15_r0_body.zstack42
  zjobs := PRE_first_tail_x15_r0_body.zjobs42
  zstores := PRE_first_tail_x15_r0_body.zstores42
  zroots := PRE_first_tail_x15_r0_body.zroots42
  znC := PRE_first_tail_x15_r0_body.znC42
  ctab := PRE_first_tail_x15_r0_body.ctab42
  zbin := PRE_first_tail_x15_r0_body.zbin42
  cbridge := PRE_first_tail_x15_r0_body.cbridge42
  sbridge := bodyBridge42
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj42
  cshiftR := fun h hNL => bodyCshift42 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN42
  raised := PRE_first_tail_x15_r0_body.raised42
  cbigs := PRE_first_tail_x15_r0_body.cbigs42
  cjcl := PRE_first_tail_x15_r0_body.cjcl42
  xnLe := Nat.le_of_ble_eq_true bodyXn42
  loLe := Nat.le_of_ble_eq_true bodyLo42
  zroots2 := PRE_first_tail_x15_r0_body.zrootsB42
  cntM := bodyCntM42
  hiLe := Nat.le_of_ble_eq_true bodyHi42
  nhiLe := Nat.le_of_ble_eq_true bodyNhi42
  jsHeap := bodyJs42
  jsRoots := bodyJsRoots42
  jsNative := bodyJsNative42
  framesEmpty := bodyFramesEmpty42
  trailOld := by decide
  lowVars := bodyLow42

def bodyQs42 : List (Option Q) := [some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs42 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr42.map fun r => nth? PRE_first_tail_x15_r0_body.st42.S5.tab r
kernel_rfl bodyResChk42 : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs42 bodyQs42) = true
kernel_rfl bodyLq42 : bodyQs42.length = PRE_first_tail_x15_r0_body.cws42.length
kernel_rfl bodyNrLo42 : PRE_first_tail_x15_r0_body.nr42.all (Nat.ble PRE_first_tail_x15_r0_body.S419.tab.length) = true
kernel_rfl bodySub42 : (Oracles.PRE_first_tail_x15_r0_body.map_site42.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost42 : postSubB bodyM PRE_first_tail_x15_r0_body.ws42 PRE_first_tail_x15_r0_body.cws42 bodyQs42 = true
kernel_rfl bodyDrop42 : Nat.ble (17998 + (PRE_first_tail_x15_r0_body.s420.next - PRE_first_tail_x15_r0_body.s421.next)) 19147 = true
kernel_rfl bodyDropH42 : Nat.ble (302 + ((mlxOf PRE_first_tail_x15_r0_body.s420.ffi).next - (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).next)) 327 = true
kernel_rfl bodyDropN42 : Nat.ble (0 + ((mlxOf PRE_first_tail_x15_r0_body.s420.ffi).nnext - (mlxOf PRE_first_tail_x15_r0_body.s421.ffi).nnext)) 0 = true
kernel_rfl bodyDv42 : bodyΘ.1.take 243 = bodyΘ.1.take 225 ++ PRE_first_tail_x15_r0_body.cws42
kernel_rfl bodyDe42 : bodyΘ.2.take 243 = bodyΘ.2.take 225 ++ PRE_first_tail_x15_r0_body.nr42.map (fun r =>
  ((nth? PRE_first_tail_x15_r0_body.st42.S5.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take 225) (bodyΘ.2.take 225)))
kernel_rfl bodyDl42 : (bodyΘ.1.take 225).length = (bodyΘ.2.take 225).length
kernel_rfl bodyDold42 : (bodyΘ.1.take 225).all (fun v => (Conv.idx? v PRE_first_tail_x15_r0_body.cws42).isNone && !PRE_first_tail_x15_r0_body.ws42.contains v) = true
kernel_rfl bodyDfree42 : (bodyΘ.2.take 243).all (fun e => (PRE_first_tail_x15_r0_body.cws42 ++ PRE_first_tail_x15_r0_body.ws42).all fun w => e.noVar w) = true

theorem bodyStep42 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17998, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s419 PRE_first_tail_x15_r0_body.S419)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19147, 327, 0, 243⟩ bodyM PRE_first_tail_x15_r0_body.s421 PRE_first_tail_x15_r0_body.S421) (11334 + 1) :=
  bodySite bodyFacts42.cfix bodyFacts42.trailOld fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := 11334) (S2 := PRE_first_tail_x15_r0_body.st42.S5.tab) (Es := bodyEs42) (qs := bodyQs42)
    (ok := PRE_first_tail_x15_r0_body.st42.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site42 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts42
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site42 r hr) hi (MapOk.sub hm (sub_of_all bodySub42)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk42 r hr) hi hm ho hq)
    bodyLq42 rfl bodyNrLo42 (postSub_sound bodyPost42)
    (Nat.le_of_ble_eq_true bodyDrop42) (by decide) (Nat.le_of_ble_eq_true bodyDropH42) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN42) (by decide)
    bodyDv42 bodyDe42 bodyDl42 bodyDold42 bodyDfree42 hR hB

end Host.Ts.Sim.Compose.VWFirst.VW15
