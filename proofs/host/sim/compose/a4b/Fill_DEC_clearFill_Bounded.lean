import host.sim.compose.a4b.Fill_DEC_clearFill
import host.sim.compose.StartBounded

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case `clearFill`'s pieces from chain `DEC_clearFill`** at the prompt route's instance (`addrPrompt`, `wideP`, the
frames `framesP DEC_clearFill.s0 q`, `fixP`), A4's end (`DEC_clearFill.iterEnd`). -/
noncomputable def DEC_clearFill.piecesBounded (q : List Val) (R : DEC_clearFill.Runs)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : 148176 ≤ ΔJ) (hdH : 3771 ≤ ΔH) (hdN : 4690 ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).next + T * ΔH + B.H + (DEC_clearFill.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).nnext + T * ΔN + B.N + (DEC_clearFill.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).nnext) < 2 ^ 62) :
    DecPieces_DEC_clearFill (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_clearFill.Pw (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T ((Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0) (DEC_clearFill.g3 b0 NB DEC_clearFill.eN) :=
  let θ := Host.Load.Run.Tpl.DEC_clearFill.θ
  let hW := DEC_clearFill.hW
  let Gw : DEC_clearFill.Grow b0 NB Template.wideP := DEC_clearFill.grow R hW
  { c1 := (fun i x0 => bdCut b0 NB DEC_clearFill.Pw DEC_clearFill.fr DEC_clearFill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) Host.Load.Run.Tpl.DEC_clearFill.s0) DEC_clearFill.m0 Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0 i x0)
    c2 := (fun i x0 => bdCut b0 NB DEC_clearFill.Pw DEC_clearFill.fr DEC_clearFill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clearFill.g1 b0 NB DEC_clearFill.eN) DEC_clearFill.m0 Host.Load.Run.Tpl.DEC_clearFill.s2 Host.Load.Run.Tpl.DEC_clearFill.S2 i x0)
    c3 := (fun i x0 => bdCut b0 NB DEC_clearFill.Pw DEC_clearFill.fr DEC_clearFill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clearFill.g1 b0 NB DEC_clearFill.eN) DEC_clearFill.m0 Host.Load.Run.Tpl.DEC_clearFill.s4 Host.Load.Run.Tpl.DEC_clearFill.S4 i x0)
    c4 := (fun i x0 => bdCut b0 NB DEC_clearFill.Pw DEC_clearFill.fr DEC_clearFill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clearFill.g2 b0 NB DEC_clearFill.eN) DEC_clearFill.m1 Host.Load.Run.Tpl.DEC_clearFill.s6 Host.Load.Run.Tpl.DEC_clearFill.S6 i x0)
    c5 := (fun i x0 => bdCut b0 NB DEC_clearFill.Pw DEC_clearFill.fr DEC_clearFill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clearFill.g2 b0 NB DEC_clearFill.eN) DEC_clearFill.m1 Host.Load.Run.Tpl.DEC_clearFill.s8 Host.Load.Run.Tpl.DEC_clearFill.S8 i x0)
    c6 := (fun i x0 => bdCut b0 NB DEC_clearFill.Pw DEC_clearFill.fr DEC_clearFill.wd Template.wideP Host.Load.Run.Prompt.addrPrompt (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP toks ΔJ ΔH ΔN θ (DEC_clearFill.g3 b0 NB DEC_clearFill.eN) DEC_clearFill.m1 Host.Load.Run.Tpl.DEC_clearFill.s10 Host.Load.Run.Tpl.DEC_clearFill.S10 i x0)
    start := startLinkBounded [] (by decide +kernel) rfl rfl (DEC_clearFill.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    rb__start__g1 := callLink Host.Load.Run.Tpl.DEC_clearFill.st0.tpl Host.Load.Run.Tpl.DEC_clearFill.st0.O hW DEC_clearFill.chk0 Host.Load.Run.Tpl.DEC_clearFill.srvO0 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_clearFill.iso0) (htab := Host.Load.Run.Tpl.DEC_clearFill.tab0_0) (hfoot := Host.Load.Run.Tpl.DEC_clearFill.stFoot0) (hnd := Host.Load.Run.Tpl.DEC_clearFill.wrNodup0)
      (hbd := Host.Load.Run.Tpl.DEC_clearFill.wrBound0) (htr := Host.Load.Run.Tpl.DEC_clearFill.trace0) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clearFill.merged0) (hmtab := Host.Load.Run.Tpl.DEC_clearFill.mergeTab0)
      (hwsl := DEC_clearFill.wsl0) (hwsnd := (Template.nodupT_sound DEC_clearFill.wsnd0).2) (hfresh := noVar_of_all DEC_clearFill.fresh0)
      (hlen := Nat.le_of_ble_eq_true DEC_clearFill.len0) (hgtab := noVar_nth_of_all DEC_clearFill.gtab0)
      (hgθ := noVarθ_nth_of_all DEC_clearFill.gth0)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clearFill.st0.tpl Host.Load.Run.Tpl.DEC_clearFill.iso0 Host.Load.Run.Tpl.DEC_clearFill.stFoot0 Host.Load.Run.Tpl.DEC_clearFill.wrNodup0 Host.Load.Run.Tpl.DEC_clearFill.wrBound0 Host.Load.Run.Tpl.DEC_clearFill.trace0)
      (hctab := Host.Load.Run.Tpl.DEC_clearFill.ctab0) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clearFill.cwsDisj0) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clearFill.ctab0 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clearFill.zkap0
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearFill.jcl0) Host.Load.Run.Tpl.DEC_clearFill.cfix0 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clearFill.zpl0 Host.Load.Run.Tpl.DEC_clearFill.zplnd0 Host.Load.Run.Tpl.DEC_clearFill.zn10 Host.Load.Run.Tpl.DEC_clearFill.zfirst0 Host.Load.Run.Tpl.DEC_clearFill.zscn0 Host.Load.Run.Tpl.DEC_clearFill.zsmn0 Host.Load.Run.Tpl.DEC_clearFill.zgrow0 Host.Load.Run.Tpl.DEC_clearFill.mergeTab0
        Host.Load.Run.Tpl.DEC_clearFill.zfresh0 Host.Load.Run.Tpl.DEC_clearFill.zcnd0 DEC_clearFill.lenc0 Host.Load.Run.Tpl.DEC_clearFill.znrHi0 Host.Load.Run.Tpl.DEC_clearFill.znC0 Host.Load.Run.Tpl.DEC_clearFill.zfrlt0 xs_wideP wfr_wideP (hX_framesP DEC_clearFill.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_clearFill.zg0_2673448, Host.Load.Run.Tpl.DEC_clearFill.zk0_2673448, Host.Load.Run.Tpl.DEC_clearFill.zm0_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_clearFill.zg0_12504, Host.Load.Run.Tpl.DEC_clearFill.zk0_12504, Host.Load.Run.Tpl.DEC_clearFill.zm0_12504⟩, ⟨Host.Load.Run.Tpl.DEC_clearFill.zg0_2665, Host.Load.Run.Tpl.DEC_clearFill.zk0_2665, Host.Load.Run.Tpl.DEC_clearFill.zm0_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_clearFill.zw0_4910) wf_wideP Host.Load.Run.Tpl.DEC_clearFill.zclbd0 Host.Load.Run.Tpl.DEC_clearFill.cheap0
        (hoff_of Host.Load.Run.Tpl.DEC_clearFill.mheap0 Host.Load.Run.Tpl.DEC_clearFill.stFoot0 Host.Load.Run.Tpl.DEC_clearFill.iso0 Host.Load.Run.Tpl.DEC_clearFill.zwr0) Host.Load.Run.Tpl.DEC_clearFill.ckeepP0 Host.Load.Run.Tpl.DEC_clearFill.csupp0 Host.Load.Run.Tpl.DEC_clearFill.cbound0 Host.Load.Run.Tpl.DEC_clearFill.zimg0
        Host.Load.Run.Tpl.DEC_clearFill.zctl0 Host.Load.Run.Tpl.DEC_clearFill.zstack0 Host.Load.Run.Tpl.DEC_clearFill.zjobs0 Host.Load.Run.Tpl.DEC_clearFill.zstores0 Host.Load.Run.Tpl.DEC_clearFill.zroots0 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clearFill.cshiftR0 h rfl)
      (hbig := DEC_clearFill.big0) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearFill.jcl2)
        (Nat.le_of_ble_eq_true DEC_clearFill.xn0) (by decide) Host.Load.Run.Tpl.DEC_clearFill.zroots20)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clearFill.bandLo0) (Nat.le_of_ble_eq_true DEC_clearFill.bandHi) (by decide))
      (hκn := compact_num_of DEC_clearFill.kn0) (hκa := compact_fix_of DEC_clearFill.ka0) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clearFill.cfix0 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clearFill.zhm0))
      (hfwd := Host.Load.Run.Tpl.DEC_clearFill.arr0_2673448) (hemit := Host.Load.Run.Tpl.DEC_clearFill.arr0_12504) (hkeep := Host.Load.Run.Tpl.DEC_clearFill.keep0 q)
      (heN := Host.Load.Run.Tpl.DEC_clearFill.arrR0_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clearFill.cJm0) (hJc := Nat.le_of_ble_eq_true DEC_clearFill.cJc0)
      (hH := Nat.le_of_ble_eq_true DEC_clearFill.cHm0) (hHE := Nat.blt_eq.mp DEC_clearFill.cHE0)
      (hN := Nat.le_of_ble_eq_true DEC_clearFill.cNm0) (hm0 := m0_of_all DEC_clearFill.m0_0) (hndc := (Template.nodupT_sound DEC_clearFill.ndc0).2)
      (hlenc := DEC_clearFill.lenc0) (hnrLo := DEC_clearFill.nrLo0) (hder := rfl)
      (qs := DEC_clearFill.qs0) (hlq := DEC_clearFill.lq0) (hEs := hEs_of_all (by decide) DEC_clearFill.dq0)
      (hq := qs_le DEC_clearFill.qsOk0) (hR' := sub_of_all DEC_clearFill.R'0)
      (dJ := 148176) (dH := 3771) (dN := 4690) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clearFill.cRJ0) (hcH := Nat.le_of_ble_eq_true DEC_clearFill.cRH0)
      (hcN := Nat.le_of_ble_eq_true DEC_clearFill.cRN0) (hs0E := Nat.le_of_ble_eq_true DEC_clearFill.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clearFill.scE0) (hs0N := Nat.le_of_ble_eq_true DEC_clearFill.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clearFill.scN0)
    g1 := glueLinkCall (List.drop 0 Host.Load.Run.Tpl.DEC_clearFill.O) hW DEC_clearFill.chk_g1 DEC_clearFill.srv2 DEC_clearFill.ok2 R.runSeg1
      (runOk_ok_end 915 R.runSeg1 DEC_clearFill.halt3) DEC_clearFill.halt3 R.stepA2 DEC_clearFill.top4
      (Nat.le_of_ble_eq_true DEC_clearFill.len2) (fun _ h => h) Gw.g1
    fwd_D1_warm_DFill__g1__g2 := callLink Host.Load.Run.Tpl.DEC_clearFill.st1.tpl Host.Load.Run.Tpl.DEC_clearFill.st1.O hW DEC_clearFill.chk1 Host.Load.Run.Tpl.DEC_clearFill.srvO1 (fun _ h => h)
      (hs0 := Host.Load.Run.Tpl.DEC_clearFill.iso1) (htab := Host.Load.Run.Tpl.DEC_clearFill.tab0_1) (hfoot := Host.Load.Run.Tpl.DEC_clearFill.stFoot1) (hnd := Host.Load.Run.Tpl.DEC_clearFill.wrNodup1)
      (hbd := Host.Load.Run.Tpl.DEC_clearFill.wrBound1) (htr := Host.Load.Run.Tpl.DEC_clearFill.trace1) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clearFill.merged1) (hmtab := Host.Load.Run.Tpl.DEC_clearFill.mergeTab1)
      (hwsl := DEC_clearFill.wsl1) (hwsnd := (Template.nodupT_sound DEC_clearFill.wsnd1).2) (hfresh := noVar_of_all DEC_clearFill.fresh1)
      (hlen := Nat.le_of_ble_eq_true DEC_clearFill.len4) (hgtab := noVar_nth_of_all DEC_clearFill.gtab1)
      (hgθ := noVarθ_nth_of_all DEC_clearFill.gth1)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clearFill.st1.tpl Host.Load.Run.Tpl.DEC_clearFill.iso1 Host.Load.Run.Tpl.DEC_clearFill.stFoot1 Host.Load.Run.Tpl.DEC_clearFill.wrNodup1 Host.Load.Run.Tpl.DEC_clearFill.wrBound1 Host.Load.Run.Tpl.DEC_clearFill.trace1)
      (hctab := Host.Load.Run.Tpl.DEC_clearFill.ctab1) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clearFill.cwsDisj1) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clearFill.ctab1 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clearFill.zkap1
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearFill.jcl4) Host.Load.Run.Tpl.DEC_clearFill.cfix1 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clearFill.zpl1 Host.Load.Run.Tpl.DEC_clearFill.zplnd1 Host.Load.Run.Tpl.DEC_clearFill.zn11 Host.Load.Run.Tpl.DEC_clearFill.zfirst1 Host.Load.Run.Tpl.DEC_clearFill.zscn1 Host.Load.Run.Tpl.DEC_clearFill.zsmn1 Host.Load.Run.Tpl.DEC_clearFill.zgrow1 Host.Load.Run.Tpl.DEC_clearFill.mergeTab1
        Host.Load.Run.Tpl.DEC_clearFill.zfresh1 Host.Load.Run.Tpl.DEC_clearFill.zcnd1 DEC_clearFill.lenc1 Host.Load.Run.Tpl.DEC_clearFill.znrHi1 Host.Load.Run.Tpl.DEC_clearFill.znC1 Host.Load.Run.Tpl.DEC_clearFill.zfrlt1 xs_wideP wfr_wideP (hX_framesP DEC_clearFill.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_clearFill.zg1_2673448, Host.Load.Run.Tpl.DEC_clearFill.zk1_2673448, Host.Load.Run.Tpl.DEC_clearFill.zm1_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_clearFill.zg1_12504, Host.Load.Run.Tpl.DEC_clearFill.zk1_12504, Host.Load.Run.Tpl.DEC_clearFill.zm1_12504⟩, ⟨Host.Load.Run.Tpl.DEC_clearFill.zg1_2665, Host.Load.Run.Tpl.DEC_clearFill.zk1_2665, Host.Load.Run.Tpl.DEC_clearFill.zm1_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_clearFill.zw1_4910) wf_wideP Host.Load.Run.Tpl.DEC_clearFill.zclbd1 Host.Load.Run.Tpl.DEC_clearFill.cheap1
        (hoff_of Host.Load.Run.Tpl.DEC_clearFill.mheap1 Host.Load.Run.Tpl.DEC_clearFill.stFoot1 Host.Load.Run.Tpl.DEC_clearFill.iso1 Host.Load.Run.Tpl.DEC_clearFill.zwr1) Host.Load.Run.Tpl.DEC_clearFill.ckeepP1 Host.Load.Run.Tpl.DEC_clearFill.csupp1 Host.Load.Run.Tpl.DEC_clearFill.cbound1 Host.Load.Run.Tpl.DEC_clearFill.zimg1
        Host.Load.Run.Tpl.DEC_clearFill.zctl1 Host.Load.Run.Tpl.DEC_clearFill.zstack1 Host.Load.Run.Tpl.DEC_clearFill.zjobs1 Host.Load.Run.Tpl.DEC_clearFill.zstores1 Host.Load.Run.Tpl.DEC_clearFill.zroots1 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clearFill.cshiftR1 h rfl)
      (hbig := DEC_clearFill.big1) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearFill.jcl6)
        (Nat.le_of_ble_eq_true DEC_clearFill.xn1) (by decide) Host.Load.Run.Tpl.DEC_clearFill.zroots21)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clearFill.bandLo1) (Nat.le_of_ble_eq_true DEC_clearFill.bandHi) (by decide))
      (hκn := compact_num_of DEC_clearFill.kn1) (hκa := compact_fix_of DEC_clearFill.ka1) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clearFill.cfix1 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clearFill.zhm1))
      (hfwd := Host.Load.Run.Tpl.DEC_clearFill.arr1_2673448) (hemit := Host.Load.Run.Tpl.DEC_clearFill.arr1_12504) (hkeep := Host.Load.Run.Tpl.DEC_clearFill.keep1 q)
      (heN := Host.Load.Run.Tpl.DEC_clearFill.arrR1_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clearFill.cJm1) (hJc := Nat.le_of_ble_eq_true DEC_clearFill.cJc1)
      (hH := Nat.le_of_ble_eq_true DEC_clearFill.cHm1) (hHE := Nat.blt_eq.mp DEC_clearFill.cHE1)
      (hN := Nat.le_of_ble_eq_true DEC_clearFill.cNm1) (hm0 := m0_of_all DEC_clearFill.m0_1) (hndc := (Template.nodupT_sound DEC_clearFill.ndc1).2)
      (hlenc := DEC_clearFill.lenc1) (hnrLo := DEC_clearFill.nrLo1) (hder := rfl)
      (qs := DEC_clearFill.qs1) (hlq := DEC_clearFill.lq1) (hEs := hEs_of_all (by decide) DEC_clearFill.dq1)
      (hq := qs_le DEC_clearFill.qsOk1) (hR' := sub_of_all DEC_clearFill.R'1)
      (dJ := 148176) (dH := 3771) (dN := 4690) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clearFill.cRJ1) (hcH := Nat.le_of_ble_eq_true DEC_clearFill.cRH1)
      (hcN := Nat.le_of_ble_eq_true DEC_clearFill.cRN1) (hs0E := Nat.le_of_ble_eq_true DEC_clearFill.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clearFill.scE1) (hs0N := Nat.le_of_ble_eq_true DEC_clearFill.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clearFill.scN1)
    g2 := glueLinkCall (List.drop 5 Host.Load.Run.Tpl.DEC_clearFill.O) hW DEC_clearFill.chk_g2 DEC_clearFill.srv6 DEC_clearFill.ok6 R.runSeg2
      (runOk_ok_end 3657 R.runSeg2 DEC_clearFill.halt7) DEC_clearFill.halt7 R.stepA3 DEC_clearFill.top8
      (Nat.le_of_ble_eq_true DEC_clearFill.len6) (fun _ h => h) Gw.g2
    async__g2__g3 := callLink Host.Load.Run.Tpl.DEC_clearFill.st2.tpl Host.Load.Run.Tpl.DEC_clearFill.st2.O hW DEC_clearFill.chk2 Host.Load.Run.Tpl.DEC_clearFill.srvO2 (by decide +kernel)
      (hs0 := Host.Load.Run.Tpl.DEC_clearFill.iso2) (htab := Host.Load.Run.Tpl.DEC_clearFill.tab0_2) (hfoot := Host.Load.Run.Tpl.DEC_clearFill.stFoot2) (hnd := Host.Load.Run.Tpl.DEC_clearFill.wrNodup2)
      (hbd := Host.Load.Run.Tpl.DEC_clearFill.wrBound2) (htr := Host.Load.Run.Tpl.DEC_clearFill.trace2) (hmer := fun _ => Host.Load.Run.Tpl.DEC_clearFill.merged2) (hmtab := Host.Load.Run.Tpl.DEC_clearFill.mergeTab2)
      (hwsl := DEC_clearFill.wsl2) (hwsnd := (Template.nodupT_sound DEC_clearFill.wsnd2).2) (hfresh := noVar_of_all DEC_clearFill.fresh2)
      (hlen := Nat.le_of_ble_eq_true DEC_clearFill.len8) (hgtab := noVar_nth_of_all DEC_clearFill.gtab2)
      (hgθ := noVarθ_nth_of_all DEC_clearFill.gth2)
      (hgrow := call_ngrow hW Host.Load.Run.Tpl.DEC_clearFill.st2.tpl Host.Load.Run.Tpl.DEC_clearFill.iso2 Host.Load.Run.Tpl.DEC_clearFill.stFoot2 Host.Load.Run.Tpl.DEC_clearFill.wrNodup2 Host.Load.Run.Tpl.DEC_clearFill.wrBound2 Host.Load.Run.Tpl.DEC_clearFill.trace2)
      (hctab := Host.Load.Run.Tpl.DEC_clearFill.ctab2) (hdis := disj_of_all Host.Load.Run.Tpl.DEC_clearFill.cwsDisj2) (hshift := fun x0 x hcf hfq hK hB => Host.Load.Run.Tpl.DEC_clearFill.ctab2 ▸ Conv.callShift Host.Load.Run.Tpl.DEC_clearFill.zkap2
        (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearFill.jcl8) Host.Load.Run.Tpl.DEC_clearFill.cfix2 hfq
        rfl rfl Host.Load.Run.Tpl.DEC_clearFill.zpl2 Host.Load.Run.Tpl.DEC_clearFill.zplnd2 Host.Load.Run.Tpl.DEC_clearFill.zn12 Host.Load.Run.Tpl.DEC_clearFill.zfirst2 Host.Load.Run.Tpl.DEC_clearFill.zscn2 Host.Load.Run.Tpl.DEC_clearFill.zsmn2 Host.Load.Run.Tpl.DEC_clearFill.zgrow2 Host.Load.Run.Tpl.DEC_clearFill.mergeTab2
        Host.Load.Run.Tpl.DEC_clearFill.zfresh2 Host.Load.Run.Tpl.DEC_clearFill.zcnd2 DEC_clearFill.lenc2 Host.Load.Run.Tpl.DEC_clearFill.znrHi2 Host.Load.Run.Tpl.DEC_clearFill.znC2 Host.Load.Run.Tpl.DEC_clearFill.zfrlt2 xs_wideP wfr_wideP (hX_framesP DEC_clearFill.arr4910)
        (kept_of fun a ha => by
          simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
          rcases ha with rfl | rfl | rfl
          exacts [⟨Host.Load.Run.Tpl.DEC_clearFill.zg2_2673448, Host.Load.Run.Tpl.DEC_clearFill.zk2_2673448, Host.Load.Run.Tpl.DEC_clearFill.zm2_2673448⟩, ⟨Host.Load.Run.Tpl.DEC_clearFill.zg2_12504, Host.Load.Run.Tpl.DEC_clearFill.zk2_12504, Host.Load.Run.Tpl.DEC_clearFill.zm2_12504⟩, ⟨Host.Load.Run.Tpl.DEC_clearFill.zg2_2665, Host.Load.Run.Tpl.DEC_clearFill.zk2_2665, Host.Load.Run.Tpl.DEC_clearFill.zm2_2665⟩])
        (wp_present Host.Load.Run.Tpl.DEC_clearFill.zw2_4910) wf_wideP Host.Load.Run.Tpl.DEC_clearFill.zclbd2 Host.Load.Run.Tpl.DEC_clearFill.cheap2
        (hoff_of Host.Load.Run.Tpl.DEC_clearFill.mheap2 Host.Load.Run.Tpl.DEC_clearFill.stFoot2 Host.Load.Run.Tpl.DEC_clearFill.iso2 Host.Load.Run.Tpl.DEC_clearFill.zwr2) Host.Load.Run.Tpl.DEC_clearFill.ckeepP2 Host.Load.Run.Tpl.DEC_clearFill.csupp2 Host.Load.Run.Tpl.DEC_clearFill.cbound2 Host.Load.Run.Tpl.DEC_clearFill.zimg2
        Host.Load.Run.Tpl.DEC_clearFill.zctl2 Host.Load.Run.Tpl.DEC_clearFill.zstack2 Host.Load.Run.Tpl.DEC_clearFill.zjobs2 Host.Load.Run.Tpl.DEC_clearFill.zstores2 Host.Load.Run.Tpl.DEC_clearFill.zroots2 x0 x hcf hK hB.ofFb)
      (hffi := fun _ _ _ h => Host.Load.Run.Tpl.DEC_clearFill.cshiftR2 h rfl)
      (hbig := DEC_clearFill.big2) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) Host.Load.Run.Tpl.DEC_clearFill.jcl10)
        (Nat.le_of_ble_eq_true DEC_clearFill.xn2) (by decide) Host.Load.Run.Tpl.DEC_clearFill.zroots22)
      (hband := band_of (Nat.le_of_ble_eq_true DEC_clearFill.bandLo2) (Nat.le_of_ble_eq_true DEC_clearFill.bandHi) (by decide))
      (hκn := compact_num_of DEC_clearFill.kn2) (hκa := compact_fix_of DEC_clearFill.ka2) (hκv := Conv.node_of_fixOld Host.Load.Run.Tpl.DEC_clearFill.cfix2 (Nat.le_of_ble_eq_true Host.Load.Run.Tpl.DEC_clearFill.zhm2))
      (hfwd := Host.Load.Run.Tpl.DEC_clearFill.arr2_2673448) (hemit := Host.Load.Run.Tpl.DEC_clearFill.arr2_12504) (hkeep := Host.Load.Run.Tpl.DEC_clearFill.keep2 q)
      (heN := Host.Load.Run.Tpl.DEC_clearFill.arrR2_12504)
      (hJ := Nat.le_of_ble_eq_true DEC_clearFill.cJm2) (hJc := Nat.le_of_ble_eq_true DEC_clearFill.cJc2)
      (hH := Nat.le_of_ble_eq_true DEC_clearFill.cHm2) (hHE := Nat.blt_eq.mp DEC_clearFill.cHE2)
      (hN := Nat.le_of_ble_eq_true DEC_clearFill.cNm2) (hm0 := m0_of_all DEC_clearFill.m0_2) (hndc := (Template.nodupT_sound DEC_clearFill.ndc2).2)
      (hlenc := DEC_clearFill.lenc2) (hnrLo := DEC_clearFill.nrLo2) (hder := rfl)
      (qs := DEC_clearFill.qs2) (hlq := DEC_clearFill.lq2) (hEs := hEs_of_all (by decide) DEC_clearFill.dq2)
      (hq := qs_le DEC_clearFill.qsOk2) (hR' := sub_of_all DEC_clearFill.R'2)
      (dJ := 148176) (dH := 3771) (dN := 4690) (hdJ := hdJ) (hdH := hdH)
      (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true DEC_clearFill.cRJ2) (hcH := Nat.le_of_ble_eq_true DEC_clearFill.cRH2)
      (hcN := Nat.le_of_ble_eq_true DEC_clearFill.cRN2) (hs0E := Nat.le_of_ble_eq_true DEC_clearFill.s0E)
      (hscE := Nat.le_of_ble_eq_true DEC_clearFill.scE2) (hs0N := Nat.le_of_ble_eq_true DEC_clearFill.s0N)
      (hscN := Nat.le_of_ble_eq_true DEC_clearFill.scN2)
    g3 := glueLinkEndD (List.drop 5 Host.Load.Run.Tpl.DEC_clearFill.O) hW DEC_clearFill.chk_g3 DEC_clearFill.srv10 DEC_clearFill.ok10 R.runSeg3
      DEC_clearFill.top11 Host.Load.Run.Tpl.DEC_clearFill.dvs Host.Load.Run.Tpl.DEC_clearFill.des (e := (Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0) rfl DEC_clearFill.hS1D
      (hde_of_dec DEC_clearFill.hvsB (by decide))
      (Nat.le_of_ble_eq_true DEC_clearFill.len10) Gw.g3
  }

/-- **Decode case `clearFill` from chain `DEC_clearFill`** (`IterCaseW`) at the prompt route's instance, A4's end facts
(`DEC_clearFill.iterEnd`, `DEC_clearFill.shiftFW`, `DEC_clearFill.keep`). -/
noncomputable def DEC_clearFill.caseBounded (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : 148176 ≤ ΔJ) (hH : 3771 ≤ ΔH) (hN : 4690 ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).next + T * ΔH + B.H + (DEC_clearFill.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).nnext + T * ΔN + B.N + (DEC_clearFill.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s0.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Template.wideP DEC_clearFill.Pw (Template.framesP Host.Load.Run.Tpl.DEC_clearFill.s0 q) Host.Load.Run.Tpl.DEC_clearFill.s0 Host.Load.Run.Tpl.DEC_clearFill.S0.tab Template.fixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .clearFill) where
  e := (Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0
  g := DEC_clearFill.g3 b0 NB DEC_clearFill.eN
  chain := (DEC_clearFill.piecesBounded (E0 := E0) (B := B) q DEC_clearFill.runs hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := Host.Load.Run.Tpl.DEC_clearFill.shiftFW NB q
  keep := Host.Load.Run.Tpl.DEC_clearFill.keep q
  emit := DEC_clearFill.emitTok b0 NB
  within := DEC_clearFill.within (e := (Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0) DEC_clearFill.eN rfl hJ hH hN

end

end Host.Ts.Sim.Compose
