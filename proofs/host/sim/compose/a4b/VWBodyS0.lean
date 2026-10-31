import host.sim.compose.a4b.VWBodyJ0
import host.sim.compose.a4b.VWBodySite0
import host.sim.compose.a4b.VWBodyOracles_0
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteR0
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteD0
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteZ0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyFramesEmpty0 : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf PRE_first_tail_x15_r0_body.s15 a).isEmpty) = true
kernel_rfl bodyJsRoots0 : noBigRootsP (jsAboveB PRE_first_tail_x15_r0_body.s14.next) PRE_first_tail_x15_r0_body.s16.trace PRE_first_tail_x15_r0_body.s16 = true
kernel_rfl bodyJsNative0 : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x15_r0_body.s16.ffi) = true
kernel_rfl bodyLow0 : (PRE_first_tail_x15_r0_body.cws0 ++ PRE_first_tail_x15_r0_body.ws0).all (Nat.ble 9) = true
kernel_rfl bodySameH0 : (mlxOf PRE_first_tail_x15_r0_body.s15.ffi).next = (mlxOf PRE_first_tail_x15_r0_body.s16.ffi).next
kernel_rfl bodySameN0 : (mlxOf PRE_first_tail_x15_r0_body.s15.ffi).nnext = (mlxOf PRE_first_tail_x15_r0_body.s16.ffi).nnext
kernel_rfl bodyBridge0 : bridgeOf PRE_first_tail_x15_r0_body.s15.ffi = bridgeOf PRE_first_tail_x15_r0_body.s14.ffi
kernel_rfl bodyNN0 : Nat.ble (mlxOf PRE_first_tail_x15_r0_body.s14.ffi).nnext PRE_first_tail_x15_r0_body.P0.NL = true
kernel_rfl bodyXn0 : Nat.ble (⟨18197, 15296, 2674920, 101⟩ : Conv.Cnt).xn (mlxOf PRE_first_tail_x15_r0_body.s16.ffi).next = true
kernel_rfl bodyLo0 : Nat.ble setupP.lo (mlxOf PRE_first_tail_x15_r0_body.s16.ffi).next = true
kernel_rfl bodyStart2665 : arrOf PRE_first_tail_x15_r0_body.s0 2665 = []
kernel_rfl bodyStartChunk : arrOf PRE_first_tail_x15_r0_body.s0 VWFrames.chunk = []

theorem bodyFacts0 : BodySiteFacts PRE_first_tail_x15_r0_body.s14 PRE_first_tail_x15_r0_body.s15 PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S14 PRE_first_tail_x15_r0_body.S15 PRE_first_tail_x15_r0_body.S16
    PRE_first_tail_x15_r0_body.ws0 PRE_first_tail_x15_r0_body.cws0 PRE_first_tail_x15_r0_body.nr0 PRE_first_tail_x15_r0_body.pl0 PRE_first_tail_x15_r0_body.cl0 2676612 101 PRE_first_tail_x15_r0_body.kd0 PRE_first_tail_x15_r0_body.kappa0 PRE_first_tail_x15_r0_body.P0
    ⟨18189, 15254, 2674897, 83⟩ ⟨18197, 15296, 2674920, 101⟩ where
  zkap := PRE_first_tail_x15_r0_body.zkap0
  clean := bodyClean0
  cfix := PRE_first_tail_x15_r0_body.cfix0
  zpl := PRE_first_tail_x15_r0_body.zpl0
  zplnd := PRE_first_tail_x15_r0_body.zplnd0
  zn1 := PRE_first_tail_x15_r0_body.zn10
  zfirst := PRE_first_tail_x15_r0_body.zfirst0
  zscn := PRE_first_tail_x15_r0_body.zscn0
  zsmn := PRE_first_tail_x15_r0_body.zsmn0
  zgrow := PRE_first_tail_x15_r0_body.zgrow0
  mergeTab := PRE_first_tail_x15_r0_body.mergeTab0
  zfresh := PRE_first_tail_x15_r0_body.zfresh0
  zcnd := PRE_first_tail_x15_r0_body.zcnd0
  lenc := by rfl
  znrHi := PRE_first_tail_x15_r0_body.znrHi0
  zfrlt := PRE_first_tail_x15_r0_body.zfrlt0
  zgP := PRE_first_tail_x15_r0_body.zg0_2665
  zkP := PRE_first_tail_x15_r0_body.zk0_2665
  zmP := PRE_first_tail_x15_r0_body.zm0_2665
  zgC := PRE_first_tail_x15_r0_body.zg0_2673467
  zkC := PRE_first_tail_x15_r0_body.zk0_2673467
  zmC := PRE_first_tail_x15_r0_body.zm0_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := PRE_first_tail_x15_r0_body.zw0_2673472
  zwV := PRE_first_tail_x15_r0_body.zw0_2673473
  cheap := PRE_first_tail_x15_r0_body.cheap0
  zclbd := PRE_first_tail_x15_r0_body.zclbd0
  hml := hoff_of PRE_first_tail_x15_r0_body.mheap0 PRE_first_tail_x15_r0_body.stFoot0 PRE_first_tail_x15_r0_body.iso0 PRE_first_tail_x15_r0_body.zwr0
  ckeepP := PRE_first_tail_x15_r0_body.ckeepP0
  csupp := PRE_first_tail_x15_r0_body.csupp0
  cbound := PRE_first_tail_x15_r0_body.cbound0
  zimg := PRE_first_tail_x15_r0_body.zimg0
  zctl := PRE_first_tail_x15_r0_body.zctl0
  zstack := PRE_first_tail_x15_r0_body.zstack0
  zjobs := PRE_first_tail_x15_r0_body.zjobs0
  zstores := PRE_first_tail_x15_r0_body.zstores0
  zroots := PRE_first_tail_x15_r0_body.zroots0
  znC := PRE_first_tail_x15_r0_body.znC0
  ctab := PRE_first_tail_x15_r0_body.ctab0
  zbin := PRE_first_tail_x15_r0_body.zbin0
  cbridge := PRE_first_tail_x15_r0_body.cbridge0
  sbridge := bodyBridge0
  cwsDisj := PRE_first_tail_x15_r0_body.cwsDisj0
  cshiftR := fun h hNL => PRE_first_tail_x15_r0_body.cshiftR0 h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN0
  raised := PRE_first_tail_x15_r0_body.raised0
  cbigs := PRE_first_tail_x15_r0_body.cbigs0
  cjcl := PRE_first_tail_x15_r0_body.cjcl0
  xnLe := Nat.le_of_ble_eq_true bodyXn0
  loLe := Nat.le_of_ble_eq_true bodyLo0
  zroots2 := PRE_first_tail_x15_r0_body.zroots20
  sameH := bodySameH0
  sameN := bodySameN0
  jsHeap := bodyJs0
  jsRoots := bodyJsRoots0
  jsNative := bodyJsNative0
  framesEmpty := bodyFramesEmpty0
  inputOld := by decide
  lowVars := bodyLow0

def bodyQs0 : List (Option Q) := [some Q.n, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n, some Q.n, none, none, some Q.n, some Q.n, none, some Q.n, some Q.n, some Q.n, some Q.n]
noncomputable def bodyEs0 : List (Option SymE) := PRE_first_tail_x15_r0_body.nr0.map fun r => nth? PRE_first_tail_x15_r0_body.st0.S3.tab r
kernel_rfl bodyResChk0 : (fwdRows.all fun r =>
  resChkAll r Oracles.PRE_first_tail_x15_r0_body.map_g0 bodyEs0 bodyQs0) = true
kernel_rfl bodyLq0 : bodyQs0.length = PRE_first_tail_x15_r0_body.cws0.length
kernel_rfl bodyNrLo0 : PRE_first_tail_x15_r0_body.nr0.all (Nat.ble PRE_first_tail_x15_r0_body.S14.tab.length) = true
kernel_rfl bodyM00 : (Oracles.PRE_first_tail_x15_r0_body.map_g0.all fun p =>
  (Conv.idx? p.1 PRE_first_tail_x15_r0_body.cws0).isNone && !PRE_first_tail_x15_r0_body.ws0.contains p.1) = true
kernel_rfl bodySub0 : (Oracles.PRE_first_tail_x15_r0_body.map_site0.all fun p => Oracles.PRE_first_tail_x15_r0_body.map_g0.contains p) = true
kernel_rfl bodySubNext0 : postSubB Oracles.PRE_first_tail_x15_r0_body.map_g1 Oracles.PRE_first_tail_x15_r0_body.map_g0 PRE_first_tail_x15_r0_body.cws0 bodyQs0 = true
kernel_rfl bodyDrop0 : Nat.ble (3571 + (PRE_first_tail_x15_r0_body.s15.next - PRE_first_tail_x15_r0_body.s16.next)) 5263 = true

noncomputable def bodyD0 : Nat := 3571

theorem bodyStep0 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i 3571 Oracles.PRE_first_tail_x15_r0_body.map_g0 PRE_first_tail_x15_r0_body.s14 PRE_first_tail_x15_r0_body.S14)
      (bodyCut NB T tk π i 5263 Oracles.PRE_first_tail_x15_r0_body.map_g1 PRE_first_tail_x15_r0_body.s16 PRE_first_tail_x15_r0_body.S16) (17040 + 1) :=
  bodySite (n := 17040) (S2 := PRE_first_tail_x15_r0_body.st0.S3.tab) (Es := bodyEs0) (qs := bodyQs0)
    (ok := PRE_first_tail_x15_r0_body.st0.bodyOkL)
    (fun bs rows => Host.Ts.Sim.Compose.PRE_first_tail_x15_r0_body.site0 bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts0
    (fun _ _ ν hm => good_of_row
      (List.all_eq_true.mp Oracles.PRE_first_tail_x15_r0_body.chk_site0 r hr) hi (MapOk.sub hm (sub_of_all bodySub0)))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk0 r hr) hi hm ho hq)
    bodyLq0 rfl bodyNrLo0 (m0_of_all bodyM00) (postSub_sound bodySubNext0)
    (Nat.le_of_ble_eq_true bodyDrop0) (by decide)

end Host.Ts.Sim.Compose.VWFirst
