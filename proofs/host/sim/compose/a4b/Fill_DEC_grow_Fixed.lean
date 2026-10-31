import host.sim.compose.a4b.FixedEnds
import host.sim.compose.a4b.Fill_DEC_grow
import host.sim.compose.StartBounded

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case `grow`'s pieces from chain `DEC_grow`** at the prompt route's instance (`addrPrompt`, `wideP`, the
frames `framesP DEC_grow.s0 q`, `fixP`), A4's end (`DEC_grow.iterEnd`). -/
noncomputable def DEC_grow.piecesFixed (q : List Val) (R : DEC_grow.Runs)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : 151311 ≤ ΔJ) (hdH : 3867 ≤ ΔH) (hdN : 4882 ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).next + T * ΔH + B.H + (DEC_grow.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).nnext + T * ΔN + B.N + (DEC_grow.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).nnext) < 2 ^ 62) :
    DecPieces_DEC_grow (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_grow.Pw (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T (DEC_grow.endFixed b0 NB) (DEC_grow.g3 b0 NB DEC_grow.eN) :=
  let θ := Host.Load.Run.Tpl.DEC_grow.θ
  let hW := DEC_grow.hW
  let Gw : DEC_grow.Grow b0 NB Template.wideP := DEC_grow.grow R hW
  { c1 := (fun i x0 => bdCut b0 NB DEC_grow.Pw DEC_grow.fr DEC_grow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) Host.Load.Run.Tpl.DEC_grow.s0) DEC_grow.m0 Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0 i x0)
    c2 := (fun i x0 => bdCut b0 NB DEC_grow.Pw DEC_grow.fr DEC_grow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_grow.g1 b0 NB DEC_grow.eN) DEC_grow.m0 Host.Load.Run.Tpl.DEC_grow.s2 Host.Load.Run.Tpl.DEC_grow.S2 i x0)
    c3 := (fun i x0 => bdCut b0 NB DEC_grow.Pw DEC_grow.fr DEC_grow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_grow.g1 b0 NB DEC_grow.eN) DEC_grow.m0 Host.Load.Run.Tpl.DEC_grow.s4 Host.Load.Run.Tpl.DEC_grow.S4 i x0)
    c4 := (fun i x0 => bdCut b0 NB DEC_grow.Pw DEC_grow.fr DEC_grow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_grow.g2 b0 NB DEC_grow.eN) DEC_grow.m1 Host.Load.Run.Tpl.DEC_grow.s6 Host.Load.Run.Tpl.DEC_grow.S6 i x0)
    c5 := (fun i x0 => bdCut b0 NB DEC_grow.Pw DEC_grow.fr DEC_grow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_grow.g2 b0 NB DEC_grow.eN) DEC_grow.m1 Host.Load.Run.Tpl.DEC_grow.s8 Host.Load.Run.Tpl.DEC_grow.S8 i x0)
    c6 := (fun i x0 => bdCut b0 NB DEC_grow.Pw DEC_grow.fr DEC_grow.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP toks ΔJ ΔH ΔN θ (DEC_grow.g3 b0 NB DEC_grow.eN) DEC_grow.m1 Host.Load.Run.Tpl.DEC_grow.s10 Host.Load.Run.Tpl.DEC_grow.S10 i x0)
    start := startLinkBounded [] (by decide +kernel) rfl rfl (DEC_grow.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    rb__start__g1 := callLink Host.Load.Run.Tpl.DEC_grow.st0.tpl Host.Load.Run.Tpl.DEC_grow.st0.O hW DEC_grow.chk0 Host.Load.Run.Tpl.DEC_grow.srvO0 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_grow.iso0) (htab := Host.Load.Run.Tpl.DEC_grow.tab0_0) (hfoot := Host.Load.Run.Tpl.DEC_grow.stFoot0) (hnd := Host.Load.Run.Tpl.DEC_grow.wrNodup0)
      (hbd := Host.Load.Run.Tpl.DEC_grow.wrBound0) (htr := Host.Load.Run.Tpl.DEC_grow.trace0) (hmer := fun _ => Host.Load.Run.Tpl.DEC_grow.merged0) (hmtab := Host.Load.Run.Tpl.DEC_grow.mergeTab0)
      (hwsl := DEC_grow.wsl0) (hwsnd := (Template.nodupT_sound DEC_grow.wsnd0).2) (hfresh := noVar_of_all DEC_grow.fresh0)
      (hlen := Nat.le_of_ble_eq_true DEC_grow.len0) (hgtab := noVar_nth_of_all DEC_grow.gtab0)
      (hgθ := noVarθ_nth_of_all DEC_grow.gth0)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_grow.st0.tpl Host.Load.Run.Tpl.DEC_grow.iso0 Host.Load.Run.Tpl.DEC_grow.stFoot0 Host.Load.Run.Tpl.DEC_grow.wrNodup0 Host.Load.Run.Tpl.DEC_grow.wrBound0 Host.Load.Run.Tpl.DEC_grow.trace0)
      (hctab := Host.Load.Run.Tpl.DEC_grow.ctab0) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_grow.cwsDisj0) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_grow.ctab0 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_grow.zkap0
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_grow.jcl0) Host.Load.Run.Tpl.DEC_grow.cfix0 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_grow.zpl0 Host.Load.Run.Tpl.DEC_grow.zplnd0 Host.Load.Run.Tpl.DEC_grow.zn10 Host.Load.Run.Tpl.DEC_grow.zfirst0 Host.Load.Run.Tpl.DEC_grow.zscn0 Host.Load.Run.Tpl.DEC_grow.zsmn0 Host.Load.Run.Tpl.DEC_grow.zgrow0 Host.Load.Run.Tpl.DEC_grow.mergeTab0
        Host.Load.Run.Tpl.DEC_grow.zfresh0 Host.Load.Run.Tpl.DEC_grow.zcnd0 DEC_grow.lenc0 Host.Load.Run.Tpl.DEC_grow.znrHi0 Host.Load.Run.Tpl.DEC_grow.znC0 Host.Load.Run.Tpl.DEC_grow.zfrlt0 xs_wideP wfr_wideP (hX_framesP DEC_grow.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_grow.zg0_2673448, Host.Load.Run.Tpl.DEC_grow.zk0_2673448, Host.Load.Run.Tpl.DEC_grow.zm0_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_grow.zg0_12504, Host.Load.Run.Tpl.DEC_grow.zk0_12504, Host.Load.Run.Tpl.DEC_grow.zm0_12504⟩, ⟨Host.Load.Run.Tpl.DEC_grow.zg0_2665, Host.Load.Run.Tpl.DEC_grow.zk0_2665, Host.Load.Run.Tpl.DEC_grow.zm0_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_grow.zw0_4910) wf_wideP Host.Load.Run.Tpl.DEC_grow.zclbd0 Host.Load.Run.Tpl.DEC_grow.cheap0
        (hoff_of Host.Load.Run.Tpl.DEC_grow.mheap0 Host.Load.Run.Tpl.DEC_grow.stFoot0 Host.Load.Run.Tpl.DEC_grow.iso0 Host.Load.Run.Tpl.DEC_grow.zwr0) Host.Load.Run.Tpl.DEC_grow.ckeepP0 Host.Load.Run.Tpl.DEC_grow.csupp0 Host.Load.Run.Tpl.DEC_grow.cbound0 Host.Load.Run.Tpl.DEC_grow.zimg0
        Host.Load.Run.Tpl.DEC_grow.zctl0 Host.Load.Run.Tpl.DEC_grow.zstack0 Host.Load.Run.Tpl.DEC_grow.zjobs0 Host.Load.Run.Tpl.DEC_grow.zstores0 Host.Load.Run.Tpl.DEC_grow.zroots0 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_grow.cshiftR0 h rfl)
      (hbig := DEC_grow.big0) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_grow.jcl2)
        (Nat.le_of_ble_eq_true DEC_grow.xn0) (by decide) Host.Load.Run.Tpl.DEC_grow.zroots20)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_grow.bandLo0) (Nat.le_of_ble_eq_true DEC_grow.bandHi) (by decide))
      (hκn := compact_num_of DEC_grow.kn0) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_grow.kappa0 (compact_fix_of DEC_grow.ka0) DEC.FixedCells.grow_kappa0_2586 DEC.FixedCells.grow_kappa0_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_grow.cfix0 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_grow.zhm0))
      (hfwd := Host.Load.Run.Tpl.DEC_grow.arr0_2673448) (hemit := Host.Load.Run.Tpl.DEC_grow.arr0_12504) (hkeep := Host.Load.Run.Tpl.DEC_grow.keep0 q)
      (heN := Host.Load.Run.Tpl.DEC_grow.arrR0_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_grow.cJm0) (hJc := Nat.le_of_ble_eq_true DEC_grow.cJc0)
      (hH := Nat.le_of_ble_eq_true DEC_grow.cHm0) (hHE := Nat.blt_eq.mp DEC_grow.cHE0)
      (hN := Nat.le_of_ble_eq_true DEC_grow.cNm0) (hm0 := m0_of_all DEC_grow.m0_0) (hndc := (Template.nodupT_sound DEC_grow.ndc0).2)
      (hlenc := DEC_grow.lenc0) (hnrLo := DEC_grow.nrLo0) (hder := rfl)
      (qs := DEC_grow.qs0) (hlq := DEC_grow.lq0) (hEs := hEs_of_allC dec_grow.capRow (by decide) (by decide) DEC_grow.dq0)
      (hq := qs_leC dec_grow.capRow DEC_grow.qsOk0) (hR' := sub_of_all DEC_grow.R'0)
      (dJ := 151311) (dH := 3867) (dN := 4882) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_grow.cRJ0) (hcH := Nat.le_of_ble_eq_true DEC_grow.cRH0)
      (hcN := Nat.le_of_ble_eq_true DEC_grow.cRN0) (hs0E := Nat.le_of_ble_eq_true DEC_grow.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_grow.scE0) (hs0N := Nat.le_of_ble_eq_true DEC_grow.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_grow.scN0)
    g1 := glueLinkCall (List.drop 0 Host.Load.Run.Tpl.DEC_grow.O) hW DEC_grow.chk_g1 DEC_grow.srv2 DEC_grow.ok2 R.runSeg1
      (runOk_ok_end 899 R.runSeg1 DEC_grow.halt3) DEC_grow.halt3 R.stepA2 DEC_grow.top4
      (Nat.le_of_ble_eq_true DEC_grow.len2) (fun _ h => h) Gw.g1
    fwd_D1_warm_DGrow__g1__g2 := callLink Host.Load.Run.Tpl.DEC_grow.st1.tpl Host.Load.Run.Tpl.DEC_grow.st1.O hW DEC_grow.chk1 Host.Load.Run.Tpl.DEC_grow.srvO1 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_grow.iso1) (htab := Host.Load.Run.Tpl.DEC_grow.tab0_1) (hfoot := Host.Load.Run.Tpl.DEC_grow.stFoot1) (hnd := Host.Load.Run.Tpl.DEC_grow.wrNodup1)
      (hbd := Host.Load.Run.Tpl.DEC_grow.wrBound1) (htr := Host.Load.Run.Tpl.DEC_grow.trace1) (hmer := fun _ => Host.Load.Run.Tpl.DEC_grow.merged1) (hmtab := Host.Load.Run.Tpl.DEC_grow.mergeTab1)
      (hwsl := DEC_grow.wsl1) (hwsnd := (Template.nodupT_sound DEC_grow.wsnd1).2) (hfresh := noVar_of_all DEC_grow.fresh1)
      (hlen := Nat.le_of_ble_eq_true DEC_grow.len4) (hgtab := noVar_nth_of_all DEC_grow.gtab1)
      (hgθ := noVarθ_nth_of_all DEC_grow.gth1)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_grow.st1.tpl Host.Load.Run.Tpl.DEC_grow.iso1 Host.Load.Run.Tpl.DEC_grow.stFoot1 Host.Load.Run.Tpl.DEC_grow.wrNodup1 Host.Load.Run.Tpl.DEC_grow.wrBound1 Host.Load.Run.Tpl.DEC_grow.trace1)
      (hctab := Host.Load.Run.Tpl.DEC_grow.ctab1) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_grow.cwsDisj1) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_grow.ctab1 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_grow.zkap1
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_grow.jcl4) Host.Load.Run.Tpl.DEC_grow.cfix1 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_grow.zpl1 Host.Load.Run.Tpl.DEC_grow.zplnd1 Host.Load.Run.Tpl.DEC_grow.zn11 Host.Load.Run.Tpl.DEC_grow.zfirst1 Host.Load.Run.Tpl.DEC_grow.zscn1 Host.Load.Run.Tpl.DEC_grow.zsmn1 Host.Load.Run.Tpl.DEC_grow.zgrow1 Host.Load.Run.Tpl.DEC_grow.mergeTab1
        Host.Load.Run.Tpl.DEC_grow.zfresh1 Host.Load.Run.Tpl.DEC_grow.zcnd1 DEC_grow.lenc1 Host.Load.Run.Tpl.DEC_grow.znrHi1 Host.Load.Run.Tpl.DEC_grow.znC1 Host.Load.Run.Tpl.DEC_grow.zfrlt1 xs_wideP wfr_wideP (hX_framesP DEC_grow.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_grow.zg1_2673448, Host.Load.Run.Tpl.DEC_grow.zk1_2673448, Host.Load.Run.Tpl.DEC_grow.zm1_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_grow.zg1_12504, Host.Load.Run.Tpl.DEC_grow.zk1_12504, Host.Load.Run.Tpl.DEC_grow.zm1_12504⟩, ⟨Host.Load.Run.Tpl.DEC_grow.zg1_2665, Host.Load.Run.Tpl.DEC_grow.zk1_2665, Host.Load.Run.Tpl.DEC_grow.zm1_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_grow.zw1_4910) wf_wideP Host.Load.Run.Tpl.DEC_grow.zclbd1 Host.Load.Run.Tpl.DEC_grow.cheap1
        (hoff_of Host.Load.Run.Tpl.DEC_grow.mheap1 Host.Load.Run.Tpl.DEC_grow.stFoot1 Host.Load.Run.Tpl.DEC_grow.iso1 Host.Load.Run.Tpl.DEC_grow.zwr1) Host.Load.Run.Tpl.DEC_grow.ckeepP1 Host.Load.Run.Tpl.DEC_grow.csupp1 Host.Load.Run.Tpl.DEC_grow.cbound1 Host.Load.Run.Tpl.DEC_grow.zimg1
        Host.Load.Run.Tpl.DEC_grow.zctl1 Host.Load.Run.Tpl.DEC_grow.zstack1 Host.Load.Run.Tpl.DEC_grow.zjobs1 Host.Load.Run.Tpl.DEC_grow.zstores1 Host.Load.Run.Tpl.DEC_grow.zroots1 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_grow.cshiftR1 h rfl)
      (hbig := DEC_grow.big1) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_grow.jcl6)
        (Nat.le_of_ble_eq_true DEC_grow.xn1) (by decide) Host.Load.Run.Tpl.DEC_grow.zroots21)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_grow.bandLo1) (Nat.le_of_ble_eq_true DEC_grow.bandHi) (by decide))
      (hκn := compact_num_of DEC_grow.kn1) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_grow.kappa1 (compact_fix_of DEC_grow.ka1) DEC.FixedCells.grow_kappa1_2586 DEC.FixedCells.grow_kappa1_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_grow.cfix1 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_grow.zhm1))
      (hfwd := Host.Load.Run.Tpl.DEC_grow.arr1_2673448) (hemit := Host.Load.Run.Tpl.DEC_grow.arr1_12504) (hkeep := Host.Load.Run.Tpl.DEC_grow.keep1 q)
      (heN := Host.Load.Run.Tpl.DEC_grow.arrR1_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_grow.cJm1) (hJc := Nat.le_of_ble_eq_true DEC_grow.cJc1)
      (hH := Nat.le_of_ble_eq_true DEC_grow.cHm1) (hHE := Nat.blt_eq.mp DEC_grow.cHE1)
      (hN := Nat.le_of_ble_eq_true DEC_grow.cNm1) (hm0 := m0_of_all DEC_grow.m0_1) (hndc := (Template.nodupT_sound DEC_grow.ndc1).2)
      (hlenc := DEC_grow.lenc1) (hnrLo := DEC_grow.nrLo1) (hder := rfl)
      (qs := DEC_grow.qs1) (hlq := DEC_grow.lq1) (hEs := hEs_of_allC dec_grow.capRow (by decide) (by decide) DEC_grow.dq1)
      (hq := qs_leC dec_grow.capRow DEC_grow.qsOk1) (hR' := sub_of_all DEC_grow.R'1)
      (dJ := 151311) (dH := 3867) (dN := 4882) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_grow.cRJ1) (hcH := Nat.le_of_ble_eq_true DEC_grow.cRH1)
      (hcN := Nat.le_of_ble_eq_true DEC_grow.cRN1) (hs0E := Nat.le_of_ble_eq_true DEC_grow.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_grow.scE1) (hs0N := Nat.le_of_ble_eq_true DEC_grow.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_grow.scN1)
    g2 := glueLinkCall (List.drop 5 Host.Load.Run.Tpl.DEC_grow.O) hW DEC_grow.chk_g2 DEC_grow.srv6 DEC_grow.ok6 R.runSeg2
      (runOk_ok_end 3657 R.runSeg2 DEC_grow.halt7) DEC_grow.halt7 R.stepA3 DEC_grow.top8
      (Nat.le_of_ble_eq_true DEC_grow.len6) (fun _ h => h) Gw.g2
    async__g2__g3 := callLink Host.Load.Run.Tpl.DEC_grow.st2.tpl Host.Load.Run.Tpl.DEC_grow.st2.O hW DEC_grow.chk2 Host.Load.Run.Tpl.DEC_grow.srvO2 (by decide +kernel)
      (hs0 := Host.Load.Run.Tpl.DEC_grow.iso2) (htab := Host.Load.Run.Tpl.DEC_grow.tab0_2) (hfoot := Host.Load.Run.Tpl.DEC_grow.stFoot2) (hnd := Host.Load.Run.Tpl.DEC_grow.wrNodup2)
      (hbd := Host.Load.Run.Tpl.DEC_grow.wrBound2) (htr := Host.Load.Run.Tpl.DEC_grow.trace2) (hmer := fun _ => Host.Load.Run.Tpl.DEC_grow.merged2) (hmtab := Host.Load.Run.Tpl.DEC_grow.mergeTab2)
      (hwsl := DEC_grow.wsl2) (hwsnd := (Template.nodupT_sound DEC_grow.wsnd2).2) (hfresh := noVar_of_all DEC_grow.fresh2)
      (hlen := Nat.le_of_ble_eq_true DEC_grow.len8) (hgtab := noVar_nth_of_all DEC_grow.gtab2)
      (hgθ := noVarθ_nth_of_all DEC_grow.gth2)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_grow.st2.tpl Host.Load.Run.Tpl.DEC_grow.iso2 Host.Load.Run.Tpl.DEC_grow.stFoot2 Host.Load.Run.Tpl.DEC_grow.wrNodup2 Host.Load.Run.Tpl.DEC_grow.wrBound2 Host.Load.Run.Tpl.DEC_grow.trace2)
      (hctab := Host.Load.Run.Tpl.DEC_grow.ctab2) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_grow.cwsDisj2) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_grow.ctab2 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_grow.zkap2
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_grow.jcl8) Host.Load.Run.Tpl.DEC_grow.cfix2 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_grow.zpl2 Host.Load.Run.Tpl.DEC_grow.zplnd2 Host.Load.Run.Tpl.DEC_grow.zn12 Host.Load.Run.Tpl.DEC_grow.zfirst2 Host.Load.Run.Tpl.DEC_grow.zscn2 Host.Load.Run.Tpl.DEC_grow.zsmn2 Host.Load.Run.Tpl.DEC_grow.zgrow2 Host.Load.Run.Tpl.DEC_grow.mergeTab2
        Host.Load.Run.Tpl.DEC_grow.zfresh2 Host.Load.Run.Tpl.DEC_grow.zcnd2 DEC_grow.lenc2 Host.Load.Run.Tpl.DEC_grow.znrHi2 Host.Load.Run.Tpl.DEC_grow.znC2 Host.Load.Run.Tpl.DEC_grow.zfrlt2 xs_wideP wfr_wideP (hX_framesP DEC_grow.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_grow.zg2_2673448, Host.Load.Run.Tpl.DEC_grow.zk2_2673448, Host.Load.Run.Tpl.DEC_grow.zm2_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_grow.zg2_12504, Host.Load.Run.Tpl.DEC_grow.zk2_12504, Host.Load.Run.Tpl.DEC_grow.zm2_12504⟩, ⟨Host.Load.Run.Tpl.DEC_grow.zg2_2665, Host.Load.Run.Tpl.DEC_grow.zk2_2665, Host.Load.Run.Tpl.DEC_grow.zm2_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_grow.zw2_4910) wf_wideP Host.Load.Run.Tpl.DEC_grow.zclbd2 Host.Load.Run.Tpl.DEC_grow.cheap2
        (hoff_of Host.Load.Run.Tpl.DEC_grow.mheap2 Host.Load.Run.Tpl.DEC_grow.stFoot2 Host.Load.Run.Tpl.DEC_grow.iso2 Host.Load.Run.Tpl.DEC_grow.zwr2) Host.Load.Run.Tpl.DEC_grow.ckeepP2 Host.Load.Run.Tpl.DEC_grow.csupp2 Host.Load.Run.Tpl.DEC_grow.cbound2 Host.Load.Run.Tpl.DEC_grow.zimg2
        Host.Load.Run.Tpl.DEC_grow.zctl2 Host.Load.Run.Tpl.DEC_grow.zstack2 Host.Load.Run.Tpl.DEC_grow.zjobs2 Host.Load.Run.Tpl.DEC_grow.zstores2 Host.Load.Run.Tpl.DEC_grow.zroots2 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_grow.cshiftR2 h rfl)
      (hbig := DEC_grow.big2) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_grow.jcl10)
        (Nat.le_of_ble_eq_true DEC_grow.xn2) (by decide) Host.Load.Run.Tpl.DEC_grow.zroots22)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_grow.bandLo2) (Nat.le_of_ble_eq_true DEC_grow.bandHi) (by decide))
      (hκn := compact_num_of DEC_grow.kn2) (hκa := terminal_fix_append Host.Load.Run.Tpl.DEC_grow.kappa2 (compact_fix_of DEC_grow.ka2) DEC.FixedCells.grow_kappa2_2586 DEC.FixedCells.grow_kappa2_2589) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_grow.cfix2 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_grow.zhm2))
      (hfwd := Host.Load.Run.Tpl.DEC_grow.arr2_2673448) (hemit := Host.Load.Run.Tpl.DEC_grow.arr2_12504) (hkeep := Host.Load.Run.Tpl.DEC_grow.keep2 q)
      (heN := Host.Load.Run.Tpl.DEC_grow.arrR2_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_grow.cJm2) (hJc := Nat.le_of_ble_eq_true DEC_grow.cJc2)
      (hH := Nat.le_of_ble_eq_true DEC_grow.cHm2) (hHE := Nat.blt_eq.mp DEC_grow.cHE2)
      (hN := Nat.le_of_ble_eq_true DEC_grow.cNm2) (hm0 := m0_of_all DEC_grow.m0_2) (hndc := (Template.nodupT_sound DEC_grow.ndc2).2)
      (hlenc := DEC_grow.lenc2) (hnrLo := DEC_grow.nrLo2) (hder := rfl)
      (qs := DEC_grow.qs2) (hlq := DEC_grow.lq2) (hEs := hEs_of_allC dec_grow.capRow (by decide) (by decide) DEC_grow.dq2)
      (hq := qs_leC dec_grow.capRow DEC_grow.qsOk2) (hR' := sub_of_all DEC_grow.R'2)
      (dJ := 151311) (dH := 3867) (dN := 4882) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_grow.cRJ2) (hcH := Nat.le_of_ble_eq_true DEC_grow.cRH2)
      (hcN := Nat.le_of_ble_eq_true DEC_grow.cRN2) (hs0E := Nat.le_of_ble_eq_true DEC_grow.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_grow.scE2) (hs0N := Nat.le_of_ble_eq_true DEC_grow.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_grow.scN2)
    g3 := glueLinkEndD (List.drop 5 Host.Load.Run.Tpl.DEC_grow.O) hW DEC_grow.chk_g3 DEC_grow.srv10 DEC_grow.ok10 R.runSeg3
      DEC_grow.top11 Host.Load.Run.Tpl.DEC_grow.dvs Host.Load.Run.Tpl.DEC_grow.des (e := DEC_grow.endFixed b0 NB) rfl DEC_grow.hS1D
      (hde_of_decC dec_grow.capRow DEC_grow.hvsB (by decide) (by decide))
      (Nat.le_of_ble_eq_true DEC_grow.len10) Gw.g3
  }

/-- **Decode case `grow` from chain `DEC_grow`** (`IterCaseW`) at the prompt route's instance, A4's end facts
(`DEC_grow.iterEnd`, `DEC_grow.shiftFW`, `DEC_grow.keep`). -/
noncomputable def DEC_grow.caseFixed (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : 151311 ≤ ΔJ) (hH : 3867 ≤ ΔH) (hN : 4882 ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).next + T * ΔH + B.H + (DEC_grow.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).nnext + T * ΔN + B.N + (DEC_grow.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_grow.Pw (Template.framesP Host.Load.Run.Tpl.DEC_grow.s0 q) Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .grow) where
  e := DEC_grow.endFixed b0 NB
  g := DEC_grow.g3 b0 NB DEC_grow.eN
  chain := (DEC_grow.piecesFixed (E0 := E0) (B := B) q DEC_grow.runs hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := Host.Load.Run.Tpl.DEC_grow.shiftFW NB q
  keep := Host.Load.Run.Tpl.DEC_grow.keep q
  emit := DEC_grow.emitTok b0 NB
  within := DEC_grow.within (e := DEC_grow.endFixed b0 NB) DEC_grow.eN rfl hJ hH hN

end

end Host.Ts.Sim.Compose
