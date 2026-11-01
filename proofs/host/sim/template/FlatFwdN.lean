import host.sim.template.FlatFwdCap
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # A flat forward whose start's table is short

`FlatFwd.cut` keeps the map's first 20 table entries; a first forward's start can have fewer. `cutN e` keeps the first `e`. -/

namespace Host.Load.Run.Tpl.FlatFwd
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk Host.Load.Layers

/-- `cut`, keeping the first `e` entries. -/
noncomputable def cutN (e : Nat) (f : Fr) (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (Book : SegInst FF → Prop)
    (M0 : Map) (y0 : Host.Mlx.Ffi.St) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => RelB FF (Native NB T tk y0) (f.typedW bytes) [] x.M x.ν x.K s S x.t x.C ∧ Book x
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ Ext M0 x.M e

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
variable {e : Nat} {f : Fr} {NB T n cap : Nat} {tk : Nat → Nat} {bytes : List Byte} {ps : List Lin.Prm} {V : List (Nat × Lin.Aff)}
  {Book : SegInst FF → Prop} {M0 : Map} {y0 : Host.Mlx.Ffi.St}

theorem toCallN (L : LawsCap f bytes cap ps V Book) {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (hb : (fun bs : List Byte => f.typedOk bs sb Sb) = fun _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (h20 : e ≤ Sa.tab.length) :
    CutStep (cutN e f NB T tk bytes Book M0 y0 sa Sa) (cutN e f NB T tk bytes Book M0 y0 sc Sc) (n + 1) := by
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

theorem finishN (L : LawsCap f bytes cap ps V Book) {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : e ≤ Sa.tab.length) :
    CutStep (cutN e f NB T tk bytes Book M0 y0 sa Sa) (cutN e f NB T tk bytes Book M0 y0 sb Sb) n := by
  apply cut_glue (simulationCap f NB T tk bytes cap y0) (lifted L.hcap (congrFun ha _)) (liftedRun L.hcap (hrun _)) htop
  · intro x hbook _
    exact ⟨L.context x hbook, L.valuation x hbook⟩
  · intro x hbook _
    obtain ⟨v, hv, hρ⟩ := L.box x hbook
    exact Lin.goodLin_sound hgood hv hρ
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), L.ext hbook he⟩,
      freshC hr hrel hi hbr hB.1, fixedC hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem sizeN (L : LawsCap f bytes cap ps V Book) {sa sb : St FF.S} {Sa Sb Sdec : SSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} {asR : List Arg}
    (hparts : Disp.sizeParts sa = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk sa = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hta : ta ∉ [2665, f.chunk, f.buffer, f.view] ++ f.ghosts)
    (hdec : interpS (decodeArgs FF sa tys args).run Sa = some (some asR, Sdec))
    (hpre : sizePreB loopVB Sdec sa.ffi asR = true)
    (hsize : interpS (Disp.sizeS FF sa).run Sa = some (sb, Sb))
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : e ≤ Sa.tab.length) :
    CutStep (cutN e f NB T tk bytes Book M0 y0 sa Sa) (cutN e f NB T tk bytes Book M0 y0 sb Sb) 3 := by
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
