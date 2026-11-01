import host.route.SetupEntry
import host.sim.dispatch.BridgeTyped
import host.sim.compose.Glue
import host.sim.compose.a4b.SetupChunkStage
import host.sim.template.a4pre_d1_body.SizeAt
import host.sim.full.RunFast
import host.sim.LinGood
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # A flat D1 forward, for any frames and book

A forward chain with no stage cuts: its glue stretches and size bridges, at the typed acceptance of the
class's chunk, buffer and view addresses (`Fr`), the book the caller's (`Laws`). The chain's generated pieces
compose `toCall`, `size`, `finish` into a `CutStep` from the call to the return, `genFlatFwd.ts`. -/

namespace Host.Load.Run.Tpl.FlatFwd
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- A class's chunk array, its buffer and its view. -/
structure Fr where
  chunk : Nat
  buffer : Nat
  view : Nat
  hvb : Nat.beq view buffer = false
  hbv : Nat.beq buffer view = false

namespace Fr
variable (f : Fr)

def typedW (bytes : List Byte) : Nat → Option WFrame :=
  Disp.wAt (Disp.wAt wideP f.buffer (.buf bytes)) f.view (.typed .i32 f.buffer 0 1)

abbrev typedJ (bytes : List Byte) : Disp.JSP FF :=
  fullJSPPXS setupP [2665, f.chunk, f.buffer, f.view]
    [(f.buffer, .buf bytes), (f.view, .typed .i32 f.buffer 0 1), (4910, .memo [])]

noncomputable def typedOk (bytes : List Byte) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (f.typedJ bytes) (okBackFXS setupP) 4096

/-- `typedOk` over the fast table. -/
noncomputable def typedOkN (bytes : List Byte) : St FF.S → FSrv → Bool :=
  Disp.okJSJN (f.typedJ bytes) (okBackFXS setupP) 4096 (smallFX2F loopVB)

theorem typedOkN_ok (bytes : List Byte) (s : St FF.S) (c : FSrv) (h : c.Wf) :
    f.typedOkN bytes s c = f.typedOk bytes s c.toS :=
  Disp.okJSJN_eq (f.typedJ bytes) (okBackFXS setupP) 4096 (fun _ x name args hw => smallFX2F_eq loopVB hw x name args) s h

theorem typed_wp (bytes : List Byte) : Disp.Wp (f.typedJ bytes) (f.typedW bytes) := by
  intro a w hw
  change Disp.lookupW a [(f.buffer, .buf bytes), (f.view, .typed .i32 f.buffer 0 1), (4910, .memo [])] = some w
  have e1 := f.hvb
  have e2 := f.hbv
  by_cases hv : a = f.view
  · subst hv
    simpa only [typedW, Disp.wAt, Disp.lookupW, e1, Nat.beq_refl, Bool.cond_true, Bool.cond_false] using hw
  · have ev := Template.beq_false hv
    by_cases hb : a = f.buffer
    · subst hb
      simpa only [typedW, Disp.wAt, Disp.lookupW, e2, Nat.beq_refl, Bool.cond_true, Bool.cond_false] using hw
    · have eb := Template.beq_false hb
      simpa only [typedW, Disp.wAt, ev, eb, Bool.cond_false, wideP, Disp.lookupW] using hw

end Fr

abbrev Native (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :=
  Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
    (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))

/-- What the caller's book gives and keeps across the forward. `box`: the valuation lies in the class the
chain's oracle was checked over. -/
structure Laws (f : Fr) (bytes : List Byte) (ps : List Lin.Prm) (V : List (Nat × Lin.Aff)) (Book : SegInst FF → Prop) : Prop where
  context : ∀ x, Book x → Disp.KpJ (f.typedJ bytes) 4096 x.K
  valuation : ∀ x, Book x → VBOkF loopVB x.ν
  box : ∀ x, Book x → ∃ v, Lin.InBox ps 0 v ∧ Lin.VarsOk x.ν v V
  ext : ∀ {x : SegInst FF} {M' : Map} {t' : St FF.S} {C' : CSrv} {n : Nat}, Book x → Ext x.M M' n →
    Book ⟨M', x.ν, x.K, t', C'⟩
  restart : ∀ {x : SegInst FF} {M' : Map} {t' : St FF.S} {C' : CSrv} {n : Nat} {e : Event} {base : List Event}
    {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame} {s : St FF.S} {S : SSrv},
    Book x → Ext x.M M' n → RelB FF FR W [] x.M x.ν x.K s S x.t x.C → t'.trace = e :: x.t.trace →
    Book ⟨M', x.ν, ⟨x.K.fr, base, t'.trace, x.K.D, x.K.lo, x.K.hi⟩, t', C'⟩

/-- A chain's answers are a suffix of the checked oracle. -/
theorem goodLin_drop {ps : List Lin.Prm} {V : List (Nat × Lin.Aff)} {O : List Ans} (h : Lin.goodLin ps V O = true) (m : Nat) :
    Lin.goodLin ps V (O.drop m) = true := by
  unfold Lin.goodLin at h ⊢
  rw [List.all_eq_true] at h ⊢
  exact fun q hq => h q (List.mem_of_mem_drop hq)

/-- A cut of the forward: related at the class's frames, the book, and the bookkeeping every forward keeps. -/
noncomputable def cut (f : Fr) (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (Book : SegInst FF → Prop)
    (M0 : Map) (y0 : Host.Mlx.Ffi.St) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => RelB FF (Native NB T tk y0) (f.typedW bytes) [] x.M x.ν x.K s S x.t x.C ∧ Book x
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ Ext M0 x.M 20

theorem simulation (f : Fr) (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Native NB T tk y0) (f.typedOk bytes)
      (Disp.KpJ (f.typedJ bytes) 4096) (f.typedW bytes) [] (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (f.typedJ bytes).okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJSQ P NB loopVB (f.typedJ bytes) 4096 hj rfl rfl rfl rfl rfl []
    (f.typed_wp bytes) y0
  simpa only [Native, P, backRest, Fr.typedOk] using hs

private theorem fresh {NB T : Nat} {tk : Nat → Nat} {y0 : Host.Mlx.Ffi.St}
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

private theorem fixed {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
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
variable {f : Fr} {NB T n : Nat} {tk : Nat → Nat} {bytes : List Byte} {ps : List Lin.Prm} {V : List (Nat × Lin.Aff)}
  {Book : SegInst FF → Prop} {M0 : Map} {y0 : Host.Mlx.Ffi.St}

theorem toCall (L : Laws f bytes ps V Book) {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (hb : (fun bs : List Byte => f.typedOk bs sb Sb) = fun _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sc Sc) (n + 1) := by
  apply cut_glueCall (simulation f NB T tk bytes y0)
    (congrFun ha _) (hrun _) (congrFun hb _) hh hs htop
  · intro x hbook _
    exact ⟨L.context x hbook, L.valuation x hbook⟩
  · intro x hbook _
    obtain ⟨v, hv, hρ⟩ := L.box x hbook
    exact Lin.goodLin_sound hgood hv hρ
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), L.ext hbook he⟩,
      fresh hr hrel hi hbr hB.1, fixed hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem finish (L : Laws f bytes ps V Book) {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sb Sb) n := by
  apply cut_glue (simulation f NB T tk bytes y0) (congrFun ha _) (hrun _) htop
  · intro x hbook _
    exact ⟨L.context x hbook, L.valuation x hbook⟩
  · intro x hbook _
    obtain ⟨v, hv, hρ⟩ := L.box x hbook
    exact Lin.goodLin_sound hgood hv hρ
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), L.ext hbook he⟩,
      fresh hr hrel hi hbr hB.1, fixed hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem size (L : Laws f bytes ps V Book) {sa sb : St FF.S} {Sa Sb Sdec : SSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} {asR : List Arg}
    (hparts : Disp.sizeParts sa = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk sa = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hta : ta ∉ [2665, f.chunk, f.buffer, f.view])
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
    exact ⟨sizePre_of hdec hpre hval ars S1 hd, hi⟩
  obtain ⟨M', t', C', _, ⟨⟨gg, hrel, ars, ret, ars', ret', w, hs, ht, hw, hw'⟩, hrun⟩⟩ :=
    (D1BodySize.growAt y0 hr0 hparts hargs hsym hm hpay hfr hpre0).run sb Sb hsize
  let K' : Host.Ts.Sim.Ctx := ⟨x.K.fr, sb.trace, t'.trace, x.K.D, x.K.lo, x.K.hi⟩
  have hb' : Book ⟨M', x.ν, K', t', C'⟩ := L.restart hbook gg.ext hr0 ht
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨hrel.withOracle (fun _ h => nomatch h), hb'⟩,
    fresh hr hrel hi hbr hf, fixed hfixed gg.ext, he0.trans (gg.ext.mono h20) (Nat.le_refl _)⟩

end

end Host.Load.Run.Tpl.FlatFwd
