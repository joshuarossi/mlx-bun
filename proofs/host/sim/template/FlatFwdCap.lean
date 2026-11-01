import host.sim.template.FlatFwd
import host.sim.full.JsLimit
import host.sim.conv.RunAccept
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # A flat forward at the admitted offset

A tailed forward's context has the offset its first tail's compactions left, far above the 4096 its chunks are checked at. The
chunks stay checked at `typedOk`; `okL` is the same acceptance at the offset `cap`, `lifted` and `liftedRun` move them there, and the pieces
`toCall`, `size`, `finish` compose at `simulationCap`. -/

namespace Host.Load.Run.Tpl.FlatFwd
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk Host.Load.Layers

/-- `typedOk` at the offset `cap`. -/
noncomputable def okL (f : Fr) (bytes : List Byte) (cap : Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSJLimit (f.typedJ bytes) jsSignedLimit cap (okBackFXS setupP)

theorem lifted {f : Fr} {bytes : List Byte} {cap : Nat} {s : St FF.S} {S : SSrv}
    (hcap : cap ≤ 4096 + 1593835520) (h : f.typedOk bytes s S = true) : okL f bytes cap s S = true :=
  Disp.okJSJLimit_signed_of_allowance hcap h

theorem liftedRun {f : Fr} {bytes : List Byte} {cap n : Nat} {s s1 : St FF.S} {S S1 : SSrv}
    (hcap : cap ≤ 4096 + 1593835520) (h : runOk FF (f.typedOk bytes) n s S = some (s1, S1)) :
    runOk FF (okL f bytes cap) n s S = some (s1, S1) :=
  runOk_mono (fun _ _ => lifted hcap) h

theorem simulationCap (f : Fr) (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (cap : Nat) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Native NB T tk y0) (okL f bytes cap)
      (Disp.KpJ (f.typedJ bytes) cap) (f.typedW bytes) [] (VP f.row) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (f.typedJ bytes).okCall = okCallFXS P := (okCallFXS_rest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) (f.typedJ bytes).okCall Full.smallFXS := by
    rw [hj]; exact fullCallSimXS P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJSLimit (P := f.typedJ bytes) (D0 := cap) (stk := [])
    (VBOk := VP f.row) (Nat.le_refl _) ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFX2_sound hν hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB (f.typedJ bytes) rfl rfl rfl).liftQ (f.typed_wp bytes)
  simpa only [P, backRest, okL] using hs

/-- `Laws` at the offset `cap`. -/
structure LawsCap (f : Fr) (bytes : List Byte) (cap : Nat) (ps : List Lin.Prm) (V : List (Nat × Lin.Aff)) (Book : SegInst FF → Prop) : Prop where
  hcap : cap ≤ 4096 + 1593835520
  context : ∀ x, Book x → Disp.KpJ (f.typedJ bytes) cap x.K
  valuation : ∀ x, Book x → VP f.row x.ν
  box : ∀ x, Book x → ∃ v, Lin.InBox ps 0 v ∧ Lin.VarsOk x.ν v V
  ext : ∀ {x : SegInst FF} {M' : Map} {t' : St FF.S} {C' : CSrv} {n : Nat}, Book x → Ext x.M M' n →
    Book ⟨M', x.ν, x.K, t', C'⟩
  restart : ∀ {x : SegInst FF} {M' : Map} {t' : St FF.S} {C' : CSrv} {n : Nat} {e : Event} {base : List Event}
    {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame} {s : St FF.S} {S : SSrv},
    Book x → Ext x.M M' n → RelB FF FR W [] x.M x.ν x.K s S x.t x.C → t'.trace = e :: x.t.trace →
    Book ⟨M', x.ν, ⟨x.K.fr, base, t'.trace, x.K.D, x.K.lo, x.K.hi⟩, t', C'⟩

private theorem freshC {NB T : Nat} {tk : Nat → Nat} {y0 : Host.Mlx.Ffi.St}
    {W : Nat → Option WFrame} {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (Native NB T tk y0) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Native NB T tk y0) W [] M' ν K' sb Sb t' C')
    (hi : (bridgeOf sa.ffi).active = false) (he : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hf : AneFresh t) : AneFresh t' := by
  obtain ⟨_, _, r0⟩ := hr.ffi.1.1
  obtain ⟨_, _, r1⟩ := hr'.ffi.1.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) he).trans hi
  have hb : bridgeOf t'.ffi = bridgeOf t.ffi :=
    (r1.toR hi').bridge.1.trans (he.trans (r0.toR hi).bridge.1.symm)
  intro Cx Pc Kc weights kind NE IP G init
  rw [hb]
  exact hf Cx Pc Kc weights kind NE IP G init

private theorem fixedC {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : fixedCells (⟨M, ν, K, t, C⟩ : SegInst FF)) (he : Ext M M' n) :
    fixedCells (⟨M', ν, K', t', C'⟩ : SegInst FF) := by
  constructor
  · change M'.a 2586 = 2586
    rw [he.a]
    exact h.1
  · change M'.a 2589 = 2589
    rw [he.a]
    exact h.2

section
variable {f : Fr} {NB T n cap : Nat} {tk : Nat → Nat} {bytes : List Byte} {ps : List Lin.Prm} {V : List (Nat × Lin.Aff)}
  {Book : SegInst FF → Prop} {M0 : Map} {y0 : Host.Mlx.Ffi.St}

theorem toCallCap (L : LawsCap f bytes cap ps V Book) {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (hb : (fun bs : List Byte => f.typedOk bs sb Sb) = fun _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sc Sc) (n + 1) := by
  apply cut_glueCall (simulationCap f NB T tk bytes cap y0)
    (lifted L.hcap (congrFun ha _)) (liftedRun L.hcap (hrun _)) (lifted L.hcap (congrFun hb _)) hh hs htop
  · intro x hbook _
    exact ⟨L.context x hbook, L.valuation x hbook⟩
  · intro x hbook _
    obtain ⟨v, hv, hρ⟩ := L.box x hbook
    exact Lin.goodLin_sound hgood hv hρ
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), L.ext hbook he⟩,
      freshC hr hrel hi hbr hB.1, fixedC hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem finishCap (L : LawsCap f bytes cap ps V Book) {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sb Sb) n := by
  apply cut_glue (simulationCap f NB T tk bytes cap y0) (lifted L.hcap (congrFun ha _)) (liftedRun L.hcap (hrun _)) htop
  · intro x hbook _
    exact ⟨L.context x hbook, L.valuation x hbook⟩
  · intro x hbook _
    obtain ⟨v, hv, hρ⟩ := L.box x hbook
    exact Lin.goodLin_sound hgood hv hρ
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), L.ext hbook he⟩,
      freshC hr hrel hi hbr hB.1, fixedC hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem sizeCap (L : LawsCap f bytes cap ps V Book) {sa sb : St FF.S} {Sa Sb Sdec : SSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} {asR : List Arg}
    (hparts : Disp.sizeParts sa = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk sa = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hta : ta ∉ [2665, f.chunk, f.buffer, f.view] ++ ghostPf)
    (hdec : interpS (decodeArgs FF sa tys args).run Sa = some (some asR, Sdec))
    (hpre : sizePreB loopVB Sdec sa.ffi asR = true)
    (hsize : interpS (Disp.sizeS FF sa).run Sa = some (sb, Sb))
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sb Sb) 3 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hbook⟩, hf, hfixed, he0⟩
  have hctx := L.context x hbook
  have hval := L.valuation x hbook
  obtain ⟨v, hv, hρ⟩ := L.box x hbook
  have hg := Lin.goodLin_sound hgood hv hρ
  have hr0 := hr.withOracle hg
  have hfr : x.K.fr ta = none := by
    by_contra h
    exact hta ((hctx.1.2.2 ta).mp h)
  have hpre0 : ∀ ars S1, interpS (decodeArgs FF sa tys args).run Sa = some (some ars, S1) →
      D1BodySize.Pre x.ν S1 sa.ffi ars := by
    intro ars S1 hd
    exact ⟨sizePre_of hdec hpre hval.1 ars S1 hd, hi⟩
  obtain ⟨M', t', C', _, ⟨⟨gg, hrel, ars, ret, ars', ret', w, hs, ht, hw, hw'⟩, hrun⟩⟩ :=
    (D1BodySize.growAt y0 hr0 hparts hargs hsym hm hpay hfr hpre0).run sb Sb hsize
  let K' : Host.Ts.Sim.Ctx := ⟨x.K.fr, sb.trace, t'.trace, x.K.D, x.K.lo, x.K.hi⟩
  have hb' : Book ⟨M', x.ν, K', t', C'⟩ := L.restart hbook gg.ext hr0 ht
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨hrel.withOracle (fun _ h => nomatch h), hb'⟩,
    freshC hr hrel hi hbr hf, fixedC hfixed gg.ext, he0.trans (gg.ext.mono h20) (Nat.le_refl _)⟩

end

end Host.Load.Run.Tpl.FlatFwd
