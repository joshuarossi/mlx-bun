import host.sim.compose.a4b.FixedEnds
import host.sim.compose.a4b.Fill_DEC_clearGrow
import host.sim.compose.StartBounded

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case `clearGrow`'s pieces from chain `DEC_clearGrow`** at the prompt route's instance (`addrPrompt`, `wideP`, the
frames `framesP DEC_clearGrow.s0 q`, `fixP`), A4's end (`DEC_clearGrow.iterEnd`). -/
noncomputable def DEC_clearGrow.piecesFixed (q : List Val) (R : DEC_clearGrow.Runs)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : 151312 ≤ ΔJ) (hdH : 3867 ≤ ΔH) (hdN : 4882 ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).next + T * ΔH + B.H + (DEC_clearGrow.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).nnext + T * ΔN + B.N + (DEC_clearGrow.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).nnext) < 2 ^ 62) :
    DecPieces_DEC_clearGrow (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_clearGrow.Pw (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T (DEC_clearGrow.endFixed b0 NB) (DEC_clearGrow.g3 b0 NB DEC_clearGrow.eN) :=
  let θ := Host.Load.Run.Tpl.DEC_clearGrow.θ
  let hW := DEC_clearGrow.hW
  let Gw : DEC_clearGrow.Grow b0 NB Template.wideP := DEC_clearGrow.grow R hW
  { c1 := (fun i x0 => bdCut b0 NB DEC_clearGrow.Pw DEC_clearGrow.fr DEC_clearGrow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) Host.Load.Run.Tpl.DEC_clearGrow.s0) DEC_clearGrow.m0 Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0 i x0)
    c2 := (fun i x0 => bdCut b0 NB DEC_clearGrow.Pw DEC_clearGrow.fr DEC_clearGrow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_clearGrow.g1 b0 NB DEC_clearGrow.eN) DEC_clearGrow.m0 Host.Load.Run.Tpl.DEC_clearGrow.s2 Host.Load.Run.Tpl.DEC_clearGrow.S2 i x0)
    c3 := (fun i x0 => bdCut b0 NB DEC_clearGrow.Pw DEC_clearGrow.fr DEC_clearGrow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_clearGrow.g1 b0 NB DEC_clearGrow.eN) DEC_clearGrow.m0 Host.Load.Run.Tpl.DEC_clearGrow.s4 Host.Load.Run.Tpl.DEC_clearGrow.S4 i x0)
    c4 := (fun i x0 => bdCut b0 NB DEC_clearGrow.Pw DEC_clearGrow.fr DEC_clearGrow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_clearGrow.g2 b0 NB DEC_clearGrow.eN) DEC_clearGrow.m1 Host.Load.Run.Tpl.DEC_clearGrow.s6 Host.Load.Run.Tpl.DEC_clearGrow.S6 i x0)
    c5 := (fun i x0 => bdCut b0 NB DEC_clearGrow.Pw DEC_clearGrow.fr DEC_clearGrow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_clearGrow.g2 b0 NB DEC_clearGrow.eN) DEC_clearGrow.m1 Host.Load.Run.Tpl.DEC_clearGrow.s8 Host.Load.Run.Tpl.DEC_clearGrow.S8 i x0)
    c6 := (fun i x0 => bdCut b0 NB DEC_clearGrow.Pw DEC_clearGrow.fr DEC_clearGrow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_clearGrow.g3 b0 NB DEC_clearGrow.eN) DEC_clearGrow.m1 Host.Load.Run.Tpl.DEC_clearGrow.s10 Host.Load.Run.Tpl.DEC_clearGrow.S10 i x0)
    start := startLinkBounded [] (by decide +kernel) rfl rfl (DEC_clearGrow.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    rb__start__g1 := callLink Host.Load.Run.Tpl.DEC_clearGrow.st0.tpl Host.Load.Run.Tpl.DEC_clearGrow.st0.O hW DEC_clearGrow.chk0 Host.Load.Run.Tpl.DEC_clearGrow.srvO0 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_clearGrow.iso0) (htab := Host.Load.Run.Tpl.DEC_clearGrow.tab0_0) (hfoot := Host.Load.Run.Tpl.DEC_clearGrow.stFoot0) (hnd := Host.Load.Run.Tpl.DEC_clearGrow.wrNodup0)
      (hbd := Host.Load.Run.Tpl.DEC_clearGrow.wrBound0) (htr := Host.Load.Run.Tpl.DEC_clearGrow.trace0) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clearGrow.merged0) (hmtab := Host.Load.Run.Tpl.DEC_clearGrow.mergeTab0)
      (hwsl := DEC_clearGrow.wsl0) (hwsnd := (Template.nodupT_sound DEC_clearGrow.wsnd0).2) (hfresh := noVar_of_all DEC_clearGrow.fresh0)
      (hlen := Nat.le_of_ble_eq_true DEC_clearGrow.len0) (hgtab := noVar_nth_of_all DEC_clearGrow.gtab0)
      (hgθ := noVarθ_nth_of_all DEC_clearGrow.gth0)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clearGrow.st0.tpl Host.Load.Run.Tpl.DEC_clearGrow.iso0 Host.Load.Run.Tpl.DEC_clearGrow.stFoot0 Host.Load.Run.Tpl.DEC_clearGrow.wrNodup0 Host.Load.Run.Tpl.DEC_clearGrow.wrBound0 Host.Load.Run.Tpl.DEC_clearGrow.trace0)
      (hctab := Host.Load.Run.Tpl.DEC_clearGrow.ctab0) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clearGrow.cwsDisj0) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clearGrow.ctab0 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clearGrow.zkap0
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearGrow.jcl0) Host.Load.Run.Tpl.DEC_clearGrow.cfix0 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clearGrow.zpl0 Host.Load.Run.Tpl.DEC_clearGrow.zplnd0 Host.Load.Run.Tpl.DEC_clearGrow.zn10 Host.Load.Run.Tpl.DEC_clearGrow.zfirst0 Host.Load.Run.Tpl.DEC_clearGrow.zscn0 Host.Load.Run.Tpl.DEC_clearGrow.zsmn0 Host.Load.Run.Tpl.DEC_clearGrow.zgrow0 Host.Load.Run.Tpl.DEC_clearGrow.mergeTab0
        Host.Load.Run.Tpl.DEC_clearGrow.zfresh0 Host.Load.Run.Tpl.DEC_clearGrow.zcnd0 DEC_clearGrow.lenc0 Host.Load.Run.Tpl.DEC_clearGrow.znrHi0 Host.Load.Run.Tpl.DEC_clearGrow.znC0 Host.Load.Run.Tpl.DEC_clearGrow.zfrlt0 xs_wideP wfr_wideP (hX_framesP DEC_clearGrow.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_clearGrow.zg0_2673448, Host.Load.Run.Tpl.DEC_clearGrow.zk0_2673448, Host.Load.Run.Tpl.DEC_clearGrow.zm0_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_clearGrow.zg0_12504, Host.Load.Run.Tpl.DEC_clearGrow.zk0_12504, Host.Load.Run.Tpl.DEC_clearGrow.zm0_12504⟩, ⟨Host.Load.Run.Tpl.DEC_clearGrow.zg0_2665, Host.Load.Run.Tpl.DEC_clearGrow.zk0_2665, Host.Load.Run.Tpl.DEC_clearGrow.zm0_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_clearGrow.zw0_4910) wf_wideP Host.Load.Run.Tpl.DEC_clearGrow.zclbd0 Host.Load.Run.Tpl.DEC_clearGrow.cheap0
        (hoff_of Host.Load.Run.Tpl.DEC_clearGrow.mheap0 Host.Load.Run.Tpl.DEC_clearGrow.stFoot0 Host.Load.Run.Tpl.DEC_clearGrow.iso0 Host.Load.Run.Tpl.DEC_clearGrow.zwr0) Host.Load.Run.Tpl.DEC_clearGrow.ckeepP0 Host.Load.Run.Tpl.DEC_clearGrow.csupp0 Host.Load.Run.Tpl.DEC_clearGrow.cbound0 Host.Load.Run.Tpl.DEC_clearGrow.zimg0
        Host.Load.Run.Tpl.DEC_clearGrow.zctl0 Host.Load.Run.Tpl.DEC_clearGrow.zstack0 Host.Load.Run.Tpl.DEC_clearGrow.zjobs0 Host.Load.Run.Tpl.DEC_clearGrow.zstores0 Host.Load.Run.Tpl.DEC_clearGrow.zroots0 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clearGrow.cshiftR0 h rfl)
      (hbig := DEC_clearGrow.big0) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearGrow.jcl2)
        (Nat.le_of_ble_eq_true DEC_clearGrow.xn0) (by decide) Host.Load.Run.Tpl.DEC_clearGrow.zroots20)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clearGrow.bandLo0) (Nat.le_of_ble_eq_true DEC_clearGrow.bandHi) (by decide))
      (hκn := compact_num_of DEC_clearGrow.kn0) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_clearGrow.kappa0 (compact_fix_of DEC_clearGrow.ka0) DEC.FixedCells.clearGrow_kappa0_2586 DEC.FixedCells.clearGrow_kappa0_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clearGrow.cfix0 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clearGrow.zhm0))
      (hfwd := Host.Load.Run.Tpl.DEC_clearGrow.arr0_2673448) (hemit := Host.Load.Run.Tpl.DEC_clearGrow.arr0_12504) (hkeep := Host.Load.Run.Tpl.DEC_clearGrow.keep0 q)
      (heN := Host.Load.Run.Tpl.DEC_clearGrow.arrR0_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clearGrow.cJm0) (hJc := Nat.le_of_ble_eq_true DEC_clearGrow.cJc0)
      (hH := Nat.le_of_ble_eq_true DEC_clearGrow.cHm0) (hHE := Nat.blt_eq.mp DEC_clearGrow.cHE0)
      (hN := Nat.le_of_ble_eq_true DEC_clearGrow.cNm0) (hm0 := m0_of_all DEC_clearGrow.m0_0) (hndc := (Template.nodupT_sound DEC_clearGrow.ndc0).2)
      (hlenc := DEC_clearGrow.lenc0) (hnrLo := DEC_clearGrow.nrLo0) (hder := rfl)
      (qs := DEC_clearGrow.qs0) (hlq := DEC_clearGrow.lq0) (hEs := hEs_of_allC dec_clearGrow.capRow (by decide) (by decide) DEC_clearGrow.dq0)
      (hq := qs_leC dec_clearGrow.capRow DEC_clearGrow.qsOk0) (hR' := sub_of_all DEC_clearGrow.R'0)
      (dJ := 151312) (dH := 3867) (dN := 4882) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clearGrow.cRJ0) (hcH := Nat.le_of_ble_eq_true DEC_clearGrow.cRH0)
      (hcN := Nat.le_of_ble_eq_true DEC_clearGrow.cRN0) (hs0E := Nat.le_of_ble_eq_true DEC_clearGrow.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clearGrow.scE0) (hs0N := Nat.le_of_ble_eq_true DEC_clearGrow.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clearGrow.scN0)
    g1 := glueLinkCall (List.drop 0 Host.Load.Run.Tpl.DEC_clearGrow.O) hW DEC_clearGrow.chk_g1 DEC_clearGrow.srv2 DEC_clearGrow.ok2 R.runSeg1
      (runOk_ok_end 915 R.runSeg1 DEC_clearGrow.halt3) DEC_clearGrow.halt3 R.stepA2 DEC_clearGrow.top4
      (Nat.le_of_ble_eq_true DEC_clearGrow.len2) (fun _ h => h) Gw.g1
    fwd_D1_warm_DGrow__g1__g2 := callLink Host.Load.Run.Tpl.DEC_clearGrow.st1.tpl Host.Load.Run.Tpl.DEC_clearGrow.st1.O hW DEC_clearGrow.chk1 Host.Load.Run.Tpl.DEC_clearGrow.srvO1 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_clearGrow.iso1) (htab := Host.Load.Run.Tpl.DEC_clearGrow.tab0_1) (hfoot := Host.Load.Run.Tpl.DEC_clearGrow.stFoot1) (hnd := Host.Load.Run.Tpl.DEC_clearGrow.wrNodup1)
      (hbd := Host.Load.Run.Tpl.DEC_clearGrow.wrBound1) (htr := Host.Load.Run.Tpl.DEC_clearGrow.trace1) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clearGrow.merged1) (hmtab := Host.Load.Run.Tpl.DEC_clearGrow.mergeTab1)
      (hwsl := DEC_clearGrow.wsl1) (hwsnd := (Template.nodupT_sound DEC_clearGrow.wsnd1).2) (hfresh := noVar_of_all DEC_clearGrow.fresh1)
      (hlen := Nat.le_of_ble_eq_true DEC_clearGrow.len4) (hgtab := noVar_nth_of_all DEC_clearGrow.gtab1)
      (hgθ := noVarθ_nth_of_all DEC_clearGrow.gth1)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clearGrow.st1.tpl Host.Load.Run.Tpl.DEC_clearGrow.iso1 Host.Load.Run.Tpl.DEC_clearGrow.stFoot1 Host.Load.Run.Tpl.DEC_clearGrow.wrNodup1 Host.Load.Run.Tpl.DEC_clearGrow.wrBound1 Host.Load.Run.Tpl.DEC_clearGrow.trace1)
      (hctab := Host.Load.Run.Tpl.DEC_clearGrow.ctab1) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clearGrow.cwsDisj1) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clearGrow.ctab1 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clearGrow.zkap1
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearGrow.jcl4) Host.Load.Run.Tpl.DEC_clearGrow.cfix1 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clearGrow.zpl1 Host.Load.Run.Tpl.DEC_clearGrow.zplnd1 Host.Load.Run.Tpl.DEC_clearGrow.zn11 Host.Load.Run.Tpl.DEC_clearGrow.zfirst1 Host.Load.Run.Tpl.DEC_clearGrow.zscn1 Host.Load.Run.Tpl.DEC_clearGrow.zsmn1 Host.Load.Run.Tpl.DEC_clearGrow.zgrow1 Host.Load.Run.Tpl.DEC_clearGrow.mergeTab1
        Host.Load.Run.Tpl.DEC_clearGrow.zfresh1 Host.Load.Run.Tpl.DEC_clearGrow.zcnd1 DEC_clearGrow.lenc1 Host.Load.Run.Tpl.DEC_clearGrow.znrHi1 Host.Load.Run.Tpl.DEC_clearGrow.znC1 Host.Load.Run.Tpl.DEC_clearGrow.zfrlt1 xs_wideP wfr_wideP (hX_framesP DEC_clearGrow.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_clearGrow.zg1_2673448, Host.Load.Run.Tpl.DEC_clearGrow.zk1_2673448, Host.Load.Run.Tpl.DEC_clearGrow.zm1_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_clearGrow.zg1_12504, Host.Load.Run.Tpl.DEC_clearGrow.zk1_12504, Host.Load.Run.Tpl.DEC_clearGrow.zm1_12504⟩, ⟨Host.Load.Run.Tpl.DEC_clearGrow.zg1_2665, Host.Load.Run.Tpl.DEC_clearGrow.zk1_2665, Host.Load.Run.Tpl.DEC_clearGrow.zm1_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_clearGrow.zw1_4910) wf_wideP Host.Load.Run.Tpl.DEC_clearGrow.zclbd1 Host.Load.Run.Tpl.DEC_clearGrow.cheap1
        (hoff_of Host.Load.Run.Tpl.DEC_clearGrow.mheap1 Host.Load.Run.Tpl.DEC_clearGrow.stFoot1 Host.Load.Run.Tpl.DEC_clearGrow.iso1 Host.Load.Run.Tpl.DEC_clearGrow.zwr1) Host.Load.Run.Tpl.DEC_clearGrow.ckeepP1 Host.Load.Run.Tpl.DEC_clearGrow.csupp1 Host.Load.Run.Tpl.DEC_clearGrow.cbound1 Host.Load.Run.Tpl.DEC_clearGrow.zimg1
        Host.Load.Run.Tpl.DEC_clearGrow.zctl1 Host.Load.Run.Tpl.DEC_clearGrow.zstack1 Host.Load.Run.Tpl.DEC_clearGrow.zjobs1 Host.Load.Run.Tpl.DEC_clearGrow.zstores1 Host.Load.Run.Tpl.DEC_clearGrow.zroots1 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clearGrow.cshiftR1 h rfl)
      (hbig := DEC_clearGrow.big1) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearGrow.jcl6)
        (Nat.le_of_ble_eq_true DEC_clearGrow.xn1) (by decide) Host.Load.Run.Tpl.DEC_clearGrow.zroots21)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clearGrow.bandLo1) (Nat.le_of_ble_eq_true DEC_clearGrow.bandHi) (by decide))
      (hκn := compact_num_of DEC_clearGrow.kn1) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_clearGrow.kappa1 (compact_fix_of DEC_clearGrow.ka1) DEC.FixedCells.clearGrow_kappa1_2586 DEC.FixedCells.clearGrow_kappa1_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clearGrow.cfix1 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clearGrow.zhm1))
      (hfwd := Host.Load.Run.Tpl.DEC_clearGrow.arr1_2673448) (hemit := Host.Load.Run.Tpl.DEC_clearGrow.arr1_12504) (hkeep := Host.Load.Run.Tpl.DEC_clearGrow.keep1 q)
      (heN := Host.Load.Run.Tpl.DEC_clearGrow.arrR1_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clearGrow.cJm1) (hJc := Nat.le_of_ble_eq_true DEC_clearGrow.cJc1)
      (hH := Nat.le_of_ble_eq_true DEC_clearGrow.cHm1) (hHE := Nat.blt_eq.mp DEC_clearGrow.cHE1)
      (hN := Nat.le_of_ble_eq_true DEC_clearGrow.cNm1) (hm0 := m0_of_all DEC_clearGrow.m0_1) (hndc := (Template.nodupT_sound DEC_clearGrow.ndc1).2)
      (hlenc := DEC_clearGrow.lenc1) (hnrLo := DEC_clearGrow.nrLo1) (hder := rfl)
      (qs := DEC_clearGrow.qs1) (hlq := DEC_clearGrow.lq1) (hEs := hEs_of_allC dec_clearGrow.capRow (by decide) (by decide) DEC_clearGrow.dq1)
      (hq := qs_leC dec_clearGrow.capRow DEC_clearGrow.qsOk1) (hR' := sub_of_all DEC_clearGrow.R'1)
      (dJ := 151312) (dH := 3867) (dN := 4882) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clearGrow.cRJ1) (hcH := Nat.le_of_ble_eq_true DEC_clearGrow.cRH1)
      (hcN := Nat.le_of_ble_eq_true DEC_clearGrow.cRN1) (hs0E := Nat.le_of_ble_eq_true DEC_clearGrow.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clearGrow.scE1) (hs0N := Nat.le_of_ble_eq_true DEC_clearGrow.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clearGrow.scN1)
    g2 := glueLinkCall (List.drop 5 Host.Load.Run.Tpl.DEC_clearGrow.O) hW DEC_clearGrow.chk_g2 DEC_clearGrow.srv6 DEC_clearGrow.ok6 R.runSeg2
      (runOk_ok_end 3657 R.runSeg2 DEC_clearGrow.halt7) DEC_clearGrow.halt7 R.stepA3 DEC_clearGrow.top8
      (Nat.le_of_ble_eq_true DEC_clearGrow.len6) (fun _ h => h) Gw.g2
    async__g2__g3 := callLink Host.Load.Run.Tpl.DEC_clearGrow.st2.tpl Host.Load.Run.Tpl.DEC_clearGrow.st2.O hW DEC_clearGrow.chk2 Host.Load.Run.Tpl.DEC_clearGrow.srvO2 (by decide +kernel)
      (hs0 := Host.Load.Run.Tpl.DEC_clearGrow.iso2) (htab := Host.Load.Run.Tpl.DEC_clearGrow.tab0_2) (hfoot := Host.Load.Run.Tpl.DEC_clearGrow.stFoot2) (hnd := Host.Load.Run.Tpl.DEC_clearGrow.wrNodup2)
      (hbd := Host.Load.Run.Tpl.DEC_clearGrow.wrBound2) (htr := Host.Load.Run.Tpl.DEC_clearGrow.trace2) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clearGrow.merged2) (hmtab := Host.Load.Run.Tpl.DEC_clearGrow.mergeTab2)
      (hwsl := DEC_clearGrow.wsl2) (hwsnd := (Template.nodupT_sound DEC_clearGrow.wsnd2).2) (hfresh := noVar_of_all DEC_clearGrow.fresh2)
      (hlen := Nat.le_of_ble_eq_true DEC_clearGrow.len8) (hgtab := noVar_nth_of_all DEC_clearGrow.gtab2)
      (hgθ := noVarθ_nth_of_all DEC_clearGrow.gth2)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clearGrow.st2.tpl Host.Load.Run.Tpl.DEC_clearGrow.iso2 Host.Load.Run.Tpl.DEC_clearGrow.stFoot2 Host.Load.Run.Tpl.DEC_clearGrow.wrNodup2 Host.Load.Run.Tpl.DEC_clearGrow.wrBound2 Host.Load.Run.Tpl.DEC_clearGrow.trace2)
      (hctab := Host.Load.Run.Tpl.DEC_clearGrow.ctab2) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clearGrow.cwsDisj2) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clearGrow.ctab2 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clearGrow.zkap2
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearGrow.jcl8) Host.Load.Run.Tpl.DEC_clearGrow.cfix2 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clearGrow.zpl2 Host.Load.Run.Tpl.DEC_clearGrow.zplnd2 Host.Load.Run.Tpl.DEC_clearGrow.zn12 Host.Load.Run.Tpl.DEC_clearGrow.zfirst2 Host.Load.Run.Tpl.DEC_clearGrow.zscn2 Host.Load.Run.Tpl.DEC_clearGrow.zsmn2 Host.Load.Run.Tpl.DEC_clearGrow.zgrow2 Host.Load.Run.Tpl.DEC_clearGrow.mergeTab2
        Host.Load.Run.Tpl.DEC_clearGrow.zfresh2 Host.Load.Run.Tpl.DEC_clearGrow.zcnd2 DEC_clearGrow.lenc2 Host.Load.Run.Tpl.DEC_clearGrow.znrHi2 Host.Load.Run.Tpl.DEC_clearGrow.znC2 Host.Load.Run.Tpl.DEC_clearGrow.zfrlt2 xs_wideP wfr_wideP (hX_framesP DEC_clearGrow.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_clearGrow.zg2_2673448, Host.Load.Run.Tpl.DEC_clearGrow.zk2_2673448, Host.Load.Run.Tpl.DEC_clearGrow.zm2_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_clearGrow.zg2_12504, Host.Load.Run.Tpl.DEC_clearGrow.zk2_12504, Host.Load.Run.Tpl.DEC_clearGrow.zm2_12504⟩, ⟨Host.Load.Run.Tpl.DEC_clearGrow.zg2_2665, Host.Load.Run.Tpl.DEC_clearGrow.zk2_2665, Host.Load.Run.Tpl.DEC_clearGrow.zm2_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_clearGrow.zw2_4910) wf_wideP Host.Load.Run.Tpl.DEC_clearGrow.zclbd2 Host.Load.Run.Tpl.DEC_clearGrow.cheap2
        (hoff_of Host.Load.Run.Tpl.DEC_clearGrow.mheap2 Host.Load.Run.Tpl.DEC_clearGrow.stFoot2 Host.Load.Run.Tpl.DEC_clearGrow.iso2 Host.Load.Run.Tpl.DEC_clearGrow.zwr2) Host.Load.Run.Tpl.DEC_clearGrow.ckeepP2 Host.Load.Run.Tpl.DEC_clearGrow.csupp2 Host.Load.Run.Tpl.DEC_clearGrow.cbound2 Host.Load.Run.Tpl.DEC_clearGrow.zimg2
        Host.Load.Run.Tpl.DEC_clearGrow.zctl2 Host.Load.Run.Tpl.DEC_clearGrow.zstack2 Host.Load.Run.Tpl.DEC_clearGrow.zjobs2 Host.Load.Run.Tpl.DEC_clearGrow.zstores2 Host.Load.Run.Tpl.DEC_clearGrow.zroots2 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clearGrow.cshiftR2 h rfl)
      (hbig := DEC_clearGrow.big2) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearGrow.jcl10)
        (Nat.le_of_ble_eq_true DEC_clearGrow.xn2) (by decide) Host.Load.Run.Tpl.DEC_clearGrow.zroots22)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clearGrow.bandLo2) (Nat.le_of_ble_eq_true DEC_clearGrow.bandHi) (by decide))
      (hκn := compact_num_of DEC_clearGrow.kn2) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_clearGrow.kappa2 (compact_fix_of DEC_clearGrow.ka2) DEC.FixedCells.clearGrow_kappa2_2586 DEC.FixedCells.clearGrow_kappa2_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clearGrow.cfix2 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clearGrow.zhm2))
      (hfwd := Host.Load.Run.Tpl.DEC_clearGrow.arr2_2673448) (hemit := Host.Load.Run.Tpl.DEC_clearGrow.arr2_12504) (hkeep := Host.Load.Run.Tpl.DEC_clearGrow.keep2 q)
      (heN := Host.Load.Run.Tpl.DEC_clearGrow.arrR2_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clearGrow.cJm2) (hJc := Nat.le_of_ble_eq_true DEC_clearGrow.cJc2)
      (hH := Nat.le_of_ble_eq_true DEC_clearGrow.cHm2) (hHE := Nat.blt_eq.mp DEC_clearGrow.cHE2)
      (hN := Nat.le_of_ble_eq_true DEC_clearGrow.cNm2) (hm0 := m0_of_all DEC_clearGrow.m0_2) (hndc := (Template.nodupT_sound DEC_clearGrow.ndc2).2)
      (hlenc := DEC_clearGrow.lenc2) (hnrLo := DEC_clearGrow.nrLo2) (hder := rfl)
      (qs := DEC_clearGrow.qs2) (hlq := DEC_clearGrow.lq2) (hEs := hEs_of_allC dec_clearGrow.capRow (by decide) (by decide) DEC_clearGrow.dq2)
      (hq := qs_leC dec_clearGrow.capRow DEC_clearGrow.qsOk2) (hR' := sub_of_all DEC_clearGrow.R'2)
      (dJ := 151312) (dH := 3867) (dN := 4882) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clearGrow.cRJ2) (hcH := Nat.le_of_ble_eq_true DEC_clearGrow.cRH2)
      (hcN := Nat.le_of_ble_eq_true DEC_clearGrow.cRN2) (hs0E := Nat.le_of_ble_eq_true DEC_clearGrow.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clearGrow.scE2) (hs0N := Nat.le_of_ble_eq_true DEC_clearGrow.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clearGrow.scN2)
    g3 := glueLinkEndD (List.drop 5 Host.Load.Run.Tpl.DEC_clearGrow.O) hW DEC_clearGrow.chk_g3 DEC_clearGrow.srv10 DEC_clearGrow.ok10 R.runSeg3
      DEC_clearGrow.top11 Host.Load.Run.Tpl.DEC_clearGrow.dvs Host.Load.Run.Tpl.DEC_clearGrow.des (e := DEC_clearGrow.endFixed b0 NB) rfl DEC_clearGrow.hS1D
      (hde_of_decC dec_clearGrow.capRow DEC_clearGrow.hvsB (by decide) (by decide))
      (Nat.le_of_ble_eq_true DEC_clearGrow.len10) Gw.g3
  }

/-- **Decode case `clearGrow` from chain `DEC_clearGrow`** (`IterCaseW`) at the prompt route's instance, A4's end facts
(`DEC_clearGrow.iterEnd`, `DEC_clearGrow.shiftFW`, `DEC_clearGrow.keep`). -/
noncomputable def DEC_clearGrow.caseFixed (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : 151312 ≤ ΔJ) (hH : 3867 ≤ ΔH) (hN : 4882 ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).next + T * ΔH + B.H + (DEC_clearGrow.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).nnext + T * ΔN + B.N + (DEC_clearGrow.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s0.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_clearGrow.Pw (Template.framesP Host.Load.Run.Tpl.DEC_clearGrow.s0 q) Host.Load.Run.Tpl.DEC_clearGrow.s0 Host.Load.Run.Tpl.DEC_clearGrow.S0.tab terminalFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .clearGrow) where
  e := DEC_clearGrow.endFixed b0 NB
  g := DEC_clearGrow.g3 b0 NB DEC_clearGrow.eN
  chain := (DEC_clearGrow.piecesFixed (E0 := E0) (B := B) q DEC_clearGrow.runs hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := Host.Load.Run.Tpl.DEC_clearGrow.shiftFW NB q
  keep := Host.Load.Run.Tpl.DEC_clearGrow.keep q
  emit := DEC_clearGrow.emitTok b0 NB
  within := DEC_clearGrow.within (e := DEC_clearGrow.endFixed b0 NB) DEC_clearGrow.eN rfl hJ hH hN

end

end Host.Ts.Sim.Compose
