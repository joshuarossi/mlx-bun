import host.sim.conv.Site
import host.sim.RestartDrop
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage

/-! # Isolate under the caller's frames

`isolate` asks the template's present addresses to be unframed in the caller (`Iso.unfr`). A prefill
caller frames entries a stage reads: the prompt (a framed array), ghost cells, by-key maps.
`isolateW` drops that condition. The template's context frames exactly the preimages of the caller's
framed addresses (`isoCtxW`): a framed array with its whole start array as its prefix and the
target's array as the target prefix (so nothing is appended yet: `FramedObj` with `xs = []`), and
any other framed entry under the caller's frame at its image (`W0 b = W (σ.a b)`, the frame's names
fixed by `σ`: `WFix`, as the restart asks; `WideOK.after`). The rest is `isolate`'s.

**The projection to the class needs no merge**: `site_classW` (as `site_class`) isolates the site
instance's start into the class template's start, runs the class template, and identifies the two runs
by determinism, so the class's end relation (and every fact proven once for the class) holds at the
site's return. Only the isolate is needed, under the caller's frames. -/

/-- **The call morphism without `Iso.unfr`.** -/
structure IsoW (F : Ffi) (FS : Map → F.S → F.S → Prop) (σ : Map) (θ : Nat → SymE) (K : Ctx) (rs : List Frame)
    (s0 : St F.S) (S0 : SSrv) (s : St F.S) (S : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → s.heap.get (σ.a a) = some (σ.hobj h)
  next : ∀ k, σ.a (s0.next + k) = s.next + k
  grows : s0.next ≤ s.next
  inj : ∀ a b, Present s0 a → Present s0 b → σ.a a = σ.a b → a = b
  presentBound : ∀ a, Present s0 a → a < s0.next
  ctl : s.ctl = σ.ctl s0.ctl
  stack : s.stack = s0.stack.map σ.frame ++ rs
  jobs : s.jobs = s0.jobs.map σ.job
  stores : s.stores = σ.stores s0.stores
  ffi : FS σ s0.ffi s.ffi
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) S0.tab.length h
  ctlSupp : Supp.ctl (Present s0) S0.tab.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) S0.tab.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) S0.tab.length j
  storesSupp : Supp.stores (Present s0) S0.tab.length s0.stores
  bigFixed : ∀ i, BigFixed K.lo K.hi i → σ.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → σ.big (ptrInt (.ext r) off) = ptrInt (.ext (σ.region r)) off
  intr : ∀ a, a < aFirst → σ.a a = a

theorem Iso.toW {F : Ffi} {FS : Map → F.S → F.S → Prop} {σ : Map} {θ : Nat → SymE} {K : Ctx} {rs : List Frame}
    {s0 s : St F.S} {S0 S : SSrv} (h : Iso F FS σ θ K rs s0 S0 s S) : IsoW F FS σ θ K rs s0 S0 s S :=
  ⟨h.num, h.heap, h.next, h.grows, h.inj, h.presentBound, h.ctl, h.stack, h.jobs, h.stores, h.ffi, h.heapSupp,
    h.ctlSupp, h.stackSupp, h.jobsSupp, h.storesSupp, h.bigFixed, h.bigExt, h.intr⟩

/-- An entry's array elements (none if it is not an array). -/
def arrElems : Option HObj → List Val
  | some (.obj o) => match o.kind with
    | .array es => es
    | _ => []
  | _ => []

/-- The isolated framed arrays: the preimages of the caller's framed addresses, with the start's and
the target's arrays as prefixes. -/
def isoFr {S : Type} (K : Ctx) (σ M : Map) (s0 t : St S) (b : Nat) : Option (List Val × List Val) :=
  match s0.heap.get b, K.fr (σ.a b) with
  | some h0, some _ => some (arrElems (some h0), arrElems (t.heap.get (M.a (σ.a b))))
  | _, _ => none

/-- **The context of the isolated relation under the caller's frames** (`isoCtx` with `isoFr`). -/
def isoCtxW {S : Type} (K : Ctx) (σ M : Map) (s0 t : St S) : Ctx :=
  ⟨isoFr K σ M s0 t, s0.trace, t.trace, t.next - s0.next, K.lo, K.hi⟩

section
variable {S : Type} {K : Ctx} {σ M : Map} {s0 t : St S} {b : Nat}

theorem isoFr_none {h0 : HObj} (hg : s0.heap.get b = some h0) (hk : K.fr (σ.a b) = none) :
    isoFr K σ M s0 t b = none := by
  simp only [isoFr, hg, hk]

theorem isoFr_some {h0 : HObj} {p : List Val × List Val} (hg : s0.heap.get b = some h0) (hk : K.fr (σ.a b) = some p) :
    isoFr K σ M s0 t b = some (arrElems (some h0), arrElems (t.heap.get (M.a (σ.a b)))) := by
  simp only [isoFr, hg, hk]

theorem isoFr_present {p : List Val × List Val} (h : isoFr K σ M s0 t b = some p) : Present s0 b := by
  cases hg : s0.heap.get b with
  | none => simp [isoFr, hg] at h
  | some h0 => exact Present.of_get hg

/-- The isolated context frames exactly the preimages of the caller's framed addresses. -/
theorem isoFr_iff (hb : Present s0 b) : isoFr K σ M s0 t b ≠ none ↔ K.fr (σ.a b) ≠ none := by
  obtain ⟨h0, hg⟩ := Present.get hb
  cases hk : K.fr (σ.a b) with
  | none => simp [isoFr_none hg hk]
  | some p => simp [isoFr_some (M := M) (t := t) hg hk]

end

theorem Map.kind_array {σ : Map} {k : Kind} {es : List Val} (h : σ.kind k = .array es) :
    ∃ es0, k = .array es0 ∧ es = σ.vals es0 := by
  cases k with
  | array m => exact ⟨m, rfl, (Kind.array.inj h).symm⟩
  | _ => cases h

section
variable {F : Ffi} {FR FR0 : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W0 : Nat → Option WFrame} {stk : List Frame}
  {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {K : Ctx} {rs : List Frame} {s0 s t : St F.S} {S0 S : SSrv} {C : CSrv}

/-- The heap clause under the caller's frames. -/
theorem isoW_slot (h : RelB F FR W stk M ν K s S t C) (hs : IsoW F FS σ θ K rs s0 S0 s S)
    (hW0 : ∀ b, Present s0 b → W0 b = W (σ.a b))
    (hwf : ∀ b w, Present s0 b → W (σ.a b) = some w → K.fr (σ.a b) ≠ none → WFix σ (Present s0) w)
    {a : Nat} {h' : HObj} (ha : s0.heap.get a = some h') :
    SlotW (M.after σ) (isoFr K σ M s0 t) W0 a h' (t.heap.get ((M.after σ).a a)) := by
  have hP : Present s0 a := Present.of_get ha
  have h1 := h.heap _ _ (hs.heap a h' ha)
  show SlotW (M.after σ) (isoFr K σ M s0 t) W0 a h' (t.heap.get (M.a (σ.a a)))
  cases hk : K.fr (σ.a a) with
  | none =>
    have e1 := (SlotW.of_fr_none hk).1 h1
    refine (SlotW.of_fr_none (isoFr_none ha hk)).2 ?_
    rw [e1, Map.hobj_after]
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    have hfr := isoFr_some (M := M) (t := t) ha hk
    unfold SlotW at h1 ⊢
    rw [hW0 a hP]
    cases hw : W (σ.a a) with
    | some w =>
      rw [hw, hk] at h1
      simp only [hfr]
      exact WideOK.after (hwf a w hP hw (by rw [hk]; simp)) hs.inj (hs.heapSupp a h' ha) h1
    | none =>
      rw [hw] at h1
      simp only [SlotOK, hk] at h1
      obtain ⟨o, o', ho, ht, xs, hkind, ho'⟩ := h1
      cases h' with
      | cell v => cases ho
      | obj o0 =>
        cases ho
        obtain ⟨es0, hk0, hes⟩ := Map.kind_array hkind
        simp only [SlotOK, hfr]
        refine ⟨o0, o', rfl, ht, [], ?_, ?_⟩
        · show o0.kind = .array (arrElems (some (.obj o0)) ++ [])
          simp only [arrElems, hk0, List.append_nil]
        · rw [ht, ho', Map.obj_after]
          simp [arrElems, Map.vals]

/-- **Isolate under the caller's frames** (`isolate` without `Iso.unfr`): the template's context
frames the preimages of the caller's framed addresses (`isoCtxW`), its frames `W0` are the caller's at
the images. -/
theorem isolateW
    (hFS : ∀ x y z, FS σ x y → FR M S.tab.length y z → FR0 (M.after σ) S0.tab.length x z)
    (h : RelB F FR W stk M ν K s S t C) (hs : IsoW F FS σ θ K rs s0 S0 s S)
    (hW0 : ∀ b, Present s0 b → W0 b = W (σ.a b))
    (hwf : ∀ b w, Present s0 b → W (σ.a b) = some w → K.fr (σ.a b) ≠ none → WFix σ (Present s0) w)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) :
    RelB F FR0 W0 (rs.map M.frame ++ stk) (M.after σ) (Shift.valuation θ ν) (isoCtxW K σ M s0 t) s0 S0 t C := by
  refine
    { srv := ⟨fun i e he => ?_, hg⟩
      heap := fun a h' ha => isoW_slot h hs hW0 hwf ha
      next := fun k => ?_
      offset := ?_
      room := hroom
      bigFixed := fun i hi => ?_
      bigExt := fun r off hoff => ?_
      band := h.band
      intr := fun a ha => by
        show M.a (σ.a a) = a
        rw [hs.intr a ha, h.intr a ha]
      bound := fun a ha => h.bound _ (by obtain ⟨h0, hg0⟩ := Present.get ha; exact Present.of_get (hs.heap a h0 hg0))
      inj := fun a b ha hb hab => by
        have pa : Present s (σ.a a) := by obtain ⟨h0, hg0⟩ := Present.get ha; exact Present.of_get (hs.heap a h0 hg0)
        have pb : Present s (σ.a b) := by obtain ⟨h0, hg0⟩ := Present.get hb; exact Present.of_get (hs.heap b h0 hg0)
        exact hs.inj a b ha hb (h.inj _ _ pa pb hab)
      presentBound := hs.presentBound
      framedPresent := fun a p hp => isoFr_present hp
      ctl := ?_
      stack := ?_
      jobs := ?_
      stores := ?_
      ffi := hFS _ _ _ hs.ffi h.ffi
      trace := ⟨[], by simp [isoCtxW], by simp [isoCtxW]⟩
      heapSupp := hs.heapSupp
      ctlSupp := hs.ctlSupp
      stackSupp := hs.stackSupp
      jobsSupp := hs.jobsSupp
      storesSupp := hs.storesSupp
      traceSupp := ⟨[], by simp [isoCtxW], by simp⟩ }
  · have h1 := h.srv.num.val (hs.num i e he)
    rw [SymE.eval_subst] at h1
    exact h1
  · show M.a (σ.a (s0.next + k)) = t.next + k
    rw [hs.next, h.next]
  · have := h.offset
    have := hs.grows
    show t.next = s0.next + (t.next - s0.next)
    omega
  · show M.big (σ.big i) = i
    rw [hs.bigFixed i hi, h.bigFixed i hi]
  · show M.big (σ.big (ptrInt (.ext r) off)) = ptrInt (.ext (M.region (σ.region r))) off
    rw [hs.bigExt r off hoff, h.bigExt _ off hoff]
  · rw [h.ctl, hs.ctl, Map.ctl_after]
  · rw [h.stack, hs.stack, List.map_append, List.map_map, List.append_assoc]
    exact congrArg (· ++ (rs.map M.frame ++ stk)) (List.map_congr_left fun f _ => Map.frame_after M σ f)
  · rw [h.jobs, hs.jobs, List.map_map]
    exact List.map_congr_left fun j _ => Map.job_after M σ j
  · rw [h.stores, hs.stores, Map.stores_after]

end

/-! ## The projection to the class under the caller's frames -/

section
variable {F : Ffi} {FR FRc : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W0 : Nat → Option WFrame} {ok okc : St F.S → SSrv → Bool}
  {Kpc : Ctx → Prop} {VBc : (Nat → F64) → Prop} {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {K : Ctx}
  {t t' : St F.S} {C C' : CSrv} {r : List Frame}

/-- **A site instance projects to its class under the caller's frames** (`site_class` without
`Iso.unfr`): the class template's run from the isolated site start is the site's run, so the class's
end relation holds at the site's return, in the class's context `isoCtxW` (its framed list the
preimages of the caller's, `Kpc`) and frames `W0` (the caller's at the images). No merge is used. -/
theorem site_classW (Tc : StageTpl F okc) (Ts : StageTpl F ok)
    (hsimc : Disp.StepSimXLB F FRc okc Kpc W0 r VBc) (hlocc : ∀ s S, okc s S = true → Disp.localB s = true)
    (hn : Tc.n = Ts.n)
    (hFS : ∀ x y z, FS σ x y → FR M Ts.S0.tab.length y z → FRc (M.after σ) Tc.S0.tab.length x z)
    (hiso : IsoW F FS σ θ K [] Tc.s0 Tc.S0 Ts.s0 Ts.S0)
    (hW0 : ∀ b, Present Tc.s0 b → W0 b = W (σ.a b))
    (hwf : ∀ b w, Present Tc.s0 b → W (σ.a b) = some w → K.fr (σ.a b) ≠ none → WFix σ (Present Tc.s0) w)
    (hKc : Kpc (isoCtxW K σ M Tc.s0 t)) (hνc : VBc (Shift.valuation θ ν))
    (hg : Good (Shift.valuation θ ν) Tc.S0.oracle) (hroom : t.next - Tc.s0.next < Sim.bound)
    (h : RelB F FR W r M ν K Ts.s0 Ts.S0 t C) (hrun : runC F (Ts.n + 1) t C = some (t', C')) :
    ∃ M2, Ext (M.after σ) M2 Tc.S0.tab.length ∧
      RelB F FRc W0 r M2 (Shift.valuation θ ν) (isoCtxW K σ M Tc.s0 t) Tc.s2 Tc.S2 t' C' := by
  have h0 : RelB F FRc W0 r (M.after σ) (Shift.valuation θ ν) (isoCtxW K σ M Tc.s0 t) Tc.s0 Tc.S0 t C := by
    have := isolateW (W0 := W0) hFS h hiso hW0 hwf hg hroom
    simpa using this
  obtain ⟨M2, t2, C2, hrun2, he, h2⟩ := Tc.runB hsimc hlocc hKc hνc h0
  rw [hn, hrun] at hrun2
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj hrun2)
  exact ⟨M2, he, h2⟩

end

end Host.Ts.Sim.Conv
